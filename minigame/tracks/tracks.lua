local LP=love.physics
local setColor=gc.setColor
local max,min,ceil,floor=math.max,math.min,math.ceil,math.floor
local circle,rect,poly,draw=gc.circle,gc.rectangle,gc.polygon,gc.draw
local printf=gc.printf

local obsList={--障碍分布，用Algodoo作出，坐标需乘以80，y轴需反转
}
local teamColor={
    R={1,.2,.2},B={.2,.6,1}
}
local ballColor={
    p3={.6,1,.2},p5={.2,1,.8},m12={.8,.4,.8}
}
local track={}

local contactList={}
local function preSolve(fa,fb,coll)
    if track.onCollide[fa] or track.onCollide[fb] then table.insert(contactList,coll) end
end

function track.init()
    track.team={
        [1]={},
        [2]={}
    }
    track.teamBelong={}

    track.sim=false
    track.time=0 track.updateTimer=0
    track.gameTime=300 track.readyTime=5

    track.world=LP.newWorld(0,0) track.world:setSleepingAllowed(false)
    track.world:setCallbacks(nil,nil,preSolve,nil)
    LP.setMeter(15)


    track.edge={}--游戏边界
    track.ctrl={edge={},obs={},cmd={},ball={}}--控制区 边界、障碍、指令、小球
    track.type={}

    for i=1,6 do--创建边界
        if i<=2 then
            track.edge[i]={
                body=LP.newBody(track.world,0,45+480*(i%2*2-1),'static'),
                shape=LP.newRectangleShape(1920,30),
            }
        elseif i<=4 then
            track.edge[i]={
                body=LP.newBody(track.world,945*(i%2*2-1),60,'static'),
                shape=LP.newRectangleShape(30,960),
            }
        elseif i<=5 then
            track.edge[i]={
                body=LP.newBody(track.world,180,45,'static'),
                shape=LP.newRectangleShape(1500,30),
            }
        else
            track.edge[i]={
                body=LP.newBody(track.world,-555,60,'static'),
                shape=LP.newRectangleShape(30,960),
            }
        end
        track.edge[i].fixture=LP.newFixture(track.edge[i].body,track.edge[i].shape,1)
        track.edge[i].fixture:setCategory(5)
        track.edge[i].fixture:setFriction(0)
        track.edge[i].fixture:setRestitution(1)
        track.type[track.edge[i].fixture]='edge'
    end
end
function track.keyP(k)
    if k=='space' or k=='return' then track.sim=not track.sim
    elseif k=='escape' then
        scene.switch({
            dest='intro',destScene=require('scene/intro'),swapT=.6,outT=.2,
            anim=function() anim.cover(.2,.4,.2,0,0,0) end
        })
    end
end
local fa,fb
function track.update(dt)
    if track.sim then track.updateTimer=track.updateTimer+dt
        while track.updateTimer>=1/256 do track.gameUpdate(1/256) track.updateTimer=track.updateTimer-1/256 end
    end
end
local vx,vy
function track.gameUpdate(dt)
    track.readyTime=track.readyTime-dt
    if track.readyTime>0 then return end
    track.time=track.time+dt
    track.world:update(dt,1,1)
    track.gameTime=max(track.gameTime-dt,0)

    for i=#contactList,1,-1 do
        if not contactList[i]:isDestroyed() and contactList[i]:isTouching() then fa,fb=contactList[i]:getFixtures()
        if track.onCollide[fa] then track.onCollide[fa](fa,fb) end
        if track.onCollide[fb] then track.onCollide[fb](fb,fa) end
        end
        table.remove(contactList,i)
    end
    --[[for i=#track.bullet,1,-1 do--移除已销毁炮弹
        if track.bullet[i].body:isDestroyed() then table.remove(track.bullet,i) end
    end]]
end


local clr,u
function track.draw()
    --gc.push()
    --gc.scale(1.25)
    gc.setColor(1,1,1)
    for i=-50,50 do circle('fill',30*i,0,4,4) circle('fill',0,30*i,4,4) end
    setColor(.8,.8,.8)
    for i=1,#track.edge do
        u=track.edge[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end

    setColor(1,1,1)
    printf(string.format("%01d:%02d",track.gameTime/60,track.gameTime%60),font.JB_B,-930,-490,1000,'left',0,.625,.625,0,font.height.JB_B/2)
    if track.readyTime>0 then printf(string.format("%d",ceil(track.readyTime)),font.JB_B,0,60,1000,'center',0,1.5,1.5,500,font.height.JB_B/2) end
    printf(user.lang.tracks.info,font.JB_B,930,-490,10000,'right',0,.25,.25,10000,font.height.JB_B)

    --gc.pop()
end
return track