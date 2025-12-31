local M,T=myMath,myTable
local cfc=user.lang.conf.custom

local custom={}
local block=require'mino/blocks'
local BUTTON,SLIDER=scene.button,scene.slider

local blockSkinList={'glossy','glass','metal','pure','carbon fibre','classic','wheelchair'}
local skinFuncList={}
for k,v in pairs(blockSkinList) do
    skinFuncList[v]=require('skin/block/'..v)
end

local defaultColor={
    Z={.9,.15,.3},S={.45,.9,0},J={0,.6,.9},L={.9,.6,.3},T={.75,.18,.9},O={.9,.9,0},I={.15,.9,.67},
    g1={.5,.5,.5},g2={.75,.75,.75},
}
local blockDraw={'Z','S','J','L','T','O','I','g1','g2',}
local themeList={'simple'}
local sfxList={'plastic_v2','plastic','krystal','meme','otto',--[['LexNinja']]}
local RSList={'SRS','AqRS'}
function custom.read()
    custom.info={block='glossy',theme='simple',sfx='plastic',RS='SRS',smoothAnimAct=false,smoothFallType=1,rotationCenter=false,smoothTime=.05,fieldScale=1}
    local info=file.read('conf/custom')
    T.combine(custom.info,info)

    custom.color={}
    custom.color=myTable.copy(defaultColor)
    local c=file.read('conf/mino color')
    myTable.combine(custom.color,c)

    custom.texType={}
    if fs.getInfo('conf/mino textype') then T.combine(custom.texType,file.read('conf/mino textype'))
    end
end
function custom.save()
    file.save('conf/custom',custom.info)
end
custom.seTxt={texture={},RS={},theme={},sfx={},scale={}}
custom.smslTxt={}--平滑运动滑块文本
custom.smTxt={}--平滑运动勾选框文本
custom.smfTxt={}--重力运动按钮文本
custom.rcTxt={}--旋转中心勾选框文本
custom.csTxt={}--方块颜色按钮文本
custom.bbTxt={}--版面晃动按钮文本
custom.titleTxt={txt=gc.newText(font.Bender)}
local tt
function custom.init()
    scene.BG=require'BG/settings'

    sfx.add({
        cOn='sfx/general/checkerOn.wav',
        cOff='sfx/general/checkerOff.wav',
        click='sfx/general/buttonClick.wav',
        sceneSwitch='sfx/general/confSwitch.wav',
        optionSwitch='sfx/general/optionSwitch.wav',
    })

    tt=custom.titleTxt
    tt.txt:clear()
    tt.txt:add(user.lang.conf.main.custom)
    tt.w,tt.h=tt.txt:getDimensions()
    tt.s=min(600/tt.w,1)

    cfc=user.lang.conf.custom
    for k,v in pairs(custom.seTxt) do
        v.txt=gc.newText(font.Bender_B,cfc[k])
        v.w,v.h=v.txt:getDimensions()
        v.s=min(450/v.w,4/9)
    end

    local cs=custom.csTxt
    cs.txt=gc.newText(font.Bender_B,cfc.color)
    cs.w,cs.h=cs.txt:getDimensions()
    cs.s=min(360/cs.w,.4)

    local bb=custom.bbTxt
    bb.txt=gc.newText(font.Bender_B,cfc.boardBounce)
    bb.w,bb.h=bb.txt:getDimensions()
    bb.s=min(360/bb.w,.4)

    local sm=custom.smTxt
    sm.txt=gc.newText(font.Bender_B,cfc.smooth)
    sm.w,sm.h=sm.txt:getDimensions()
    sm.s=min(288/sm.w,1/3)

    local smf=custom.smfTxt
    smf.txt=gc.newText(font.Bender,cfc.fallAnimType)
    smf.w,smf.h=smf.txt:getDimensions()
    smf.s=min(60/smf.h,min(270/smf.w,.3125))

    local rc=custom.rcTxt
    rc.txt=gc.newText(font.Bender_B,cfc.rotationCenter)
    rc.w,rc.h=rc.txt:getDimensions()
    rc.s=min(288/rc.w,1/3)

    local st=custom.smslTxt
    st.txt=gc.newText(font.JB,cfc.smoothTime)
    st.w,st.h=st.txt:getDimensions()
    st.s=min(270/st.w,.3125)
    st.ow=min(270,st.w*.3125)
    st.numTxt=gc.newText(font.JB)

    custom.read()

    custom.bOrder=T.include(blockSkinList,custom.info.block) or 1
    custom.RSOrder=T.include(RSList,custom.info.RS) or 1
    custom.tOrder=T.include(themeList,custom.info.theme) or 1
    custom.sOrder=T.include(sfxList,custom.info.sfx) or 1

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            sfx.play('sceneSwitch')
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    scene.button.create('test',{
        x=700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(user.lang.conf.test,font.Bender,0,0,1280,'center',0,.5,.5,640,font.height.Bender/2)
        end,
        event=function()
            sfx.play('click')
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)

    BUTTON.create('colorAdjust',{
        x=600,y=-280,type='rect',w=400,h=80,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(cs.txt,0,0,0,cs.s,cs.s,cs.w/2,cs.h/2)
        end,
        event=function()
            sfx.play('sceneSwitch')
            scene.switch({
                dest='conf',destScene=require('scene/game conf/mino color'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('boardBounce',{
        x=-600,y=-280,type='rect',w=400,h=80,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(bb.txt,0,0,0,bb.s,bb.s,bb.w/2,bb.h/2)
        end,
        event=function()
            sfx.play('sceneSwitch')
            scene.switch({
                dest='conf',destScene=require('scene/game conf/board bounce'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)

    BUTTON.create('textureChoose',{
        x=-600,y=-40,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local o,l=custom.bOrder,#blockSkinList
            local w,h=bt.w,bt.h
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/2*(1-a)
                if cp[1]<0 then gc.line(-(w-h)/2-off,h/2,-w/2-off,0,-(w-h)/2-off,-h/2)
                else gc.line((w-h)/2+off,h/2,w/2+off,0,(w-h)/2+off,-h/2)
                end
            end
            gc.setColor(.44,.88,.77)
            local tt=custom.seTxt.texture
            gc.draw(tt.txt,0,-h/2-10,0,tt.s,tt.s,tt.w/2,tt.h)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(blockSkinList[custom.bOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,font.height.Bender/2)
        end,
        event=function(x,y,bt)
            local success=false
            if x<0 then
                if custom.bOrder>1 then custom.bOrder=custom.bOrder-1 success=true end
            elseif custom.bOrder<#blockSkinList then custom.bOrder=custom.bOrder+1 success=true
            end
            custom.info.block=blockSkinList[custom.bOrder]
            bt.success=success
            if success then sfx.play('optionSwitch') end
        end
    },.2)

    BUTTON.create('RSChoose',{
        x=-600,y=200,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local o,l=custom.RSOrder,#RSList
            local w,h=bt.w,bt.h
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/2*(1-a)
                if cp[1]<0 then gc.line(-(w-h)/2-off,h/2,-w/2-off,0,-(w-h)/2-off,-h/2)
                else gc.line((w-h)/2+off,h/2,w/2+off,0,(w-h)/2+off,-h/2)
                end
            end
            gc.setColor(.88,.66,.44)
            local tt=custom.seTxt.RS
            gc.draw(tt.txt,0,-h/2-10,0,tt.s,tt.s,tt.w/2,tt.h)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(RSList[custom.RSOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,font.height.Bender/2)
        end,
        event=function(x,y,bt)
            local success=false
            if x<0 then
                if custom.RSOrder>1 then custom.RSOrder=custom.RSOrder-1 success=true end
            elseif custom.RSOrder<#RSList then custom.RSOrder=custom.RSOrder+1 success=true
            end
            custom.info.RS=RSList[custom.RSOrder]
            bt.success=success
            if success then sfx.play('optionSwitch') end
        end
    },.2)

    BUTTON.create('themeChoose',{
        x=600,y=200,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local o,l=custom.tOrder,#themeList
            local w,h=bt.w,bt.h
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/2*(1-a)
                if cp[1]<0 then gc.line(-(w-h)/2-off,h/2,-w/2-off,0,-(w-h)/2-off,-h/2)
                else gc.line((w-h)/2+off,h/2,w/2+off,0,(w-h)/2+off,-h/2)
                end
            end
            gc.setColor(.88,.44,.44)
            local tt=custom.seTxt.theme
            gc.draw(tt.txt,0,-h/2-10,0,tt.s,tt.s,tt.w/2,tt.h)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(themeList[custom.tOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,font.height.Bender/2)
        end,
        event=function(x,y,bt)
            local success=false
            if x<0 then
                if custom.tOrder>1 then custom.tOrder=custom.tOrder-1 success=true end
            elseif custom.tOrder<#themeList then custom.tOrder=custom.tOrder+1 success=true
            end
            custom.info.theme=themeList[custom.tOrder]
            bt.success=success
            if success then sfx.play('optionSwitch') end
        end
    },.2)
    BUTTON.create('sfxChoose',{
        x=600,y=-40,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local o,l=custom.sOrder,#sfxList
            local w,h=bt.w,bt.h
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/2*(1-a)
                if cp[1]<0 then gc.line(-(w-h)/2-off,h/2,-w/2-off,0,-(w-h)/2-off,-h/2)
                else gc.line((w-h)/2+off,h/2,w/2+off,0,(w-h)/2+off,-h/2)
                end
            end
            gc.setColor(.88,.22,.66)
            local tt=custom.seTxt.sfx
            gc.draw(tt.txt,0,-h/2-10,0,tt.s,tt.s,tt.w/2,tt.h)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(sfxList[custom.sOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,font.height.Bender/2)
            if cfc.sfxWarning[sfxList[o]] then gc.setColor(1,0,0,.75)
            gc.printf(cfc.sfxWarning[sfxList[o]],font.Bender_B,-w/2,h/2+48,1600,'left',0,.25,.25,0,152)
            end
        end,
        event=function(x,y,bt)
            local success=false
            if x<0 then
                if custom.sOrder>1 then custom.sOrder=custom.sOrder-1 success=true end
            elseif custom.sOrder<#sfxList then custom.sOrder=custom.sOrder+1 success=true
            end
            custom.info.sfx=sfxList[custom.sOrder]
            bt.success=success
            if success then sfx.play('optionSwitch') end
        end
    },.2)

    BUTTON.create('scaleAdjust',{
        x=0,y=80,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local sz=custom.info.fieldScale
            local w,h=bt.w,bt.h
            gc.setColor(.3,.6,.9)
            local tt=custom.seTxt.scale
            gc.draw(tt.txt,0,-h/2-10,0,tt.s,tt.s,tt.w/2,tt.h)

            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            gc.line(-(w-h)/2, h/2,-w/2+h,0,-(w-h)/2,-h/2)
            gc.line( (w-h)/2, h/2, w/2-h,0, (w-h)/2,-h/2)
            gc.setLineWidth(8)
            gc.setColor(1,1,1)
            if sz>0.76 then gc.line(-(w-h)/2-h/2*.5,0,-(w-h)/2+h/2*.5,0) end
            if sz<1.24 then
                gc.line( (w-h)/2-h/2*.5,0, (w-h)/2+h/2*.5,0)
                gc.line( (w-h)/2,h/2*.5,(w-h)/2,-h/2*.5)
            end
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/4*(1-a)
                if cp[1]<0 then gc.circle('line',-(w-h)/2,0,h/2+off,4)
                else gc.circle('line',(w-h)/2,0,h/2+off,4)
                end
            end
            gc.setColor(1,1,1)
            gc.printf(("%.2f"):format(sz),font.Bender,0,0,1280,'center',0,.45,.45,640,font.height.Bender/2)
            gc.push()
            gc.translate(0,50)
            gc.scale(custom.info.fieldScale)
            local sk=blockSkinList[custom.bOrder]
            for i=1,#blockDraw do
                local bd=blockDraw[i]
                skinFuncList[sk].unitDraw(nil,i-#blockDraw/2-.5,-.5,custom.color[bd],1,custom.texType[sk][bd])
            end
            gc.pop()
        end,
        event=function(x,y,bt)
            local success=false
            local w,h=bt.w,bt.h
            local s=custom.info.fieldScale
            if     x<-w/2+h then success=s> .75 custom.info.fieldScale=max(custom.info.fieldScale-.05,0.75)
            elseif x> w/2-h then success=s<1.25 custom.info.fieldScale=min(custom.info.fieldScale+.05,1.25)
            end
            bt.success=success
            if success then sfx.play('optionSwitch') end
        end
    },.2)

    BUTTON.create('rotationCenter',{
        x=-160,y=320,type='rect',w=80,h=80,
        draw=function(bt,t,ct)
            local animArg=custom.info.rotationCenter and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,320*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+320*animArg,-h/2,320*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(6)
            gc.rectangle('line',-w/2+3,-h/2+3,w-6,h-6)
            if custom.info.rotationCenter then
                gc.line(-w*3/8,0,-w/8,h/4,w*3/8,-h/4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.draw(rc.txt,w/2+16,0,0,rc.s,rc.s,0,rc.h/2)
        end,
        event=function()
            custom.info.rotationCenter=not custom.info.rotationCenter
            sfx.play(custom.info.rotationCenter and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('smoothAnim',{
        x=-160,y=-160,type='rect',w=80,h=80,
        draw=function(bt,t,ct)
            local animArg=custom.info.smoothAnimAct and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,320*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+320*animArg,-h/2,320*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(6)
            gc.rectangle('line',-w/2+3,-h/2+3,w-6,h-6)
            if custom.info.smoothAnimAct then
                gc.line(-w*3/8,0,-w/8,h/4,w*3/8,-h/4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.draw(sm.txt,w/2+16,0,0,sm.s,sm.s,0,sm.h/2)
        end,
        event=function()
            custom.info.smoothAnimAct=not custom.info.smoothAnimAct
            sfx.play(custom.info.smoothAnimAct and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('fallAnimType',{
        x=140,y=-80,type='rect',w=120,h=40,success=false,
        draw=function(bt,t,ct,cp)
            if not custom.info.smoothAnimAct then return end
            local o=custom.info.smoothFallType
            local w,h=bt.w,bt.h
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/2*(1-a)
                if cp[1]<0 then gc.line(-(w-h)/2-off,h/2,-w/2-off,0,-(w-h)/2-off,-h/2)
                else gc.line((w-h)/2+off,h/2,w/2+off,0,(w-h)/2+off,-h/2)
                end
            end
            gc.setColor(1,1,1)
            gc.draw(smf.txt,-340,0,0,smf.s,smf.s,0,smf.h/2)
            gc.setLineWidth(3)
            if o>1 then gc.line(-(w-h)/2,h/2-4,-w/2+4,0,-(w-h)/2,-h/2+4) end
            if o<2 then gc.line( (w-h)/2,h/2-4, w/2-4,0, (w-h)/2,-h/2+4) end
            gc.setColor(1,1,1)
            gc.printf(custom.info.smoothFallType,font.Bender,0,0,1280,'center',0,.4,.4,640,font.height.Bender/2)
        end,
        event=function(x,y,bt)
            if not custom.info.smoothAnimAct then return end
            local success=false
            if x<0 then
                if custom.info.smoothFallType>1 then custom.info.smoothFallType=custom.info.smoothFallType-1 success=true end
            elseif custom.info.smoothFallType<2 then custom.info.smoothFallType=custom.info.smoothFallType+1 success=true
            end
            bt.success=success
            if success then sfx.play('optionSwitch') end
        end
    },.2)

    SLIDER.create('smoothAnimTime',{
        x=0,y=-240,type='hori',sz={400,32},button={32,32},
        gear=0,pos=(custom.info.smoothTime-1/30)*15,
        sliderDraw=function(g,sz)
            if custom.info.smoothAnimAct then
            gc.setColor(.24,.48,.42,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.draw(st.txt,-210,-24,0,st.s,st.s,0,st.h)
            st.numTxt:clear()
            st.numTxt:add(string.format(":%3.0fms",custom.info.smoothTime*1000))
            gc.draw(st.numTxt,-210+st.ow,-24,0,.3125,.3125,0,st.h)
            end
        end,
        buttonDraw=function(pos,sz)
            if custom.info.smoothAnimAct then
                gc.setColor(1,1,1)
                gc.circle('fill',sz[1]*(pos-.5),0,20,4)
            end
        end,
        always=function(pos,s)
            if custom.info.smoothAnimAct then
            custom.info.smoothTime=(1+2*(floor(8*pos+.5)/8))/30
            end
            s.pos=(custom.info.smoothTime-1/30)*15
        end
    })
end
function custom.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function custom.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and SLIDER.mouseP(x,y,button,istouch) then end
end
function custom.mouseR(x,y,button,istouch)
    BUTTON.release(x,y) SLIDER.mouseR(x,y,button,istouch)
end
function custom.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function custom.draw()
    tt=custom.titleTxt
    gc.setColor(1,1,1)
    gc.draw(tt.txt,0,-510,0,tt.s,tt.s,tt.w/2,0)
    BUTTON.draw() SLIDER.draw()
end
function custom.exit()
    custom.save()
end
function custom.send(destScene,arg)
    if scene.dest=='game' then
    destScene.exitScene='game conf/custom'
    destScene.modeInfo={mode='conf_test'}
    destScene.resetStopMusic=false
    end
end
return custom