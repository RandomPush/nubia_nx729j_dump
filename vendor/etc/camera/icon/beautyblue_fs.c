#version 300 es

precision highp float;
uniform sampler2D sTexture;
in vec2 vTexCoor;
out vec4 uFragColor;
uniform float alpha;

void main() {
    vec4 color = texture(sTexture, vTexCoor);

    vec3 new_color = color.rgb;
    color.b = (255.0 - 40.0) * color.b / 255.0 + 40.0 / 255.0;
    color.r = 230.0 / 255.0 * color.r;

    color.rgb = min(color.rgb, 1.0);
    color.rgb = max(color.rgb, 0.0);

    if (color.r < 0.5)
        color.r = color.r + (2.0 * color.r - 1.0) * (color.r - color.r * color.r);
    else color.r = color.r + (2.0 * color.r - 1.0) * (sqrt(color.r) - color.r);

    if (color.g < 0.5)
        color.g = color.g + (2.0 * color.g - 1.0) * (color.g - color.g * color.g);
    else color.g = color.g + (2.0 * color.g - 1.0) * (sqrt(color.g) - color.g);

    if (color.b < 0.5)
        color.b = color.b + (2.0 * color.b - 1.0) * (color.b - color.b * color.b);
    else color.b = color.b + (2.0 * color.b - 1.0) * (sqrt(color.b) - color.b);

    color.r = 0.80 * color.r + (0.00) * (1.0 - color.r);
    color.g = 1.00 * color.g + (0.00) * (1.0 - color.g);

    new_color = alpha * color.rgb + (1.0 - alpha) * new_color;

    new_color = min(new_color.rgb, 1.0);
    new_color = max(new_color.rgb, 0.0);

    uFragColor = vec4(new_color.rgb, color.a);

}
