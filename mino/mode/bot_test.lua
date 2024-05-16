local fLib=require('mino/fieldLib')
local bot_zzz=require('mino/bot/zzztoj')
local btest={}
function btest.init(P,mino)
    btest.opTimer=0 btest.eq=nil
    mino.resetStopMusic=false
    mino.rule.allowSpin={T=true}
    --mino.waitTime=.5
    mino.musInfo="R-side - Nine Five"
    P[1].FDelay=1e99
    bot_zzz.init() bot_zzz.start(1)
    --[[fLib.insertField(P[1],{
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z',' ',' ',' ',' '},
        {'Z','Z','Z','Z','Z','Z','O','O',' ',' '},
        {'Z','Z','Z','Z','Z','Z','O',' ',' ',' '},
    })]]
end
local eq,hold
function btest.update(player,dt,mino)
    btest.opTimer=btest.opTimer+dt
    if btest.opTimer>.5 then
        bot_zzz.think(player)
        btest.opTimer=btest.opTimer-.5
    end
    eq,hold=bot_zzz.getExecution()
    
    if hold then bot_zzz.execute(player,'v',mino) end
    if eq then print(hold) print(eq)
        btest.eq=eq
        while eq~='' do
            eq=bot_zzz.execute(player,eq,mino)
        end
        bot_zzz.execute(player,'V',mino)
    end
end
function btest.overFieldDraw()
    gc.setColor(1,1,1)
    if btest.eq then gc.printf(btest.eq,font.Exo_2_SB,0,-300,1280,'center',0,.75,.75,640,84) end
end
return btest