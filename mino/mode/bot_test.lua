local fLib=require('mino/fieldLib')
local bot_cc=require('mino/bot/cc')
local btest={}
function btest.init(P,mino)
    mino.resetStopMusic=false
    mino.seqGenType='bagp1FromBag'
    mino.rule.allowSpin={T=true}
    --mino.waitTime=.5
    mino.musInfo="R-side - Nine Five"
    P[1].FDelay=1e99
    mino.stacker.opList={}
    --[[fLib.insertField(P[1],{
        {'L',' ',' ','Z','Z',' ','S',' ',' ',' '},
        {'L',' ',' ',' ','Z','Z','S','S','O','O'},
        {'L','L',' ','I','I','I','I','S','O','O'},
    })]]
    btest.botThread=bot_cc.newThread(1,P,1)
    bot_cc.startThread(btest.botThread,{pcloop=2},{perfect_clear=9999})
    btest.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(P[1]),
    B2B=P[1].history.B2B>0,
    combo=P[1].history.combo,
    })
    btest.expect={} btest.opTimer=0
end

local msgSend=false
function btest.update(player,dt,mino)
    btest.opTimer=btest.opTimer+dt
    if btest.opTimer>1 then
        if not msgSend then
        btest.botThread.sendChannel:push({op='require'})
        msgSend=true
        end
        local op=btest.botThread.recvChannel:pop()
        if op and msgSend then
        btest.expect=op.expect
        bot_cc.operate(player,op,false,mino)
        btest.opTimer=btest.opTimer-.25
        msgSend=false
        end
    end
end
function btest.afterPieceDrop(player)
    btest.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(player),
    B2B=player.history.B2B>0,
    combo=player.history.combo,
    })
end
function btest.onNextGen(player,nextStart)
    print('adding next queue')
    bot_cc.sendNext(btest.botThread,player,nextStart)
    print('next queue added')
end
function btest.overFieldDraw(player)
    gc.setColor(1,1,1)
    if btest.expect then
        for i=1,#btest.expect,2 do
            gc.setLineWidth(3)
            gc.rectangle('line',36*(btest.expect[i]-player.w/2-1)+3,-36*(btest.expect[i+1]-player.h/2)+3,30,30)
        end
    end
    gc.printf(btest.botThread.sendChannel:getCount(),font.JB_B,0,0,6000,'center',0,.25,.25,3000,96)
    --gc.printf(msgSend and "true" or "false",font.JB_B,0,0,6000,'center',0,.25,.25,3000,96)
end
function btest.exit()
    btest.botThread.sendChannel:push({op='destroy'})
    while btest.botThread.thread:isRunning() do
        --nothing 
    end
    btest.botThread.thread:release()
end
return btest