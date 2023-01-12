#version 300 es

precision highp float;
uniform sampler2D sTexture;
in vec2 vTexCoor;
out vec4 uFragColor;
uniform float alpha;

void main() {
    vec4 color = texture(sTexture, vTexCoor);

    vec3 new_color = color.rgb;
    vec3 origin_color = color.rgb;

    color.r = color.r + 0.0 / 255.0;
    color.g = color.g + 0.0 / 255.0;
    color.b = color.b + 0.0 / 255.0;
    color.rgb = min(color.rgb, 1.0);
    color.rgb = max(color.rgb, 0.0);
    color.r = (1.0 - 30.0 / 255.0) * color.r + 30.0 / 255.0;
    color.b = (300.0 / 255.0 - 50.0 / 255.0) * color.b + 50.0 / 255.0;

    color.rgb = min(color.rgb, 1.0);
    color.rgb = max(color.rgb, 0.0);

    //B1-1.15*B1*(B1-1)
    color.r = color.r - 1.05 * color.r * (color.r - 1.0);
    color.g = color.g - 1.05 * color.g * (color.g - 1.0);
    color.b = color.b - 1.05 * color.b * (color.b - 1.0);

    new_color.r = 0.25 * new_color.r + 0.75 * color.r;
    new_color.g = 0.25 * new_color.g + 0.75 * color.g;
    new_color.b = 0.25 * new_color.b + 0.75 * color.b;

    new_color = min(new_color.rgb, 1.0);
    new_color = max(new_color.rgb, 0.0);

    new_color = alpha * new_color + (1.0 - alpha) * origin_color;

    uFragColor = vec4(new_color.rgb, color.a);;

}
