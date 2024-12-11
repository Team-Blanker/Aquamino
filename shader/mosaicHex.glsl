#define pi 3.1415926535898
extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){

    highp float lt=30;//正三角形边长
    highp float th=sqrt(3.)/2.;//正三角形点阵的高度
    //highp float m=1920/phase;
    highp float x=texCoord.x*1920.-960.; highp float y=texCoord.y*1080.-540.;
    highp float z=.5*x+th*y;
    
    return texture2D(tex,texCoord);
}