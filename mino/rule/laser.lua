local fLib=require('mino/fieldLib')

local laser={}
local setColor,rect=gc.setColor,gc.rectangle
local progressAct={
    --{几分以前使用事件，事件间间隔几拍，下一波激光的位置，到达分数时事件}
    --随机边列
    {50,16,function(player)
        return {{'s','destroy',player.laserList[1][3]==1 and player.w or 1}}
    end},
    --随机全部
    {100,16,function (player)
        local a=rand(player.w-1)
        return {{'s','destroy',player.laserList[1][3]==a and a+1 or a}}
    end},
    --随机中间
    {150,16,function (player)
        local a=player.laserList[1][3]>3 and player.laserList[1][3]<player.w-3 and rand(4,player.w-4) or rand(4,player.w-5)
        return {{'s','destroy',player.laserList[1][3]==a and a+1 or a}}
    end},
    --随机两条，一条毁灭，一条反转
    {175,16,function (player)
        return {{'s','destroy',rand(player.w)},{'s','reverse',rand(player.w)}}
    end},
    --以上全部纵向
    {200},--随机一条纵向毁灭，每20块在场地最上方出现一条横向毁灭
    {225},--TEC的squeeze
    {250},--squeeze加强
    {300},--“强制4w”
    {350},--随机两条，一条毁灭，一条反转
    {375},--限高18行，每1分降低1行，8行为止
    {390},--限高4行
    {400},--全反转
}
function laser.init(P,mino)
    scene.BG=require('BG/Symphonic Laser') scene.BG.init()

    mino.musInfo="Syun Nakano - Symphonic Laser"
    mus.add('music/Hurt Record/Symphonic Laser','whole','mp3',45,200*60/128)
    --mus.start()
    sfx.add({
        lvup='sfx/rule/laser/level up.ogg',
        destroy='sfx/rule/laser/destroy.wav',mayhem='sfx/rule/laser/mayhem.wav',reverse='sfx/rule/laser/reverse.wav',
        forceGarbage='sfx/rule/laser/garbage.wav',
    })

    mino.rule.allowPush={}
    mino.rule.allowSpin={}
    P[1].pDropped=0
    P[1].point=0
    P[1].laserLv=1
    --P[1].posy=600
    --激光表，destroy摧毁，reverse反转，random随机；h水平(horizontal)，s竖直(straight)
    P[1].laserArg={}
    P[1].laserList={} P[1].nextLaserList={} P[1].animLaserList={}
    --e.g. {'h','destroy',3} 摧毁激光，水平，作用于第三行

    P[1].nextLaserList={{'s','destroy',rand(2)==1 and 1 or P[1].w}}
    P[1].eventBeat=0
    P[1].beat=0
    P[1].garbageTimer,P[1].garbageTMax=3,3
end

local laserAct={
    h={
        destroy=function(field,line)
            for i=1,#field[line] do
                field[line][i]={}
            end
        end,
        reverse=function(field,line)
            for i=1,#field[line] do
                field[line][i]=next(field[i][col]) and {} or {name='g1'}
            end
        end,
        mayhem =function(field,line)
            for i=1,#field[line] do
                field[line][i]=rand()<.5 and {} or {name='g1'}
            end
        end,
    },
    s={
        destroy=function(field,col)
            for i=1,#field do
                field[i][col]={}
            end
        end,
        reverse=function(field,col)
            for i=1,#field do
                field[i][col]=next(field[i][col]) and {} or {name='g1'}
            end
        end,
        mayhem =function(field,col)
            for i=1,#field do
                field[i][col]=rand()<.5 and {} or {name='g1'}
            end
        end,
    }
}

local animTMax=.1

function laser.postCheckClear(player,mino)
    local his=player.history
    local piece=his.piece
    local laserTouch=false
    local list,aList=player.laserList,player.animLaserList
    player.pDropped=player.pDropped+1
    for i=#list,1,-1 do
        for j=1,#piece do
            if list[i]=='h' then
                if piece[j][2]+his.y==list[i][3] then laserAct.h[list[i][2]](player.field,list[i][3])
                laserTouch=true sfx.play(list[i][2]) ins(aList,rem(list,i)) aList[#aList][4]=animTMax
                break end
            else
                if piece[j][1]+his.x==list[i][3] then laserAct.s[list[i][2]](player.field,list[i][3])
                laserTouch=true sfx.play(list[i][2]) ins(aList,rem(list,i)) aList[#aList][4]=animTMax
                break end
            end
        end
    end

    player.garbageTimer=player.garbageTMax
end
function laser.onLineClear(player,mino)
    local l,c=player.history.line,player.history.combo
    --player.point=player.point+l*(l+1)/2+c-1
    player.point=player.point+c+l-1
    if player.point>=400 then mino.win(player) return end

    for i=#progressAct,1,-1 do
        if player.point<progressAct[i][1] then
            break
        end
    end
    for i=1,#progressAct do
        if player.point<progressAct[i][1] then player.laserLv=i break end
    end
end

function laser.start()
    mus.start()
end
function laser.pause(stacker,paused)
    if stacker.started and stacker.winState==0 then
    if paused then mus.pause() else mus.start() end
    end
end
local BPM,offset=128,0
function laser.update(player,dt,mino)
    player.garbageTimer=player.garbageTimer-dt
    local beat=(player.gameTimer+offset)*BPM/60
    if beat-1>=player.beat then
        player.beat=player.beat+1 player.eventBeat=player.eventBeat+1
        if player.eventBeat>=progressAct[player.laserLv][2] then
            player.laserList=player.nextLaserList
            player.nextLaserList=progressAct[player.laserLv][3](player)
            player.eventBeat=0
        end
        if player.garbageTimer<=0 then
            fLib.garbage(player,'g1',1,rand(player.w))
            fLib.garbage(player,'g1',1,rand(player.w))
            player.garbageTimer=player.garbageTMax
            sfx.play('forceGarbage')
        end
    end

    local aList=player.animLaserList
    for i=#aList,1,-1 do
        aList[i][4]=aList[i][4]-dt
        if aList[i][4]<0 then rem(aList,i) end
    end
end

function laser.BGUpdate(stacker,dt)
    if stacker.started and not stacker.paused or stacker.winState~=0 then scene.BG.time=mus.whole:tell() end
end
function laser.underFieldDraw(player)
    if player.gameTimer==0 then
    gc.setColor(0,0,0) gc.rectangle('fill',-960,-540,1920,1080)
    end
    gc.setColor(1,1,1)
    gc.printf(""..player.point,font.Consolas_B,-player.w*18-110,-32,2048,'center',0,.5,.5,1024,56)
    gc.printf(400,font.Consolas_B,-player.w*18-110,32,2048,'center',0,.5,.5,1024,56)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)

    if player.garbageTimer<=0 then setColor(1,0,0) else setColor(1,1,1) end
    gc.setLineWidth(40)
    gc.arc('line','open',0,0,450,-math.pi/2,(min(1-player.garbageTimer/player.garbageTMax,1)-.25)*2*math.pi,72)
end
function laser.overFieldDraw(player,mino)
    local list,nList,aList=player.laserList,player.nextLaserList,player.animLaserList
    for i=1,#list do
        if list[i][1]=='h' then
            if list[i][2]=='destroy' then
            setColor(1,1,1,.4+(scene.time%.2<.1 and .2 or 0))
            rect('fill',-18*player.w,-36*list[i][3]+18*player.w+9,36*player.w,18)
            elseif list[i][2]=='reverse' then
            setColor(0,1,1,.4+(scene.time%.2<.1 and .2 or 0))
            rect('fill',-18*player.w,-36*list[i][3]+18*player.w+9,36*player.w,18)
            else
            setColor(1,.8,0,.4+(scene.time%.2<.1 and .2 or 0))
            rect('fill',-18*player.w,-36*list[i][3]+18*player.w+9,36*player.w,18)
            end
        else
            if list[i][2]=='destroy' then
            setColor(1,1,1,.4+(scene.time%.2<.1 and .2 or 0))
            rect('fill',36*list[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            elseif list[i][2]=='reverse' then
            setColor(0,1,1,.4+(scene.time%.2<.1 and .2 or 0))
            rect('fill',36*list[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            else
            setColor(1,.8,0,.4+(scene.time%.2<.1 and .2 or 0))
            rect('fill',36*list[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            end
        end
    end

    local parg=.5+.5*player.eventBeat/progressAct[player.laserLv][2]
    for i=1,#nList do
        if nList[i][1]=='h' then
            if nList[i][2]=='destroy' then
            setColor(1,1,1,.25*parg)
            rect('fill',-18*player.w,-36*nList[i][3]+18*player.w+9,36*player.w,18)
            elseif nList[i][2]=='reverse' then
            setColor(0,1,1,.25*parg)
            rect('fill',-18*player.w,-36*nList[i][3]+18*player.w+9,36*player.w,18)
            else
            setColor(1,.8,0,.25*parg)
            rect('fill',-18*player.w,-36*nList[i][3]+18*player.w+9,36*player.w,18)
            end
        else
            if nList[i][2]=='destroy' then
            setColor(1,1,1,.25*parg)
            rect('fill',36*nList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            elseif nList[i][2]=='reverse' then
            setColor(0,1,1,.25*parg)
            rect('fill',36*nList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            else
            setColor(1,.8,0,.25*parg)
            rect('fill',36*nList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            end
        end
    end

    for i=1,#aList do
        setColor(1,1,1)
        if aList[i][1]=='h' then
            rect('fill',-18*player.w,-36*aList[i][3]+18*player.w+18,36*player.w,36)
        else
            rect('fill',36*aList[i][3]-18*player.w-18-18*aList[i][4]/animTMax,-18*player.h,36*aList[i][4]/animTMax,36*player.h)
        end
    end
    --[[for i=1,#aList do
        if aList[i][1]=='h' then
            if aList[i][2]=='destroy' then
            setColor(1,1,1)
            rect('fill',-18*player.w,-36*aList[i][3]+18*player.w+9,36*player.w,18)
            elseif aList[i][2]=='reverse' then
            setColor(0,1,1)
            rect('fill',-18*player.w,-36*aList[i][3]+18*player.w+9,36*player.w,18)
            else
            setColor(1,.8,0)
            rect('fill',-18*player.w,-36*aList[i][3]+18*player.w+9,36*player.w,18)
            end
        else
            if aList[i][2]=='destroy' then
            setColor(1,1,1)
            rect('fill',36*aList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            elseif aList[i][2]=='reverse' then
            setColor(0,1,1)
            rect('fill',36*aList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            else
            setColor(1,.8,0)
            rect('fill',36*aList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            end
        end
    end]]
end
return laser