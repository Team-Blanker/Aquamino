vec4 effect( vec4 color, Image texture, vec2 texCoord, vec2 scrCoord ){
    vec4 px = texture2D(texture,texCoord);
    float Cmax=max(px.r,max(px.g,px.b));
    float Cmin=min(px.r,min(px.g,px.b));
    float L=Cmax+Cmin; float v=min(floor(L),1.);
    px.rgb=mix(vec3(v,v,v),color.rgb,1-abs(L-1)); px.a*=color.a;
    return px;
}