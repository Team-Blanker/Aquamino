local cfcs=user.lang.conf.boardSet

local bb={}
local BUTTON,SLIDER=scene.button,scene.slider
local T=mytable
function bb.read()
    bb.boardBounce={
        moveForce=0,
        dropVel=0,

        spinAngvel=0,

        velDamping=40,
        angDamping=30,

        elasticFactor=800,
        spinFactor=400,
        clearFactor=.8,

        level=0,custom=false
    }
    local info=file.read('conf/board bounce')
    T.combine(bb.boardBounce,info)
end
function bb.save()
    file.save('conf/board bounce',bb.boardBounce)
end
bb.txt={
moveForce={},
dropVel={},
clearFactor={},
velDamping={},
elasticFactor={},

spinAngvel={},
angDamping={},
spinFactor={},
}
bb.titleTxt={txt=gc.newText(font.Bender)}
local tt
function bb.init()
    sfx.add({
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/confSwitch.wav',
    })

    cfcs=user.lang.conf.custom.boardSet

    tt=bb.titleTxt
    tt.txt:clear()
    tt.txt:add(cfcs.title)
    tt.w,tt.h=tt.txt:getDimensions()
    tt.s=min(400/tt.w,.8)

    bb.read()

    for k,v in pairs(bb.txt) do
        v.txt=gc.newText(font.JB,cfcs[k])
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
                dest='conf',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
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

    SLIDER.create('moveForce',{
        x=-480,y=-240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.moveForce/100,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.moveForce
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%6.2f",bb.boardBounce.moveForce))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.moveForce=100*pos
        end
    })
    SLIDER.create('dropVel',{
        x=-480,y=-80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.dropVel/20,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.dropVel
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%5.2f",bb.boardBounce.dropVel))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.dropVel=20*pos
        end
    })
    SLIDER.create('velDamping',{
        x=-480,y=80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.velDamping<1e-2 and 0 or (math.log(bb.boardBounce.velDamping,10)+2)/5,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.velDamping
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.2e",bb.boardBounce.velDamping))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.velDamping=pos==0 and 0 or 10^(pos*5-2)
        end
    })
    SLIDER.create('elasticFactor',{
        x=-480,y=240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.elasticFactor<1e-1 and 0 or (math.log(bb.boardBounce.elasticFactor,10)+1)/5,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.elasticFactor
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.2e",bb.boardBounce.elasticFactor))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.elasticFactor=10^(pos*5-1)
        end
    })
    SLIDER.create('clearFactor',{
        x=480,y=-240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.clearFactor/10,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.clearFactor
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%5.2f",bb.boardBounce.clearFactor))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.clearFactor=pos*10
        end
    })

    SLIDER.create('spinAngvel',{
        x=480,y=-80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.spinAngvel/50,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.spinAngvel
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%5.2f",bb.boardBounce.spinAngvel))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.spinAngvel=50*pos
        end
    })
    SLIDER.create('angDamping',{
        x=480,y=80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.angDamping<1e-2 and 0 or (math.log(bb.boardBounce.angDamping,10)+2)/5,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.angDamping
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.2e",bb.boardBounce.angDamping))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.angDamping=pos==0 and 0 or 10^(pos*5-2)
        end
    })
    SLIDER.create('spinFactor',{
        x=480,y=240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=bb.boardBounce.spinFactor<1e-1 and 0 or (math.log(bb.boardBounce.spinFactor,10)+1)/5,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.spinFactor
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(string.format(":%3.2e",bb.boardBounce.spinFactor))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bb.boardBounce.spinFactor=10^(pos*5-1)
        end
    })
end
function bb.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function bb.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and SLIDER.mouseP(x,y,button,istouch) then end
end
function bb.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
end
function bb.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function bb.draw()
    gc.setColor(1,1,1)
    gc.draw(tt.txt,-640,-480,0,tt.s,tt.s,tt.w/2,0)
    BUTTON.draw() SLIDER.draw()
end
function bb.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/handling'
    destScene.modeInfo={mode='conf_test'}
    destScene.resetStopMusic=false
    end
end
function bb.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/board bounce'
    destScene.modeInfo={mode='conf_test'}
    destScene.resetStopMusic=false
    end
end
function bb.exit()
    bb.save()
end
return bb