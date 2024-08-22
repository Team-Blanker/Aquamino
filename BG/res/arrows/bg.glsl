extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){
    float rd=9./16.;
    float ad=step(rd,love_ScreenSize.y/love_ScreenSize.x);

    highp float x=(scrCoord.x/love_ScreenSize.x*2.-1.)*(ad+(1-ad)*love_ScreenSize.x/(love_ScreenSize.y/rd))*16.;
    highp float y=(scrCoord.y/love_ScreenSize.y*2.-1.)*((1-ad)+ad*love_ScreenSize.y/(love_ScreenSize.x*rd))*9.;

    highp float r=sqrt((x*x+y*y)/337.);
    return mix(vec4(.5,.625,1,.125+.075*r),vec4(.5,.875,1,.125+.075*r),.5+.5*sin(phase));
}