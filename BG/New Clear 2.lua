local setColor,setLineWidth=gc.setColor,gc.setLineWidth
local circle,arc,line=gc.circle,gc.arc,gc.line
local stencil,stencilTest=gc.stencil,gc.setStencilTest

local tau=2*math.pi
local sin,cos=math.sin,math.cos

local M=myMath

local bg={}
local BPM=120
local time=0
local beat=0
local parTime=0
local timeBar=24

local insTime=0
local bubbleDensity=18
local bbList={}
function bg.init()
    time=0
    beat=0
    parTime=0
end
function bg.newBubble()
    local nb={x=4000*(rand()-.5),t=0,distance=.5+rand()*1.5,phase=rand()*tau,sz=.125+.25*rand()}
    if #bbList==0 then ins(bbList,nb)
    else local s=false
        for i=1,#bbList do
        if nb.distance>=bbList[i].distance then s=true ins(bbList,i,nb) break end--按距离从远到近排序
        end
        if not s then ins(bbList,nb) end
    end
end
function bg.update(dt)
    time=time+dt
    beat=time*BPM/60

    parTime=parTime+dt

    insTime=insTime+dt
    for i=#bbList,1,-1 do
        bbList[i].t=bbList[i].t+dt
        if bbList[i].t>20 then rem(bbList,i) end
    end
    if insTime>2/bubbleDensity then
        bg.newBubble()
        insTime=insTime-2/bubbleDensity
    end
    if math.random()<dt*bubbleDensity/2 then
        bg.newBubble()
    end
end

local wp=gc.newCanvas(256,256)
gc.setCanvas(wp)

gc.setColor(1,1,1)
gc.rectangle('fill',0,0,256,256)

gc.setCanvas()

local bbShader=gc.newShader('BG/res/bubble/bubble.glsl')
local bb=gc.newCanvas(256,256)
gc.setCanvas(bb)
gc.setShader(bbShader)
gc.setColor(1,1,1)
gc.draw(wp,0,0)
gc.setShader()

gc.setCanvas()

local neodymiumStencil=function ()
    setLineWidth(20)
    for i=1,24 do
    line(-cos(tau*i/24)*720,-sin(tau*i/24)*720,cos(tau*i/24)*720,sin(tau*i/24)*720)
    end
end

local bgColor={
    {.1,.15,.2},{.1,.15,.2},
    {.04,.08,.20},{.08,.08,.12},
    {.16,.18,.33},{.56,.225,.56},
    {.125,.25,.25},{0,.5,.5}
}
local bgShader=gc.newShader[[
    extern vec4 clru;
    extern vec4 clrd;
    vec4 effect( vec4 color, Image texture, vec2 texCoord, vec2 scrCoord ){
        float rd=9./16.;
        float ad=step(rd,love_ScreenSize.y/love_ScreenSize.x);

        //highp float x=(scrCoord.x/love_ScreenSize.x*2.-1.)*(ad+(1.-ad)*love_ScreenSize.x/(love_ScreenSize.y/rd))*16.;
        highp float y=(scrCoord.y/love_ScreenSize.y*2.-1.)*((1.-ad)+ad*love_ScreenSize.y/(love_ScreenSize.x*rd))*9.;

        return mix(clru,clrd,y/18.+.5);
    }
]]
local colorU={0,0,0,1}
local colorD={0,0,0,1}
local s,bl
function bg.draw()
    local sz=1+max(.25-beat%2,0)

    local v=floor(beat%32/8)+1--背景相位
    local pv=floor((beat-8)%32/8)+1
    local tr=min(4*(beat%8/8),1)--渐变控制
    colorU[1],colorU[2],colorU[3]=M.lerp(bgColor[2*pv-1][1],bgColor[2*v-1][1],tr),M.lerp(bgColor[2*pv-1][2],bgColor[2*v-1][2],tr),M.lerp(bgColor[2*pv-1][3],bgColor[2*v-1][3],tr)
    colorD[1],colorD[2],colorD[3]=M.lerp(bgColor[2*pv][1],bgColor[2*v][1],tr),M.lerp(bgColor[2*pv][2],bgColor[2*v][2],tr),M.lerp(bgColor[2*pv][3],bgColor[2*v][3],tr)
    bgShader:send('clru',colorU)
    bgShader:send('clrd',colorD)
    gc.setShader(bgShader)
    gc.rectangle('fill',-960,-540,1920,1080)
    gc.setShader()
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

    for i=1,#bbList do
        bl=bbList[i]
        s=1/bl.distance
        gc.setColor(1,1,1,.5*s)
        gc.draw(bb,(bl.x+12*sin(math.pi*bl.t))*s,(1200-400*bl.t)*s,0,s*bl.sz,s*bl.sz,32,32)
    end

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