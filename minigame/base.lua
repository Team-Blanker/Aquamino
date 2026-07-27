local LP=love.physics
local setColor,setLineWidth=gc.setColor,gc.setLineWidth
local circle,arc,rect,poly,line,draw=gc.circle,gc.arc,gc.rectangle,gc.polygon,gc.line,gc.draw
local printf=gc.printf

local gb={}
local contactList={}
local contactSolveList={}

local function beginContact(fa,fb,coll)
    if (fa:getUserData() and fa:getUserData().onCollide) or (fb:getUserData() and fb:getUserData().onCollide) then table.insert(contactList,coll) end
end
local function endContact(fa,fb,coll)

end
local function preSolve(fa,fb,coll)
    if (fa:getUserData() and fa:getUserData().onCollideSolve) or (fb:getUserData() and fb:getUserData().onCollideSolve) then table.insert(contactSolveList,coll) end
end
local function postSolve(fa,fb,coll,normalImpulse,tangentImpulse)

end

local function die(this)
    table.insert(gb.dieList,this)
end

function gb.init()
    --拟真运行状态
    gb.sim=false
    gb.readyTime=3
    gb.time=0
    gb.updateTimer=0

    gb.dieList={}
    --生命
    gb.targetHP={L=4000,R=4000}
    --初始化世界
    gb.world=LP.newWorld(0,960) gb.world:setSleepingAllowed(false)
    gb.world:setCallbacks(beginContact,endContact,preSolve,postSolve)
    LP.setMeter(20)
end
function gb.keyP(k)
    if k=='space' or k=='return' then gb.sim=not gb.sim
    elseif k=='escape' then
        scene.switch({
            dest='intro',destScene=require('scene/secret/AquaMarbler'),swapT=.6,outT=.2,
            anim=function() anim.cover(.2,.4,.2,0,0,0) end
        })
    end
end
function gb.touchP(id,x,y)
    gb.sim=not gb.sim
end
function gb.update(dt)
    if gb.sim then gb.updateTimer=gb.updateTimer+dt
        while gb.updateTimer>=1/128 do gb.gameUpdate(1/128) gb.updateTimer=gb.updateTimer-1/128 end
    end
end
function gb.gameUpdate(dt)
    gb.readyTime=gb.readyTime-dt
    if gb.readyTime>0 then return end

    gb.world:update(dt,8,3) gb.time=gb.time+dt

    for i=#contactList,1,-1 do
        if not contactList[i]:isDestroyed() and contactList[i]:isTouching() then fa,fb=contactList[i]:getFixtures()
        if fa:getUserData() and fa:getUserData().onCollide then fa:getUserData().onCollide(fa,fb) end
        if fb:getUserData() and fb:getUserData().onCollide then fb:getUserData().onCollide(fb,fa) end
        end
        table.remove(contactList,i)
    end
    for i=#contactSolveList,1,-1 do
        if not contactSolveList[i]:isDestroyed() and contactSolveList[i]:isTouching() then fa,fb=contactSolveList[i]:getFixtures()
        if fa:getUserData() and fa:getUserData().onCollideSolve then fa:getUserData().onCollideSolve(fa,fb) end
        if fb:getUserData() and fb:getUserData().onCollideSolve then fb:getUserData().onCollideSolve(fb,fa) end
        end
        table.remove(contactSolveList,i)
    end
    for i=#gb.dieList,1,-1 do
        if not gb.dieList[i]:isDestroyed() then gb.dieList[i]:getBody():destroy() end
        gb.dieList[i]=nil
    end
end
local bgpic=gc.newImage('pic/AquaMarbler/AquaMarbler.png') --1950x450
function gb.draw()
    gc.clear(0,0,0)
    setColor(1,1,1,.5)
    draw(bgpic,0,0,0,1,1,975,225)
    gc.push()
    gc.scale(1.2)

    setColor(1,1,1,.5)
    printf(string.format("%02d:%02d",gb.time/60,gb.time%60),font.OX_SB,0,-400,1000,'center',0,.6,.6,500,font.height.OX_SB/3)
    setColor(1,1,1,gb.sim and 1 or .5)
    if gb.readyTime>0 then printf(string.format("%d",ceil(gb.readyTime)),font.OX_SB,0,0,1000,'center',0,1.5,1.5,500,font.height.OX_SB/3) end

    gc.pop()
end
return gb