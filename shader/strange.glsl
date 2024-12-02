extern highp float phase;

highp float TWave(highp float x){
    return abs(mod(x,2.)-1.)*2.-1.;
}
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){

    //highp float x=texCoord.x; highp float y=texCoord.y;
    texCoord.y=texCoord.y+40./1080.*TWave((texCoord.x*1920./120.+phase));
    texCoord.x=texCoord.x+40./1920.*TWave((texCoord.y*1080./120.+phase));
    return texture2D(tex,texCoord);
}