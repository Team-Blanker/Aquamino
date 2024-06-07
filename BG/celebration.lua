local ins,rem=table.insert,table.remove

local bg={}
function bg.init()
    bg.parList={}--{sz,x,y,vx,vy,TTL}
    bg.fireList={}--{sz,x,y,vs,clr,timer,TTL}
    bg.parTimer=0
    bg.emitAvgPeriod=0.8
end
local c=gc.newCanvas(1,2)
gc.setCanvas(c)
gc.setColor(.05,.1,.075) gc.points(.5, .5)
gc.setColor(.04,.04,.08) gc.points(.5,1.5)
gc.setCanvas()
function bg.update(dt)
    bg.parTimer=bg.parTimer+dt
    if bg.parTimer>=bg.emitAvgPeriod/2 then
        ins(bg.parList,{
            sz=7+rand(17),x=2100*(rand()-.5),y=600,
            vx=900*(rand()-.5),vy=-500-1000*(rand()^.5),
            TTL=.5+rand(),angle=2*rand()
        })
        bg.parTimer=bg.parTimer-bg.emitAvgPeriod/2
    end
    if rand()<dt*bg.emitAvgPeriod/2 then
        ins(bg.parList,{
            sz=7+rand(17),x=2100*(rand()-.5),y=600,
            vx=900*(rand()-.5),vy=-500-1000*(rand()^.5),
            TTL=.5+rand(),angle=2*rand()
        })
    end

    for i=#bg.parList,1,-1 do
        local p=bg.parList[i]
        p.TTL=p.TTL-dt
        if p.TTL<=0 then
            local t=(rand()+.5+(p.sz-8)/8)*.625
            local r,g,b=COLOR.hsv(2.75+6*(2*rand()-1)^3,.5,1)
            --local r,g,b=COLOR.hsv(rand()*6,.5,1)
            ins(bg.fireList,{
                sz=p.sz,x=p.x,y=p.y,
                vx=p.vx,vy=p.vy,
                vs=100+rand()*(4500/p.sz),
                clr={r,g,b},
                timer=0,TTL=t,angle=p.angle
            })
            rem(bg.parList,i)
        else
            p.x,p.y=p.x+dt*p.vx,p.y+dt*p.vy
            p.vy=p.vy+dt*1000
        end
    end

    for i=#bg.fireList,1,-1 do
        local p=bg.fireList[i]
        p.timer=p.timer+dt
        if p.TTL<=p.timer then rem(bg.fireList,i) end
    end
end
local p,s,r
local tau=2*math.pi
function bg.draw()
    gc.setLineWidth(4)
    gc.draw(c,0,0,0,1920,540,.5,1)
    if scene.time%.2<.1 then gc.setColor(1,1,1) else gc.setColor(.5,1,.875) end
    for i=1,#bg.parList do
        p=bg.parList[i]
        gc.circle('fill',p.x,p.y,p.sz/4)
    end
    for i=1,#bg.fireList do
        p=bg.fireList[i]
        s=-(math.exp(-p.timer*4)-1)/4
        r=p.vs*p.timer

        gc.setColor(p.clr[1],p.clr[2],p.clr[3],2-2*(p.timer/p.TTL))
        for j=1,p.sz do
            gc.circle('fill', p.x+p.vx*s+r*cos((j/p.sz+p.angle)*tau),p.y+p.vy*s+r*sin((j/p.sz+p.angle)*tau), 6,4)
            --gc.circle('line',p.x+p.vx*s,p.y+p.vy*s,p.vs*p.timer)
        end
    end
end
return bg