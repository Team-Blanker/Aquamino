local others={}
local BUTTON,SLIDER=scene.button,scene.slider
function others.read()
end
function others.save()
end
function others.init()
    scene.BG=require'BG/space' scene.BG.init()
    others.read()

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h,6)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h,6)
            gc.setColor(1,1,1)
            gc.printf("返回",Exo_2_SB,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.cover(.1,.05,.1,0,0,0) end
            })
        end
    })
end
function others.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function others.mouseR(x,y,button,istouch)

end
function others.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)) end
end
function others.draw()
    gc.setColor(1,1,1)
    gc.printf("其它设置",SYHT,0,-460,1280,'center',0,1,1,640,64)
    gc.printf("暂无内容",SYHT,0,-66,1280,'center',0,1,1,640,64)
    BUTTON.draw() SLIDER.draw()
end
function others.exit()
    others.save()
end
return others