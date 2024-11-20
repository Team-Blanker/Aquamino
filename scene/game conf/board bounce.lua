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
presetLevel={},

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

local preset={
    [0]={
        moveForce=0,
        dropVel=0,

        spinAngvel=0,

        velDamping=40,
        angDamping=30,

        elasticFactor=500,
        spinFactor=1000,
        clearFactor=.8,
    },
    [1]={
        moveForce=3,
        dropVel=.2,

        spinAngvel=4,

        velDamping=30,
        angDamping=200,

        elasticFactor=500,
        spinFactor=1000,
        clearFactor=.8,
    },
    [2]={
        moveForce=10,
        dropVel=.5,

        spinAngvel=10,

        velDamping=30,
        angDamping=200,

        elasticFactor=500,
        spinFactor=1000,
        clearFactor=.8,
    },
    [3]={
        moveForce=12.5,
        dropVel=.8,

        spinAngvel=10,

        velDamping=30,
        angDamping=100,

        elasticFactor=500,
        spinFactor=750,
        clearFactor=.8,
    },
    [4]={
        moveForce=15,
        dropVel=1.25,

        spinAngvel=12,

        velDamping=30,
        angDamping=80,

        elasticFactor=400,
        spinFactor=750,
        clearFactor=.9,
    },
    [5]={
        moveForce=20,
        dropVel=1.6,

        spinAngvel=15,

        velDamping=30,
        angDamping=80,

        elasticFactor=300,
        spinFactor=750,
        clearFactor=1,
    },
    [6]={
        moveForce=45,
        dropVel=1.25,

        spinAngvel=25,

        velDamping=8,
        angDamping=50,

        elasticFactor=24,
        spinFactor=50,
        clearFactor=1.5,
    },
}
local sliderList={
    level={
        x=200,y=-400,type='hori',sz={960,32},button={32,32},
        gear=7,pos=0,
        setPosWithValue=function (v)
            return v
        end,
        sliderDraw=function(g,sz,sl)
            gc.setColor(.24,.48,.42,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/3,-8,sz[1]/3+8,0,sz[1]/3,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local v=bb.txt.presetLevel
            gc.draw(v.txt,-sz[1]/2-20,-24,0,v.s,v.s,0,v.h)
            v.numTxt:clear()
            v.numTxt:add(bb.boardBounce.custom and ":-" or string.format(":%d",sl.pos))
            gc.draw(v.numTxt,-sz[1]/2-20+v.ow,-24,0,.3125,.3125,0,v.h)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        release=function(pos)
            bb.boardBounce.level=pos
            for k,v in pairs(preset[pos]) do
                bb.boardBounce[k]=v
                SLIDER.setPosWithValue(k,bb.boardBounce[k])
            end
        end,
        click=function ()
            bb.boardBounce.custom=false
        end
    },
    moveForce={
        x=-480,y=-240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return v/100
        end,
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
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },
    dropVel={
        x=-480,y=-80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return (v/20)^.5
        end,
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
            bb.boardBounce.dropVel=20*pos^2
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },
    velDamping={
        x=-480,y=80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return v<1e-2 and 0 or (math.log(v,10)+2)/5
        end,
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
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },
    elasticFactor={
        x=-480,y=240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return v<1e-1 and 0 or (math.log(v,10)+1)/5
        end,
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
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },
    clearFactor={
        x=480,y=-240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return v/10
        end,
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
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },

    spinAngvel={
        x=480,y=-80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return (v/50)^.5
        end,
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
            bb.boardBounce.spinAngvel=50*pos^2
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },
    angDamping={
        x=480,y=80,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return v<1e-2 and 0 or (math.log(v,10)+2)/5
        end,
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
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    },
    spinFactor={
        x=480,y=240,type='hori',sz={800,32},button={32,32},
        gear=0,pos=0,
        setPosWithValue=function (v)
            return v<1e-1 and 0 or (math.log(v,10)+1)/5
        end,
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
        end,
        click=function ()
            bb.boardBounce.custom=true
        end
    }
}
local tt
function bb.init()
    scene.BG=require'BG/settings'

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

    for k,v in pairs(sliderList) do SLIDER.create(k,v)
        if bb.boardBounce[k] then SLIDER.setPosWithValue(k,bb.boardBounce[k]) end
    end
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