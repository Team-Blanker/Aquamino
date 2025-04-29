local rule={}
local LDelayList={
    .500,.475,.450,.425,.400,
    .380,.360,.340,.320,.300,
    .280,.260,.240,.220,.200,
    .180,.160,.140,.120,.100
}
local ASDList={
    .15,.15,.15,.15,.15,
    .15,.15,.15,.15,.15,
    .14,.14,.14,.14,.14,
    .13,.13,.12,.10,.09
}
local ASPList={
    .030,.030,.030,.030,.030,
    .030,.030,.030,.030,.030,
    .028,.028,.028,.028,.028,
    .026,.026,.024,.020,.018
}
function rule.init(P,mino)

    mino.rule.allowPush={}
    mino.rule.allowSpin={T=true}
    scene.BG=require('BG/rise') scene.BG.init()
    scene.BG.density=1.5
    mino.musInfo="アキハバラ所司代 - TENSION"
    mus.add('music/Hurt Record/TENSION','whole','ogg',1.761,160*60/84)
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
        v.FDelay=0
        v.speedLv=1
        v.totalLine=0
        v.LDRInit=20 v.LDR=20
    end
end
function rule.onLineClear(player,mino)
    local his=player.history
    player.totalLine=player.totalLine+his.line
    while player.totalLine>=player.speedLv*10 do
        if player.totalLine>=200 then mino.win(player) break end
        player.speedLv=player.speedLv+1
        player.LDelay=LDelayList[player.speedLv]
        player.CDelay=max(.25*(16-player.speedLv)/15,0)
        sfx.play('lvup')
        local c=mino.stacker.ctrl
        c.ASD=ASDList[player.speedLv]
        c.ASP=ASPList[player.speedLv]

        if not mino.unableBG then
        scene.BG.density=1.5+4.5*(player.speedLv-1)/19
        scene.BG.BGColor=(player.speedLv>15 and {.04,.12,.08} or player.speedLv>10 and {.12,.06,.06} or player.speedLv>5 and {.04,.06,.12} or {0,0,0})
        scene.BG.parColor=(player.speedLv>15 and {0,1,.6} or player.speedLv>10 and {1,.4,.4} or player.speedLv>5 and {0,.5,1} or {1,1,1})
        end
    end
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.totalLine,font.JB_B,-player.w*18-110,-36,2048,'center',0,.5,.5,1024,84)
    gc.printf(""..player.speedLv*10,font.JB_B,-player.w*18-110,36,2048,'center',0,.5,.5,1024,84)
    gc.printf(("Level M%d\n%.0fms"):format(player.speedLv,LDelayList[player.speedLv]*1000),
        font.JB_B,-player.w*18-28,252,2048,'right',0,0.25,0.25,2048,84)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end

function rule.scoreSave(P,mino)
    local pb=file.read('player/best score')
    local ispb=pb.master and P[1].totalLine>pb.master.line
    if not pb.master or ispb then
    pb.master={level=P[1].speedLv,line=P[1].totalLine,time=P[1].gameTimer,date=os.date("%Y/%m/%d  %H:%M:%S")}
    file.save('player/best score',pb)
    end
    return ispb
end
return rule