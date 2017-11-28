// Returns grayscale representation of a given pixel

vec3 grayscale(in vec3 pix)
{
    float f = dot(pix, vec3(0.2125, 0.7154, 0.0721));
    return vec3(f,f,f);
}

vec4 grayscale(in vec4 pix)
{
    pix.rgb = grayscale(pix.rgb);
    return pix;
}
