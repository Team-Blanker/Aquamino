local BUTTON=scene.button

local banned={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12', 'f17','f18',
'audiomute','audioplay','volumeup','volumedown',
'numlock','capslock','scrolllock',
'printscreen'
}
local intro={}
local logo=gc.newImage('assets/pic/logo.png')
local mode={
    {'40 lines','marathon','sandbox'},
    {'smooth','thunder','ice storm','master','multitasking'},
    {},
    {}
}
local unlocked={true,true,false,false}
local fl=gc.newCanvas(5,5)
do
    gc.setColor(1,1,1)
    gc.setCanvas(fl)
    for i=.5,4.5 do gc.points(i,.5) gc.points(i,4.5) end
    for i=.5,4.5 do gc.points(.5,i) gc.points(4.5,i) end
    gc.setCanvas()
end

local function edgeDraw(w,h,l)
    gc.rectangle('fill',-w/2,-h/2,w,l) gc.rectangle('fill',-w/2,h/2-l,w,l)
    gc.rectangle('fill',-w/2,-h/2,l,h) gc.rectangle('fill',w/2-l,-h/2,l,h)
end
local function btdraw(ch,w,h,o,t)
    if unlocked[o] then
        gc.setColor(COLOR.hsv(ch,.6,.6,intro.choose==o and .35 or .15)) gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(COLOR.hsv(ch,.6,.6,intro.choose==o and .75 or .2+.5*t)) gc.draw(fl,0,0,0,w/5,h/5,2.5,2.5)
    else gc.setColor(.5,.5,.5,.2) gc.rectangle('fill',-w/2,-h/2,w,h) end

    if unlocked[o] then gc.setColor(COLOR.hsv(ch,.5,.8,1)) else gc.setColor(.8,.8,.8) end
    edgeDraw(w,h,16)
end

function intro.init()
    intro.choose=0
    intro.lvl2animT=0
    intro.lvl=1
    scene.BG=require'BG/blank'
    if mus.path~='music/Hurt Record/Nine Five' then
        mus.add('music/Hurt Record/Nine Five','parts','mp3',61.847,224*60/130)
        mus.start()
    end
    intro.tip=require'mino/tips'
    intro.order=rand(#intro.tip)
    BUTTON.create('practice',{
        x=-1440,y=-270,type='rect',w=960,h=540,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            btdraw(3.5,w,h,1,t)
            gc.setColor(1,1,1)
            gc.printf(unlocked[1] and "练习" or "???",Exo_2_SB,0,0,1280,'center',0,.75,.75,640,84)
        end,
        event=function()
            if not unlocked[1] then return end
            intro.lvl=3 intro.choose=1
            scene.switch({
                dest='menu',swapT=.9,outT=.6,
                anim=function() anim.enter2(.4,.5,.6) end
            })
            function scene.cur.send(destScene)
                destScene.modelist=mytable.copy(mode[1])
                destScene.modeKey=1
                destScene.bgName='pond'
            end
        end,
        always=function(dt,bt)
            local v=min(intro.lvl2animT/.4,1)
            bt.x=-480-960*(1-v)*(1-v)
        end
    },.4)
    BUTTON.create('challenge',{
        x=1440,y=-270,type='rect',w=960,h=540,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            btdraw(2.5,w,h,2,t)
            gc.setColor(1,1,1)
            gc.printf(unlocked[2] and "挑战" or "???",Exo_2_SB,0,0,1280,'center',0,.75,.75,640,84)
        end,
        event=function()
            if not unlocked[2] then return end
            intro.lvl=3 intro.choose=2
            scene.switch({
                dest='menu',swapT=.9,outT=.6,
                anim=function() anim.enter2(.4,.5,.6) end
            })
            function scene.cur.send(destScene)
                destScene.modelist=mytable.copy(mode[2])
                destScene.modeKey=1
                destScene.bgName='radio'
            end
        end,
        always=function(dt,bt)
            local v=min(intro.lvl2animT/.4,1)
            bt.x=480+960*(1-v)*(1-v)
        end
    },.4)
    BUTTON.create('mystery',{
        x=-1440,y=270,type='rect',w=960,h=540,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            btdraw(2.5,w,h,3,t)
            gc.setColor(1,1,1)
            gc.printf(unlocked[3] and "秘境" or "???",Exo_2_SB,0,0,1280,'center',0,.75,.75,640,84)
        end,
        event=function()
            if not unlocked[3] then return end
            intro.lvl=3 intro.choose=3
            scene.switch({
                dest='menu',swapT=.9,outT=.6,
                anim=function() anim.enter2(.4,.5,.6) end
            })
            function scene.cur.send(destScene)
                destScene.modelist=mytable.copy(mode[3])
                destScene.modeKey=1
            end
        end,
        always=function(dt,bt)
            local v=min(intro.lvl2animT/.4,1)
            bt.x=-480-960*(1-v)*(1-v)
        end
    },.4)
    BUTTON.create('phun',{
        x=1440,y=270,type='rect',w=960,h=540,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            btdraw(2.5,w,h,4,t)
            gc.setColor(1,1,1)
            gc.printf(unlocked[4] and "理堂" or "???",Exo_2_SB,0,0,1280,'center',0,.75,.75,640,84)
        end,
        event=function()
            if not unlocked[4] then return end
            intro.lvl=3 intro.choose=4
            scene.switch({
                dest='menu',swapT=.9,outT=.6,
                anim=function() anim.enter2(.4,.5,.6) end
            })
            function scene.cur.send(destScene)
                destScene.modelist=mytable.copy(mode[1])
                destScene.modeKey=1
            end
        end,
        always=function(dt,bt)
            local v=min(intro.lvl2animT/.4,1)
            bt.x=480+960*(1-v)*(1-v)
        end
    },.4)
end

function intro.keyP(k)
    if intro.lvl==1 then
        if k=='escape' then love.event.quit()
        elseif not mytable.include(banned,k) then
            if win.stat.launch==1 and win.freshman then
                scene.switch({
                dest='game conf',destScene=require('scene/game conf/conf_main'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
                })
                function scene.cur.send()
                    scene.cur.exitScene='scene/intro'
                end
                win.freshman=false
            else intro.lvl=2 end
        end
    else if k=='escape' then intro.lvl=1 end end
end
function intro.mouseP(x,y,button,istouch)
    if intro.lvl==1 then
        intro.lvl=2
    else
        BUTTON.click(x,y,button,istouch)
    end
end
function intro.update(dt)
    --if intro.lvl==3 then intro.lvl2animT=.3
    if intro.lvl==2 then intro.lvl2animT=min(intro.lvl2animT+dt,.4)
    else intro.lvl2animT=max(0,intro.lvl2animT-dt) end

    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
local v
function intro.draw()
    v=intro.lvl2animT/.4
    gc.setColor(0,0,0,(intro.lvl==3 and 1 or v))
    gc.rectangle('fill',-1000,-600,2000,1200)
    if intro.lvl<3 then
        local w,h=logo:getPixelDimensions()
        gc.setColor(1,1,1)
        gc.draw(logo,0,-200+12*sin(scene.time/5%2*math.pi)-600*v*v,0,1600/w,1600/w,w/2,h/2)

        gc.setColor(1,1,1,1-v)
        gc.printf("Press any key to start",Exo_2,-57257,150,114514,'center',0,1,1)

        gc.printf(intro.tip[intro.order],Exo_2,0,450,114514,'center',0,.4,.4,57257,84)

        gc.setColor(1,1,1,.25-v*.25)
        gc.printf("Version : "..win.stat.version,Exo_2,-240,480,1600,'center',0,.3,.3)
    end

    BUTTON.draw()
end
--function intro.send() scene.cur.modename[1]="40行" end
return intro