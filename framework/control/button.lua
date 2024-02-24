local BUTTON={list={},active=nil}
local gc=love.graphics
local M,T=mymath,mytable
function BUTTON.create(name,arg,aboveTLimit)
    if name and arg then BUTTON.list[name]=arg BUTTON.list[name].aboveT=0
    BUTTON.list[name].clickT=1e99--距离上一次点击的时间
    BUTTON.list[name].aboveTLimit=aboveTLimit and aboveTLimit or 1
    else BUTTON.list={} end
    BUTTON.active=nil
end
--[[e.g.
arg={
    x=0,y=0,
1.  type='circle',r=36,
2.  type='rect',w=72,h=48,
3.  type='poly',edge={ 80,0 , 0,80 , -80,0 , 0,-80 },
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
function BUTTON.remove(name)
    if type(name)=='table' then for k,v in pairs(name) do BUTTON.list[v]=nil end
    else BUTTON.list[name]=nil end
end
function BUTTON.update(dt,x,y)
    for k,v in pairs(BUTTON.list) do
        if BUTTON.check(v,x,y) then v.aboveT=min(v.aboveT+dt,v.aboveTLimit)
            if v.update then v.update(dt,v) end
        else v.aboveT=max(v.aboveT-dt,0) end
        v.clickT=v.clickT+dt
        if v.always then v.always(dt,v) end
    end
end
function BUTTON.check(butt,x,y)
    local ax,ay=x-butt.x,y-butt.y
    if butt.type=='circle' then return (x-butt.x)^2+(y-butt.y)^2<butt.r^2
    elseif butt.type=='rect' then
        return ax>-butt.w/2 and ax<butt.w/2 and ay>-butt.h/2 and ay<butt.h/2
    elseif butt.type=='poly' then return M.pointInPolygon(ax,ay,butt.edge) end
end
function BUTTON.draw()
    for k,v in pairs(BUTTON.list) do gc.push()
        gc.translate(v.x,v.y)
        v.draw(v,v.aboveT,v.clickT,v.clickPos)
    gc.pop() end
end
function BUTTON.press(x,y)
    for k,v in pairs(BUTTON.list) do
        if BUTTON.check(v,x,y) then BUTTON.active=k return k end
    end
end
function BUTTON.release(x,y)
    for k,v in pairs(BUTTON.list) do
        if BUTTON.check(v,x,y) and BUTTON.active==k then v.event(x-v.x,y-v.y,v) v.clickT=0 end
    end
end
function BUTTON.click(x,y,button,istouch)
    for k,v in pairs(BUTTON.list) do
        if BUTTON.check(v,x,y) then
            v.event(x-v.x,y-v.y,v) v.clickT=0 v.clickPos={x=x-v.x,y=y-v.y}
            return k
        end
    end
end
return BUTTON