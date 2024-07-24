extern highp float TRAngle=.5;//全反射角，暂时没用上
vec4 effect( vec4 color, Image texture, vec2 texCoord, vec2 scrCoord ){
    vec4 px=texture2D(texture,texCoord);
    //变换成立体坐标系
    highp float x=texCoord.x*2-1.;
    highp float z=-(texCoord.y*2-1.);
    highp float rsq=x*x+z*z;//半径的平方
    if (x*x+z*z>1.) return vec4(0.,0.,0.,0.);
    //highp float y=-sqrt(1.-rsq);

    //highp float ra=atan(z,-y);
    //highp float ll=max(z/sqrt(x*x+(1.-y)*(1.-y)+z*z),0.)*.6;

    //ll=（反光与泛光取大）+（边缘光）
    highp float ll=max(rsq*(z*.9),rsq*.3) + min((.5+.5*sign(rsq-.94+z*.02))*(z+2.)/3.,1.)*.8;
    return vec4(1.,1.,1.,ll)*color;
}