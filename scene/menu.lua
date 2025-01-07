local m=user.lang.menu
local BUTTON=scene.button
local SLIDER=scene.slider

local menu={modeKey=1,sAnimTMax=.15}

local bso=require'mino/bestScoreOrder'

local setIcon1,setIcon2=gc.newCanvas(120,120),gc.newCanvas(120,120)
local aboutIcon=gc.newCanvas(120,120)
gc.translate(60,60)
gc.setColor(1,1,1)
gc.setLineWidth(6)
gc.setCanvas(setIcon1)
    gc.circle('line',0,0,22.5,12)
gc.setCanvas(setIcon2)
    gc.line(0,36,-18*3^.5,18) gc.line(0,-36,-18*3^.5,-18) gc.line(18*3^.5,-18,18*3^.5,18)
gc.setCanvas(aboutIcon)
    gc.circle('line',0,0,55,8)
    gc.circle('fill',0,-30,10,4)
    gc.rectangle('fill',-5,-10,10,50)
gc.setCanvas()
gc.translate(-60,-60)

menu.modeList={
    --xy都是绘制坐标
    ['40 lines']={x=-300,y=0,borderColor={.1,.9,.7}},
    marathon={x=-150,y=150,borderColor={.1,.9,.7}},
    ['dig 40']={x=-150,y=-150,borderColor={.1,.9,.7}},
    backfire={x=300,y=0,borderColor={.1,.9,.7}},
    battle={x=150,y=-150,borderColor={.1,.9,.7}},
    ['ice storm']={x=450,y=150,borderColor={.2,.9,.9}},
    sandbox={x=150,y=150,borderColor={.6,.6,.6}},
    thunder={x=-300,y=-300,borderColor={.2,.9,.9}},
    smooth={x=-450,y=150,borderColor={.2,.9,.9}},
    levitate={x=-450,y=-150,borderColor={.2,.9,.9}},
    master={x=-300,y=300,borderColor={.96,.24,.24}},
    overdose={x=300,y=300,borderColor={.96,.24,.24}},
    multitasking={x=0,y=300,borderColor={.96,.24,.24}},
    laser={x=450,y=-150,borderColor={.2,.9,.9}},
    ['tower defense']={x=300,y=-300,borderColor={.2,.9,.9}},
}
menu.secretMode={
    ['40 lines']={mode='pento 40'},
    ['tower defense']={mode='core destruction',arg='tower defense'},
    sandbox={mode='square'}
}
menu.notRecordScore={sandbox=true,battle=true,['tower defense']=true}
menu.icon={}
menu.option={
    battle={bot_DropDelay=1,playerPos='left'},
    ['tower defense']={bot_DropDelay=1,playerPos='left'},
}

for k,v in pairs(menu.modeList) do
    menu.icon[k]=gc.newImage('pic/mode icon/'..k..'.png')
end

local playButtonPolygon={-225,0,-175,50,175,50,225,0,175,-50,-175,-50}
function menu.init()
    sfx.add({
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/buttonQuit.wav',
        gameEnter='sfx/general/gameEnter.wav',
    })

    for k,v in pairs(menu.modeList) do
        v.hoverT=0
    end
    m=user.lang.menu
    menu.modeName=user.lang.modeName
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

    menu.modeTxt={}
    for k,v in pairs(user.lang.modeName) do
        menu.modeTxt[k]={}
        menu.modeTxt[k].txt=gc.newText(font.Bender,v)

        menu.modeTxt[k].w=menu.modeTxt[k].txt:getWidth()
        menu.modeTxt[k].h=menu.modeTxt[k].txt:getHeight()
    end

    menu.describeTxt={}
    for k,v in pairs(user.lang.modeDescription) do
        menu.describeTxt[k]={}
        menu.describeTxt[k].txt=gc.newText(font.Bender)
        menu.describeTxt[k].txt:addf(v,4096,'center',0,0,0,1,1,2048,0)

        menu.describeTxt[k].w=menu.describeTxt[k].txt:getWidth()
        menu.describeTxt[k].h=menu.describeTxt[k].txt:getHeight()
    end

    menu.lvl=1 menu.sAnimTimer=0
    menu.pAnim=false menu.pAnimTimer=0
    menu.rCount=0
    menu.selectedMode=''

    menu.pbString={}
    menu.pb=file.read('player/best score')
    for k,v in pairs(menu.pb) do
        menu.pbString[k]=bso[k](v)
    end

    menu.CDTimer=0--旧核心毁灭进入计时
    menu.CDEnter=false

    BUTTON.setLayer(1)
    BUTTON.create('setting',{
        x=-960,y=-540,type='diamond',r=225,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setLineWidth(6)
            gc.setColor(1,1,1)
            gc.arc('line','closed',60,60,50,math.pi/2,5*math.pi/2,6)
            gc.setColor(1,1,1,(1-t*5))
            gc.draw(setIcon1,0,0)
            gc.setColor(1,1,1,(t*5))
            gc.draw(setIcon2,0,0)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.3,outT=.2,
                anim=function() anim.enterUL(.2,.1,.2,0,0,0) end
            })
            sfx.play('click')
            function menu.send(destScene)
                destScene.exitScene='scene/menu'
            end
        end
    },.2)
    BUTTON.create('quit',{
        x=-960,y=540,type='diamond',r=225,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,-5,95)
        end,
        event=function()
            sfx.play('quit')
            scene.switch({
                dest='intro',swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('about',{
        x=960,y=-540,type='diamond',r=225,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1)
            gc.draw(aboutIcon,0,0,0,1,1,120,0)
        end,
        event=function()
            sfx.play('click')
            scene.switch({
                dest='about',swapT=.3,outT=.2,
                anim=function() anim.enterUR(.2,.1,.2,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('nothing',{
        x=960,y=540,type='diamond',r=225,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
        end,
        event=function()
        end
    },.2)
    BUTTON.setLayer(2)
    BUTTON.create('back',{
        x=-960,y=540,type='diamond',r=225,
        draw=function(bt,t)
            local a=menu.sAnimTimer/menu.sAnimTMax
            gc.setColor(.5,.5,.5,(.3+t)*a)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8,a)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1,a)
            gc.draw(win.UI.back,0,0,0,1,1,-5,95)
        end,
        event=function()
            sfx.play('quit',1,2^(1/3))
            menu.lvl=1
        end
    },.2)
    BUTTON.create('play',{
        x=0,y=390,type='rect',w=450,h=100,
        draw=function(bt,t)
            local a=menu.sAnimTimer/menu.sAnimTMax*2-1
            if menu.pAnim then
                local s=menu.pAnimTimer>.2 and 1 or menu.pAnimTimer%.1<.05 and 1 or 0
                gc.setColor(.75,.75,.75,.5+.1*s)
            else gc.setColor(.75,.75,.75,(.15+t/2)*a)
            end
            gc.polygon('fill',playButtonPolygon)
            gc.setColor(1,1,1,a)
            gc.setLineWidth(5)
            gc.polygon('line',playButtonPolygon)
            gc.setColor(1,1,1,a)
            gc.circle('fill',-5,0,40,3)
        end,
        event=function()
            menu.pAnim=true
            sfx.play('click',1,2^(2/3))
            sfx.play('gameEnter')
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=1.6,outT=.2,
                anim=function() anim.enterGame(.4,1.2,.2) end
            })
            scene.sendArg={mode=menu.selectedMode,arg=menu.option[menu.selectedMode]}
            menu.send=menu.gameSend
        end
    },.2)

    local lst=require'scene/menu/modeOption'
    lst.slider(menu)
end
function menu.keyP(k)
    if menu.lvl==1 then
        if k=='escape' then
            scene.switch({
                dest='intro',swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    elseif menu.lvl==2 then
        if k=='escape' then menu.lvl=1 end
    end
end
function menu.mouseP(x,y,button,istouch)
    if not (BUTTON.press(x,y,menu.lvl) or SLIDER.mouseP(x,y,button,istouch)) then
        if menu.lvl==1 then
            for k,v in pairs(menu.modeList) do
                if abs(x-v.x)+abs(y-v.y)<150 then
                    menu.selectedMode=k
                    sfx.play('click',1,2^(1/3))
                    print(menu.selectedMode)
                end
            end
            if abs(x)+abs(y)<150 then
                menu.rCount=menu.rCount+1
                if menu.rCount>=8 then
                    sfx.play('gameEnter')
                    scene.switch({
                        dest='game',destScene=require'mino/game',
                        swapT=1.6,outT=.2,
                        anim=function() anim.enterGame(.4,1.2,.2) end
                    })
                    scene.sendArg={mode='idea_test'}
                    menu.send=menu.gameSend
                end
            end
        elseif menu.lvl==2 then
        end
    end
end
function menu.mouseR(x,y,button,istouch)
    if not (BUTTON.release(x,y,menu.lvl) or SLIDER.mouseR(x,y,button,istouch)) then
        for k,v in pairs(menu.modeList) do
            if abs(x-v.x)+abs(y-v.y)<150 and k==menu.selectedMode then
                menu.lvl=2
            end
        end
    end
end
local hv=''
local msx,msy=0,0
function menu.swapUpdate(dest,swapT)
    if dest=='game' then mus.setVolume((swapT-1.2)/.4) end
end
function menu.update(dt)
    msx,msy=adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],msx,msy) end
    local n=false
    for k,v in pairs(menu.modeList) do
        if menu.lvl==1 and abs(msx-v.x)+abs(msy-v.y)<150 then n=true
            v.hoverT=min(v.hoverT+dt,.15)
            if k~=hv then
                scene.BG.setPolyColor(v.borderColor[1],v.borderColor[2],v.borderColor[3])
                hv=k
            end
        else v.hoverT=max(v.hoverT-dt,0) end
    end
    if (not n) and hv~='' then scene.BG.setPolyColor(1,1,1) hv='' end
    if hv=='tower defense' and not menu.CDEnter then menu.CDTimer=menu.CDTimer+dt
        if menu.CDTimer>=10 then menu.CDEnter=true
            sfx.play('gameEnter')
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=1.6,outT=.2,
                anim=function() anim.enterGame(.4,1.2,.2) end
            })
            scene.sendArg={mode='core destruction',arg=menu.option[hv]}
            menu.send=menu.gameSend
        end
    elseif hv=='40 lines' and not menu.CDEnter then menu.CDTimer=menu.CDTimer+dt
        if menu.CDTimer>=10 then menu.CDEnter=true
            sfx.play('gameEnter')
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=1.6,outT=.2,
                anim=function() anim.enterGame(.4,1.2,.2) end
            })
            scene.sendArg={mode='pento 40'}
            menu.send=menu.gameSend
        end
    else menu.CDTimer=0 end

    if menu.pAnim then menu.pAnimTimer=menu.pAnimTimer+dt end
    menu.sAnimTimer=menu.lvl==2 and min(menu.sAnimTimer+dt,menu.sAnimTMax) or max(menu.sAnimTimer-dt,0)
    BUTTON.update(dt,msx,msy,menu.lvl)
end

local cv=gc.newCanvas(300,300)
gc.setCanvas(cv)
gc.setColor(1,1,1)
gc.circle('fill',150,150,140,4)
gc.setCanvas()

local mt
local ts=.4
local w,h,c
local lerp=mymath.lerp
function menu.draw()
    mt=menu.modeTxt
    for k,v in pairs(menu.modeList) do
        c=v.borderColor

        gc.setColor(c[1],c[2],c[3],.25+v.hoverT)
        gc.draw(cv,v.x,v.y,0,1,1,150,150)
        gc.setColor(c)
        gc.setLineWidth(4+2*v.hoverT/.15)
        gc.circle('line',v.x,v.y,140,4)
        gc.setColor(1,1,1)
        gc.draw(menu.icon[k],v.x,v.y,0,1,1,150,150)
    end
    for k,v in pairs(menu.modeList) do
        w,h=mt[k].w*ts,mt[k].h*ts
        c=v.borderColor

        gc.setColor(c[1],c[2],c[3],v.hoverT/.15*.25)
        for i=-2,2 do
        gc.rectangle('fill',v.x-w/2+16*i,v.y-45-h-v.hoverT/.15*15-2,w,h+4)
        end
        gc.setColor(1,1,1,v.hoverT/.15)
        gc.draw(mt[k].txt,v.x,v.y-45-v.hoverT/.15*15,0,.4,.4,mt[k].w/2,mt[k].h)
    end
    BUTTON.draw(1)

    if menu.selectedMode~='' then
    c=menu.modeList[menu.selectedMode].borderColor
    local a=menu.sAnimTimer/menu.sAnimTMax
    gc.setColor(.05,.05,.05,a*.75)
    gc.rectangle('fill',-960,-540,1920,1080)
    gc.setColor(c[1],c[2],c[3],a)

    gc.setLineWidth(40)
    local p=menu.lvl==2 and (a-2)*-a or a
    gc.circle('line',0,0,540+360*p,4)

    gc.setColor(1,1,1,a*2-1)
    local t,det,bst=mt[menu.selectedMode],menu.describeTxt[menu.selectedMode],menu.pb[menu.selectedMode]
    local s=min(750/t.w,.75)
    gc.draw(t.txt,0,-390,0,s,s,t.w/2,t.h)
    if det then gc.draw(det.txt,0,-360,0,3/8,3/8,0,0) end
    if not menu.notRecordScore[menu.selectedMode] then
        if bst then
            gc.printf(user.lang.menu.bestScore,font.Bender,0,150,2000,'center',0,.5,.5,1000,72)
            gc.printf(menu.pbString[menu.selectedMode],font.Bender,0,210,3000,'center',0,1/3,1/3,1500,72)
            gc.printf(menu.pb[menu.selectedMode].date or '',font.Bender,0,270,2000,'center',0,.25,.25,1000,72)
        else gc.printf(user.lang.menu.noBestScore,font.Bender,0,180,2000,'center',0,.5,.5,1000,72) end
        end
    end

    BUTTON.draw(2)
    SLIDER.draw()
end
function menu.exit()
    file.save('player/unlocked',menu.unlocked)
end
function menu.gameSend(destScene,arg)
    destScene.modeInfo=arg
    destScene.exitScene='menu'
end
return menu