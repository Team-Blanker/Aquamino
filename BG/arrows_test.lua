local pi,tau=math.pi,2*math.pi

local mapW,mapH=2048,1280
local attach=32

local setColor,setShader=gc.setColor,gc.setShader
local draw,line,poly,rect,printf=gc.draw,gc.line,gc.polygon,gc.rectangle,gc.printf

local ar=gc.newCanvas(120,60)
gc.setCanvas(ar)
setColor(1,1,1)
poly('fill',0,30,60,0,120,30,60,60)
gc.setCanvas()

local bg={}

local cbl={}
local function checkBeside(x,y,id)
    if #cbl~=0 then for i=#cbl,1,-1 do cbl[i]=nil end end
    for k,v in pairs(bg.attach[x][y]) do
        if v and k~=id then ins(cbl,k) end
    end
    if #cbl~=0 then return cbl[#cbl] end
end
function bg.init()
    bg.arrowList={}
    for i=1,128 do
        bg.arrowList[i]={x=mapW*rand(),y=mapH*rand(),v=100,angle=tau*rand(),state=rand()<.85 and 0 or 1}
        bg.arrowList[i].attach={x=floor(bg.arrowList[i].x/attach+.5),y=floor(bg.arrowList[i].y/attach+.5)}
        bg.arrowList[i].follow={index=nil,angle=0}
        bg.arrowList[i].guideT=bg.arrowList[i].state==1 and 1 or 0
        bg.arrowList[i].dropT=bg.arrowList[i].state==1 and 2 or 0
        bg.arrowList[i].freeT=0
    end

    bg.attach={}--[x][y]格式
    for x=0,mapW/attach-1 do
        bg.attach[x]={}
        for y=0,mapH/attach-1 do
            bg.attach[x][y]={}
        end
    end
    bg.updateT=0 bg.attachTick=0
end

local arw,f,idx
local tick=1/120

local oList={0,0,
    --1,0, -1,0, 0,-1, 0,1,
    1,1, 1,-1, -1,-1, -1,1
    --2,2, 2,-2, -2,-2, -2,2
}
local function setAttach(x,y,id,v)
    for i=1,#oList,2 do
        bg.attach[(x+oList[i])%(mapW/attach)][(y+oList[i+1])%(mapH/attach)][id]=v
    end
end

local bgsd=gc.newShader('BG/res/arrows/bg.glsl')

function bg.update(dt)
    bg.updateT=bg.updateT+dt
    if bg.updateT>=tick then bg.updateT=bg.updateT-tick
        for id=1,#bg.arrowList do
            arw=bg.arrowList[id]
            arw.x,arw.y=(arw.x+arw.v*cos(arw.angle)*tick)%mapW,(arw.y+arw.v*sin(arw.angle)*tick)%mapH

            f=arw.state==1
            if f then
                setAttach(arw.attach.x,arw.attach.y,id,nil)
            end

            arw.attach.x,arw.attach.y=floor(arw.x/attach+.5),floor(arw.y/attach+.5)

            if f then
                arw.guideT=max(arw.guideT-tick,0)
                if arw.guideT<=0 then
                    arw.state=0 arw.freeT=.5+rand()
                    setAttach(arw.attach.x,arw.attach.y,id,nil)
                else
                    setAttach(arw.attach.x,arw.attach.y,id,true)
                end
            else
                arw.freeT=max(arw.freeT-tick,0)
                if arw.freeT<=0 then
                    idx=checkBeside(arw.attach.x%(mapW/attach),arw.attach.y%(mapH/attach),id)
                    if arw.follow.index~=idx then
                        if idx then arw.state=1 arw.guideT=3 end
                        arw.follow.index=idx
                        if idx then arw.follow.angle=(bg.arrowList[idx].angle-arw.angle+pi)%tau-pi*(rand()<.95 and .975+.05*rand() or .5+rand()) end
                    end
                end
            end

            if arw.follow.angle>0 then
                arw.angle=arw.angle+min(4*tick,arw.follow.angle)
                arw.follow.angle=max(arw.follow.angle-4*tick,0)
            elseif arw.follow.angle<0 then
                arw.angle=arw.angle-min(4*tick,-arw.follow.angle)
                arw.follow.angle=min(arw.follow.angle+4*tick,0)
            else
                arw.follow.index=nil
            end
        end
    end
end

local x,y,s
function bg.draw()
    bgsd:send('phase',scene.time)
    setShader(bgsd)
    rect('fill',-960,-540,1920,1080)
    setShader()

    gc.push()
    gc.translate(-mapW/2,-mapH/2)
    setColor(1,1,1)
    gc.setLineWidth(2)
    gc.rectangle('line',0,0,mapW,mapH)
    setColor(1,1,1,1/3)
    --[[for i=0,mapW,attach do
        line(i,0,i,mapH)
    end
    for i=0,mapH,attach do
        line(0,i,mapW,i)
    end]]
    for i=1,#bg.arrowList do
        arw=bg.arrowList[i]
        if arw.state==1 then setColor(1,1,1)
            --gc.printf(i,font.JB_B,arw.x,arw.y-16,5000,'center',0,.125,.125,2500,84)
        else
            if arw.freeT>0 then setColor(1,.6,.2)
                --gc.printf(i,font.JB_B,arw.x,arw.y-16,5000,'center',0,.125,.125,2500,84)
            else setColor(.6,1,.2) end
        end

        x=(arw.x-mapW/2)/mapH*2 y=(arw.y-mapH/2)/mapH*2
        s=(x*x+y*y)/2
        draw(ar,arw.x,arw.y,arw.angle,.2+.05*s,.2+.05*s,60,30)
        --line(arw.x,arw.y,arw.attach.x*attach,arw.attach.y*attach)
    end
    gc.pop()
end
return bg