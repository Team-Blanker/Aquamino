local btest={}
local bot_cc=require('mino/bot/cc')
local battle=require'mino/battle'

local rb
function btest.init(P,mino)
    rb=user.lang.rule.backfire

    scene.BG=require('BG/Energy Beat') scene.BG.init()
    mino.musInfo="T-Malu - Energy Beat"
    mus.add('music/Hurt Record/Energy Beat','whole','ogg',80.556,128*60/126)
    mus.start()

    battle.init(P[1]) P[1].atkMinusByDef=false
    mino.seqGenType='bagp1FromBag'
    P[1].LDelay=1e99
    P[1].recvLine=0
    P[1].atk=0
    P[1].line=0

    mino.stacker.opList={}
    --[[fLib.insertField(P[1],{
        {'L',' ',' ','Z','Z',' ','S',' ',' ',' '},
        {'L',' ',' ',' ','Z','Z','S','S','O','O'},
        {'L','L',' ','I','I','I','I','S','O','O'},
    })]]
    btest.botThread=bot_cc.newThread(1,P,1)
    bot_cc.startThread(btest.botThread)
    btest.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(P[1]),
    B2B=P[1].history.B2B>0,
    combo=P[1].history.combo,
    })
    btest.expect={}
    btest.opTimer=0
end
function btest.BGUpdate()
    scene.BG.setTime(mus.whole:tell())
end
function btest.update(player,dt,mino)
    btest.opTimer=btest.opTimer+dt
    if btest.opTimer>1 then
        btest.botThread.sendChannel:push({op='require'})
        local op=btest.botThread.recvChannel:demand()
        if op then
        btest.expect=op.expect
        bot_cc.operate(player,op,false,mino)
        btest.opTimer=btest.opTimer-1
        end
    end
end
function btest.postCheckClear(player,mino)
    if player.history.line==0 then
        for i=1,#player.garbage do
        battle.atkRecv(player,player.garbage[i])
        player.recvLine=player.recvLine+player.garbage[i].amount
        end
        player.garbage={}
    else battle.defense(player,battle.stdAtkCalculate(player),mino)
    end
end
function btest.onLineClear(player,mino)
    local his=player.history
    player.line=player.line+his.line
    player.atk=player.atk+battle.stdAtkCalculate(player)
    battle.sendAtk(player,player,battle.stdAtkGen(player))
end
function btest.afterPieceDrop(player)
    btest.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(player),
    B2B=player.history.B2B>0,
    combo=player.history.combo,
    })
    if player.recvLine>=80 then mino.win(player) end
end
function btest.onNextGen(player,nextStart)
    print('adding next queue')
    bot_cc.sendNext(btest.botThread,player,nextStart)
    print('next queue added')
end
local efftxt
function btest.underFieldDraw(player)
    local x=-18*player.w-110
    gc.setColor(1,1,1)
    gc.printf(""..max(80-player.recvLine,0),font.JB,x,-48,6000,'center',0,.625,.625,3000,96)
    gc.printf(rb.remain,font.JB_B,x,0,6000,'center',0,.2,.2,3000,96)
    efftxt=player.line==0 and "-" or string.format("%.2f",player.atk/player.line)
    gc.printf(efftxt,font.JB,x,56,6000,'center',0,.4,.4,3000,96)
    gc.printf(rb.eff,font.JB_B,x,96,6000,'center',0,.2,.2,3000,96)
end
function btest.overFieldDraw(player)
    gc.setColor(1,1,1)
    if btest.expect then
        for i=1,#btest.expect,2 do
            gc.setLineWidth(3)
            gc.rectangle('line',36*(btest.expect[i]-player.w/2-1)+3,-36*(btest.expect[i+1]-player.h/2)+3,30,30)
        end
    end
    --gc.printf(btest.botThread.sendChannel:getCount(),font.JB_B,0,0,6000,'center',0,.25,.25,3000,96)
end
function btest.exit()
    btest.botThread.sendChannel:push({op='destroy'})
    while btest.botThread.thread:isRunning() do
        --nothing 
    end
    btest.botThread.thread:release()
end
return btest