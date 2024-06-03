local bf={}
local battle=require'mino/battle'

local rb
function bf.init(P,mino)
    rb=user.lang.rule.backfire

    scene.BG=require('BG/Energy Beat') scene.BG.init()
    mino.musInfo="T-Malu - Energy Beat"
    mus.add('music/Hurt Record/Energy Beat','whole','ogg',80.556,128*60/126)
    mus.start()

    battle.init(P[1]) P[1].atkMinusByDef=false
    mino.seqGenType='bagp1FromBag'
    P[1].recvLine=0
    P[1].atk=0
    P[1].line=0
end
function bf.BGUpdate()
    scene.BG.setTime(mus.whole:tell())
end
function bf.postCheckClear(player,mino)
    if player.history.line==0 then
        for i=1,#player.garbage do
        battle.atkRecv(player,player.garbage[i])
        player.recvLine=player.recvLine+player.garbage[i].amount
        end
        player.garbage={}
    else battle.defense(player,battle.stdAtkCalculate(player),mino)
    end
end
function bf.onLineClear(player,mino)
    local his=player.history
    player.line=player.line+his.line
    player.atk=player.atk+battle.stdAtkCalculate(player)
    battle.sendAtk(player,player,battle.stdAtkGen(player))
end
function bf.afterPieceDrop(player,mino)
    if player.recvLine>=80 then mino.win(player) end
end
local efftxt
function bf.underFieldDraw(player)
    local x=-18*player.w-110
    gc.setColor(1,1,1)
    gc.printf(""..max(80-player.recvLine,0),font.JB,x,-48,6000,'center',0,.625,.625,3000,96)
    gc.printf(rb.remain,font.JB_B,x,0,6000,'center',0,.2,.2,3000,96)
    efftxt=player.line==0 and "-" or string.format("%.2f",player.atk/player.line)
    gc.printf(efftxt,font.JB,x,56,6000,'center',0,.4,.4,3000,96)
    gc.printf(rb.eff,font.JB_B,x,96,6000,'center',0,.2,.2,3000,96)
end
return bf