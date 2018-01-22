# Material fragment shaders

NWN:EE exposes a way to modify a single texture using a custom shader VS/FS pair. Any texture can be accompanied by a .txi file which specifies additional texture attributes. The TXI simulates what modern engines call "materials", so this shading feature was dubbed "material shaders". The name is non-standard, so don't bother searching it online - whatever you do find is unlikely to be applicable to NWN:EE. An alternative name for the feature is "Per-TXI shaders".

## Using TXIs

The .txi format was never publicly documented, and is out of scope for these tutorials. For our uses, it is enough to assume that when a texture (`.tga`, `.dds`, `.plt`) is loaded, the engine will also look for a `.txi` with the same basename and load it for additional configuration.

The only feature of the TXI we care about is the `customShaderName` command. Find the texture you want to modify, create a .txi file with the same basename and add this line to it:

    customShaderName MyShader

Now, whenever the game loads this texture, instead of the stock shaders it will use `vsMyShader.shd` and `fsMyShader.shd`. If the shaders are missing or cannot be compiled, it will fallback to the stock shader.

Note: It is currently not possible to only override one shader, leaving the other one. If you don't want to modify one shader, you need to create a copy of the stock shader and name it appropriately.


## Stock shaders

The game ships with a set of stock shaders that are made to emulate the old 1.69 Fixed Function Pipeline behavior. These shaders were auto-generated and then tweaked for some specific purposes. As such, they might not be easy to follow.

First step in modifying one of the stock shaders is figuring out which one is used for the model in question. The shaders mostly follow a naming scheme based on what they take as input:

 - `lit` means the shader uses dynamic lighting
 - `_sm` means the object is sphere-mapped,
 - `_cm` means the object is cube-mapped
 - `t` means the shader has texture coordinates
 - `c` means the shader is given a specific color by the engine
 - `v` means the (vertex) shader gets the vertex coordinates
 - `_ls` means the shader is using long-distance fog
 - `_sk` means the shader is using the `m_bones` skeleton

The VS and FS for stock shaders aren't paired 1:1, and can have a number of mappings:

    VS         | FS       | Used for
    -----------|----------|----------------------
    vsv        | fsc      |
    vsvt       | fstc     | GUI, Inventory icons, Sky
    vsvtc      | fstc     | Text
    vsvc       | fsc_ls   | Shadows
    vslitnotex | fsc      |
    vslitnt_sm | fsc_sm   |
    vslit_sm   | fslit    | Static geometry, scene, backgrounds - almost everything
    vslit_sm   | fslit_sm | Dynamic models (e.g. PC), items on ground, compass
    vslit      | fslit    |
    vslitc_sm  | fslit_sm |
    vslit_sk   | fslit    |
    vslit_sk   | fslit_sm | Skeleton-based models (e.g. cloaks)
    vsglu      | fsglu    |

If you're not sure which stock shader is used for a given model, you can:

 a) Load a GL debugger/tracer and check `glUseProgram()` calls
 b) Modify each FS to show a different solid color, then check the color of the model.

## Custom FS

Let's make a custom shader to apply to the default `sky_001` - the "Grass, Clear" skybox. First, we make a `sky_001.txi` file with the following content:

    customShaderName CustomSky

Then we create copies of the two shaders per the table above:

    vsvt -> vsCustomSky.shd
    fstc -> fsCustomSky.shd

Since this is chapter deals with FS only, we'll leave the VS as is for now. Let's examine the FS:

    varying mediump vec2 vTcOut;
    varying lowp vec4 vColorOut;

    uniform sampler2D texUnit0;

    void main()
    {
        gl_FragColor = texture2D(texUnit0, vTcOut) * vColorOut;
    }

We have the texture in question bound to `texUnit0`, the current pixel's coordinates in `vTcOut`, and a color tint in `vColorOut`.

All of the tricks that we used for [FB shaders](tut/framebuffer-effects.md) work here as well, and they will only apply to this one texture. Let's try some of them:

    void main()
    {
        // Pick pixel size
        float dx = 0.007;
        float dy = 0.007;

        vec2 coord = vec2(dx*floor(vTcOut.x/dx), dy*floor(vTcOut.y/dy));
        gl_FragColor = texture2D(texUnit0, coord);
    }


![](https://i.imgur.com/zQF8fet.png)
