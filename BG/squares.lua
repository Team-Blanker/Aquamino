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
local a,c,s
function bg.draw()
    gc.clear(sqr*.25,sqg*.25,sqb*.25)
    for i=16,1,-1 do  for j=9,1,-1 do  for k=1,4 do
        a=abs((sq[i][j][k].phase+t)*2%2-1)
        s=1/(1-.04*(3*a^2-2*a^3))
        c=sq[i][j][k].light
        gc.setColor(sqr*c,sqg*c,sqb*c)
        gc.rectangle('fill',((i-.5)*posScale[k*2-1]-.5)*bsz*s,((j-.5)*posScale[k*2]-.5)*bsz*s,bsz*s,bsz*s)
    end  end  end
end
return bg