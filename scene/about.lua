local BUTTON=scene.button

local ins,rem=table.insert,table.remove

local logo=gc.newImage('pic/assets/title.png')
local loveLogo=gc.newImage('pic/assets/love-logo.png')
local w,h=logo:getPixelDimensions()
local lw,lh=loveLogo:getPixelDimensions()
local ballR=32

local repo={
    {'json.lua','rxi'},{'profile.lua','itraykov'}
}
local tool={'beepbox.co','GoldWave','REAPER','Malody','VS Code','vecta.io','GFIE (Greenfish Icon Editor)','Photoshop CC 2019'}

local simdt=0
local about={}
function about.init()
    simdt=0

    sfx.add({
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/buttonQuit.wav',
    })

    scene.BG=require('BG/menuBG') scene.BG.setPolyColor(1,1,1)
    if scene.BG.init then scene.BG.init() end
    if not mus.checkTag('menu') then
        if win.date.month==8 and win.date.day==14 then
        mus.add('music/Hurt Record/Winter Story','whole','ogg',7.579,96)
        mus.start()
        else
        mus.add('music/Hurt Record/Nine Five','parts','ogg')
        mus.start()
        end
        mus.setTag({'menu'})
    end

    local txt=user.lang.about.repo..'\n\n'
    for i=1,#repo do
        txt=txt..string.format('%s by %s\n',repo[i][1],repo[i][2])
    end
    about.rTxt=gc.newText(font.Bender)
    about.rTxt:setf(txt,500*3,'left')
    txt=user.lang.about.tool..'\n\n'
    for i=1,#tool do
        txt=txt..string.format('%s\n',tool[i])
    end
    about.tTxt=gc.newText(font.Bender)
    about.tTxt:setf(txt,500*3,'left')

    about.eTxt=gc.newText(font.Bender,user.lang.about.engineText)

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            sfx.play('quit')
            scene.switch({
                dest='menu',destScene=require('scene/menu'),swapT=.3,outT=.2,
                anim=function() anim.enterDL(.2,.1,.2,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('staff',{
        x=675,y=400,type='rect',w=250,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(user.lang.about.staff,font.Bender,0,0,1280,'center',0,.4,.4,640,72)
        end,
        event=function()
            sfx.play('click')
            scene.switch({
                dest='staff',destScene=require('scene/staff'),swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)

    local LP=love.physics
    LP.setMeter(32)
    about.world=LP.newWorld(0,1024,true)
    about.loveBall={
        body=LP.newBody(about.world,430+about.eTxt:getWidth()/3+ballR,-400+800/w*h/4-about.eTxt:getHeight()/6,'dynamic'),
        shape=LP.newCircleShape(ballR),
    }
    about.loveBall.fixture=LP.newFixture(about.loveBall.body,about.loveBall.shape,1)
    about.loveBall.body:setAwake(false)
    about.loveBall.fixture:setRestitution(.75)
    about.edge={
        {body=LP.newBody(about.world,0,-570,'static'),
        shape=LP.newRectangleShape(1920,60)},
        {body=LP.newBody(about.world,0, 570,'static'),
        shape=LP.newRectangleShape(1920,60)},
        {body=LP.newBody(about.world,-990,0,'static'),
        shape=LP.newRectangleShape(60,1080)},
        {body=LP.newBody(about.world, 990,0,'static'),
        shape=LP.newRectangleShape(60,1080)},
    }
    for i=1,4 do
        about.edge[i].fixture=LP.newFixture(about.edge[i].body,about.edge[i].shape,1)
        about.edge[i].fixture:setRestitution(.75)
    end
    about.obs1={
        body=LP.newBody(about.world,-700,400,'static'),
        shape=LP.newRectangleShape(200,100)
    }
    about.obs1.fixture=LP.newFixture(about.obs1.body,about.obs1.shape,1)
    about.obs2={
        body=LP.newBody(about.world,675,400,'static'),
        shape=LP.newRectangleShape(250,100)
    }
    about.obs2.fixture=LP.newFixture(about.obs2.body,about.obs2.shape,1)

    about.loveBallTrail={}
end
function about.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='menu',destScene=require('scene/menu'),swapT=.3,outT=.2,
            anim=function() anim.enterDL(.2,.1,.2,0,0,0) end
        })
    end
end
local drag=false
function about.mouseP(x,y,button,istouch)
    if (x-about.loveBall.body:getX())^2+(y-about.loveBall.body:getY())^2<ballR^2 then
        drag=true
        about.loveBall.body:setAwake(true)
    else BUTTON.press(x,y) end
end
function about.mouseR(x,y,button,istouch)
    drag=false
    BUTTON.release(x,y)
end

local timeTxt=gc.newText(font.Bender)
function about.update(dt)
    local mx,my=adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    BUTTON.update(dt,mx,my)

    simdt=simdt+dt
    if simdt>1/256 then
        about.world:update(1/256)
        simdt=simdt-1/256

        if ms.isDown(1) and drag then
            about.loveBall.body:applyForce(400*(mx-about.loveBall.body:getX()),400*(my-about.loveBall.body:getY()))
        end

        --[[if about.loveBall.body:isAwake(true) then
            ins(about.loveBallTrail,{x=about.loveBall.body:getX(),y=about.loveBall.body:getY(),r=about.loveBall.body:getAngle()})
            if #about.loveBallTrail>128 then
                rem(about.loveBallTrail,1)
            end
        end]]
    end
end
function about.draw()
    gc.setColor(1,1,1)
    gc.draw(logo,0,-400+12*sin(scene.time/5%2*math.pi),0,800/w,800/w,w/2,h/2)
    gc.draw(about.eTxt,425,-400+800/w*h/4,0,1/3,1/3,0,128)
    gc.draw(about.rTxt,-810,-270,0,1/3,1/3,0,0)
    gc.draw(about.tTxt,-270,-270,0,1/3,1/3,0,0)

    timeTxt:clear()
    timeTxt:addf(user.lang.about.time:format(win.stat.launch,win.stat.totalTime+scene.totalTime),
        10000,'center',0,0,0,1,1,5000)
    gc.draw(timeTxt,0,400,0,1/3,1/3,0,timeTxt:getHeight()/2)
    --gc.printf(user.lang.about.time:format(win.stat.launch,win.stat.totalTime+scene.totalTime),
        --font.Bender,-700,400,10000,'center',0,1/3,1/3,5000,144)
    BUTTON.draw()

    local t=#about.loveBallTrail
    local lbt=about.loveBallTrail
    local s
    for i=1,t do
        s=(128-t+i)/128
        gc.setColor(1,1,1,.25*s^.5)
        gc.draw(loveLogo,lbt[i].x,lbt[i].y,lbt[i].r,ballR*2/lw*s,ballR*2/lh*s,lw/2,lh/2)
    end

    gc.setColor(1,1,1)
    gc.draw(loveLogo,about.loveBall.body:getX(),about.loveBall.body:getY(),about.loveBall.body:getAngle(),ballR*2/lw,ballR*2/lh,lw/2,lh/2)
end
return about