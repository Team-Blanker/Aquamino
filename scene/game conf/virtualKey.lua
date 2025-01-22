local BUTTON,SLIDER=scene.button,scene.slider
local M,T=myMath,myTable

local cfv

local keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}

local attachList={[0]=0,30,40,50,60,90,120}
local attachIndex=4

local defaultPreset={
    --开发者在铁壳的大致配置（类似铁壳默认配置1）
    {
        ML=   {x= 420,y= 180,r=120,tolerance=60},
        MR=   {x= 780,y= 180,r=120,tolerance=60},
        SD=   {x= 600,y= 360,r=120,tolerance=60},
        HD=   {x= 600,y=   0,r=120,tolerance=60},
        CW=   {x=-420,y= 180,r=120,tolerance=60},
        CCW=  {x=-780,y= 180,r=120,tolerance=60},
        flip= {x=-600,y=   0,r=120,tolerance=60},
        hold= {x=-600,y= 360,r=120,tolerance=60},
        R=    {x=-500,y=-400,r= 90,tolerance=30},
        pause={x= 500,y=-400,r= 90,tolerance=30},
    },
    --对称
    {
        ML=   {x=-780,y= 180,r=120,tolerance=60},
        MR=   {x=-420,y= 180,r=120,tolerance=60},
        SD=   {x=-600,y= 360,r=120,tolerance=60},
        HD=   {x=-600,y=   0,r=120,tolerance=60},
        CW=   {x= 780,y= 180,r=120,tolerance=60},
        CCW=  {x= 420,y= 180,r=120,tolerance=60},
        flip= {x= 600,y=   0,r=120,tolerance=60},
        hold= {x= 600,y= 360,r=120,tolerance=60},
        R=    {x=-500,y=-400,r= 90,tolerance=30},
        pause={x= 500,y=-400,r= 90,tolerance=30},
    },
    --铁壳默认配置3
    {
        ML=   {x=-840,y= 420,r=120,tolerance=60},
        MR=   {x=-600,y= 420,r=120,tolerance=60},
        SD=   {x= 840,y= 180,r=120,tolerance=60},
        HD=   {x= 840,y= 420,r=120,tolerance=60},
        CW=   {x= 600,y= 420,r=120,tolerance=60},
        CCW=  {x= 360,y= 420,r=120,tolerance=60},
        flip= {x= 600,y= 180,r=120,tolerance=60},
        hold= {x= 840,y=- 60,r=120,tolerance=60},
        R=    {x=-500,y=-400,r= 90,tolerance=30},
        pause={x= 500,y=-400,r= 90,tolerance=30},
    },
    --铁壳默认配置4
    {
        ML=   {x= 360,y= 420,r=120,tolerance=60},
        MR=   {x= 840,y= 420,r=120,tolerance=60},
        SD=   {x= 600,y= 420,r=120,tolerance=60},
        HD=   {x= 600,y= 180,r=120,tolerance=60},
        CW=   {x=-600,y= 420,r=120,tolerance=60},
        CCW=  {x=-840,y= 420,r=120,tolerance=60},
        flip= {x=-600,y= 180,r=120,tolerance=60},
        hold= {x=-360,y= 420,r=120,tolerance=60},
        R=    {x=-500,y=-400,r= 90,tolerance=30},
        pause={x= 500,y=-400,r= 90,tolerance=30},
    },
    --maimai
    {
        ML=   {x= 200,y=-500,r=120,tolerance=60},
        MR=   {x= 500,y=-200,r=120,tolerance=60},
        SD=   {x= 500,y= 200,r=120,tolerance=60},
        HD=   {x= 200,y= 500,r=120,tolerance=60},
        CW=   {x=-200,y= 500,r=120,tolerance=60},
        CCW=  {x=-500,y= 200,r=120,tolerance=60},
        flip= {x=-500,y=-200,r=120,tolerance=60},
        hold= {x=-200,y=-500,r=120,tolerance=60},
        R=    {x=-870,y=-450,r= 90,tolerance=30},
        pause={x= 870,y=-450,r= 90,tolerance=30},
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
    if not vk.set then vk.set={} end
    if not vk.enabled then vk.enabled=false end
    if not vk.anim then vk.anim=false end
    T.combine(VKey.set,vk.set)
    VKey.enabled=vk.enabled
    VKey.anim=vk.anim

    for i=1,#keyName do
        if not VKey.set[keyName[i]] then VKey.set[keyName[i]]={x=0,y=0,r=120} end
    end
    for k,v in pairs(VKey.set) do
        if not T.include(keyName,k) then v=nil
        elseif not v.tolerance then v.tolerance=60 end
    end
end
function VKey.save()
    local lst={enabled=VKey.enabled,set=VKey.set,anim=VKey.anim}
    file.save('conf/virtualKey',lst)
end

VKey.txt={preset={},vkEnable={},animEnable={}}
VKey.sliderTxt={btsz={},tolerance={},attach={}}
function VKey.init()
    scene.BG=require'BG/settings'

    sfx.add({
        cOn='sfx/general/checkerOn.wav',
        cOff='sfx/general/checkerOff.wav',
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/confSwitch.wav',
        preset='sfx/general/buttonChoose.wav',
    })

    presetIndex=0
    VKey.read()

    VKey.toMove,VKey.choose,VKey.movePosShow=nil,nil,nil
    VKey.posShowTimer=0

    cfv=user.lang.conf.virtualKey

    local p=VKey.txt.preset
    p.txt=gc.newText(font.Bender,cfv.preset)
    p.w,p.h=p.txt:getDimensions()
    p.s=min(288/p.w,.4)
    local v=VKey.txt.vkEnable
    v.txt=gc.newText(font.Bender_B,cfv.enable)
    v.w,v.h=v.txt:getDimensions()
    v.s=min(270/v.w,cfv.enableTxtScale)
    local a=VKey.txt.animEnable
    a.txt=gc.newText(font.Bender_B,cfv.anim)
    a.w,a.h=a.txt:getDimensions()
    a.s=min(270/a.w,cfv.animTxtScale)

    for k,t in pairs(VKey.sliderTxt) do
        t.txt=gc.newText(font.JB,cfv[k])
        t.w,t.h=t.txt:getDimensions()
        t.s=min(240/t.w,.25)
        t.ow=min(240,t.w*.25)
        t.numTxt=gc.newText(font.JB)
    end

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
            sfx.play('quit')
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
            gc.setLineWidth(4)
            gc.rectangle('line',-w/2+2,-h/2+2,h-4,h-4)
            if VKey.enabled then
                gc.line(-w*3/8,0,-w/8,h/4,w*3/8,-h/4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.draw(v.txt,w/2+15,0,0,v.s,v.s,0,v.h/2)
            --gc.printf(cfv.enable,font.Bender_B,w/2+30,0,1200,'left',0,cfv.enableTxtScale,cfv.enableTxtScale,0,72)
        end,
        event=function()
            VKey.enabled=not VKey.enabled
            sfx.play(VKey.enabled and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('animEnable',{
        x=-150,y=90,type='rect',w=60,h=60,
        draw=function(bt,t,ct)
            local animArg=VKey.anim and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,300*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+300*animArg,-h/2,300*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(4)
            gc.rectangle('line',-w/2+2,-h/2+2,h-4,h-4)
            if VKey.anim then
                gc.line(-w*3/8,0,-w/8,h/4,w*3/8,-h/4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.draw(a.txt,w/2+15,0,0,a.s,a.s,0,a.h/2)
        end,
        event=function()
            VKey.anim=not VKey.anim
            sfx.play(VKey.anim and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('preset',{
        x=0,y=200,type='rect',w=320,h=80,
        draw=function(bt,t,ct)
            if VKey.enabled then
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(p.txt,0,0,0,p.s,p.s,p.w/2,p.h/2)
            gc.setColor(1,1,1,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
            end
        end,
        event=function()
            if VKey.enabled then
            sfx.play('preset')
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
            local t=VKey.sliderTxt.btsz
            gc.draw(t.txt,-160,-20,0,t.s,t.s,0,t.h)
            t.numTxt:clear()
            t.numTxt:add(string.format(":%3d",VKey.set[VKey.choose].r))
            gc.draw(t.numTxt,-160+t.ow,-20,0,.25,.25,0,t.h)
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
    SLIDER.create('toleranceAdjust',{
        x=0,y=-90,type='hori',sz={300,24},button={24,24},
        gear=13,pos=0,
        sliderDraw=function(g,sz)
            if VKey.enabled and VKey.choose then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local t=VKey.sliderTxt.tolerance
            gc.draw(t.txt,-160,-20,0,t.s,t.s,0,t.h)
            t.numTxt:clear()
            t.numTxt:add(string.format(":%3d",VKey.set[VKey.choose].tolerance))
            gc.draw(t.numTxt,-160+t.ow,-20,0,.25,.25,0,t.h)
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
            VKey.set[VKey.choose].tolerance=10*pos
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
            local t=VKey.sliderTxt.attach
            gc.draw(t.txt,-160,-20,0,t.s,t.s,0,t.h)
            t.numTxt:clear()
            t.numTxt:add(string.format(":%3d",attachList[attachIndex]))
            gc.draw(t.numTxt,-160+t.ow,-20,0,.25,.25,0,t.h)
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

function VKey.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/keys'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
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
        if VKey.choose then
            SLIDER.setPos('szAdjust',(VKey.set[VKey.choose].r-60)/10)
            SLIDER.setPos('toleranceAdjust',VKey.set[VKey.choose].tolerance/10)
        end
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
            gc.setLineWidth(5*v.r/100)
            gc.circle('line',v.x,v.y,v.r+v.tolerance,4)
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