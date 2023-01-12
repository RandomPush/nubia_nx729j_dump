#version 300 es

precision mediump float;
in vec2 vTexCoor;
uniform sampler2D sTexture;
out vec4 uFragColor;
uniform float alpha;

void main() {
    vec4 color = texture(sTexture, vTexCoor);
    float y = dot(color, vec4(0.299, 0.587, 0.114, 0));
    y = 0.25 * (alpha - 0.5)/0.5 + y;
    uFragColor = vec4(y, y, y, color.a);
}

