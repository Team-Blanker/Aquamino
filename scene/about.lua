local BUTTON=scene.button

local logo=gc.newImage('assets/pic/title.png')
local loveLogo=gc.newImage('assets/pic/love-logo.png')
local w,h=logo:getPixelDimensions()
local lw,lh=loveLogo:getPixelDimensions()
local ballR=32
local devList={
    devTeam={
        name="Team Blanker",
        member={'Aqua6623(Aquamarine6623, Kairan, 海兰)'}
    },
    program={'Aqua6623'},
    art={'Aqua6623','MrZ_26'},
    UI={'Aqua6623'},
    music={
        hurtRecord={
            'たかゆき','R-side','T-Malu','守己','カモキング','龍飛','Syun Nakano','Naoki Hirai',
            'つかスタジオ','アキハバラ所司代','georhythm','Teada','Mikiya Komaba','ミレラ','周藤三日月',
            'DiscreetDragon'
        }
    },
    sfx={'Aqua6623'},
    --{谁,字多大,……}
    specialThanks={'MrZ_26',1.75,'XMiao小渺(Chumo2791)',1,'User670',1,'MianSoft',1,'沙盒子',1,'Sunday',1,'Not-A-Normal-Robot',1,'SweetSea-ButImNotSweet',1}
}
local repo={
    {'json.lua','rxi'},{'profile.lua','itraykov'}
}
local tool={'Beepbox','Malody','VS Code','GFIE(Greenfish Icon Editor)'}

local about={}
function about.init()
    scene.BG=require('BG/menuBG')
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

    local txt=user.lang.about.repo..'\n'
    for i=1,#repo do
        txt=txt..string.format('%s by %s\n',repo[i][1],repo[i][2])
    end
    about.rTxt=gc.newText(font.Bender)
    about.rTxt:setf(txt,500*3,'left')
    txt=user.lang.about.tool..'\n'
    for i=1,#repo do
        txt=txt..string.format('%s\n',tool[i])
    end
    about.tTxt=gc.newText(font.Bender)
    about.tTxt:setf(txt,500*3,'left')

    about.eTxt=gc.newText(font.Bender,user.lang.about.engineText)

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            scene.switch({
                dest='menu',destScene=require('scene/menu'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
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
end
local drag=false
function about.mouseP(x,y,button,istouch)
    if (x-about.loveBall.body:getX())^2+(y-about.loveBall.body:getY())^2<ballR^2 then
        drag=true
        about.loveBall.body:setAwake(true)
    else BUTTON.press(x,y,button,istouch) end
end
function about.mouseR(x,y,button,istouch)
    drag=false
    BUTTON.release(x,y,button,istouch)
end

function about.update(dt)
    about.world:update(dt)
    local mx,my=adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    BUTTON.update(dt,mx,my)
    if ms.isDown(1) and drag then
        about.loveBall.body:applyForce(400*(mx-about.loveBall.body:getX()),400*(my-about.loveBall.body:getY()))
    end
end
function about.draw()
    gc.setColor(1,1,1)
    gc.draw(logo,0,-400+12*sin(scene.time/5%2*math.pi),0,800/w,800/w,w/2,h/2)
    gc.draw(about.eTxt,425,-400+800/w*h/4,0,1/3,1/3,0,128)
    gc.draw(about.rTxt,-810,-270,0,1/3,1/3,0,0)
    gc.draw(about.tTxt,-270,-270,0,1/3,1/3,0,0)
    BUTTON.draw()
    gc.draw(loveLogo,about.loveBall.body:getX(),about.loveBall.body:getY(),about.loveBall.body:getAngle(),ballR*2/lw,ballR*2/lh,lw/2,lh/2)
end
return about