local warn={}
local logo=gc.newImage('pic/assets/Team Blanker.png')
function warn.init()
    scene.BG=require'BG/blank'
end
function warn.switch()
    scene.switch({
        dest='intro',swapT=.6,outT=.2,
        anim=function() anim.cover(.2,.4,.2,0,0,0) end
    })
end
function warn.keyP(k)
    if k=='escape' then love.event.quit() else warn.switch() end
end
function warn.mouseP(x,y,button,istouch)
    warn.switch()
end

local w
function warn.draw()
    w=user.lang.warning
    gc.clear(.04,.04,.04)

    gc.setColor(1,1,1,min(2*scene.time-.5,1)*.2)
    gc.draw(logo,0,0,0,1,1,600,600)
    gc.setColor(1,1,1,2*scene.time-.5)
    gc.printf(w.title,font.Bender_B,0,-300,3000,'center',0,.6,.6,1500,72)
    gc.setColor(.5,1,.875,2*scene.time-.5)
    gc.printf(w.txt,font.Bender,0,-160,w.txtWidth,'center',0,w.txtScale,w.txtScale,w.txtWidth*.5,72)
end

return warn