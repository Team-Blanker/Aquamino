local anim={}--animation的缩写

function anim.init()--第一帧不能用来画图，会出问题
    anim.e1cl=gc.newCanvas(160,320) anim.e1cr=gc.newCanvas(160,320)
    anim.e1cw=gc.newCanvas(320,320)
    gc.setLineWidth(20) gc.setColor(1,1,1)
    gc.setCanvas(anim.e1cl) gc.circle('line',160,160,150,4)
    gc.setCanvas(anim.e1cr) gc.circle('line',0,160,150,4)
    gc.setCanvas(anim.e1cw) gc.circle('line',160,160,150,4)
    gc.setCanvas()
    print(anim.e1cw:newImageData():getPixel(160,1))

    anim.e1stcf=function()
        gc.circle('fill',0,0,100,4)
    end
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
    gc.setColor(0,0,0)
    if scene.swapT>0 then
        local rect_w=1-((scene.swapT-keeptime)/intime)^2
        if scene.swapT>keeptime then
            gc.rectangle('fill',-960,-540,960*rect_w,1080)
            gc.rectangle('fill',960-960*rect_w,-540,960*rect_w,1080)
            gc.setColor(1,1,1)
            --gc.draw(anim.e1cl,-960+960*rect_w,0,0,1,1,160,160)
            --gc.draw(anim.e1cr, 960-960*rect_w,0,0,1,1,0,160)
        else
            gc.rectangle('fill',-960,-540,1920,1080)
            gc.setColor(1,1,1)
            --gc.draw(anim.e1cw,0,0,0,1,1,160,160)
        end
    else
        local sz=1920*(-(1-scene.outT/outtime)^2+1)
        gc.circle('fill',-960,960,sz,4) gc.circle('fill',960,-960,sz,4)
        gc.circle('fill',960,960,sz,4) gc.circle('fill',-960,-960,sz,4)
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