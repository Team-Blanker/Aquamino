--[[
song info:
name: nega to posi  author: georhythm
]]
local BPM=130
local offset=0.922
local loopStartBeat=136
local loopBeatLen=224

local M=mymath
local bg={}

local nCanvas,pCanvas=gc.newCanvas(100,100),gc.newCanvas(100,100)
gc.setColor(1,1,1)
gc.setCanvas(nCanvas)
    gc.rectangle('fill',0,40,100,20)
gc.setCanvas(pCanvas)
    gc.rectangle('fill',0,40,100,20)
    gc.rectangle('fill',40,0,20,100)
gc.setCanvas()
local function nsDraw(alpha)
    gc.setColor(1,1,1,alpha)
    gc.draw(nCanvas,-450,0,0,3-alpha,3-alpha,50,50)
end
local function psDraw(alpha)
    gc.setColor(1,1,1,alpha)
    gc.draw(pCanvas, 450,0,0,3-alpha,3-alpha,50,50)
end
local function blink(a)
    gc.setColor(1,1,1,.2*a)
    gc.rectangle('fill',-1000,-600,2000,1200)
end
function bg.init()
    bg.progressN=0 bg.progressP=0
end
function bg.sendProgress(n,p)
    bg.progressN=n bg.progressP=p
end

local rn,gn,bn, rp,gp,bp
function bg.draw()
    local beat=(offset+scene.time)*BPM/60
    if beat>loopStartBeat then gc.clear(COLOR.hsv(beat/4,1,.14))
    else gc.clear(.03,.03,.03) end

    rn,gn,bn=1-bg.progressN,1-.75*bg.progressN,1
    rp,gp,bp=1,1-.25*bg.progressP,1-bg.progressP

    psDraw(1) nsDraw(1)
    if beat>=8 then
        local a=max(1.25-(beat-8))/1.25
        gc.setLineWidth(24)
        gc.setColor(1,1,1,a)
        gc.circle('line',-450,0,240+100*(1-a))
        gc.circle('line', 450,0,240+100*(1-a))

        if beat>=24 and beat<40 then
            gc.setColor(1,1,1)
            gc.setColor(1,1,1,1-beat%1)
            gc.circle('fill',-270+180*floor(beat%4),0,40,4)
        end

        if beat>=40 then--负环
            for i=0,7 do
                if (beat-i/8)%4<1 then
                    gc.setColor(M.lerp(rn,1,1-i/8),M.lerp(gn,1,1-i/8),M.lerp(bn,1,1-i/8),.5)
                    gc.setLineWidth(20)
                    gc.circle('line',-450,0,240+25*i)
                end
            end
        end
        if beat>=41 then--正环
            for i=0,7 do
                if (beat+2-i/8)%4<1 then
                    gc.setColor(M.lerp(rp,1,1-i/8),M.lerp(gp,1,1-i/8),M.lerp(bp,1,1-i/8),.5)
                    gc.setLineWidth(20)
                    gc.circle('line', 450,0,240+25*i)
                end
            end
        end

        local b=max(1.25-(beat-8)%32,0)/1.25
        psDraw(b) nsDraw(b) blink(b)
        local b1=(1.25-max(beat-56,0))/1.25
        psDraw(b1) nsDraw(b1) blink(beat>=56 and b1 or 0)
        local b2=(1.25-max(beat-88,0))/1.25
        psDraw(b2) nsDraw(b2) blink(beat>=88 and b2 or 0)
    end
    if beat>loopStartBeat then
        local loopBeat=(beat-loopStartBeat)%loopBeatLen
        for i=0,6 do
        local c=(1.25-max(loopBeat-(i~=4 and 16+32*i or 100000),0))/1.25
        psDraw(c) nsDraw(c)
        if loopBeat>(i~=4 and 16+32*i or 100000) then blink(c) end
        end
    end

    --gc.setColor(1,1,1)
    --gc.printf(""..floor(beat),font.Bender,0,0,1000,'center',0,1,1,500,84)
end
return bg