local nmp={}
function nmp.init()
    scene.BG=require('BG/squares')
    if scene.BG.init then scene.BG.init() end
end
function nmp.update(dt)
end
function nmp.draw()
end
return nmp