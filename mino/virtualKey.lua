--用于方块游戏的虚拟按键模块，适配移动端用

local keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}
local keyIcon={}
for i=1,#keyName do
    keyIcon[keyName[i]]=gc.newImage('pic/virtual key/'..keyName[i]..'.png')--200*200
end

local borderCanvas=gc.newCanvas(450,450)
gc.setScissor(0,0,450,450)
gc.setCanvas(borderCanvas)
gc.setLineWidth(10)
gc.setColor(1,1,1)
gc.circle('line',225,225,200,4)
gc.setCanvas()
gc.setScissor()

local T=myTable
local ins,rem=table.insert,table.remove
local abs=math.abs
local tau=2*math.pi
local vk={}

local function checkAct(k)
    return T.include(vk.act,k) or vk.animAct[k]
end

local function defaultVkDraw(k,v)
    if checkAct(k) then gc.setColor(1,1,1,.25)
    gc.circle('fill',v.x,v.y,v.r*15/16,4)
    end

    gc.setColor(1,1,1)
    gc.setLineWidth(5*v.r/100)
    gc.circle('line',v.x,v.y,v.r,4)

    gc.setColor(1,1,1,1-5*v.clickT)
    gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

    gc.setColor(1,1,1,.8)
    gc.draw(keyIcon[k],v.x,v.y,0,v.r/100,v.r/100,100,100)
end

local vkDraw={
    ML=function(k,v)
        local l=v.holdT>=vk.ctrl.ASD and v.holdT>0
        local va=min(v.holdT-vk.ctrl.ASD,.1)*5
        local ia=vk.ctrl.ASD==0 and (v.holdT>0 and 1 or 0) or min(v.holdT/vk.ctrl.ASD,1)^3

        if checkAct(k) then
            if l then gc.setColor(.5,1,.875,.25) else gc.setColor(1,1,1,.25) end
            gc.circle('fill',v.x,v.y,v.r*15/16,4)
        end

        if l then gc.setColor(.5,1,.875) else gc.setColor(1,1,1) end
        gc.setLineWidth(5*v.r/100)
        gc.circle('line',v.x,v.y,v.r,4)
        if l then gc.setColor(.5,1,.875,v.holdT%.2<.1 and 1 or .75)
        gc.arc('line','open',v.x-v.r*(1/3+va),v.y,v.r*2/3,tau/4,tau*3/4,2)
        end

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x-v.r*.25*ia,v.y,0,v.r/100,v.r/100,100,100)
    end,

    MR=function(k,v)
        local l=v.holdT>=vk.ctrl.ASD and v.holdT>0
        local va=min(v.holdT-vk.ctrl.ASD,.1)*5
        local ia=vk.ctrl.ASD==0 and (v.holdT>0 and 1 or 0) or min(v.holdT/vk.ctrl.ASD,1)^3

        if checkAct(k) then
            if l then gc.setColor(.5,1,.875,.25) else gc.setColor(1,1,1,.25) end
            gc.circle('fill',v.x,v.y,v.r*15/16,4)
        end

        if l then gc.setColor(.5,1,.875) else gc.setColor(1,1,1) end
        gc.setLineWidth(5*v.r/100)
        gc.circle('line',v.x,v.y,v.r,4)
        if l then gc.setColor(.5,1,.875,v.holdT%.2<.1 and 1 or .75)
        gc.arc('line','open',v.x+v.r*(1/3+va),v.y,v.r*2/3,-tau/4,tau/4,2)
        end

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x+v.r*.25*ia,v.y,0,v.r/100,v.r/100,100,100)
    end,

    SD=function(k,v)
        local l=v.holdT>=vk.ctrl.SD_ASD and v.holdT>0
        local va=min(v.holdT-vk.ctrl.SD_ASD,.1)*5
        local ia=vk.ctrl.SD_ASD==0 and (v.holdT>0 and 1 or 0) or min(v.holdT/vk.ctrl.SD_ASD,1)^3

        if checkAct(k) then
            if l then gc.setColor(.5,1,.875,.25) else gc.setColor(1,1,1,.25) end
            gc.circle('fill',v.x,v.y,v.r*15/16,4)
        end

        if l then gc.setColor(.5,1,.875) else gc.setColor(1,1,1) end
        gc.setLineWidth(5*v.r/100)
        gc.circle('line',v.x,v.y,v.r,4)
        if l then gc.setColor(.5,1,.875,v.holdT%.2<.1 and 1 or .75)
        gc.arc('line','open',v.x,v.y+v.r*(1/3+va),v.r*2/3,0,tau/2,2)
        end

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x,v.y+v.r*.25*ia,0,v.r/100,v.r/100,100,100)
    end,

    HD=function(k,v)
        local l=v.holdT>=vk.ctrl.SD_ASD and v.holdT>0
        local ia=max(-abs(v.clickT-.05)+.05,0)*2

        if checkAct(k) then
            gc.setColor(1,1,1,.25)
            gc.circle('fill',v.x,v.y,v.r*15/16,4)
        end

        gc.setColor(1,1,1)
        gc.setLineWidth(5*v.r/100)
        gc.circle('line',v.x,v.y,v.r,4)

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x,v.y+v.r*ia,0,v.r/100,v.r/100,100,100)
    end,

    CW=function(k,v)
    local as=min(max((1-v.clickT/.2)^3,0),1)

    if checkAct(k) then gc.setColor(1,1,1,.25)
        gc.arc('fill','closed',v.x,v.y,v.r*15/16,-as/4*tau,(3-as)/4*tau,3)
    end

    gc.setColor(1,1,1)
    gc.setLineWidth(5*v.r/100)
    gc.arc('line','closed',v.x,v.y,v.r,-as/4*tau,(3-as)/4*tau,3)

    gc.setColor(1,1,1,1-5*v.clickT)
    gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

    gc.setColor(1,1,1,.8)
    gc.draw(keyIcon[k],v.x,v.y,0,v.r/100,v.r/100,100,100)
    end,

    CCW=function(k,v)
        local as=min(max((1-v.clickT/.2)^3,0),1)

        if checkAct(k) then gc.setColor(1,1,1,.25)
            gc.arc('fill','closed',v.x,v.y,v.r*15/16,as/4*tau,(3+as)/4*tau,3)
        end

        gc.setColor(1,1,1)
        gc.setLineWidth(5*v.r/100)
        gc.arc('line','closed',v.x,v.y,v.r,as/4*tau,(3+as)/4*tau,3)

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x,v.y,0,v.r/100,v.r/100,100,100)
    end,

    flip=function(k,v)
        local as=min(max((1-v.clickT/.2)^3,0),1)

        if checkAct(k) then gc.setColor(1,1,1,1-3^.5/2)
            gc.arc('fill','closed',v.x,v.y,v.r*15/16,-as/4*tau,(3-as)/4*tau,3)
            gc.arc('fill','closed',v.x,v.y,v.r*15/16, as/4*tau,(3+as)/4*tau,3)
        end

        gc.setColor(1,1,1)
        gc.setLineWidth(5*v.r/100)
        gc.arc('line','closed',v.x,v.y,v.r,-as/4*tau,(3-as)/4*tau,3)
        gc.arc('line','closed',v.x,v.y,v.r, as/4*tau,(3+as)/4*tau,3)

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x,v.y,0,v.r/100,v.r/100,100,100)
    end,

    hold=function(k,v)
        local l=v.holdT>=vk.ctrl.SD_ASD and v.holdT>0
        local ia=min(abs(v.clickT-.05),.05)/.05

        if checkAct(k) then
            gc.setColor(1,1,1,.25)
            gc.ellipse('fill',v.x,v.y,v.r*15/16,v.r*15/16,4)
        end

        gc.setColor(1,1,1)
        gc.setLineWidth(5*v.r/100)
        gc.ellipse('line',v.x,v.y,v.r,v.r,4)

        gc.setColor(1,1,1,1-5*v.clickT)
        gc.draw(borderCanvas,v.x,v.y,0,v.r/200*(1+2*v.clickT),v.r/200*(1+2*v.clickT),225,225)

        gc.setColor(1,1,1,.8)
        gc.draw(keyIcon[k],v.x,v.y,0,v.r/100*ia,v.r/100,100,100)
    end,
}

function vk.init(ctrl,anim)
    vk.key={}
    vk.act={}
    vk.animAct={}--非触屏
    vk.ctrl=ctrl
    vk.anim=anim
end
--arg={x,y,r,t,op}
--op=ML/MR/CW/CCW/flip/SD/HD/hold
function vk.new(name,arg)
    local k={x=0,y=0,r=100,tolerance=0,clickT=1e99,holdT=0}
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
        if r<v.r+v.tolerance and r<d then ak=k d=r end
    end
    if ak then vk.act[id]=ak vk.key[ak].clickT=0 end
    return ak
end
function vk.release(id,x,y)
    local rk=vk.act[id]
    vk.act[id]=nil
    return rk
end

function vk.animPress(k)
    vk.animAct[k]=true vk.key[k].clickT=0
end
function vk.animRelease(k)
    vk.animAct[k]=false
end

function vk.update(dt)
    for k,v in pairs(vk.key) do
        if checkAct(k) then v.holdT=v.holdT+dt else v.holdT=0 end
    end
end
function vk.animUpdate(dt)
    for k,v in pairs(vk.key) do
        v.clickT=v.clickT+dt
    end
end
function vk.checkActive(name)
    if T.include(vk.act,name) then return true else return false end
end
function vk.draw()
    for k,v in pairs(vk.key) do
        if vk.anim and vkDraw[k] then vkDraw[k](k,v) else defaultVkDraw(k,v) end
    end
end
return vk