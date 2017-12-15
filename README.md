# Shader tutorials

This repository holds various shader demos you can use as a primer to write your own superfancy effects. The shaders are well commented, so if you're feeling adventurous you can dive right in. Otherwise, read on.

## Prerequisites

These tutorials assume a basic level of understanding of:
- NWScript: Code flow, control structures (if/for/while), functions, structs (specifically vector)
- Linear algebra: Matrix and vector operations (additions, multiplication, dot products)
- 3D models: Vertices, triangles, textures

## Goals

The tutorials will (try to) teach you to write shaders for NWN:EE. A lot of this knowledge is applicable to other games, but there are also significant gaps. NWN supports only a small subset of features present in a modern game; others (e.g. tessellation, geometry shaders, etc) are beyond the scope of these tutorials. You will find plenty of generic tutorials online, should you want to learn about those.

## FAQ

If you already have some knowledge how shaders work and are just looking for a specific answer, check the [FAQ](tut/faq.md).

## Chapters

- [What is a shader?](tut/what-is-a-shader.md)
- [GLSL (OpenGL Shading Language) basics](tut/glsl-basics.md)
- [Framebuffer effects](tut/framebuffer-effects.md)
- "Material" fragment shaders
- "Material" vertex shaders
- Dynamic lighting in NWN


## Other resources

If you are having trouble following, [this](https://simonschreibt.de/gat/renderhell/) is a great animated introduction about the rendering pipeline, made with non-technical people in mind.

If this is too slow and basic for you, try the [lighthouse3d](http://www.lighthouse3d.com/tutorials/) tutorials on GLSL. You can skip anything that mentions "Geometry Shaders" or "Tessellation", as NWN doesn't have those.

If you've gone through everything and _really_ want to know more about GPUs, send me a PM or email.
