local ins,rem=table.insert,table.remove

local rain={}
local rListS,rListM,tList={},{},{}
--rList={x,t,x,t,x,t...}
local insTimeS,insTimeM,thunTime=0,0,0
local lightTTL=.25
function rain.init()
    rain.density=200
    rain.thunderDensity=0.25
    rain.angle=0
end
function rain.addLightning()
    ins(tList,lightTTL)
end
function rain.update(dt)
    insTimeS=insTimeS+dt
    for i=#rListS-1,1,-2 do
        rListS[i+1]=rListS[i+1]+dt
        if rListS[i+1]>=2 then rem(rListS,i) rem(rListS,i) end
    end
    if insTimeS>2/rain.density then
        ins(rListS,2000*(rand()-.5))
        ins(rListS,0)
        insTimeS=insTimeS-2/rain.density
    end
    if math.random()<dt*rain.density/2 then
        ins(rListS,2000*(rand()-.5))
        ins(rListS,0)
    end
    insTimeM=insTimeM+dt
    for i=#rListM-1,1,-2 do
        rListM[i+1]=rListM[i+1]+dt
        if rListM[i+1]>=1 then rem(rListM,i) rem(rListM,i) end
    end
    if insTimeM>4/rain.density then
        ins(rListM,2000*(rand()-.5))
        ins(rListM,0)
        insTimeM=insTimeM-4/rain.density
    end
    if math.random()<dt*rain.density/2 then
        ins(rListM,2000*(rand()-.5))
        ins(rListM,0)
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
        gc.setColor(1,1,1,tList[i]/lightTTL*.15)
        gc.rectangle('fill',-1000,-600,2000,1200)
    end
    gc.push('transform')
    gc.rotate(rain.angle)
    gc.setColor(.8,.8,.84,.75)
    for i=1,#rListS,2 do
        gc.rectangle('fill',rListS[i]-1,-2000+2500*rListS[i+1],2,40)
    end
    for i=1,#rListM,2 do
        gc.rectangle('fill',rListM[i]-2,-2000+5000*rListM[i+1],4,80)
    end
    gc.pop()
end
return rain