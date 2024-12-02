#define pi 3.1415926535898
extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){

    //highp float x=texCoord.x; highp float y=texCoord.y;
    texCoord.y=texCoord.y+20./1080.*sin((texCoord.x*1920./120.+phase)*pi);
    texCoord.x=texCoord.x+20./1920.*cos((texCoord.y*1080./120.+phase)*pi);
    return texture2D(tex,texCoord);
}