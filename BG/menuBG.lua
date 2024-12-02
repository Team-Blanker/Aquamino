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
local op={'x',math.atan(1/phi),'z',0,
    'x',.2,'z',0,'x',math.pi/2
}
local newDot=mytable.copy(dot)

local x1,y1,x2,y2
local pcv=gc.newCanvas(1000,1000)
local pr,pg,pb=1,1,1
local nr,ng,nb=1,1,1
local sf=0
function bg.setPolyColor(r,g,b)
    pr,pg,pb=pr*sf+nr*(1-sf),pg*sf+ng*(1-sf),pb*sf+nb*(1-sf)
    nr,ng,nb=r,g,b
    sf=1
end
function bg.update(dt)
    sf=max(sf-4*dt,0)
end
function bg.draw()
    op[4]=scene.totalTime/2.5+scene.totalTime/8 op[8]=-scene.totalTime/8
    gc.push()
        gc.origin()
        gc.setScissor(0,0,1000,1000)
        gc.translate(500,500)

        gc.setCanvas(pcv)
        gc.clear()
        gc.setColor(1,1,1)
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
        gc.setDefaultCanvas()
        gc.setScissor()
    gc.pop()
    gc.clear(.05,.05,.05)
    gc.setColor(pr*sf+nr*(1-sf),pg*sf+ng*(1-sf),pb*sf+nb*(1-sf),.25)
    gc.draw(pcv,0,0,0,1.75,1.75,500,500)
end
return bg