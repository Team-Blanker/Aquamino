local BG={speed=1,delay=0,baseColor={.4,.8,1}}
function BG.draw()
    local t=scene.time*BG.speed-BG.delay
    gc.clear(BG.baseColor)
    gc.setColor(1,1,1,.25)
    gc.translate(-960,-540)
    for i=0,16 do for j=0,9 do
        local progress=t%1
        local sz=t%2<1 and 0.5-0.5*math.cos(progress*math.pi) or 0.5+0.5*math.cos(progress*math.pi)
        gc.circle('fill',120*i,120*j,60*sz,4)
        gc.circle('fill',120*i+60,120*j+60,60*(1-sz),4)
    end end
    gc.translate(960,540)
end
return BG
