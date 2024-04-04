local pause={}
local ptxt=user.lang.pause
local max,min=math.max,math.min
function pause.init(mino)
    ptxt=user.lang.pause
    local mode=mino.mode
    pause.time=0
    local butt=fs.read('framework/control/button.lua')
    pause.button=assert(loadstring(butt))()
    pause.button.create('pause_resume',{
        x=-600,y=420,type='rect',w=400,h=100,
        draw=function(bt,t)
            gc.setColor(.75,.75,.75,.5+min(2*t,.3))
            gc.rectangle('fill',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.setLineWidth(3)
            gc.rectangle('line',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.printf(ptxt.resume,font.Exo_2,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.cur.paused=false
            if mino.rule.pause then mino.rule.pause(mino.stacker,mino.paused) end
        end
    },.25)
    pause.button.create('pause_retry',{
        x=0,y=420,type='rect',w=400,h=100,
        draw=function(bt,t)
            gc.setColor(.75,.75,.75,.5+min(2*t,.3))
            gc.rectangle('fill',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.setLineWidth(3)
            gc.rectangle('line',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.printf(ptxt.r,font.Exo_2,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.dest='solo' scene.destScene=require'mino/game'
            scene.swapT=.7 scene.outT=.3
            scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end
            if scene.cur.resetStopMusic then mus.stop() end
            --function scene.cur.send(scene) scene.mode=mode end
        end
    },.25)
    pause.button.create('pause_quit',{
        x=600,y=420,type='rect',w=400,h=100,
        draw=function(bt,t)
            gc.setColor(.75,.75,.75,.5+min(2*t,.3))
            gc.rectangle('fill',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.setLineWidth(3)
            gc.rectangle('line',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.printf(ptxt.quit,font.Exo_2,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.dest=mino.exitScene or 'menu'
            scene.swapT=.7 scene.outT=.3
            scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end
        end
    },.25)
end
function pause.mouseP(x,y,button,istouch)
    pause.button.click(x,y,button,istouch)
end
function pause.update(dt)
    pause.time=pause.time+dt
    pause.button.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function pause.draw()
    pause.button.draw()
end
function pause.exit() end
return pause