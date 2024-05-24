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
    else
        setColor(1,1,1)
        local k=max(1-beat*2,0)^3
        rect('fill',0,0,400,300*k)
    end
end
return bg