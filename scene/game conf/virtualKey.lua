local BUTTON,SLIDER=scene.button,scene.slider
local M,T=mymath,mytable

local cfv

local keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}

local attachList={[0]=0,30,40,50,60,90,120}
local attachIndex=0

local defaultPreset={
    --我自己在铁壳的大致配置（类似铁壳默认配置1）
    {
        ML=   {x= 420,y= 180,r=120},
        MR=   {x= 780,y= 180,r=120},
        SD=   {x= 600,y= 360,r=120},
        HD=   {x= 600,y=   0,r=120},
        CW=   {x=-420,y= 180,r=120},
        CCW=  {x=-780,y= 180,r=120},
        flip= {x=-600,y=   0,r=120},
        hold= {x=-600,y= 360,r=120},
        R=    {x=-500,y=-400,r= 90},
        pause={x= 500,y=-400,r= 90},
    },
    --对称
    {
        ML=   {x=-780,y= 180,r=120},
        MR=   {x=-420,y= 180,r=120},
        SD=   {x=-600,y= 360,r=120},
        HD=   {x=-600,y=   0,r=120},
        CW=   {x= 780,y= 180,r=120},
        CCW=  {x= 420,y= 180,r=120},
        flip= {x= 600,y=   0,r=120},
        hold= {x= 600,y= 360,r=120},
        R=    {x=-500,y=-400,r= 90},
        pause={x= 500,y=-400,r= 90},
    },
    --铁壳默认配置3
    {
        ML=   {x=-840,y= 420,r=120},
        MR=   {x=-600,y= 420,r=120},
        SD=   {x= 840,y= 180,r=120},
        HD=   {x= 840,y= 420,r=120},
        CW=   {x= 600,y= 420,r=120},
        CCW=  {x= 360,y= 420,r=120},
        flip= {x= 600,y= 180,r=120},
        hold= {x= 840,y=- 60,r=120},
        R=    {x=-500,y=-400,r= 90},
        pause={x= 500,y=-400,r= 90},
    },
    --铁壳默认配置4
    {
        ML=   {x= 360,y= 420,r=120},
        MR=   {x= 840,y= 420,r=120},
        SD=   {x= 600,y= 180,r=120},
        HD=   {x= 600,y= 420,r=120},
        CW=   {x=-600,y= 420,r=120},
        CCW=  {x=-840,y= 420,r=120},
        flip= {x=-600,y= 180,r=120},
        hold= {x=-360,y= 420,r=120},
        R=    {x=-500,y=-400,r= 90},
        pause={x= 500,y=-400,r= 90},
    },
    --maimai
    {
        ML=   {x= 200,y=-500,r=120},
        MR=   {x= 500,y=-200,r=120},
        SD=   {x= 500,y= 200,r=120},
        HD=   {x= 200,y= 500,r=120},
        CW=   {x=-200,y= 500,r=120},
        CCW=  {x=-500,y= 200,r=120},
        flip= {x=-500,y=-200,r=120},
        hold= {x=-200,y=-500,r=120},
        R=    {x=-870,y=-450,r= 90},
        pause={x= 870,y=-450,r= 90},
    },
}
local presetIndex=0

local vkpic={}
for k,v in pairs(defaultPreset[1]) do
    vkpic[k]=gc.newImage('pic/virtual key/'..k..'.png')--200*200
end

local VKey={}
function VKey.read()
    VKey.set=T.copy(defaultPreset[1])
    local vk=file.read('conf/virtualKey')
    if not vk.set then vk.set={} end if not vk.enabled then vk.enabled=false end
    T.combine(VKey.set,vk.set)
    VKey.enabled=vk.enabled

    for i=1,#keyName do
        if not VKey.set[keyName[i]] then VKey.set[keyName[i]]={x=0,y=0,r=120} end
    end
    for k,v in pairs(VKey.set) do
        if not T.include(keyName,k) then v=nil end
    end
end
function VKey.save()
    local lst={enabled=VKey.enabled,set=VKey.set}
    file.save('conf/virtualKey',lst)
end
function VKey.init()
    presetIndex=0
    VKey.read()

    VKey.toMove,VKey.choose,VKey.movePosShow=nil,nil,nil
    VKey.posShowTimer=0

    cfv=user.lang.conf.virtualKey

    BUTTON.create('quit',{
        x=0,y=300,type='rect',w=140,h=80,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,.8,.8,60,35)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/keys'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('vkEnable',{
        x=-150,y=0,type='rect',w=60,h=60,
        draw=function(bt,t,ct)
            local animArg=VKey.enabled and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,300*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+300*animArg,-h/2,300*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(6)
            gc.rectangle('line',-w/2+4,-h/2+4,h-8,h-8)
            if VKey.enabled then
                gc.circle('line',0,0,(w/2-4)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cfv.enable,font.Bender_B,w/2+30,0,1200,'left',0,cfv.enableTctScale,cfv.enableTctScale,0,72)
        end,
        event=function()
            VKey.enabled=not VKey.enabled
        end
    },.2)
    BUTTON.create('preset',{
        x=0,y=200,type='rect',w=320,h=80,
        draw=function(bt,t)
            if VKey.enabled then
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(cfv.preset,font.Bender,0,0,1280,'center',0,.5,.5,640,72)
            end
        end,
        event=function()
            if VKey.enabled then
            presetIndex=presetIndex%#defaultPreset+1
            VKey.set=T.copy(defaultPreset[presetIndex])
            end
        end
    },.2)

    SLIDER.create('szAdjust',{
        x=-0,y=-180,type='hori',sz={300,24},button={24,24},
        gear=19,pos=0,
        sliderDraw=function(g,sz)
            if VKey.enabled and VKey.choose then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(cfv.btsz..VKey.set[VKey.choose].r, font.JB,-sz[1]/2-12,-36,114514,'left',0,.25,.25,0,84)
            end
        end,
        buttonDraw=function(pos,sz)
            if VKey.enabled and VKey.choose then
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,16,4)
            end
        end,
        always=function(pos)
            if VKey.enabled and VKey.choose then
            VKey.set[VKey.choose].r=10*pos+60
            end
        end
    })
    SLIDER.create('attachAdjust',{
        x=-0,y=-270,type='hori',sz={300,24},button={24,24},
        gear=7,pos=attachIndex,
        sliderDraw=function(g,sz)
            if VKey.enabled then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(cfv.attach..attachList[attachIndex],font.JB,-sz[1]/2-12,-36,114514,'left',0,.25,.25,0,84)
            end
        end,
        buttonDraw=function(pos,sz)
            if VKey.enabled then
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,16,4)
            end
        end,
        always=function(pos)
            if VKey.enabled then
            attachIndex=pos
            end
        end
    })
end

function VKey.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and not SLIDER.mouseP(x,y,button,istouch) and VKey.enabled then
        local ak
        local d=1e99
        for k,v in pairs(VKey.set) do
            local r=abs(x-v.x)+abs(y-v.y)
            if r<v.r and r<d then ak=k d=r end
        end
        VKey.toMove,VKey.choose,VKey.movePosShow=ak,ak or VKey.choose,ak or VKey.movePosShow
        if VKey.choose then SLIDER.setPos('szAdjust',(VKey.set[VKey.choose].r-60)/10) end
    end
end
function VKey.mouseR(x,y,button,istouch)
    if VKey.toMove then
        local attach=attachList[attachIndex]
        --四舍五入进行黏附
        if attach==0 then
            VKey.set[VKey.toMove].x,VKey.set[VKey.toMove].y=x,y
        else
            VKey.set[VKey.toMove].x,VKey.set[VKey.toMove].y=attach*floor(x/attach+.5),attach*floor(y/attach+.5)
        end
    end
    VKey.toMove=nil
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
end

local msx,msy
function VKey.update(dt)
    msx,msy=adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    BUTTON.update(dt,msx,msy)
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],msx,msy)
    elseif VKey.toMove then
        VKey.set[VKey.toMove].x,VKey.set[VKey.toMove].y=M.clamp(msx,-960,960),M.clamp(msy,-540,540)
        VKey.posShowTimer=0
    else VKey.posShowTimer=VKey.posShowTimer+dt end
end

local tw,th
local posTxt=gc.newText(font.Bender)
function VKey.draw()
    gc.setLineWidth(4)
    gc.setColor(.5,1,.875,.5)
    gc.rectangle('line',-400,-400,800,800)
    gc.setLineWidth(8)
    gc.setColor(.5,1,.875)
    gc.rectangle('line',-184,-364,368,728)

    if VKey.enabled then
    local attach=attachList[attachIndex]
    if attach~=0 then
    gc.setColor(1,1,1,.25)
    gc.setLineWidth(max(attach/30,2))
    for i=0,960,attach do
        if i==0 then gc.line(0,-540,0,540)
        else
            gc.line(i,-540,i,540) gc.line(-i,-540,-i,540)
        end
    end
    for i=0,540,attach do
        if i==0 then gc.line(-960,0,960,0)
        else
            gc.line(-960,i,960,i) gc.line(-960,-i,960,-i)
        end
    end
    end
        gc.setColor(1,1,1,.8)
        for k,v in pairs(VKey.set) do
            gc.setLineWidth(5*v.r/100)
            gc.circle('line',v.x,v.y,v.r,4)
            --gc.printf(k,font.Bender,v.x,v.y,2000,'center',0,.5,.5,1000,72)
            gc.draw(vkpic[k],v.x,v.y,0,v.r/100,v.r/100,100,100)
        end
        if VKey.choose then
            local v=VKey.set[VKey.choose]
            gc.setColor(1,1,1,scene.time%.2<.1 and .3 or .2)
            gc.circle('fill',v.x,v.y,v.r*15/16,4)
        end
        if VKey.movePosShow then
            local v=VKey.set[VKey.movePosShow]
            posTxt:clear()
            posTxt:set(string.format("%.2f, %.2f",v.x,v.y))
            tw,th=posTxt:getDimensions()

            local horiOffset=v.x+tw/4>960 and 960-v.x-tw/4 or v.x-tw/4<-960 and -960-v.x+tw/4 or 0
            gc.setColor(1,1,1,VKey.posShowTimer<.5 and 1 or (1-(VKey.posShowTimer-.5)/.5)^.5)
            gc.draw(posTxt,v.x+horiOffset,v.y+(v.y-v.r<-420 and v.r+th/4 or -v.r-th/4),0,.5,.5,tw/2,th/2)
        end
    end

    BUTTON.draw() SLIDER.draw()
end
function VKey.exit()
    VKey.save()
end
return VKey