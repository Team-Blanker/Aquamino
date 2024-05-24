--[[
song info:
name: Energy Beat  author: T-Malu
]]
--该背景依靠外部传入时间变量。
local BPM=126
local offset=-0.556
local loopStartBeat=96
local loopBeatLen=128

local flore,ceil,max,min=math.floor,math.ceil,math.max,math.min

local rect,setColor=gc.rectangle,gc.setColor

local M=mymath
local bg={}
function bg.init()
    bg.time=0
end
function bg.setTime(time)
    bg.time=time
end
local beat,intBeat, loopBeat,intLoopBeat
function bg.draw()
    beat=(offset+bg.time)*BPM/60 intBeat=flore(beat)
    if beat<4 then
        setColor(1,1,1,.5)
        local h=(intBeat+1)*135
        for i=0,3 do
            gc.rectangle('fill',-960+480*i+60,-570,360,h)
            gc.rectangle('fill',-960+480*i+60,570-h,360,h)
        end
    elseif beat<6 then
        setColor(1,1,1,.5)
        local k=max(1-beat%2*2,0)^3
        local n=beat%4<2 and 1-k or k
        for i=0,3 do
            gc.rectangle('fill',-960+480*i+60,-570,360,540+n*270*(1-i%2*2))
            gc.rectangle('fill',-960+480*i+60,30+n*270*(1-i%2*2),360,1080)
        end
    else
        setColor(1,1,1,.5)
        local k=max(1-beat%2*2,0)^2
        local n=beat%4<2 and 1 or 0
        local a,b=270,540
        for i=0,3 do
            gc.rectangle('fill',-960+480*i+60,-570,360,a+b*(((i+n)%2)==0 and k or 1-k))
            gc.rectangle('fill',-960+480*i+60,570-a-b*(((i+n)%2)==0 and 1-k or k),360,1080)
        end
    end
end
return bg