#version 300 es

precision mediump float;
in vec2 vTexCoor;
uniform sampler2D sTexture;
uniform float width;
uniform float height;
uniform float alpha;

uniform sampler2D uFrontTexture;
out vec4 uFragColor;

vec4 japen(vec2 vTexCoor, vec4 front) {

    vec4 color = texture(sTexture, vTexCoor);

    vec3 new_color = color.rgb;

    color.r = (color.r - 0.10) / (1.0 - 0.1);
    color.b = (color.b) * (1.0 - 0.1);
    color.rgb = max(color.rgb, 0.0);
    vec3 colorSau;

    colorSau.r = 0.4785 * pow(color.r, 3.0) - 1.4711 * pow(color.r, 2.0)
        + 1.6358 * pow(color.r, 1.0) + 0.2384 * pow(color.r, 0.0);
    colorSau.g = 0.4785 * pow(color.g, 3.0) - 1.4711 * pow(color.g, 2.0)
        + 1.6358 * pow(color.g, 1.0) + 0.2384 * pow(color.g, 0.0);
    colorSau.b = 0.4785 * pow(color.b, 3.0) - 1.4711 * pow(color.b, 2.0)
        + 1.6358 * pow(color.b, 1.0) + 0.2384 * pow(color.b, 0.0);

    color.rgb = 0.75 * color.rgb + colorSau.rgb * 0.25;

    new_color = alpha * color.rgb + (1.0 - alpha) * new_color;

    color.rgb = min(new_color.rgb, 1.0);
    color.rgb = max(new_color.rgb, 0.0);

    return color;
}


void main() {

    vec4 front = texture(uFrontTexture, vTexCoor);

    vec4 color = japen(vTexCoor, front);

    uFragColor = vec4(color.r, color.g, color.b, color.a);

}
