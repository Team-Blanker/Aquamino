local M,T=mymath,mytable
local cfc=user.lang.conf.custom

local custom={}
local block=require'mino/blocks'
local BUTTON,SLIDER=scene.button,scene.slider

blockSkinList={'glossy','glass','pure','carbon fibre','wheelchair'}
themeList={'simple'}
sfxList={'plastic','krystal','meme','otto'}
function custom.read()
    custom.info={block='glossy',theme='simple',sfx='plastic',smoothAnimAct=false,smoothTime=.05,fieldScale=1}
    custom.color={}
    local info=file.read('conf/custom')
    T.combine(custom.info,info)
    if not T.include(blockSkinList,custom.info.block) then custom.info.block='glossy' end
    if not T.include(themeList,custom.info.theme) then custom.info.theme='simple' end
    if not T.include(sfxList,custom.info.sfx) then custom.info.sfx='plastic' end
end
function custom.save()
    file.save('conf/custom',custom.info)
end
function custom.init()
    cfc=user.lang.conf.custom
    custom.read()

    custom.bOrder=T.include(blockSkinList,custom.info.block) or 1
    custom.tOrder=T.include(themeList,custom.info.theme) or 1
    custom.sOrder=T.include(sfxList,custom.info.sfx) or 1

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
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
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(user.lang.conf.test,font.Bender,0,0,1280,'center',0,.5,.5,640,72)
        end,
        event=function()
            scene.switch({
                dest='game',destScene=require'mino/game',
                swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
        end
    },.2)

    BUTTON.create('blockChoose',{
        x=0,y=-200,type='rect',w=400,h=100,
        draw=function(bt,t)
            local o,l=custom.bOrder,#blockSkinList
            local w,h=bt.w,bt.h
            gc.setColor(.5,1,.875)
            gc.printf(cfc.texture,font.Bender_B,0,-100,1280,'center',0,.5,.5,640,72)
            gc.setLineWidth(3)
            gc.rectangle('line',-bt.w/2,-bt.h/2,bt.w,bt.h)
            gc.setLineWidth(8)
            if o>1 then gc.line(-(w-h)/2,h/2-8,-w/2+8,0,-(w-h)/2,-h/2+8) end
            if o<l then gc.line( (w-h)/2,h/2-8, w/2-8,0, (w-h)/2,-h/2+8) end
            gc.setColor(1,1,1)
            gc.printf(blockSkinList[custom.bOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
        end,
        event=function(x,y)
            if x<0 then
                if custom.bOrder>1 then custom.bOrder=custom.bOrder-1 end
            elseif custom.bOrder<#blockSkinList then custom.bOrder=custom.bOrder+1
            end
            custom.info.block=blockSkinList[custom.bOrder]
        end
    },.2)
    BUTTON.create('colorAdjust',{
        x=600,y=-200,type='rect',w=400,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(cfc.color,font.Bender_B,0,0,1280,'center',0,.5,.5,640,72)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/mino color'),swapT=.15,outT=.1,
                anim=function() anim.confSelect(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('smoothAnim',{
        x=-750,y=-200,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=custom.info.smoothAnimAct and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,300*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+300*animArg,-h/2,300*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if custom.info.smoothAnimAct then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cfc.smooth,font.Bender_B,w/2+50+cfc.smoothOffX,0,1200,'left',0,cfc.smoothScale,cfc.smoothScale,0,72)
            gc.setColor(1,1,1,.75)
            gc.printf(cfc.smoothTxt,font.Bender_B,-w/2,h/2+32,1600,'left',0,.25,.25,0,72)
        end,
        event=function()
            custom.info.smoothAnimAct=not custom.info.smoothAnimAct
        end
    },.2)
    SLIDER.create('smoothAnimTime',{
        x=-600,y=-320,type='hori',sz={400,32},button={32,32},
        gear=0,pos=(custom.info.smoothTime-1/30)*15,
        sliderDraw=function(g,s)
            if custom.info.smoothAnimAct then
            gc.setColor(.24,.48,.42,.8)
            gc.rectangle('fill',-s.sz[1]/2-16,-16,s.sz[1]+32,32)
            gc.setColor(.44,.88,.77)
            gc.setLineWidth(6)
            gc.rectangle('line',-s.sz[1]/2-19,-19,s.sz[1]+38,38)
            gc.setColor(1,1,1)
            gc.printf(string.format(cfc.smoothTime.."%.0fms",custom.info.smoothTime*1000),
                font.JB,-s.sz[1]/2-19,-48,114514,'left',0,.3125,.3125,0,84)
            end
        end,
        buttonDraw=function(pos,s)
            if custom.info.smoothAnimAct then
            gc.setColor(1,1,1)
            gc.rectangle('fill',s.sz[1]*(pos-.5)-16,-18,32,36)
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
        x=0,y=150,type='rect',w=400,h=100,
        draw=function(bt,t)
            local o,l=custom.tOrder,#themeList
            local w,h=bt.w,bt.h
            gc.setColor(1,.5,.5)
            gc.printf(cfc.theme,font.Bender_B,0,-100,1280,'center',0,.5,.5,640,72)
            gc.setLineWidth(3)
            gc.rectangle('line',-bt.w/2,-bt.h/2,bt.w,bt.h)
            gc.setLineWidth(8)
            if o>1 then gc.line(-(w-h)/2,h/2-8,-w/2+8,0,-(w-h)/2,-h/2+8) end
            if o<l then gc.line( (w-h)/2,h/2-8, w/2-8,0, (w-h)/2,-h/2+8) end
            gc.setColor(1,1,1)
            gc.printf(themeList[custom.tOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
        end,
        event=function(x,y)
            if x<0 then
                if custom.tOrder>1 then custom.tOrder=custom.tOrder-1 end
            elseif custom.tOrder<#themeList then custom.tOrder=custom.tOrder+1
            end
            custom.info.theme=themeList[custom.tOrder]
        end
    },.2)
    BUTTON.create('sfxChoose',{
        x=600,y=150,type='rect',w=400,h=100,
        draw=function(bt,t)
            local o,l=custom.sOrder,#sfxList
            local w,h=bt.w,bt.h
            gc.setColor(1,.5,1)
            gc.printf(cfc.sfx,font.Bender_B,0,-100,1280,'center',0,.5,.5,640,72)
            gc.setLineWidth(3)
            gc.rectangle('line',-bt.w/2,-bt.h/2,bt.w,bt.h)
            gc.setLineWidth(8)
            if o>1 then gc.line(-(w-h)/2,h/2-8,-w/2+8,0,-(w-h)/2,-h/2+8) end
            if o<l then gc.line( (w-h)/2,h/2-8, w/2-8,0, (w-h)/2,-h/2+8) end
            gc.setColor(1,1,1)
            gc.printf(sfxList[custom.sOrder],font.Bender,0,0,1280,'center',0,.4,.4,640,72)
            if cfc.sfxWarning[sfxList[o]] then gc.setColor(1,0,0,.75)
            gc.printf(cfc.sfxWarning[sfxList[o]],font.Bender_B,-w/2,h/2+48,1600,'left',0,.25,.25,0,152)
            end
        end,
        event=function(x,y)
            if x<0 then
                if custom.sOrder>1 then custom.sOrder=custom.sOrder-1 end
            elseif custom.sOrder<#sfxList then custom.sOrder=custom.sOrder+1
            end
            custom.info.sfx=sfxList[custom.sOrder]
        end
    },.2)
    BUTTON.create('scaleAdjust',{
        x=-600,y=150,type='rect',w=400,h=100,
        draw=function(bt,t,ct,pos)
            local sz=custom.info.fieldScale
            local w,h=bt.w,bt.h
            gc.setColor(.5,1,1)
            gc.printf(cfc.scale,font.Bender_B,0,-100,1280,'center',0,.5,.5,640,72)

            gc.setColor(.5,1,1)
            gc.setLineWidth(4)
            gc.circle('line',-(w-h)/2,0,h/2)
            gc.circle('line', (w-h)/2,0,h/2)
            gc.setLineWidth(12)
            gc.setColor(1,1,1)
            if sz>0.76 then gc.line(-(w-h)/2-h/2*.625,0,-(w-h)/2+h/2*.625,0) end
            if sz<1.24 then
                gc.line( (w-h)/2-h/2*.625,0, (w-h)/2+h/2*.625,0)
                gc.line( (w-h)/2,h/2*.625,(w-h)/2,-h/2*.625)
            end
            gc.setColor(1,1,1)
            gc.printf(("%.2f"):format(sz),font.Bender,0,0,1280,'center',0,.5,.5,640,72)
            gc.setColor(1,1,1,.75)
            gc.printf(cfc.scaleTxt,font.Bender_B,-w/2,h/2+48,1600,'left',0,.25,.25,0,152)
        end,
        event=function(x,y,bt)
            local w,h=bt.w,bt.h
            if     x<-w/2+h then custom.info.fieldScale=max(custom.info.fieldScale-.05,0.75)
            elseif x> w/2-h then custom.info.fieldScale=min(custom.info.fieldScale+.05,1.25)
            end
        end
    },.2)
end
function custom.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function custom.mouseR(x,y,button,istouch)
    BUTTON.release(x,y,button,istouch) SLIDER.mouseR(x,y,button,istouch)
end
function custom.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
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
    destScene.mode='conf_test'
    destScene.resetStopMusic=false
    end
end
return custom