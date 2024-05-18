local m=user.lang.menu
local BUTTON=scene.button

local menu={modeKey=1}
local flashT,enterT,clickT=0,0,0
menu.modeList={
    --xy都是绘制坐标
    ['40 lines']={x=-300,y=0,borderColor={0,1,.75}},
    marathon={x=-150,y=150,borderColor={0,1,.75}},
    ['ice storm']={x=450,y=150,borderColor={0,1,1}},
    thunder={x=-300,y=-300,borderColor={0,1,1}},
    smooth={x=-450,y=150,borderColor={0,1,1}},
    levitate={x=-450,y=-150,borderColor={0,1,1}},
    master={x=-300,y=300,borderColor={1,.25,.25}},
    multitasking={x=0,y=300,borderColor={1,.25,.25}},
    sandbox={x=300,y=0,borderColor={.6,.6,.6}},
    ['dig 40']={x=-150,y=-150,borderColor={0,1,.75}},
    laser={x=450,y=-150,borderColor={0,1,1}},
}
for k,v in pairs(menu.modeList) do
    v.hoverT=0
end
menu.icon={
    border=gc.newImage('pic/mode icon/border.png')
}
for k,v in pairs(menu.modeList) do
    menu.icon[k]=gc.newImage('pic/mode icon/'..k..'.png')
end
function menu.init()
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
        menu.modeTxt[k]=gc.newText(font.Exo_2,v)
    end
    menu.lvl=1
    menu.rCount=0

    BUTTON.create('setting',{
        x=-800,y=-400,type='rect',w=150,h=150,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-75,-75,150,150)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.rectangle('line',-75,-75,150,150)
            gc.setColor(1,1,1)
            gc.setLineWidth(8)
            gc.setColor(1,1,1)
            gc.circle('line',0,0,50,6)
            gc.setColor(1,1,1,(1-t*5))
            gc.circle('line',0,0,22.5)
            gc.setColor(1,1,1,(t*5))
            gc.line(36,0,18,-18*3^.5) gc.line(-36,0,-18,-18*3^.5) gc.line(-18,18*3^.5,18,18*3^.5)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
            function menu.send(destScene)
                destScene.exitScene='scene/menu'
            end
        end
    },.2)
    BUTTON.create('quit',{
        x=-800,y=400,type='rect',w=150,h=150,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            scene.switch({
                dest='intro',swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('about',{
        x=800,y=-400,type='rect',w=150,h=150,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.circle('fill',0,-37.5,12.5,4)
            gc.rectangle('fill',-6,-5,12,55)
        end,
        event=function()
            scene.switch({
                dest='about',swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
        end
    },.2)
end
function menu.keyP(k)
    if k=='r' then
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
    if not BUTTON.click(x,y,button,istouch) then local len,l=#menu.modeList,1920/#menu.modeList
        for k,v in pairs(menu.modeList) do
            if abs(x-v.x)+abs(y-v.y)<=150 then
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
function menu.update(dt)
    local msx,msy=adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    for k,v in pairs(menu.modeList) do
        if abs(msx-v.x)+abs(msy-v.y)<=150 then
            v.hoverT=min(v.hoverT+dt,.15)
        else v.hoverT=max(v.hoverT-dt,0) end
    end
    BUTTON.update(dt,msx,msy)
    flashT=max(flashT-dt,0) clickT=max(clickT-dt,0)
end

local cv=gc.newCanvas(300,300)
gc.setCanvas(cv)
gc.setColor(1,1,1)
gc.circle('fill',150,150,140,4)
gc.setCanvas()
function menu.draw()
    for k,v in pairs(menu.modeList) do
        --local s=(abs(v.x)+abs(v.y)-150*(16*(scene.time-.125)))/150/2
        --if s<=0 then
        local c=v.borderColor
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