#version 300 es

precision mediump float;
in vec2 vTexCoor;
uniform sampler2D sTexture;
out vec4 uFragColor;
uniform float alpha;

void main() {
    vec4 color = texture(sTexture, vTexCoor);
    vec4 y = vec4(1.0 - color.r, 1.0 - color.g, 1.0 - color.b, color.a);
    y = 0.25 * (alpha - 0.5)/0.5 + y;
    uFragColor = y;
}
