local ins,rem=table.insert,table.remove

local bg={}
local bbListS,bbListM,bbListL={},{},{}
local insTimeS,insTimeM,insTimeL=0,0,0
function bg.init()
    bbListS,bbListM,bbListL={},{},{}
    bg.density=12
    bg.thunderDensity=0.25
    bg.angle=0
end
function bg.update(dt)
    insTimeS=insTimeS+dt
    for i=#bbListS,1,-1 do
        bbListS[i].t=bbListS[i].t+dt
        if bbListS[i].t>20 then rem(bbListS,i) end
    end
    if insTimeS>2/bg.density then
        ins(bbListS,{x=2000*(rand()-.5),t=0})
        insTimeS=insTimeS-2/bg.density
    end
    if math.random()<dt*bg.density/2 then
        ins(bbListS,{x=2000*(rand()-.5),t=0})
    end
    insTimeM=insTimeM+dt
    for i=#bbListM,1,-1 do
        bbListM[i].t=bbListM[i].t+dt
        if bbListM[i].t>15 then rem(bbListM,i) end
    end
    if insTimeM>8/bg.density then
        ins(bbListM,{x=2000*(rand()-.5),t=0})
        insTimeM=insTimeM-4/bg.density
    end
    if math.random()<dt*bg.density/8 then
        ins(bbListM,{x=2000*(rand()-.5),t=0})
    end
    for i=#bbListL,1,-1 do
        bbListL[i].t=bbListL[i].t+dt
        if bbListL[i].t>10 then rem(bbListL,i) end
    end
    if insTimeL>16/bg.density then
        ins(bbListL,{x=2000*(rand()-.5),t=0})
        insTimeL=insTimeL-16/bg.density
    end
    if math.random()<dt*bg.density/16 then
        ins(bbListL,{x=2000*(rand()-.5),t=0})
    end
end
local c=gc.newCanvas(1,2)
gc.setCanvas(c)
gc.setColor(.06, .1, .2) gc.points(.5, .5)
gc.setColor(.04,.04,.08) gc.points(.5,1.5)
gc.setCanvas()
local bb=gc.newCanvas(64,64)
gc.setCanvas(bb)
gc.setLineWidth(1)
for i=1,10 do
    gc.setColor(1,1,1,.75*i/16)
    gc.circle('line',32,32,18+i)
end
gc.setLineWidth(4)
gc.setColor(1,1,1)
gc.circle('line',32,32,30)
gc.setCanvas()
function bg.draw()
    gc.draw(c,0,0,0,1920,540,.5,1)
    gc.push('transform')
    gc.rotate(bg.angle)
    gc.setColor(.8,.8,.84,.06)
    for i=1,#bbListS do
        --gc.circle('line',bbListS[i].x,1200-300*bbListS[i].t,20)
        gc.draw(bb,bbListS[i].x,1200-300*bbListS[i].t,0,.625,.625,32,32)
    end
    gc.setColor(.8,.8,.84,.09)
    for i=1,#bbListM do
        gc.draw(bb,bbListM[i].x,1800-450*bbListM[i].t,0,.9375,.9375,32,32)
    end
    gc.setColor(.8,.8,.84,.15)
    for i=1,#bbListL do
        gc.draw(bb,bbListL[i].x,2400-600*bbListL[i].t,0,1.25,1.25,32,32)
    end
    gc.pop()
end
return bg