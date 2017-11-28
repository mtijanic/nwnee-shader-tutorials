# What is a shader?

A shader is similar to a script that is executed on the GPU. When the game wants to render an object to the screen, it will pass some information about this object to the shaders, which perform some transformations on it, before finally passing it on to another component that displays it on the screen.

In NWN, rendering each model trimesh (a "submodel" that uses a single texture) roughly follows this sequence:

- [CPU] Decide which shaders to use
- [CPU] Update engine variables on the GPU
- [CPU] Load the required texture onto the GPU
- [CPU] Send vertex data (including texture positions) to the GPU
- [GPU] Execute the Vertex Shader (VS) on every vertex.
- [GPU] Make triangles out of vertices, scale to screen resolution.
- [GPU] Execute the Fragment Shader (FS) on every visible pixel in the resulting triangles
- [GPU] Display model on the framebuffer

When modding, we can change the VS and FS stages of the sequence.

## Vertex Shader

A vertex shader is run once for every vertex, and can change the position of that vertex. Its uses are limited, but it can be used to move, scale, rotate, or deform an existing model. A new vertex cannot be added, so dynamically modifying the model is not possible (currently).

### Vertex transformations

A vertex is just a point in 3D space. A 3D model is essentially a set of vertices, each of which holding some extra data - A location in the texture (TODO:image example), and a normal (used for lighting, more on this later).

A 3D model has a coordinate system in which its vertices are defined. The (0,0,0) location may be in the center, or in a corner, but all vertices are defined relative to it.

Because a model's vertices exist in a different coordinate system than the NWN world, they need to be mapped into so-called World Position. This is done using a so called Model transformation.


Let's make a little math digression:

A vertex is essentially a 3-element vector (A `vec3` in GLSL). For ease of calculations, these are often expanded to a `vec4`, with the last element being `1.0`. So, if you define a vertex in a model as (0.33, 0.5, 0.66), GLSL will see it as (0.33, 0.5, 0.66, 1.0).

A 3D transformation can mathematically be presented as a 4x4 matrix. If you have a vertex `v`, and a transformation `M`, the transformed position of `v` is `M*v`. If `M` is an identity matrix, the result stays the same.

There are a few standard transformation matrices that do translation, rotation, scaling and sheering. They are well covered in various online tutorials, so we'll skip them here. If you wish to read more about them, follow these links:

- https://www.tutorialspoint.com/computer_graphics/3d_transformation.htm
- http://mathforum.org/mathimages/index.php/Transformation_Matrix
- https://en.wikipedia.org/wiki/Transformation_matrix

The key takeaways here are that:

- A transformation of a vertex is represented by a 4x4 matrix
- Basic transformations are translation, rotation, scaling and sheering
- Basic transformations can be chained to make a more complex one (`M1*M2*M3*v`)


Back to our Model transformation, which moves a vertex from Object-space into World-space. In NWN, it is represented with the `m_m` matrix.

After a vertex has been moved into world space, we need to move it into so-called camera space, which represents everything the camera sees. This is done using the View transformation. NWN does not expose the View matrix directly, but it does have the `m_mv` matrix which is `Model * View`.

Finally, from camera space the vertex needs to be transformed into screen space, which represents the actual position of the vertex on your screen. This is done with the Projection transformation. Again, NWN doesn't expose it directly, but you do have `m_mvp = Model * View * Projection`, which is called the Model-View-Projection matrix.


### Minimal Vertex Shader

A vertex shader has a set of inputs (notably the MVP and Vertex position), and outputs (Notably the screen space position of the vertex). A minimal VS in NWN would look like:

    gl_Position = m_mvp * vec4(vPos, 1.0);

More on the syntax later, but for now, `vPos` is the vertex in Object space (x/y/z), while `gl_Position` is VS output and FS input. Usually, the VS will specify some other outputs as well to be used by the FS.

A vertex shader performs some additional calculations, relating to lighting and fog, which it then makes available to the fragment shader, but this is done for performance reasons. More on that (much) later.


## Fragment Shader

Fragment shader runs after the VS, and is executed once for every visible pixel on the model. This is where the magic happens. The fragment shader knows the location of its pixel on the screen (`gl_Position`), and as the output specifies the color of the pixel (`gl_FragColor`).

### Passing data from VS to FS

VS is run per-vertex, FS is run per-pixel. There are many more pixels than vertices. Also, a pixel is found inside a triangle, which has 3 vertices, which had different outputs from their VS.

So, what happens is that the FS knows its position inside the triangle as well, and knows which vertices (and thus which VS outputs) it cares about. Then, the _actual_ value taken as input to FS is interpolated between the values outputted by the three VSs, weighted by the distance of the pixel from the edges.

This might be best shown in this example:
![alt text](https://i.stack.imgur.com/VQLYb.jpg "GLSL Example Triangle")

The VS specify a color as output: Blue for top, red for left, green for right:

    // gl_VertexID is a predefined input into all VS programs
    // GetVertexColor() is a function we defined somewhere, don't worry about it for now
    vColorOut = GetVertexColor(gl_VertexID);

The FS just does:

    gl_FragColor = vColorOut;

And the actual color is interpolated based on distance between the pixel and the vertex.


### Minimal Fragment Shader

A minimal (useful) fragment shader simply samples the texture at the given location:

    gl_FragColor = texture2D(texUnit0, vTexCoord);

Here, `texUnit0` is just the name of the main texture used for this model, while `vTexCoord` would be an additional output of the VS that specifies the coordinates in the texture (in addition to `gl_Position` which specifies the coordinates on the screen).

### Framebuffer effects

NWN:EE added "Advanced Framebuffer Effects", also known as "fullscreen shaders" or "FBO shaders". These are just fragment shaders that run on the entire screen, after everything has already been rendered.

At a lower level, what happens is that rather than rendering onto the screen, the game renders onto a spare image (texture), and then draws one large rectangle across the screen and applies that texture to it. Drawing of that rectangle follows the same process as drawing everything else, so the shaders are applied as well. This includes the VS as well, but there is little reason to modify the VS.

Since these are easiest to work with, we'll start with them.

## Next chapter
[Framebuffer effects](tut/framebuffer-effects.md)
