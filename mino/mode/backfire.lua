local bf={}
local battle=require'mino/battle'
function bf.init(P,mino)
    scene.BG=require'BG/blank'
    battle.init(P[1])
    P[1].recvLine=0
end
function bf.postCheckClear(player,mino)
    if player.history.line==0 then
        for i=1,#player.garbage do
        battle.atkRecv(player,player.garbage[i])
        player.recvLine=player.recvLine+player.garbage[i].amount
        end
        player.garbage={}
    else battle.defense(player,battle.stdAtkCalculate(player))
    end
end
function bf.onLineClear(player,mino)
    battle.sendAtk(player,player,battle.stdAtkGen(player))
end
function bf.afterPieceDrop(player,mino)
    if player.recvLine>=80 then mino.win(player) end
end
function bf.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..max(80-player.recvLine,0),font.JB,-18*player.w-110,0,800,'center',0,.625,.625,400,84)
end
return bf