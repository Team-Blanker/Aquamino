local polar={}
function polar.init()
    polar.img=gc.newImage('assets/pic/otto.jpg')
    local sha=fs.newFile('shader/polar.glsl'):read()
    polar.shader=gc.newShader(sha)
    scene.watermark=false
    polar.scale=.5
    polar.rotate=0
    polar.yShift=0
end
function polar.update(dt)
    if love.keyboard.isDown('up') then polar.scale=min(1/(1/polar.scale-dt),3) end
    if love.keyboard.isDown('down') then polar.scale=max(1/(1/polar.scale+dt),.125) end
    if love.keyboard.isDown('left') then polar.rotate=polar.rotate+dt*.5 end
    if love.keyboard.isDown('right') then polar.rotate=polar.rotate-dt*.5 end
    if love.keyboard.isDown('x') then polar.yShift=polar.yShift+dt*.5 end
    if love.keyboard.isDown('z') then polar.yShift=polar.yShift-dt*.5 end
end
function polar.draw()
    polar.shader:send('wins',win.scale)
    polar.shader:send('img',polar.img)
    polar.shader:send('scale',polar.scale)
    polar.shader:send('angle',polar.rotate)
    polar.shader:send('yShift',polar.yShift)
    gc.setShader(polar.shader)
    gc.rectangle('fill',-960,-540,1920,1080)
    gc.setShader()
    --gc.circle('fill',0,0,1000*sin(scene.time%2*math.pi))
end
return polar