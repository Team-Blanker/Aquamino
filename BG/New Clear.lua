local setColor,setLineWidth=gc.setColor,gc.setLineWidth
local circle,arc,line=gc.circle,gc.arc,gc.line
local stencil,stencilTest=gc.stencil,gc.setStencilTest

local bg={}
local BPM=120
local time=0
local beat=0
local parTime=0
local timeBar=24
function bg.init()
    time=0
    beat=0
    parTime=0
end
function bg.update(dt)
    time=time+dt
    beat=time*BPM/60

    parTime=parTime+dt
end
local tau=2*math.pi
local sin,cos=math.sin,math.cos

local neodymiumStencil=function ()
    setLineWidth(20)
    for i=1,24 do
    line(-cos(tau*i/24)*720,-sin(tau*i/24)*720,cos(tau*i/24)*720,sin(tau*i/24)*720)
    end
end
function bg.draw()
    local sz=1+max(.25-beat%2,0)
    gc.clear(.1,.15,.2)

    --[[for i=0,timeBar-1 do
        setColor(1,1,1,.25*(.5-(beat+(i-24)/12)%4)/.5)
        arc('line','open',0,0,330,tau*(i-6)/24,tau*(i-5)/24)
    end
    setLineWidth(20)
    setColor(.1,.15,.2)
    for i=1,24 do
    line(-cos(tau*i/24)*720,-sin(tau*i/24)*720,cos(tau*i/24)*720,sin(tau*i/24)*720)
    end]]
    stencil(neodymiumStencil,'replace',1)
    stencilTest('notequal',1)
    setLineWidth(300)
    setColor(1,1,1,.2)
    for i=0,timeBar-1 do
        arc('line','open',0,0,330,tau*(i-6)/24,tau*(i-5)/24)
    end
    for i=0,timeBar-1 do
        setColor(1,1,1,.25*(.5-(beat+(i-24)/12)%4)/.5)
        arc('line','open',0,0,330,tau*(i-6)/24,tau*(i-5)/24)
    end
    stencilTest()

    setColor(1,1,1,.2)
    setLineWidth(6)
    circle('line',0,0,500)

    setLineWidth(6)
    local l=0
    if beat%16>=14 then
        l=beat%16<15 and max(.5-beat%(1/3),0) or max(1-(beat+1)%2*2,0)
    elseif beat%32>=24 then
        l=max(1-beat%2*2,0)
    end
    for i=1,8 do
        local t=beat/16%1+i/8
        setColor(1,1,1,.2+.4*l)
        circle('fill',720*cos(t*tau),720*sin(t*tau),60*sz)
        setColor(1,1,1)
        circle('line',720*cos(t*tau),720*sin(t*tau),55*sz)
    end

    for i=0,4 do
        setLineWidth(3)
        setColor(1,1,1,.2*(5-i-beat%.5*2)/5)
        circle('line',0,0,500+40*(i+beat%.5*2))
    end

    for i=0,min(beat%8*2,11) do
        local t=(beat/8-i/16)%1
        local s=1-t*2
        local r=720-480*t
        local a=min(1,(7-beat%8)/3)
        if s>=0 and t>=0 then
            setLineWidth(10*s)
            setColor(.8,.9,.77,.2*a)
            circle('fill',r*cos(t*tau),-270+r*sin(t*tau),75*s)
            setColor(.8,.9,.77,a)
            circle('line',r*cos(t*tau),-270+r*sin(t*tau),70*s)
            setColor(.96,.81,.54,.2*a)
            circle('fill',-r*cos(t*tau),270-r*sin(t*tau),75*s)
            setColor(.96,.81,.54,a)
            circle('line',-r*cos(t*tau),270-r*sin(t*tau),70*s)
        end
    end
    if beat>=4 then
    for i=0,min((beat+4)%8*2,11) do
        local t=((beat+4)/8-i/16)%1
        local s=1-t*2
        local r=720-480*t
        local a=min(1,(7-(beat+4)%8)/3)
        if s>=0 and t>=0 then
            setLineWidth(10*s)
            setColor(.96,.81,.54,.2*a)
            circle('fill',-270+r*sin(t*tau),r*-cos(t*tau),75*s)
            setColor(.96,.81,.54,a)
            circle('line',-270+r*sin(t*tau),r*-cos(t*tau),70*s)
            setColor(.8,.9,.77,.2*a)
            circle('fill',270-r*sin(t*tau),-r*-cos(t*tau),75*s)
            setColor(.8,.9,.77,a)
            circle('line',270-r*sin(t*tau),-r*-cos(t*tau),70*s)
        end
    end
    end
    --setColor(1,1,1)
    --gc.printf(floor(beat),font.JB,0,480,8000,'center',0,.6,.6,4000,font.height.JB/2)
end
return bg