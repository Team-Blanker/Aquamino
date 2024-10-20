local BG={speed=1,}
local p=24
local vis=10
local t=0
local parList={}
for i=1,16 do
    parList[i]={x=rand()-.5,y=rand()-.5,z=(rand()-.5)*vis*2}
end
function BG.init()
    t=0
end
function BG.update(dt)
    t=t+dt/2
end
local tau=2*math.pi
function BG.draw()
    for i=1,p+.75,.25 do
        local s=(i-t)%p
        local d=max(1-(s-1)/vis,0)^2

        local k,k1=1920/s,1920/(s+.25)
        gc.setLineWidth(10/s)
        gc.setColor(1,1,1,d*.5)
        gc.arc('line','closed',0,0,k,tau*(i/p),tau*(i/p+.75),3)
        gc.setColor(1,1,1,d*.2)
        gc.rectangle('line',-k/2,-k/2,k,k)
        gc.setLineWidth(4)
        --gc.line(-k/2,-k/2,-k1/2,-k1/2)
        --gc.line( k/2,-k/2, k1/2,-k1/2)
        --gc.line( k/2, k/2, k1/2, k1/2)
        --gc.line(-k/2, k/2,-k1/2, k1/2)
    end
end
return BG