local BUTTON=scene.button

local logo=gc.newImage('assets/pic/title.png')
local w,h=logo:getPixelDimensions()

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

local stf={}
function stf.init()
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

    stf.posy=0

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
                dest='about',destScene=require('scene/about'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
        end
    },.2)
end

local posyMax=1080
local mp=false local opy,mpy=0,0
function stf.mouseP(x,y,button,istouch)
    mp=true opy,mpy=stf.posy,y
    BUTTON.press(x,y,button,istouch)
end
function stf.mouseR(x,y,button,istouch)
    mp=false stf.posy=max(min(opy-y+mpy,posyMax),0)
    BUTTON.release(x,y,button,istouch)
end

function stf.wheelMove(dx,dy)
    stf.posy=max(min(stf.posy-dy*108,posyMax),0)
    print(dy)
end

function stf.update(dt)
    local mx,my=adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    if love.mouse.isDown(1) then stf.posy=max(min(opy-my+mpy,posyMax),0) end
    BUTTON.update(dt,mx,my)

    if kb.isDown('up') then stf.posy=max(stf.posy-540*dt,0) end
    if kb.isDown('down') then stf.posy=min(stf.posy+540*dt,posyMax) end
end
function stf.draw()
    gc.translate(0,-stf.posy)
    gc.setColor(1,1,1)
    gc.draw(logo,0,0,0,1280/w,1280/w,w/2,h/2)
    gc.printf('by Team Blanker',font.Bender,0,280,10000,'center',0,.8,.8,5000,72)
    gc.translate(0,stf.posy)
    BUTTON.draw()
end
return stf