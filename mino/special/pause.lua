local pause={}
local ptxt=user.lang.pause
function pause.init(mino)
    ptxt=user.lang.pause
    local mode=mino.mode
    pause.time=0
    local bt=fs.read('framework/control/button.lua')
    pause.button=assert(loadstring(bt))()
    pause.button.create('pause_resume',{
        x=0,y=-150,type='rect',w=600,h=100,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.5+2*t)
            gc.rectangle('fill',-300,-50,600,100)
            gc.setColor(1,1,1)
            gc.printf(ptxt.resume,Exo_2,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.cur.paused=false
        end
    },.25)
    pause.button.create('pause_retry',{
        x=0,y=0,type='rect',w=600,h=100,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.5+2*t)
            gc.rectangle('fill',-300,-50,600,100)
            gc.setColor(1,1,1)
            gc.printf(ptxt.r,Exo_2,0,0,1280,'center',0,.5,.5,640,84)
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
        x=0,y=150,type='rect',w=600,h=100,
        draw=function(bt,t)
            gc.setColor(.5,.5,.5,.5+2*t)
            gc.rectangle('fill',-300,-50,600,100)
            gc.setColor(1,1,1)
            gc.printf(ptxt.quit,Exo_2,0,0,1280,'center',0,.5,.5,640,84)
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