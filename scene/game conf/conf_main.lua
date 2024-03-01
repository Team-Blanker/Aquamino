local BUTTON=scene.button
local config={}
function config.init()
    scene.BG=require'BG/space' scene.BG.init()
    local bt=fs.read('scene/game conf/conf_main_load.lua')
    assert(loadstring(bt))()
end
function config.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) then end
end
--function AnV.mouseR(x,y,button,istouch)
--end
function config.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function config.draw()
    gc.setColor(1,1,1)
    gc.printf(user.lang.conf.main.title,Exo_2,0,-420,1280,'center',0,1,1,640,84)
    BUTTON.draw()
end
function config.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene=arg
    destScene.mode='conf_test'
    destScene.resetStopMusic=false
    end
end
return config