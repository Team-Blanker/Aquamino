local M,T=mymath,mytable
local cf=user.lang.conf

local video={}
local BUTTON,SLIDER=scene.button,scene.slider
function video.read()
    local isMobile=win.OS=='Android' or win.OS=='iOS'
    video.info={unableBG=false,vsync=false,fullscr=false,frameLim=isMobile and 60 or 120,discardAfterDraw=false}
    local info=file.read('conf/video')
    T.combine(video.info,info)
    win.setFullscr(video.info.fullscr)
    win.discardAfterDraw=video.info.discardAfterDraw
end
function video.save()
    file.save('conf/video',video.info)
    love.window.setVSync(video.info.vsync and 1 or 0)
    drawCtrl.dtRestrict=1/video.info.frameLim
end

local iq=gc.newImage('pic/UI/sign/info_question.png') --64*64
local vit,vir=0,0
local vsf=function() gc.rectangle('fill',vir/2-635,vir+3,645,(video.vth*.25+10)*4*vit) end
local dit,dir=0,0
local dsf=function() gc.rectangle('fill',dir/2-635,dir+3,645,(video.dth*.25+10)*4*dit) end

function video.init()
    sfx.add({
        cOn='sfx/general/checkerOn.wav',
        cOff='sfx/general/checkerOff.wav',
        quit='sfx/general/confSwitch.wav',
    })

    cf=user.lang.conf
    video.info.fullscr=win.fullscr video.save() video.read()

    video.vsyncTxt=gc.newText(font.Bender_B)
    video.vsyncTxt:addf(cf.video.vsyncTxt,2500,'left')
    video.vth=video.vsyncTxt:getHeight()

    video.DADTxt=gc.newText(font.Bender_B)
    video.DADTxt:addf(cf.video.DADTxt,2500,'left')
    video.dth=video.DADTxt:getHeight()

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
            sfx.play('quit')
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    },.2)

    BUTTON.create('unableBG',{
        x=-750,y=-240,type='rect',w=80,h=80,
        draw=function(bt,t,ct)
            local animArg=video.info.unableBG and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(8)
            gc.rectangle('line',-w/2+4,-h/2+4,h-8,h-8)
            if video.info.unableBG then
                gc.circle('line',0,0,(w/2-4)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.unableBG,font.Bender_B,w/2+40,0,1200,'left',0,.35,.35,0,72)
        end,
        event=function()
            video.info.unableBG=not video.info.unableBG
            sfx.play(video.info.unableBG and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('vsync',{
        x=390,y=-240,type='rect',w=80,h=80,
        draw=function(bt,t,ct)
            local animArg=video.info.vsync and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(8)
            gc.rectangle('line',-w/2+4,-h/2+4,h-8,h-8)
            if video.info.vsync then
                gc.circle('line',0,0,(w/2-4)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.vsync,font.Bender_B,w/2+40,0,1200,'left',0,.35,.35,0,72)
        end,
        event=function()
            video.info.vsync=not video.info.vsync
            love.window.setVSync(video.info.vsync and 1 or 0)
            sfx.play(video.info.vsync and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('vsyncInfo',{
        x=800,y=-160,type='circle',r=32,
        draw=function(bt,t,ct)
            gc.setColor(1,1,1)
            gc.draw(iq,0,0,0,.5,.5,32,32)
            gc.setColor(0,0,0,.5)
            vsf()
            vit=t vir=bt.r
            gc.stencil(vsf,'replace',1)
            gc.setStencilTest('equal',1)
            gc.setColor(1,1,1)
            gc.draw(video.vsyncTxt,bt.r/2,bt.r+8,0,.25,.25,2500,0)
            gc.setStencilTest()
        end,
        event=function()
        end
    },.25)
    BUTTON.create('fullscr',{
        x=-180,y=-240,type='rect',w=80,h=80,
        draw=function(bt,t,ct)
            local animArg=video.info.fullscr and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(8)
            gc.rectangle('line',-w/2+4,-h/2+4,h-8,h-8)
            if video.info.fullscr then
                gc.circle('line',0,0,(w/2-4)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.fullScr,font.Bender_B,w/2+40,0,1200,'left',0,.35,.35,0,72)
            gc.setColor(1,1,1,.75)
            gc.printf(cf.video.fullScrTxt,font.Bender_B,-w/2,h/2+64,1840,'left',0,.25,.25,0,152)
        end,
        event=function()
            video.info.fullscr=not video.info.fullscr
            win.setFullscr(video.info.fullscr)
            sfx.play(video.info.fullscr and 'cOn' or 'cOff')
        end
    },.2)
    --[[BUTTON.create('discardAfterDraw',{
        x=390,y=0,type='rect',w=80,h=80,
        draw=function(bt,t,ct)
            local animArg=video.info.discardAfterDraw and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.875,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(8)
            gc.rectangle('line',-w/2+4,-h/2+4,h-8,h-8)
            if video.info.discardAfterDraw then
                gc.circle('line',0,0,(w/2-4)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.discardAfterDraw,font.Bender_B,w/2+40,0,1200,'left',0,.35,.35,0,72)
        end,
        event=function()
            video.info.discardAfterDraw=not video.info.discardAfterDraw
            win.discardAfterDraw=video.info.discardAfterDraw
            sfx.play(video.info.discardAfterDraw and 'cOn' or 'cOff')
        end
    },.2)
    BUTTON.create('DADInfo',{
        x=800,y=80,type='circle',r=32,
        draw=function(bt,t,ct)
            gc.setColor(1,1,1)
            gc.draw(iq,0,0,0,.5,.5,32,32)
            gc.setColor(0,0,0,.5)
            dsf()
            dit=t dir=bt.r
            gc.stencil(dsf,'replace',1)
            gc.setStencilTest('equal',1)
            gc.setColor(1,1,1)
            gc.draw(video.DADTxt,bt.r/2,bt.r+8,0,.25,.25,2500,0)
            gc.setStencilTest()
        end,
        event=function()
        end
    },.25)]]
    SLIDER.create('frameLim',{
        x=-400,y=0,type='hori',sz={800,32},button={32,32},
        gear=0,pos=(video.info.frameLim-60)/240,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(cf.video.frameLim.."%d",video.info.frameLim),
                font.JB,-419,-48,114514,'left',0,.3125,.3125,0,84)
            gc.setColor(1,1,1,.75)
            gc.printf(cf.video.frameTxt,font.Bender_B,-419,48,114514,'left',0,.25,.25,0,72)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            video.info.frameLim=math.floor(60.5+pos*240)
        end,
        release=function(pos)
            video.info.frameLim=math.floor(60.5+pos*240)
            drawCtrl.dtRestrict=1/video.info.frameLim
        end
    })
end
function video.detectKeyP(k)
    if k=='f11' then video.info.fullscr=win.fullscr end
end
function video.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and SLIDER.mouseP(x,y,button,istouch) then end
end
function video.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
end
function video.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function video.draw()
    gc.setColor(1,1,1)
    gc.printf(cf.main.video,font.Bender,0,-430,1280,'center',0,1,1,640,72)
    BUTTON.draw() SLIDER.draw()
end
function video.exit()
    video.save()
end
return video