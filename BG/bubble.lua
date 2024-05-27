local ins,rem=table.insert,table.remove

local bg={}
local bbList={}
local insTime=0
function bg.init()
    bbList={}
    bg.density=18
end
local c=gc.newCanvas(1,2)
gc.setCanvas(c)
gc.setColor(.06, .1, .2) gc.points(.5, .5)
gc.setColor(.04,.04,.08) gc.points(.5,1.5)
gc.setCanvas()

local  pi,tau=math.pi,2*math.pi
function bg.newBubble()
    local nb={x=3000*(rand()-.5),t=0,distance=.3+rand()*1.2,phase=rand()*tau}
    print(nb.distance)
    if #bbList==0 then ins(bbList,nb)
    else for i=1,#bbList do
        if nb.distance>=bbList[i].distance then ins(bbList,nb) break end--按距离从远到近排序
    end end
end
function bg.update(dt)
    insTime=insTime+dt
    for i=#bbList,1,-1 do
        bbList[i].t=bbList[i].t+dt
        if bbList[i].t>20 then rem(bbList,i) end
    end
    if insTime>2/bg.density then
        bg.newBubble()
        insTime=insTime-2/bg.density
    end
    if math.random()<dt*bg.density/2 then
        bg.newBubble()
    end

    gc.setCanvas(c)
    gc.setColor(COLOR.hsv(3.75,.8,.16+.02*sin(scene.time%6/3*math.pi))) gc.points(.5, .5)
    gc.setCanvas()
end
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
local s
function bg.draw()
    gc.draw(c,0,0,0,1920,540,.5,1)
    gc.push('transform')
    for i=1,#bbList do
        s=1/bbList[i].distance
        gc.setColor(.96,.96,.96,.12*s)
        gc.draw(bb,(bbList[i].x+12*sin(pi*bbList[i].t))*s,(1200-300*bbList[i].t)*s,0,s,s,32,32)
    end
    gc.pop()
end
return bg