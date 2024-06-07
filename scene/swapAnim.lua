local anim={}--animation的缩写

function anim.init()--第一帧不能用来画图，会出问题
end
function anim.cover(intime,keeptime,outtime,r,g,b)
    if scene.swapT>keeptime then 
        gc.setColor(r,g,b,1-((scene.swapT-keeptime)/intime))
    elseif scene.swapT>0 then
        gc.setColor(r,g,b)
    else
        gc.setColor(r,g,b,scene.outT/outtime)
    end
    gc.rectangle('fill',-960,-540,1920,1080)
end

function anim.enterMenu(intime,keeptime,outtime)
    gc.setColor(.05,.05,.05)
    if scene.swapT>0 then
        local rect_w=1-((scene.swapT-keeptime)/intime)^3
        if scene.swapT>keeptime then
            gc.rectangle('fill',-960,-540,960*rect_w,1080)
            gc.rectangle('fill',960-960*rect_w,-540,960*rect_w,1080)
            gc.setColor(1,1,1)
            gc.setLineWidth(15)
            gc.arc('line','open',-960+960*rect_w,0,150,math.pi/2,3*math.pi/2,2)
            gc.arc('line','open', 960-960*rect_w,0,150,-math.pi/2, math.pi/2,2)
        else
            local angle=mymath.clamp((scene.swapT/keeptime-1/2)*2,0,1)^2*math.pi/2
            gc.rectangle('fill',-960,-540,1920,1080)
            gc.setColor(1,1,1)
            gc.setLineWidth(15)
            gc.arc('line','closed',0,0,150,-math.pi/2+angle,math.pi+angle,3)
        end
    else
        local sz=1920*(-(1-scene.outT/outtime)^3+1)
        gc.circle('fill',-960,960,sz,4) gc.circle('fill',960,-960,sz,4)
        gc.circle('fill',960,960,sz,4) gc.circle('fill',-960,-960,sz,4)
        gc.setColor(1,1,1)
        gc.setLineWidth(1920-sz<=150 and 15 or 5+10*(1920-sz-150)/(1920-150))
        gc.arc('line','open',0,0,max(150,1920-sz),-math.pi/2,3*math.pi/2,4)
    end
end
local r6=960*2/3^.5 local r4=1500
function anim.confEnter(intime,keeptime,outtime)
    if scene.swapT>0 then
        local w=1-((scene.swapT-keeptime)/intime)^2
        if scene.swapT>keeptime then
            local l=.05+.05*w
            gc.setColor(l,l,l)
            gc.setLineWidth(1920*w)
            gc.arc('line','closed',0,0,r6,math.pi/2,5*math.pi/2,6)
        else
            gc.setColor(.1,.1,.1)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        gc.setColor(.1,.1,.1)
        local w=(-(1-scene.outT/outtime)^2+1)
        gc.setLineWidth(1920*w)
        gc.arc('line','closed',0,0,r6,math.pi/2,5*math.pi/2,6)
    end
end
function anim.confExit(intime,keeptime,outtime)
    if scene.swapT>0 then
        local w=1-((scene.swapT-keeptime)/intime)^2
        if scene.swapT>keeptime then
            local l=.1*(1-w)+.05
            gc.setColor(l,l,l)
            gc.setLineWidth(3000*w/2^.5)
            gc.arc('line','closed',0,0,r4,math.pi/2,5*math.pi/2,4)
        else
            gc.setColor(.05,.05,.05)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        gc.setColor(.05,.05,.05)
        local w=(-(1-scene.outT/outtime)^2+1)
        gc.setLineWidth(3000*w/2^.5)
        gc.arc('line','closed',0,0,r4,math.pi/2,5*math.pi/2,4)
    end
end
function anim.confSelect(intime,keeptime,outtime)
    if scene.swapT>0 then
        local w=1-((scene.swapT-keeptime)/intime)
        if scene.swapT>keeptime then
            gc.setColor(.1,.1,.1)
            gc.setLineWidth(1920*w)
            gc.arc('fill','closed',0,0,r6*w,math.pi/2,5*math.pi/2,6)
        else
            gc.setColor(.1,.1,.1)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        gc.setColor(.1,.1,.1)
        local w=(-(1-scene.outT/outtime)+1)
        gc.setLineWidth(1920*w)
        gc.arc('line','closed',0,0,r6,math.pi/2,5*math.pi/2,6)
    end
end
function anim.confBack(intime,keeptime,outtime)
    if scene.swapT>0 then
        local w=1-((scene.swapT-keeptime)/intime)
        if scene.swapT>keeptime then
            gc.setColor(.1,.1,.1)
            gc.setLineWidth(1920*w)
            gc.arc('line','closed',0,0,r6,math.pi/2,5*math.pi/2,6)
        else
            gc.setColor(.1,.1,.1)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        local w=(-(1-scene.outT/outtime)+1)
        gc.setColor(.1,.1,.1)
        gc.setLineWidth(1920*w)
        gc.arc('fill','closed',0,0,r6*w,math.pi/2,5*math.pi/2,6)
    end
end
function anim.enter2(intime,keeptime,outtime)
    local rect_w=(1-((scene.swapT-keeptime)/intime))^2
    gc.setColor(0,0,0)
    if scene.swapT>0 then
        if scene.swapT>keeptime then
            gc.rectangle('fill',-960*rect_w,-550,1920*rect_w,1100)
        else
            gc.rectangle('fill',-960,-540,1920,1080)
            gc.rectangle('line',-960,-540,1920,1080)
        end
    else
        for i=1,8 do for j=1,9 do
            if scene.outT/outtime>(j+8)/18 then gc.setColor(0,0,0)
                gc.rectangle('fill',-960+120*(2*i-2),-540+120*(j-1),120,120)
                gc.rectangle('fill',-960+120*(2*i-1),-540+120*(9-j),120,120)
            elseif scene.outT/outtime>(j-1)/18 then gc.setColor(0,0,0,.625)
                gc.rectangle('fill',-960+120*(2*i-2),-540+120*(j-1),120,120)
                gc.rectangle('fill',-960+120*(2*i-1),-540+120*(9-j),120,120)
            end
        end end
    end
end
return anim