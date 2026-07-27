local M,T=myMath,myTable
local BUTTON,SLIDER=scene.button,scene.slider
local setColor=gc.setColor
local draw,printf=gc.draw,gc.printf
local round=myMath.round

local gameList={'territory','tracks','zombie','square'}
local gameScene={
    territory='territory/territory',
    tracks='tracks/tracks',
    zombie='zombie/zombie',
    square='square/battle',
}
local gamePic={}
for k,v in pairs(gameList) do
    gamePic[v]=gc.newImage('pic/AquaMarbler/'..v..'.png')
end
local am={}

local logo_yt=gc.newImage('pic/assets/youtube.png')
local logo_bili=gc.newImage('pic/assets/bilibili.png')

local musTag={'AquaMarbler'}
function am.init()
    if not mus.checkTag('AquaMarbler') then
        mus.add('music/Hurt Record/seidou','whole','ogg',12,122.88)
        mus.start()

        mus.setTag(musTag)
    end

    scene.BG=require'BG/settings'
    if scene.BG.init then scene.BG.init() end

    if not am.mode then am.mode=1 end--注意为了做动画用的是是浮点数

    am.targetMode=1
    am.targetConfirmed=true

    am.floatModeError=0 --划到的位置和目标位置的误差
    am.floatAdjustTime=0 --调整误差的动画时长
    am.switchSpeed=0 --滑动的时候残留的速度

    am.curKey=nil --记录当前按下的方向键
    am.keyMoveAnimTimer=0 --通过方向键移动时的动画
    am.keyMoveDir=0

    am.txt=user.lang.AquaMarbler

    sfx.add({
        click='sfx/general/buttonClick.wav',
        quit='sfx/general/buttonQuit.wav',
        rbopen='sfx/general/ruleBookOpen.wav',
    })

    BUTTON.create('quit',{
        x=-700,y=420,type='rect',w=200,h=100,
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
                dest='conf',destScene=require('scene/intro'),swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('play',{
        x=0,y=420,type='rect',w=600,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.circle('fill',-5,0,40,3)
        end,
        event=function()
            if not (am.targetConfirmed and am.mode%1==0) then return end
            sfx.play('click')
            scene.switch({
                destScene=require('minigame/'..gameScene[gameList[1+(am.mode-1)%4]]),swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    },.2)
    BUTTON.create('bilibili',{
        x=550,y=420,type='rect',w=100,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(1/2,1/6,4/15,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(1,1/3,8/15)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(logo_bili,0,0,0,.3,.3,100,100)
        end,
        event=function()
            if not (am.targetConfirmed and am.mode%1==0) then return end
            sfx.play('rbopen')
            love.system.openURL('https://space.bilibili.com/210243326/lists/7412419')
        end
    },.2)
    BUTTON.create('youtube',{
        x=750,y=420,type='rect',w=100,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,0,.1,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(1,0,.2)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(logo_yt,0,0,0,.3,.3,100,100)
        end,
        event=function()
            if not (am.targetConfirmed and am.mode%1==0) then return end
            sfx.play('rbopen')
            love.system.openURL('https://www.youtube.com/channel/UC5XcIb4aMBfsXJX_weAZbQw')
        end
    },.2)
end

local drag,px,py,nx,ny,mx,my
function am.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='conf',destScene=require('scene/intro'),swapT=.6,outT=.2,
            anim=function() anim.cover(.2,.4,.2,0,0,0) end
        })
    end
    if k=='left' or k=='a' then
            am.curKey='left'
    elseif k=='right' or k=='d' then
        am.curKey='right'
    end
    if am.targetConfirmed and am.mode%1==0 and not drag then
        if k=='left' or k=='a' then
            am.targetMode=am.mode-1
            am.keyMoveAnimTimer=1
            am.keyMoveDir=-1
        elseif k=='right' or k=='d' then
            am.targetMode=am.mode+1
            am.keyMoveAnimTimer=1
            am.keyMoveDir= 1
        elseif k=='space' or k=='return' then
            scene.switch({
                destScene=require('minigame/'..gameScene[gameList[1+(am.mode-1)%4]]),swapT=.6,outT=.2,
                anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
        end
    end
end
function am.keyR(k)
    if k=='left' or k=='a' then
        if kb.isDown('right','d') then am.curKey='right' end
    elseif k=='right' or k=='d' then
        if kb.isDown('left','a') then am.curKey='left' end
    end
end
function am.mouseP(x,y,button,istouch)
    if not (BUTTON.press(x,y) or SLIDER.mouseP(x,y,button,istouch)) and am.keyMoveAnimTimer==0 then
        drag=true
        nx,ny=x,y
        am.floatAdjustTime=0
        am.targetConfirmed=false
    end
end
function am.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
    drag=false
end
function am.update(dt)
    mx,my=adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    BUTTON.update(dt,mx,my)
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],mx,my) end
    if drag then
        px,py=nx,ny
        nx,ny=mx,my
        am.mode=am.mode-(nx-px)/960
        am.switchSpeed=0
    else
        if am.keyMoveAnimTimer>0 then
            am.keyMoveAnimTimer=max(am.keyMoveAnimTimer-dt*5,0)
            am.mode=1+(am.targetMode-am.keyMoveDir*am.keyMoveAnimTimer^3-1)%4
            if am.keyMoveAnimTimer==0 then
                if kb.isDown('left','right','a','d') and am.keyMoveAnimTimer==0 then am.keyP(am.curKey) end
            end
        else
            if (nx and nx-px~=0) then
                if am.switchSpeed==0 and not am.targetConfirmed then am.switchSpeed=(px-nx)/960/dt end
                nx,ny,px,py=nil,nil,nil,nil
            else
                am.floatModeError=am.mode-round(am.mode) am.targetMode=round(am.mode) am.targetConfirmed=true
            end
            if am.switchSpeed>0 then
                am.switchSpeed=max(am.switchSpeed-dt*40,0)
                am.mode=am.mode+am.switchSpeed*dt
            elseif am.switchSpeed<0 then
                am.switchSpeed=min(am.switchSpeed+dt*40,0)
                am.mode=am.mode+am.switchSpeed*dt
            else
                if not am.targetConfirmed then
                    am.floatModeError=am.mode-round(am.mode) am.targetMode=round(am.mode) am.targetConfirmed=true
                end
                if am.floatModeError>0 then
                    am.floatAdjustTime=am.floatAdjustTime+dt
                    am.floatModeError=am.floatModeError-am.floatAdjustTime*dt*16
                    if am.floatModeError<=0 then
                        am.floatAdjustTime=0
                        am.floatModeError=0
                        am.mode=1+(am.targetMode-1)%4
                    else
                        am.mode=am.mode-am.floatAdjustTime*dt*16
                    end
                elseif am.floatModeError<0 then
                    am.floatAdjustTime=am.floatAdjustTime+dt
                    am.floatModeError=am.floatModeError+am.floatAdjustTime*dt*16
                    if am.floatModeError>=0 then
                        am.floatAdjustTime=0
                        am.floatModeError=0
                        am.mode=1+(am.targetMode-1)%4
                    else
                        am.mode=am.mode+am.floatAdjustTime*dt*16
                    end
                end
            end
        end
    end
end
function am.draw()
    setColor(1,1,1)
    printf(am.txt.title,font.OX_SB,0,-460,2000,'center',0,1,1,1000,font.height.OX_SB/3)
    setColor(1,1,1,.6)
    printf(am.txt.keyInfo,font.OX_SB,0,510,4000,'center',0,1/3,1/3,2000,font.height.OX_SB/3)
    --printf(am.txt.info,font.OX_SB,840,400,4000,'right',0,1/4,1/4,4000,5*font.height.OX_SB/6)

    local gm=round(am.mode)
    for i=round(am.mode)-1,round(am.mode)+1 do
        local k=1+(i-1)%#gameList
        local o=round(i)-am.mode
        setColor(1,1,1,1-.4*abs(o))
        draw(gamePic[gameList[k]],960*(o),0,0,.5-.2*abs(o),.5-.2*abs(o),960,540)
    end
    setColor(1,1,1,1-4*abs(gm-am.mode))
    printf(am.txt.name[gameList[1+(gm-1)%4]],font.OX_SB,0,-320,2000,'center',0,2/3,2/3,1000,font.height.OX_SB/3)
    printf(""..(1+(gm-1)%4).."/"..#gameList,font.OX,480,-300,1000,'left',0,1/3,1/3,0,font.height.OX/3)
    setColor(1,1,1,.5-2*abs(gm-am.mode))
    printf(am.txt.desc[gameList[1+(gm-1)%4]],font.OX_SB,0,295,4000,'center',0,1/4,1/4,2000,font.height.OX_SB/3)

    BUTTON.draw() SLIDER.draw()
end
function am.exit()
end
return am