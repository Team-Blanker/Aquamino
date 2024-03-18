local laser={}
local setColor,rect=gc.setColor,gc.rectangle
function laser.init(P,mino)
    scene.BG=require('BG/Symphonic Laser') scene.BG.init()

    mino.musInfo="Syun Nakano - Symphonic Laser"
    mus.add('music/Hurt Record/Symphonic Laser','whole','mp3',45,200*60/128)
    mus.start()
    sfx.add({
        lvup='sfx/rule/laser/level up.ogg',
        destroy='sfx/rule/laser/destroy.wav',mayhem='sfx/rule/laser/mayhem.wav',reverse='sfx/rule/laser/reverse.wav',
    })

    mino.rule.allowPush={}
    mino.rule.allowSpin={}
    P[1].pDropped=0
    P[1].point=0
    P[1].laserLv=1
    --P[1].posy=600
    --激光表，destroy摧毁，reverse反转，random随机；h水平(horizontal)，s竖直(straight)
    P[1].laserList={} P[1].nextLaserList={}
    --e.g. {'h','destroy',3} 摧毁激光，水平，作用于第三行

    P[1].nextLaserList={{'s','destroy',rand(P[1].w)}}
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
function laser.postCheckClear(player,mino)
    local his=player.history
    local piece=his.piece
    local laserTouch=false
    local list=player.laserList
    player.pDropped=player.pDropped+1
    for i=#list,1,-1 do
        for j=1,#piece do
            if list[i]=='h' then
                if piece[j][2]+his.y==list[i][3] then laserAct.h[list[i][2]](player.field,list[i][3])
                laserTouch=true sfx.play(list[i][2]) rem(list,i)
                break end
            else
                if piece[j][1]+his.x==list[i][3] then laserAct.s[list[i][2]](player.field,list[i][3])
                laserTouch=true sfx.play(list[i][2]) rem(list,i)
                break end
            end
        end
    end
    if laserTouch then player.pDropped=2 end
    if player.pDropped>=5 then
    player.laserList=player.nextLaserList
    player.nextLaserList={{'s','reverse',rand(player.w)}}
    player.pDropped=0
    end
end
function laser.onLineClear(player,mino)
    local l,c=player.history.line,player.history.combo
    player.point=player.point+l*(l+1)/2+c-1
    if player.point>=player.laserLv*50 then
        if player.laserLv==10 then mino.win(player) return end
        player.laserLv=min(player.laserLv+1,10) sfx.play('lvup')
    end
end

function laser.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.point,font.Consolas_B,-player.w*18-110,-32,2048,'center',0,.5,.5,1024,56)
    gc.printf(""..player.laserLv*50,font.Consolas_B,-player.w*18-110,32,2048,'center',0,.5,.5,1024,56)
    gc.printf("Laser Lv.\n"..player.laserLv,font.Consolas_B,-player.w*18-28,256,2048,'right',0,0.25,0.25,2048,56)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end
function laser.overFieldDraw(player,mino)
    local list,nList=player.laserList,player.nextLaserList
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

    for i=1,#nList do
        if nList[i][1]=='h' then
            if nList[i][2]=='destroy' then
            setColor(1,1,1,.25)
            rect('fill',-18*player.w,-36*nList[i][3]+18*player.w+9,36*player.w,18)
            elseif nList[i][2]=='reverse' then
            setColor(0,1,1,.25)
            rect('fill',-18*player.w,-36*nList[i][3]+18*player.w+9,36*player.w,18)
            else
            setColor(1,.8,0,.25)
            rect('fill',-18*player.w,-36*nList[i][3]+18*player.w+9,36*player.w,18)
            end
        else
            if nList[i][2]=='destroy' then
            setColor(1,1,1,.25)
            rect('fill',36*nList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            elseif nList[i][2]=='reverse' then
            setColor(0,1,1,.25)
            rect('fill',36*nList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            else
            setColor(1,.8,0,.25)
            rect('fill',36*nList[i][3]-18*player.w-27,-18*player.h,18,36*player.h)
            end
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