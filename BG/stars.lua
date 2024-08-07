local star={}
local c={}

gc.setScissor(0,0,2000,2000)--默认的scissor是1920*1080，这里要改，否则一半地方画不了
gc.setColor(1,1,1)
for i=1,4 do
    gc.origin()
    c[i]=gc.newCanvas(2000,2000)
    gc.setCanvas(c[i])
    for j=1,96 do
        local a,b=2*rand()-1,2*rand()-1
        gc.circle('fill',1000*a+1000,1000*b+1000,(2+1*(a*a+b*b))*(.75+.5*rand()),4)
    end
end
gc.setCanvas()
gc.setScissor()

function star.draw()
    gc.clear(.04,.04,.08)
    gc.push('transform')
    gc.rotate(scene.time*math.pi/1000)
    for i=1,4 do
        gc.setColor(1,1,1,.6+abs((scene.time+2*i)%8-4)/4*.4)
        gc.draw(c[i],0,0,0,1,1,1000,1000)
    end
    gc.pop()
end
return star