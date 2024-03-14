local laser={}
local setColor,rect=gc.setColor,gc.rectangle
function laser.init(P,mino)
    scene.BG=require('BG/Symphonic Laser') scene.BG.init()

    mino.musInfo="Syun Nakano - Symphonic Laser"
    mus.add('music/Hurt Record/Symphonic Laser','whole','mp3',45,200*60/128)
    mus.start()
    mino.rule.allowPush={}
    mino.rule.allowSpin={T=true}
    P[1].pDropped=0
    --横向和纵向激光表，白色摧毁，蓝色反转，橙色随机
    laser.HLaserList,laser.SLaserList={destroy={},reverse={},mayhem={}},{destroy={1,2,3,4,5,6,7,8,9,10},reverse={},mayhem={}}
end
function laser.postCheckClear(player,mino)
    local h,s=laser.HLaserList,laser.SLaserList

    local his=player.history
    local piece=his.piece
    local laserTouch=false
    player.pDropped=player.pDropped+1
    for j=1,#s.destroy do
        local touch=false
        for i=1,#piece do
        if piece[i][1]+his.x==s.destroy[j] then
            for k=1,#player.field do
                player.field[k][s.destroy[j]]={}
                laserTouch=true touch=true
            end
            if touch then break end
        end
        end
    end
    for j=1,#s.reverse do
        local touch=false
        for i=1,#piece do
        if piece[i][1]+his.x==s.reverse[j] then
            for k=1,#player.field do
                print(next(player.field[k][s.reverse[j]]) and 'O' or ' ')
                player.field[k][s.reverse[j]]=next(player.field[k][s.reverse[j]]) and {} or {name='g1'}
                laserTouch=true touch=true
            end
            if touch then break end
        end
        end
    end
    for j=1,#s.mayhem do
        local touch=false
        for i=1,#piece do
        if piece[i][1]+his.x==s.mayhem[j] then
            for k=1,#player.field do
                player.field[k][s.mayhem[j]]=rand()<.5 and {name='g1'} or {}
                laserTouch=true touch=true
            end
            if touch then break end
        end
        end
    end

    if laserTouch or player.pDropped>=5 then
        player.pDropped=0
        --laser.SLaserList.destroy[1]=rand(player.w)
        --laser.SLaserList.reverse[1]=rand(player.w)
        --laser.SLaserList.rand   [1]=rand(player.w)
    end
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