local BUTTON=scene.button

local banned={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12', 'f17','f18',
'audiomute','audioplay','volumeup','volumedown',
'numlock','capslock','scrolllock',
'printscreen'
}
local intro={}
local unlocked={true,true,false,false}
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

function intro.init()
    introCount=introCount+1
    local it=user.lang.intro

    birthday=win.date.month==8 and win.date.day==14--Aquamino的生日！也是海兰的生日！
    if birthday then
    scene.BG=require('BG/celebration') scene.BG.init()
    else
    scene.BG=require('BG/blank')
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
    elseif not mytable.include(banned,k) then
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
                dest='menu',swapT=.9,outT=.6,
                anim=function() anim.enterMenu(.3,.6,.6) end
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

local logo=gc.newImage('assets/pic/title.png')
local hat=gc.newImage('assets/pic/mizuki hat.png')

local v
function intro.draw()
    if win.date.month==3 and win.date.day==22 then--水月的生日
        gc.setColor(0,.03,.12)
        gc.rectangle('fill',-1000,-600,2000,1200)
        gc.setColor(1,1,1,.4)
        gc.draw(hat,0,0,0,1.25,1.25,500,500)
    end

    local w,h=logo:getPixelDimensions()
    gc.setColor(1,1,1)
    gc.draw(logo,0,-200+12*sin(scene.time/5%2*math.pi),0,1600/w,1600/w,w/2,h/2)

    local r,g,b=1,1,1
    if birthday then r,g,b=COLOR.hsv(scene.time,.2,1) end
    gc.setColor(r,g,b)
    gc.printf(user.lang.intro.start,font.Bender,0,300,4000,'center',0,.625,.625,2000,84)

    gc.printf(intro.tip[intro.tipOrder],font.Bender,0,450,114514,'center',0,user.lang.tipScale,user.lang.tipScale,57257,84)

    gc.setColor(r,g,b,.3)
    gc.printf(win.stat.version,font.Bender,950,540,10000,'right',0,.3,.3,10000,160)
end
return intro