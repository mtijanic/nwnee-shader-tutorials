# Framebuffer effects

Framebuffer effects, also known as fullscreen shaders or per-pixel shaders are a post-processing step where a custom FS is applied to the entire scene after it was already rendered.

## How to use FB shaders

NWN:EE currently only has 3 Framebuffer Effects available:

- Depth of Field
- High Contrast
- Vibrance

These are activated in the Graphics Options, under "Advanced Framebuffer Effects".

Adding new effects to the game is currently not supported, but you can override the existing ones. Your new FS should be named:

- `fsFBDOF.shd` to replce Depth of Field
- `fsFBLVLS.shd` to replace High Contrast
- `fsFBVIB.shd` to replace Vibrance

and placed in your `override/` folder.

These shaders are compiled when the game starts, and as such can't be put in a per-module .hak file. Hopefully, this will change in the future when support for custom FB effects is added to the game.


### Ambient Occlusion

A fourth FB effect is present, called Ambient Occlusion, but disabled. You can enable it in the nwn.ini file by adding:

    [Video Options]
    Enable FBEffect Ambient Occlusion=1

To override this effect (leaving the other three available), the shader should be named `fsFBSSAO.shd`.


## Writing a custom FB shader

Note that in the following examples, the variable declarations will not be repeated. All `main()` functions are complete, but they require the declarations above them. If a `main()` function uses some variable, you will find a declaration for it in a previous snippet - use those.

### Vertex shader

A framebuffer effect does have a vertex shader attached to it, but it isn't of much use. Since everything has been previously drawn to a texture, all that is drawn now is one rectangle over the entire screen.

Modifying the bounds of that rectangle could implement a zoom feature, or possibly some kind of split-screen effect, but it will cause conflicts with the code that detects where a mouse is pointing (since it will be pointing in the original scene), so there is little practical use for it. Still, in the interest of completeness, let's examine the full VS for a FB effect:

    attribute vec3 vPos;   // Absolute vertex position of rectangle corners
    attribute vec2 vTcIn;  // Texture position of that corner
    varying vec2 vTcOut;   // Output, input to FS

    void main()
    {
        gl_Position = vec4(vPos, 1.0);
        vTcOut = vTcIn;
    }

### Fragment shader

This is where the magic happens. This shader is executed for every pixel on the scene (not the UI). We have two main inputs:

- `vTcIn`    - The coordinates of the current pixel
- `texUnit0` - The texture holding the previously rendered scene (including any transformations from previous FB effects)

Additionally, we get access to a few uniforms (engine variables):

- Screen resolution
- Dynamic light information
- Fog information
- World Timer information
- Wind and weather information
- Mouse input

For a complete list, see [uniforms.glsl](../src/uniforms.glsl).

#### Passthrough FS

The simplest postprocessing effect we can implement is to do nothing. We just read the input texture at current pixel location and write it to the output:

    varying vec2 vTcOut; // Current pixel texture coordinate, set in VS (interpolated)
    uniform sampler2D texUnit0; // Already rendered scene as a texture

    void main()
    {
        gl_FragColor = texture2D(texUnit0, vTcOut);
    }


#### Per-pixel changes

Instead of outputting the unmodified texture, we can change it in some simple ways. For example, we can make it a negative:

    void main()
    {
        gl_FragColor = texture2D(texUnit0, vTcOut);
        gl_FragColor.r = 1.0 - gl_FragColor.r;
        gl_FragColor.g = 1.0 - gl_FragColor.g;
        gl_FragColor.b = 1.0 - gl_FragColor.b;
    }
![](https://i.imgur.com/L2wQiez.png)


Colors in GLSL range from 0.0 to 1.0, and will automatically be clamped to that range when displaying. Let's take a look at few other simple effects we can do.

Make everything much darker:

    void main()
    {
        gl_FragColor = texture2D(texUnit0, vTcOut) * 0.5;
    }
![](https://i.imgur.com/ZZlTltm.png)


Grayscale:

    void main()
    {
        gl_FragColor = texture2D(texUnit0, vTcOut);
        float intensity = dot(gl_FragColor.rgb, vec3(0.2125, 0.7154, 0.0721));
        gl_FragColor.rgb = vec3(intensity, intensity, intensity);
    }

![](https://i.imgur.com/B7i11Jh.png)


#### Pixel-dependent changes

In the above examples, we changed each pixel independent of the values of neighboring pixels. While it is enough to implement some basic effects, it's unlikely to be enough for anything useful. However, each pixel (i.e. each FS instance) has access to the entire input texture, and can read all of it.

Keep in mind that `vTcOut` is a float vector, typically ranging from 0.0 to 1.0 in both axes. This is done so that the code is independent of screen resolution - you just read the pixel at 0.5, and it works whether running at 1080p or 4K. However, this means you cannot just increment by a constant and get the next pixel. Instead, we need to find how much neighboring pixel coordinates are different.

By convention, these values are called `dx` and `dy`:

    float dx = 1.0 / screenWidth;
    float dy = 1.0 / screenHeight;

Now we can use these to get neighboring pixel coordinates

    vec2 bl = vTcOut - vec2(dx, dy); // bottom-left
    vec2 tr = vTcOut + vec2(dx, dy); // top-right
    vec2 br = vTcOut - vec2(dx,-dy); // bottom-right
    vec2 tl = vTcOut + vec2(dx,-dy); // top-left
    vec2 bc = vTcOut - vec2(dx, 0.); // bottom-center
    vec2 tc = vTcOut + vec2(dx, 0.); // top-center
    vec2 cl = vTcOut - vec2(0., dy); // center-left
    vec2 cr = vTcOut + vec2(0., dy); // center-right

armed with this, let's make it so that each pixel is an average of itself and all neighbors:

    void main()
    {
        vec4 color = texture2D(texUnit0, vTcOut) +
                     texture2D(texUnit0, bl) +
                     texture2D(texUnit0, tr) +
                     texture2D(texUnit0, br) +
                     texture2D(texUnit0, tl) +
                     texture2D(texUnit0, bc) +
                     texture2D(texUnit0, tc) +
                     texture2D(texUnit0, cl) +
                     texture2D(texUnit0, cr);
        gl_FragColor = color / 9.0;
    }

and now we have a subtle blur effect.


![](https://i.imgur.com/HjEFvQ6.png)


How about simply showing a different pixel than the one we were told to? We need a way to consistently displace the current position. We can use `vTcOut.x + K*dx` to move the image `K` pixels to the side. While a fixed `K` does not make much sense, we can tie it to something that changes, like the world timer:

    // A monotonically ticking timer with millisecond resolution
    uniform int worldtimerTimeOfDay;

    void main()
    {
        const float SPEED = 1.0;      // Adjust for slower/faster transitions
        const float AMPLITUDE = 20.0; // Adjust for smaller/larger distortions

        // Need a new variable since 'varying' variables cannot be modified
        vec2 newTc = vTcOut;
        // Useful: sin(x) always returns in range (-1.0, 1.0).
        newTc.x += AMPLITUDE * sin(SPEED * worldtimerTimeOfDay) * dx;
        gl_FragColor = texture2D(texUnit0, newTc);
    }

And we have a simple screen-shake effect. Let's make the displacement along the x-axis depend on the y-axis position instead:

    newTc.x += AMPLITUDE * sin(newTc.y * SPEED * worldtimerTimeOfDay) * dx;

and we have wavy effect.


![](https://i.imgur.com/15BF5q3l.png)


With some constant modifications this could be an underwater scene, or an acid trip.


Another option would be to show the same pixel several times (while dropping some others):

    void main()
    {
        dx *= 8; dy *= 8; // How big should the pixels be?

        vec2 coord = vec2(dx*floor(vTcOut.x/dx), dy*floor(vTcOut.y/dy));
        gl_FragColor = texture2D(texUnit0, coord);
    }

and we get a pixelated world:


![](https://i.imgur.com/O7vZEjq.png)



#### Ideas for experimenting

The above should be enough to get you started on custom FB effects. Some ideas that you can take a shot at:

- Make the area under the mouse cursor different. Maybe draw something.
- Apply movie grain
- Make it darker when it is raining, brighter when it is snowing.
- Invert the image upside down
- Do proper Gaussian blur
-- With intensity increasing the further away from center pixels are.

#### Compiling shaders

FB effect shaders are compiled when the game starts, and any compilation errors will show up on stderr. Make good use of these, as you won't get compilation error feedback when we move onto per .txi shaders.

#### Other examples

A collection of somewhat adequately documented FB effect shaders can be found in [src/fb](../src/fb).

