local bf={}
local battle=require'mino/battle'
function bf.init(P,mino)
    scene.BG=require'BG/blank'
    battle.init(P[1])
end
function bf.postCheckClear(player,mino)
    if player.history.line==0 then
        for i=1,#player.garbage do
        battle.atkRecv(player,player.garbage[i])
        end
        player.garbage={}
    else battle.defense(player,battle.stdAtkCalculate(player))
    end
end
function bf.onLineClear(player,mino)
    battle.sendAtk(player,player,battle.stdAtkGen(player))
end
return bf