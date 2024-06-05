local M,T=mymath,mytable
local cf=user.lang.conf

local video={}
local BUTTON,SLIDER=scene.button,scene.slider
function video.read()
    video.info={unableBG=false,vsync=false,fullscr=false,frameLim=120}
    if fs.getInfo('conf/video') then T.combine(video.info,json.decode(fs.newFile('conf/video'):read())) end
    win.setFullscr(video.info.fullscr)
end
function video.save()
    local s=fs.newFile('conf/video')
    s:open('w')
    s:write(json.encode(video.info))
    love.window.setVSync(video.info.vsync and 1 or 0)
    drawCtrl.dtRestrict=1/video.info.frameLim
end

local iq=gc.newImage('pic/UI/sign/info_question.png') --64*64
local vit,vir=0,0
local vsf=function() gc.rectangle('fill',vir/2-635,vir+3,645,(video.vth*.25+10)*4*vit) end
function video.init()
    cf=user.lang.conf
    video.info.fullscr=win.fullscr video.save() video.read()

    video.vsyncTxt=gc.newText(font.Bender_B)
    video.vsyncTxt:addf(cf.video.vsyncTxt,2500,'left')
    video.vth=video.vsyncTxt:getHeight()

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
    })

    BUTTON.create('unableBG',{
        x=-750,y=-240,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=video.info.unableBG and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if video.info.unableBG then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.unableBG,font.Bender_B,w/2+50,0,1200,'left',0,.35,.35,0,76)
            gc.setColor(1,1,1,.75)
            gc.printf(cf.video.unableTxt,font.Bender_B,-w/2,h/2+60,1840,'left',0,.25,.25,0,152)
        end,
        event=function()
            video.info.unableBG=not video.info.unableBG
        end
    },.2)
    BUTTON.create('vsync',{
        x=390,y=-240,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=video.info.vsync and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if video.info.vsync then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.vsync,font.Bender_B,w/2+50,0,1200,'left',0,.35,.35,0,76)
        end,
        event=function()
            video.info.vsync=not video.info.vsync
            love.window.setVSync(video.info.vsync and 1 or 0)
        end
    },.2)
    BUTTON.create('vsyncInfo',{
        x=800,y=-160,type='circle',r=32,
        draw=function(bt,t,ct)
            gc.setColor(1,1,1)
            gc.draw(iq,0,0,0,.5,.5,32,32)
            gc.setColor(0,0,0,.5)
            gc.rectangle('fill',bt.r/2-635,bt.r+3,645,(video.vth*.25+10)*4*t)

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
        x=-180,y=-240,type='rect',w=100,h=100,
        draw=function(bt,t,ct)
            local animArg=video.info.fullscr and min(ct/.2,1) or max(1-ct/.2,0)
            local w,h=bt.w,bt.h
            local r=M.lerp(1,.5,animArg)
            local g=1
            local b=M.lerp(1,.75,animArg)
            gc.setColor(.5,1,.875,.4)
            gc.rectangle('fill',w/2,-h/2,360*animArg,h)
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',w/2+360*animArg,-h/2,360*(1-animArg),h)
            gc.setColor(r,g,b)
            gc.setLineWidth(10)
            gc.rectangle('line',-w/2+5,-h/2+5,h-10,h-10)
            if video.info.fullscr then
                gc.circle('line',0,0,(w/2-5)*1.4142,4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.printf(cf.video.fullScr,font.Bender_B,w/2+50,0,1200,'left',0,.35,.35,0,76)
            gc.setColor(1,1,1,.75)
            gc.printf(cf.video.fullScrTxt,font.Bender_B,-w/2,h/2+64,1840,'left',0,.25,.25,0,152)
        end,
        event=function()
            video.info.fullscr=not video.info.fullscr
            win.setFullscr(video.info.fullscr)
        end
    },.2)
    SLIDER.create('frameLim',{
        x=-400,y=0,type='hori',sz={800,32},button={32,32},
        gear=0,pos=(video.info.frameLim-60)/240,
        sliderDraw=function()
            gc.setColor(.5,.5,.5,.8)
            gc.rectangle('fill',-416,-16,832,32)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(6)
            gc.rectangle('line',-419,-19,838,38)
            gc.setColor(1,1,1)
            gc.printf(string.format(cf.video.frameLim.."%d",video.info.frameLim),
                font.JB,-419,-48,114514,'left',0,.3125,.3125,0,84)
                gc.setColor(1,1,1,.75)
            gc.printf(cf.video.frameTxt,font.Bender_B,-419,48,114514,'left',0,.25,.25,0,76)
        end,
        buttonDraw=function(pos)
            gc.setColor(1,1,1)
            gc.rectangle('fill',800*(pos-.5)-16,-18,32,36)
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
    if not BUTTON.press(x,y,button,istouch) and SLIDER.mouseP(x,y,button,istouch) then end
end
function video.mouseR(x,y,button,istouch)
    BUTTON.release(x,y,button,istouch)
    SLIDER.mouseR(x,y,button,istouch)
end
function video.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    end
end
function video.draw()
    gc.setColor(1,1,1)
    gc.printf(cf.main.video,font.Bender,0,-430,1280,'center',0,1,1,640,76)
    BUTTON.draw() SLIDER.draw()
end
function video.exit()
    video.save()
end
return video