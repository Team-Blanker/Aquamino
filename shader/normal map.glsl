//法线贴图格式：
//        ^Y
//      \ |
//       \|
//--------O------->X
//        |\
//        | \
//        |  vZ(指向屏幕外)

extern vec3 light;//光照方向
vec4 effect( vec4 color, Image texture, vec2 texCoord, vec2 scrCoord ){
    vec4 px=texture2D(texture,texCoord);
    vec3 vec=px.rgb*2.-1.;
    float l=px.a;
    //计算反射光
    vec3 ref=light+vec;
    //计算与Z轴夹角余弦值并输出
    float scrl=ref.z/(ref.x*ref.x+ref.y*ref.y+ref.x*ref.z);
    return vec4(scrl,scrl,scrl,l);
}