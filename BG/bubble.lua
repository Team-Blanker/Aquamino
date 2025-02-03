local ins,rem=table.insert,table.remove

local bg={}
local bbList={}
local insTime=0
function bg.init()
    bbList={}
    bg.density=18
end

local  pi,tau=math.pi,2*math.pi
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
    insTime=insTime+dt
    for i=#bbList,1,-1 do
        bbList[i].t=bbList[i].t+dt
        if bbList[i].t>20 then rem(bbList,i) end
    end
    if insTime>2/bg.density then
        bg.newBubble()
        insTime=insTime-2/bg.density
    end
    if math.random()<dt*bg.density/2 then
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
--[[gc.setLineWidth(2)
for i=1,32,2 do
    gc.setColor(1,1,1,.75*i/64)
    gc.circle('line',32,32,i)
end
gc.setLineWidth(2)
gc.setColor(1,1,1)
gc.circle('line',32,32,31)]]

gc.setShader(bbShader)
gc.setColor(1,1,1)
gc.draw(wp,0,0)
gc.setShader()

gc.setLineWidth(2)
--gc.setColor(1,1,1,.7)
--gc.circle('line',64,64,63)

gc.setCanvas()


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
bgShader:send('clru',{.04,.08,.20,1.})
bgShader:send('clrd',{.08,.08,.12,1.})
local s,bl
function bg.draw()
    gc.setShader(bgShader)
    gc.rectangle('fill',-960,-540,1920,1080)
    gc.setShader()
    gc.setColor(.04,.04,.06,.08+.08*sin(scene.time%5/2.5*math.pi))
    gc.rectangle('fill',-960,-540,1920,1080)
    for i=1,#bbList do
        bl=bbList[i]
        s=1/bl.distance
        gc.setColor(1,1,1,.16*s)
        gc.draw(bb,(bl.x+12*sin(pi*bl.t))*s,(1200-300*bl.t)*s,0,s*bl.sz,s*bl.sz,32,32)
    end
    --gc.setColor(1,1,1)
    --gc.draw(bb,480,0)
end
return bg