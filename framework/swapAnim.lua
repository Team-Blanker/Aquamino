local anim={}

local goTxt
function anim.init()--第一帧不能用来画图，会出问题
    goTxt={txt=gc.newText(font.Bender_B)}
    goTxt.txt:add("LET'S GO")
    goTxt.w,goTxt.h=goTxt.txt:getDimensions()
end
function anim.cover(inT,keepT,outT,r,g,b)
    if scene.swapT>keepT then
        gc.setColor(r,g,b,1-((scene.swapT-keepT)/inT))
    elseif scene.swapT>0 then
        gc.setColor(r,g,b)
    else
        gc.setColor(r,g,b,scene.outT/outT)
    end
    gc.rectangle('fill',-960,-540,1920,1080)
end

local s2=2^.5
function anim.enterMenu(inT,keepT,outT)
    gc.setColor(.05,.05,.05)
    if scene.swapT>0 then
        if scene.swapT>keepT then
            local sz=(1-((scene.swapT-keepT)/inT)^3)*1920
            local hsz=1920-sz
            gc.circle('fill',-960,960,sz,4) gc.circle('fill',960,-960,sz,4)
            gc.circle('fill',960,960,sz,4) gc.circle('fill',-960,-960,sz,4)
            gc.setColor(1,1,1)
            if hsz<=150 then
            gc.setLineWidth((10+(150-hsz)/150*70)*s2)
            gc.arc('line','open',0,0,80+hsz/150*70,-math.pi/2,3*math.pi/2,4)
            else
            gc.setLineWidth((5+5*(1920-sz-150)/(1920-150))*s2)
            gc.arc('line','open',0,0,max(150,1920-sz),-math.pi/2,3*math.pi/2,4)
            end
        else
            local s=myMath.clamp((scene.swapT/keepT-1/2)*2,0,1)^3
            gc.rectangle('fill',-960,-540,1920,1080)
            gc.setColor(1,1,1)
            gc.arc('fill','closed',0,0,160,-math.pi/2,math.pi,3)
        end
    else
        local sz=1920*(-(1-scene.outT/outT)^3+1)
        local hsz=1920-sz
        gc.circle('fill',-960,960,sz,4) gc.circle('fill',960,-960,sz,4)
        gc.circle('fill',960,960,sz,4) gc.circle('fill',-960,-960,sz,4)
        gc.setColor(1,1,1)
        if hsz<=150 then
        gc.setLineWidth((10+(150-hsz)/150*70)*s2)
        gc.arc('line','open',0,0,80+hsz/150*70,-math.pi/2,3*math.pi/2,4)
        else
        gc.setLineWidth((5+5*(1920-sz-150)/(1920-150))*s2)
        gc.arc('line','open',0,0,max(150,1920-sz),-math.pi/2,3*math.pi/2,4)
        end
    end
end

local rn=0
local x,y=0,0
function anim.enterGame(inT,keepT,outT)
    gc.setColor(.05,.05,.05)
    if scene.swapT>0 then
        if scene.swapT>keepT then
            local t=(scene.swapT-keepT)/inT
            local sz=(1-t)^3
            gc.rectangle('fill',-960,-540,960*sz,1080)
            gc.rectangle('fill',960-960*sz,-540,960*sz,1080)
            gc.setColor(1,1,1,(1-t)*1.5-.5)
            gc.draw(goTxt.txt,0,0,0,4-3*sz,4-3*sz,goTxt.w/2,goTxt.h/2)
        else
            local t=max(scene.swapT/keepT*3-2,0)
            if floor(t*20)~=rn then x,y=64*t*(rand()-.5),64*t*(rand()-.5) rn=floor(t*20) end
            gc.rectangle('fill',-960,-540,1920,1080)
            gc.setColor(1,1,1)
            gc.draw(goTxt.txt,x,y,0,1,1,goTxt.w/2,goTxt.h/2)
        end
    else
        local t=scene.outT/outT
        local r=1920*t
        gc.circle('fill',-960,960,r,4) gc.circle('fill',960,-960,r,4)
        gc.circle('fill',960,960,r,4) gc.circle('fill',-960,-960,r,4)
        gc.setColor(1,1,1,2*t-1)
        gc.draw(goTxt.txt,0,0,0,4-3*t,4-3*t,goTxt.w/2,goTxt.h/2)
    end
end

local r6=960*2/3^.5
function anim.confSelect(inT,keepT,outT)
    if scene.swapT>0 then
        local w=1-((scene.swapT-keepT)/inT)
        if scene.swapT>keepT then
            gc.setColor(.1,.1,.1)
            gc.setLineWidth(1920*w)
            gc.arc('fill','closed',0,0,r6*w,math.pi/2,5*math.pi/2,6)
        else
            gc.setColor(.1,.1,.1)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        gc.setColor(.1,.1,.1)
        local w=(-(1-scene.outT/outT)+1)
        gc.setLineWidth(1920*w)
        gc.arc('line','closed',0,0,r6,math.pi/2,5*math.pi/2,6)
    end
end
function anim.confBack(inT,keepT,outT)
    if scene.swapT>0 then
        local w=1-((scene.swapT-keepT)/inT)
        if scene.swapT>keepT then
            gc.setColor(.1,.1,.1)
            gc.setLineWidth(1920*w)
            gc.arc('line','closed',0,0,r6,math.pi/2,5*math.pi/2,6)
        else
            gc.setColor(.1,.1,.1)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        local w=(-(1-scene.outT/outT)+1)
        gc.setColor(.1,.1,.1)
        gc.setLineWidth(1920*w)
        gc.arc('fill','closed',0,0,r6*w,math.pi/2,5*math.pi/2,6)
    end
end

function anim.enter2(inT,keepT,outT)
    local rect_w=(1-((scene.swapT-keepT)/inT))^2
    gc.setColor(0,0,0)
    if scene.swapT>0 then
        if scene.swapT>keepT then
            gc.rectangle('fill',-960*rect_w,-550,1920*rect_w,1100)
        else
            gc.rectangle('fill',-960,-540,1920,1080)
            gc.rectangle('line',-960,-540,1920,1080)
        end
    else
        for i=1,8 do for j=1,9 do
            if scene.outT/outT>(j+8)/18 then gc.setColor(0,0,0)
                gc.rectangle('fill',-960+120*(2*i-2),-540+120*(j-1),120,120)
                gc.rectangle('fill',-960+120*(2*i-1),-540+120*(9-j),120,120)
            elseif scene.outT/outT>(j-1)/18 then gc.setColor(0,0,0,.625)
                gc.rectangle('fill',-960+120*(2*i-2),-540+120*(j-1),120,120)
                gc.rectangle('fill',-960+120*(2*i-1),-540+120*(9-j),120,120)
            end
        end end
    end
end

function anim.enterUL(inT,keepT,outT)
    if scene.swapT>0 then
        if scene.swapT>keepT then
        local w=1-(scene.swapT-keepT)/inT
            gc.setColor(.05,.05,.05)
            gc.circle('fill',-960,-540,3000*w,4)
        else
            gc.setColor(.05,.05,.05)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        local w=-(1-scene.outT/outT)+1
        gc.setColor(.05,.05,.05)
        gc.circle('fill',960,540,3000*w,4)
    end
end
function anim.enterUR(inT,keepT,outT)
    if scene.swapT>0 then
        if scene.swapT>keepT then
        local w=1-(scene.swapT-keepT)/inT
            gc.setColor(.05,.05,.05)
            gc.circle('fill',960,-540,3000*w,4)
        else
            gc.setColor(.05,.05,.05)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        local w=-(1-scene.outT/outT)+1
        gc.setColor(.05,.05,.05)
        gc.circle('fill',-960,540,3000*w,4)
    end
end
function anim.enterDL(inT,keepT,outT)
    if scene.swapT>0 then
        if scene.swapT>keepT then
        local w=1-(scene.swapT-keepT)/inT
            gc.setColor(.05,.05,.05)
            gc.circle('fill',-960,540,3000*w,4)
        else
            gc.setColor(.05,.05,.05)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        local w=-(1-scene.outT/outT)+1
        gc.setColor(.05,.05,.05)
        gc.circle('fill',960,-540,3000*w,4)
    end
end
function anim.enterDR(inT,keepT,outT)
    if scene.swapT>0 then
        if scene.swapT>keepT then
        local w=1-(scene.swapT-keepT)/inT
            gc.setColor(.05,.05,.05)
            gc.circle('fill',960,540,3000*w,4)
        else
            gc.setColor(.05,.05,.05)
            gc.rectangle('fill',-960,-540,1920,1080)
        end
    else
        local w=-(1-scene.outT/outT)+1
        gc.setColor(.05,.05,.05)
        gc.circle('fill',-960,-540,3000*w,4)
    end
end
return anim