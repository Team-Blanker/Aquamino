local bg={}
local ins,rem=table.insert,table.remove
function bg.init(BPM,offset,offsetBeat,pcAnimTMax)
    bg.BPM,bg.time=BPM or 120,offset or 0
    bg.offsetBeat=offsetBeat or 0
    bg.anim={} bg.pc=0 bg.l=0
end
function bg.update(dt)
    bg.time=bg.time+dt
    bg.l=min(bg.l+dt,bg.pc)
    for i=#bg.anim,1,-1 do bg.anim[i]=bg.anim[i]+dt
        if bg.anim[i]>=1 then rem(bg.anim,i) end
    end
end
function  bg.newProgress(pc)
    bg.pc=pc
    ins(bg.anim,0)
end
local beat
function bg.draw()
    beat=bg.time*bg.BPM/60-bg.offsetBeat
    m=1-beat%1
    gc.setLineWidth(1920/64)
    for i=0,1,1/64 do
        gc.setColor(.5,1,.875,i*bg.l/2)
        gc.circle('line',0,0,1920*i)
    end
    local k
    for i=1,#bg.anim do
        k=bg.anim[i]-(bg.anim[i])%(1/64)
        for j=1,4 do
        gc.setColor(.5,1,.875,j/4*(.2))
        gc.circle('line',0,0,1920*(k+(j-1)/64))
        end
    end
end
return bg