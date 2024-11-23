local BUTTON=scene.button

local clock={}
local tau=2*math.pi

local time

local quitButton={
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
}
local sfxList={
    click='sfx/general/buttonChoose.wav',
    quit='sfx/general/confSwitch.wav',
}

function clock.init()
    scene.BG=require('BG/blank')
    time=os.date('*t')

    sfx.add(sfxList)
    BUTTON.create('quit',quitButton,.2)
end

function clock.mouseP(x,y,button,istouch)
    BUTTON.press(x,y)
end
function clock.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
end

function clock.update(dt)
    time=os.date('*t')
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function clock.draw()
    local h,m,s=time.hour,time.min,time.sec
    local timetxt=string.format('%02d:%02d:%02d',h,m,s)

    gc.setLineWidth(4)--秒针
    gc.line(0,0,sin(tau*s/60)*400,-cos(tau*s/60)*400)
    gc.setLineWidth(8)--分针
    gc.line(0,0,sin(tau*(m+s/60)/60)*360,-cos(tau*(m+s/60)/60)*360)
    gc.setLineWidth(12)--时针
    gc.line(0,0,sin(tau*(h+m/60+s/3600)/12)*256,-cos(tau*(h+m/60+s/3600)/12)*256)
    gc.circle('line',0,0,500,24)
    gc.circle('fill',0,0,15)

    gc.setColor(.5,1,.875)
    gc.printf(timetxt,font.JB,0,-200,1000,'center',0,.75,.75,500,font.height.JB/2)

    BUTTON.draw()
end
function clock.keyP(k)
end
return clock