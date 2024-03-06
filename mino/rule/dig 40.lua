local gc=love.graphics
local fLib=require'mino/fieldLib'

local rule={}
function rule.init(P,mino)
    scene.BG=require('BG/bubble') scene.BG.init()
    mino.musInfo="守己 - アトモスフィア(Atmosphere)"
    mus.add('music/Hurt Record/Atmosphere','whole','mp3',21.667,64)--192*(60/180)
    mus.start()
    P[1].remainLine=40
    P[1].summonLine=40
    P[1].pieceCount=0
    P[1].lastHole=0
    P[1].FDelay=4
    for i=1,10 do rule.newGarbageLine(P[1]) end
end
local h
function rule.newGarbageLine(player)
    if player.lastHole==0 then h=rand(player.w)
    else h=rand(player.w-1)
        if h>=player.lastHole then h=h+1 end
    end
    player.lastHole=h
    fLib.garbage(player,'g2',1,h)
    player.field[1].type='gbg'
    player.summonLine=player.summonLine-1
end
function rule.onLineClear(player,mino)
    if player.history.clearLine then
        for k,v in pairs(player.history.clearLine) do
            if v.type=='gbg' then
                player.remainLine=player.remainLine-1
                if player.summonLine>0 then rule.newGarbageLine(player) end
            end
        end
    end
    if player.remainLine<=0 then mino.win(player) end
end
function rule.onPieceDrop(player)
    player.pieceCount=player.pieceCount+1
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..player.remainLine,Consolas,-18*player.w-110,-48,6000,'center',0,.75,.75,3000,0)
    gc.printf(""..player.pieceCount.." pieces",Consolas,-18*player.w-30,64,6000,'right',0,.25,.25,6000,96)
end
return rule