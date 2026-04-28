local LP=love.physics
local setColor,setLineWidth=gc.setColor,gc.setLineWidth
local circle,arc,rect,poly,line,draw=gc.circle,gc.arc,gc.rectangle,gc.polygon,gc.line,gc.draw
local printf=gc.printf

local zb={}
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
    table.insert(zb.dieList,this)
end

local color={
    L={
    main={1,.25,0},text={1,.7,.6},zombie={.6,.15,0},zombieDark={.2,.05,0},explode={1,.625,.5}
    },
    R={
    main={.2,.6,1},text={.6,.8,1},zombie={0,.3,.6},zombieDark={0,.1,.2},explode={.5,.75,1}
    }
}
local cmdColor={
    normal={.8,.8,.8},
    roadblock={1,.5,0},
    bucket={.9,.9,1},
    rugby={.9,0,0},
    pea={.5,1,0},
    enchant={1,.5,1},
    giant={.5,0,0},
    explode={0,.5,.5},
}

local zombieList={
    normal={HP=50,atk=10,speed=1,atkCD=.5,targetDamage=10},--普通
    roadblock={HP=100,atk=10,speed=1,atkCD=.5,targetDamage=10},--路障
    bucket={HP=150,atk=10,speed=1,atkCD=.5,targetDamage=10},--铁桶
    rugby={HP=200,atk=20,speed=1.25,atkCD=.5,targetDamage=20},--橄榄球
    pea={HP=50,atk=10,speed=1,atkCD=1,targetDamage=10},--豌豆，远程单位
    enchant={HP=25,atk=5,speed=1,atkCD=.5,targetDamage=5},--魅惑
    giant={HP=2000,atk=100,speed=.5,atkCD=3,targetDamage=80},--巨人，走得慢伤害高，群伤
}
local bulletList={
    pea={--豌豆
        speed=5,
        effect=function (track,pos,target,enemyTeam)
            if target then target.HP=target.HP-5 end
        end
    },
    explode={--炸弹，群伤
        speed=2.5,
        effect=function (track,pos,target,enemyTeam)
            for i=1,#zb['zombie'..enemyTeam][track] do
                local t=zb['zombie'..enemyTeam][track][i]
                if abs(t.pos-pos)<=120 then t.HP=t.HP-1500 end
            end
            if track-1>0 then
                for i=1,#zb['zombie'..enemyTeam][track-1] do
                    t=zb['zombie'..enemyTeam][track-1][i]
                    if abs(t.pos-pos)<=120 then t.HP=t.HP-1500 end
                end
            end
            if track+1<6 then
                for i=1,#zb['zombie'..enemyTeam][track+1] do
                    t=zb['zombie'..enemyTeam][track+1][i]
                    if abs(t.pos-pos)<=120 then t.HP=t.HP-1500 end
                end
            end
            for i=1,64 do
                ins(zb.explodeAnim,{posX=pos,posY=-10+80*track,team=enemyTeam=='L' and 'R' or 'L',time=0,angle=rand()*2*math.pi,offX=240*rand()-120,offY=240*rand()-120,scale=.1+.2*rand()})
            end
        end
    },
}
local visualOffsetIndex={
    normal=1,
    roadblock=1,
    bucket=1,
    rugby=1,
    pea=.1,
    enchant=1,
    giant=0,
    wall=0,
}
local function summonZombie(track,team,type,offset)
    offset=offset or 0
    ins(zb['zombie'..team][track],{
        type=type,
        HP=zombieList[type].HP,
        maxHP=zombieList[type].HP,
        atk=zombieList[type].atk,
        speed=zombieList[type].speed,
        atkCD=zombieList[type].atkCD,
        target=type=='giant' and {} or nil,
        atkTimer=0,
        targetDamage=zombieList[type].targetDamage,
        pos=(team=='L' and -1 or 1)*(720-offset),
        visualOffset=(20*rand()-10)*visualOffsetIndex[type],
        atkAnimTimer=0,
        atkAnimTMax=type=='giant' and .5 or .15,
        size=type=='giant' and 30 or 20,
        peaTime=type=='pea' and 0,
        peaCD=type=='pea' and 1,
        time=zb.time --该僵尸生成的时间
    })
end
local function summonBullet(track,team,type,pos)
    ins(zb['bullet'..team][track],{
        type=type,
        target=nil,
        speed=bulletList[type].speed,
        pos=pos and pos or (team=='L' and -720 or 720),
        effect=bulletList[type].effect
    })
end

local u,ud,v

local ballShape,ballShape2
local cmdShape,targetShape,barShape1,barShape2
local needleShape,needleShape2,needleShape3,needleShape4
local function summonBall()
    zb.cmdBall[#zb.cmdBall+1]={
        body=LP.newBody(zb.world,10*(rand()-.5),-650,'dynamic'),
        shape=ballShape,
    }
    u=zb.cmdBall[#zb.cmdBall]
    u.fixture=LP.newFixture(u.body,u.shape,1)
    u.fixture:setFriction(0)
    u.fixture:setRestitution(.5)
    u.body:setLinearVelocity(20*(rand()-.5),20*(rand()-.5))
end
local cmd={
    [1]={
        'normal',1,'normal',1,'roadblock',1,'bucket',1,'pea',1,'bucket',1,'normal',2,'roadblock',2,'normal',2,'normal',3,
    },
    [2]={
        'normal',1,'roadblock',1,'bucket',1,'pea',2,'roadblock',1,'normal',2,'enchant',1,'rugby',1,'bucket',2,'roadblock',2,
    },
    [3]={
        'roadblock',1,'bucket',1,'pea',2,'normal',2,'bucket',2,'enchant',1,'rugby',1,'normal',3,'rugby',2,'normal',4,
    },
    [4]={
        'bucket',1,'normal',2,'pea',3,'roadblock',2,'normal',3,'enchant',2,'rugby',2,'explode',1,'giant',1,'roadblock',4,
    },
    [5]={
        'roadblock',2,'bucket',2,'pea',4,'enchant',2,'normal',4,'rugby',3,'bucket',3,'giant',1,'normal',8,'explode',1,
    },
    [6]={
        'roadblock',6,'bucket',6,'pea',8,'enchant',4,'explode',1,'giant',1,'rugby',4,'giant',3,'bucket',16,'giant',2,
    },
}
function zb.init()
    --拟真运行状态
    zb.sim=false
    zb.readyTime=3
    zb.time=0
    zb.updateTimer=0

    zb.dieList={}
    --挡板周期
    zb.barTimer=0
    zb.barRefreshTime=1.2

    zb.availableTrack=1
    --小球生成周期
    zb.ballTimer=2
    zb.ballRefreshTime=1/.5
    --指令等级、生命
    zb.level={L=1,R=1}
    zb.maxLevel=5
    zb.death={L=0,R=0}
    zb.deathTarget={L=60,R=60}
    zb.targetHP={L=4000,R=4000}
    --初始化世界
    zb.world=LP.newWorld(0,960) zb.world:setSleepingAllowed(false)
    zb.world:setCallbacks(beginContact,endContact,preSolve,postSolve)
    LP.setMeter(20)

    ballShape=LP.newCircleShape(19.75)
    ballShape2=LP.newCircleShape(10)
    cmdShape=LP.newRectangleShape(60,20)
    targetShape=LP.newRectangleShape(40,80)
    needleShape =LP.newPolygonShape(10,0,10,-20,0,-40,-10,-20,-10,0)
    needleShape2=LP.newPolygonShape(10,0,10, 20,0, 40,-10, 20,-10,0)
    needleShape3=LP.newPolygonShape(30,0,0,-60,-30,0)
    needleShape4=LP.newPolygonShape(20,0,0,-20,-20,0)
    barShape1=LP.newPolygonShape(0,0,-60,-20,-60,0,0,20)
    barShape2=LP.newPolygonShape(0,0, 60,-20, 60,0,0,20)

    --静止多边形障碍物，包括边界
    zb.polyobs={}

    zb.polyobs[1]={
        body=LP.newBody(zb.world,480,-470,'static'),
        shape=LP.newRectangleShape(640,40),
    }
    zb.polyobs[2]={
        body=LP.newBody(zb.world,-480,-470,'static'),
        shape=LP.newRectangleShape(640,40),
    }
    zb.polyobs[3]={
        body=LP.newBody(zb.world,0, 470,'static'),
        shape=LP.newRectangleShape(1600,40),
    }
    zb.polyobs[4]={
        body=LP.newBody(zb.world,-820,0,'static'),
        shape=LP.newRectangleShape(40,900),
    }
    zb.polyobs[5]={
        body=LP.newBody(zb.world, 820,0,'static'),
        shape=LP.newRectangleShape(40,900),
    }
    zb.polyobs[6]={
        body=LP.newBody(zb.world,0,-340,'static'),
        shape=LP.newRectangleShape(1440,20),
    }
    zb.polyobs[7]={
        body=LP.newBody(zb.world,0,-160,'static'),
        shape=LP.newRectangleShape(40,340),
    }
    zb.polyobs[8]={
        body=LP.newBody(zb.world,0,-40,'static'),
        shape=LP.newRectangleShape(1600,20),
    }
    zb.polyobs[9]={
        body=LP.newBody(zb.world,0,20,'static'),
        shape=LP.newRectangleShape(1520,20),
    }
    zb.polyobs[10]={
        body=LP.newBody(zb.world,0,440,'static'),
        shape=LP.newRectangleShape(1600,20),
    }
    zb.polyobs[11]={
        body=LP.newBody(zb.world,180,-600,'static'),
        shape=LP.newRectangleShape(40,300),
    }
    zb.polyobs[12]={
        body=LP.newBody(zb.world,-180,-600,'static'),
        shape=LP.newRectangleShape(40,300),
    }
    zb.polyobs[13]={
        body=LP.newBody(zb.world,0,-750,'static'),
        shape=LP.newRectangleShape(300,40),
    }
    for i=1,#zb.polyobs do
        zb.polyobs[i].fixture=LP.newFixture(zb.polyobs[i].body,zb.polyobs[i].shape,1)
        zb.polyobs[i].fixture:setFriction(0)
        zb.polyobs[i].fixture:setRestitution(0)
    end
    --静止的球形障碍物
    zb.ballobs={}
    for i=0,9 do
        zb.ballobs[#zb.ballobs+1]={
            body=LP.newBody(zb.world, 10+80*i,-220,'static'),
            shape=ballShape2,
        }
        zb.ballobs[#zb.ballobs+1]={
            body=LP.newBody(zb.world,-10-80*i,-220,'static'),
            shape=ballShape2,
        }
    end
    for i=1,#zb.ballobs do
        zb.ballobs[i].fixture=LP.newFixture(zb.ballobs[i].body,zb.ballobs[i].shape,1)
        zb.ballobs[i].fixture:setFriction(0)
        zb.ballobs[i].fixture:setRestitution(.5)
    end

    --静止的刺形障碍物，用于分割指令物件
    zb.needle={}

    for i=0,8 do
        zb.needle[#zb.needle+1]={
            body=LP.newBody(zb.world, 90+80*i,-50,'static'),
            shape=needleShape,
        }
        zb.needle[#zb.needle+1]={
            body=LP.newBody(zb.world,-90-80*i,-50,'static'),
            shape=needleShape,
        }
    end
    --[[for i=0,1 do
        bowling.needle[#bowling.needle+1]={
            body=LP.newBody(bowling.world, 50+80*i,-330,'static'),
            shape=needleShape2,
        }
        bowling.needle[#bowling.needle+1]={
            body=LP.newBody(bowling.world,-50-80*i,-330,'static'),
            shape=needleShape2,
        }
    end]]
    for i=1,#zb.needle do
        zb.needle[i].fixture=LP.newFixture(zb.needle[i].body,zb.needle[i].shape,1)
        zb.needle[i].fixture:setFriction(0)
        zb.needle[i].fixture:setRestitution(.5)
    end

    --[[往复运动、用于将小球推向两边的尖刺
    bowling.sortNeedle={
        body=LP.newBody(bowling.world,0,-350,'kinematic'),
        shape=needleShape3,
    }
    bowling.sortNeedle.fixture=LP.newFixture(bowling.sortNeedle.body,bowling.sortNeedle.shape,4800)
    bowling.sortNeedle.fixture:setFriction(0)
    bowling.sortNeedle.fixture:setRestitution(.5)]]


    --循环运动、用于将小球推到更远距离的尖刺
    zb.pushNeedleL={} zb.pushNeedleR={}
    for i=1,8 do
        zb.pushNeedleL[i]={
            body=LP.newBody(zb.world,-820+150-150*i,-230,'kinematic'),
            shape=needleShape4,
        }
        zb.pushNeedleL[i].fixture=LP.newFixture(zb.pushNeedleL[i].body,zb.pushNeedleL[i].shape,4800)
        zb.pushNeedleL[i].fixture:setFriction(0)
        zb.pushNeedleL[i].fixture:setRestitution(.5)
        zb.pushNeedleL[i].body:setLinearVelocity(150,0)

        zb.pushNeedleR[i]={
            body=LP.newBody(zb.world,820-150+150*i,-230,'kinematic'),
            shape=needleShape4,
        }
        zb.pushNeedleR[i].fixture=LP.newFixture(zb.pushNeedleR[i].body,zb.pushNeedleR[i].shape,4800)
        zb.pushNeedleR[i].fixture:setFriction(0)
        zb.pushNeedleR[i].fixture:setRestitution(.5)
        zb.pushNeedleR[i].body:setLinearVelocity(-150,0)
    end
    --阻挡小球、随时间解锁新指令的挡板
    zb.unlockL={}
    zb.unlockR={}
    for i=1,8 do
        zb.unlockL[i]={
            body=LP.newBody(zb.world,-30+80*i+(i==1 and 5 or 0),-190,'static'),
            shape=LP.newRectangleShape(i==1 and 70 or 80,280),
        }
        zb.unlockL[i].fixture=LP.newFixture(zb.unlockL[i].body,zb.unlockL[i].shape,1)
        zb.unlockL[i].fixture:setFriction(0)
        zb.unlockL[i].fixture:setRestitution(.5)
        zb.unlockR[i]={
            body=LP.newBody(zb.world, 30-80*i-(i==1 and 5 or 0),-190,'static'),
            shape=LP.newRectangleShape(i==1 and 70 or 80,280),
        }
        zb.unlockR[i].fixture=LP.newFixture(zb.unlockR[i].body,zb.unlockR[i].shape,1)
        zb.unlockR[i].fixture:setFriction(0)
        zb.unlockR[i].fixture:setRestitution(.5)
    end
    --目标
    zb.targetL={}
    zb.targetR={}
    for i=1,5 do
        zb.targetL[i]={
            body=LP.newBody(zb.world,-720,-10+80*i,'static'),
            shape=targetShape,
        }
        zb.targetL[i].fixture=LP.newFixture(zb.targetL[i].body,zb.targetL[i].shape,1)
        zb.targetL[i].fixture:setUserData({onCollide=function (this,other)
            if zb.targetHP.L<=0 then die(other) return end
            ud=other:getUserData()
            for j=1,ud.amount do
                if ud.type=='explode' then summonBullet(i,'L',ud.type)
                else summonZombie(i,'L',ud.type,j*5-5) end
            end
            die(other)
        end})
        zb.targetR[i]={
            body=LP.newBody(zb.world, 720,-10+80*i,'static'),
            shape=targetShape,
        }
        zb.targetR[i].fixture=LP.newFixture(zb.targetR[i].body,zb.targetR[i].shape,1)
        zb.targetR[i].fixture:setUserData({onCollide=function (this,other)
            if zb.targetHP.R<=0 then die(other) return end
            ud=other:getUserData()
            for j=1,ud.amount do
                if ud.type=='explode' then summonBullet(i,'R',ud.type)
                else summonZombie(i,'R',ud.type,j*5-5) end
            end
            die(other)
        end})
    end
    --使小球向指定方向移动的板子
    zb.conveyor={
        body=LP.newBody(zb.world,0,20,'static'),
        shape=LP.newRectangleShape(1500,20),
    }
    zb.conveyor.fixture=LP.newFixture(zb.conveyor.body,zb.conveyor.shape,1)
    zb.conveyor.fixture:setFriction(0)
    zb.conveyor.fixture:setRestitution(0)
    zb.conveyor.fixture:setUserData({onCollideSolve=function (this,other)
        u=other:getBody()
        local x,y=u:getPosition()
        u:setLinearVelocity(x>0 and 300 or -300,0)
    end})
    --阻挡指令球，令其进入指令区的挡板
    zb.barL={}
    zb.barR={}
        for i=1,5 do
        zb.barL[i]={
            body=LP.newBody(zb.world,-740,30+80*i,'static'),
            shape=barShape1,
        }
        zb.barL[i].fixture=LP.newFixture(zb.barL[i].body,zb.barL[i].shape,1)
        zb.barL[i].fixture:setFriction(0)
        zb.barL[i].fixture:setRestitution(0)
        zb.barR[i]={
            body=LP.newBody(zb.world, 740,30+80*i,'static'),
            shape=barShape2,
        }
        zb.barR[i].fixture=LP.newFixture(zb.barR[i].body,zb.barR[i].shape,1)
        zb.barR[i].fixture:setFriction(0)
        zb.barR[i].fixture:setRestitution(0)
    end
    --小球列表
    zb.cmdBall={}
    --指令块列表和计数
    zb.cmdL={}
    zb.cmdR={}
    zb.cmdCountL={}
    zb.cmdCountR={}
    for i=1,10 do
        zb.cmdL[i]={
            body=LP.newBody(zb.world,-850+80*i,-60,'static'),
            shape=cmdShape,
        }
        zb.cmdL[i].fixture=LP.newFixture(zb.cmdL[i].body,zb.cmdL[i].shape,1)
        zb.cmdL[i].fixture:setUserData({onCollide=function (this,other)
            u=other:getBody()
            local x,y=u:getPosition()
            u:setPosition(x,y+80)
            other:setUserData({type=cmd[zb.level.L][2*i-1],amount=cmd[zb.level.L][2*i]})
            zb.cmdCountL[i]=zb.cmdCountL[i]+1
        end})
        zb.cmdR[i]={
            body=LP.newBody(zb.world, 850-80*i,-60,'static'),
            shape=cmdShape,
        }
        zb.cmdR[i].fixture=LP.newFixture(zb.cmdR[i].body,zb.cmdR[i].shape,1)
        zb.cmdR[i].fixture:setUserData({onCollide=function (this,other)
            u=other:getBody()
            local x,y=u:getPosition()
            u:setPosition(x,y+80)
            other:setUserData({type=cmd[zb.level.R][2*i-1],amount=cmd[zb.level.R][2*i]})
            zb.cmdCountR[i]=zb.cmdCountR[i]+1
        end})

        zb.cmdCountL[i]=0
        zb.cmdCountR[i]=0
    end
    --僵尸与子弹（豌豆、炸弹）
    zb.zombieL={{},{},{},{},{}} zb.zombieR={{},{},{},{},{}}
    zb.bulletL={{},{},{},{},{}} zb.bulletR={{},{},{},{},{}}
    --动画相关
    --dieAnim[i]={posX,posY,time,type,team}
    zb.dieAnim={}
    --dieAnim[i]={posX,posY,team,time,angle,offX,offY}
    zb.explodeAnim={}
    zb.upgradeAnimTime={L=0,R=0}
    zb.targetAnimTime={L=0,R=0}
    zb.loseAnim={
        L={count=0,timer=1/16,period=1/16},
        R={count=0,timer=1/16,period=1/16},
    }
    zb.loseExplosionLimit=20
end

function zb.keyP(k)
    if k=='space' or k=='return' then zb.sim=not zb.sim
    elseif k=='escape' then
        scene.switch({
            dest='intro',destScene=require('scene/intro'),swapT=.6,outT=.2,
            anim=function() anim.cover(.2,.4,.2,0,0,0) end
        })
    end
end
function zb.touchP(id,x,y)
    zb.sim=not zb.sim
end

function zb.update(dt)
    if zb.sim then zb.updateTimer=zb.updateTimer+dt
        while zb.updateTimer>=1/128 do zb.gameUpdate(1/128) zb.updateTimer=zb.updateTimer-1/128 end
    end
end
function zb.gameUpdate(dt)
    zb.readyTime=zb.readyTime-dt
    if zb.readyTime>0 then return end

    zb.world:update(dt,8,3) zb.time=zb.time+dt

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
    for i=#zb.dieList,1,-1 do
        if not zb.dieList[i]:isDestroyed() then zb.dieList[i]:getBody():destroy() end
        zb.dieList[i]=nil
    end

    for i=#zb.cmdBall,1,-1 do
        u=zb.cmdBall[i]
        if u.body:isDestroyed() then table.remove(zb.cmdBall,i) end
    end
    for i=#zb.unlockL,1,-1 do
        u=zb.unlockL[i]
        if zb.time>30*(#zb.unlockL-i+1) then u.body:setPosition(0,1000) end
        u=zb.unlockR[i]
        if zb.time>30*(#zb.unlockL-i+1) then u.body:setPosition(0,1000) end
    end

    zb.ballTimer=zb.ballTimer+dt
    if zb.ballTimer>=zb.ballRefreshTime then
        summonBall()
        zb.ballTimer=zb.ballTimer-zb.ballRefreshTime
    end
    zb.barTimer=zb.barTimer+dt
    if zb.barTimer>=zb.barRefreshTime then
        for i=1,5 do
            local x=rand()<1/max(zb.availableTrack+1-i,1) and 0 or 60
            zb.barL[i].body:setPosition(-740-x,30+80*i)
            zb.barR[i].body:setPosition( 740+x,30+80*i)
        end
        zb.barTimer=zb.barTimer-zb.barRefreshTime
    end

    --bowling.sortNeedle.body:setPosition(40*sin(bowling.time/bowling.ballRefreshTime%2*math.pi),-350)
    --bowling.sortNeedle.body:setLinearVelocity(40/bowling.ballRefreshTime*math.pi*cos(bowling.time/bowling.ballRefreshTime%2*math.pi),0)

    for i=1,#zb.pushNeedleL do
        u=zb.pushNeedleL[i]
        local x,y=u.body:getPosition()
        if x>0 then u.body:setPosition(x-1200,y) end
        u=zb.pushNeedleR[i]
        local x,y=u.body:getPosition()
        if x<0 then u.body:setPosition(x+1200,y) end
    end

    zb.ballRefreshTime=1/min(max(zb.time/60,.5),8)
    zb.availableTrack=min(1+floor(zb.time/60),5)
    --僵尸和炮弹的行动逻辑独立于物理引擎
    --僵尸攻击
    for i=1,5 do
        for j=1,#zb.zombieL[i] do
            u=zb.zombieL[i][j]
            if u.type=='giant' then for k=1,#u.target do u.target[k]=nil end else u.target=nil end
            for k=1,#zb.zombieR[i] do
                v=zb.zombieR[i][k]
                if v.pos<=u.pos+(u.size+v.size) and v.pos>=u.pos then
                    if u.type=='giant' then ins(u.target,v) else u.target=v break end
                end
            end
            if (u.type=='giant' and u.target[1]) or (u.type~='giant' and u.target) then
                u.atkTimer=u.atkTimer+dt
                if u.atkTimer>=u.atkCD then
                    if u.type=='giant' then
                        for k=1,#u.target do u.target[k].HP=u.target[k].HP-u.atk end
                    else
                        u.target.HP=u.target.HP-u.atk
                        if u.target.HP<=0 and u.target.type=='enchant' and u.type~='enchant' then
                        u.enchanted=true--被策反了
                        end
                    end
                    u.atkTimer=u.atkTimer-u.atkCD
                    u.atkAnimTimer=u.atkAnimTMax
                end
            else u.atkTimer=0 end
            if u.type=='pea' then
                u.peaTime=u.peaTime+dt
                if u.peaTime>=u.peaCD then
                    summonBullet(i,'L','pea',u.pos+30)
                    u.peaTime=u.peaTime-u.peaCD
                end
            end
        end
        for j=1,#zb.zombieR[i] do
            u=zb.zombieR[i][j]
            if u.type=='giant' then for k=1,#u.target do u.target[k]=nil end else u.target=nil end
            for k=1,#zb.zombieL[i] do
                v=zb.zombieL[i][k]
                if v.pos>=u.pos-(u.size+v.size) and v.pos<=u.pos then
                    if u.type=='giant' then ins(u.target,v) else u.target=v break end
                end
            end
            if (u.type=='giant' and u.target[1]) or (u.type~='giant' and u.target) then
                u.atkTimer=u.atkTimer+dt
                if u.atkTimer>=u.atkCD then
                    if u.type=='giant' then
                        for k=1,#u.target do u.target[k].HP=u.target[k].HP-u.atk end
                    else
                        u.target.HP=u.target.HP-u.atk
                        if u.target.HP<=0 and u.target.type=='enchant' and u.type~='enchant' then
                        u.enchanted=true--被策反了
                        end
                    end
                    u.atkTimer=u.atkTimer-u.atkCD
                    u.atkAnimTimer=u.atkAnimTMax
                end
            else u.atkTimer=0 end
            if u.type=='pea' then
                u.peaTime=u.peaTime+dt
                if u.peaTime>=u.peaCD then
                    summonBullet(i,'R','pea',u.pos-30)
                    u.peaTime=u.peaTime-u.peaCD
                end
            end
        end
    end
    --子弹攻击和移动
    for i=1,5 do
        for j=#zb.bulletL[i],1,-1 do
            u=zb.bulletL[i][j]
            u.target=nil
            for k=1,#zb.zombieR[i] do
                v=zb.zombieR[i][k]
                if v.pos<=u.pos+30 and v.pos>=u.pos-30 then u.target=v break end
            end
            if u.target or u.pos>=(u.type=='pea' and 900 or 700) then
                u.effect(i,u.pos,u.target,'R')
                rem(zb.bulletL[i],j)
            else
                u.pos=u.pos+u.speed*(.75+.25*zb.level.L)*45*dt
            end
        end
        for j=#zb.bulletR[i],1,-1 do
            u=zb.bulletR[i][j]
            u.target=nil
            for k=1,#zb.zombieL[i] do
                v=zb.zombieL[i][k]
                if v.pos>=u.pos-30 and v.pos<=u.pos+30 then u.target=v break end
            end
            if u.target or u.pos<=(u.type=='pea' and -900 or -700) then
                u.effect(i,u.pos,u.target,'L')
                rem(zb.bulletR[i],j)
            else
                u.pos=u.pos-u.speed*(.75+.25*zb.level.L)*45*dt
            end
        end
    end
    --僵尸移动
    for i=1,5 do
        for j=#zb.zombieL[i],1,-1 do
            u=zb.zombieL[i][j]
            if (u.type~='giant' and not u.target) or (u.type=='giant' and not u.target[1]) then u.pos=u.pos+u.speed*(.75+.25*zb.level.L)*45*dt end
            u.atkAnimTimer=max(u.atkAnimTimer-dt,0)
            if u.pos>= 680 then
                zb.targetHP.R=zb.targetHP.R-u.targetDamage
                rem(zb.zombieL[i],j)
                ins(zb.dieAnim,{posX=u.pos,posY=-10+80*i+u.visualOffset,team='L',time=0,size=u.type=='giant' and 35 or 20})
                zb.targetAnimTime.R=1
            end
        end
        for j=#zb.zombieR[i],1,-1 do
            u=zb.zombieR[i][j]
            if (u.type~='giant' and not u.target) or (u.type=='giant' and not u.target[1]) then u.pos=u.pos-u.speed*(.75+.25*zb.level.R)*45*dt end
            u.atkAnimTimer=max(u.atkAnimTimer-dt,0)
            if u.pos<=-680 then
                zb.targetHP.L=zb.targetHP.L-u.targetDamage
                rem(zb.zombieR[i],j)
                ins(zb.dieAnim,{posX=u.pos,posY=-10+80*i+u.visualOffset,team='R',time=0,size=u.type=='giant' and 35 or 20})
                zb.targetAnimTime.L=1
            end
        end
    end
    --清理死掉的僵尸
    for i=1,5 do
        for j=#zb.zombieL[i],1,-1 do
            u=zb.zombieL[i][j]
            if u.HP<=0 then
                rem(zb.zombieL[i],j)
                ins(zb.dieAnim,{posX=u.pos,posY=-10+80*i+u.visualOffset,team='L',time=0,size=u.type=='giant' and 35 or 20})
                zb.death.L=zb.death.L+1
                if zb.death.L>=zb.deathTarget.L then
                    zb.level.L=min(zb.level.L+1,zb.maxLevel)
                    zb.upgradeAnimTime.L=1
                    zb.deathTarget.L=zb.level.L==zb.maxLevel and 1e999 or 60*(2^zb.level.L-1)
                end
            end
        end
        for j=#zb.zombieR[i],1,-1 do
            u=zb.zombieR[i][j]
            if u.HP<=0 then
                rem(zb.zombieR[i],j)
                ins(zb.dieAnim,{posX=u.pos,posY=-10+80*i+u.visualOffset,team='R',time=0,size=u.type=='giant' and 35 or 20})
                zb.death.R=zb.death.R+1
                if zb.death.R>=zb.deathTarget.R then
                    zb.level.R=min(zb.level.R+1,zb.maxLevel)
                    zb.upgradeAnimTime.R=1
                    zb.deathTarget.R=zb.level.R==zb.maxLevel and 1e999 or 60*(2^zb.level.R-1)
                end
            end
        end
    end
    --处理被魅惑的僵尸
    for i=1,5 do
        for j=#zb.zombieL[i],1,-1 do
            u=zb.zombieL[i][j]
            if u.enchanted then
                u.HP=u.maxHP u.enchanted=false
                ins(zb.zombieR[i],rem(zb.zombieL[i],j))
            end
        end
        for j=#zb.zombieR[i],1,-1 do
            u=zb.zombieR[i][j]
            if u.enchanted then
                u.HP=u.maxHP u.enchanted=false
                ins(zb.zombieL[i],rem(zb.zombieR[i],j))
            end
        end
    end

    --动画
    for i=#zb.dieAnim,1,-1 do
        u=zb.dieAnim[i]
        u.time=u.time+dt*2
        if u.time>=1 then rem(zb.dieAnim,i) end
    end
    for i=#zb.explodeAnim,1,-1 do
        u=zb.explodeAnim[i]
        u.time=u.time+dt*2
        if u.time>=1 then rem(zb.explodeAnim,i) end
    end
    zb.upgradeAnimTime.L=max(zb.upgradeAnimTime.L-dt/.2,0)
    zb.upgradeAnimTime.R=max(zb.upgradeAnimTime.R-dt/.2,0)
    zb.targetAnimTime.L=max(zb.targetAnimTime.L-dt/.4,0)
    zb.targetAnimTime.R=max(zb.targetAnimTime.R-dt/.4,0)

    if zb.targetHP.L<=0 then
        zb.loseAnim.L.timer=zb.loseAnim.L.timer+dt
        if zb.loseAnim.L.timer>=zb.loseAnim.L.period then  
            if zb.loseAnim.L.count<zb.loseExplosionLimit then
                zb.loseAnim.L.timer=zb.loseAnim.L.timer-zb.loseAnim.L.period
                local py=70+80*(zb.loseAnim.L.count%5)
                zb.loseAnim.L.count=zb.loseAnim.L.count+1
                for i=1,8 do
                    local angle=rand()*math.pi*2
                    ins(zb.explodeAnim,{posX=-740+40*rand(),posY=py,team='L',time=0,angle=rand()*2*math.pi,offX=80*cos(angle),offY=80*sin(angle),scale=.1+.2*rand()})
                end
            elseif zb.loseAnim.L.count==zb.loseExplosionLimit then
                zb.loseAnim.L.count=zb.loseAnim.L.count+1
                for i=1,128 do
                    local angle=rand()*math.pi*2
                    ins(zb.explodeAnim,{posX=-720,posY=30+400*rand(),team='L',time=0,angle=rand()*2*math.pi,offX=160*cos(angle),offY=160*sin(angle),scale=.1+.2*rand()})
                end
            end
        end
    end
    if zb.targetHP.R<=0 then
        zb.loseAnim.R.timer=zb.loseAnim.R.timer+dt
        if zb.loseAnim.R.timer>=zb.loseAnim.R.period then  
            if zb.loseAnim.R.count<zb.loseExplosionLimit then
                zb.loseAnim.R.timer=zb.loseAnim.R.timer-zb.loseAnim.R.period
                local py=70+80*(zb.loseAnim.R.count%5)
                zb.loseAnim.R.count=zb.loseAnim.R.count+1
                for i=1,12 do
                    local angle=rand()*math.pi*2
                    ins(zb.explodeAnim,{posX=740-40*rand(),posY=py,team='R',time=0,angle=rand()*2*math.pi,offX=80*cos(angle),offY=80*sin(angle),scale=.1+.2*rand()})
                end
                elseif zb.loseAnim.R.count==zb.loseExplosionLimit then
                zb.loseAnim.R.count=zb.loseAnim.R.count+1
                for i=1,128 do
                    local angle=rand()*math.pi*2
                    ins(zb.explodeAnim,{posX=720,posY=30+400*rand(),team='R',time=0,angle=rand()*2*math.pi,offX=160*cos(angle),offY=160*sin(angle),scale=.1+.2*rand()})
                end
            end
        end
    end
end

local CNText={
    normal="普通僵尸",
    roadblock="路障僵尸",
    bucket="铁桶僵尸",
    rugby="橄榄球僵尸",
    pea="豌豆僵尸",
    enchant="魅惑僵尸",
    giant="巨人僵尸",
    explode="炸弹",

    death="死亡数",
}
local ENText={
    normal="Normal",
    roadblock="Roadblock",
    bucket="Buckethead",
    rugby="Rugby",
    pea="Peashooter",
    enchant="Enchanter",
    giant="Giant",
    explode="Bomb",

    death="Deaths",
}
local bgpic=gc.newImage('minigame/aquamarbler.png') --1950x450
local zombieDraw={
    normal=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos+d*(1-abs(2*a-1))*5
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,20)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,20,-math.pi/2,2*math.pi*(d*z.HP/z.maxHP-.25),32)
        setLineWidth(2)
        setColor(1,1,1)
        circle('line',p,-10+80*track+z.visualOffset,20)
        setColor(1,1,1)
        arc('fill','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
    end,
    roadblock=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos+d*(1-abs(2*a-1))*5
        local hp=z.HP/z.maxHP
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,20)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,20,-math.pi/2,2*math.pi*(d*min(hp*2,1)-.25),32)
        setLineWidth(2)
        setColor(1,1,1)
        circle('line',p,-10+80*track+z.visualOffset,20)
        setColor(1,1,1)
        arc('fill','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        if hp>1/2 then
        setLineWidth(8)
        setColor(1,.5,0)
        arc('line','open',p,-10+80*track+z.visualOffset,24,-math.pi/2,2*math.pi*(d*(hp*2-1)-.25),32)
        end
    end,
    bucket=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos+d*(1-abs(2*a-1))*5
        local hp=z.HP/z.maxHP
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,20)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,20,-math.pi/2,2*math.pi*(d*min(hp*3,1)-.25),32)
        setLineWidth(2)
        setColor(1,1,1)
        circle('line',p,-10+80*track+z.visualOffset,20)
        setColor(1,1,1)
        arc('fill','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        if hp>1/3 then
        setLineWidth(8)
        setColor(.9,.9,1)
        arc('line','open',p,-10+80*track+z.visualOffset,24,-math.pi/2,2*math.pi*(d*(hp*3-1)/2-.25),32)
        end
    end,
    rugby=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos+d*(1-abs(2*a-1))*10
        local hp=z.HP/z.maxHP
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,20)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,20,-math.pi/2,2*math.pi*(d*min(hp*4,1)-.25),32)
        setLineWidth(2)
        setColor(1,1,1)
        circle('line',p,-10+80*track+z.visualOffset,20)
        setColor(1,0,0)
        arc('fill','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        if hp>1/4 then
        setLineWidth(10)
        setColor(.9,0,0)
        arc('line','open',p,-10+80*track+z.visualOffset,24,-math.pi/2,2*math.pi*(d*(hp*4-1)/3-.25),32)
        end
    end,
    pea=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos+d*(1-abs(2*a-1))*5
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,20)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,20,-math.pi/2,2*math.pi*(d*z.HP/z.maxHP-.25),32)
        setLineWidth(20)
        line(p+d*20,-10+80*track+z.visualOffset,p+d*30,-10+80*track+z.visualOffset)
        setLineWidth(2)
        setColor(1,1,1)
        circle('line',p,-10+80*track+z.visualOffset,20)
        setLineWidth(4)
        local c=color[team].main
        setColor(c[1],c[2],c[3],.6)
        circle('line',p,-10+80*track+z.visualOffset,30,4)
        setColor(1,1,1)
        arc('fill','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
    end,
    enchant=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos+d*(1-abs(2*a-1))*5
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,20)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,20,-math.pi/2,2*math.pi*(d*z.HP/z.maxHP-.25),32)
        setLineWidth(2)
        setColor(1,.5,1)
        circle('line',p,-10+80*track+z.visualOffset,20)
        setColor(1,.5,1)
        arc('fill','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*10,-10+80*track+z.visualOffset-5,7.5,0,math.pi,16)
    end,
    giant=function (z,track,team)
        local a=z.atkAnimTimer/z.atkAnimTMax
        local d=(team=='L' and 1 or -1)
        local p=z.pos
        setColor(color[team].zombieDark)
        circle('fill',p,-10+80*track+z.visualOffset,35)
        setColor(color[team].zombie)
        arc('fill','pie',p,-10+80*track+z.visualOffset,35,-math.pi/2,2*math.pi*(d*z.HP/z.maxHP-.25),32)
        setLineWidth(4)
        setColor(.5,0,0)
        circle('line',p,-10+80*track+z.visualOffset,35)
        setColor(.5,0,0)
        arc('fill','closed',p+d*20,-10+80*track+z.visualOffset-10,10,0,math.pi,16)
        setColor(0,0,0)
        setLineWidth(1.5)
        arc('line','closed',p+d*20,-10+80*track+z.visualOffset-10,10,0,math.pi,16)
        setColor(1,0,0,.5)
        if z.atkCD-z.atkTimer<1 then
            circle('fill',p,-10+80*track+z.visualOffset,35*(1-z.atkCD+z.atkTimer))
        end
        setColor(1,0,0,2*a)
        setLineWidth(15*(min((2*(1-a)-1)^3,0)+1))
        arc('line','open',p,-10+80*track+z.visualOffset,40+20*(min((2*(1-a)-1)^3,0)+1),math.pi*(-.25+(team=='L' and 0 or 1)),math.pi*(.25+(team=='L' and 0 or 1)),16)
        --arc('line','open',p,-10+80*track+z.visualOffset,40+20*(min((2*(1-a)-1)^3,0)+1),math.pi*(-.25+(team=='L' and 0 or 1)),math.pi*(.25+(team=='L' and 0 or 1)),16)
    end,
}
local bulletDraw={
    pea=function (b,track,team)
        setColor(color[team].zombie)
        circle('fill',b.pos,-10+80*track,10)
        setColor(1,1,1)
        setLineWidth(1)
        circle('line',b.pos,-10+80*track,10)
    end,
    explode=function (b,track,team)
        setColor(1,1,1)
        setLineWidth(8)
        circle('line',b.pos,-10+80*track,20,4)
        arc('line','closed',b.pos,-10+80*track,20,-math.pi/4,5*math.pi/4,3)
        setColor(color[team].explode)
        circle('fill',b.pos,-10+80*track,20,4)
        arc('fill','closed',b.pos,-10+80*track,20,-math.pi/4,5*math.pi/4,3)
    end
}
local bombCanvas=gc.newCanvas(100,100)
gc.setCanvas(bombCanvas)
gc.clear(1,1,1)
gc.setCanvas()
local c,t0,t1,t2
function zb.draw()
    gc.clear(0,0,0)
    setColor(1,1,1,.5)
    gc.draw(bgpic,0,0,0,1,1,975,225)
    gc.push()
    gc.scale(1.2)
    setColor(.6,.6,.6)
    for i=1,#zb.polyobs do
        u=zb.polyobs[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    for i=1,#zb.ballobs do
        u=zb.ballobs[i]
        circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
    end
    for i=1,#zb.needle do
        u=zb.needle[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    --[[u=bowling.sortNeedle
    poly('fill',u.body:getWorldPoints(u.shape:getPoints()))]]
    for i=1,#zb.pushNeedleL do
        u=zb.pushNeedleL[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        u=zb.pushNeedleR[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    for i=1,#zb.barL do
        if zb.time<60*i and i~=5 then setColor(1,1,1) else setColor(.6,.6,.6) end
        u=zb.barL[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        u=zb.barR[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        setColor(1,1,1)
        if zb.time<60*i then
            printf(string.format("%d",ceil(60*i-zb.time)),font.JB_B,-770,60+80*i,1000,'center',0,.2,.2,500,font.height.JB_B/2)
            printf(string.format("%d",ceil(60*i-zb.time)),font.JB_B, 770,60+80*i,1000,'center',0,.2,.2,500,font.height.JB_B/2)
        end
    end
    setColor(1,1,1)
    for i=1,#zb.cmdL do
        setColor(cmdColor[cmd[zb.level.L][2*i-1]])
        u=zb.cmdL[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        setColor(cmdColor[cmd[zb.level.R][2*i-1]])
        u=zb.cmdR[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    setColor(color.L.zombieDark)
    for i=1,#zb.targetL do
        u=zb.targetL[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    setColor(color.R.zombieDark)
    for i=1,#zb.targetR do
        u=zb.targetR[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
    end
    setLineWidth(40)
    local hl,hr=max(zb.targetHP.L/4000,0),max(zb.targetHP.R/4000,0)
    setColor(color.L.main)
    line(-720,430-400*hl,-720,430)
    setColor(1,1,1,zb.targetAnimTime.L*.6)
    line(-720,430-400*hl,-720,430)
    setColor(color.R.main)
    line( 720,430-400*hr, 720,430)
    setColor(1,1,1,zb.targetAnimTime.R*.6)
    line( 720,430-400*hr, 720,430)
    setColor(1,1,1)
    printf(max(zb.targetHP.L,0).." HP",font.JB_B,-720,420,1600,'left',-math.pi/2,1/3,1/3,0,font.height.JB_B/2)
    printf(max(zb.targetHP.R,0).." HP",font.JB_B, 720,420,1600,'left',-math.pi/2,1/3,1/3,0,font.height.JB_B/2)
    for i=1,#zb.unlockL do
        setColor(1,1,1,.4)
        u=zb.unlockL[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        setColor(1,1,1,.4)
        u=zb.unlockR[i]
        poly('fill',u.body:getWorldPoints(u.shape:getPoints()))
        setColor(1,1,1)
        if zb.time<(#zb.unlockL-i+1)*30 then
        printf(string.format("%d",ceil((#zb.unlockL-i+1)*30-zb.time)),font.JB_B,-30+80*i,-250,1000,'center',0,.25,.25,500,font.height.JB_B/2)
        printf(string.format("%d",ceil((#zb.unlockL-i+1)*30-zb.time)),font.JB_B, 30-80*i,-250,1000,'center',0,.25,.25,500,font.height.JB_B/2)
        end
    end

    for i=1,#zb.cmdBall do
        u=zb.cmdBall[i]
        ud=u.fixture:getUserData()
        setColor(1,1,1)
        circle('fill',u.body:getX(),u.body:getY(),u.shape:getRadius())
        if ud then
            if ud.type=='roadblock' then
                setColor(1,.5,0)
                setLineWidth(4)
                circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius())
            elseif ud.type=='bucket' then
                setColor(.9,.9,1)
                setLineWidth(4)
                circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius())
            elseif ud.type=='rugby' then
                setColor(.9,0,0)
                setLineWidth(6)
                circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius())
            elseif ud.type=='pea' then
                setColor(1,1,1)
                setLineWidth(20)
                line(u.body:getX()-20,u.body:getY(),u.body:getX()-30,u.body:getY())
                line(u.body:getX()+20,u.body:getY(),u.body:getX()+30,u.body:getY())
                setLineWidth(4)
                setColor(1,1,1,.5)
                circle('line',u.body:getX(),u.body:getY(),30,4)
            elseif ud.type=='enchant' then
                setColor(1,.5,1)
                setLineWidth(4)
                circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius())
            elseif ud.type=='giant' then
                setColor(.5,0,0)
                setLineWidth(10)
                circle('line',u.body:getX(),u.body:getY(),u.shape:getRadius()*1.25)
            elseif ud.type=='explode' then
                setColor(0,.5,.5)
                setLineWidth(6)
                circle('fill',u.body:getX(),u.body:getY(),16,4)
                arc('fill','closed',u.body:getX(),u.body:getY(),16,-math.pi/4,5*math.pi/4,3)
            end
            if ud.amount>1 then
                setColor(0,0,0)
                printf(ud.amount,font.JB_B,u.body:getX(),u.body:getY(),1000,'center',0,1/4,1/4,500,font.height.JB_B/2)
            end
        end
    end

    setColor(1,1,1,.5)
    circle('fill',0,-650,20)
    setLineWidth(4)
    for i=1,4 do
        gc.line(-700,30+80*i,700,30+80*i)
    end
    setColor(1,1,1)
    for i=1,#zb.cmdCountL do
        printf(zb.cmdCountL[i],font.JB_B, -850+80*i,-40,1000,'center',0,1/6,1/6,500,font.height.JB_B/2)
        printf(zb.cmdCountR[i],font.JB_B,  850-80*i,-40,1000,'center',0,1/6,1/6,500,font.height.JB_B/2)
    end
    for i=1,10 do
        setColor(1,1,1,.6)
        printf(CNText[cmd[zb.level.L][2*i-1]],font.JB_B,-860+80*i,-90,1600,'left',-math.pi/2,1/4,1/4,4,font.height.JB_B/2)
        printf(ENText[cmd[zb.level.L][2*i-1]],font.JB_B,-835+80*i,-90,1600,'left',-math.pi/2,1/6,1/6,0,font.height.JB_B/2)
        printf(CNText[cmd[zb.level.R][2*i-1]],font.JB_B, 840-80*i,-90,1600,'left',-math.pi/2,1/4,1/4,4,font.height.JB_B/2)
        printf(ENText[cmd[zb.level.R][2*i-1]],font.JB_B, 865-80*i,-90,1600,'left',-math.pi/2,1/6,1/6,0,font.height.JB_B/2)
        if cmd[zb.level.L][2*i]>1 then
        printf("x"..cmd[zb.level.L][2*i],font.JB_B,-850+80*i,-70,1000,'center',0,1/3,1/3,500,font.height.JB_B/2)
        end
        if cmd[zb.level.R][2*i]>1 then
        printf("x"..cmd[zb.level.R][2*i],font.JB_B, 850-80*i,-70,1000,'center',0,1/3,1/3,500,font.height.JB_B/2)
        end
        setColor(1,1,1)
        if zb.upgradeAnimTime.L>0 then
        setLineWidth(60*zb.upgradeAnimTime.L)
        line(-850+80*i,-50,-850+80*i,-330)
        end
        if zb.upgradeAnimTime.R>0 then
        setLineWidth(60*zb.upgradeAnimTime.R)
        line( 850-80*i,-50, 850-80*i,-330)
        end
    end

    for i=1,5 do
        local LIndex,RIndex=#zb.zombieL[i],#zb.zombieR[i]
        while LIndex+RIndex>0 do
            u,v=zb.zombieL[i][LIndex],zb.zombieR[i][RIndex]
            t1,t2=u and u.time or 1e99,v and v.time or 1e99
            if t1<t2 then
                zombieDraw[u.type](u,i,'L') LIndex=LIndex-1
            else
                zombieDraw[v.type](v,i,'R') RIndex=RIndex-1
            end
        end
    end
    --[[for i=1,#zb.zombieL do
        for j=#zb.zombieL[i],1,-1 do
            u=zb.zombieL[i][j]
            zombieDraw[u.type](u,i,'L')
        end
    end
    for i=1,#zb.zombieR do
        for j=#zb.zombieR[i],1,-1 do
            u=zb.zombieR[i][j]
            zombieDraw[u.type](u,i,'R')
        end
    end]]
    for i=1,#zb.bulletL do
        for j=#zb.bulletL[i],1,-1 do
            u=zb.bulletL[i][j]
            bulletDraw[u.type](u,i,'L')
        end
    end
    for i=1,#zb.bulletR do
        for j=#zb.bulletR[i],1,-1 do
            u=zb.bulletR[i][j]
            bulletDraw[u.type](u,i,'R')
        end
    end

    setLineWidth(5)
    for i=1,#zb.dieAnim do
        u=zb.dieAnim[i]
        c=color[u.team].zombie
        setColor(c[1],c[2],c[3],1-u.time)
        circle('line',u.posX,u.posY,u.size+10*u.time)
    end
    for i=1,#zb.explodeAnim do
        u=zb.explodeAnim[i]
        c=color[u.team].explode
        t1=min((2*u.time-1)^3,0)+1
        t2=-max((u.time)^3,0)+1
        setColor(c[1],c[2],c[3],t2*.8)
        draw(bombCanvas,u.posX+t1*u.offX,u.posY+t1*u.offY,u.angle,u.scale,u.scale,50,50)
    end

    setColor(color.L.text)
    printf("Lv."..zb.level.L,font.JB_B,-25,-330,1000,'right',0,1/3,1/3,1000,0)
    printf(CNText.death,font.JB_B,-210,-330,1000,'center',0,1/4,1/4,500,0)
    printf(ENText.death,font.JB_B,-210,-300,1000,'center',0,1/6,1/6,500,0)
    printf(zb.death.L.."/"..(zb.level.L==zb.maxLevel and "INF" or zb.deathTarget.L),font.JB_B,-270,-330,1000,'right',0,1/3,1/3,1000,0)
    setColor(color.R.text)
    printf("Lv."..zb.level.R,font.JB_B, 25,-330,1000,'left',0,1/3,1/3,0,0)
    printf(CNText.death,font.JB_B, 210,-330,1000,'center',0,1/4,1/4,500,0)
    printf(ENText.death,font.JB_B, 210,-300,1000,'center',0,1/6,1/6,500,0)
    printf(zb.death.R.."/"..(zb.level.R==zb.maxLevel and "INF" or zb.deathTarget.R),font.JB_B, 270,-330,1000,'left',0,1/3,1/3,0,0)


    setColor(1,1,1,.5)
    printf(string.format("%02d:%02d",zb.time/60,zb.time%60),font.JB_B,0,-400,1000,'center',0,.6,.6,500,font.height.JB_B/2)
    setColor(1,1,1,zb.sim and 1 or .5)
    if zb.readyTime>0 then printf(string.format("%d",ceil(zb.readyTime)),font.JB_B,0,0,1000,'center',0,1.5,1.5,500,font.height.JB_B/2) end
    gc.pop()
end
return zb