local marathon={}
function marathon.init(P,mino)

    mino.rule.allowPush={}
    mino.rule.allowSpin={T=true}
    scene.BG=require('BG/chessboard')
    scene.BG.speed=125/120 scene.BG.delay=.241
    scene.BG.baseColor={.4,.4,.4}
    local r,g,b=COLOR.hsv(rand()*6,.8,.8)
    marathon.finalColor={r,g,b}
    mino.musInfo="つかスタジオ - リズムよく心地よく汗を流す時のテーマ"
    mus.add('music/Hurt Record/sweat','whole','mp3',20.879,336*60/125)
    mus.start()
    sfx.add({
        lvup='sfx/rule/marathon/level up.ogg'
    })
    mino.stacker.ctrl={
       ASD=.15,ASP=.03,SD_ASD=0,SD_ASP=.03
    }
    P[1].LDelay=.5
    for k,v in pairs(P) do
        v.CDelay=.25
        v.EDelay=.1

        v.speedLv=1
        v.FDelay=2^(-(v.speedLv-1)/14*8)
        v.totalLine=0
    end
end
function marathon.onLineClear(player,mino)
    local his=player.history
    player.totalLine=player.totalLine+his.line
    while player.totalLine>=player.speedLv*10 do
        if player.totalLine>=150 then mino.win(player) break end
        player.speedLv=player.speedLv+1
        player.FDelay=2^(-(player.speedLv-1)/14*8)
        mino.stacker.ctrl.SD_AMP=2^(-(player.speedLv-1)/14*8)*.03
        sfx.play('lvup')
        scene.BG.baseColor=mymath.lerp({.4,.4,.4},marathon.finalColor,(player.speedLv-1)/14)
    end
end
function marathon.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.totalLine,font.Consolas_B,-player.w*18-110,-32,2048,'center',0,.5,.5,1024,56)
    gc.printf(""..player.speedLv*10,font.Consolas_B,-player.w*18-110,32,2048,'center',0,.5,.5,1024,56)
    gc.printf("Speed Lv.\n"..player.speedLv,font.Consolas_B,-player.w*18-28,256,2048,'right',0,0.25,0.25,2048,56)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end
return marathon