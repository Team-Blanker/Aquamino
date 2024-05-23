local gc=love.graphics
local fLib=require'mino/fieldLib'
local rd
local rule={}
function rule.init(P,mino)
    rd=user.lang.rule.dig
    scene.BG=require('BG/bubble') scene.BG.init()
    mino.musInfo="守己 - アトモスフィア(Atmosphere)"
    mus.add('music/Hurt Record/Atmosphere','whole','ogg',21.667,64)--192*(60/180)
    mus.start()
    P[1].remainLine=40
    P[1].summonLine=40
    P[1].pieceCount=0
    P[1].lastHole=0
    P[1].FDelay=4
    P[1].LDelay=4
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
function rule.afterPieceDrop(player)
    player.pieceCount=player.pieceCount+1
end
function rule.underFieldDraw(player)
    local x=-18*player.w-110
    gc.setColor(1,1,1)
    gc.printf(""..player.remainLine,font.JB,x,-48,6000,'center',0,.625,.625,3000,96)
    gc.printf(rd.remain,font.JB_B,x,0,6000,'center',0,.2,.2,3000,96)
    gc.printf(""..player.pieceCount,font.JB,x,56,6000,'center',0,.4,.4,3000,96)
    gc.printf(rd.piece,font.JB_B,x,96,6000,'center',0,.2,.2,3000,96)
end
return rule