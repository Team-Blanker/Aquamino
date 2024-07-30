local BUTTON=scene.button

local logo=gc.newImage('assets/pic/title.png')
local w,h=logo:getPixelDimensions()
local kairan=gc.newImage('assets/pic/kairan.png')
local kw,kh=kairan:getPixelDimensions()
local devList={
    program={'Aqua6623 (Aquamarine6623, Kairan, 海兰)'},
    UI={'Aqua6623','Not-A-Normal-Robot'},
    sfx={'Aqua6623','Farter'},
    music={
        hurtRecord={
            {'たかゆき','R-side','T-Malu','守己','カモキング','龍飛'},
            {'Syun Nakano','Naoki Hirai','つかスタジオ'},
            {'アキハバラ所司代','georhythm','Teada','Mikiya Komaba'},
            {'ミレラ','周藤三日月','DiscreetDragon'}
        }
    },
    specialThanks={
        {'MrZ_26'},
        {'XMiao小渺 (XM1ao)','User670','MianSoft','沙盒子','Sunday'},
        {'T427 默默颗','風洛靈flore','大叔Rex'},
        {'Not-A-Normal-Robot','SweetSea-ButImNotSweet'},
        {'nekonaomii (MelloBoo44)'}
    }
}

local stf={}
local uls
local c1,c2={.5,1,.875},{1,1,1}

stf.s={.4,.6,.4}
stf.h={}
local function getH(num)
    local th=0
    for i=1,num do
        th=th+stf.h[i]*stf.s[i]
    end
    return th
end

local posyMax=2160

function stf.init()
    sfx.add({
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

    uls=user.lang.staff
    stf.posy=0
    stf.hidey=0 stf.hideAnimy=0 stf.showKairan=false
    stf.txt1={c1,uls.program,c2,'\n\n'..devList.program[1],c1,'\n\n'..uls.UI,c2}


    local t1='\n\n'
    for i=1,#devList.UI do
        t1=t1..devList.UI[i]
        if i~=#devList.UI then t1=t1..'    ' end
    end
    stf.txt1[#stf.txt1+1]=t1

    stf.txt1[#stf.txt1+1]=c1
    stf.txt1[#stf.txt1+1]='\n\n'..uls.sfx
    stf.txt1[#stf.txt1+1]=c2
    stf.txt1[#stf.txt1+1]='\n\n'..devList.sfx[1]..'    '..devList.sfx[2]
    stf.txt1[#stf.txt1+1]=c1
    stf.txt1[#stf.txt1+1]='\n\n'..uls.music
    stf.txt1[#stf.txt1+1]={1,.75,.75}
    stf.txt1[#stf.txt1+1]=' HURT RECORD (https://www.hurtrecord.com)'

    stf.txt1[#stf.txt1+1]=c2
    t1='\n\n'
    local hr=devList.music.hurtRecord
    for i=1,#hr do
        for j=1,#hr[i] do
        t1=t1..hr[i][j]
        if i~=#hr[i] then t1=t1..'    ' end
        end
        t1=t1..'\n'
    end
    stf.txt1[#stf.txt1+1]=t1

    stf.txt1[#stf.txt1+1]=c1
    stf.txt1[#stf.txt1+1]='\n'..uls.specialThanks..'\n'

    stf.stftxt1=gc.newText(font.Bender)
    stf.stftxt1:addf(stf.txt1,4000,'center')
    stf.h[1]=stf.stftxt1:getHeight()

    stf.stftxt2=gc.newText(font.Bender)
    stf.stftxt2:addf(devList.specialThanks[1][1],4000,'center')
    stf.h[2]=stf.stftxt2:getHeight()

    t1=''
    local sp=devList.specialThanks
    for i=2,#sp do
        for j=1,#sp[i] do
        t1=t1..sp[i][j]
        if i~=#sp[i][j] then t1=t1..'    ' end
        end
        t1=t1..'\n'
    end
    t1=t1..uls.tester
    t1=t1..'\n\nThank you for playing.'

    stf.stftxt3=gc.newText(font.Bender)
    stf.stftxt3:addf(t1,4000,'center')
    stf.h[3]=stf.stftxt3:getHeight()


    posyMax=400+getH(3)

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
                dest='about',destScene=require('scene/about'),swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)
end

local mp=false local opy,mpy=0,0
local hp=false local ohy,mhy=0,0
function stf.mouseP(x,y,button,istouch)
    mp=true opy,mpy=stf.posy,y
    if stf.posy==posyMax then
        hp=true ohy,mhy=0,y
    end
    BUTTON.press(x,y)
end
function stf.mouseR(x,y,button,istouch)
    mp=false stf.posy=max(min(opy-y+mpy,posyMax),0)
    hp=false ohy,mhy=0,0
    BUTTON.release(x,y)
end

function stf.wheelMove(dx,dy)
    stf.posy=max(min(stf.posy-dy*90,posyMax),0)
end

local function setAnimy(hidey)
    local hy=hidey/1000
    return ((2-hy)*hy-.75)*1000
end
function stf.update(dt)
    local mx,my=adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    if love.mouse.isDown(1,2) then
        stf.posy=max(min(opy-my+mpy,posyMax),0)
        if hp and not stf.showKairan then stf.hidey=max(min(ohy-my+mhy,1000),0) stf.hideAnimy=setAnimy(stf.hidey)
        if stf.hidey>=1000 then stf.showKairan=true end
        end
    end
    if stf.showKairan then stf.hideAnimy=min(stf.hideAnimy+8000*dt,1000)
    else stf.hidey=max(stf.hidey-4000*dt,0) stf.hideAnimy=max(stf.hideAnimy-4000*dt,0) end

    BUTTON.update(dt,mx,my)

    if kb.isDown('up') then stf.posy=max(stf.posy-720*dt,0) end
    if kb.isDown('down') then stf.posy=min(stf.posy+720*dt,posyMax) end
end
function stf.draw()
    gc.translate(0,-stf.posy)
    gc.setColor(1,1,1)
    gc.draw(logo,0,0,0,1280/w,1280/w,w/2,h/2)
    gc.printf("by Team Blanker",font.Bender,0,240,10000,'center',0,.75,.75,5000,72)
    gc.draw(stf.stftxt1,0,400,0,stf.s[1],stf.s[1],2000)
    gc.draw(stf.stftxt2,0,400+getH(1),0,stf.s[2],stf.s[2],2000)
    gc.draw(stf.stftxt3,0,400+getH(2),0,stf.s[3],stf.s[3],2000)

    local p=stf.hideAnimy/1000
    gc.draw(kairan,900-kw/4,posyMax+540-kh/2*p,0,.5,.5,kw/2,0)
    gc.translate(0,stf.posy)
    BUTTON.draw()
end
return stf