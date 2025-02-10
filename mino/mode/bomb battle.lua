local rule={}
local battle=require'mino/battle'
local fLib=require'mino/fieldLib'
local bot_cc=require'mino/bot/cc'

local musTag={'battle'}

local songList={
    function ()
        mus.add('music/Hurt Record/burning heart','whole','ogg',5.4,256*60/200)
    end,
    function ()
        mus.add('music/Hurt Record/SAMURAI SWORD','whole','ogg',16.8,67.2)
    end,
    function ()
        mus.add('music/Hurt Record/Ice-eyes','whole','ogg',99/7,576/7)
    end,
}
local songInfoList={
    "カモキング - burning heart",
    "カモキング - SAMURAI SWORD",
    "カモキング - アイス・アイズ (Ice-eyes)"
}
local songCs=math.random(#songList)
function rule.init(P,mino,modeInfo)
    mino.resetStopMusic=false

    scene.BG=require('BG/galaxy') scene.BG.init()

    local hasbgm=mus.checkTag('battle')

    if not hasbgm then
        songCs=math.random(#songList)
        songList[songCs]()
        mus.start()
        mus.setTag(musTag)
    end

    mino.musInfo=songInfoList[songCs]

    mino.seqGenType='bagp1FromBag' mino.seqSync=true
    P[1].atk=0
    P[1].line=0
    P[2]=myTable.copy(P[1])
    --print(modeInfo.arg.playerPos)
    if modeInfo.arg.playerPos=='left' then P[1].posX=-400 P[2].posX=400
    else P[1].posX=400 P[2].posX=-400 end
    P[2].LDelay=1e99 P[2].FDelay=1e99 --P[2].summonHeightAlign=1
    P[1].target=2 P[2].target=1
    mino.fieldScale=min(mino.fieldScale,1)
    battle.init(P[1]) battle.init(P[2]) fLib.setRS(P[2],'SRS_origin')

    rule.botThread=bot_cc.newThread(1,P,2)
    bot_cc.startThread(rule.botThread,nil)
    rule.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(P[2]),
    B2B=P[2].history.B2B>0,
    combo=P[2].history.combo,
    })

    rule.expect={}
    rule.opDelay=modeInfo.arg.bot_DropDelay
    rule.opTimer=0
end

local msgSend=false
function rule.gameUpdate(P,dt,mino)
    rule.opTimer=rule.opTimer+dt
    if rule.opTimer>1 then
        if not msgSend then
        rule.botThread.sendChannel:push({op='require'})
        msgSend=true
        end
        local op=rule.botThread.recvChannel:pop()
        if op and msgSend then
        rule.expect=op.expect
        bot_cc.operate(P[2],op,false,mino)
        rule.opTimer=rule.opTimer-rule.opDelay
        msgSend=false
        end
    end
    if P[2].deadTimer>=0 then mino.win(P[1]) end
end

function rule.always(player,dt)
    battle.update(player,dt)
end
function rule.afterCheckClear(player,mino)
    if player.history.line==0 then
        battle.stdBombAtkRecv(player)
    else battle.defense(player,battle.stdAtkCalculate(player),mino)
    end
end
function rule.onLineClear(player,mino)
    local his=player.history
    player.line=player.line+his.line
    player.atk=player.atk+battle.stdAtkCalculate(player)
    battle.sendAtk(player,mino.player[player.target],battle.stdBombAtkGen(player))
end
function rule.afterPieceDrop(player,mino)
    if player==mino.player[2] then
    rule.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(player),
    B2B=player.history.B2B>0,
    combo=player.history.combo,
    garbage=battle.getGarbageAmount(player)
    })
    end
end
function rule.onNextGen(player,nextStart,mino)
    if player==mino.player[2] then
    bot_cc.sendNext(rule.botThread,player,nextStart)
    end
end
local efftxt
function rule.underFieldDraw(player)
    local x=-18*player.w-110
    gc.setColor(1,1,1)
    gc.printf(""..player.atk,font.JB,x,-48,6000,'center',0,.625,.625,3000,96)

    efftxt=player.line==0 and "-" or string.format("%.2f",player.atk/player.line)
    gc.printf(efftxt,font.JB,x,56,6000,'center',0,.4,.4,3000,96)
end
function rule.overFieldDraw(player,mino)
    if player==mino.player[2] then
    gc.setColor(1,1,1)
    if rule.expect then
        for i=1,#rule.expect,2 do
            gc.setLineWidth(3)
            gc.rectangle('line',36*(rule.expect[i]-player.w/2-1)+3,-36*(rule.expect[i+1]-player.h/2)+3,30,30)
        end
    end
    end
end
function rule.exit()
    bot_cc.destroyThread(rule.botThread)
end
return rule