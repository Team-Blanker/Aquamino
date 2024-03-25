--[[
song info:
name: nega to posi  author: georhythm
]]
--该背景依靠外部传入时间变量。
local BPM=128
local offset=0
local loopStartBeat=96
local loopBeatLen=200

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
local function diamondPos(sz,p)
    --[[
    example:
    sz=3 p=5
          -3
        -4  -2
      O5      -1
    -6          -0
      -7      -B
        -8  -A
          -9
    return -2,1
    ]]
    local k=p/sz%4 local l=p%sz
    if k<1 then return sz-l,l elseif k<2 then return -l,sz-l elseif k<3 then return l-sz,-l else return l,l-sz end
end
function bg.draw()
    beat=(offset+bg.time)*BPM/60 intBeat=flore(beat)

    if beat<64 then
        if beat>=16 then
            local m=beat%4*4
            if flore(beat)~=31 then
            for i=0,7 do
                if i<=m%8-1 then
                setColor(1,1,1,.06+.02*i)
                rect('fill',m<8 and -960 or 0,-540+120*i,960,120)
                rect('fill',m<8 and 0 or -960,420-120*i,960,120)
                end
            end
            setColor(1,1,1,.2+.4*(beat>60 and 1-beat%.25*4 or beat>56 and 1-beat%.5*2 or beat>=48 and (1-beat%1) or 0))
            rect('fill',m<8 and -960 or 0,-540+flore(m%8)*120,960,120)
            rect('fill',m<8 and 0 or -960,420-flore(m%8)*120,960,120)
            end
        end

        if beat>=31 then gc.setColor(1,1,1,.1) rect('fill',-960,-540,1920,1080) end

        if beat%8<1 then
        setColor(1,1,1,.25*(1-beat%1))
        rect('fill',-960,-540,1920,1080)
        end

        if beat%8>=7 then
        setColor(1,1,1,.25*(1-beat%1))
        rect('fill',-960,-540,1920,1080)
        local m=(floor(beat%1*4%4)*2+1)/9
        setColor(1,1,1,.48)
        rect('fill',-960,-540*m,120,m*1080)
        rect('fill', 840,-540*m,120,m*1080)

        setColor(1,1,1,1-beat%1*2)
        else setColor(1,1,1,.8) end
        rect('fill',intBeat%8*120-960,-540,120,1080)
        rect('fill',840-intBeat%8*120,-540,120,1080)
    elseif beat<80 then
        setColor(1,1,1,.25*(65-beat))
        rect('fill',-960,-540,1920,1080)
        setColor(1,1,1,65-beat)
        rect('fill',-960,-540,120,1080)
        rect('fill', 840,-540,120,1080)
    elseif beat<96 then
        setColor(1,1,1,.25*(81-beat))
        rect('fill',-960,-540,1920,1080)
        for i=-7,0 do
            if beat+i/8>=80 then
            local m=flore(beat*4+i)%16
            setColor(1,1,1,.2+i*.05)
            rect('fill',-960+120*m,-540,120,1080)
            rect('fill',840-120*m,-540,120,1080)
            end
        end
    else--进入循环
        loopBeat=(beat-loopStartBeat)%200 intLoopBeat=flore(loopBeat)
        if loopBeat<44 then
            setColor(1,1,1,.25*(1-loopBeat)) rect('fill',-960,-540,1920,1080)

            for i=-7,0 do
                local m=flore(beat*4+i)%16
                setColor(1,1,1,.2+i*.05)
                rect('fill',-960+120*m,-540,120,1080)
                rect('fill',840-120*m,-540,120,1080)
            end

            for i=-4,0 do
                if loopBeat+i/4>=0 then
                local m=math.abs(8-flore(loopBeat*4+i)%16)
                setColor(1,1,1,.2+i*.05)
                rect('fill',-960,-540+120*m,1920,120)
                end
            end
            if loopBeat>=16 and loopBeat<40 then --local sz=flore(loopBeat%8)+1
                setColor(1,1,1,.025*(intLoopBeat%8+1)*(1-loopBeat%1))
                --rect('fill',-sz*120,-540,sz*240,1080)
                rect('fill',-960,-540,1920,1080)
            end
        elseif loopBeat<48 then
            setColor(1,1,1,.2*max(1-.55*flore((loopBeat-44)*3)/5,.45)+.02*max(flore((loopBeat-46)*4/3+1),0))
            local m=min(flore((loopBeat-44)*3),6)
            rect('fill',-960,420-m*192,1920,120+m*192)
            local s=max(flore((loopBeat-46)*4/3+1),0)
            setColor(1,1,1,.1*s)
            --local sz=(4-s)*120
            rect('fill',-840+120*s,-60,120,120) rect('fill',720-120*s,-60,120,120)
        elseif loopBeat<152 then
            setColor(1,1,1,.25*(49-loopBeat)) rect('fill',-960,-540,1920,1080)
            setColor(0,1,.5,.15) rect('fill',-960,-540,1920,1080)

            if loopBeat<140 then
                if loopBeat>=76 and loopBeat<80 then
                    setColor(1,1,1,.8*(77-loopBeat))
                    rect('fill',-960,-60,1920,120) rect('fill',-60,-540,120,1080)

                    local m=14-flore(loopBeat%4*3)
                    setColor(1,1,1,.08*(12-m)/8)
                    for i=-m,m do
                        if i==-m or i==m then rect('fill',-60+120*i,-60,120,120)
                        else
                            rect('fill',-60+120*i,-60-120*(m-math.abs(i)),120,120)
                            rect('fill',-60+120*i,-60+120*(m-math.abs(i)),120,120)
                        end
                    end
                elseif loopBeat>=108 and loopBeat<112 then
                    local m=loopBeat%4-1
                    setColor(1,1,1,.5)
                    rect('fill',-540,-1620+1080*flore(m*9)/9,120,1080)
                    rect('fill', 420,  540-1080*flore(m*9)/9,120,1080)
                    rect('fill',-1620+1080*flore(m*9)/9, 420,1080,120)
                    rect('fill',  540-1080*flore(m*9)/9,-540,1080,120)
                else local m=flore(loopBeat*8%8+1)
                setColor(1,1,1,.3*(9-m)/8)
                rect('fill',-960,-540,120*m,1080)
                rect('fill',960-120*m,-540,120*m,1080)

                if loopBeat%8>=7 then
                    local n=flore(loopBeat%1*16)
                    setColor(1,1,1,.2)
                    for i=1,7 do
                        rect('fill',-960+(i+n)%2*120,-540+120*(i+n-8),120,120)
                        rect('fill', 840-(i+n)%2*120, 420-120*(i+n-8),120,120)
                    end
                    setColor(1,1,1,.5)
                    rect('fill',-960+n%2*120,-540+120*n,120,120)
                    rect('fill', 840-n%2*120, 420-120*n,120,120)
                end
                end
            else setColor(1,1,1,.25*(1-loopBeat%4)) rect('fill',-960,-540,1920,1080) end

            for i=1,3 do
                if loopBeat-i/3>48 then
                setColor(1,1,1,.1*(4-i))
                local x,y=diamondPos(3,flore(beat*3%12)-i)
                rect('fill',120*x-60,-120*y-60,120,120)
                rect('fill',-120*x-60,120*y-60,120,120)
                end
            end
            setColor(1,1,1,.4+.4*max(1.5-beat%1*3,0))
            local x,y=diamondPos(3,flore(beat*3%12))
            rect('fill',120*x-60,-120*y-60,120,120)
            rect('fill',-120*x-60,120*y-60,120,120)
            setColor(1,1,1,.8*(1-beat%1*1.5))
            if loopBeat<140 then
                if loopBeat<76 or loopBeat>=80 and loopBeat<108 or loopBeat>=112 then
                    if loopBeat%2<1 then rect('fill',-960,-180,540,120) rect('fill',-960,60,540,120)
                        rect('fill',420,-180,540,120) rect('fill',420,60,540,120)
                    else rect('fill',-180,-540,120,120) rect('fill',60,-540,120,120)
                        rect('fill',-180,420,120,120) rect('fill',60,420,120,120)
                    end
                end
            else
                if loopBeat%4<1 then rect('fill',-960,-60,660,120) rect('fill', 300,-60,660,120) end
            end
        else
            setColor(1,1,1,.8*((153-loopBeat)*1.5))
            rect('fill',-960,-60,660,120) rect('fill', 300,-60,660,120)
            setColor(1,1,1,.25*(153-loopBeat)) rect('fill',-960,-540,1920,1080)

            local m=flore(loopBeat%4*4)
            setColor(1,1,1,loopBeat<168 and .1 or .1+.025*m)
            for i=-m,m do
                if i==-m or i==m then rect('fill',-60+120*i,-60,120,120)
                else
                    rect('fill',-60+120*i,-60-120*(m-math.abs(i)),120,120)
                    rect('fill',-60+120*i,-60+120*(m-math.abs(i)),120,120)
                end
            end

            if loopBeat>=168 then
            setColor(1,1,1,.25*(169-loopBeat)) rect('fill',-960,-540,1920,1080)
            end

            for i=-7,0 do
                if loopBeat+i/8>=184 then
                local m=flore(beat*4+i)%32
                setColor(1,1,1,.2+i*.05)
                rect('fill',-960+120*m,-540,120,1080)
                rect('fill',840-120*m,-540,120,1080)
                end
            end
        end
    end
end
return bg