local BUTTON=scene.button

local menu={modeKey=1,lvl=1}
local flashT,enterT=0,0
menu.modelist={'practice','challenge','mystery','phun'}
menu.modename={"练习","挑战","秘境","理堂"}
--menu.modeBG={'pond','galaxy','wave','radio'}
menu.modeBG={'pond','pond','wave','radio'}
menu.unlocked={}
local modelist=menu.modelist
local modename=menu.modename
local discription={}

function menu.init()
    local s=fs.newFile('player/unlocked')
    --menu.modeKey=1
    menu.lvl=1
    menu.changeBG(menu.modeKey)

    --[[if fs.getInfo('player/unlocked') then menu.unlocked=json.decode(fs.newFile('player/unlocked'):read())
    else menu.unlocked={classic={'40 lines'},challenge={}} end]]
    menu.unlocked={classic={},challenge={}}

    BUTTON.create('setting',{
        x=-800,y=-400,type='rect',w=150,h=150,
        draw=function(t)
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-75,-75,150,150,12)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(5)
            gc.rectangle('line',-75,-75,150,150,12)
            gc.setColor(1,1,1)
            gc.setLineWidth(6)
            gc.setColor(.8,1,.9,.75)
            gc.circle('line',0,0,50,6) gc.circle('line',0,0,22.5)
            --gc.polygon('line')
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
        end
    },.2)
    menu.changeBG(menu.modeKey)
end
function menu.changeBG(key)
    if menu.unlocked[menu.modelist[key]] then
        scene.BG=require('BG/'..menu.modeBG[key]) 
        if menu.modeBG[key]=='wave' or menu.modeBG[key]=='galaxy' then scene.BG.init() end
    else scene.BG=require('BG/blank') end
end
function menu.keyP(k)
    local len=#modelist
    if k=='return' and menu.unlocked[modelist[menu.modeKey]] then menu.lvl=min(menu.lvl+1,2)
    elseif k=='escape' then menu.lvl=max(menu.lvl-1,0) end
    if menu.lvl==0 then
        scene.dest='intro' scene.swapT=.7 scene.outT=.3
        scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end
    elseif menu.lvl==1 then
        if k=='left' or k=='right' or k=='r' or k=='kp4' or k=='kp6' then flashT=.3 end
        if k=='left' or k=='kp4' then menu.modeKey=(menu.modeKey-2)%len+1
        elseif k=='right' or k=='kp6' then menu.modeKey=menu.modeKey%len+1
        elseif k=='r' then menu.modeKey=rand(1,#modelist)
        end
        menu.changeBG(menu.modeKey)
    elseif menu.lvl==2 then
        scene.dest='game' scene.destScene=require'mino/game'
        scene.swapT=.7 scene.outT=.3
        scene.anim=function() anim.cover(.3,.4,.3,0,0,0) end
        scene.sendArg=menu.modeKey
    end
end
function menu.mouseP(x,y,button,istouch)
    if not BUTTON.click(x,y,button,istouch) then local len,l=#modelist,1920/#modelist
        if button==1 then
            if y>=500 then
            for i=1,len do
                if x>-960+l*(i-1) and x<-960+l*i then
                    menu.modeKey=i flashT=.3 break
                end
            end
            elseif x<-640 then menu.modeKey=(menu.modeKey-2)%len+1 flashT=.3
            elseif x> 640 then menu.modeKey=menu.modeKey%len+1 flashT=.3 end
            menu.changeBG(menu.modeKey)
        end
    end
end
function menu.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if flashT>0 then flashT=flashT-dt end
end
function menu.draw()
    local l=1920/#modelist
    if menu.unlocked[menu.modelist[menu.modeKey]] then
        gc.printf(modename[menu.modeKey],Exo_2,-750,-540,1000,'center',0,1.5,1.5)
    else gc.printf("???",Exo_2,-750,-540,1000,'center',0,1.5,1.5) end

    gc.setColor(1,1,1,.5-.15*cos(scene.time%8*math.pi/4))
    if menu.unlocked[menu.modelist[menu.modeKey]] then
        gc.printf("按Enter键开始游戏\n按R键随机跳转",
        Exo_2,0,0,2000,'center',0,.6,.6,1000,512/3)
    else
        gc.printf("未知还潜伏在阴影之中。",
        Exo_2,0,0,2000,'center',0,.6,.6,1000,84)
    end

    gc.setLineWidth(3)
    for i=1,#modelist do
        if i==menu.modeKey then
            gc.setColor(1,1,1,.4)
            gc.rectangle('fill',-960+l*(menu.modeKey-1),500,l,40)
        else
            gc.setColor(1,1,1,.1+.03*(i%2))
            gc.rectangle('fill',-960+l*(i-1),500,l,40)
        end
        if menu.unlocked[menu.modelist[i]] then
            gc.printf(menu.modename[i],Consolas,-960+l*(i-.5),480,2000,'center',0,.3,.3,1000,56)
        else gc.printf("???",Consolas,-960+l*(i-.5),480,2000,'center',0,.3,.3,1000,56) end
    end
    gc.setColor(1,1,1,.5)
    gc.setLineWidth(20)
    gc.line(-840,-100,-860,0,-840,100)
    gc.line( 840,-100, 860,0, 840,100)
    do
        local s=scene.time%4/4
        if.08-s>0 then
            gc.setColor(1,1,1,10*(.08-s))
            gc.line(-840-800*s,-100,-860-800*s,0,-840-800*s,100)
            gc.line( 840+800*s,-100, 860+800*s,0, 840+800*s,100)
        end
    end
    if flashT>0 then gc.setColor(1,1,1,flashT/.3*.15)
        gc.rectangle('fill',-1000,-600,2000,1200)
    end
    BUTTON.draw()
end
function menu.exit()
    local s=fs.newFile('player/unlocked')
    s:open('w')
    s:write(json.encode(menu.unlocked))
    s:close()
end
function menu.send(destScene,arg)
    if scene.dest=='game' then
    local mode={'40 lines','ice storm'}
    destScene.mode=mode[arg]
    end
end
return menu