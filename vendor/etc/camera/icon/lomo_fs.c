#version 300 es

precision highp float;
uniform sampler2D sTexture;
in vec2 vTexCoor;

uniform float mult;
uniform float igamma;
uniform float width;
uniform float height;
uniform float alpha;
out vec4 uFragColor;

void main() {
    vec4 color = texture(sTexture, vTexCoor);

    float rangeAlpha  = 0.75 + 0.25 * (alpha - 0.5);

    vec3 new_color = color.rgb;
    new_color.r = 1.5 * (new_color.r - 0.5);
    new_color.g = new_color.g - 0.5;
    new_color.b = new_color.b - 0.5;

    new_color.r = new_color.r + 0.5;
    new_color.g = new_color.g + 0.5;
    new_color.b = new_color.b + 0.5;

    new_color = min(new_color.rgb, 1.0);
    new_color = max(new_color.rgb, 0.0);

    new_color.r = 1.0 - (1.0 - new_color.r) * (1.0 - new_color.r);
    new_color.g = 1.0 - (1.0 - new_color.g) * (1.0 - new_color.g);
    new_color.b = 1.0 - (1.0 - new_color.b) * (1.0 - new_color.b);

    color.r = 1.0 - new_color.r;
    color.g = 1.0 - new_color.g;
    color.b = 1.0 - new_color.b;

    vec3 out_color;

    out_color.r = new_color.r;
    out_color.g = new_color.g;
    out_color.b = color.b * (1.0 - rangeAlpha) + new_color.b * rangeAlpha;

    out_color = min(out_color.rgb, 1.0);
    out_color = max(out_color.rgb, 0.0);

    uFragColor = vec4(out_color.rgb, color.a);;
}
