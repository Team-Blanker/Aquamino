local bg={}
local phi=(5^.5-1)/2
local dot={
    {1,phi,0},{-1,phi,0},{-1,-phi,0},{1,-phi,0},
    {0,1,phi},{0,-1,phi},{0,-1,-phi},{0,1,-phi},
    {phi,0,1},{phi,0,-1},{-phi,0,-1},{-phi,0,1},
}
local edge={
    1,4, 2,3, 5,8, 6,7, 9,12, 10,11,
    1,9, 1,10, 4,9, 4,10, 2,11, 2,12, 3,11, 3,12,
    5,1, 5,2, 8,1, 8,2, 6,3, 6,4, 7,3, 7,4,
    9,5, 9,6, 12,5, 12,6, 10,7, 10,8, 11,7, 11,8,
}
local r3d=mymath.rotate3D
local op={'z',0}
local newDot=mytable.copy(dot)

local x1,y1,x2,y2
local pcv=gc.newCanvas(1000,1000)
function bg.draw()
    gc.push()
        gc.origin()
        gc.translate(500,500)

        gc.setCanvas(pcv)
        gc.clear()
        gc.setColor(1,1,1)
        op[2]=scene.time
        for i=1,#dot do
            newDot[i][1],newDot[i][2],newDot[i][3]=r3d(dot[i][1],dot[i][2],dot[i][3],op)
        end
        gc.setLineWidth(10)
        for i=1,#newDot do
            gc.circle('fill',420*newDot[i][1],-420*newDot[i][3],5)
        end
        for i=1,#edge,2 do
            x1,y1=420*newDot[edge[i]][1],-420*newDot[edge[i]][3]
            x2,y2=420*newDot[edge[i+1]][1],-420*newDot[edge[i+1]][3]
            gc.line(x1,y1,x2,y2)
        end
        gc.setCanvas()
    gc.pop()
    gc.clear(0,0,0)
    for i=1,5 do
        gc.setColor(1,1,1,.08/i)
        for j=1,6 do
            gc.draw(pcv,cos(math.pi*j/2)*i*4,sin(math.pi*j/2)*i*4,0,1,1,500,500)
        end
    end
    gc.setColor(1,1,1,.25)
    gc.draw(pcv,0,0,0,1,1,500,500)
end
return bg