--模拟可激发介质的背景
local bg={}

local updateT,updateTimer=1/8,0
local time=0
local medium={R={},G={},B={}}--“介质”
local w,h=64,36
local CDTick=7--介质冷却刻数
local cellSize=1920/w
local actChance=.8--介质被完全激活的概率
for k,v in pairs(medium) do
    for y=1,h do v[y]={}
        for x=1,w do
            v[y][x]={value=rand()<.01 and rand(CDTick) or 0,newValue=0}
        end
    end
end

local cList={{0,1},{1,0},{0,-1},{-1,0}}

function bg.update(dt)
    time=time+dt
    updateTimer=updateTimer+dt
    if updateTimer>=updateT then
        updateTimer=updateTimer-updateT
        --计算刷新后的值
        for k,med in pairs(medium) do
            for y=1,h do  for x=1,w do
                if med[y][x].value>0 then--介质未完全冷却时，继续冷却
                    med[y][x].newValue=med[y][x].value-1
                else--介质已完全冷却，查看周围4格介质情况
                    for i=1,#cList do
                        if med[(y+cList[i][2]-1)%h+1][(x+cList[i][1]-1)%w+1].value==CDTick then
                            med[y][x].newValue=(rand()<actChance and CDTick or CDTick-1)
                            break
                        end
                    end
                end
            end  end
            --刷新
            for y=1,h do  for x=1,w do
                med[y][x].value=med[y][x].newValue
            end  end
        end
    end
end
local clear,setColor,rect=gc.clear,gc.setColor,gc.rectangle
function bg.draw()
    gc.clear(.1,.1,.1)
    for y=1,h do
        for x=1,w do
            setColor(.25*medium.R[y][x].value/CDTick,.25*medium.G[y][x].value/CDTick,.25*medium.B[y][x].value/CDTick,.8)
            rect('fill',-960+cellSize*(x-1),-540+cellSize*(y-1),cellSize,cellSize)
        end
    end
end
return bg