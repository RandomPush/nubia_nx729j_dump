#version 300 es

precision mediump float;
in vec2 vTexCoor;
uniform sampler2D sTexture;
uniform float width;
uniform float height;
out vec4 uFragColor;
uniform float alpha;

float luminance(in vec3 color) {
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}


vec4 pass2(vec2 vTexCoor, float xDistance, float yDistance) {
    vec2 pos = vTexCoor.st;
    float s00 = luminance(texture(sTexture, pos + vec2(-xDistance, yDistance)).rgb);
    float s10 = luminance(texture(sTexture, pos + vec2(-xDistance, 0.0)).rgb);
    float s20 = luminance(texture(sTexture, pos + vec2(-xDistance, -yDistance)).rgb);
    float s01 = luminance(texture(sTexture, pos + vec2(0.0, yDistance)).rgb);
    float s21 = luminance(texture(sTexture, pos + vec2(0.0, -yDistance)).rgb);
    float s02 = luminance(texture(sTexture, pos + vec2(xDistance, yDistance)).rgb);
    float s12 = luminance(texture(sTexture, pos + vec2(xDistance, 0.0)).rgb);
    float s22 = luminance(texture(sTexture, pos + vec2(xDistance, -yDistance)).rgb);

    float sx = s00 + 1.0 * s10 + s20 - (s02 + 1.0 * s12 + s22);
    float sy = s00 + 1.0 * s01 + s02 - (s20 + 1.0 * s21 + s22);

    float dist = sx * sx + sy * sy;

    dist = sqrt(dist);

    dist = dist - 0.0 * dist * (dist - 0.5) * (dist - 1.0);
    dist = dist > 1.0 ? 1.0 : dist;
    dist = dist < 0.0 ? 0.0 : dist;
    float newWidth = pos.s;
    float newHeight = pos.t;

    float media_r = (0.5 + 0.25);
    float media_g = (0.5 - 0.25);


    float r = 0.0, g = 0.0, b = 0.0;

    r = 1.0 - dist + r > 1.0 ? 1.0 : 1.0 - dist + r;
    g = 1.0 - dist + g > 1.0 ? 1.0 : 1.0 - dist + g;
    b = 1.0 - dist + b > 1.0 ? 1.0 : 1.0 - dist + b;


    return vec4(r, g, b, 1.0);
}

void main() {
    float xDistance = 1.0 / 1080.0;
    float yDistance = 1.0 / 1920.0;
    vec4 c = pass2(vTexCoor, xDistance, yDistance);

    c = 0.25 * (alpha - 0.5)/0.5 + c;

    uFragColor = c;
}
