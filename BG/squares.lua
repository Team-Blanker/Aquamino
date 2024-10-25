local bg={}
local sq={}

for i=1,16 do
    sq[i]={}
    for j=1,9 do
        sq[i][j]={}
        for k=1,4 do--“象限”
        sq[i][j][k]={light=.375+.25*rand(),phase=rand()}
        end
    end
end

local posScale={1,1,1,-1,-1,-1,-1,1}

local t=0
function bg.update(dt)
    t=t+dt*.25
end

local sqr,sqg,sqb=1,1,1
function bg.setBGColor(r,g,b)
    sqr,sqg,sqb=r,g,b
end
local bsz=1920/32
local a,c,s,x,y
function bg.draw()
    gc.clear(sqr*.25,sqg*.25,sqb*.25)
    for k=1,4 do
        gc.push()
        gc.scale(posScale[k*2-1],posScale[k*2])
        for i=16,1,-1 do  for j=9,1,-1 do
            a=abs((sq[i][j][k].phase+t)*2%2-1)
            s=1/(1-.04*(3*a^2-2*a^3))
            c=sq[i][j][k].light

            x,y=i-1,j-1
            gc.setColor(sqr*c*.8,sqg*c*.8,sqb*c*.8)
            gc.polygon('fill',x*bsz,y*bsz,(x+1)*bsz,y*bsz,(x+1)*bsz*s,y*bsz*s,x*bsz*s,(y+1)*bsz*s,x*bsz,(y+1)*bsz)
            gc.setColor(sqr*c,sqg*c,sqb*c)
            gc.rectangle('fill',x*bsz*s,y*bsz*s,bsz*s,bsz*s)
        end  end
        gc.pop()
    end
end
return bg