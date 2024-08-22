#define pi 3.1415926535898
extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float rd=9./16.;
    float ad=step(rd,love_ScreenSize.y/love_ScreenSize.x);

    highp float x=(scrCoord.x/love_ScreenSize.x*2.-1.)*(ad+(1-ad)*love_ScreenSize.x/(love_ScreenSize.y/rd))*16.;
    highp float y=(scrCoord.y/love_ScreenSize.y*2.-1.)*((1-ad)+ad*love_ScreenSize.y/(love_ScreenSize.x*rd))*9.;

    return mix(vec4(0,0,0,1),vec4(1,.5,.5,1),abs(mod(.5+.5*sin(x*pi)*sin(y*pi)+phase,2.)-1.)*.5);
}