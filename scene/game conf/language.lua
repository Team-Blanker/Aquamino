local lang={}
local BUTTON,SLIDER=scene.button,scene.slider
function lang.read()
    lang.uage={'English'}
    if fs.getInfo('conf/lang') then
        mytable.combine(lang.uage,json.decode(fs.newFile('conf/lang'):read()))
    end
    user.langName=lang.uage[1]
    user.lang=require('language/'..user.langName)
end
function lang.save()
    local s=fs.newFile('conf/lang')
    s:open('w')
    s:write(json.encode(lang.uage))
end
function lang.init()
    scene.BG=require'BG/space' scene.BG.init()
    lang.read()

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.cover(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('zh-CN',{
        x=-400,y=0,type='rect',w=640,h=150,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.6,.5,.4,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.9,.75,.6)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf("简体中文",font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
            gc.setColor(.9,.75,.6,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160,6+ct*80)
        end,
        event=function()
            lang.uage[1],user.langName="zh-CN","zh-CN"
            user.lang=require('language/'..user.langName)
        end
    },.2)
    BUTTON.create('English',{
        x=400,y=0,type='rect',w=640,h=150,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.4,.5,.6,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.6,.75,.9)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf("English",font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
            gc.setColor(.6,.75,.9,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160,6+ct*80)
        end,
        event=function()
            lang.uage[1],user.langName="English","English"
            user.lang=require('language/'..user.langName)
        end
    },.2)
end
function lang.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function lang.mouseR(x,y,button,istouch)

end
function lang.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)) end
end
function lang.draw()
    gc.setColor(1,1,1)
    gc.printf("语言/Language",font.Exo_2,0,-460,1280,'center',0,1,1,640,84)
    gc.printf(user.lang.conf.lang.cur,font.Exo_2,0,-300,5000,'center',0,.5,.5,2500,84)
    BUTTON.draw() SLIDER.draw()
end
function lang.exit()
    lang.save()
end
return lang