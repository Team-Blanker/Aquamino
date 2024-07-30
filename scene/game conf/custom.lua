local M,T=mymath,mytable
local cfc=user.lang.conf.custom

local custom={}
local block=require'mino/blocks'
local BUTTON,SLIDER=scene.button,scene.slider

local blockSkinList={'glossy','glass','pure','carbon fibre','wheelchair'}
local themeList={'simple'}
local sfxList={'plastic','krystal','meme','otto'}
local RSList={'SRS','AqRS'}
function custom.read()
    custom.info={block='glossy',theme='simple',sfx='plastic',RS='SRS',smoothAnimAct=false,smoothTime=.05,fieldScale=1}
    custom.color={}
    local info=file.read('conf/custom')
    T.combine(custom.info,info)
end
function custom.save()
    file.save('conf/custom',custom.info)
end
function custom.init()
    sfx.add({
        cOn='sfx/general/checkerOn.wav',
        cOff='sfx/general/checkerOff.wav',
        click='sfx/general/buttonClick.wav',
        sceneSwitch='sfx/general/confSwitch.wav',
        optionSwitch='sfx/general/optionSwitch.wav',
    })

    cfc=user.lang.conf.custom
    custom.read()

    custom.bOrder=T.include(blockSkinList,custom.info.block) or 1
    custom.RSOrder=T.include(RSList,custom.info.RS) or 1
    custom.tOrder=T.include(themeList,custom.info.theme) or 1
    custom.sOrder=T.include(sfxList,custom.info.sfx) or 1

    custom.sTxt={txt=gc.newText(font.Bender_B,cfc.scaleTxt)}
    custom.sTxt.w,custom.sTxt.h=custom.sTxt.txt:getDimensions()

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
            gc.printf(user.lang.conf.test,font.Bender,0,0,1280,'center',0,.5,.5,640,72)
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

    BUTTON.create('blockChoose',{
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
            gc.setColor(.5,1,.875)
            gc.printf(cfc.texture,font.Bender_B,0,-h/2-48,1280,'center',0,.45,.45,640,72)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(blockSkinList[custom.bOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
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
            gc.setColor(1,.75,.5)
            gc.printf(cfc.RS,font.Bender_B,0,-h/2-48,1280,'center',0,.45,.45,640,72)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(RSList[custom.RSOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
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
            gc.printf(cfc.color,font.Bender_B,0,0,1280,'center',0,.4,.4,640,72)
        end,
        event=function()
            sfx.play('sceneSwitch')
            scene.switch({
                dest='conf',destScene=require('scene/game conf/mino color'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('smoothAnim',{
        x=-760,y=-280,type='rect',w=80,h=80,
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
            gc.setLineWidth(8)
            gc.rectangle('line',-w/2+4,-h/2+4,h-8,h-8)
            if custom.info.smoothAnimAct then
                gc.circle('line',0,0,(w/2-4)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cfc.smooth,font.Bender_B,w/2+40+cfc.smoothOffX,0,1200,'left',0,cfc.smoothScale,cfc.smoothScale,0,72)
        end,
        event=function()
            custom.info.smoothAnimAct=not custom.info.smoothAnimAct
            sfx.play(custom.info.smoothAnimAct and 'cOn' or 'cOff')
        end
    },.2)
    SLIDER.create('smoothAnimTime',{
        x=-600,y=-400,type='hori',sz={400,32},button={32,32},
        gear=0,pos=(custom.info.smoothTime-1/30)*15,
        sliderDraw=function(g,sz)
            if custom.info.smoothAnimAct then
            gc.setColor(.24,.48,.42,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(cfc.smoothTime.."%.0fms",custom.info.smoothTime*1000),
                font.JB,-sz[1]/2-16,-48,114514,'left',0,.3125,.3125,0,84)
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

    BUTTON.create('themeChoose',{
        x=0,y=320,type='rect',w=450,h=80,success=false,
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
            gc.setColor(1,.5,.5)
            gc.printf(cfc.theme,font.Bender_B,0,-h/2-48,1280,'center',0,.45,.45,640,72)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(themeList[custom.tOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
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
            gc.setColor(1,.25,.75)
            gc.printf(cfc.sfx,font.Bender_B,0,-h/2-48,1280,'center',0,.45,.45,640,72)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(sfxList[custom.sOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
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
        x=0,y=-160,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local sz=custom.info.fieldScale
            local w,h=bt.w,bt.h
            gc.setColor(.3,.65,1)
            gc.printf(cfc.scale,font.Bender_B,0,-h/2-48,1280,'center',0,.45,.45,640,72)

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
            gc.printf(("%.2f"):format(sz),font.Bender,0,0,1280,'center',0,.45,.45,640,72)
            gc.setColor(1,1,1,.75)
            gc.draw(custom.sTxt.txt,-w/2,h/2+36,0,.25,.25,0,custom.sTxt.h/2)
            local bsz=36*custom.info.fieldScale
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2+.25*custom.sTxt.w+16,h/2+36-bsz/2,bsz,bsz)
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
    gc.setColor(1,1,1)
    gc.printf(user.lang.conf.main.custom,font.Bender,0,-430,1280,'center',0,1,1,640,72)
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