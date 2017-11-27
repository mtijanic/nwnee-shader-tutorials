# GLSL basics

GLSL stands for OpenGL Shading Language and is what you need to learn to write shaders for NWN. There are a few other shading languages, but they are all similar enough that the knowledge will be transferable.

## Massively parallel

If you're used to traditional programming, such as NWScript, the biggest change to your model will be the multiple of programs executing _at the same time_. Even if you did some multithreading on the CPU side, this is not the same. It is not just a couple of programs executing that occasionally need to synchronize, we can literally have millions of threads running _at the same time_, executing _same code_.

Think of your GPU as a collection of some 500 Pentium-1 style processors, all running the same program. This is a _huge_ oversimplification, but it will do for now.

In case of e.g. Fullscreen Fragment Shaders, you have as many programs running as you have pixels on the screen, and each one of those performs only the most basic operations on a given pixel.


## Syntax

The syntax of GLSL is almost identical to C, which means almost identical to NWScript.

GLSL has `int` and `float` as basic types, and does not support strings. It has support for arrays, like in C, but we won't be using them in these tutorials until we get to dynamic lighting. Most everything that is legal in NWScript is also legal in GLSL.

### Vectors

Vectors are a very commonly used type in GLSL, and while simple at the core, they have a few quirks that are hard to figure out on your own. A vector can be described as:

    typedef struct vec2 {
        float x,y;
    } vec2;
    typedef struct vec3 {
        float x,y,z;
    } vec3;
    typedef struct vec4 {
        float x,y,z,w;
    } vec4;

There are also corresponding `ivec2`/`ivec3`/`ivec4` where the element type is `int` instead of `float`. The `vec3` builtin type is practically identical to `vector` from NWScript.

There are a few weird quirks regarding vectors that can be very confusing

- `x`,`y`,`z`,`w` are aliased to `r`,`g`,`b`,`a`. Typing `v.x` is _same_ as typing `v.r`. Changing one changes the other. This is just added to make things simpler when a vector represents a color as opposed to coordinates.

- Multiple fields of a vector can be indexed at once: `v.xy` is of type `vec2`, `v.rgba` is of type `vec4` and so on.

- Fields can be "swizzled", so all of these are valid as well:
-- `v.xxxx` - Shorthand for `vec4(v.x, v.x, v.x, v.x)`
-- `v.xyz = v.zyx` - Swap values of `x` and `z` in `v`
-- `v.xyz = v.rgb` - No effect.

- Vector constructor functions can take vectors. The following are all valid ways to make a new `vec3`:
-- `vec3 v = vec3();` - Populate with zeros
-- `vec3 v = vec3(1.0);` - Populate rest with zeros
-- `vec3 v = vec3(v2.xy, 1.0);`
-- `vec3 v = v2.rgb`

- Arithmetic between a vector and a scalar is done for each vector field:
-- `v += 0.5` is a shorthand for `v.x += 0.5; v.y += 0.5; v.z += 0.5;`
-- `v.xy = v.xz * 3` - is shorthand for `v.x *= 3; v.y = v.z * 3;`

- Arithmetic between two vectors is done on a per-field basis:
-- `v1 += v2` is a shorthand for `v1.x += v2.x; v1.y += v2.y; v1.z += v2.z;`


More about the various data types in GLSL and how they can be used:
https://www.khronos.org/opengl/wiki/Data_Type_(GLSL)


## Variable types

There are a few types of variables that exist in a shader program. Typical, unqualified variables are locals or globals, like in NWScript. `const` is available as well.

In addition to these, there are three special types of variables as well. OpenGL has some built in variables that have a special meaning. NWN doesn't like to use these and just defines its own that do the same thing. However, `gl_Position` and `gl_FragColor` are used as outputs for VS and FS respectively.

### Uniforms

A uniform is global constant that is set by the NWN game engine, and that can be used by the shaders. `m_m`, `m_mv` and `m_mvp` (Model/View/Projection matrices) are examples of uniform variables. Other things the engine exposes are:

- Textures
- Dynamic lighting
- World timer
- Various area info
- Fog
- Screen resolution
- Mouse

More details can be found in the `Shaders_README.txt` file in your instalation.

To use a uniform, we declare it as a global with the `uniform` qualifier:

    uniform mat4 m_mvp;
    uniform int screenWidth, screenHeight;

### Attributes

An attribute is a per-vertex variable available to the VS for the vertex it is currently operating on. Most notable attributes in NWN are:

- `vPos` - representing the vertex position in object space (reminder: `gl_Position = m_mvp * vPos`)
- `vTcIn` - Texture coordinates of current vertex in the texture
- `vNormal` - (Untransformed) normal of the vertex, used for lighting
- `vColor` - A per-vertex color set by the engine. Only used to render things that have no textures.

Using an attribute is similar to a uniform, except for the `attribute` keyword:

    attribute vec3 vNormal;


### Varying

A varying variable is the output of VS and input into FS. These variables are then interpolated among all vertices of a triangle when used in the FS. The `gl_Position` is an example of a varying, as well as `vColorOut` in the previous chapter.

A varying variable is defined in both the VS and FS. It is written to by the VS, then read by the VS. Typically, in NWN the attributes are passed onto the FS by putting them in a variable:

    // VS
    attribute vec2 vTcIn; // Texture coordinate of current vertex
    varying vec2 vTcOut; // Output variable
    void main()
    {
        vTcOut = vTcIn;
        gl_Position = m_mvp * vPos;
    }
    // FS
    uniform sampler2D texUnit0;
    varying vec2 vTcOut; // Interpolated position between 3 vertices
    void main()
    {
        gl_FragColor = texture2D(texUnit0, vTcOut); // Use color of texture at vTcOut
    }



## GLSL and NWN

A few things that NWN does in a nonstandard way:

### Shader names

Shaders in NWN follow the format of vsXxx.shd and fsXxx.shd for vertex and fragment shaders. Each custom FS needs to be paired with a VS of same name (_not_ true for all built-in shaders)

### Variable names

No strict naming convention exists, but typically matrices are prefixed with `m_`, attributes are `vXxxIn`, and varying variables are `vXxxOut`. You will find plenty of exceptions though.

### Precision

Floats in builtin shaders are sometimes decorated with `lowp`, `mediump` and `highp` precision specifiers. These _do not do anything_, you can ignore them. Those words are literally removed from the code before executing.

### Material shaders

NWN has a feature called "material shaders", which is a bit of a misnomer. Technically, it is a per-texture (or per-PLT) VS/FS pair. It lets specify `customShaderName XXX` in a `.txi` and it will call `vsXXX.shd` and `fsXXX.shd` on that texture every time it is drawn

### Dynamic lighting

Dynamic lighting will be covered in the last chapter of the tutorial, but a quick foreward will help you understand NWN VSs. In NWN, light is calculated per-vertex, and then interpolated for every pixel on that face as a `varying` variable. This is why 90% of VS code will deal with lighting.

A more advanced technique, called per-pixel lighting, moves these calculations into the FS, where finer grain control is available. This, however, is much more expensive on the GPU (more pixels than vertices).
