local BUTTON={list={},active=nil}
local gc=love.graphics
local M,T=mymath,mytable

local layer=0
function BUTTON.create(name,arg,aboveTLimit)
    if name and arg then
    if not BUTTON.list[layer] then BUTTON.list[layer]={} end
    BUTTON.list[layer][name]=arg
    BUTTON.list[layer][name].hover=false
    BUTTON.list[layer][name].aboveT=0
    BUTTON.list[layer][name].clickT=1e99--距离上一次点击的时间
    BUTTON.list[layer][name].aboveTLimit=aboveTLimit and aboveTLimit or 1
    BUTTON.list[layer][name].clickPos={0,0}
    BUTTON.list[layer][name].hoverPos={0,0}
    end
end
--[[e.g.
arg={
    x=0,y=0,

1.  type='circle',r=36,
2.  type='diamond',r=48,
3.  type='rect',w=72,h=48,
4.  type='poly',edge={ 80,0 , 0,80 , -80,0 , 0,-80 }


    draw=function()
        gc.setColor(1,1,1,.6)
        gc.rectangle('fill',-16,-16,32,32)
        gc.setColor(1,1,1)
        gc.rectangle('line',-16,-16,32,32)
    end
    aboveT=0
    event=function() end
}
]]
function BUTTON.discard()
    BUTTON.list={} layer=0
    BUTTON.active=nil
end
function BUTTON.setLayer(l)
    layer=l or 0
end
function BUTTON.getLayer()
    return layer
end
function BUTTON.remove(name)
    if type(name)=='table' then for k,v in pairs(name) do BUTTON.list[v]=nil end
    else BUTTON.list[name]=nil end
end
function BUTTON.update(dt,x,y,l)
    l=l or 0
    if not BUTTON.list[l] then return end
    for k,v in pairs(BUTTON.list[l]) do
        if BUTTON.check(v,x,y) then
            v.aboveT=min(v.aboveT+dt,v.aboveTLimit)
            v.hoverPos[1],v.hoverPos[2]=x-v.x,y-v.y
            v.hover=true
            if v.update then v.update(dt,v) end
        else
            v.aboveT=max(v.aboveT-dt,0)
            v.hover=false
        end

        v.clickT=v.clickT+dt
        if v.always then v.always(dt,v) end
    end
end
function BUTTON.check(butt,x,y)
    local ax,ay=x-butt.x,y-butt.y
    if butt.type=='circle' then return (x-butt.x)^2+(y-butt.y)^2<butt.r^2
    elseif butt.type=='diamond' then return abs(x-butt.x)+abs(y-butt.y)<butt.r
    elseif butt.type=='rect' then
        return ax>-butt.w/2 and ax<butt.w/2 and ay>-butt.h/2 and ay<butt.h/2
    elseif butt.type=='poly' then return M.pointInPolygon(ax,ay,butt.edge) end
end
function BUTTON.draw(l)
    l=l or 0
    if BUTTON.list[l] then
    for k,v in pairs(BUTTON.list[l]) do gc.push()
        gc.translate(v.x,v.y)
        v.draw(v,v.aboveT,v.clickT,v.clickPos)
    gc.pop() end
    end
end
function BUTTON.press(x,y,l)
    l=l or 0
    if BUTTON.list[l] then
        for k,v in pairs(BUTTON.list[l]) do
        if BUTTON.check(v,x,y) then BUTTON.active=k return k end
        end
    end
end
function BUTTON.release(x,y,l)
    l=l or 0
    if BUTTON.list[l] then
        for k,v in pairs(BUTTON.list[l]) do
        if BUTTON.check(v,x,y) and BUTTON.active==k then
            v.event(x-v.x,y-v.y,v) v.clickT=0
            v.clickPos[1],v.clickPos[2]=x-v.x,y-v.y
        end
        end
    end
end

--默认绘制参数
local arg=0
local function checkerStencil()
    gc.arc('fill','closed',0,0)
end
function BUTTON.checker(bt,ct,arg)
    
end

return BUTTON