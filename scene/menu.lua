local m=user.lang.menu
local BUTTON=scene.button

local menu={modeKey=1}
local flashT,enterT,clickT=0,0,0

local setIcon1,setIcon2=gc.newCanvas(120,120),gc.newCanvas(120,120)
local aboutIcon=gc.newCanvas(120,120)
gc.translate(60,60)
gc.setColor(1,1,1)
gc.setLineWidth(8)
gc.setCanvas(setIcon1)
    gc.push()
    gc.rotate(math.pi/2)
    gc.circle('line',0,0,50,6)
    gc.pop()
    gc.circle('line',0,0,22.5,12)
gc.setCanvas(setIcon2)
    gc.push()
    gc.rotate(math.pi/2)
    gc.circle('line',0,0,50,6)
    gc.pop()
    gc.line(0,36,-18*3^.5,18) gc.line(0,-36,-18*3^.5,-18) gc.line(18*3^.5,-18,18*3^.5,18)
gc.setCanvas(aboutIcon)
    gc.circle('line',0,0,55,8)
    gc.circle('fill',0,-30,10,4)
    gc.rectangle('fill',-5,-10,10,50)
gc.setCanvas()
gc.translate(-60,-60)

menu.modeList={
    --xy都是绘制坐标
    ['40 lines']={x=-300,y=0,borderColor={0,1,.75}},
    marathon={x=-150,y=150,borderColor={0,1,.75}},
    ['dig 40']={x=-150,y=-150,borderColor={0,1,.75}},
    ['ice storm']={x=450,y=150,borderColor={0,1,1}},
    backfire={x=150,y=-150,borderColor={0,1,.75}},
    sandbox={x=300,y=0,borderColor={.6,.6,.6}},
    thunder={x=-300,y=-300,borderColor={0,1,1}},
    smooth={x=-450,y=150,borderColor={0,1,1}},
    levitate={x=-450,y=-150,borderColor={0,1,1}},
    master={x=-300,y=300,borderColor={1,.25,.25}},
    multitasking={x=0,y=300,borderColor={1,.25,.25}},
    laser={x=450,y=-150,borderColor={0,1,1}},
}
menu.icon={
    border=gc.newImage('pic/mode icon/border.png')
}
for k,v in pairs(menu.modeList) do
    menu.icon[k]=gc.newImage('pic/mode icon/'..k..'.png')
end
function menu.init()
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

    menu.lvl=1
    menu.rCount=0
    menu.selectedMode=''

    BUTTON.create('setting',{
        x=-960,y=-540,type='diamond',r=225,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.circle('fill',0,0,bt.r,4)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.circle('line',0,0,bt.r,4)
            gc.setColor(1,1,1,(1-t*5))
            gc.draw(setIcon1,0,0)
            gc.setColor(1,1,1,(t*5))
            gc.draw(setIcon2,0,0)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.6,outT=.4,
                anim=function() anim.enterConf(.4,.2,.4,0,0,0) end
            })
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
            scene.switch({
                dest='intro',swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
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
            scene.switch({
                dest='about',swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
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
end
function menu.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='intro',swapT=.7,outT=.3,
            anim=function() anim.cover(.3,.4,.3,0,0,0) end
        })
    elseif k=='r' then
        menu.rCount=menu.rCount+1
        if menu.rCount>=16 then
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
            scene.sendArg='idea_test'
            menu.send=menu.gameSend
        end
    end
end
function menu.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) then
        for k,v in pairs(menu.modeList) do
            if abs(x-v.x)+abs(y-v.y)<150 then
                menu.selectedMode=k
                print(menu.selectedMode)
            end
        end
    end
end
function menu.mouseR(x,y,button,istouch)
    if not BUTTON.release(x,y) then
        for k,v in pairs(menu.modeList) do
            if abs(x-v.x)+abs(y-v.y)<150 and k==menu.selectedMode then
                menu.lvl=2
                scene.switch({
                    dest='game',destScene=require'mino/game',
                    swapT=.7,outT=.3,
                    anim=function() anim.cover(.3,.4,.3,0,0,0) end
                })
                scene.sendArg=k
                menu.send=menu.gameSend
            end
        end
    end
end
local hv=''
function menu.update(dt)
    local msx,msy=adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    local n=false
    for k,v in pairs(menu.modeList) do
        if abs(msx-v.x)+abs(msy-v.y)<150 then n=true
            v.hoverT=min(v.hoverT+dt,.15)
            if k~=hv then
            scene.BG.setPolyColor(v.borderColor[1],v.borderColor[2],v.borderColor[3])
            hv=k
        end
        else v.hoverT=max(v.hoverT-dt,0) end
    end
    if (not n) and hv~='' then scene.BG.setPolyColor(1,1,1) hv='' end
    BUTTON.update(dt,msx,msy)
    flashT=max(flashT-dt,0) clickT=max(clickT-dt,0)
end

local cv=gc.newCanvas(300,300)
gc.setCanvas(cv)
gc.setColor(1,1,1)
gc.circle('fill',150,150,140,4)
gc.setCanvas()

local mt
local ts=.4
local w,h,c
function menu.draw()
    mt=menu.modeTxt
    for k,v in pairs(menu.modeList) do
        --local s=(abs(v.x)+abs(v.y)-150*(16*(scene.time-.125)))/150/2
        --if s<=0 then
        c=v.borderColor
        gc.setColor(c[1],c[2],c[3],.25+v.hoverT)
        gc.draw(cv,v.x,v.y,0,1,1,150,150)
        gc.setColor(c)
        gc.draw(menu.icon.border,v.x,v.y,0,1,1,150,150)
        --gc.setColor(1,1,1,1+s*.5)
        --gc.draw(menu.icon.border,v.x,v.y,0,1,1,150,150)
        gc.setColor(1,1,1)
        gc.draw(menu.icon[k],v.x,v.y,0,1,1,150,150)
        --end
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
    BUTTON.draw()
end
function menu.exit()
    local s=fs.newFile('player/unlocked')
    s:open('w')
    s:write(json.encode(menu.unlocked))
    s:close()
end
function menu.gameSend(destScene,arg)
    destScene.mode=arg
    destScene.exitScene='menu'
    print('success')
end
return menu