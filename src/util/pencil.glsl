// produces a pencil drawing of an image, called per-pixel


vec4 pencil(in vec4 pix)
{
    vec4 color = fwidth(pix);
    return vec4(1.-3.*min(.9,length(color)))*length(pix)/1.2;
}
vec4 pencil_color(in vec4 pix)
{
    vec4 color = fwidth(pix);
    return vec4(1.-3.*min(.9,length(color)))*length(pix)/1.2*vec4(ivec4(8.*pix))/8.;
}
