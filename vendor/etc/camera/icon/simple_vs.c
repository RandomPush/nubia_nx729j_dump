#version 300 es

in vec2 aVertex;
in vec2 aTexCoor;
out vec2 vTexCoor;
uniform mat4 uMVPMatrix;

void main() {
    gl_Position = uMVPMatrix * vec4(aVertex, 0.0f, 1.0f);
    vTexCoor = aTexCoor;
}
