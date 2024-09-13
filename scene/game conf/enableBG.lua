local cfeb=user.lang.conf.enableBG

local BUTTON=scene.button

local M,T=mymath,mytable

local modeList={
    '40 lines','marathon','dig 40','backfire','battle',
    'ice storm','thunder','smooth','levitate','laser',
    'master','multitasking',
    'sandbox',
    'tower defense'
}
local ebg={}
function ebg.read()
    ebg.enableList={
        ['40 lines']=true,
        marathon=true,
        ['ice storm']=true,
        thunder=true,
        smooth=true,
        levitate=true,
        master=true,
        multitasking=true,
        sandbox=true,
        ['dig 40']=true,
        laser=true,
        battle=true,
        ['tower defense']=true,
        backfire=true,
        conf_test=true,
        idea_test=true
    }
    ebg.enableList=file.read('conf/enableBG')
    for k,v in pairs(modeList) do
        if ebg.enableList[v]==nil then ebg.enableList[v]=true end
    end
end
function ebg.save()
    file.save('conf/enableBG',ebg.enableList)
end

function ebg.init()
    sfx.add({
        keyAdd='sfx/general/checkerOn.wav',
        keyRem='sfx/general/checkerOff.wav',
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/confSwitch.wav',
        choose='sfx/general/buttonChoose.wav',
    })

    cfk=user.lang.conf.keys

    ebg.read()

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
                dest='conf',destScene=require('scene/game conf/video'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
end
function ebg.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/video'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function ebg.mouseP(x,y,button,istouch)
    if not (button==1 and BUTTON.press(x,y)) then
    end
end
function ebg.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
end
function ebg.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function ebg.draw()
    BUTTON.draw()
end
function ebg.exit()
    ebg.save()
end
return ebg