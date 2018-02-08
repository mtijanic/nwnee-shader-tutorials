# Questions
1. [How do I make new framebuffer effects?](#q1)
2. [How do I use custom shaders on a model or texture?](#q2)
3. [How do I send data from NWScript to a shader?](#q3)
4. [My shader has no effect](#q4)
5. [My shader failed to compile, I can't figure out why](#q5)
6. [How do I figure out which stock shaders render which object?](#q6)
7. [Which uniforms are available to my shader?](#q7)
8. [Can I modify the uniforms in game?](#q8)
9. [I changed the value of a uniform in .shd, but it has no effect](#q9)
10. [How do I measure the performance of my shader?](#q10)
11. [What order are the FB effects run in?](#q11)




<a name="q1"></a>
## How do I make new framebuffer effects?

Currently, you can only override the four default FB effects that ship with the game. See [here](src/fb/README.md) for details how to do that.

<a name="q2"></a>
## How do I use custom shaders on a model or texture?

Custom "material" shaders are per-texture (or PLT). You need to make a .txi file with the same name as the texture/plt you want to shade, then add this line to it:

    customShaderName XYZ

Now, make `vsXYZ.shd` and `fsXYZ.shd`. Put these three files in a hak or in your `override/` directory.

<a name="q3"></a>
## How do I send data from NWScript to a shader?

Currently, this is not possible. There are a few engine variables visible to shaders that can be controlled through scripting - such as area weather - but there is no way to send generic data. It is coming, though!

<a name="q4"></a>
## My shader has no effect

Most likely, your shader failed to compile and the game fell back to the default one. See [My shader failed to compile, I can't figure out why](#q5).

Of course, maybe your shader is working and just giving exact same results as stock. Try adding `gl_FragColor.r = 1.0;` to the FS and see if it turns red.

<a name="q5"></a>
## My shader failed to compile, I can't figure out why

The game gives no indication that anything is wrong when a material shaders don't compile. Some options:

- Try to compile the shader in some external program that will report the errors
- Use an OGL debugger or tracer to catch `glCompileShader()` call and examine the errors.
    - [List of OpenGL debugging tools](https://www.khronos.org/opengl/wiki/Debugging_Tools)
    - FWIW, I use [apitrace](https://github.com/apitrace/apitrace/).
- Try commenting out half of your code and see if it still compiles. You can do binary search this way.
- Try compiling your shader as a FB shader instead. Those are compiled when the game starts, and errors are reported to `stderr`
- Try showing the model that uses your shader in the toolset. The toolset reports shader compilation errors in a popup.

<a name="q6"></a>
## How do I figure out which stock shaders render which object?

The proper way would be to use a debugger/tracer and check the active program. A quick alternative is to just edit the stock shaders and give a distinct color/tint to everything rendered by it.

Quick and incomplete list:

 - fstc.shd - console, text, gui, inventory, sky
 - fslit.shd - backgrounds, scene, static geometry, almost everything
 - fsc_ls.shd - shadows
 - fslit_sm.shd - compass, dynamic models (e.g. PC), items on ground

<a name="q7"></a>
## Which uniforms are available to my shader?

See [uniforms.glsl](src/uniforms.glsl) for a full list.

<a name="q8"></a>
## Can I modify the uniforms in game?

Some uniforms are exposed to read/write from the in-game console:

    TYPE  Shader Name     Console Name
    ------------------------------------------
    float DOFAmount       dof_amount
    float Vibrance        vibrance_vibrance
    vec3  RGBBalance      vibrance_rgbbalance
    float AORadius        ssao_radius
    float AOIntensity     ssao_intensity
    float AOColor         ssao_color
    float fogStart        mainscene.fogstart
    float fogEnd          mainscene.fogend
    vec4  fogColor        mainscene.fogcolor
    int   fogMode         mainscene.fogmode
    int   fogEnabled      mainscene.fog
    float blackPoint      levels_blackPoint
    float whitePoint      levels_whitePoint

<a name="q9"></a>
## I changed the value of a uniform in .shd, but it has no effect

Some shaders have code like:

    uniform float nearClip = 0.1;
    uniform float farClip = 45.0;

The values specified on the right are used *only* if the engine does not set them. Most of these are set by the engine, so the "defaults" are just for reference. If you want to change them, you can remove the `uniform` keyword, making them into a generic shader variable.

<a name="q10"></a>
## How do I measure the performance of my shader?

Make a save game in a scene where you want to measure. Type `trace fps` in the console to have a constant display. Load the save once with your shader, once without, without moving the camera. Compare FPS.

`fps` command gives three numbers, for example: `100.0 (10.0) (0.01)` - The first is FPS, the second is minimal FPS in the last second and the third is `1/fps`.

<a name="q11"></a>
## What order are the FB effects run in?

The order in which they were enabled. The game keeps all FB effects in an array. When an effect is enabled, it gets added to the end. When it is disabled, it is removed. You should not make any assumption that a particular order will be honored.
