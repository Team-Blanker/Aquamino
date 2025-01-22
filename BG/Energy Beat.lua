--[[
song info:
name: Energy Beat  author: T-Malu
]]
--该背景依靠外部传入时间变量。
local BPM=126
local offset=-0.556
local loopStartBeat=168
local loopBeatLen=128

local flore,ceil,max,min=math.floor,math.ceil,math.max,math.min

local rect,setColor=gc.rectangle,gc.setColor

local M=myMath
local bg={}
function bg.init()
    bg.time=0
end
function bg.setTime(time)
    bg.time=time
end
local beat,intBeat, loopBeat,intLoopBeat
local tau=2*math.pi
function bg.draw()
    gc.clear(.05,.05,.05)
    beat=(offset+bg.time)*BPM/60 intBeat=flore(beat)
    if beat<4 then
        setColor(1,1,1,.5)
        local h=(intBeat+1)*135
        for i=0,3,3 do
            gc.rectangle('fill',-960+480*i+60,-570,360,h)
            gc.rectangle('fill',-960+480*i+60,570-h,360,h)
        end
    else
        if beat<6 then
            setColor(1,1,1,.5+.15*max(5-beat,0))
            local s=max(1-beat%2,0)
            local k=1-2.5*s*s+1.5*s

            gc.arc('fill','closed',0,0,100,-(k-1)*tau/8,tau*(7/8-k/8),3)
            for i=0,3,3 do
                gc.rectangle('fill',-960+480*i+60,-570,360,540+k*270*(1-i%2*2))
                gc.rectangle('fill',-960+480*i+60,30+k*270*(1-i%2*2),360,1080)
            end
        else
            if beat<160 then setColor(1,1,1,.5+.15*max(1-(beat-4)%32,0))
            elseif beat<loopStartBeat then setColor(1,1,1,.5)
            else setColor(1,1,1,.5+.15*max(1-(beat-loopStartBeat)%32,0)) end
            local s=max(1-beat%2,0)
            local k=1+s-2*s*s
            local n=beat%4<2 and 0 or 1
            local a,b=270,540

            for i=0,3,3 do
                gc.rectangle('fill',-960+480*i+60,-570,360,a+b*(((i+n)%2)==0 and k or 1-k))
                gc.rectangle('fill',-960+480*i+60,570-a-b*(((i+n)%2)==0 and 1-k or k),360,1080)
            end
            local st=(beat%4<2 and 1-k or k)*tau/4
            gc.arc('fill','closed',0,0,100,st,tau*3/4+st,3)
            if beat>=36 then
                gc.setLineWidth(8)
                gc.arc('line','closed',0,0,100+100*min((beat-36)*2,1),-st,tau*3/4-st,3)
            end
            if beat>=132 and beat<=164 then
                local d=beat%4<2 and 1 or -1
                for i=-3.5,3.5 do
                    if (beat*8+i-4)%16<8 then
                    gc.rectangle('fill',120*d*i-30,-510,60,120)
                    gc.rectangle('fill',-120*d*i-30,390,60,120)
                    end
                end
            end
            --[[if beat<loopStartBeat then
            else
                for i=1,16 do
                    local cv,sv=cos(tau*(i+beat*4)/16),sin(tau*(i+beat*4)/16)
                    gc.circle('fill',200*(2^.5*cv*cos(tau*beat/12)+sv*sin(tau*beat/12)),200*sv,20,4)
                end
            end]]
            if beat>=loopStartBeat then
                gc.setLineWidth(8*2^(beat%2*3))
                gc.arc('line','closed',0,0,100+100*2^(beat%2*3),-st,tau*3/4-st,3)
            end
        end
    end
end
return bg