extern highp float H;
vec4 effect( vec4 color, Image texture, vec2 texCoord, vec2 scrCoord ){
    vec4 pixel = texture2D(texture,texCoord);
    float Cmax=max(pixel.r,max(pixel.g,pixel.b));
    float Cmin=min(pixel.r,min(pixel.g,pixel.b));
    float C=Cmax-Cmin;
    float R1=clamp(3*abs(mod( H   /3,2)-1)-1,0,1);
    float G1=clamp(3*abs(mod((H-2)/3,2)-1)-1,0,1);
    float B1=clamp(3*abs(mod((H-4)/3,2)-1)-1,0,1);
    return vec4(Cmin+C*R1,Cmin+C*G1,Cmin+C*B1,pixel.a);
    //return vec4(H/6,H/6,H/6,.5);
}