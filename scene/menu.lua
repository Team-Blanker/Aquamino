local m=user.lang.menu
local BUTTON=scene.button
local SLIDER=scene.slider

local menu={modeKey=1}

local bso=require'mino/bestScoreOrder'

local rulebookIcon=gc.newImage('pic/UI/sign/rulebook.png')
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
    ['40 lines']={x=-300,y=0,borderColor={.1,.9,.7},playable=true},
    marathon={x=-150,y=150,borderColor={.1,.9,.7},playable=true},
    ['dig 40']={x=-150,y=-150,borderColor={.1,.9,.7},playable=true},
    backfire={x=300,y=0,borderColor={.1,.9,.7},playable=true},
    battle={x=150,y=-150,borderColor={.1,.9,.7},playable=true},
    ['ice storm']={x=450,y=150,borderColor={.2,.9,.9},playable=true},
    sandbox={x=150,y=150,borderColor={.6,.6,.6},playable=true},
    thunder={x=-300,y=-300,borderColor={.2,.9,.9},playable=true},
    smooth={x=-450,y=150,borderColor={.2,.9,.9},playable=true},
    levitate={x=-450,y=-150,borderColor={.2,.9,.9},playable=true},
    master={x=-300,y=300,borderColor={.96,.24,.24},playable=true},
    overdose={x=300,y=300,borderColor={.96,.24,.24},playable=false},
    multitasking={x=0,y=300,borderColor={.96,.24,.24},playable=true},
    laser={x=450,y=-150,borderColor={.2,.9,.9},playable=true},
    ['tower defense']={x=300,y=-300,borderColor={.2,.9,.9},playable=true},

    --['mech heart detector']={x=750,y=0,borderColor={.6,.6,.6},playable=true},
}
menu.secretMode={
    ['40 lines']={mode='pento 40'},
    ['tower defense']={mode='core destruction',arg='tower defense'},
    sandbox={mode='square'},
    ['dig 40']={mode='dig bomb'},
    --multitasking={mode='multitasking_plus'},
}

menu.notSaveScore={sandbox=true,battle=true,['tower defense']=true}
menu.icon={}
menu.battleRuleSet={'basic','allspin','allspin2','aqua','shrink','bomb'}
menu.option={
    battle={bot_PPS=1,playerPos='left',ruleNum=0,ruleSet='basic'},
    ['tower defense']={bot_PPS=1,playerPos='left'},
    ['ice storm']={iceOpacity=1}
}

for k,v in pairs(menu.modeList) do
    menu.icon[k]=gc.newImage('pic/mode icon/'..k..'.png')
end

local extLinkURL={
    'https://github.com/Aqua6623/Aquamino_Doc',
    'https://harddrop.com/wiki/Tetris_Wiki',
    'http://tetriswiki.cn',
    'https://tetris.wiki',
    'https://four.lol',
    'https://dunspixel.github.io/ospin-guide/',
}
local playButtonPolygon={-225,0,-175,50,175,50,225,0,175,-50,-175,-50}
function menu.init()
    sfx.add({
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/buttonQuit.wav',
        gameEnter='sfx/general/gameEnter.wav',
        rbopen='sfx/general/ruleBookOpen.wav',
        rbclose='sfx/general/ruleBookClose.wav',
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
    mus.setVolume(1)

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

    menu.lvl=1
    menu.selectAnimTimer=0 menu.selectAnimTMax=.15
    menu.linkAnimTimer=0 menu.linkAnimTMax=.15
    menu.pAnim=false menu.pAnimTimer=0
    menu.rCount=0
    menu.selectedMode=nil

    menu.pbString={}
    menu.pb=file.read('player/best score')
    for k,v in pairs(menu.pb) do
        menu.pbString[k]=bso[k](v)
    end

    menu.SMTimer=0
    menu.SMEnter=false

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
            gc.setColor(1,1,1,t*3)
            gc.printf(m.button.setting,font.Bender,114,114,2000,'center',-math.pi/4,1/3,1/3,1000,0)
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
            if menu.lvl~=1 then return end
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
            gc.setColor(1,1,1,t*3)
            gc.printf(m.button.about,font.Bender,-114,114,2000,'center',math.pi/4,1/3,1/3,1000,0)
        end,
        event=function()
            sfx.play('click')
            scene.switch({
                dest='about',swapT=.3,outT=.2,
                anim=function() anim.enterUR(.2,.1,.2,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('links',{
        x=960,y=540,type='diamond',r=225,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1)
            gc.draw(rulebookIcon,0,0,0,1,1,120,120)
            gc.setColor(1,1,1,t*3)
            gc.printf(m.button.links,font.Bender,-114,-114,2000,'center',-math.pi/4,1/3,1/3,1000,font.height.Bender)
        end,
        event=function()
            sfx.play('click')
            menu.lvl=3
        end
    },.2)
    BUTTON.setLayer(2)
    BUTTON.create('backsm',{
        x=-960,y=540,type='diamond',r=225,
        draw=function(bt,t)
            if menu.lvl~=2 then return end
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1)
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
            if not menu.selectedMode then return end
            if not menu.modeList[menu.selectedMode].playable then
                gc.printf(m.notPlayable,font.Bender,0,0,2000,'center',0,.625,.625,1000,font.height.Bender/2)
                return
            end
            local a=menu.selectAnimTimer/menu.selectAnimTMax*2-1
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
            if not menu.modeList[menu.selectedMode].playable then return end
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
    BUTTON.setLayer(3)
    BUTTON.create('backrbcs',{
        x=-960,y=540,type='diamond',r=225,
        draw=function(bt,t)
            if menu.lvl<=2 then return end
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,-5,95)
        end,
        event=function()
            sfx.play('quit',1,2^(1/3))
            menu.lvl=1
        end
    },.2)
    for i=1,#extLinkURL do
        BUTTON.create(('extlink'..i),{
        x=0,y=-280+80*i,type='rect',w=960,h=60,
        draw=function(bt,t)
            local a=menu.linkAnimTimer/menu.linkAnimTMax
            if t>0 then gc.setColor(.5,1,.875,a*.1)
                gc.rectangle('fill',-bt.w/2,-bt.h/2,bt.w,bt.h)
            end
            if t>0 then gc.setColor(.5,1,.875,a) else gc.setColor(1,1,1,a) end
            gc.draw(win.UI.link,bt.w/2-bt.h/2,0,0,.2,.2,100,100)
            gc.printf(m.extLink[i],font.Bender,-bt.w/2,bt.h/2,2000,'left',0,.4,.4,0,font.height.Bender)
            gc.setLineWidth(2)
            gc.line(-bt.w/2,bt.h/2,bt.w/2,bt.h/2)
        end,
        event=function()
            sfx.play('rbopen')
            love.system.openURL(extLinkURL[i])
        end
    },.0001)
    end
    BUTTON.setLayer(4)

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
        elseif menu.lvl==3 then
        end
    end
end
function menu.mouseR(x,y,button,istouch)
    if not (BUTTON.release(x,y,menu.lvl) or SLIDER.mouseR(x,y,button,istouch)) then
        for k,v in pairs(menu.modeList) do
            local click=abs(x-v.x)+abs(y-v.y)<150
            if click and k==menu.selectedMode and menu.lvl==1 then
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

    if love.mouse.isDown(1) then
        for k,v in pairs(menu.secretMode) do
            if hv==k and not menu.SMEnter then menu.SMTimer=menu.SMTimer+dt
                if menu.SMTimer>=5 then menu.SMEnter=true
                    sfx.play('gameEnter')
                    scene.switch({
                        dest='game',destScene=require'mino/game',
                        swapT=1.6,outT=.2,
                        anim=function() anim.enterGame(.4,1.2,.2) end
                    })
                    scene.sendArg={mode=v.mode,arg=menu.option[v.arg]}
                    menu.send=menu.gameSend
                end
            end
        end
    else menu.SMTimer=0 end

    if menu.pAnim then menu.pAnimTimer=menu.pAnimTimer+dt end
    menu.selectAnimTimer=menu.lvl==2 and min(menu.selectAnimTimer+dt,menu.selectAnimTMax) or max(menu.selectAnimTimer-dt,0)
    menu.linkAnimTimer=menu.lvl>=3 and min(menu.linkAnimTimer+dt,menu.linkAnimTMax) or max(menu.linkAnimTimer-dt,0)
    BUTTON.update(dt,msx,msy,menu.lvl)
end

local cv=gc.newCanvas(300,300)
gc.setCanvas(cv)
gc.setColor(1,1,1)
gc.circle('fill',150,150,140,4)
gc.setCanvas()

local mt
local ts=5/12
local w,h,c
local lerp=myMath.lerp
function menu.draw()
    mt=menu.modeTxt

    BUTTON.draw(1)

    local a=menu.linkAnimTimer/menu.linkAnimTMax
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
        gc.draw(mt[k].txt,v.x,v.y-45-v.hoverT/.15*15,0,ts,ts,mt[k].w/2,mt[k].h)
    end

    if menu.selectedMode then
    c=menu.modeList[menu.selectedMode].borderColor
    local a=menu.selectAnimTimer/menu.selectAnimTMax
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
    if not menu.notSaveScore[menu.selectedMode] then
        if bst then
            gc.printf(m.bestScore,font.Bender,0,150,2000,'center',0,.5,.5,1000,font.height.Bender/2)
            gc.printf(menu.pbString[menu.selectedMode],font.Bender,0,210,3000,'center',0,1/3,1/3,1500,font.height.Bender/2)
            gc.printf(menu.pb[menu.selectedMode].date or '',font.Bender,0,270,2000,'center',0,.25,.25,1000,font.height.Bender/2)
        else gc.printf(m.noBestScore,font.Bender,0,180,2000,'center',0,.5,.5,1000,font.height.Bender/2) end
        end
    end

    BUTTON.draw(2)
    SLIDER.draw()

    gc.setColor(.05,.05,.05,a*.75)
    gc.rectangle('fill',-960,-540,1920,1080)
    gc.setColor(1,1,1,a)
    BUTTON.draw(3)
end
function menu.exit()
    file.save('player/unlocked',menu.unlocked)
end
function menu.gameSend(destScene,arg)
    destScene.modeInfo=arg
    destScene.exitScene='menu'
end
return menu