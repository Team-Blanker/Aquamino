local ins,rem=table.insert,table.remove

local rain={}
local rList,rListM,tList={},{},{}
--rList={x,t,x,t,x,t...}
local insTime,thunTime=0,0
local lightTTL=.25
function rain.init()
    rain.density=200
    rain.thunderDensity=0.25
    rain.angle=0
    rList,tList={},{}
end
function rain.addLightning()
    ins(tList,lightTTL)
end
function rain.update(dt)
    insTime=insTime+dt
    for i=#rList-2,1,-3 do
        rList[i+1]=rList[i+1]+dt
        if rList[i+1]>=2 then rem(rList,i) rem(rList,i) rem(rList,i) end
    end
    if insTime>2/rain.density then
        ins(rList,2000*(rand()-.5))
        ins(rList,0)
        ins(rList,.5+.5*rand())
        insTime=insTime-2/rain.density
    end
    if math.random()<dt*rain.density/2 then
        ins(rList,2000*(rand()-.5))
        ins(rList,0)
        ins(rList,.5+.5*rand())
    end

    if rain.thunderDensity~=0 then thunTime=thunTime+dt
        for i=#tList,1,-1 do
            tList[i]=tList[i]-dt
            if tList[i]<0 then rem(tList,i) end
        end
        if thunTime>2/rain.thunderDensity then
            ins(tList,lightTTL)
            thunTime=thunTime-2/rain.thunderDensity
        end
        if math.random()<dt*rain.thunderDensity/2 then
            ins(tList,lightTTL)
        end
    end
    --print(#rListS)
end
function rain.draw()
    gc.clear(.04,.04,.08)
    for i=1,#tList do
        gc.setColor(1,1,1,tList[i]/lightTTL*.2)
        gc.rectangle('fill',-1000,-600,2000,1200)
    end
    gc.push('transform')
    gc.rotate(rain.angle)
    for i=1,#rList,3 do
        local sz=1/rList[i+2]
        gc.setColor(.8,.8,.84,1-.5*rList[i+2])
        gc.rectangle('fill',rList[i]-.5*sz,-2000*sz+3000*sz*rList[i+1],sz,80*sz)
    end
    gc.pop()
end
return rain