#define pi 3.1415926535898
extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){

    //highp float m=1920/phase;
    //highp float x=texCoord.x; highp float y=texCoord.y;
    texCoord.y=(floor(texCoord.y*1080./20))*20/1080.;
    texCoord.x=(floor(texCoord.x*1920./20))*20/1920.;
    return texture2D(tex,texCoord);
}