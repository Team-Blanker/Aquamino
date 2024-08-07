local rule={}
local contactList={}
local function preSolve(fa,fb,coll)
    if rule.onCollide[fa] or rule.onCollide[fb] then table.insert(contactList,coll) end
end
local lp=love.physics
local pt=0
function rule.init(P,mino)
    pt=0
    mino.musInfo="georhythm - nega to posi"
    scene.BG=require('BG/blank')
    mus.add('music/Hurt Record/nega to posi','whole','ogg',61.847,224*60/130)
    mus.start()

    mino.seqGenType='bagp1FromBag' mino.seqSync=true
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    P[1].atk=0
    P[1].line=0
    P[1].preview=3
    P[1].posx=-640 P[2]=mytable.copy(P[1]) P[2].posx=640
    P[1].target=2 P[2].target=1
    P[1].name=1 P[2].name=2
    mino.fieldScale=2/3

    mino.stacker.opList={1,2}

    --使用物理引擎生成世界和各种物件
    --生成用代码固定、密度极低的砖块，保证普通物体能够触发碰撞判定且正常穿过
    rule.world=lp.newWorld(0,20,false)
    rule.world:setSleepingAllowed(false)
    rule.world:setCallbacks(nil,nil,preSolve,nil)

    rule.onCollide={}
    rule.entityType={}
    local e
    rule.blockL={}
    for i=0,29 do
        rule.blockL[i+1]={}
        for j=0,17 do
            rule.blockL[i+1][j+1]={}
            e=rule.blockL[i+1][j+1]
            e.body=lp.newBody(rule.world,-360+10+20*j,-300+10+20*i,'dynamic')
            e.shape=lp.newRectangleShape(18,18)
            e.fixture=love.physics.newFixture(e.body,e.shape,1e-7)
            rule.entityType[e.fixture]='block'
        end
    end
    rule.blockR={}
    for i=0,29 do
        rule.blockR[i+1]={}
        for j=0,17 do
            rule.blockR[i+1][j+1]={}
            e=rule.blockR[i+1][j+1]
            e.body=lp.newBody(rule.world,360-10-20*j,-300+10+20*i,'dynamic')
            e.shape=lp.newRectangleShape(12,12)
            e.fixture=love.physics.newFixture(e.body,e.shape,1e-7)
            rule.entityType[e.fixture]='block'
        end
    end
    rule.bullet={L={},R={}}--存炮弹实体
    rule.bulletType={}--存炮弹属性
    --{type=(Z/S/J/L/N/H)} ZSJL元素属性 N/H 普通/坚固
    --属性克制：J->Z->S->L->J a->b表示a炮弹可高效清除b砖块
    --灵感来源：水克火 火克风 风克土 土克水
end
function rule.blockCollide(this,other)
end
local eq,hold
local e
function rule.gameUpdate(P,dt,mino)
    pt=pt+dt
    if pt>=1/64 then
        pt=pt-1/64
        for i=#contactList,1,-1 do
            if not contactList[i]:isDestroyed() and contactList[i]:isTouching() then fa,fb=contactList[i]:getFixtures()
            if war.onCollide[fa] then war.onCollide[fa](fa,fb) end
            if war.onCollide[fb] then war.onCollide[fb](fb,fa) end
            end
            table.remove(contactList,i)
        end

        rule.world:update(1/64,16,6)--由于物件太多，故使用低帧率高精度方法
        for i=0,29 do
            for j=0,17 do
                rule.blockL[i+1][j+1].body:setPosition(-360+10+20*j,-300+10+20*i)
            end
        end
        for i=0,29 do
            for j=0,17 do
                rule.blockR[i+1][j+1].body:setPosition(360-10-20*j,-300+10+20*i)
            end
        end
    end
end
function rule.postCheckClear(player,mino)
end
local e
function rule.onLineClear(player,mino)
    local b=rule.bullet
    if player.name==1 then
        b.L[#b.L+1]={}
        e=b.L[#b.L]
        e.body=lp.newBody(rule.world,0,0,'dynamic')
        e.shape=lp.newCircleShape(16)
        e.fixture=love.physics.newFixture(e.body,e.shape,2000)
    else
    end
end
local e,x,y
function rule.underAllDraw()
    gc.setColor(1,1,1,.5)
    for i=-360,360,20 do
        for j=-300,300,20 do
            gc.circle('fill',i,j,2,4)
        end
    end
    gc.setColor(1,.5,0,.5)
    for i=1,30 do
        for j=1,18 do
            e=rule.blockL[i][j]
            x,y=e.body:getPosition()
            gc.rectangle('fill',x-10,y-10,20,20)
        end
    end
    gc.setColor(0,.5,1,.5)
    for i=1,30 do
        for j=1,18 do
            e=rule.blockR[i][j]
            x,y=e.body:getPosition()
            gc.rectangle('fill',x-10,y-10,20,20)
        end
    end
end
return rule