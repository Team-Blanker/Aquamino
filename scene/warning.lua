local warn={}
local bannedkey={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12','tab'}
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
    gc.clear(.08,.08,.08)

    gc.setColor(1,1,1,2*scene.time-.5)
    gc.printf(w.title,font.Bender_B,0,-300,3000,'center',0,.6,.6,1500,72)
    gc.setColor(.5,1,.875,2*scene.time-.5)
    gc.printf(w.txt,font.Bender,0,-160,w.txtWidth,'center',0,w.txtScale,w.txtScale,w.txtWidth*.5,72)
end
--function intro.send() scene.cur.modename[1]="40行" end
return warn