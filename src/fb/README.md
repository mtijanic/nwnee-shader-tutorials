# How to use FB shaders

NWN:EE currently only has 3 Framebuffer Effects available:

- Depth of Field
- High Contrast
- Vibrance

These are activated in the Graphics Options, under "Advanced Framebuffer Effects".

Adding new effects to the game is currently not supported, but you can override the existing ones. Just take any of the FSs in this folder, rename them:

- `fsFBDOF.shd` to replce Depth of Field
- `fsFBLVLS.shd` to replace High Contrast
- `fsFBVIB.shd` to replace Vibrance

and drop it in your `override/` folder.


## Ambient Occlusion

A fourth FB effect is present, called Ambient Occlusion, but disabled. You can enable it in the nwn.ini file by adding:

    [Video Options]
    Enable FBEffect Ambient Occlusion=1

To override this effect (leaving the other three available), the shader should be named `fsFBSSAO.shd`.
