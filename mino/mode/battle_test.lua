local rule={}
local battle=require'mino/battle'
local bot_zzz=require('mino/bot/zzztoj')
function rule.init(P,mino)
    mino.musInfo="georhythm - nega to posi"
    scene.BG=require('BG/nega to posi') scene.BG.init()
    mus.add('music/Hurt Record/nega to posi','whole','ogg',61.847,224*60/130)
    mus.start()

    mino.seqGenType='bagp1FromBag' mino.seqSync=true
    P[1].atk=0
    P[1].line=0
    P[1].posx=-450 P[2]=mytable.copy(P[1]) P[2].posx=450
    P[1].target=2 P[2].target=1
    mino.fieldScale=min(mino.fieldScale,1)
    battle.init(P[1]) battle.init(P[2])

    bot_zzz.init() bot_zzz.start(1)
    rule.opTimer=0
end
local eq,hold
function rule.botUpdate(P,dt,mino)
    rule.opTimer=rule.opTimer+dt
    if rule.opTimer>.25 then
        bot_zzz.think(P[2])
        rule.opTimer=rule.opTimer-.25
    end
    eq,hold=bot_zzz.getExecution()

    if hold then bot_zzz.execute(P[2],'v',mino) end
    if eq then print(hold) print(eq)
        while eq~='' do
            eq=bot_zzz.execute(P[2],eq,mino)
        end
        bot_zzz.execute(P[2],'V',mino)
    end
end
function rule.postCheckClear(player,mino)
    if player.history.line==0 then
        for i=1,#player.garbage do
        battle.atkRecv(player,player.garbage[i])
        end
        player.garbage={}
    else battle.defense(player,battle.stdAtkCalculate(player),mino)
    end
end
function rule.onLineClear(player,mino)
    local his=player.history
    player.line=player.line+his.line
    player.atk=player.atk+battle.stdAtkCalculate(player)
    battle.sendAtk(player,mino.player[player.target],battle.stdAtkGen(player))
end
local efftxt
function rule.underFieldDraw(player)
    local x=-18*player.w-110
    gc.setColor(1,1,1)
    gc.printf(""..player.atk,font.JB,x,-48,6000,'center',0,.625,.625,3000,96)

    efftxt=player.line==0 and "-" or string.format("%.2f",player.atk/player.line)
    gc.printf(efftxt,font.JB,x,56,6000,'center',0,.4,.4,3000,96)

end
return rule