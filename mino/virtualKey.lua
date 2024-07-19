--用于方块游戏的虚拟按键模块，适配移动端用

local vk={}
local T=mytable
local ins,rem=table.insert,table.remove
local abs=math.abs
function vk.init()
    vk.key={}
    vk.act={}
end
--arg={x,y,r,t,op}
--op=ML/MR/CW/CCW/flip/SD/HD/hold
function vk.new(name,arg)
    local k={x=0,y=0,r=100,t=0,op=''}
    if arg then
        vk.key[name]=T.combine(k,arg)
    end
end
function vk.press(id,x,y)
    local ak
    local d=1e99
    for k,v in pairs(vk.key) do
        local r=abs(x-v.x)+abs(y-v.y)
        if r<v.r and r<d then ak=k end
    end
    vk.act[id]=ak
    return ak,vk.key[ak.op]
end
function vk.release(id,x,y)
    rem(vk.act,id)
end
function vk.checkActive(name)
    return T.include(name,vk.act)
end
return vk