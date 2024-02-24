local bg={}
local parList={}
local insTime=0

function bg.init()
    bg.density=1.5
    parList={}
    bg.BGColor={0,0,0}
    bg.parColor={1,1,1}
end
function bg.update(dt)
    insTime=insTime+dt
    for i=#parList,1,-1 do
        parList[i].t=parList[i].t+dt
        if parList[i].t>5 then table.remove(parList,i) end
    end
    if insTime>2/bg.density then
        table.insert(parList,{x=rand(16),t=0})
        insTime=insTime-2/bg.density
    end
    if math.random()<dt*bg.density/2 then
        table.insert(parList,{x=rand(16),t=0})
    end
end
local arg,r,g,b
function bg.draw()
    gc.clear(bg.BGColor)
    gc.translate(-960,540)
    for i=1,#parList do
        local p=parList[i]
        local t=p.t*8
        for j=1,9 do
            local l=6
            arg=1-(t-j)/l
            r=bg.parColor[1]*(1-arg)+arg g=bg.parColor[2]*(1-arg)+arg b=bg.parColor[3]*(1-arg)+arg
            gc.setColor(r,g,b,(j<t and 1-(t-j)/l or 0))
            gc.rectangle('fill',120*(p.x-1)+10,-120*j+10,100,100)
        end
    end
    gc.translate(960,-540)
end
return bg