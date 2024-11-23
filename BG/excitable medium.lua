--模拟可激发介质的背景
local bg={}

local updateT,updateTimer=1/8,0
local time=0
local medium={}--“介质”
local w,h=64,36
local CDTick=9--介质冷却刻数
local cellSize=1920/w
local actChance=.75--介质被完全激活的概率
for y=1,h do
    medium[y]={}
    for x=1,w do
        --medium[y][x]={value=rand()<.025 and rand(CDTick) or 0,newValue=0}
        medium[y][x]={value=0,newValue=0}
    end
end
for i=1,2 do medium[rand(h)][rand(w)].value=CDTick end

local cList={{0,1},{1,0},{0,-1},{-1,0}}

function bg.setBPM(bpm)
    updateT=60/bpm
end

function bg.update(dt)
    time=time+dt
    updateTimer=updateTimer+dt
    if updateTimer>=updateT then
        updateTimer=updateTimer-updateT
        --计算刷新后的值
        for y=1,h do
            for x=1,w do
                if medium[y][x].value>0 then--介质未完全冷却时，继续冷却
                    medium[y][x].newValue=medium[y][x].value-1
                else--介质已完全冷却，查看周围4格介质情况
                    for i=1,#cList do
                        if medium[(y+cList[i][2]-1)%h+1][(x+cList[i][1]-1)%w+1].value==CDTick then
                            medium[y][x].newValue=(rand()<actChance and CDTick or CDTick-1)
                            break
                        end
                    end
                end
            end
        end
        --刷新
        for y=1,h do
            for x=1,w do
                medium[y][x].value=medium[y][x].newValue
            end
        end
    end
end
local clear,setColor,rect=gc.clear,gc.setColor,gc.rectangle
function bg.draw()
    gc.clear(.08,.08,.08)
    for y=1,h do
        for x=1,w do
            setColor(1,1,1,.2*medium[y][x].value/CDTick)
            rect('fill',-960+cellSize*(x-1),-540+cellSize*(y-1),cellSize,cellSize)
        end
    end
end

function bg.discard()
    updateT,updateTimer=1/8,0
    time=0
    medium={}
end
return bg