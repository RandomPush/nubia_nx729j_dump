#version 300 es
precision mediump float;

const vec4 coeff_y = vec4(0.257, 0.504, 0.098, 0.063);
const vec4 coeff_v = vec4(0.439, -0.368, -0.071, 0.500);
const vec4 coeff_u = vec4(-0.148, -0.291, 0.439, 0.500);

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
const vec3 red = vec3(1.0, 0.0, 0.0);
const vec3 green = vec3(0.0, 1.0, 0.0);
const vec3 blue = vec3(0.0, 0.0, 1.0);

in vec2 vTexCoor;
out vec4 uFragColor;

uniform sampler2D sTexture;
uniform float u_r; // high hue
uniform float u_g; // low hue
uniform float u_b; // current hue
uniform float u_range;
uniform int u_ColorType;
uniform int substitute;
uniform vec3 to_hsv;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)) * 360.0, d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float dist(vec3 a, vec3 b) {
    float d = distance(a, b);
    return d * d;
}

void main() {
    int scaleCoef = int(u_range * 100.0);
    int hue_low = int(u_g * 255.0);
    int hue_high = int(u_r * 255.0);
    int current_hue = int(u_b * 255.0);

    vec4 pixelColor = texture(sTexture, vTexCoor);
    float luminance = dot(pixelColor.rgb, W);
    float h_value = rgb2hsv(pixelColor.rgb).x;
    float rangeFactor = float(scaleCoef) / 100.0;
    vec3 rgb = pixelColor.rgb / (pixelColor.r + pixelColor.g + pixelColor.b);
    int a = 0;

    if (u_ColorType == 0) { /* red */
        if ((h_value < 14.0 || h_value > 300.0) && dist(rgb, red) < rangeFactor) {
            a = 1;
        }
    } else if (u_ColorType == 1) { /* green */
        if (h_value > 60.0 && dist(rgb, green) < rangeFactor) {
            a = 1;
        }
    } else if (u_ColorType == 2) { /* blue */
        if (dist(rgb, blue) < rangeFactor) {
            a = 1;
        }
    } else if (u_ColorType == 10) { /* self-define color */
        h_value /= 2.0; // range map
        if (h_value <  7.0) {
            h_value += 180.0;
        }
        if (abs(h_value - float(current_hue)) < float(scaleCoef) && h_value > float(hue_low) && h_value < float(hue_high)) {
            a = 1;
        }
    } else if (u_ColorType == 11) {
        a = 1;
    } else if (u_ColorType == 12) {
        a = 0;
    }

    if (substitute == 1) {
        if (a == 1) {
            vec3 hsv = rgb2hsv(pixelColor.rgb);
            hsv.x = to_hsv.x / 360.0;
            hsv.y = hsv.y * to_hsv.y;
            hsv.z = hsv.z * to_hsv.z;
            pixelColor.rgb = hsv2rgb(hsv);
        }
    } else {
        if (a == 0) {
            pixelColor.rgb = vec3(luminance, luminance, luminance);
        }
    }

    pixelColor.a = 1.0;
    //uFragColor.r = dot(pixelColor, coeff_y);
    //uFragColor.g = dot(pixelColor, coeff_v);
    //uFragColor.b = dot(pixelColor, coeff_u);
    uFragColor = pixelColor;
}