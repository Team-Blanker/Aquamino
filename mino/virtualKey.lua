--用于方块游戏的虚拟按键模块，适配移动端用

local keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}
local keyIcon={}
for i=1,#keyName do
    keyIcon[keyName[i]]=gc.newImage('pic/virtual key/'..keyName[i]..'.png')--200*200
end

local actCanvas=gc.newCanvas(450,450)
gc.setScissor(0,0,450,450)
gc.setCanvas(actCanvas)
gc.setLineWidth(10)
gc.circle('line',225,225,200,4)
gc.setCanvas()
gc.setScissor()

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
    local k={x=0,y=0,r=100,t=1e99}
    if arg then
        T.combine(k,arg)
        vk.key[name]=k
    end
end
function vk.press(id,x,y)
    local ak
    local d=1e99
    for k,v in pairs(vk.key) do
        local r=abs(x-v.x)+abs(y-v.y)
        if r<v.r and r<d then ak=k d=r end
    end
    if ak then vk.act[id]=ak vk.key[ak].t=0 end
    return ak
end
function vk.release(id,x,y)
    local rk=vk.act[id]
    vk.act[id]=nil
    return rk
end
function vk.animUpdate(dt)
    for k,v in pairs(vk.key) do
        v.t=v.t+dt
    end
end
function vk.checkActive(name)
    if T.include(vk.act,name) then return true else return false end
end
function vk.draw()
    for k,v in pairs(vk.act) do
        local ak=vk.key[v]
        gc.setColor(1,1,1,.25)
        gc.circle('fill',ak.x,ak.y,ak.r*15/16,4)
    end
    for k,v in pairs(vk.key) do
        gc.setColor(1,1,1)
        gc.setLineWidth(5*v.r/100)
        gc.circle('line',v.x,v.y,v.r,4)

        gc.setColor(1,1,1,1-5*v.t)
        gc.draw(actCanvas,v.x,v.y,0,v.r/200*(1+v.t),v.r/200*(1+v.t),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x,v.y,0,v.r/100,v.r/100,100,100)
    end
end
return vk