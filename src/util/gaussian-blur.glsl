// Gives a gaussian blur value of a pixel at coordinates xy for texture tex:


const float gblur_offsets[2] = float[](1.3846153846, 3.2307692308 );
const float gblur_weight[3]  = float[]( 0.2270270270, 0.3162162162, 0.0702702703 );
vec3 gaussian_blur_vertical(in vec2 xy, in sampler2D tex)
{
    vec3 b = texture2D(tex, xy).rgb * gblur_weight[0];

    b += texture2D(tex, xy + vec2(0.0, gblur_offsets[0])/inScreenHeight).rgb * gblur_weight[1];
    b += texture2D(tex, xy - vec2(0.0, gblur_offsets[0])/inScreenHeight).rgb * gblur_weight[1];
    b += texture2D(tex, xy + vec2(0.0, gblur_offsets[1])/inScreenHeight).rgb * gblur_weight[2];
    b += texture2D(tex, xy - vec2(0.0, gblur_offsets[1])/inScreenHeight).rgb * gblur_weight[2];

    return b;
}
vec3 gaussian_blur_horizontal(in vec2 xy, in sampler2D tex)
{
    vec3 b = texture2D(tex, xy).rgb * gblur_weight[0];

    b += texture2D(tex, xy + vec2(gblur_offsets[0], 0.0)/inScreenHeight).rgb * gblur_weight[1];
    b += texture2D(tex, xy - vec2(gblur_offsets[0], 0.0)/inScreenHeight).rgb * gblur_weight[1];
    b += texture2D(tex, xy + vec2(gblur_offsets[1], 0.0)/inScreenHeight).rgb * gblur_weight[2];
    b += texture2D(tex, xy - vec2(gblur_offsets[1], 0.0)/inScreenHeight).rgb * gblur_weight[2];

    return b;
}
