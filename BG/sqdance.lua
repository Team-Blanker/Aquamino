local bg={}

local parlist={}
local parTTL=5
local newpartime=0
local numparlist1={}
local numparlist2={}
local numparTTL1=.5
local numparTTL2=.25
local newnumpartime1=0
local newnumpartime2=0
function bg.update(dt)
    for i=#parlist,1,-1 do
        local p=parlist[i]
        p.time=p.time+dt
        if p.time>=parTTL then table.remove(parlist,i) end
    end

    if newpartime<=0 then
        table.insert(parlist,{px=rand()*1920-960,v=75*(1-rand(0,1)*2),hue=4.625+.5*rand(),time=0})
        newpartime=.15+.1*math.random()
    else newpartime=newpartime-dt end
    if rand()<dt*2 and #parlist<20 then
        table.insert(parlist,{px=rand()*1920-960,v=75*(1-rand(0,1)*2),hue=4.625+.5*rand(),time=0})
    end

    for i=#numparlist1,1,-1 do
        local p=numparlist1[i]
        p.time=p.time+dt
        if p.time>=numparTTL1 then table.remove(numparlist1,i) end
    end
    if newnumpartime1<=0 then
        table.insert(numparlist1,{pos=384*rand(-2,2),num=rand(0,9),time=0})
        newnumpartime1=1/40
    else newnumpartime1=newnumpartime1-dt end
    if rand()<dt*2 and #numparlist1<50 then
        table.insert(numparlist1,{pos=384*rand(-2,2),num=rand(0,9),time=0})
    end

    for i=#numparlist2,1,-1 do
        local p=numparlist2[i]
        p.time=p.time+dt
        if p.time>=numparTTL2 then table.remove(numparlist2,i) end
    end
    if newnumpartime2<=0 then
        table.insert(numparlist2,{pos=384*rand(-2,2),num=rand(0,9),time=0})
        newnumpartime2=1/25
    else newnumpartime2=newnumpartime2-dt end
    if rand()<dt and #numparlist2<10 then
        table.insert(numparlist2,{pos=384*rand(-2,2),num=rand(0,9),time=0})
    end
end
local tau=math.pi*2
function bg.draw()
    gc.setBlendMode('add','alphamultiply')
    gc.clear(0,0,0)
    for i=1,#parlist do
        local p=parlist[i]
        gc.setColor(COLOR.hsv(p.hue,1,1,min(parTTL-math.abs(2*p.time-parTTL),1)^2*.1))
        gc.setLineWidth(360)
        local x=p.px+p.time*p.v
        gc.line(x,-540,x,540)
    end
    for i=1,#numparlist1 do
        local p=numparlist1[i]
        gc.setColor(1,1,1,(1-p.time/numparTTL1)*.2)
        gc.printf(p.num,font.JB_L,p.pos,0,100,'center',0,3,3,50,font.height.JB_L/2)
    end
    for i=1,#numparlist2 do
        local p=numparlist2[i]
        for j=0,1,1/32 do
            gc.setColor(1,.75,.5,(1-p.time/numparTTL2)*.0125)
            gc.printf(p.num,font.JB_B,p.pos+60*cos(tau*j),60*sin(tau*j),100,'center',0,5,5,50,font.height.JB_B/2)
        end
        gc.setColor(1,.75,.5,(1-p.time/numparTTL2)*.6)
        gc.printf(p.num,font.JB_L,p.pos,0,100,'center',0,5,5,50,font.height.JB_L/2)
    end
    gc.setBlendMode('alpha','alphamultiply')
end
return bg
