#version 300 es

precision mediump float;

in vec2 vTexCoor;
uniform sampler2D sTexture;
out vec4 uFragColor;
uniform float alpha;

void main() {
    uFragColor = texture(sTexture, vTexCoor);
}
