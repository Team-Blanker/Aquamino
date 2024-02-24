local ins,rem=table.insert,table.remove

local rain={}
local rListS,rListM,tList={},{},{}
local insTimeS,insTimeM,thunTime=0,0,0
local lighTTL=.25
function rain.init()
    rain.density=200
    rain.thunderDensity=0.25
    rain.angle=0
end
function rain.addLightning()
    ins(tList,lighTTL)
end
function rain.update(dt)
    insTimeS=insTimeS+dt
    for i=#rListS,1,-1 do
        rListS[i].t=rListS[i].t+dt
        if rListS[i].t>2 then rem(rListS,i) end
    end
    if insTimeS>2/rain.density then
        ins(rListS,{x=2000*(rand()-.5),t=0})
        insTimeS=insTimeS-2/rain.density
    end
    if math.random()<dt*rain.density/2 then
        ins(rListS,{x=2000*(rand()-.5),t=0})
    end
    insTimeM=insTimeM+dt
    for i=#rListM,1,-1 do
        rListM[i].t=rListM[i].t+dt
        if rListM[i].t>1 then rem(rListM,i) end
    end
    if insTimeM>4/rain.density then
        ins(rListM,{x=2000*(rand()-.5),t=0})
        insTimeM=insTimeM-4/rain.density
    end
    if math.random()<dt*rain.density/2 then
        ins(rListM,{x=2000*(rand()-.5),t=0})
    end

    if rain.thunderDensity~=0 then thunTime=thunTime+dt
        for i=#tList,1,-1 do
            tList[i]=tList[i]-dt
            if tList[i]<0 then rem(tList,i) end
        end
        if thunTime>2/rain.thunderDensity then
            ins(tList,lighTTL)
            thunTime=thunTime-2/rain.thunderDensity
        end
        if math.random()<dt*rain.thunderDensity/2 then
            ins(tList,lighTTL)
        end
    end
end
function rain.draw()
    gc.clear(.04,.04,.08)
    for i=1,#tList do
        gc.setColor(1,1,1,tList[i]/lighTTL*.15)
        gc.rectangle('fill',-1000,-600,2000,1200)
    end
    gc.push('transform')
    gc.rotate(rain.angle)
    gc.setColor(.8,.8,.84,.75)
    for i=1,#rListS do
        gc.rectangle('fill',rListS[i].x-1,-2000+2500*rListS[i].t,2,40)
    end
    for i=1,#rListM do
        gc.rectangle('fill',rListM[i].x-2,-2000+5000*rListM[i].t,4,80)
    end
    gc.pop()
end
return rain