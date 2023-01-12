#version 310 es
precision mediump float;
in vec2 vTexCoor;
out vec4 outFragColor;
uniform sampler2D sTexture;

void main() {
    vec3 W = vec3(0.2125, 0.7154, 0.0721);


    //pseudo noise
    vec4 pixelColor = texture(sTexture, vTexCoor);
    float lum = dot(pixelColor.rgb, W);
    float ixd=pow((lum-0.50)/0.35,2.0);
    float k1=0.04375*(2.3765-exp(ixd)/2.0);
	vec2 cord=vTexCoor;
    vec2 bias=vec2(0.52,0.52);
    cord=cord-step(bias,vTexCoor)*0.50;
    highp vec2 xy=mod(cord*1900.0,2400.0);
    float tt=fract(tan(distance(xy*1.6182743,xy)*175.53)*xy.x);
    float n =(tt-0.48)*k1;
    vec4 psenoise=vec4(vec3(n,n,n),1.0)*(1.0-smoothstep(0.90,0.96,lum));
    vec4 addNoise=clamp((psenoise+pixelColor),0.0,1.0);


    outFragColor=(addNoise);
}
