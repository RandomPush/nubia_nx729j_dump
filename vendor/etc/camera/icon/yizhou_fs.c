#version 300 es

precision highp float;

in vec2 vTexCoor;

uniform float width;
uniform float height;
uniform int angle;
uniform float alpha;

uniform sampler2D sTexture;
uniform sampler2D sBlurTexture;

out vec4 uFragColor;

void main() {   
    vec4 originColor = texture(sTexture, vTexCoor);
    vec4 blurColor = texture(sBlurTexture, vTexCoor);
    vec2 finalTexCoor= vTexCoor.st;
    if(angle == 0 || angle == 180) {
        if (finalTexCoor.s < 0.25f || finalTexCoor.s > 0.75f) {
            uFragColor = blurColor;
        } else if (finalTexCoor.s <= 0.35f) {
            uFragColor = ((0.35f - finalTexCoor.s) / 0.1f) * blurColor + ((finalTexCoor.s - 0.25f) / 0.1f) * originColor;
        } else if (finalTexCoor.s >= 0.65) {
            uFragColor = ((finalTexCoor.s - 0.65f) / 0.1f) * blurColor + ((0.75f - finalTexCoor.s) / 0.1f) * originColor;
        } else {
            uFragColor = originColor;
        }
    } else {
        if (finalTexCoor.t < 0.25f || finalTexCoor.t > 0.75f) {
            uFragColor = blurColor;
        } else if (finalTexCoor.t <= 0.35f) {
            uFragColor = ((0.35f - finalTexCoor.t) / 0.1f) * blurColor + ((finalTexCoor.t - 0.25f) / 0.1f) * originColor;
        } else if (finalTexCoor.t >= 0.65) {
            uFragColor = ((finalTexCoor.t - 0.65f) / 0.1f) * blurColor + ((0.75f - finalTexCoor.t) / 0.1f) * originColor;
        } else {
            uFragColor = originColor;
        }
    }

    uFragColor = alpha * uFragColor + (1.0 - alpha) * originColor;
}
