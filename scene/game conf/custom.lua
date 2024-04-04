local M,T=mymath,mytable
local cfc=user.lang.conf.custom

local custom={}
local block=require'mino/blocks'
local BUTTON,SLIDER=scene.button,scene.slider
function custom.read()
    custom.info={block='glossy',theme='simple',sfx='Dr Ocelot',smoothAnimAct=false,fieldScale=1}
    custom.color={}
    if fs.getInfo('conf/custom') then
        T.combine(custom.info,json.decode(fs.newFile('conf/custom'):read()))
    end
end
function custom.save()
    local s=fs.newFile('conf/custom')
    s:open('w')
    s:write(json.encode(custom.info))
    s:close()
end
function custom.init()
    cfc=user.lang.conf.custom
    custom.read()

    custom.blockSkinList={'glossy','pure','carbon fibre','wheelchair'}
    custom.themeList={'simple'}
    custom.sfxList={'krystal',
        'Dr Ocelot','meme','otto'
    }

    custom.bOrder=T.include(custom.blockSkinList,custom.info.block) or 1
    custom.tOrder=T.include(custom.themeList,custom.info.theme) or 1
    custom.sOrder=T.include(custom.sfxList,custom.info.sfx) or 1

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
                anim=function() anim.cover(.1,.05,.1,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('blockChoose',{
        x=0,y=-200,type='rect',w=400,h=100,
        draw=function(bt,t)
            local o,l=custom.bOrder,#custom.blockSkinList
            local w,h=bt.w,bt.h
            gc.setColor(.5,1,.75)
            gc.printf(cfc.texture,font.Exo_2_SB,0,-100,1280,'center',0,.5,.5,640,84)
            gc.setLineWidth(3)
            gc.rectangle('line',-bt.w/2,-bt.h/2,bt.w,bt.h)
            gc.setLineWidth(8)
            if o>1 then gc.line(-(w-h)/2,h/2-8,-w/2+8,0,-(w-h)/2,-h/2+8) end
            if o<l then gc.line( (w-h)/2,h/2-8, w/2-8,0, (w-h)/2,-h/2+8) end
            gc.setColor(1,1,1)
            gc.printf(custom.blockSkinList[custom.bOrder],font.Exo_2_SB,0,0,1280,'center',0,.4,.4,640,84)
        end,
        event=function(x,y)
            if x<0 then
                if custom.bOrder>1 then custom.bOrder=custom.bOrder-1 end
            elseif custom.bOrder<#custom.blockSkinList then custom.bOrder=custom.bOrder+1
            end
            custom.info.block=custom.blockSkinList[custom.bOrder]
        end
    },.2)
    BUTTON.create('colorChoose',{
        x=600,y=-200,type='rect',w=400,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.printf(cfc.color,font.Exo_2_SB,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/mino color'),swapT=.15,outT=.1,
                anim=function() anim.cover(.1,.05,.1,0,0,0) end
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
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.75,.4)
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
            gc.printf(cfc.smooth,font.Exo_2_SB,w/2+20+cfc.smoothOffX,cfc.smoothOffY,1200,'left',0,.3,.3,0,84)
            gc.setColor(1,1,1,.75)
            gc.printf(cfc.smoothTxt,font.Exo_2_SB,-w/2,h/2+32,1600,'left',0,.25,.25,0,84)
        end,
        event=function()
            custom.info.smoothAnimAct=not custom.info.smoothAnimAct
        end
    },.2)

    BUTTON.create('themeChoose',{
        x=0,y=150,type='rect',w=400,h=100,
        draw=function(bt,t)
            local o,l=custom.tOrder,#custom.themeList
            local w,h=bt.w,bt.h
            gc.setColor(1,.5,.5)
            gc.printf(cfc.theme,font.Exo_2_SB,0,-100,1280,'center',0,.5,.5,640,84)
            gc.setLineWidth(3)
            gc.rectangle('line',-bt.w/2,-bt.h/2,bt.w,bt.h)
            gc.setLineWidth(8)
            if o>1 then gc.line(-(w-h)/2,h/2-8,-w/2+8,0,-(w-h)/2,-h/2+8) end
            if o<l then gc.line( (w-h)/2,h/2-8, w/2-8,0, (w-h)/2,-h/2+8) end
            gc.setColor(1,1,1)
            gc.printf(custom.themeList[custom.tOrder],font.Exo_2_SB,0,0,1280,'center',0,.4,.4,640,84)
        end,
        event=function(x,y)
            if x<0 then
                if custom.tOrder>1 then custom.tOrder=custom.tOrder-1 end
            elseif custom.tOrder<#custom.themeList then custom.tOrder=custom.tOrder+1
            end
            custom.info.theme=custom.themeList[custom.tOrder]
        end
    },.2)
    BUTTON.create('sfxChoose',{
        x=600,y=150,type='rect',w=400,h=100,
        draw=function(bt,t)
            local o,l=custom.sOrder,#custom.sfxList
            local w,h=bt.w,bt.h
            gc.setColor(1,.5,1)
            gc.printf(cfc.sfx,font.Exo_2_SB,0,-100,1280,'center',0,.5,.5,640,84)
            gc.setLineWidth(3)
            gc.rectangle('line',-bt.w/2,-bt.h/2,bt.w,bt.h)
            gc.setLineWidth(8)
            if o>1 then gc.line(-(w-h)/2,h/2-8,-w/2+8,0,-(w-h)/2,-h/2+8) end
            if o<l then gc.line( (w-h)/2,h/2-8, w/2-8,0, (w-h)/2,-h/2+8) end
            gc.setColor(1,1,1)
            gc.printf(custom.sfxList[custom.sOrder],font.Exo_2_SB,0,0,1280,'center',0,.4,.4,640,84)
            if cfc.sfxWarning[custom.sfxList[o]] then gc.setColor(1,0,0,.75)
            gc.printf(cfc.sfxWarning[custom.sfxList[o]],font.Exo_2_SB,-w/2,h/2+48,1600,'left',0,.25,.25,0,152)
            end
        end,
        event=function(x,y)
            if x<0 then
                if custom.sOrder>1 then custom.sOrder=custom.sOrder-1 end
            elseif custom.sOrder<#custom.sfxList then custom.sOrder=custom.sOrder+1
            end
            custom.info.sfx=custom.sfxList[custom.sOrder]
        end
    },.2)
    BUTTON.create('scaleAdjust',{
        x=-600,y=150,type='rect',w=400,h=100,
        draw=function(bt,t,ct,pos)
            local sz=custom.info.fieldScale
            local w,h=bt.w,bt.h
            gc.setColor(.5,1,1)
            gc.printf(cfc.scale,font.Exo_2_SB,0,-100,1280,'center',0,.5,.5,640,84)

            gc.setColor(.5,1,1)
            gc.setLineWidth(4)
            gc.circle('line',-(w-h)/2,0,h/2)
            gc.circle('line', (w-h)/2,0,h/2)
            gc.setLineWidth(16)
            gc.setColor(1,1,1)
            if sz>0.76 then gc.line(-(w-h)/2-h/2*.625,0,-(w-h)/2+h/2*.625,0) end
            if sz<1.24 then
                gc.line( (w-h)/2-h/2*.625,0, (w-h)/2+h/2*.625,0)
                gc.line( (w-h)/2,h/2*.625,(w-h)/2,-h/2*.625)
            end
            gc.setColor(1,1,1)
            gc.printf(("%.2f"):format(sz),font.Exo_2_SB,0,0,1280,'center',0,.5,.5,640,84)
            gc.setColor(1,1,1,.75)
            gc.printf(cfc.scaleTxt,font.Exo_2_SB,-w/2,h/2+48,1600,'left',0,.25,.25,0,152)
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
    if not BUTTON.click(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function custom.mouseR(x,y,button,istouch)

end
function custom.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function custom.draw()
    gc.setColor(1,1,1)
    gc.printf(user.lang.conf.main.custom,font.Exo_2,0,-460,1280,'center',0,1,1,640,84)
    BUTTON.draw() SLIDER.draw()
end
function custom.exit()
    custom.save()
end
return custom