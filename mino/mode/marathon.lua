local rule={}
function rule.init(P,mino)

    mino.rule.allowPush={}
    mino.rule.allowSpin={T=true}
    scene.BG=require('BG/chessboard')
    scene.BG.speed=125/120 scene.BG.delay=.241
    scene.BG.baseColor={.4,.4,.4}
    local r,g,b=COLOR.hsv(rand()*6,.8,.75)
    rule.finalColor={r,g,b}
    mino.musInfo="つかスタジオ - リズムよく心地よく汗を流す時のテーマ"
    mus.add('music/Hurt Record/sweat','whole','ogg',20.879,336*60/125)
    mus.start()
    sfx.add({
        lvup='sfx/mode/general/level up.wav'
    })

    local c=mino.stacker.ctrl
    c.ASD=.15 c.ASP=.03 c.SD_ASD=0 c.SD_ASP=.03

    P[1].LDelay=.5
    for k,v in pairs(P) do
        v.CDelay=.25
        v.EDelay=.1

        v.speedLv=1
        v.FDelay=2^(-(v.speedLv-1)/14*8)
        v.totalLine=0
    end
end
function rule.onLineClear(player,mino)
    local his=player.history
    player.totalLine=player.totalLine+his.line
    while player.totalLine>=player.speedLv*10 do
        if player.totalLine>=150 then mino.win(player) break end
        player.speedLv=player.speedLv+1
        player.FDelay=2^(-(player.speedLv-1)/14*8)
        mino.stacker.ctrl.SD_AMP=2^(-(player.speedLv-1)/14*8)*.03
        sfx.play('lvup')
        if not mino.unableBG then scene.BG.baseColor=myMath.lerp({.4,.4,.4},rule.finalColor,(player.speedLv-1)/14) end
    end
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.totalLine,font.JB_B,-player.w*18-110,-36,2048,'center',0,.5,.5,1024,font.height.JB_B/2)
    gc.printf(""..player.speedLv*10,font.JB_B,-player.w*18-110,36,2048,'center',0,.5,.5,1024,font.height.JB_B/2)
    gc.printf("Level "..player.speedLv,font.JB_B,-player.w*18-28,288,2048,'right',0,0.25,0.25,2048,font.height.JB_B/2)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end

function rule.scoreSave(P,mino)
    local pb=file.read('player/best score')
    local ispb=pb.marathon and (P[1].totalLine>=150 and P[1].gameTimer<pb.marathon.time or min(P[1].totalLine,150)>pb.marathon.line)
    if not pb.marathon or ispb then
    pb.marathon={level=P[1].speedLv,line=P[1].totalLine,time=P[1].gameTimer,date=os.date("%Y/%m/%d  %H:%M:%S")}
    file.save('player/best score',pb)
    end
    return ispb
end
return rule