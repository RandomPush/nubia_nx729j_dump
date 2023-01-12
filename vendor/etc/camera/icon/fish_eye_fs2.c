#version 310 es

precision highp float;

in vec2 vTexCoor;
out vec4 uFragColor;

uniform float width;
uniform float height;
uniform sampler2D sTexture;
uniform float alpha;

void main() {
    const float ANGLE_MIN = 60.0f / 57.3f;
    const float ANGLE_MAX = 90.0f / 57.3f;
    float angleMax = ANGLE_MIN + (ANGLE_MAX - ANGLE_MIN) * alpha;

    float x = vTexCoor.x - 0.5f;
    float y = vTexCoor.y - 0.5f;
    float xEx = x * width;
    float yEx = y * height;
    float lenMax = sqrt(width * width / 4.0f + height * height / 4.0f);
    float R = lenMax / sin(angleMax);
    float len = sqrt(xEx * xEx + yEx * yEx);

    if (len > 0.001f) {
        float angle = asin(len / R);
        float ratio = angle / angleMax;
        float scale = ratio / (len / lenMax);
        x *= scale;
        y *= scale;
    }

    vec2 texCoor = vec2(x + 0.5f, y + 0.5f);
    uFragColor = texture(sTexture, texCoor);
}
