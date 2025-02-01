local rule={}
local battle=require'mino/battle'

local rb
function rule.init(P,mino)
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
function rule.BGUpdate()
    scene.BG.setTime(mus.whole:tell())
end
function rule.afterCheckClear(player,mino)
    if player.history.line==0 then
        player.recvLine=player.recvLine+battle.stdAtkRecv(player)
    else battle.defense(player,battle.stdAtkCalculate(player),mino)
    end
end
function rule.onLineClear(player,mino)
    local his=player.history
    player.line=player.line+his.line
    player.atk=player.atk+battle.stdAtkCalculate(player)
    battle.sendAtk(player,player,battle.stdAtkGen(player,0))
end
function rule.afterPieceDrop(player,mino)
    if player.recvLine>=80 then mino.win(player) end
end

function rule.always(player,dt)
    battle.update(player,dt)
end

local efftxt
function rule.underFieldDraw(player)
    local x=-18*player.w-110
    gc.setColor(1,1,1)
    gc.printf(""..max(80-player.recvLine,0),font.JB,x,-48,6000,'center',0,.625,.625,3000,96)
    gc.printf(rb.remain,font.JB_B,x,0,6000,'center',0,.2,.2,3000,96)
    efftxt=player.line==0 and "-" or string.format("%.2f",player.atk/player.line)
    gc.printf(efftxt,font.JB,x,56,6000,'center',0,.4,.4,3000,96)
    gc.printf(rb.eff,font.JB_B,x,96,6000,'center',0,.2,.2,3000,96)
end

function rule.scoreSave(P,mino)
    if mino.stacker.winState~=1 then return false end
    local pb=file.read('player/best score')
    local ispb=pb.backfire and P[1].gameTimer<pb.backfire.time or false
    if not pb.backfire or P[1].gameTimer<pb.backfire.time then
        pb.backfire={time=P[1].gameTimer,eff=P[1].atk/P[1].line,date=os.date("%Y/%m/%d  %H:%M:%S")}
        file.save('player/best score',pb)
    end
    return ispb
end
return rule