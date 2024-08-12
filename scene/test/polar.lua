local polar={}
function polar.init()
    polar.img=gc.newImage('pic/assets/kairan.png')
    local sha=fs.newFile('shader/polar.glsl'):read()
    polar.shader=gc.newShader(sha)
    scene.watermark=false
    polar.scale=.5
    polar.angle=0
    polar.xShift=0
    polar.yShift=0
    polar.imgCutX=1
    polar.imgCutY=1
end
function polar.update(dt)
    if love.keyboard.isDown('up') then polar.scale=min(1/(1/polar.scale-4*dt),3) end
    if love.keyboard.isDown('down') then polar.scale=max(1/(1/polar.scale+4*dt),1/40) end
    if love.keyboard.isDown('left') then polar.angle=polar.angle+dt*.5 end
    if love.keyboard.isDown('right') then polar.angle=polar.angle-dt*.5 end
    if love.keyboard.isDown('a') then polar.xShift=polar.xShift+dt*.5 end
    if love.keyboard.isDown('d') then polar.xShift=polar.xShift-dt*.5 end
    if love.keyboard.isDown('w') then polar.yShift=polar.yShift+dt*.5 end
    if love.keyboard.isDown('s') then polar.yShift=polar.yShift-dt*.5 end
    if love.keyboard.isDown('c') then polar.imgCutX=min(polar.imgCutX+dt,4) end
    if love.keyboard.isDown('v') then polar.imgCutX=max(polar.imgCutX-dt,.25) end
    if love.keyboard.isDown('z') then polar.imgCutY=min(polar.imgCutY+dt,4) end
    if love.keyboard.isDown('x') then polar.imgCutY=max(polar.imgCutY-dt,.25) end
end
function polar.draw()
    polar.shader:send('wins',win.scale)
    polar.shader:send('img',polar.img)
    polar.shader:send('scale',polar.scale)
    polar.shader:send('angle',polar.angle)
    polar.shader:send('xShift',polar.xShift)
    polar.shader:send('yShift',polar.yShift)
    polar.shader:send('imgCutX',polar.imgCutX)
    polar.shader:send('imgCutY',polar.imgCutY)

    gc.setShader(polar.shader)
    gc.rectangle('fill',-960,-540,1920,1080)
    gc.setShader()
    --gc.circle('fill',0,0,1000*sin(scene.time%2*math.pi))
end
return polar