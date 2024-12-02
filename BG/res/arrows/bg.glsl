extern highp float phase;
vec4 effect(vec4 color,sampler2D tex,vec2 texCoord,vec2 scrCoord){

    highp float x=(scrCoord.x/1920*2.-1.)*16.;
    highp float y=(scrCoord.y/1080*2.-1.)*9.;

    highp float r=sqrt((x*x+y*y)/337.);
    //highp float r=1.+phase;
    return mix(vec4(.5,.625,1.,.125+.075*r),vec4(.5,.875,1.,.125+.075*r),.5+.5*sin(phase));
    //return vec4(1,0,0,1+phase);
    //return vec4(r,0,0,.5);
}