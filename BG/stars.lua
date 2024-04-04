local star={}
local c={}
gc.setColor(1,1,1)
for i=1,4 do
    c[i]=gc.newCanvas(2000,2000)
    gc.setCanvas(c[i])
    for j=1,96 do
        gc.circle('fill',rand()*2000,rand()*2000,3,6)
    end
end
gc.setCanvas()
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