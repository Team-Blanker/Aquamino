local master={}
local LDelayList={
    .500,.475,.450,.425,.400,
    .380,.360,.340,.320,.300,
    .280,.260,.240,.220,.200,
    .180,.160,.140,.120,.100
}
local ASDList={
    .15,.15,.15,.15,.15,
    .15,.15,.15,.15,.15,
    .14,.14,.13,.13,.12,
    .10,.10,.09,.09,.08
}
local ASPList={
    .030,.030,.030,.030,.030,
    .030,.030,.030,.030,.030,
    .028,.027,.026,.025,.024,
    .020,.020,.018,.018,.016
}
function master.init(P,mino)

    mino.rule.allowPush={}
    mino.rule.allowSpin={T=true}
    scene.BG=require('BG/rise') scene.BG.init()
    scene.BG.density=1.5
    mino.musInfo="アキハバラ所司代 - TENSION"
    mus.add('music/Hurt Record/TENSION','whole','ogg',1.761,160*60/84)
    mus.start()
    sfx.add({
        lvup='sfx/rule/general/level up.ogg'
    })
    mino.stacker.ctrl={
       ASD=.15,ASP=.03,SD_ASD=0,SD_ASP=0
    }
    P[1].LDelay=.5
    for k,v in pairs(P) do
        v.CDelay=.25
        v.EDelay=.1
        v.FDelay=0
        v.speedLv=1
        v.totalLine=0
    end
end
function master.onLineClear(player,mino)
    local his=player.history
    player.totalLine=player.totalLine+his.line
    while player.totalLine>=player.speedLv*10 do
        if player.totalLine>=200 then mino.win(player) break end
        player.speedLv=player.speedLv+1
        player.LDelay=LDelayList[player.speedLv]
        player.CDelay=max(.25*(16-player.speedLv)/15,0)
        sfx.play('lvup')
        local cxk=mino.stacker.ctrl
        cxk.ASD=ASDList[player.speedLv]
        cxk.ASP=ASPList[player.speedLv]

        scene.BG.density=1.5+4.5*(player.speedLv-1)/19
        scene.BG.BGColor=(player.speedLv>15 and {.04,.12,.08} or player.speedLv>10 and {.12,.06,.06} or player.speedLv>5 and {.04,.06,.12} or {0,0,0})
        scene.BG.parColor=(player.speedLv>15 and {0,1,.6} or player.speedLv>10 and {1,.4,.4} or player.speedLv>5 and {0,.5,1} or {1,1,1})
    end
end
function master.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.totalLine,font.JB_B,-player.w*18-110,-32,2048,'center',0,.5,.5,1024,84)
    gc.printf(""..player.speedLv*10,font.JB_B,-player.w*18-110,32,2048,'center',0,.5,.5,1024,84)
    gc.printf(("Speed Lv.\nM%d,%.0fms"):format(player.speedLv,LDelayList[player.speedLv]*1000),
        font.JB_B,-player.w*18-28,256,2048,'right',0,0.25,0.25,2048,84)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end
return master