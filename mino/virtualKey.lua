local vk={key={},act={}}
local T=mytable
local ins,rem=table.insert,table.remove
function vk.reset()
    vk.key={}
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
        local r2=((x-v.x)^2+(y-v.y)^2)^.5
        if r<v.r and r<d then ak=k end
    end
    vk.act[id]=k
end
function vk.release(id,x,y)
    rem(vk.act,id)
end
return vk