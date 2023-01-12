#version 300 es

precision highp float;

in vec2 vTexCoor;
uniform sampler2D sTexture;

uniform float width;
uniform float height;
out vec4 uFragColor;

void main() {
    float offset[3];
    offset[0] = 0.0f;
    offset[1] = 1.3846153846f;
    offset[2] = 3.2307692308;

    float weight[3];
    weight[0] = 0.2270270270f;
    weight[1] = 0.3162162162f;
    weight[2] = 0.0702702703f;

    float xDistance = 1.0f / width;
    float yDistance = 1.0f / height;

    vec4 color = texture(sTexture, vTexCoor);

    vec2 pos = vTexCoor.st;
    vec3 outval = color.rgb * weight[0];

    for (int i = 1; i < 3; i++) {
        outval.rgb += texture(sTexture, pos + vec2(0.0f, yDistance * offset[i])).rgb * weight[i];
        outval.rgb += texture(sTexture, pos - vec2(0.0f, yDistance * offset[i])).rgb * weight[i];
    }

    uFragColor = vec4(outval.r, outval.g, outval.b, color.a);
}
