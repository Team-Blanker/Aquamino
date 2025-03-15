#define pi 3.1415926535898
extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    highp float x=8.*texCoord.x-4.;
    highp float y=8.*texCoord.y-4.;

    highp float x1=max(2.5*cos(2.*pi*phase),0.);
    highp float y1=max(-2.5*cos(2.*pi*phase),0.);
    highp float v=((x-x1)*(x-x1)+(y-y1)*(y-y1)-1.)*((x+x1)*(x+x1)+(y+y1)*(y+y1)-1.);
    float k=1.-sign(v-pow(sin(2.*pi*phase),2));
    return vec4(1,1,1,k);
}