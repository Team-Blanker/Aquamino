local BUTTON=scene.button
local config={}
function config.init()
        scene.BG=require'BG/settings' if not scene.BG.time then scene.BG.init() end
        local cf=user.lang.conf
    local cfm=cf.main
    local arcs,arcf=math.pi/2,5*math.pi/2

    config.posList={
        audio=0,video=0,custom=0,ctrl=0,keys=0
    }
    config.clrList={}
    config.txtList={} local ct=config.txtList
    for k,v in pairs(cfm) do
        ct[k]={}
        local t=ct[k]
        t.txt=gc.newText(font.Bender,v)
        t.w,t.h=t.txt:getWidth(),t.txt:getHeight()
    end
    ct.test={}
    ct.test.txt=gc.newText(font.Bender,cf.test)
    ct.test.w,ct.test.h=ct.test.txt:getWidth(),ct.test.txt:getHeight()
    scene.button.create('quit',{
        x=-675,y=225*3^.5,type='circle',r=150,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1.25,1.25,60,35)
        end,
        event=function()
            print(scene.cur.exitScene)
            if scene.cur.exitScene~='scene/menu' then
            scene.switch({
                dest=scene.cur.exitScene,destScene=require(scene.cur.exitScene),swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
            else
            scene.switch({
                dest='menu',destScene=require'scene/menu',swapT=.3,outT=.2,
                anim=function() anim.enterDR(.2,.1,.2) end
            })
            end
        end
    },.2)
    scene.button.create('test',{
        x=675,y=225*3^.5,type='circle',r=150,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.test.txt,0,0,0,.75,.75,ct.test.w/2,ct.test.h/2)
        end,
        event=function()
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)

    scene.button.create('keys',{
        x=250,y=250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.25,.5,.4375,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.5,1,.875)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.printf(cfm.keys,font.Bender,0,0,1280,'center',0,.75,.75,640,72)
        end,
        event=function()
            scene.switch({
                dest='menu',destScene=require('scene/game conf/keys'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    scene.button.create('ctrl',{
        x=500,y=0,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.125,.25,.5,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.25,.5,1)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.printf(cfm.ctrl,font.Bender,0,0,1280,'center',0,.75,.75,640,72)
        end,
        event=function()
            scene.switch({
                dest='menu',destScene=require('scene/game conf/handling'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    scene.button.create('language',{
        x=250,y=-250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.5,.125,.375,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,.25,.75)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(win.UI.lang,0,0,0,1.5,1.5,50,50)
        end,
        event=function()
            scene.switch({
                dest='language',destScene=require('scene/game conf/language'),
                swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)

    scene.button.create('audio',{
        x=-250,y=-250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.5,.125,.125,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,.25,.25)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.printf(cfm.audio,font.Bender,0,0,1280,'center',0,.75,.75,640,72)
        end,
        event=function()
            scene.switch({
                dest='menu',destScene=require('scene/game conf/audio'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    scene.button.create('video',{
        x=-500,y=0,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.5,.375,.125,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,.75,.25)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.printf(cfm.video,font.Bender,0,0,1280,'center',0,.75,.75,640,72)
        end,
        event=function()
            scene.switch({
                dest='menu',destScene=require('scene/game conf/video'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    scene.button.create('custom',{
        x=-250,y=250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.15,.5,.125,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.3,1,.25)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.printf(cfm.custom,font.Bender,0,0,1280,'center',0,.75,.75,640,72)
        end,
        event=function()
            scene.switch({
                dest='menu',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
end
function config.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y,button,istouch) then end
end
function config.mouseR(x,y,button,istouch)
    if not BUTTON.release(x,y,button,istouch) then end
end
--function AnV.mouseR(x,y,button,istouch)
--end
function config.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function config.draw()
    gc.setColor(1,1,1)
    gc.printf(user.lang.conf.main.title,font.Bender_B,0,0,1280,'center',0,.75,.75,640,72)
    BUTTON.draw()
end
function config.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/conf_main'
    destScene.mode='conf_test'
    destScene.resetStopMusic=false
    end
end
return config