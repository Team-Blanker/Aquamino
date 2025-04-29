local M,T=myMath,myTable
local BUTTON,SLIDER=scene.button,scene.slider
local cf=user.lang.conf

local audio={}
function audio.read()
    audio.info={
        mus=.5,distractCut=false,
        sfx=.8,stereo=.5
    }
    local info=file.read('conf/audio')
    if fs.getInfo('conf/audio') then T.combine(audio.info,info) end
    mus.volume,sfx.volume=audio.info.mus,audio.info.sfx
    mus.distractCut=audio.info.distractCut
end
function audio.save()
    file.save('conf/audio',audio.info)
end
local function getdB(v)
    return v==0 and -1e999 or math.log(v,10)*10
end

audio.titleTxt={txt=gc.newText(font.Bender)}
local tt
audio.distractTxt={}
function audio.init()
    scene.BG=require'BG/settings'

    sfx.add({
        cOn='sfx/general/checkerOn.wav',
        cOff='sfx/general/checkerOff.wav',
        quit='sfx/general/confSwitch.wav',
        test='sfx/mode/general/sq.wav'
    })

    tt=audio.titleTxt
    tt.txt:clear()
    tt.txt:add(user.lang.conf.main.audio)
    tt.w,tt.h=tt.txt:getDimensions()
    tt.s=min(600/tt.w,1)

    cf=user.lang.conf
    audio.read()
    mus.volume,sfx.volume=audio.info.mus,audio.info.sfx

    local dtxt=audio.distractTxt
    dtxt.txt=gc.newText(font.Bender_B,cf.audio.distract)
    dtxt.w,dtxt.h=dtxt.txt:getDimensions()
    dtxt.s=min(270/dtxt.w,.25)

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

    BUTTON.create('distractCut',{
        x=100,y=-250,type='rect',w=60,h=60,
        draw=function(bt,t,ct)
            local animArg=audio.info.distractCut and min(ct/.2,1) or max(1-ct/.2,0)
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
            gc.rectangle('line',-w/2+2,-h/2+2,w-4,h-4)
            if audio.info.distractCut then
                gc.line(-w*3/8,0,-w/8,h/4,w*3/8,-h/4)
            end
            gc.setColor(r,g,b,2*t)
            gc.rectangle('fill',-w/2,-h/2,h,h)
            gc.setColor(1,1,1)
            gc.draw(dtxt.txt,w/2+15,0,0,dtxt.s,dtxt.s,0,dtxt.h/2)
            --gc.printf(cf.audio.distract,font.Bender_B,w/2+25+cf.audio.DOX,0,1200,'left',0,.25,.25,0,72)
            --DOX=Distract Offset X
        end,
        event=function()
            audio.info.distractCut=not audio.info.distractCut
            mus.distractCut=audio.info.distractCut
            sfx.play(audio.info.distractCut and 'cOn' or 'cOff')
        end
    },.2)

    SLIDER.create('mus_volume',{
        x=-480,y=-250,type='hori',sz={800,32},button={32,32},
        gear=0,pos=mus.volume,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(cf.audio.mus..":%3.0f%%,%5.2fdB",audio.info.mus*100,getdB(audio.info.mus)),
                font.JB,-410,-48,10000,'left',0,.3125,.3125,0,84)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            audio.info.mus=pos
            mus.setMasterVolume(pos)
        end
    })
    SLIDER.create('sfx_volume',{
        x=-480,y=-125,type='hori',sz={800,32},button={32,32},
        gear=0,pos=sfx.volume,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(cf.audio.sfx..":%3.0f%%,%5.2fdB",audio.info.sfx*100,getdB(audio.info.sfx)),
                font.JB,-410,-48,10000,'left',0,.3125,.3125,0,84)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            audio.info.sfx,sfx.volume=pos,pos
        end,
        release=function(pos)
            audio.info.sfx,sfx.volume=pos,pos
            sfx.play('test')
        end
    })
    SLIDER.create('sfx_stereo',{
        x=240,y=-125,type='hori',sz={400,32},button={32,32},
        gear=0,pos=(audio.info.stereo+1)/2,
        sliderDraw=function(g,sz)
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(cf.audio.stereo..":%3.0f%%",audio.info.stereo*100),
                font.JB,-210,-48,5000,'left',0,.3125,.3125,0,84)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            audio.info.stereo=pos*2-1
        end,
        release=function(pos)
            audio.info.stereo=pos*2-1
        end
    })
end
function audio.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function audio.mouseP(x,y,button,istouch)
    if not (BUTTON.press(x,y) or SLIDER.mouseP(x,y,button,istouch)) then end
end
function audio.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
end
function audio.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)) end
end
function audio.draw()
    gc.setColor(1,1,1)
    gc.draw(tt.txt,0,-510,0,tt.s,tt.s,tt.w/2,0)
    BUTTON.draw() SLIDER.draw()
end
function audio.exit()
    audio.save()
end
return audio