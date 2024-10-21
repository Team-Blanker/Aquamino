local cfh=user.lang.conf.boardSet

local hand={}
local BUTTON,SLIDER=scene.button,scene.slider
local T=mytable
function hand.read()
    hand.ctrl={ASD=.15,ASP=.03,SD_ASD=0,SD_ASP=.05}
    local info=file.read('conf/ctrl')
    T.combine(hand.ctrl,info)  
end
function hand.save()
    file.save('conf/ctrl',hand.ctrl)
end
hand.txt={
    ASD={},ASP={},SD_ASD={},SD_ASP={}
}
hand.titleTxt={txt=gc.newText(font.Bender)}
local tt
function hand.init()
    sfx.add({
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/confSwitch.wav',
    })

    tt=hand.titleTxt
    tt.txt:clear()
    tt.txt:add(user.lang.conf.main.handling)
    tt.w,tt.h=tt.txt:getDimensions()
    tt.s=min(600/tt.w,1)

    cfh=user.lang.conf.handling
    hand.read()

    for k,v in pairs(hand.txt) do
        v.txt=gc.newText(font.JB,cfh[k])
        v.w,v.h=v.txt:getDimensions()
        v.s=min(700/v.w,.3125)
        v.ow=min(700,v.w*.3125)
        v.numTxt=gc.newText(font.JB)
    end

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
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    scene.button.create('test',{
        x=700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(user.lang.conf.test,font.Bender,0,0,1280,'center',0,.5,.5,640,font.height.Bender/2)
        end,
        event=function()
            sfx.play('click')
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
            scene.sendArg='game conf/handling'
        end
    },.2)

    SLIDER.create('ASD',{
        x=-380,y=-250,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.ASD/.2,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=hand.txt.ASD
            gc.draw(v.txt,-520,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.0fms,%5.2fF",hand.ctrl.ASD*1000,hand.ctrl.ASD*60))
            gc.draw(v.numTxt,-520+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            hand.ctrl.ASD=.2*pos
        end
    })
    SLIDER.create('ASP',{
        x=-380,y=-125,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.ASP/.1,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=hand.txt.ASP
            gc.draw(v.txt,-520,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.0fms,%5.2fF",hand.ctrl.ASP*1000,hand.ctrl.ASP*60))
            gc.draw(v.numTxt,-520+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            hand.ctrl.ASP=.1*pos
        end
    })
    SLIDER.create('SD_ASD',{
        x=-380,y=0,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.SD_ASD/.2,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=hand.txt.SD_ASD
            gc.draw(v.txt,-520,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.0fms,%5.2fF",hand.ctrl.SD_ASD*1000,hand.ctrl.SD_ASD*60))
            gc.draw(v.numTxt,-520+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            hand.ctrl.SD_ASD=.2*pos
        end
    })
    SLIDER.create('SD_ASP',{
        x=-380,y=125,type='hori',sz={1000,32},button={32,32},
        gear=0,pos=hand.ctrl.SD_ASP/.1,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=hand.txt.SD_ASP
            gc.draw(v.txt,-520,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.0fms,%5.2fF",hand.ctrl.SD_ASP*1000,hand.ctrl.SD_ASP*60))
            gc.draw(v.numTxt,-520+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            hand.ctrl.SD_ASP=.1*pos
        end
    })
end
function hand.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function hand.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and SLIDER.mouseP(x,y,button,istouch) then end
end
function hand.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
end
function hand.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function hand.draw()
    gc.setColor(1,1,1)
    gc.draw(tt.txt,0,-510,0,tt.s,tt.s,tt.w/2,0)
    BUTTON.draw() SLIDER.draw()
end
function hand.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/handling'
    destScene.modeInfo={mode='conf_test'}
    destScene.resetStopMusic=false
    end
end
function hand.exit()
    hand.save()
end
return hand