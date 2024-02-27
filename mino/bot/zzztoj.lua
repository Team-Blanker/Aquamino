--Use ZZZTOJ wrapper from 26F Studio

require'zzz'
local fLib=require('mino/fieldLib')
local bot_zzz={}
function bot_zzz.renderField(player)
    if player.w~=10 then error('Field width must be 10') end
    local boolField={}
    for y=1,#player.field do
        for x=1,10 do
            boolField[10*(y-1)+x]=next(player.field[y][x]) and true or false
        end
    end
    while #boolField < 400 do
        boolField[#boolField+1]=false
    end
    return boolField
end
function bot_zzz.getExecution(player,nextLimit)
    local nq=''
    for i=1,min(#player.next,nextLimit) do
        nq=nq..player.next[i]
    end
    return zzz.run(bot_zzz.renderField(player),player.cur.name or ' ',player.hold.name or ' ',player.canHold,nq)
end
--[[return:
l=左一格 L=左到底 r=右一格 R=右到底 d=降一格 D=降到底
z=逆时针 x=180（不让用……） c=顺时针 v=暂存 V=硬降
]]
function bot_zzz.execute(player,eq,mino)
    local k=eq:sub(1,1)
    local C,A=player.cur,player.smoothAnim
    local his=player.history
    local success
    if player.deadTimer<0 and S.winState==0 then
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
            if love.keyboard.isDown(S.keySet.MR) then player.MTimer=0 end

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
            if love.keyboard.isDown(S.keySet.MR) then player.MTimer=0 end
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
                    color=player.color[C.name]
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

            if S.winState==0 then
                if (#player.loosen==0 or player.loosen.fallTPL==0) then
                    if player.EDelay==0 and player.CDelay==0 then mino.curIns(player)
                        else mino.addEvent(player,player.EDelay,'curIns')
                    end
                end
            end

        elseif k=='d' then local touch
            if not landed then
                mino.setAnimPrePiece(player) A.timer=A.delay
                C.y=C.y-1 his.spin=false
                touch=fLib.coincide(player,0,-1)
                if mino.sfxPlay.SD then mino.sfxPlay.SD(player) end
            end
        elseif k=='D' then local touch
            while not fLib.coincide(player,0,-1) do local h=0
                mino.setAnimPrePiece(player) A.timer=A.delay
                C.y=C.y-1 h=h+1 his.spin=false
                touch=h>0
                if mino.sfxPlay.SD then mino.sfxPlay.SD(player) end
            end
            mino.sfxPlay.touch(player,touch)
        elseif T.include(S.keySet.hold,k) and player.canHold then
            mino.hold(player) mino.sfxPlay.hold(player)
            if not C.name then local LDR=player.LDR mino.curIns(player) player.LDR=LDR end
            player.canHold=false
        end
        --最高下落速度
        if not T.include(S.keySet.HD,k) and player.FDelay==0 then
            local h=0
            while not fLib.coincide(player,0,-1) do C.y=C.y-1 h=h+1 his.spin=false end
            if h>0 then mino.sfxPlay.touch(player,true) end
        end
    end
    
    return eq:sub(1,#eq)
end
return bot_zzz