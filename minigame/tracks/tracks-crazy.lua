local LP=love.physics
local setColor=gc.setColor
local rand=math.random
local max,min,ceil,floor,abs=math.max,math.min,math.ceil,math.floor,math.abs
local ins,rem=table.insert,table.remove
local arc,circle,rect,poly,draw,setLineW=gc.arc,gc.circle,gc.rectangle,gc.polygon,gc.draw,gc.setLineWidth
local printf=gc.printf
local lerp=myMath.lerp

local obsList={--障碍分布，用Algodoo作出，坐标需乘以80，y轴需反转
}
local teamColor={
    R={1,.2,.2},B={.2,.6,1},
    ['']={.6,.6,.6}
}
local marbleColor={
    p1={.6,.63,.66},p3={.6,1,.2},p5={.2,1,.8},m12={.6,.2,.6}
}
local sc={p1=1,p3=3,p5=5,m12=-12}
local track={}

local contactList={}
local function beginContact(fa,fb,coll)
    if track.onCollide[fa] or track.onCollide[fb] then table.insert(contactList,coll) end
end

local function summonBonusMarble(team,vx,vy,ox,oy)
    if not vx then vx=0 end if not vy then vy=0 end
    if not ox then ox=0 end if not oy then oy=0 end
    track.bonusCtrl.marble[#track.bonusCtrl.marble+1]={
        body=LP.newBody(track.world,track.bonusSummonX+ox,track.bonusSummonY+oy,'dynamic'),
        shape=LP.newCircleShape(12),
    }
    o=track.bonusCtrl.marble[#track.bonusCtrl.marble]
    o.fixture=LP.newFixture(o.body,o.shape,1e-3)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.75)

    local angle=math.pi*2*rand()
    o.body:setLinearVelocity(120*cos(angle)+vx,120*sin(angle)+vy)

    o.fixture:setUserData({team=team})
    track.type[o.fixture]='bonusBall'
end
local function summonTempMarble(team,time)
    track.ctrl1.tempMarble[#track.ctrl1.tempMarble+1]={
        body=LP.newBody(track.world,track.tpPosX,-390,'dynamic'),
        shape=LP.newCircleShape(12),
    }
    o=track.ctrl1.tempMarble[#track.ctrl1.tempMarble]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.75)

    local angle=math.pi*2*rand()
    o.body:setLinearVelocity(120*cos(angle),120*sin(angle))

    o.fixture:setUserData({team=team,time=time,tMax=time})
    track.type[o.fixture]='tempBall'
    track.objUpdate[o.fixture]=function(this,dt)
        local d=this:getUserData()
        d.time=d.time-dt
        if d.time<=0 then this:getBody():destroy() end
    end
end
local function summonPointMarble(team,type)
    track.ctrl2.marble[#track.ctrl2.marble+1]={
        body=LP.newBody(track.world,track.tpPosX,270,'dynamic'),
        shape=LP.newCircleShape(12),
    }
    o=track.ctrl2.marble[#track.ctrl2.marble]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.8)

    local angle=math.pi*2*rand()
    o.body:setLinearVelocity(120*cos(angle),120*sin(angle))

    o.fixture:setUserData({team=team,time=15,tMax=15})
    track.type[o.fixture]=type
    track.objUpdate[o.fixture]=function(this,dt)
        local d=this:getUserData()
        d.time=d.time-dt
        if d.time<=0 then this:getBody():destroy() end
    end
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

    track.world=LP.newWorld(0,1500,false)
    track.world:setCallbacks(beginContact,nil,nil,nil)
    LP.setMeter(15)


    track.edge={}--游戏边界
    track.ctrl1={obs={},remobs={},cmd={},marble={},tempMarble={}}--指令区，抢占轨道
    track.ctrl2={obs={},cmd={},marble={}}--轨道指令区，控制分数球的去向
    track.bonusCtrl={obs={},motorObs={axis={},wheel={},joint={}},cmd={},marble={},specialBarrier={}}--奖励指令区，控制奖励球的奖励，specialBarrier为特殊障碍
    track.type={}--存储物件的种类，若检测到某物体已死亡立刻将其对应参数移除

    track.tpPosX=-750
    track.bonusSummonX,track.bonusSummonY=-450,150

    track.cmdMarbleDestroyed=false

    track.onCollide={}
    track.objUpdate={}

    track.track={}
    for i=1,6 do track.track[i]={} end
    function track.enterTrack(trk,type)
        ins(track.track[trk],{type=type,dist=1})
    end
    track.trackSpeed=1

    track.clearTrackAnimTimer={}
    for i=1,6 do track.clearTrackAnimTimer[i]=1e99 end

    track.score={
        R=0,B=0,['']=0
    }

    track.scoreAnim={}
    for i=1,6 do track.scoreAnim[i]={} end
    function track.addScoreAnim(trk,pos,team,type,defused)
        ins(track.scoreAnim[trk],{type=type,pos=pos,team=team,defused=defused,time=.5,tMax=.5})
    end

    track.trackState={'','','','','',''}
    track.cmdState  ={'','','','','',''}

    track.mvdTimer={0,0,0,0,0,0}--轨道指令区六个菱形的时间参数
    track.mvdTimerCharge=1

    track.bonusTriggerTimer={}
    for i=1,8 do track.bonusTriggerTimer[i]=1e99 end

    --边界
    for i=1,7 do
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
        elseif i<=6 then
            track.edge[i]={
                body=LP.newBody(track.world,-555,60,'static'),
                shape=LP.newRectangleShape(30,960),
            }
        else
            track.edge[i]={
                body=LP.newBody(track.world,-750,225,'static'),
                shape=LP.newRectangleShape(360,30),
            }
        end
        track.edge[i].fixture=LP.newFixture(track.edge[i].body,track.edge[i].shape,1)
        track.edge[i].fixture:setFriction(0)
        track.edge[i].fixture:setRestitution(.8)
        track.type[track.edge[i].fixture]='edge'
    end
    local o
    --指令区障碍
    for i=0,3 do
        for j=0,6 do
            track.ctrl1.obs[#track.ctrl1.obs+1]={
                body=LP.newBody(track.world,(-31+2*j)*30,(-9.5+5*i)*30,'static'),
                shape=LP.newCircleShape(15),
                color={.8,.8,.8}
            }
            o=track.ctrl1.obs[#track.ctrl1.obs]
            o.fixture=LP.newFixture(o.body,o.shape,1)
            o.fixture:setFriction(0)
            o.fixture:setRestitution(.2)
            track.type[o.fixture]='circleobs'
        end
    end
    --指令区可击碎障碍
    local remobsCollide=function(this,other)
        local ud=this:getUserData()
        ud.hp=ud.hp-1
        if ud.hp<=0 then this:getBody():destroy() end
    end
    for i=0,2 do
        for j=0,5 do
            if j==0 then
                track.ctrl1.remobs[#track.ctrl1.remobs+1]={
                    body=LP.newBody(track.world,(-30+2*j)*30,(-7+5*i)*30,'static'),
                    shape=LP.newPolygonShape(0,15, 7.5,7.5*3^.5, 7.5*3^.5,7.5, 15,0, 7.5*3^.5,-7.5, 7.5,-7.5*3^.5, 0,-15),
                }
            elseif j==5 then
                track.ctrl1.remobs[#track.ctrl1.remobs+1]={
                    body=LP.newBody(track.world,(-30+2*j)*30,(-7+5*i)*30,'static'),
                    shape=LP.newPolygonShape(0,15, -7.5,7.5*3^.5, -7.5*3^.5,7.5, -15,0, -7.5*3^.5,-7.5, -7.5,-7.5*3^.5, 0,-15),
                }
            else
                track.ctrl1.remobs[#track.ctrl1.remobs+1]={
                    body=LP.newBody(track.world,(-30+2*j)*30,(-7+5*i)*30,'static'),
                    shape=LP.newCircleShape(15),
                }
            end
            o=track.ctrl1.remobs[#track.ctrl1.remobs]
            o.fixture=LP.newFixture(o.body,o.shape,1)
            o.fixture:setFriction(0)
            o.fixture:setRestitution(.2)
            o.fixture:setUserData({hp=((j==0 or j==5) and 24 or 32)*(i+1),hpMax=128})
            track.onCollide[o.fixture]=remobsCollide
            track.type[o.fixture]=(j==0 or j==5) and 'polyobs' or 'circleobs'
        end
    end
    --指令区弹珠
    for i=1,8 do
        track.ctrl1.marble[#track.ctrl1.marble+1]={
            body=LP.newBody(track.world,-750+30*(i-4.5),-360,'dynamic'),
            shape=LP.newCircleShape(12),
        }
        o=track.ctrl1.marble[#track.ctrl1.marble]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.5)

        local angle=math.pi*2*rand()
        o.body:setLinearVelocity(240*cos(angle),240*sin(angle))

        if i%2==0 then o.fixture:setUserData({team='R'}) else o.fixture:setUserData({team='B'}) end
        track.type[o.fixture]='cmdBall'
    end
    --指令区轨道控制按钮
    local cmdCollide=function(this,other)
        local ctrlTrack,team=this:getUserData(),other:getUserData().team
        if team=='R' then
            if track.cmdState[ctrlTrack]=='B' then
                track.cmdState[ctrlTrack]=''
            elseif track.cmdState[ctrlTrack]=='' then
                track.cmdState[ctrlTrack]='R'
                track.trackState[ctrlTrack]='R'
            else
                summonBonusMarble('R')
            end
        else
            if track.cmdState[ctrlTrack]=='R' then
                track.cmdState[ctrlTrack]=''
            elseif track.cmdState[ctrlTrack]=='' then
                track.cmdState[ctrlTrack]='B'
                track.trackState[ctrlTrack]='B'
            else
                summonBonusMarble('B')
            end
        end
        other:getBody():setPosition(track.tpPosX,-390)
        local angle=math.pi*2*rand()
        other:getBody():setLinearVelocity(100*cos(angle),100*sin(angle))
    end
    for i=1,6 do
        track.ctrl1.cmd[i]={
            body=LP.newBody(track.world,(-32+2*i)*30,195,'static'),
            shape=LP.newRectangleShape(60,30),
        }
        track.ctrl1.cmd[i].fixture=LP.newFixture(track.ctrl1.cmd[i].body,track.ctrl1.cmd[i].shape,1)
        o=track.ctrl1.cmd[i]
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.8)
        track.type[o.fixture]='cmdctrller'
        o.fixture:setUserData(i)
        track.onCollide[o.fixture]=cmdCollide
    end

    --奖励指令区障碍
    local diamondShape=LP.newPolygonShape(0,15,15,0,0,-15,-15,0)
    local sepShape=LP.newPolygonShape(-30,0,-30,-30,0,-60,30,-30,30,0)
    for i=0,6 do--8个菱形障碍
        track.bonusCtrl.obs[i+1]={
            body=LP.newBody(track.world,(-11.5+6*i)*30,375,'static'),
            shape=diamondShape,
            color={.8,.8,.8}
        }
        o=track.bonusCtrl.obs[i+1]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.5)
        o.fixture:setCategory(16)
    end
    track.bonusCtrl.obs[8]={
        body=LP.newBody(track.world,-360,360,'static'),
        shape=diamondShape,
        color={.8,.8,.8}
    }
    o=track.bonusCtrl.obs[8]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.5)
    track.bonusCtrl.obs[9]={
        body=LP.newBody(track.world,-330,360,'static'),
        shape=LP.newPolygonShape(15,0,0,15,-15,0),
        color={.8,.8,.8}
    }
    o=track.bonusCtrl.obs[9]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.5)
    o.fixture:setCategory(16)

    for i=0,8 do--9个分隔障碍
        track.bonusCtrl.obs[#track.bonusCtrl.obs+1]={
            body=LP.newBody(track.world,(-17+6*i)*30,510,'static'),
            shape=i==0 and LP.newPolygonShape(-30,0,-30,-90,30,-30,30,0) or sepShape,
            color={.8,.8,.8}
        }
        o=track.bonusCtrl.obs[#track.bonusCtrl.obs]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(1)
    end

    track.bonusCtrl.obs[#track.bonusCtrl.obs+1]={
        body=LP.newBody(track.world,-510,360,'static'),
        shape=LP.newPolygonShape(0,0,0,-45,30,-30),
        color={.8,.8,.8}
    }
    o=track.bonusCtrl.obs[#track.bonusCtrl.obs]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.8)

    track.bonusCtrl.obs[#track.bonusCtrl.obs+1]={
        body=LP.newBody(track.world,-540,270,'static'),
        shape=LP.newPolygonShape(0,0,0,-120,120,0),
        color={.8,.8,.8}
    }
    o=track.bonusCtrl.obs[#track.bonusCtrl.obs]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.8)

    track.bonusCtrl.obs[#track.bonusCtrl.obs+1]={
        body=LP.newBody(track.world,-510,360,'static'),
        shape=LP.newPolygonShape(0,0,30,-30,135,-30,150,-15,135,0),
        color=lerp({1,.05,.05},{.6,.6,.6},.5)
    }
    o=track.bonusCtrl.obs[#track.bonusCtrl.obs]
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(0)

    --奖励区旋转障碍
    local rotatorShape1=LP.newPolygonShape(-75,0,-60,15,60,15,75,0,60,-15,-60,-15)
    local rotatorShape2=LP.newPolygonShape(15,15,15,60,0,75,-15,60,-15,15)
    local rotatorShape3=LP.newPolygonShape(15,-15,15,-60,0,-75,-15,-60,-15,-15)
    local rotatorShape4=LP.newPolygonShape(18,60,0,78,-18,60,0,42)
    local rotatorShape5=LP.newPolygonShape(18,-60,0,-78,-18,-60,0,-42)
    track.cbcmd={
        {1,.04,.04},{1,.5,0},{.95,.95,0},{0,.9,0},{0,.95,.95},{.2,.2,1},{.55,.1,1},{1,0,.5},
    }
    local mo=track.bonusCtrl.motorObs
    for i=1,7 do
        mo.axis[i]={
            body=LP.newBody(track.world,(-14.5+6*i)*30,375,'static'),
            shape=LP.newCircleShape(12),
        }
        if i==4 then
            mo.wheel[i]={
                body=LP.newBody(track.world,(-14.5+6*i)*30,375,'dynamic'),
                shape1=rotatorShape1,
                shape2=rotatorShape2,
                shape3=rotatorShape3,
                color=lerp(track.cbcmd[i+1],{.6,.6,.6},.5)
            }
        else
            mo.wheel[i]={
                body=LP.newBody(track.world,(-14.5+6*i)*30,375,'dynamic'),
                shape1=rotatorShape1,
                shape2=rotatorShape2,
                shape3=rotatorShape3,
                color=lerp(track.cbcmd[i+1],{.6,.6,.6},.5)
            }
        end
        o=mo.wheel[i]
        o.fixture1=LP.newFixture(o.body,o.shape1,100)
        o.fixture2=LP.newFixture(o.body,o.shape2,100)
        o.fixture3=LP.newFixture(o.body,o.shape3,100)
        o.fixture1:setFriction(0)
        o.fixture1:setRestitution(.9)
        o.fixture1:setMask(16)
        o.fixture2:setFriction(0)
        o.fixture2:setRestitution(.9)
        o.fixture2:setMask(16)
        o.fixture3:setFriction(0)
        o.fixture3:setRestitution(.9)
        o.fixture3:setMask(16)

        mo.joint[i]=LP.newRevoluteJoint(mo.axis[i].body,mo.wheel[i].body,(-14.5+6*i)*30,375)
        mo.joint[i]:setMotorEnabled(true)
        mo.joint[i]:setMaxMotorTorque(1e999)
        mo.joint[i]:setMotorSpeed(i==7 and -math.pi/2 or math.pi/2)--15rpm，最后一个逆时针旋转
    end

    --奖励区指令
    local bcmdFunc={
        [1]=function (this,other)
            if track.gameTime>0 then
            for i=1,(track.gameTime>0 and 5 or 1) do
                --summonBonusMarble(other:getUserData().team,0,0,0,0)
                summonBonusMarble(other:getUserData().team=='R' and 'B' or 'R',0,0)
            end
            else
                summonBonusMarble(other:getUserData().team,0,0)
            end
            other:getBody():destroy()
        end,
        [2]=function (this,other)
            for i=1,4 do summonPointMarble(other:getUserData().team,'p3') end
            other:getBody():destroy()
        end,
        [3]=function (this,other)
            for i=1,4 do summonPointMarble(other:getUserData().team,'p5') end
            other:getBody():destroy()
        end,
        [4]=function (this,other)
            for i=1,2 do summonPointMarble(other:getUserData().team=='R' and 'B' or 'R','m12') end
            other:getBody():destroy()
        end,
        [5]=function (this,other)
            for i=1,6 do
                if track.trackState[i]==other:getUserData().team then
                local t=track.track[i]
                for j=#t,1,-1 do
                    track.score[track.trackState[i]]=track.score[track.trackState[i]]+max(sc[t[j].type],0)
                    track.addScoreAnim(i,t[j].dist,track.trackState[i],t[j].type,t[j].type=='m12')
                    rem(t,j)
                end
                track.clearTrackAnimTimer[i]=0
                end
            end
            other:getBody():destroy()
        end,
        [6]=function (this,other)
            if track.gameTime>0 then summonTempMarble(other:getUserData().team,18)
            else summonBonusMarble(other:getUserData().team) end
            other:getBody():destroy()
        end,
        [7]=function (this,other)
            if track.gameTime>0 then summonTempMarble(other:getUserData().team,24)
            else summonBonusMarble(other:getUserData().team)end
            other:getBody():destroy()
        end,
        [8]=function (this,other)
            for i=1,(track.gameTime>0 and 16 or 1) do summonBonusMarble(other:getUserData().team) end
            other:getBody():destroy()
        end,
    }
    for i=1,8 do
        track.bonusCtrl.cmd[i]={
            body=LP.newBody(track.world,(-20+6*i)*30,495,'static'),
            shape=LP.newRectangleShape(120,30),
            color=track.cbcmd[i]
        }
        o=track.bonusCtrl.cmd[i]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.8)
        track.onCollide[o.fixture]=function (this,other)
            bcmdFunc[i](this,other)
            track.bonusTriggerTimer[i]=0
        end
    end
    --被球撞向右移的屏障
    track.bonusCtrl.specialBarrier={
        body=LP.newBody(track.world,-345,270,'static'),
        shape=LP.newRectangleShape(30,420),
        color=track.cbcmd[i]
    }
    o=track.bonusCtrl.specialBarrier
    o.fixture=LP.newFixture(o.body,o.shape,1)
    o.fixture:setFriction(0)
    o.fixture:setRestitution(.8)
    o.fixture:setCategory(16)
    track.onCollide[o.fixture]=function(this,other)
        this:getBody():setX(this:getBody():getX()+(this:getBody():getX()>=920 and 90 or 15))
    end

    --轨道指令区障碍
    for i=0,6 do--7个菱形障碍
        track.ctrl2.obs[i+1]={
            body=LP.newBody(track.world,(-31+2*i)*30,465,'static'),
            shape=diamondShape,
            color={.8,.8,.8}
        }
        o=track.ctrl2.obs[i+1]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.6)
        o.fixture:setCategory(16)
    end
    local fdmShape=LP.newPolygonShape(15,0,0,7.5,-15,0,0,-7.5)
    for i=0,5 do--6个移动菱形障碍
        track.ctrl2.obs[i+8]={
            body=LP.newBody(track.world,(-30+2*i)*30,465,'static'),
            shape=fdmShape,
            color={.8,.8,.8,.75}
        }
        o=track.ctrl2.obs[i+8]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.5)
        o.fixture:setCategory(16)
        track.onCollide[o.fixture]=function (this,other)
            if track.mvdTimer[i+1]==0 then track.mvdTimer[i+1]=track.mvdTimerCharge end
        end
        track.objUpdate[o.fixture]=function (this,dt)
            local t=track.mvdTimer[i+1]/track.mvdTimerCharge
            this:getBody():setY(465-480*t*(1-t))
        end
    end

    --轨道指令区进入轨道按钮
    for i=1,6 do
        track.ctrl2.cmd[i]={
            body=LP.newBody(track.world,(-32+2*i)*30,495,'static'),
            shape=LP.newRectangleShape(60,30),
        }
        track.ctrl2.cmd[i].fixture=LP.newFixture(track.ctrl2.cmd[i].body,track.ctrl2.cmd[i].shape,1)
        o=track.ctrl2.cmd[i]
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.8)
        track.type[o.fixture]='trkctrller'
        o.fixture:setUserData(i)
        track.onCollide[o.fixture]=function (this,other)
            local u=other:getUserData()
            if not u or u.team~=track.trackState[i] then
                other:getBody():setPosition(track.tpPosX,270)
                if track.type[other]=='p1' then track.enterTrack(i,'p1') end
            else
                track.enterTrack(i,track.type[other])
                other:getBody():destroy()
            end
        end
    end

    --轨道指令区预设的10个+1球
    for i=1,10 do
        track.ctrl2.marble[i]={
            body=LP.newBody(track.world,(-30.5+i)*30,300,'dynamic'),
            shape=LP.newCircleShape(12),
        }
        o=track.ctrl2.marble[i]
        o.fixture=LP.newFixture(o.body,o.shape,1)
        o.fixture:setFriction(0)
        o.fixture:setRestitution(.8)

        local angle=math.pi*2*rand()
        o.body:setLinearVelocity(120*cos(angle),120*sin(angle))
        track.type[o.fixture]='p1'
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
function track.touchP(id,x,y)
    track.sim=not track.sim
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

    track.tpPosX=-900+300*abs((track.time-.5)%2-1)
    for i=1,8 do track.bonusTriggerTimer[i]=track.bonusTriggerTimer[i]+dt end
    for i=1,6 do track.clearTrackAnimTimer[i]=track.clearTrackAnimTimer[i]+dt end
    for i=1,6 do track.mvdTimer[i]=max(track.mvdTimer[i]-dt,0) end

    if track.gameTime==0 and not track.cmdMarbleDestroyed then
        for i=1,#track.ctrl1.marble do
            track.ctrl1.marble[i].body:destroy()
        end
        for i=1,#track.ctrl1.tempMarble do
            track.ctrl1.tempMarble[i].body:destroy()
        end
        for i=1,10 do
            track.ctrl2.marble[i].body:destroy()
        end
        track.cmdMarbleDestroyed=true
    end

    for i=#contactList,1,-1 do
        if not contactList[i]:isDestroyed() and contactList[i]:isTouching() then fa,fb=contactList[i]:getFixtures()
        if track.onCollide[fa] then track.onCollide[fa](fa,fb) end
        if track.onCollide[fb] then track.onCollide[fb](fb,fa) end
        end
        table.remove(contactList,i)
    end

    for k,v in pairs(track.objUpdate) do
        if k:isDestroyed() then v=nil
        else v(k,dt)
        end
    end

    for i=#track.bonusCtrl.marble,1,-1 do--移除已销毁奖励球
        if track.bonusCtrl.marble[i].body:isDestroyed() then table.remove(track.bonusCtrl.marble,i) end
    end
    for i=#track.ctrl2.marble,1,-1 do--移除已销毁分数球
        if track.ctrl2.marble[i].body:isDestroyed() then table.remove(track.ctrl2.marble,i) end
    end
    for i=#track.ctrl1.tempMarble,1,-1 do--移除已销毁临时球
        if track.ctrl1.tempMarble[i].body:isDestroyed() then table.remove(track.ctrl1.tempMarble,i) end
    end

    track.trackSpeed=(max(track.gameTime-60,0)/240*14+1)/15
    for i=1,6 do
        local t=track.track[i]
        for j=#t,1,-1 do
            t[j].dist=t[j].dist-dt*track.trackSpeed
            if t[j].dist<=0 then
                track.score[track.trackState[i]]=track.score[track.trackState[i]]+sc[t[j].type]
                track.addScoreAnim(i,0,track.trackState[i],t[j].type,false)
                rem(t,j)
            end
        end
    end
    for i=1,6 do
        local t=track.scoreAnim[i]
        for j=#t,1,-1 do
            t[j].time=t[j].time-dt
            if t[j].time<=0 then rem(t,j) end
        end
    end
end

local bonusTxt={
    "x5 to your\nOPPONENT",.25,
    "+3 marble*4\nreward",.25,
    "+5 marble*4\nreward",.25,
    "-12 marble*2\nto your\nopponent",.25,
    "Clear\nyour\ntracks",.3,
    "18s marble",.3,
    "24s marble",.3,
    "x16",.6,
}
local bonusTimeUpTxt={
    "x1",.6,
    "+3 marble*4\nreward",.25,
    "+5 marble*4\nreward",.25,
    "-12 marble*2\nto your\nopponent",.25,
    "clear\nyour\ntracks",.3,
    "x1",.6,
    "x1",.6,
    "x1",.6,
}

local scoreTxt={
    p1="+1",p3="+3",p5="+5",m12="-12",def="Defused"
}

local glow=gc.newCanvas(100,1)
gc.setCanvas(glow)
for i=1,100 do
    setColor(1,1,1,(100-i)/100)
    gc.points(i-.5,.5)
end
gc.setCanvas()

local c,u,ud,t
function track.draw()
    --gc.push()
    --gc.scale(1.25)
    gc.setColor(1,1,1)
    --for i=-50,50 do circle('fill',30*i,0,4,4) circle('fill',0,30*i,4,4) end
    gc.setColor(1,1,1)
    --for i=-10,10 do circle('fill',150*i,0,8,4) circle('fill',0,150*i,8,4) end
    setColor(.8,.8,.8)
    for i=1,#track.edge do
        u=track.edge[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end

    for i=1,8 do
        c=track.cbcmd[i]
        setColor(c[1],c[2],c[3],.075+.175*max(1-track.bonusTriggerTimer[i]/.4,0)^.5)
        rect('fill',-690+180*i,60,180,450)
    end
    setColor(1,1,1)
    t=track.gameTime>0 and bonusTxt or bonusTimeUpTxt
    for i=1,8 do
    printf(t[2*i-1],font.JB_L,
        -514+180*i,66,10000,'left',math.pi/2,t[2*i],t[2*i],0,0)
    end

    setColor(.8,.8,.8)
    for i=1,#track.ctrl1.obs do
        u=track.ctrl1.obs[i]
        circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
    end
    setLineW(1)
    for i=1,#track.ctrl1.remobs do
        u=track.ctrl1.remobs[i]
        if not u.body:isDestroyed() then
            ud=u.fixture:getUserData()
            setColor(.8,.8,.8)
            if track.type[u.fixture]=='circleobs' then
                circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius())
            else
                poly('line',u.body:getWorldPoints(u.shape:getPoints()))
            end
            setColor(.8,.8,.8,ud.hp/ud.hpMax)
            if track.type[u.fixture]=='circleobs' then
                circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
            else
                poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
            end
        end
    end
    for i=1,#track.ctrl1.cmd do
        setColor(teamColor[track.cmdState[i]])
        u=track.ctrl1.cmd[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        setColor(teamColor[track.trackState[i]])
        rect('fill',(-33+2*i)*30,195,60,15)
    end
    for i=1,#track.ctrl2.cmd do
        setColor(teamColor[track.trackState[i]])
        u=track.ctrl2.cmd[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end

    setLineW(2)
    setColor(1,1,1,.6)
    circle('line',track.tpPosX,-390,15)
    circle('line',track.tpPosX,-390,25)
    circle('line',track.tpPosX, 270,15)
    circle('line',track.tpPosX, 270,25)
    circle('line',track.bonusSummonX,track.bonusSummonY,15)
    circle('line',track.bonusSummonX,track.bonusSummonY,25)

    if not track.cmdMarbleDestroyed then
        for i=1,#track.ctrl1.marble do
            u=track.ctrl1.marble[i]
            ud=u.fixture:getUserData()
            setColor(teamColor[ud.team])
            circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
        end
    end

    setLineW(1.5)
    for i=1,#track.ctrl1.tempMarble do
        u=track.ctrl1.tempMarble[i]
        ud=u.fixture:getUserData()
        c=teamColor[ud.team]
        setColor(c)
        circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius())
        setColor(c[1],c[2],c[3],.75)
        arc('fill','pie',u.body:getX(),u.body:getY(),u.shape:getRadius(),-math.pi/2,(ud.time/ud.tMax-.25)*2*math.pi)
    end
    setLineW(2.5)
    for i=1,#track.ctrl2.marble do
        u=track.ctrl2.marble[i]
        ud=u.fixture:getUserData()
        if ud then
        c=teamColor[ud.team]
        setColor(c[1]*.25,c[2]*.25,c[3]*.25)
        circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
        setColor(c)
        arc('fill','pie',u.body:getX(),u.body:getY(),u.shape:getRadius(),-math.pi/2,(ud.time/ud.tMax-.25)*2*math.pi)
        setColor(marbleColor[track.type[u.fixture]])
        circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius()-.5)
        else
            setColor(marbleColor[track.type[u.fixture]])
            circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
        end
    end

    for i=1,#track.bonusCtrl.marble do
        u=track.bonusCtrl.marble[i]
        ud=u.fixture:getUserData()
        setColor(teamColor[ud.team])
        circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
    end

    for k,u in pairs(track.bonusCtrl.obs) do
        setColor(u.color)
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end

    for i=1,#track.bonusCtrl.motorObs.wheel do
        u=track.bonusCtrl.motorObs.wheel[i]
        setColor(u.color)
        poly('fill',u.body:getWorldPoints(u.shape1:getPoints()))
        poly('fill',u.body:getWorldPoints(u.shape2:getPoints()))
        poly('fill',u.body:getWorldPoints(u.shape3:getPoints()))
        --setColor(1,1,1)
        --circle('fill',u.body:getX(),u.body:getY(),5)
    end
    for i=1,#track.bonusCtrl.cmd do
        u=track.bonusCtrl.cmd[i]
        setColor(u.color)
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end

    u=track.bonusCtrl.specialBarrier
    setColor(1,1,1,.8)
    poly('fill',u.body:getWorldPoints(u.shape:getPoints()))

    for k,u in pairs(track.ctrl2.obs) do
        setColor(u.color)
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end

    setColor(1,1,1,.4)
    printf(string.format("Travel speed:%2.2f",track.trackSpeed*15),font.JB,
        240,24,3000,'left',0,.3,.3,0,font.height.JB)
    --轨道及其上的所有球、得分动画
    for i=1,6 do
        c=teamColor[track.trackState[i]]
        setColor(c)
        setLineW(track.trackState[i]=='' and 2 or 3)
        circle('line',-480,(-15.25+2.5*i)*30,25)
        setColor(c[1],c[2],c[3],track.trackState[i]=='' and .2 or .4)
        arc('fill','pie',-480,(-15.25+2.5*i)*30,25,math.pi/2,3*math.pi/2,16)
        rect('fill',-480,(-15.25+2.5*i)*30-25,25,50)
        draw(glow,-455,(-15.25+2.5*i)*30,0,4,50,0,.5)
        if track.clearTrackAnimTimer[i]<.2 then
            setColor(c)
            setLineW(50*(1-track.clearTrackAnimTimer[i]/.2))
            gc.line(-480,(-15.25+2.5*i)*30,870,(-15.25+2.5*i)*30)
        end
    end
    setLineW(1)
    for i=1,6 do
        setColor(1,1,1,.8)
        arc('line','open',870,(-15.25+2.5*i)*30,15,-math.pi/2,math.pi/2,32)
        circle('line',870,(-15.25+2.5*i)*30,25)
    end
    for i=1,6 do
        t=track.track[i]
        for j=1,#t do
            c=marbleColor[t[j].type]
            setColor(c)
            circle('fill',-480+1350*t[j].dist,(-15.25+2.5*i)*30,15)
        end
    end
    for i=1,6 do
        t=track.scoreAnim[i]
        for j=1,#t do
            if t[j].time/t[j].tMax>.6 then
                local a=(t[j].time/t[j].tMax-.6)*2
                setColor(marbleColor[t[j].type])
                setLineW(7.5*a)
                circle('line',-480+1350*t[j].pos,(-15.25+2.5*i)*30,7.5+17.5*(1-a))
            end
            if t[j].team~='' then
                c=teamColor[t[j].team]
                setColor(c[1],c[2],c[3],(t[j].time/t[j].tMax*1.25)^.5)
                printf((t[j].defused and scoreTxt.def or scoreTxt[t[j].type]),font.JB_B,
                    -480+1350*t[j].pos,(-15.25+2.5*i)*30,1000,'center',0,.2,.2,500,font.height.JB_B/2)
            end
        end
    end

    setColor(1,1,1)
    printf("-",font.JB,0,-495,100,'center',0,.6,.6,50,font.height.JB/2)
    setColor(teamColor.R)
    printf(track.score.R,font.JB,-40,-495,1000,'right',0,.6,.6,1000,font.height.JB/2)
    setColor(teamColor.B)
    printf(track.score.B,font.JB,40,-495,1000,'left',0,.6,.6,0,font.height.JB/2)

    if track.gameTime>60 then setColor(1,1,1,track.sim and 1 or .5) else setColor(1,0,0,track.sim and 1 or .5) end
    printf(track.gameTime>0 and string.format("%01d:%02d",track.gameTime/60,track.gameTime%60) or "Time up!",font.JB_B,-924,-495,1000,'left',0,.6,.6,0,font.height.JB_B/2)
    if track.readyTime>0 then printf(string.format("%d",ceil(track.readyTime)),font.JB_B,0,-60,1000,'center',0,1.5,1.5,500,font.height.JB_B/2) end

    setColor(marbleColor.p1)
    circle('fill',480,-495,15)
    setColor(marbleColor.p3)
    circle('fill',600,-495,15)
    setColor(marbleColor.p5)
    circle('fill',720,-495,15)
    setColor(marbleColor.m12)
    circle('fill',840,-495,15)
    setColor(1,1,1)
    printf("+1",font.JB,500,-495,1000,'left',0,.3,.3,0,font.height.JB/2)
    printf("+3",font.JB,620,-495,1000,'left',0,.3,.3,0,font.height.JB/2)
    printf("+5",font.JB,740,-495,1000,'left',0,.3,.3,0,font.height.JB/2)
    printf("-12",font.JB,860,-495,1000,'left',0,.3,.3,0,font.height.JB/2)
    --setColor(1,1,1,.5)
    --printf(user.lang.tracks.info,font.JB_B,930,-490,10000,'right',0,.25,.25,10000,font.height.JB_B)

    --gc.pop()
end
return track