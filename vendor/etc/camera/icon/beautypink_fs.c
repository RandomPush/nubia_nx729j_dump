#version 300 es

precision mediump float;
in vec2 vTexCoor;
uniform sampler2D sTexture;
uniform float alpha;
uniform float width;
uniform float height;
uniform sampler2D uFrontTexture;

out vec4 uFragColor;

vec4 test6(vec2 vTexCoor, float xDistance, float yDistance, vec4 front) {

    vec2 pos = vTexCoor.st;

    vec4 color = texture(sTexture, pos);

    vec3 new_color = color.rgb;


    //B1-2*B1*(B1-0.5)*(B1-1)
    color.b = color.b - 1.0 * color.b * (color.b - 0.5) * ((color.b - 1.0));
    color.g = color.g - 1.0 * color.g * (color.g - 0.5) * ((color.g - 1.0));
    color.r = color.r + 1.0 * color.r * (color.r - 0.5) * ((color.r - 1.0));


    color.rgb = min(color.rgb, 1.0);
    color.rgb = max(color.rgb, 0.0);

    if (front.r < 0.5)
        color.r = color.r + (2.0 * front.r - 1.0) * (color.r - color.r * color.r);
    else color.r = color.r + (2.0 * front.r - 1.0) * (sqrt(color.r) - color.r);

    if (front.g < 0.5)
        color.g = color.g + (2.0 * front.g - 1.0) * (color.g - color.g * color.g);
    else color.g = color.g + (2.0 * front.g - 1.0) * (sqrt(color.g) - color.g);

    if (front.b < 0.5)
        color.b = color.b + (2.0 * front.b - 1.0) * (color.b - color.b * color.b);
    else color.b = color.b + (2.0 * front.b - 1.0) * (sqrt(color.b) - color.b);

    color.r = (1.0 - exp(-2.0 * pow(color.r, 1.75))) * 0.50 + 0.50 * color.r;
    color.g = (1.0 - exp(-2.0 * pow(color.g, 1.75))) * 0.50 + 0.50 * color.g;
    color.b = (1.0 - exp(-2.0 * pow(color.b, 1.75))) * 0.50 + 0.50 * color.b;

    color.rgb = min(color.rgb, 1.0);
    color.rgb = max(color.rgb, 0.0);

    new_color = alpha * color.rgb + (1.0 - alpha) * new_color;

    color.rgb = min(new_color.rgb, 1.0);
    color.rgb = max(new_color.rgb, 0.0);

    return color;
}


void main() {
    float xDistance = 1.0 / height;
    float yDistance = 1.0 / width;
    vec4 front = texture(uFrontTexture, vTexCoor).bgra;
    vec4 color = test6(vTexCoor, xDistance, yDistance, front);

    uFragColor = vec4(color.r, color.g, color.b, color.a);

}
