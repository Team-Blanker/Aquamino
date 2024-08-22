local cfk=user.lang.conf.keys

local BUTTON=scene.button

local keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}
local key={
    keySet={},
    keyName={},
    banned={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12', 'f17','f18',
        'tab','backspace',
        'audiomute','audioplay','volumeup','volumedown',
        'numlock','capslock','scrolllock',
        'printscreen'
    }
}
local M,T=mymath,mytable
function key.read()
    key.keySet={
        ML={'left'},MR={'right'},
        CW={'x'},CCW={'c'},flip={'d'},
        SD={'down'},HD={'up'},hold={'z'},
        R={'r'},pause={'escape','p'}
    }
    local keySet=file.read('conf/keySet')
    T.combine(key.keySet,keySet)

    for i=1,#keyName do
        if not key.keySet[keyName[i]] then key.keySet[keyName[i]]={} end
    end
    for k,v in pairs(key.keySet) do
        if not T.include(keyName,k) then v=nil end
    end
end
function key.save()
    file.save('conf/keySet',key.keySet)
end

function key.init()
    sfx.add({
        keyAdd='sfx/general/checkerOn.wav',
        keyRem='sfx/general/checkerOff.wav',
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/confSwitch.wav',
        choose='sfx/general/buttonChoose.wav',
    })

    cfk=user.lang.conf.keys

    key.read()
    key.order=nil

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
            gc.printf(user.lang.conf.test,font.Bender,0,0,1280,'center',0,.5,.5,640,72)
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
    BUTTON.create('virtualKey',{
        x=600,y=-420,type='rect',w=400,h=80,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(cfk.virtualKey,font.Bender_B,0,0,1280,'center',0,.4,.4,640,72)
        end,
        event=function()
            sfx.play('quit')
            scene.switch({
                dest='conf',destScene=require('scene/game conf/virtualKey'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
end
function key.keyP(k)
    if key.order then
        local K=key.keySet[keyName[key.order]]
        if k=='backspace' then key.keySet[keyName[key.order]]={}
        else local n=T.include(K,k)
            if n then table.remove(K,n) sfx.play('keyRem') elseif #K<3 then
                for o,v in pairs(key.keySet) do local include=T.include(v,k)
                    if include then table.remove(v,include) end
                end
                if not T.include(key.banned,k) then table.insert(K,k) sfx.play('keyAdd') end
            end
        end
    elseif k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function key.mouseP(x,y,button,istouch)
    if not (button==1 and BUTTON.press(x,y)) then
        if button==1 and (x>-800 and x<800 and y>-300 and y<300) then
            local o=ceil(y/100)+3+(x>0 and 6 or 0)
            key.order=o<=#keyName and o~=key.order and o or nil
            sfx.play('choose')
        else key.order=nil end
    end
end
function key.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
end
function key.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function key.draw()
    gc.setColor(1,1,1,.25)
    for i=0,5 do
        gc.rectangle('fill',-800,-300+100*i,200,100)
        gc.rectangle('fill',   0,-300+100*i,200,100)
    end
    gc.setColor(1,1,1,scene.time%.2<.1 and .25 or .125)
    if key.order then gc.rectangle('fill',key.order>6 and 200 or -600,(key.order-1)%6*100-300,600,100) end
    gc.setColor(1,1,1)
    gc.printf(user.lang.conf.main.keys,font.Bender,0,-430,1280,'center',0,1,1,640,72)
    gc.printf(cfk.info,font.JB,0,400,8000,'center',0,.3,.3,4000,192)
    for i=0,5 do
        if cfk.keyName[i+1] then gc.printf(cfk.keyName[i+1],font.Bender_B,-700,-250+100*i,2000,'center',0,cfk.kScale,cfk.kScale,1000,72) end
        if cfk.keyName[i+7] then gc.printf(cfk.keyName[i+7],font.Bender_B, 100,-250+100*i,2000,'center',0,cfk.kScale,cfk.kScale,1000,72) end
    end
    gc.setColor(.5,1,.875)
    for i=1,#keyName do local K=key.keySet[keyName[i]]
        for j=1,#K do
            gc.printf(K[j]:len()==1 and K[j]:upper() or K[j],
            font.JB,(i>6 and 100 or -700)+200*j,-300+100*((i-1)%6)+128*.4,2000,'center',0,.4,.4,1000,84)
        end
    end
    gc.setColor(.5,1,.875)
    gc.setLineWidth(4)
    for i=0,6 do gc.line(-800,-300+100*i,800,-300+100*i) end
    BUTTON.draw()
end

function key.exit()
    key.save()
end
function key.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/keys'
    destScene.modeInfo={mode='conf_test'}
    destScene.resetStopMusic=false
    end
end
return key