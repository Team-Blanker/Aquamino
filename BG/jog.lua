local bg={}
function bg.init(BPM,offset,offsetBeat,pcAnimTMax)
    bg.BPM,bg.time=BPM or 120,offset or 0
    bg.offsetBeat=offsetBeat or 0
    bg.pc=0 bg.postpc=0 bg.pcAnimT=0 bg.pcAnimTMax=pcAnimTMax or .25
    bg.swing=.01
end
function bg.update(dt)
    bg.time=bg.time+dt
    bg.pcAnimT=max(bg.pcAnimT-dt,0)
end
function  bg.newProgress(pc)
    bg.postpc=bg.pc*(1-bg.pcAnimT/bg.pcAnimTMax)+bg.postpc*(bg.pcAnimT/bg.pcAnimTMax)
    bg.pc=pc bg.pcAnimT=bg.pcAnimTMax
end
local alpha,beat,m,clap, k
local p=8
function bg.draw()
    beat=bg.time*bg.BPM/60-bg.offsetBeat
    m=1-beat%1
    --if bg.pc==1 then gc.clear(0,.15,.15) else gc.clear(0,0,0) end
    gc.clear(0,.15,.15)

    gc.setColor(1,1,1)
    for i=0,3 do for j=1,p do
        gc.push()
        gc.rotate( (j%p/p)*2*math.pi*(i%2*2-1)+(i%2*2-1)*sin(beat%16/4*math.pi)*.01*math.pi)
        --gc.circle('fill',540+40*max(2*m-1,0)+180*i,0,25*(1+.4*i)*min(beat*4,1),4)
        gc.circle('fill',540+180*i,0,25*(1+.4*i),4)
        gc.pop()
    end end

    if bg.pc==1 then gc.setColor(.6,1,1) else gc.setColor(1,1,1) end
    gc.setLineWidth(40)
    local P=bg.pc*(1-bg.pcAnimT/bg.pcAnimTMax)+bg.postpc*(bg.pcAnimT/bg.pcAnimTMax)
    gc.arc('line','open',0,0,450,-math.pi/2,(P*2-.5)*math.pi,120)
end
return bg