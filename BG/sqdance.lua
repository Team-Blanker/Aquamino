--对Lumines Remastered的关卡Square Dance的拙劣模仿
local bg={}
local time=0
local parlist={}
local parTTL=5
local newpartime=0
local numparlist1={}
local numparlist2={}
for i=1,5 do
    numparlist1[i]={count=0}
    for j=1,10 do
        numparlist1[i][j]={num=0,time=1e99}
    end
end
for i=1,5 do
    numparlist2[i]={count=0}
    for j=1,6 do
        numparlist2[i][j]={num=0,time=1e99}
    end
end
local numparTTL1=.5
local numparTTL2=.25
local newnumpartime1=0
local newnumpartime2=0

local numparCount2=0
local p
function bg.update(dt)
    time=time+dt

    for i=#parlist,1,-1 do
        p=parlist[i]
        p.time=p.time+dt
        if p.time>=parTTL then table.remove(parlist,i) end
    end

    if newpartime<=0 then
        table.insert(parlist,{px=rand()*2400-1200,v=75*(1-rand(0,1)*2),hue=4.625+.5*rand(),time=0})
        newpartime=newpartime+.15+.1*math.random()
    else newpartime=newpartime-dt end
    if rand()<dt*2 and #parlist<24 then
        table.insert(parlist,{px=rand()*2400-1200,v=75*(1-rand(0,1)*2),hue=4.625+.5*rand(),time=0})
    end

    newnumpartime1=newnumpartime1-dt
    if newnumpartime1<=0 then
        for i=1,5 do
            p=numparlist1[i][1+numparlist1[i].count%#numparlist1[i]]
            p.num=rand(10)-1 p.time=0
            numparlist1[i].count=numparlist1[i].count+1
        end
        newnumpartime1=newnumpartime1+1/16
    end
    for i=1,5 do
        for j=1,#numparlist1[i] do
            p=numparlist1[i][j]
            p.time=p.time+dt
        end
    end

    newnumpartime2=newnumpartime2-dt
    if newnumpartime2<=0 then
        local index=1+floor(numparCount2*(2.5+8/32))%5
        p=numparlist2[index][1+numparlist2[index].count%#numparlist2[1]]
        p.num=rand(10)-1 p.time=0
        numparlist2[index].count=numparlist2[index].count+1
        numparCount2=numparCount2+1
        newnumpartime2=newnumpartime2+1/32
    end
    for i=1,5 do
        for j=1,#numparlist2[i] do
            p=numparlist2[i][j]
            p.time=p.time+dt
        end
    end
end
local tau=math.pi*2
function bg.draw()
    gc.setBlendMode('add','alphamultiply')
    gc.clear(0,0,0)
    for i=1,#parlist do
        p=parlist[i]
        gc.setColor(COLOR.hsv(p.hue,1,1,min(parTTL-math.abs(2*p.time-parTTL),1)^2*.1))
        gc.setLineWidth(360)
        local x=p.px+p.time*p.v
        gc.line(x,-540,x,540)
    end
    for i=1,#numparlist1 do
        for j=1,#numparlist1[i] do
            p=numparlist1[i][j]
            if p.time<numparTTL1 then
                gc.setColor(.15,.15,.15,(1-p.time/numparTTL1)*1)
                gc.printf(p.num,font.JB_EL,384*(i-3),0,100,'center',0,3.6,3.6,50,font.height.JB_EL/2)
            end
        end
    end
    for i=1,#numparlist2 do
        for j=1,#numparlist2[i] do
            p=numparlist2[i][j]
            if p.time<numparTTL2 then
                local l=1-p.time/numparTTL2
                for t=0,1,1/32 do
                    gc.setColor(1,.7,.4,l*.008)
                    gc.printf(p.num,font.JB_EL,384*(i-3)+20*cos(tau*t),20*sin(tau*t),100,'center',0,5.4,5.4,50,font.height.JB_EL/2)
                    gc.printf(p.num,font.JB_EL,384*(i-3)+40*cos(tau*t),40*sin(tau*t),100,'center',0,5.4,5.4,50,font.height.JB_EL/2)
                end
                gc.setColor(1,.75,.5,l*.75)
                gc.printf(p.num,font.JB_EL,384*(i-3),0,100,'center',0,5.4,5.4,50,font.height.JB_EL/2)
            end
        end
    end
    gc.setBlendMode('alpha','alphamultiply')
    gc.setColor(0,0,0,.2)
    gc.rectangle('fill',-960,-540,1920,1080)
end
return bg
