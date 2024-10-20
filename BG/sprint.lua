local sqrt2=1.4142135623731

local bg={}
function bg.init(BPM,offset,offsetBeat,introBeat,pcAnimTMax)
    bg.BPM,bg.time,bg.introBeat=BPM or 120,offset or 0,introBeat or 128
    bg.offsetBeat=offsetBeat or 0
    bg.pc=0 bg.postpc=0 bg.pcAnimT=0 bg.pcAnimTMax=pcAnimTMax or .25
end
function bg.update(dt)
    bg.time=bg.time+dt
    bg.pcAnimT=max(bg.pcAnimT-dt,0)
end
function  bg.newProgress(pc)
    bg.postpc=bg.pc*(1-bg.pcAnimT/bg.pcAnimTMax)+bg.postpc*(bg.pcAnimT/bg.pcAnimTMax)
    bg.pc=pc bg.pcAnimT=bg.pcAnimTMax
end
local alpha,beat,m,bt,clap, k
local p=8

local function lengthArg(t)
    return max(0,min(1,-8*abs(t-9/16)+9/2))
end

function bg.draw()
    beat=bg.time*bg.BPM/60-bg.offsetBeat
    m=1-beat%1
    bt=beat-bg.introBeat
    if bg.pc==1 then gc.clear(.15,.145,.09) else gc.clear(.1,.1,.1) end

    --gc.setColor(1,1,1)
    --gc.printf(floor(beat),font.Bender,0,0,1280,'center',0,.5,.5,640,font.height.Bender/2)

    if beat<0 then
        --nothing
    elseif beat<bg.introBeat then
        if bg.pc==1 then gc.setColor(1,.96,.6) else gc.setColor(.9,.9,.9) end
        for i=1,9 do
            if beat>9-i and (floor(beat)<bg.introBeat-4 or i>5) then
                local l=lengthArg((beat+i-1)%8)*120
                gc.rectangle('fill',-960  ,-530+120*(i-1),60+l,100)
                gc.rectangle('fill', 900-l, 550-120*i    ,60+l,100)
            end
        end
    else
        gc.setColor(1,1,1,m*.15)
        gc.rectangle('fill',-1000,-600,2000,1200)
        if bg.pc==1 then gc.setColor(1,.96,.6) else gc.setColor(1,1,1) end
        k=math.log(beat%4+1,2)
        gc.setLineWidth(36+36*k)
        gc.rectangle('line',-960*k,-960*k,1920*k,1920*k)

        if bg.pc==1 then gc.setColor(1,.96,.6) else gc.setColor(.9,.9,.9) end

        for i=1,9 do
            if beat>=bg.introBeat+1 or i%2==1 then
                local l=lengthArg((beat+i-1)%2)*80
                gc.rectangle('fill',-960  ,-530+120*(i-1),60+l,100)
            end
            if beat>=bg.introBeat+1 or i%2==0 then
                local l=lengthArg((beat+i)%2)*80
                gc.rectangle('fill', 900-l, 550-120*i    ,60+l,100)
            end
        end
    end

    if bg.pc==1 then gc.setColor(1,.96,.6) else gc.setColor(.9,.9,.9) end
    for i=1,9 do
        gc.rectangle('fill',-960,-530+120*(i-1),60,100)
        gc.rectangle('fill', 900,-530+120*(i-1),60,100)
    end

    if bg.pc==1 then gc.setColor(1,.96,.6) else gc.setColor(1,1,1) end
    gc.setLineWidth(40+(beat>=bg.introBeat and (20*max(2*m-1,0)) or 0))
    local P=bg.pc*(1-bg.pcAnimT/bg.pcAnimTMax)+bg.postpc*(bg.pcAnimT/bg.pcAnimTMax)
    gc.arc('line','open',0,0,450,-math.pi/2,(P*2-.5)*math.pi,64)
end
return bg