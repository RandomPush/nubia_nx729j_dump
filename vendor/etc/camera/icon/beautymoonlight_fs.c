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

    color.r = 1.0 - exp(-2.0 * pow(color.r, 2.00));
    color.g = 1.0 - exp(-2.0 * pow(color.g, 2.00));
    color.b = 1.0 - exp(-2.0 * pow(color.b, 2.00));

    color.rgb = min(color.rgb, 1.0);
    color.rgb = max(color.rgb, 0.0);

    new_color.b = 1.0 - (1.0 - color.b) * ((1.0 - color.b));
    new_color.g = 1.0 - (1.0 - color.g) * ((1.0 - color.g));
    new_color.r = 1.0 - (1.0 - color.r) * ((1.0 - color.r));

    color.r = new_color.r * 0.75 + 0.25 * color.r;
    color.g = new_color.g * 0.75 + 0.25 * color.g;
    color.b = new_color.b * 0.75 + 0.25 * color.b;


    color.r = 0.90 * color.r + (0.10) * (1.0 - color.r);
    color.g = 0.90 * color.g + (0.10) * (1.0 - color.g);
    color.b = 1.00 * color.b + (0.00) * (1.0 - color.b);

    new_color = alpha * color.rgb + (1.0 - alpha) * origin_color;

    new_color = min(new_color.rgb, 1.0);
    new_color = max(new_color.rgb, 0.0);

    uFragColor = vec4(new_color.rgb, color.a);
}
