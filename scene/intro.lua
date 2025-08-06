local BUTTON=scene.button

local banned={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12', 'f17','f18',
'audiomute','audioplay','volumeup','volumedown',
'numlock','capslock','scrolllock',
'printscreen'
}
local intro={}
local fl=gc.newCanvas(5,5)
do
    gc.setColor(1,1,1)
    gc.setCanvas(fl)
    for i=.5,4.5 do gc.points(i,.5) gc.points(i,4.5) end
    for i=.5,4.5 do gc.points(.5,i) gc.points(4.5,i) end
    gc.setCanvas()
end

local introCount=0
local birthday
local mzk,gg,pp
function intro.init()
    introCount=introCount+1

    birthday=win.date.month==8 and win.date.day==14--Aquamino的生日
    mzk=win.date.month==3 and win.date.day==22--水月生日
    gg=win.date.month==1 and win.date.day==7--澄闪生日
    pp=win.date.month==6 and win.date.day==12--佩佩生日

    if birthday then
    scene.BG=require('BG/celebration') scene.BG.init()
    else
    scene.BG=require('BG/introBG') scene.BG.init()
    end

    if not mus.checkTag('menu') then
        if birthday then
        mus.add('music/Hurt Record/Winter Story','whole','ogg',8.579,96)
        mus.start()
        else
        mus.add('music/Hurt Record/Nine Five','parts','ogg')
        mus.start()
        end
        mus.setTag({'menu'})
    end
    intro.tip=user.lang.tip
    intro.tipOrder=rand(#intro.tip)
end

local tchar='territory' local cnum=1
function intro.keyP(k)
    if k=='escape' then love.event.quit()
    elseif not myTable.include(banned,k) then
        if win.stat.launch==1 and introCount==1 then
            scene.switch({
            dest='game conf',destScene=require('scene/game conf/conf_main'),swapT=.6,outT=.2,
            anim=function() anim.cover(.2,.4,.2,0,0,0) end
            })
            function scene.cur.send()
                scene.cur.exitScene='scene/intro'
            end
        elseif k==tchar:sub(cnum,cnum) then cnum=cnum+1
            if cnum==tchar:len()+1 then
                cnum=1
                scene.switch({
                    dest='territory',destScene=require('minigame/territory/territory'),swapT=.6,outT=.2,
                    anim=function() anim.cover(.2,.4,.2,0,0,0) end
                })
            end
        else cnum=1
            scene.switch({
                dest='menu',swapT=.75,outT=.6,
                anim=function() anim.enterMenu(.6,.15,.6) end
            })
        end
    end
end
function intro.mouseP(x,y,button,istouch)
    intro.keyP('mouse')
end
function intro.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end

local logo=gc.newImage('pic/assets/title.png')
local logo_mzk=gc.newImage('pic/assets/title_Mizuki.png')
local logo_gg=gc.newImage('pic/assets/title_Goldenglow.png')

local lw,lh=logo:getPixelDimensions()

function intro.draw()
    gc.setColor(1,1,1)
    gc.draw(mzk and logo_mzk or gg and logo_gg or logo,0,-200,0,1600/lw,1600/lw,lw/2,lh/2)

    local r,g,b=1,1,1
    if birthday then r,g,b=COLOR.hsv(scene.time,.2,1) end
    gc.setColor(r,g,b)
    gc.printf(user.lang.intro.start,font.Bender,0,360,4000,'center',0,.625,.625,2000,84)

    --gc.printf(intro.tip[intro.tipOrder],font.Bender,0,450,114514,'center',0,user.lang.tipScale,user.lang.tipScale,57257,84)

    gc.setColor(r,g,b,.3)
    gc.printf(win.versionTxt,font.Bender,950,540,10000,'right',0,.3,.3,10000,160)
end
return intro