local slider={list={},acting=nil}
local gc=love.graphics
local M,T=myMath,myTable
function slider.create(name,arg)
    if name and arg then slider.list[name]=arg end
end
--[[e.g.
arg={
    x=0,y=0,type=(hori/vert),sz={128,32},button={18,36}
1.  gear=5(|--|--|--|--|),pos=(0/1/2/3/4),
2.  gear=0(-------------),pos=0.6180339887,
    sideButton={
        distance=20,
        sz={10,10},
        draw=function(v,id) end,
        event=function(v,id) end
        --id为-1和1
    },
    sliderDraw=function() end,
    buttonDraw=function() end,
    aboveT=0,
   
    click=function() end,
    always=function() end,
    release=function() end,
}
]]
function slider.discard()
    slider.list={}
end
function slider.draw()
    for k,v in pairs(slider.list) do gc.push()
        gc.translate(v.x,v.y)
        v.sliderDraw(v.gear,v.sz,v) v.buttonDraw(v.gear==0 and v.pos or v.pos/(v.gear-1),v.sz)
        if v.sideButton and v.sideButton.draw then v.sideButton.draw(v,-1) v.sideButton.draw(v,1) end
    gc.pop() end
end
function slider.check(slid,x,y)
    local ax,ay=x-slid.x,y-slid.y
    return ax>-(slid.sz[1]+slid.button[1])/2 and ax<(slid.sz[1]+slid.button[1])/2
        and ay>-(slid.sz[2]+slid.button[2])/2 and ay<(slid.sz[2]+slid.button[2])/2
end
function slider.sideButtonCheck(slid,x,y)
    if not slid.sideButton then return end
    local ax,ay=x-slid.x,y-slid.y
    local buttonPosX=slid.type=='hori' and slid.sz[1]/2+slid.sideButton.distance or 0
    local buttonPosY=slid.type=='vert' and slid.sz[2]/2+slid.sideButton.distance or 0
    if slid.type=='hori' then
        if abs(ax-buttonPosX)<=slid.sideButton.sz[1]/2 and abs(ay-buttonPosY)<=slid.sideButton.sz[2]/2 then
            return 1
        end
        if abs(ax+buttonPosX)<=slid.sideButton.sz[1]/2 and abs(ay-buttonPosY)<=slid.sideButton.sz[2]/2 then
            return -1
        end
    end
    if slid.type=='vert' then
        if abs(ax-buttonPosX)<=slid.sideButton.sz[1]/2 and abs(ay-buttonPosY)<=slid.sideButton.sz[2]/2 then
            return 1
        end
        if abs(ax-buttonPosX)<=slid.sideButton.sz[1]/2 and abs(ay+buttonPosY)<=slid.sideButton.sz[2]/2 then
            return -1
        end
    end
end
local act
function slider.mouseP(x,y,button,istouch)
    for k,v in pairs(slider.list) do
        if not v.act then act=true else act=v.act() end
        if act then
            if slider.check(v,x,y) then
                local pos=M.clamp(v.type=='hori' and (x-v.x)/v.sz[1]+.5 or (y-v.y)/v.sz[2]+.5,0,1)
                if v.gear==0 then v.pos=pos else
                    v.pos=floor((v.gear-1)*pos+.5)
                end
                slider.acting=k
                if v.click then v.click(pos) end
                return k
            end
            local buttonid=slider.sideButtonCheck(v,x,y)
            if buttonid then
                if v.sideButton.event then v.sideButton.event(v,buttonid) end
                return k
            end
        end
    end
end
function slider.mouseR(x,y,button,istouch)
    if slider.acting and slider.list[slider.acting].release then
        slider.list[slider.acting].release(slider.list[slider.acting].pos)
    end
    slider.acting=nil
end
function slider.always(slid,x,y)
    local pos=M.clamp((slid.type=='hori' and (x-slid.x)/slid.sz[1]+.5 or (y-slid.y)/slid.sz[2]+.5),0,1)
    if slid.gear==0 then slid.pos=pos else
        slid.pos=floor((slid.gear-1)*pos+.5)
    end
    if slid.always then slid.always(slid.pos,slid) end
end
function slider.setPos(slidName,pos)
    local v=type(slidName)=='string' and slider.list[slidName] or slidName
    v.pos=pos
end
function slider.setPosWithEvent(slidName,pos,eventName)
    local v=type(slidName)=='string' and slider.list[slidName] or slidName
    v.pos=pos
    if eventName=='click' then v.always(v.pos)
    elseif eventName=='always' then v.always(v.pos,v)
    elseif eventName=='release' then v.release(v.pos)
    else v.always(v.pos,v) end
end
function slider.setPosWithValue(slidName,value)
    local v=type(slidName)=='string' and slider.list[slidName] or slidName
    if v.setPosWithValue then v.pos=v.setPosWithValue(value)
    else v.pos=value end
end
return slider