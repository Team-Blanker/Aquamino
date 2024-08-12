--Use ZZZTOJ wrapper from 26F Studio
--已丢弃，仅供参考

local B,SC=require('mino/blocks'),require('mino/spinCheck')
local M,T=mymath,mytable
require'zzz'
local fLib=require('mino/fieldLib')

local bot_zzz={}
function bot_zzz.renderField(player)
    assert(player.w==10,'Field width must be 10')
    local boolField={}
    for y=1,#player.field do
        for x=1,10 do
            boolField[10*(y-1)+x]=next(player.field[y][x]) and true or false
        end
    end
    while #boolField<400 do
        boolField[#boolField+1]=false
    end
    for i=39,0,-1 do
        local l=''
        for j=1,10 do
        l=l..(boolField[i*10+j] and '[]' or '  ')
        end
        print(l)
    end
    return boolField
end
function bot_zzz.calculate(player,nextLimit)
    local nq=player.cur.name
    for i=1,math.min(#player.next,nextLimit) do
        nq=nq..player.next[i]
    end
    return zzz.run(bot_zzz.renderField(player),player.cur.name or ' ',player.hold.name or ' ',player.canHold,nq)
end
--[[return:
l=左一格 L=左到底 r=右一格 R=右到底 d=降一格 D=降到底
z=逆时针 x=180 c=顺时针 v=暂存 V=硬降
]]
function bot_zzz.execute(player,eq,mino)
    local k=eq:sub(1,1)
    local C,A=player.cur,player.smoothAnim
    local his=player.history
    local success
    if player.deadTimer<0 and mino.stacker.winState==0 then
        local landed=fLib.coincide(player,0,-1)
        if k=='l' then
            success=not fLib.coincide(player,-1,0)
            if success then mino.setAnimPrePiece(player) A.timer=A.delay
                C.x=C.x-1 C.moveSuccess=true his.spin=false
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1 end
                player.ghostY=fLib.getGhostY(player)
            end

            mino.sfxPlay.move(player,success,landed)

        elseif k=='L' then
            if not fLib.coincide(player,-1,0) then mino.setAnimPrePiece(player) A.timer=A.delay
                while not fLib.coincide(player,-1,0) do
                local landed=fLib.coincide(player,0,-1)
                C.x=C.x-1 C.moveSuccess=true his.spin=false
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1 end
                end
                player.ghostY=fLib.getGhostY(player)
                mino.sfxPlay.move(player,success,landed)
            end
        elseif k=='r' then
            local success=not fLib.coincide(player,1,0)
            if success then mino.setAnimPrePiece(player) A.timer=A.delay
                C.x=C.x+1 C.moveSuccess=true his.spin=false
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1 end
                player.ghostY=fLib.getGhostY(player)
            end

            mino.sfxPlay.move(player,success,landed)

        elseif k=='R' then
            if not fLib.coincide(player,1,0) then mino.setAnimPrePiece(player) A.timer=A.delay
                while not fLib.coincide(player,1,0) do
                local landed=fLib.coincide(player,0,-1)
                C.x=C.x+1 C.moveSuccess=true his.spin=false
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1 end
                end
                player.ghostY=fLib.getGhostY(player)
                mino.sfxPlay.move(player,success,landed)
            end
        elseif k=='c' then mino.setAnimPrePiece(player)
            C.kickOrder=fLib.kick(player,'R')
            if C.kickOrder then A.timer=A.delay
                player.ghostY=fLib.getGhostY(player)
                C.moveSuccess=true
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1
                else if C.kickOrder~=1 then player.LDR=player.LDR-1 end
                end
                if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](player)
                else his.spin,his.mini=false,false end
            end

            mino.sfxPlay.rotate(player,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)

        elseif k=='z' then mino.setAnimPrePiece(player)
            C.kickOrder=fLib.kick(player,'L')
            if C.kickOrder then A.timer=A.delay
                player.ghostY=fLib.getGhostY(player)
                C.moveSuccess=true
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1
                else if C.kickOrder~=1 then player.LDR=player.LDR-1 end
                end
                if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](player)
                else his.spin,his.mini=false,false end
            end

            mino.sfxPlay.rotate(player,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)

        elseif k=='x' then mino.setAnimPrePiece(player)
            C.kickOrder=fLib.kick(player,'F')
            if C.kickOrder then A.timer=A.delay
                player.ghostY=fLib.getGhostY(player)
                C.moveSuccess=true
                if landed and player.LDR>0 then player.LTimer=0 player.LDR=player.LDR-1
                else if C.kickOrder~=1 then player.LDR=player.LDR-1 end
                end
                if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](player)
                else his.spin,his.mini=false,false end
            end

            mino.sfxPlay.rotate(player,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)

        elseif k=='V' then --硬降
            local xmin,xmax,ymin,ymax=B.edge(C.piece)
            local xlist=B.getX(C.piece)
            local smoothFall=(player.smoothAnimAct and player.FTimer/player.FDelay or 0)
            for j=1,#xlist do
                local lmax=ymax
                while not T.include(C.piece,{xlist[j],lmax}) do
                    lmax=lmax-1
                end
                player.dropAnim[#player.dropAnim+1]={
                    x=C.x+xlist[j],y=C.y-smoothFall+lmax,len=-smoothFall,
                    TMax=.5,TTL=.5, w=xmax-xmin+1,h=ymax-ymin+1,
                    color=mino.color[C.name]
                }
            end
            his.dropHeight=0
            if C.piece and #C.piece~=0 then
                for h=1,C.y do
                    if not fLib.coincide(player,0,-1) then his.spin=false
                        C.y=C.y-1  his.dropHeight=his.dropHeight+1
                        for j=#player.dropAnim,#player.dropAnim-#xlist+1,-1 do
                            player.dropAnim[j].len=player.dropAnim[j].len+1
                        end
                    end
                end

                mino.checkDie(player,true)
                mino.blockLock(player,mino)
            end

            if mino.stacker.winState==0 then
                if (#player.loosen==0 or player.loosen.fallTPL==0) then
                    if player.EDelay==0 and player.CDelay==0 then mino.curIns(player)
                        else mino.addEvent(player,player.EDelay,'curIns')
                    end
                end
            end

        elseif k=='d' then
            if not landed then
                mino.setAnimPrePiece(player) A.timer=A.delay
                C.y=C.y-1 his.spin=false
                if mino.sfxPlay.SD then mino.sfxPlay.SD(player) end
            end
            mino.sfxPlay.touch(player,fLib.coincide(player,0,-1))
        elseif k=='D' then
            while not fLib.coincide(player,0,-1) do local h=0
                mino.setAnimPrePiece(player) A.timer=A.delay
                C.y=C.y-1 h=h+1 his.spin=false
                if mino.sfxPlay.SD then mino.sfxPlay.SD(player) end
            end
            mino.sfxPlay.touch(player,fLib.coincide(player,0,-1))
        elseif k=='v' and player.canHold then--hold
            mino.hold(player) mino.sfxPlay.hold(player)
            if not C.name then local LDR=player.LDR mino.curIns(player) player.LDR=LDR end
            player.canHold=false
        end
    end

    return eq:sub(2,#eq)--去掉第一个操作
end
local th=love.thread
function bot_zzz.init()
    bot_zzz.sendChannel=th.getChannel("zzz_send")
    bot_zzz.recvChannel=th.getChannel("zzz_recv")
    bot_zzz.thread=th.newThread([[
        local bot=require('mino/bot/zzztoj')
        local th=love.thread
        local nextLim=...
        local s,r=th.getChannel("zzz_send"),th.getChannel("zzz_recv")
        while true do
            player=r:demand()
            local eq,hold=bot.calculate(player,nextLim or 6)
            s:push(eq) s:push(hold)
        end
    ]])
end
function bot_zzz.start(nextLim)
    bot_zzz.thread:start(nextLim)
end
function bot_zzz.think(player)
    bot_zzz.recvChannel:push(player)
end
function bot_zzz.getExecution()
    return bot_zzz.sendChannel:pop(),bot_zzz.sendChannel:pop()--eq,hold
end
return bot_zzz