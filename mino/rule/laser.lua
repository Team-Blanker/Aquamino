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
    --横向和纵向激光表，白色摧毁，蓝色反转，橙色随机
    laser.HLaserList,laser.SLaserList={destroy={},reverse={},mayhem={}},{destroy={},reverse={},mayhem={}}
end
function laser.postCheckClear(player,mino)
    local h,s=laser.HLaserList,laser.SLaserList

    local his=player.history
    local piece=his.piece
    local laserTouch=false
    player.pDropped=player.pDropped+1
    for j=#s.destroy,1,-1 do
        for i=1,#piece do
        if piece[i][1]+his.x==s.destroy[j] then
            for k=1,#player.field do
                player.field[k][s.destroy[j]]={}
                laserTouch=true
            end
            rem(s.destroy,j)
            sfx.play('destroy')
            break
        end
        end
    end
    for j=#s.reverse,1,-1 do
        for i=1,#piece do
        if piece[i][1]+his.x==s.reverse[j] then
            for k=1,#player.field do
                print(next(player.field[k][s.reverse[j]]) and 'O' or ' ')
                player.field[k][s.reverse[j]]=next(player.field[k][s.reverse[j]]) and {} or {name='g1'}
                laserTouch=true
            end
            rem(s.reverse,j)
            sfx.play('reverse')
            break
        end
        end
    end
    for j=#s.mayhem,1,-1 do
        for i=1,#piece do
        if piece[i][1]+his.x==s.mayhem[j] then
            for k=1,#player.field do
                player.field[k][s.mayhem[j]]=rand()<.5 and {name='g1'} or {}
                laserTouch=true
            end
            rem(s.mayhem,j)
            sfx.play('mayhem')
            break
        end
        end
    end

    if laserTouch then player.pDropped=2 end
    if --[[laserTouch or]] player.pDropped>=5 then
        player.pDropped=0
        --laser.SLaserList.destroy[1]=rand(player.w)
        laser.SLaserList.reverse[1]=rand(player.w)
        --laser.SLaserList.mayhem   [1]=rand(player.w)
    end
end
function laser.onLineClear(player,mino)
    local l,c=player.history.line,player.history.combo
    player.point=player.point+l*(l+1)/2+c-1
    if player.point>=player.laserLv*20 then
        if player.laserLv==10 then mino.win(player) return end
        player.laserLv=min(player.laserLv+1,10) sfx.play('lvup')
    end
end

function laser.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.point,font.Consolas_B,-player.w*18-110,-32,2048,'center',0,.5,.5,1024,56)
    gc.printf(""..player.laserLv*20,font.Consolas_B,-player.w*18-110,32,2048,'center',0,.5,.5,1024,56)
    gc.printf("Laser Lv.\n"..player.laserLv,font.Consolas_B,-player.w*18-28,256,2048,'right',0,0.25,0.25,2048,56)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end
function laser.overFieldDraw(player,mino)
    local h,s=laser.HLaserList,laser.SLaserList
    for i=1,#s.destroy do
        gc.setColor(1,1,1,.4+(scene.time%.2<.1 and .2 or 0))
        rect('fill',36*s.destroy[i]-18*player.w-27,-18*player.h,18,36*player.h)
    end
    for i=1,#s.reverse do
        gc.setColor(0,1,1,.4+(scene.time%.2<.1 and .2 or 0))
        rect('fill',36*s.reverse[i]-18*player.w-27,-18*player.h,18,36*player.h)
    end
    for i=1,#s.mayhem do
        gc.setColor(1,.8,0,.4+(scene.time%.2<.1 and .2 or 0))
        rect('fill',36*s.mayhem[i]-18*player.w-27,-18*player.h,18,36*player.h)
    end
end
return laser