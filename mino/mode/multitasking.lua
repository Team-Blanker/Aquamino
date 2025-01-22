local rule={}
function rule.init(P,mino)
    sfx.add({
        lvup='sfx/mode/general/level up.wav'
    })
    mino.musInfo="georhythm - nega to posi"
    scene.BG=require('BG/nega to posi') scene.BG.init()
    mus.add('music/Hurt Record/nega to posi','whole','ogg',61.847,224*60/130)
    mus.start()

    mino.stacker.ctrl={
       ASD=.15,ASP=.03,SDType='D',SD_ASD=0,SD_ASP=.03
    }
    P[1].FDelay=1e99
    P[1].posX=-400 P[2]=myTable.copy(P[1]) P[2].posX=400 mino.stacker.opList={1,2}
    --P[1].posX=-6666 P[2].posX=6666
    for k,v in pairs(P) do
        v.CDelay=.2
        v.EDelay=.1
        v.speedLv=1
        v.FDelay=2^(-(v.speedLv-1)/14*8)
        v.totalLine=0
    end
    mino.fieldScale=min(mino.fieldScale,1)
end
function rule.onLineClear(player,mino)
    local his=player.history
    player.totalLine=player.totalLine+his.line
    while player.totalLine>=player.speedLv*5 do
        local win=true
        for k,v in pairs(mino.player) do
            if v.totalLine<75 then win=false break end
        end
        if win then
            for k,v in pairs(mino.player) do mino.win(v) end break
        end
        player.speedLv=player.speedLv+1
        player.FDelay=2^(-min(player.speedLv-1,14)/14*8)
        mino.stacker.ctrl.SD_ASP=2^(-(player.speedLv-1)/14*8)*.03
        sfx.play('lvup')
        if not mino.unableBG then scene.BG.sendProgress(mino.player[1].speedLv/15,mino.player[2].speedLv/15) end
    end
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.totalLine,font.JB_B,-player.w*18-110,-36,2048,'center',0,.5,.5,1024,84)
    gc.printf(""..min(player.speedLv,15)*5,font.JB_B,-player.w*18-110,36,2048,'center',0,.5,.5,1024,84)
    gc.printf("Level "..min(player.speedLv,15),font.JB_B,-player.w*18-28,288,2048,'right',0,0.25,0.25,2048,84)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end

function rule.scoreSave(P,mino)
    local pb=file.read('player/best score')
    local lv=min(P[1].speedLv,P[2].speedLv)
    local line=min(P[1].totalLine,P[2].totalLine)
    local ispb=pb.multitasking and (line>=75 and P[1].gameTimer<pb.multitasking.time or min(line,75)>pb.multitasking.line)
    if not pb.multitasking or ispb then
    pb.multitasking={level=lv,line=line,time=P[1].gameTimer,date=os.date("%Y/%m/%d  %H:%M:%S")}
    file.save('player/best score',pb)
    end
    return ispb
end
return rule