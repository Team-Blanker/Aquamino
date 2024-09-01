local lang={}
local BUTTON,SLIDER=scene.button,scene.slider
local langList={'English','zh-s','zh-t','Italian'}
function lang.read()
    lang.uage=file.read('conf/lang')
    if not mytable.include(langList,lang.uage[1]) then lang.uage[1]='English' end
    user.langName=lang.uage[1]
    user.lang=require('language/'..user.langName)
end
function lang.save()
    file.save('conf/lang',lang.uage)
end
function lang.init()
    sfx.add({
        click='sfx/general/buttonChoose.wav',
        quit='sfx/general/confSwitch.wav',
    })

    lang.read()

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
    BUTTON.create('zh-s',{
        x=-240,y=-100,type='rect',w=360,h=100,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.6,.4,.4,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.9,.6,.6)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf("简体中文",font.Bender,0,0,1280,'center',0,.5,.5,640,72)
            gc.setColor(.9,.75,.6,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
        end,
        event=function()
            sfx.play('click')
            lang.uage[1],user.langName="zh-s","zh-s"
            user.lang=require('language/'..user.langName)
        end
    },.2)
    BUTTON.create('zh-t',{
        x=240,y=-100,type='rect',w=360,h=100,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.6,.5,.4,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.9,.75,.6)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf("繁體中文",font.Bender,0,0,1280,'center',0,.5,.5,640,72)
            gc.setColor(.9,.75,.6,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
        end,
        event=function()
            sfx.play('click')
            lang.uage[1],user.langName="zh-t","zh-t"
            user.lang=require('language/'..user.langName)
        end
    },.2)
    BUTTON.create('English',{
        x=-240,y=100,type='rect',w=360,h=100,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.4,.5,.6,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.6,.75,.9)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf("English",font.Bender,0,0,1280,'center',0,.5,.5,640,72)
            gc.setColor(.6,.75,.9,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
        end,
        event=function()
            sfx.play('click')
            lang.uage[1],user.langName="English","English"
            user.lang=require('language/'..user.langName)
        end
    },.2)
    BUTTON.create('Italian',{
        x= 240,y=100,type='rect',w=360,h=100,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.6,.4,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.75,.9,.6)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf("Italiano",font.Bender,0,0,1280,'center',0,.5,.5,640,72)
            gc.setColor(.6,.75,.9,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
        end,
        event=function()
            sfx.play('click')
            lang.uage[1],user.langName="Italian","Italian"
            user.lang=require('language/'..user.langName)
        end
    },.2)
end
function lang.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function lang.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and SLIDER.mouseP(x,y,button,istouch) then end
end
function lang.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
end
function lang.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)) end
end
function lang.draw()
    gc.setColor(1,1,1)
    gc.printf("语言/Language/Lingua",font.Bender,0,-430,6000,'center',0,1,1,3000,72)
    gc.printf(user.lang.conf.lang.cur,font.Bender,0,-280,5000,'center',0,.5,.5,2500,72)
    BUTTON.draw() SLIDER.draw()
end
function lang.exit()
    lang.save()
end
return lang