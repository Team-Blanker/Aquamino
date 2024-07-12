local fLib=require('mino/fieldLib')

local laser={}
local setColor,rect,draw,clear=gc.setColor,gc.rectangle,gc.draw,gc.clear
local progressAct={
    --{几分以前使用事件，事件间间隔几拍，下一波激光的位置}
    --随机边列
    {30,16,function(player)
        return {{'s','destroy',player.laserList[1][3]==1 and player.w or 1},beat=16}
    end},
    --随机全部
    {60,16,function(player)
        local a=rand(player.w-1)
        return {{'s','destroy',player.laserList[1][3]==a and a+1 or a},beat=16}
    end},
    --随机中间
    {90,16,function(player)
        local a=player.laserList[1][3]>3 and player.laserList[1][3]<player.w-3 and rand(4,player.w-4) or rand(4,player.w-5)
        return {{'s','destroy',player.laserList[1][3]==a and a+1 or a},beat=16}
    end},
    --随机反转
    {120,8,function(player)
        local a=rand(player.w-1)
        return {{'s','reverse',player.laserList[1][3]==a and a+1 or a},beat=8}
    end},
    --随机两条相邻反转
    {140,8,function(player)
        local a=rand(player.w-1)
        return {{'s','reverse',a},{'s','reverse',a+1},beat=8}
    end},
    --TEC的squeeze
    {180,4,function(player)
        local list={}
        for i=1,4 do
            list[i]={'s','mayhem',i-min(max(abs(floor(player.beat%48/4)-6)-1,0),4)<=0 and i or player.w-4+i}
        end
        list.beat=4
        return list
    end},
    --场地最上方出现一条横向毁灭
    {210,8,function(player)
        return {{'h','destroy',#player.field},beat=8}
    end},
    --两条随机毁灭
    {220,8,function(player)
        return {{'s','destroy',rand(player.w)},{'s','destroy',rand(player.w)},beat=8}
    end},
    --“走马灯”
    {240,4,function (player)
        local list={}
        for i=1,3 do list[i]={'s','mayhem',(i+floor(player.beat%(player.w*4)/4))%player.w+1} end
        list.beat=4
        return list
    end},
    --反向走马灯
    {270,4,function (player)
        local list={}
        for i=1,3 do list[i]={'s','mayhem',(i-floor(player.beat%(player.w*4)/4))%player.w+1} end
        list.beat=4
        return list
    end},
    --限高
    {290,4,function (player)
        local list={}
        for i=2,4 do list[#list+1] ={'h','reverse',#player.field+i} end
        list.beat=4
        return list
    end},
    --全反转
    {1e99,2,function (player)
        local list={}
        for i=1,player.w do list[i]={'s','reverse',i} end
        list.beat=2
        return list
    end},
}
function laser.init(P,mino)
    scene.BG=require('BG/Symphonic Laser') scene.BG.init()

    mino.musInfo="Syun Nakano - Symphonic Laser"
    mus.add('music/Hurt Record/Symphonic Laser','whole','ogg',45,200*60/128)
    --mus.start()
    sfx.add({
        destroy='sfx/rule/laser/destroy.wav',mayhem='sfx/rule/laser/mayhem.wav',reverse='sfx/rule/laser/reverse.wav',
        forceGarbage='sfx/rule/laser/garbage.wav',
    })

    mino.rule.allowPush={}
    mino.rule.allowSpin={}
    P[1].pDropped=0
    P[1].point=0
    P[1].laserLv=1
    P[1].scoreTxt={}--[1]={x,y,v,g,color,size,TTL,Tmax}
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
                field[line][i]=next(field[line][i]) and {} or {name='g1'}
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

function laser.onPieceDrop(player,mino)
    local his=player.history
    local piece=his.piece
    local laserTouch=false
    local list,aList=player.laserList,player.animLaserList
    player.pDropped=player.pDropped+1
    for i=#list,1,-1 do
        for j=1,#piece do
            if list[i][1]=='h' then
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
    local point=min(floor((c-1)/2),3)+ceil(l/8)*l
    player.point=player.point+point
    table.insert(player.scoreTxt,{
        x=36*player.history.x-18-18*player.w,y=-36*player.history.y+18*player.h,
        v={0,-90},g=90,TTL=.4,tMax=.4,
        size=40,color={1,1,1,.8},score=point
    })
    for i=#progressAct,1,-1 do
        if player.point<progressAct[i][1] then
            break
        end
    end
    for i=1,#progressAct do
        if player.point<progressAct[i][1] then player.laserLv=i break end
    end
    if player.point>=300 then
        player.garbageTMax=max(3-(player.point-300)*.05,.1)
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
local mb={0,0,0,0,0}
function laser.update(player,dt,mino)
    if not player.event[1] then player.garbageTimer=player.garbageTimer-dt end
    local beat=(player.gameTimer+offset)*BPM/60
    if beat-1>=player.beat then
        player.beat=player.beat+1 player.eventBeat=player.eventBeat+1
        for i=1,5 do mb[i]=rand(0,1) end

        if player.eventBeat>=(player.laserList and player.laserList.beat or progressAct[player.laserLv][2]) then
            player.laserList=player.nextLaserList
            player.nextLaserList=progressAct[player.laserLv][3](player)
            player.eventBeat=player.eventBeat%progressAct[player.laserLv][2]
        end
        if player.garbageTimer<=0 then
            fLib.garbage(player,'g1',1,rand(player.w))
            fLib.garbage(player,'g1',1,rand(player.w))
            player.garbageTimer=player.garbageTMax
            sfx.play('forceGarbage')
        end
    end
end

function laser.always(player,dt)
    local aList=player.animLaserList
    for i=#aList,1,-1 do
        aList[i][4]=aList[i][4]-dt
        if aList[i][4]<0 then rem(aList,i) end
    end
    local txt=player.scoreTxt
    for i=#txt,1,-1 do
        txt[i].TTL=txt[i].TTL-dt
        if txt[i].TTL<=0 then table.remove(txt,i) else
            txt[i].x,txt[i].y=txt[i].x+txt[i].v[1]*dt,txt[i].y+txt[i].v[2]*dt
            txt[i].v[2]=txt[i].v[2]+txt[i].g*dt
        end
    end
end

function laser.onDie(player,mino)
    if player.point>=300 then mino.win(player) else mino.lose(player) end
end

function laser.BGUpdate(stacker,dt)
    if stacker.started and not stacker.paused or stacker.winState~=0 then scene.BG.time=mus.whole:tell() end
end
function laser.underFieldDraw(player)
    if player.point>=300 then gc.setColor(1,.95,.05) else gc.setColor(1,1,1) end
    gc.printf(""..player.point,font.JB_B,-player.w*18-110,-36,2048,'center',0,.5,.5,1024,84)
    gc.printf(300,font.JB_B,-player.w*18-110,36,2048,'center',0,.5,.5,1024,84)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)

    if player.garbageTimer<=0 then setColor(1,0,0) else setColor(1,1,1) end
    gc.setLineWidth(40)
    gc.arc('line','open',0,0,450,-math.pi/2,(min(1-player.garbageTimer/player.garbageTMax,1)-.25)*2*math.pi,72)
end
function laser.underStackDraw(player)
    setColor(1,1,1,.05)
    local p=player.eventBeat/((player.laserList and player.laserList.beat or progressAct[player.laserLv][2])-1)
    rect('fill',-18*player.w,(18-36*p)*player.h,36*player.w,36*p*player.h)
end

local X,O=gc.newCanvas(36,36),gc.newCanvas(36,36)
gc.setLineWidth(4.5)
gc.setCanvas(X) clear(1,1,1,0) setColor(1,1,1)
gc.line(3,3,33,33) gc.line(3,33,33,3)
gc.setLineWidth(4)
gc.setCanvas(O)
clear(1,1,1,0)
gc.rectangle('line',3,3,30,30)
gc.setCanvas()

local W,H,parg
function laser.overFieldDraw(player,mino)

    local list,nList,aList=player.laserList,player.nextLaserList,player.animLaserList
    W,H=36*player.w,36*player.h

    gc.translate(-18*player.w,18*player.h)--绘制原点移至场地左下角
    for i=1,#list do
        local alpha=.48+(scene.time%.2<.1 and .24 or 0)
        if list[i][1]=='h' then
            if list[i][2]=='destroy' then
            setColor(1,1,1,alpha/3)
            rect('fill',0,-36*list[i][3]+6,W,24)
            setColor(1,1,1,alpha)
            rect('fill',0,-36*list[i][3]+9,W,18)

            elseif list[i][2]=='reverse' then
            setColor(0,1,1,alpha/3)
            rect('fill',0,-36*list[i][3]+6,W,24)
            setColor(0,1,1,alpha)
            rect('fill',0,-36*list[i][3]+9,W,18)
            local l=player.field[list[i][3]]
            if l then
                for j=1,player.w do
                    if next(l[j]) then setColor(1,1,1)
                        draw(X,36*j-36,-36*list[i][3])
                    else setColor(.2,1,1,.5)
                        draw(O,36*j-36,-36*list[i][3])
                    end
                end
            else
                for j=1,player.w do
                    draw(O,36*j-36,-36*list[i][3])
                end
            end

            else
            setColor(1,.8,0,alpha)
            rect('fill',0,-36*list[i][3]+9,W,18)
            setColor(1,.8,0,.5)
            for j=1,player.w do
                if mb[j%5+1]==1 then
                    draw(O,36*j-36,-36*list[i][3])
                end
            end
            end
        else
            if list[i][2]=='destroy' then
            setColor(1,1,1,alpha/3)
            rect('fill',36*list[i][3]-30,-H,24,H)
            setColor(1,1,1,alpha)
            rect('fill',36*list[i][3]-27,-H,18,H)

            elseif list[i][2]=='reverse' then
            setColor(.2,1,1,alpha/3)
            rect('fill',36*list[i][3]-30,-H,24,H)
            setColor(.2,1,1,alpha)
            rect('fill',36*list[i][3]-27,-H,18,H)
            setColor(.2,1,1,.5)
            for j=1,#player.field do
                if next(player.field[j][list[i][3]]) then setColor(1,1,1)
                    draw(X,36*list[i][3]-36,-36*j)
                else setColor(.2,1,1,.5)
                    draw(O,36*list[i][3]-36,-36*j)
                end
            end

            else
            setColor(1,.8,0,alpha/3)
            rect('fill',36*list[i][3]-30,-H,24,H)
            setColor(1,.8,0,alpha)
            rect('fill',36*list[i][3]-27,-H,18,H)
            setColor(1,.8,0,.5)
            for j=1,#player.field do
                if mb[j%5+1]==1 then
                    draw(O,36*list[i][3]-36,-36*j)
                end
            end
            end
        end
    end

    parg=.15+player.eventBeat%4/3*.1
    for i=1,#nList do
        if nList[i][1]=='h' then
            if nList[i][2]=='destroy' then setColor(1,1,1,parg)
            elseif nList[i][2]=='reverse' then setColor(0,1,1,parg)
            else setColor(1,.8,0,parg) end
            rect('fill',0,-36*nList[i][3]+9,W,18)
        else
            if nList[i][2]=='destroy' then setColor(1,1,1,parg)
            elseif nList[i][2]=='reverse' then setColor(0,1,1,parg)
            else setColor(1,.8,0,parg) end
            rect('fill',36*nList[i][3]-27,-H,18,H)
        end
    end

    for i=1,#aList do
        local animArg=aList[i][4]/animTMax
        if aList[i][1]=='h' then
            if aList[i][2]=='destroy' then setColor(1,1,1)
            elseif aList[i][2]=='reverse' then setColor(0,1,1)
            else setColor(1,.8,0) end
            rect('fill',0,-36*aList[i][3]+18-18*animArg,W,36*animArg)
        else
            if aList[i][2]=='destroy' then setColor(1,1,1)
            elseif aList[i][2]=='reverse' then setColor(0,1,1)
            else setColor(1,.8,0) end
            rect('fill',36*aList[i][3]-18-18*animArg,-H,36*animArg,H)
        end
    end
    gc.translate(18*player.w,-18*player.h)
    local txt=player.scoreTxt
    for i=1,#txt do
        local clr=txt[i].color
        gc.setColor(clr[1],clr[2],clr[3],clr[4]*txt[i].TTL/txt[i].tMax)
        gc.printf(txt[i].score,font.JB_B,txt[i].x,txt[i].y,5000,'center',0,txt[i].size/128,txt[i].size/128,2500,84)
    end
end

function laser.scoreSave(P,mino)
    local pb=file.read('player/best score')
    local ispb=pb.laser and (P[1].point==pb.laser.point and P[1].gameTimer<pb.laser.time or P[1].point>pb.laser.point)
    if not pb.laser or ispb then
    pb.laser={point=P[1].point,time=P[1].gameTimer,date=os.date("%Y/%m/%d  %H:%M:%S")}
    file.save('player/best score',pb)
    end
end
return laser