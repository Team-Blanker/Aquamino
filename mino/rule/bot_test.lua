local bot_zzz=require('mino/bot/zzztoj')
local btest={}
function btest.init(P,mino)
    btest.opTimer=0
    mino.resetStopMusic=false
    mino.rule.allowSpin={T=true}
    mino.waitTime=.5
    mino.musInfo="R-side - Nine Five"
    P[1].FDelay=1e99
end
local eq
function btest.update(player,dt,mino)
    btest.opTimer=btest.opTimer+dt
    if btest.opTimer>.5 then
        eq=bot_zzz.getExecution(player,6)
        print(eq)
        while eq~='' do
            eq=bot_zzz.execute(player,eq,mino)
        end
        bot_zzz.execute(player,'V',mino)
        print('execute')
        btest.opTimer=btest.opTimer-.5
    end
end
return btest