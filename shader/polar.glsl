uniform highp float wins;uniform Image img;
uniform float scale;uniform float angle;uniform float yShift;
vec4 effect( vec4 color, Image texture, vec2 texCoord, vec2 scrCoord ){
    float x=(scrCoord.x-love_ScreenSize.x/2)/wins/1080/scale;
    float y=(scrCoord.y-love_ScreenSize.y/2)/wins/1080/scale;
    texCoord.x=mod(1-(atan(y,x)/3.1415926535898/2+.5)+angle,1);
    texCoord.y=mod(atan(sqrt(x*x+y*y))/1.5707963267949+yShift,1);
    //texCoord.x+=.3;
    vec4 pixel = texture2D(img,texCoord);
    return pixel;
}