local BUTTON=scene.button
local sfxList={
    confEnter='sfx/general/confSwitch.wav',
    click='sfx/general/buttonClick.wav',
    quit='sfx/general/buttonQuit.wav',
}
local config={}
config.txt={title={},audio={},video={},custom={},handling={},keys={},test={}}
local tt
function config.init()
    sfx.add(sfxList)

    scene.BG=require'BG/settings'
    if not scene.BG.time then scene.BG.init() end

    local cf=user.lang.conf
    local cfm=cf.main
    local arcs,arcf=math.pi/2,5*math.pi/2

    config.posList={
        audio=0,video=0,custom=0,ctrl=0,keys=0
    }
    config.clrList={}

    tt=config.txt.title
    local ct=config.txt
    for k,v in pairs(config.txt) do
        v.txt=gc.newText(font.Bender,cfm[k])
        v.w,v.h=v.txt:getWidth(),v.txt:getHeight()
        v.s=min(.75,(k=='title' and 450 or 400)/v.w)
    end
    ct.test={}
    ct.test.txt=gc.newText(font.Bender,cf.test)
    ct.test.w,ct.test.h=ct.test.txt:getWidth(),ct.test.txt:getHeight()
    ct.test.s=min(.75,240/ct.test.w)

    BUTTON.create('quit',{
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
            sfx.play('quit')
            if scene.cur.exitScene and scene.cur.exitScene~='scene/menu' then
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
    BUTTON.create('test',{
        x=675,y=225*3^.5,type='circle',r=150,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.test.txt,0,0,0,ct.test.s,ct.test.s,ct.test.w/2,ct.test.h/2)
        end,
        event=function()
            sfx.play('click')
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)

    BUTTON.create('keys',{
        x=250,y=250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.25,.5,.4375,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.44,.88,.77)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.keys.txt,0,0,0,ct.keys.s,ct.keys.s,ct.keys.w/2,ct.keys.h/2)
        end,
        event=function()
            sfx.play('confEnter')
            scene.switch({
                dest='menu',destScene=require('scene/game conf/keys'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('handling',{
        x=500,y=0,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.125,.25,.5,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.3,.6,.9)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.handling.txt,0,0,0,ct.handling.s,ct.handling.s,ct.handling.w/2,ct.handling.h/2)
        end,
        event=function()
            sfx.play('confEnter')
            scene.switch({
                dest='menu',destScene=require('scene/game conf/handling'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('language',{
        x=250,y=-250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.5,.125,.375,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.88,.22,.66)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(win.UI.lang,0,0,0,1.5,1.5,50,50)
        end,
        event=function()
            sfx.play('confEnter')
            scene.switch({
                dest='language',destScene=require('scene/game conf/language'),
                swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)

    BUTTON.create('audio',{
        x=-250,y=-250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.5,.125,.125,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.88,.22,.33)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.audio.txt,0,0,0,ct.audio.s,ct.audio.s,ct.audio.w/2,ct.audio.h/2)
        end,
        event=function()
            sfx.play('confEnter')
            scene.switch({
                dest='menu',destScene=require('scene/game conf/audio'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('video',{
        x=-500,y=0,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.5,.375,.125,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.88,.66,.22)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.video.txt,0,0,0,ct.video.s,ct.video.s,ct.video.w/2,ct.video.h/2)
        end,
        event=function()
            sfx.play('confEnter')
            scene.switch({
                dest='menu',destScene=require('scene/game conf/video'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('custom',{
        x=-250,y=250*3^.5,type='circle',r=250,
        draw=function(bt,t)
            gc.setColor(.15,.5,.125,.3+t)
            gc.arc('fill',0,0,bt.r,arcs,arcf,6)
            gc.setColor(.28,.88,.22)
            gc.setLineWidth(9)
            gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
            gc.setColor(1,1,1)
            gc.draw(ct.custom.txt,0,0,0,ct.custom.s,ct.custom.s,ct.custom.w/2,ct.custom.h/2)
        end,
        event=function()
            sfx.play('confEnter')
            scene.switch({
                dest='menu',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
end
function config.keyP(k)
    if k=='escape' then
    if scene.cur.exitScene and scene.cur.exitScene~='scene/menu' then
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
end
function config.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) then end
end
function config.mouseR(x,y,button,istouch)
    if not BUTTON.release(x,y) then end
end
--function AnV.mouseR(x,y,button,istouch)
--end
function config.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function config.draw()
    gc.setColor(1,1,1)
    gc.draw(tt.txt,0,0,0,tt.s,tt.s,tt.w/2,tt.h/2)
    BUTTON.draw()
end
function config.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/conf_main'
    destScene.modeInfo={mode='conf_test'}
    destScene.resetStopMusic=false
    end
end
return config