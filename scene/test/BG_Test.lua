local BGTest={}
local t=0
local sddl=gc.newImage('pic/assets/sddl.png')--540*540
function BGTest.init()
    scene.BG=require('BG/celebration')
    if scene.BG.init then scene.BG.init() end
    scene.setShader('shader/mosaic.glsl')
    --scene.shader:send('phase',t)
end
function BGTest.update(dt)
    t=t+dt
    --scene.shader:send('phase',t)
end
function BGTest.draw()
    gc.draw(sddl,0,0,0,1.25,1.25,270,270)
    gc.setLineWidth(4)
    gc.setColor(1,1,1,.5)
    for i=-960,960,120 do
        gc.line(i,-540,i,540)
    end
    for i=-540,540,120 do
        gc.line(-960,i,960,i)
    end
end
return BGTest