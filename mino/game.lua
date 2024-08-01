---@diagnostic disable: deprecated
--[[
    stacker是你自己，player存储的是“玩家”的所有信息。
    stacker是可以操控多个player的。stacker.opList存储着你所操控的player序号。
]]
local BUTTON,SLIDER=scene.button,scene.slider

local gc=love.graphics
local fs=love.filesystem

local T,M=mytable,mymath

local vKey=require'mino/virtualKey'

local fLib=require'mino/fieldLib'
local coincide=fLib.coincide
local B=require'mino/blocks'
local NG=require'mino/nextGen'
local SC=require'mino/spinCheck'

--math.randomseed(os.time())

local mino={
    endPaused=false,
    exitScene=nil,resetStopMusic=true,unableBG=false,
    mode='',musInfo="",
    sfxPlay=nil,
    rule={
        timer=0,
        allowPush={},allowSpin={T=true},spinType='default',enableMiniSpin=true,
        loosen={fallTPL=0}--TPL=Time Per Line
    },
    started=false,paused=false,pauseTimer=0,
    stacker={
        keySet={},ctrl={},opList={1},event={},
        dieAnim=function() end,
        winState=0,started=false
    },
    seqGenType='bag',seqSync=false,
    bag={'Z','S','J','L','T','O','I'},orient={Z=0,S=0,J=0,L=0,T=0,O=0,I=0},
    player={},
    fieldScale=1,
}
local P,S=mino.player,mino.stacker

function mino.start(player)
    player.started=true
end
function mino.pause(player)
    mino.paused=true
end
function mino.freeze(player)
    --啥事不做，单纯的不让玩家操作
end
function mino.blockLock(player)
    local his=player.history
    fLib.lock(player) fLib.loosenFall(player) mino.sfxPlay.lock(player)
    if mino.rule.onPieceDrop then mino.rule.onPieceDrop(player,mino) end
    if player.loosen[1] then
        his.push=#player.loosen
        if mino.rule.loosen.fallTPL==0 and player.CDelay==0 then
            while player.loosen[1] do fLib.loosenFall(player) end
            mino.loosenDrop(player)
        else mino.addEvent(player,mino.rule.loosen.fallTPL,'loosenDrop') end
    else
        his.push=0
        his.line,his.PC,his.clearLine=fLib.lineClear(player)
        mino.checkClear(player,true) mino.sfxPlay.clear(player)
        if mino.rule.postCheckClear then mino.rule.postCheckClear(player,mino) end
        if his.line>0 then
            if mino.rule.onLineClear then mino.rule.onLineClear(player,mino) end
            if mino.blockSkin.onLineClear then mino.blockSkin.onLineClear(player,mino) end
        end
    end
    if mino.rule.afterPieceDrop then mino.rule.afterPieceDrop(player,mino) end

    if mino.blockSkin.afterPieceDrop then mino.blockSkin.afterPieceDrop(player,mino) end
    if mino.theme.afterPieceDrop then mino.theme.afterPieceDrop(player,mino) end
end

function mino.win(player)
    local w=S.winState
    local delay=mino.theme.getResultShowDelay
    S.winState=1 player.winTimer=0 if mino.sfxPlay.win then mino.sfxPlay.win() end
    if mino.rule.scoreSave then
        S.newRecord=mino.rule.scoreSave(mino.player,mino)
    end
    if w~=1 then mino.addStackerEvent(delay and delay(S) or 1.5,'pause') end
end
function mino.lose(player)
    local w=S.winState
    local delay=mino.theme.getResultShowDelay
    S.winState=-1 player.loseTimer=0 if mino.sfxPlay.lose then mino.sfxPlay.lose() end
    if mino.rule.scoreSave then
        S.newRecord=mino.rule.scoreSave(mino.player,mino)
    end
    if w~=-1 then mino.addStackerEvent(delay and delay(S) or 1.5,'pause') end
end
function mino.die(player,isStacker)
    player.deadTimer=0 player.alive=false
    if mino.sfxPlay.die then mino.sfxPlay.die() end
    if isStacker then
        if mino.rule.onDie then mino.rule.onDie(player,mino)
        else mino.lose(player) end
    end
end
function mino.revive(player,isStacker)
    
end
function mino.checkDie(player)
    return coincide(player)
end
function mino.Ins20GDrop(player)
    while not coincide(player,0,-1) do player.cur.y=player.cur.y-1 end
    if mino.sfxPlay.touch then mino.sfxPlay.touch(player,true) end
end

function mino.nextIns(player)
    local field=player.field
    --清除全空的行
    local stop=false
    for y=#field,1,-1 do
        if #field[y]~=0 then
            local empty=true
            for x=1,#field[y] do
                if next(field[y][x]) then empty=false stop=true break end
            end
            if stop then break end
            if empty then table.remove(field,y) end
        end
    end

    if player.alive then

    if player.next[player.preview+1] then
        local n=player.preview+1
        player.NP[n]=T.copy(B[player.next[n]])
        player.NO[n]=mino.orient[player.next[n]]
        for k=1,player.NO[n] do
            player.NP[n]=B.rotate(player.NP[n],0,'R')
        end
    end

    local C=player.cur
    local A=player.smoothAnim
    local his=player.history
    his.line=0 C.spin=false C.mini=false his.dropHeight=0
    if player.next[1] then
        C.O=table.remove(player.NO,1)
        C.name=table.remove(player.next,1)
        C.piece=table.remove(player.NP,1)
        if mino.rule.onPieceSummon then mino.rule.onPieceSummon(player,mino) end
        fLib.entryPlace(player)

        A.prePiece,A.drawPiece=T.copy(C.piece),T.copy(C.piece)
        for i=1,#A.prePiece do
            A.prePiece[i][1],A.prePiece[i][2]=A.prePiece[i][1]+C.x,A.prePiece[i][2]+C.y
            A.drawPiece[i][1],A.drawPiece[i][2]=A.drawPiece[i][1]+C.x,A.drawPiece[i][2]+C.y
        end
        player.canHold=true C.kickOrder=nil
    elseif player.hold.name then mino.hold(player)
    else C.piece,C.name=nil,nil end
    if #player.next<=player.preview then mino.insertNextQueue(player) end
    player.MTimer,player.DTimer=min(player.MTimer,S.ctrl.ASD),min(player.DTimer,S.ctrl.SD_ASD)
    player.LDR=player.LDRInit player.LTimer=0

    local k=false
    for i=1,#mino.stacker.opList do
        if mino.player[mino.stacker.opList[i]]==player then k=true break end
    end

    if k then
        if S.keyDown.hold and player.canInitHold then
            player.initOpQueue[#player.initOpQueue+1]='initHold'
        end
        if S.keyDown.ML and player.canInitMove then
            player.initOpQueue[#player.initOpQueue+1]='initML'
        elseif S.keyDown.MR and player.canInitMove then
            player.initOpQueue[#player.initOpQueue+1]='initMR'
        end
        if player.EDelay+player.CDelay~=0 then --对消行延迟与出块延迟均=0的情况特判，不应用提前旋转
            if S.keyDown.CW and player.canInitRotate then
                player.initOpQueue[#player.initOpQueue+1]='initRotateCW'
            elseif S.keyDown.CCW and player.canInitRotate then
                player.initOpQueue[#player.initOpQueue+1]='initRotateCCW'
            elseif S.keyDown.flip and player.canInitRotate then
                player.initOpQueue[#player.initOpQueue+1]='initRotate180'
            end
        end
        for i=1,#player.initOpQueue do mino.operate[player.initOpQueue[i]](player) end
    end
    player.initOpQueue={}

    if player.FDelay==0 then
        if player.event[3] then mino.addEvent(player,0,'Ins20GDrop') else
        mino.Ins20GDrop(player) end
    end

    if mino.rule.onPieceEntry then mino.rule.onPieceEntry(player) end
    if C.piece then player.cur.ghostY=fLib.getGhostY(player) end

    end
end
function mino.checkClear(player,comboBreak,delayBreak)
    local his=player.history
    his.spin,his.mini=player.cur.spin,player.cur.mini

    local b2b=his.B2B
    if his.line>0 then
        if delayBreak or player.CDelay==0 then fLib.eraseEmptyLine(player)
        else mino.addEvent(player,player.CDelay,'eraseEmptyLine') end
        his.combo=his.combo+1
        his.B2B=(his.spin or his.line>=4) and his.B2B+1 or -1
        his.CDelay=player.CDelay
    elseif comboBreak then his.combo=0 end
    his.wide=fLib.wideDetect(player)
    if his.B2B==-1 and b2b>0 and mino.sfxPlay.B2BBreak then mino.sfxPlay.B2BBreak(player,b2b) end
    if mino.theme.updateClearInfo then mino.theme.updateClearInfo(player,mino) end
end

function mino.hold(player)
    local H,C,A=player.hold,player.cur,player.smoothAnim
    H.name,C.name=C.name,H.name  H.piece,C.piece=C.piece,H.piece  H.O,C.O=C.O,H.O
    if player.hold.mode=='A' then
        H.x,H.y,C.x,C.y=C.x,C.y,H.x,H.y
        while C.piece and coincide(player) and C.y<player.h+B.Soff[C.name][2] do C.y=C.y+1 end
    elseif player.hold.mode=='S' then
    if C.name and C.piece then
        fLib.entryPlace(player)
        C.O=mino.orient[C.name]
    else
        if player.next[player.preview+1] then
            local wtf=player.preview+1
            player.NP[wtf]=T.copy(B[player.next[wtf]])
            player.NO[wtf]=mino.orient[player.next[wtf]]
            for k=1,player.NO[wtf] do
                player.NP[wtf]=B.rotate(player.NP[wtf],0,'R')
            end
        end

        local C=player.cur
        local A=player.smoothAnim
        local his=player.history
        his.line=0 C.spin=false C.mini=false his.dropHeight=0
        if player.next[1] then
            C.O=table.remove(player.NO,1)
            C.name=table.remove(player.next,1)
            C.piece=table.remove(player.NP,1)
            if mino.rule.onPieceSummon then mino.rule.onPieceSummon(player,mino) end
            fLib.entryPlace(player)

            A.prePiece,A.drawPiece=T.copy(C.piece),T.copy(C.piece)
            for i=1,#A.prePiece do
                A.prePiece[i][1],A.prePiece[i][2]=A.prePiece[i][1]+C.x,A.prePiece[i][2]+C.y
                A.drawPiece[i][1],A.drawPiece[i][2]=A.drawPiece[i][1]+C.x,A.drawPiece[i][2]+C.y
            end
            player.canHold=true C.kickOrder=nil
        elseif player.hold.name then mino.hold(player)
        else C.piece,C.name=nil,nil end
        if #player.next<=player.preview then mino.insertNextQueue(player) end
        player.MTimer,player.DTimer=min(player.MTimer,S.ctrl.ASD),min(player.DTimer,S.ctrl.SD_ASD)

        if player.FDelay==0 then mino.Ins20GDrop(player) end
        if mino.rule.onPieceEntry then mino.rule.onPieceEntry(player) end
        if C.piece then player.cur.ghostY=fLib.getGhostY(player) end

    end
    while H.O~=0 do
        H.O=B.rotate(H.piece,H.O,'L')
    end
    else error("player.hold.mode must be 'S' or 'A'") end

    player.LTimer,player.FTimer=0,0
    if C.piece then
        player.cur.ghostY=fLib.getGhostY(player)
        if player.FDelay==0 then
            if player.event[3] then mino.addEvent(player,0,'Ins20GDrop') else
            mino.Ins20GDrop(player) end
        end

        A.prePiece,A.drawPiece=T.copy(C.piece),T.copy(C.piece)
        for i=1,#A.prePiece do
            A.prePiece[i][1],A.prePiece[i][2]=A.prePiece[i][1]+C.x,A.prePiece[i][2]+C.y
        end
        for i=1,#A.drawPiece do
            A.drawPiece[i][1],A.drawPiece[i][2]=A.prePiece[i][1],A.prePiece[i][2]
        end
    end
end

local success,landed,C
mino.operate={
    initHold=function(OP)--提前hold
        mino.hold(OP) if mino.sfxPlay.hold then mino.sfxPlay.hold(OP) end
        OP.canHold=false OP.canInitHold=true
    end,
    initML=function(OP)--提前左移
        C=OP.cur
        success=not coincide(OP,-1,0)
        landed=coincide(OP,0,-1)
        if success then
            C.x=C.x-1 C.moveSuccess=true C.spin=false
            OP.cur.ghostY=fLib.getGhostY(OP)
        end
        OP.moveDir='L'
        if S.keyDown.MR then OP.MTimer=0 end
        if mino.sfxPlay.move then mino.sfxPlay.move(OP,success,landed) end
        OP.canInitMove=true
    end,
    initMR=function(OP)--提前右移
        C=OP.cur
        success=not coincide(OP,1,0)
        landed=coincide(OP,0,-1)
        if success then
            C.x=C.x+1 C.moveSuccess=true C.spin=false
            OP.cur.ghostY=fLib.getGhostY(OP)
        end
        OP.moveDir='R'
        if S.keyDown.ML then OP.MTimer=0 end
        if mino.sfxPlay.move then mino.sfxPlay.move(OP,success,landed) end
        OP.canInitMove=true
    end,
    initRotateCW=function(OP)--提前顺时针旋转
        C=OP.cur
        C.kickOrder=fLib.kick(OP,'R')
        if C.kickOrder then OP.cur.ghostY=fLib.getGhostY(OP)
            C.moveSuccess=true
            if mino.rule.allowSpin[C.name] then C.spin,C.mini=SC[mino.rule.spinType](OP)
                if not mino.rule.enableMiniSpin then C.mini=false end
            else C.spin,C.mini=false,false end
        end
        OP.canInitRotate=true

        if mino.sfxPlay.rotate then mino.sfxPlay.rotate(OP,C.kickOrder,C.spin) end
    end,
    initRotateCCW=function(OP)--提前逆时针旋转
        C=OP.cur
        C.kickOrder=fLib.kick(OP,'L')
        if C.kickOrder then OP.cur.ghostY=fLib.getGhostY(OP)
            C.moveSuccess=true
            if mino.rule.allowSpin[C.name] then C.spin,C.mini=SC[mino.rule.spinType](OP)
                if not mino.rule.enableMiniSpin then C.mini=false end
            else C.spin,C.mini=false,false end
        end
        OP.canInitRotate=true

        if mino.sfxPlay.rotate then mino.sfxPlay.rotate(OP,C.kickOrder,C.spin) end
    end,
    initRotate180=function(OP)--提前180°旋转
        C=OP.cur
        C.kickOrder=fLib.kick(OP,'F')
        if C.kickOrder then OP.cur.ghostY=fLib.getGhostY(OP)
            C.moveSuccess=true
            if mino.rule.allowSpin[C.name] then C.spin,C.mini=SC[mino.rule.spinType](OP)
                if not mino.rule.enableMiniSpin then C.mini=false end
            else C.spin,C.mini=false,false end
        end
        OP.canInitRotate=true

        if mino.sfxPlay.rotate then mino.sfxPlay.rotate(OP,C.kickOrder,C.spin) end
    end,

    --landed=coincide(OP,0,-1)
    ML=function(OP,playSFX)--左移
        success=not coincide(OP,-1,0)
        landed=coincide(OP,0,-1)
        C=OP.cur
        if success then mino.setAnimPrePiece(OP) OP.smoothAnim.timer=mino.smoothTime
            C.x=C.x-1 C.moveSuccess=true C.spin=false
            if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end
            OP.cur.ghostY=fLib.getGhostY(OP)
        else  end
        OP.moveDir='L'
        if S.keyDown.MR then OP.MTimer=0 end

        if playSFX and mino.sfxPlay.move then mino.sfxPlay.move(OP,success,landed) end
    end,
    MR=function(OP,playSFX)--右移
        success=not coincide(OP,1,0)
        landed=coincide(OP,0,-1)
        C=OP.cur
        if success then mino.setAnimPrePiece(OP) OP.smoothAnim.timer=mino.smoothTime
            C.x=C.x+1 C.moveSuccess=true C.spin=false
            if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end
            OP.cur.ghostY=fLib.getGhostY(OP)
        else  end
        OP.moveDir='R'
        if S.keyDown.ML then OP.MTimer=0 end

        if playSFX and mino.sfxPlay.move then mino.sfxPlay.move(OP,success,landed) end
    end,
    rotateCW=function(OP,playSFX)--顺时针旋转
        landed=coincide(OP,0,-1)
        mino.setAnimPrePiece(OP)
        C=OP.cur
        C.kickOrder=fLib.kick(OP,'R')
        if C.kickOrder then OP.smoothAnim.timer=mino.smoothTime
            OP.cur.ghostY=fLib.getGhostY(OP)
            C.moveSuccess=true
            if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1
            else if C.kickOrder~=1 then OP.LDR=OP.LDR-1 end
            end
            if mino.rule.allowSpin[C.name] then C.spin,C.mini=SC[mino.rule.spinType](OP)
                if not mino.rule.enableMiniSpin then C.mini=false end
            else C.spin,C.mini=false,false end
        end

        if playSFX and mino.sfxPlay.rotate then mino.sfxPlay.rotate(OP,C.kickOrder,C.spin) end
    end,

    rotateCCW=function(OP,playSFX)--顺时针旋转
        landed=coincide(OP,0,-1)
        mino.setAnimPrePiece(OP)
        C=OP.cur
        C.kickOrder=fLib.kick(OP,'L')
        if C.kickOrder then OP.smoothAnim.timer=mino.smoothTime
            OP.cur.ghostY=fLib.getGhostY(OP)
            C.moveSuccess=true
            if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1
            else if C.kickOrder~=1 then OP.LDR=OP.LDR-1 end
            end
            if mino.rule.allowSpin[C.name] then C.spin,C.mini=SC[mino.rule.spinType](OP)
                if not mino.rule.enableMiniSpin then C.mini=false end
            else C.spin,C.mini=false,false end
        end

        if playSFX and mino.sfxPlay.rotate then mino.sfxPlay.rotate(OP,C.kickOrder,C.spin) end
    end,
    rotate180=function(OP,playSFX)--180°旋转
        landed=coincide(OP,0,-1)
        mino.setAnimPrePiece(OP)
        C=OP.cur
        C.kickOrder=fLib.kick(OP,'F')
        if C.kickOrder then OP.smoothAnim.timer=mino.smoothTime
            OP.cur.ghostY=fLib.getGhostY(OP)
            C.moveSuccess=true
            if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1
            else if C.kickOrder~=1 then OP.LDR=OP.LDR-1 end
            end
            if mino.rule.allowSpin[C.name] then C.spin,C.mini=SC[mino.rule.spinType](OP)
                if not mino.rule.enableMiniSpin then C.mini=false end
            else C.spin,C.mini=false,false end
        end

        if playSFX and mino.sfxPlay.rotate then mino.sfxPlay.rotate(OP,C.kickOrder,C.spin) end
    end,

    HD=function(OP,isStacker)--硬降
        C=OP.cur

        local his=OP.history

        local xmin,xmax,ymin,ymax=B.edge(C.piece)
        local xlist=B.getX(C.piece)
        local smoothFall=(mino.smoothAnimAct and OP.FTimer/OP.FDelay or 0)

        his.dropHeight=0
        if C.piece and #C.piece~=0 then
            for h=1,C.y do
                if not coincide(OP,0,-1) then C.spin=false
                    C.y=C.y-1  his.dropHeight=his.dropHeight+1
                end
            end

            local die=mino.checkDie(OP)
            mino.blockLock(OP,mino)
            if die then mino.die(OP,isStacker) end
        end

        local animTTL=mino.blockSkin.setDropAnimTTL and mino.blockSkin.setDropAnimTTL(OP,mino) or .5
        for j=1,#xlist do
            local lmax=ymax
            while not T.include(his.piece,{xlist[j],lmax}) do
                lmax=lmax-1
            end
            OP.dropAnim[#OP.dropAnim+1]={
                x=his.x+xlist[j],y=his.y+his.dropHeight-smoothFall+lmax,len=-smoothFall+his.dropHeight,
                TMax=animTTL,TTL=animTTL, w=xmax-xmin+1,h=ymax-ymin+1,
                color=OP.color[his.name]
            }
        end

        if S.winState==0 then
            if (#OP.loosen==0 or OP.loosen.fallTPL==0) then
                if OP.EDelay==0 and OP.CDelay==0 then mino.nextIns(OP)
                    else mino.addEvent(OP,OP.EDelay,'nextIns')
                end
            end
        end
    end,
    SD=function(OP,playSFX)--软降
        C=OP.cur
        if S.ctrl.SD_ASD==0 and S.ctrl.SD_ASP==0 then
            while not coincide(OP,0,-1) do local h=0
                mino.setAnimPrePiece(OP) OP.smoothAnim.timer=mino.smoothTime
                C.y=C.y-1 h=h+1 C.spin=false
                if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
            end
        elseif not coincide(OP,0,-1) then
            mino.setAnimPrePiece(OP) OP.smoothAnim.timer=mino.smoothTime
            C.y=C.y-1 C.spin=false
            if playSFX and mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
        end
        mino.sfxPlay.touch(OP,coincide(OP,0,-1))
    end,
    SD_drop=function(OP,playSFX)--软降到底
        C=OP.cur
        while not coincide(OP,0,-1) do local h=0
            mino.setAnimPrePiece(OP) OP.smoothAnim.timer=mino.smoothTime
            C.y=C.y-1 h=h+1 C.spin=false
            if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
        end
        mino.sfxPlay.touch(OP,coincide(OP,0,-1))
    end,
    SD1H=function(OP,playSFX)--软降一格
        C=OP.cur
        if not coincide(OP,0,-1) then
            mino.setAnimPrePiece(OP) OP.smoothAnim.timer=mino.smoothTime
            C.y=C.y-1 C.spin=false
            if playSFX and mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
        end
        mino.sfxPlay.touch(OP,coincide(OP,0,-1))
    end,
    hold=function(OP,playSFX)--暂存
        mino.hold(OP) if playSFX and mino.sfxPlay.hold then mino.sfxPlay.hold(OP) end
        OP.canHold=false
    end
}

function mino.loosenDrop(player)
    local his,delay=player.history,mino.rule.loosen.fallTPL
    fLib.loosenFall(player)
    if player.loosen[1] then mino.addEvent(player,delay,'loosenDrop')
    else his.line,his.PC,his.clearLine=fLib.lineClear(player)
        mino.checkClear(player,true) mino.sfxPlay.clear(player)
        if mino.rule.postCheckClear then mino.rule.postCheckClear(player,mino) end
        if his.line>0 then
            if mino.rule.onLineClear then mino.rule.onLineClear(player,mino) end
            if mino.blockSkin.onLineClear then mino.blockSkin.onLineClear(player,mino) end
        end
        if mino.rule.afterPieceDrop then mino.rule.afterPieceDrop(player,mino) end
        mino.addEvent(player,player.EDelay,'nextIns')
    end
end

function mino.addEvent(player,time,thing)
    player.event[#player.event+1]=time player.event[#player.event+1]=thing
end
function mino.addStackerEvent(time,thing)
   mino.stacker.event[#mino.stacker.event+1]=time mino.stacker.event[#mino.stacker.event+1]=thing
end
local C,H,A
function mino.setAnimPrePiece(player)
    if not mino.smoothAnimAct then return end
    C,A=player.cur,player.smoothAnim
    for i=1,#C.piece do
        A.prePiece[i][1]=M.lerp(C.piece[i][1]+C.x,A.prePiece[i][1],A.timer/mino.smoothTime)
        A.prePiece[i][2]=M.lerp(C.piece[i][2]+C.y-(player.FDelay==0 and 0 or player.FTimer/player.FDelay),A.prePiece[i][2],A.timer/mino.smoothTime)
    end
end
function mino.setAnimDrawPiece(player)
    if not mino.smoothAnimAct then return end
    C,A=player.cur,player.smoothAnim
    for i=1,#C.piece do
        A.drawPiece[i][1]=M.lerp(C.piece[i][1]+C.x,A.prePiece[i][1],A.timer/mino.smoothTime)
        A.drawPiece[i][2]=M.lerp(C.piece[i][2]+C.y-(player.FDelay==0 and 0 or player.FTimer/player.FDelay),A.prePiece[i][2],A.timer/mino.smoothTime)
    end
end
function mino.insertNextQueue(player)
    local n--这个值表示新的next从第几个预览块开始
    local rong=mino.rule.onNextGen
    if mino.seqSync then
        mino.publicPlayer.next={}
        NG[mino.seqGenType](mino.bag,mino.publicPlayer,mino.publicPlayer.seqGen.buffer)
        for k,v in pairs(mino.player) do
            n=#v.next+1
            for i=1,#mino.publicPlayer.next do
                table.insert(v.next,mino.publicPlayer.next[i])
            end
            if rong then rong(v,n,mino) end
        end
    else
        n=#player.next+1
        NG[mino.seqGenType](mino.bag,player,player.seqGen.buffer)
        if rong then rong(player,n,mino) end
    end
    player.seqGen.count=player.seqGen.count+1
end



--初始化
local curPlayTxt
function mino.init()
    sfx.add({
        pauseButtonClick='sfx/general/buttonClick.wav',
        pauseButtonQuit='sfx/general/buttonQuit.wav',
    })
    mino.profile=require'profile'

    mino.endPaused=false
    mino.waitTime=2
    scene.BG=require('BG/blank')
    S.winState=0 S.started=false
    mino.resetStopMusic=true
    mino.started=false mino.paused=false mino.pauseTimer=0 mino.pauseAnimTimer=0

    mino.player={}
    P,S=mino.player,mino.stacker
    S.event={} S.newRecord=false S.endTimer=0 S.NRSFXPlayed=false
    S.keyDown={ML=false,MR=false,SD=false,CW=false,CCW=false,flip=false}
    P[1]=fLib.newPlayer()

    do
        mino.seqGenType='bag' mino.seqSync=false
        mino.bag={'Z','S','J','L','T','O','I'}


        local pf={block='pure',theme='simple',sfx='Dr Ocelot',smoothAnimAct=false,smoothTime=.05,fieldScale=1}
        T.combine(pf,file.read('conf/custom'))
        mino.fieldScale=pf.fieldScale
        mino.blockSkin=require('skin/block/'..pf.block)
        mino.theme=require('skin/theme/'..pf.theme)
        mino.smoothAnimAct=pf.smoothAnimAct
        mino.smoothTime=pf.smoothTime
        mino.sfxPlay=require('sfx/game/'..pf.sfx)
        mino.sfxPlay.addSFX()

        fLib.setRS(P[1],pf.RS)

        local vi={unableBG=false}
        T.combine(vi,file.read('conf/video'))
        mino.unableBG=vi.unableBG

        for i=1,#P do
            P[i].color={Z={.96,.16,.32},S={.48,.96,0},J={0,.64,.96},L={.96,.64,.32},T={.8,.2,.96},O={.96,.96,0},I={.16,.96,.72},
                g1={.5,.5,.5},g2={.75,.75,.75},
            }
            if fs.getInfo('conf/mino color') then T.combine(P[i].color,file.read('conf/mino color')) end
        end
    end
    S.opList={1}

    S.ctrl={ASD=.15,ASP=.03,SD_ASD=0,SD_ASP=.05}
    T.combine(S.ctrl,file.read('conf/ctrl'))

    local ks=file.read('conf/keySet')
    S.keySet=next(ks) and ks or {
        ML={'left'},MR={'right'},
        CW={'x'},CCW={'c'},flip={'d'},
        SD={'down'},HD={'up'},hold={'z'},
        R={'r'},pause={'escape','p'}
    }

    S.VKey=file.read('conf/virtualKey')
    vKey.init(S.ctrl,S.VKey.anim)
    if S.VKey.enabled then
        for ki,v in pairs(S.VKey.set) do
            print(v)
            vKey.new(ki,v)
        end
    end

    mino.rule={
        timer=0,
        allowPush={},allowSpin={T=true},spinType='default',enableMiniSpin=true,
        loosen={fallTPL=0}--TPL=Time Per Line
    }
    mino.mode=mino.modeInfo.mode
    if mino.mode and fs.getInfo('mino/mode/'..mino.mode..'.lua') then T.combine(mino.rule,require('mino/mode/'..mino.mode)) end
    if mino.rule.init then mino.rule.init(P,mino,mino.modeInfo) end

    --如果设定了多个玩家块序一致，设置一个“公共玩家”，并不位于player内
    if mino.seqSync then mino.publicPlayer=fLib.newPlayer() end

    for i=1,#P do
        while #P[i].next<3*#mino.bag do mino.insertNextQueue(P[i]) end
        for j=1,P[i].preview do --给所有玩家放上预览块
            P[i].NP[j]=T.copy(B[P[i].next[j]])
            P[i].NO[j]=mino.orient[P[i].next[j]]
            for k=1,P[i].NO[j] do
            P[i].NP[j]=B.rotate(P[i].NP[j],0,'R')
            end
        end
        if mino.blockSkin.init then mino.blockSkin.init(P[i]) end
        if mino.theme.init then mino.theme.init(P[i]) end
    end
    curPlayTxt=user.lang.game.nowPlaying..mino.musInfo

    --禁用背景就不画背景了，节省性能
    if mino.unableBG then scene.BG=require('BG/blank') end
    --三个暂停时按钮
    local ptxt=user.lang.pause
    mino.pauseTime=0
    mino.ptList={
        resume={txt=gc.newText(font.Bender,ptxt.resume)},
        retry={txt=gc.newText(font.Bender,ptxt.r)},
        quit={txt=gc.newText(font.Bender,ptxt.quit)},
    }
    local pt=mino.ptList
    for k,v in pairs(pt) do
        v.w,v.h=v.txt:getDimensions()
    end
    BUTTON.create('pause_resume',{
        x=-600,y=420,type='rect',w=400,h=100,
        draw=function(bt,t)
            if mino.paused then
            gc.setColor(.75,.75,.75,.3+t)
            gc.rectangle('fill',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.setLineWidth(3)
            gc.rectangle('line',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.draw(pt.resume.txt,0,0,0,.5,.5,pt.resume.w/2,pt.resume.h/2)
            end
        end,
        event=function()
            if mino.paused then
            sfx.play('pauseButtonClick')
            scene.cur.paused=false
            if mino.rule.pause then mino.rule.pause(mino.stacker,mino.paused) end
            end
        end
    },.2)
    BUTTON.create('pause_retry',{
        x=0,y=420,type='rect',w=400,h=100,
        draw=function(bt,t)
            if mino.paused then
            gc.setColor(.75,.75,.75,.3+t)
            gc.rectangle('fill',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.setLineWidth(3)
            gc.rectangle('line',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.draw(pt.retry.txt,0,0,0,.5,.5,pt.retry.w/2,pt.retry.h/2)
            end
        end,
        event=function()
            if mino.paused then
            sfx.play('pauseButtonClick')
            scene.dest='solo' scene.destScene=require'mino/game'
            scene.swapT=.7 scene.outT=.3
            scene.anim=function() anim.cover(.2,.4,.2,0,0,0) end
            if scene.cur.resetStopMusic then mus.stop() end
            scene.sendArg=mino.exitScene
            end
        end
    },.2)
    BUTTON.create('pause_quit',{
        x=600,y=420,type='rect',w=400,h=100,
        draw=function(bt,t)
            if mino.paused then
            gc.setColor(.75,.75,.75,.3+t)
            gc.rectangle('fill',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.setLineWidth(3)
            gc.rectangle('line',-200,-50,400,100)
            gc.setColor(1,1,1)
            gc.draw(pt.quit.txt,0,0,0,.5,.5,pt.quit.w/2,pt.quit.h/2)
            end
        end,
        event=function()
            if mino.paused then
            sfx.play('pauseButtonQuit')
            scene.dest=mino.exitScene or 'menu'
            scene.swapT=.6 scene.outT=.2
            scene.anim=function() anim.cover(.2,.4,.2,0,0,0) end
            end
        end
    },.2)
end

function mino.inputPress(k)
    --if k=='f1' then mino.profile.switch() end
    if k=='pause' then mino.paused=not mino.paused
        if mino.rule.pause then mino.rule.pause(S,mino.paused) end
        if S.event[2]=='pause' then rem(S.event,1) rem(S.event,1) end
    elseif k=='R' then
        local p=mino.paused
        scene.dest='game' scene.destScene=require('mino/game')
        scene.swapT=(p and .6 or 0) scene.outT=.2
        scene.anim=function() anim.cover(p and .2 or 0,p and .4 or 0,.2,0,0,0) end
        if mino.resetStopMusic then mus.stop() end
        scene.sendArg=mino.exitScene
    end
    if mino.paused then --nothing
    elseif mino.waitTime>0 then
        for i=1,#S.opList do
            local OP=P[S.opList[i]]--Player Operated by you
            if k=='ML' then OP.moveDir='L'
            elseif k=='MR' then OP.moveDir='R'
            end
        end
    else
    for i=1,#S.opList do
        local OP=P[S.opList[i]]
        C,A=OP.cur,OP.smoothAnim
        if OP.deadTimer<0 and S.winState==0 then
            if OP.event[1] then--提前操作
                if k=='hold' and OP.canInitHold then
                    OP.initOpQueue[#OP.initOpQueue+1]='initHold'
                    OP.canInitHold=false
                elseif k=='ML' and OP.canInitMove then
                    OP.initOpQueue[#OP.initOpQueue+1]='initML'
                    OP.canInitMove=false
                elseif k=='MR' and OP.canInitMove then
                    OP.initOpQueue[#OP.initOpQueue+1]='initMR'
                    OP.canInitMove=false

                elseif k=='CW' and OP.canInitRotate then
                    OP.initOpQueue[#OP.initOpQueue+1]='initRotateCW'
                    OP.canInitRotate=false
                elseif k=='CCW' and OP.canInitRotate then
                    OP.initOpQueue[#OP.initOpQueue+1]='initRotateCCW'
                    OP.canInitRotate=false
                elseif k=='flip' and OP.canInitRotate then
                    OP.initOpQueue[#OP.initOpQueue+1]='initRotate180'
                    OP.canInitRotate=false
                end

            else

                if     k=='ML'   then mino.operate.ML(OP,true)
                elseif k=='MR'   then mino.operate.MR(OP,true)
                elseif k=='CW'   then mino.operate.rotateCW(OP,true)
                elseif k=='CCW'  then mino.operate.rotateCCW(OP,true)
                elseif k=='flip' then mino.operate.rotate180(OP,true)
                elseif k=='HD'   then mino.operate.HD(OP,true)
                elseif k=='SD'   then mino.operate.SD(OP,true)
                elseif k=='hold' and OP.canHold then mino.operate.hold(OP,true)
                end
                print(mino.rule.enableMiniSpin)

                --推土机！
                if mino.rule.allowPush[C.name] and C.kickOrder then
                    local rotate=k=='CW' or k=='CCW' or k=='flip'
                    local reset=true local lBlock,push
                    if OP.moveDir=='R' and S.keyDown.MR and coincide(OP,1,0) then
                        if rotate then reset=false
                        OP.pushAtt=OP.pushAtt+1 lBlock,push=fLib.pushField(OP,'R')
                        if push then mino.operate.MR(OP,true) end
                        end
                    end
                    if OP.moveDir=='L' and S.keyDown.ML and coincide(OP,-1,0) then
                        if rotate then reset=false
                        OP.pushAtt=OP.pushAtt+1 lBlock,push=fLib.pushField(OP,'L')
                        if push then mino.operate.ML(OP,true) end
                        end
                    end
                    if S.keyDown.SD and coincide(OP,0,-1) then
                        if rotate then reset=false
                        OP.pushAtt=OP.pushAtt+1 lBlock,push=fLib.pushField(OP,'D')
                        if push then mino.operate.SD1H(OP,true) end
                        end
                    end
                    if reset then OP.pushAtt=0 end

                    if lBlock and #lBlock>0 then
                        if mino.sfxPlay.loose then mino.sfxPlay.loose(OP) end
                        if mino.blockSkin.onLoose then mino.blockSkin.onLoose(OP,lBlock) end
                    end
                    if push then
                        OP.cur.ghostY=fLib.getGhostY(OP)
                        if mino.sfxPlay.push then mino.sfxPlay.push(OP) end
                    end
                end

                --最高下落速度
                if not k=='HD' and OP.FDelay==0 then
                    local h=0
                    while not coincide(OP,0,-1) do C.y=C.y-1 h=h+1 C.spin=false end
                    if h>0 then mino.sfxPlay.touch(OP,true) end
                end

                --给皮肤传按键事件
                local keyAct
                for key,v in pairs(S.keySet) do
                    if k==key then keyAct=key break end
                end
                if keyAct then
                    if mino.theme.keyP then mino.theme.keyP(P[i],keyAct,mino) end
                    if mino.blockSkin.keyP then mino.blockSkin.keyP(P[i],keyAct,mino) end
                end
            end
        end

    end--for
    end--if-else
end

function mino.inputRelease(k)
    local key=S.keySet
    for i=1,#S.opList do
        local OP=P[S.opList[i]]
        if k=='ML' then
            if S.keyDown.MR then OP.MTimer=0 OP.moveDir='R' end
        elseif k=='MR' then
            if S.keyDown.ML then OP.MTimer=0 OP.moveDir='L' end
        end
    end
end

function mino.mouseP(x,y,button,istouch)
    BUTTON.press(x,y)
end
function mino.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
end

function mino.keyP(k)
    for ki,v in pairs(S.keySet) do
        if T.include(v,k) then mino.inputPress(ki) end
    end
end
function mino.keyR(k)
    for ki,v in pairs(S.keySet) do
        if T.include(v,k) then mino.inputRelease(ki) end
    end
end
function mino.touchP(id,x,y)
    mino.inputPress(vKey.press(id,x,y))
    mino.mouseP(x,y)
end
function mino.touchR(id,x,y)
    mino.inputRelease(vKey.release(id,x,y))
    mino.mouseR(x,y)
end

local cxk,remainTime
function mino.gameUpdate(dt)
    cxk=S.ctrl
    remainTime=0

    for i=1,#S.opList do
        local OP=P[S.opList[i]]
        C,A=OP.cur,OP.smoothAnim
        local his=OP.history

        if OP.event[1] then OP.MTimer=min(OP.MTimer+dt,cxk.ASD)
        elseif S.winState==0 and canop then
        --长按移动键
        if S.keyDown.SD then
            if OP.event[1] or coincide(OP,0,-1) then OP.DTimer=min(OP.DTimer+dt,cxk.SD_ASD)
            else OP.DTimer=OP.DTimer+dt
                local m=0
                while OP.DTimer>=cxk.SD_ASD and not coincide(OP,0,-1) do
                    m=m+1
                    mino.operate.SD1H(OP,cxk.SD_ASP~=0 or m==1)
                    OP.DTimer=OP.DTimer-cxk.SD_ASP
                end
                mino.setAnimPrePiece(OP)
                OP.cur.ghostY=fLib.getGhostY(OP)
            end
        else OP.DTimer=0 end

        if S.keyDown.ML or S.keyDown.MR then OP.MTimer=OP.MTimer+dt end
        if S.keyDown.ML then local m=0
            if coincide(OP,-1,0) then OP.MTimer=min(OP.MTimer+dt,cxk.ASD) end

            while OP.MTimer>=cxk.ASD and OP.moveDir=='L' and not coincide(OP,-1,0) do
                C.x=C.x-1 C.spin=false m=m+1
                C.moveSuccess=true OP.MTimer=OP.MTimer-cxk.ASP
                if coincide(OP,0,-1) and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end

                if S.ctrl.ASP~=0 or m==1 then mino.sfxPlay.move(OP,true,coincide(OP,0,-1)) end

                if OP.FDelay==0 then
                    while not coincide(OP,0,-1) do C.y=C.y-1 end
                else
                    if S.keyDown.SD then
                    if coincide(OP,0,-1) then OP.DTimer=min(OP.DTimer+dt,cxk.SD_ASD)
                    else
                        local m=0
                        while OP.DTimer>=cxk.SD_ASD and not coincide(OP,0,-1) do
                            m=m+1
                            mino.operate.SD1H(OP,cxk.SD_ASP~=0 or m==1)
                            OP.DTimer=OP.DTimer-cxk.SD_ASP
                        end
                    end
                    else OP.DTimer=0 end
                end
                OP.cur.ghostY=fLib.getGhostY(OP)
                mino.setAnimPrePiece(OP) A.timer=mino.smoothTime
            end
        end

        if S.keyDown.MR then local m=0
            if coincide(OP,1,0) then OP.MTimer=min(OP.MTimer+dt,cxk.ASD) end

            while OP.MTimer>=cxk.ASD and OP.moveDir=='R' and not coincide(OP,1,0) do
                C.x=C.x+1 C.spin=false m=m+1
                OP.cur.ghostY=fLib.getGhostY(OP)
                C.moveSuccess=true OP.MTimer=OP.MTimer-cxk.ASP
                if coincide(OP,0,-1) and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end

                if S.ctrl.ASP~=0 or m==1 then mino.sfxPlay.move(OP,true,coincide(OP,0,-1)) end

                if OP.FDelay==0 then
                    while not coincide(OP,0,-1) do C.y=C.y-1 end
                else
                    if S.keyDown.SD then
                    if coincide(OP,0,-1) then OP.DTimer=min(OP.DTimer+dt,cxk.SD_ASD)
                    else
                        local m=0
                        while OP.DTimer>=cxk.SD_ASD and not coincide(OP,0,-1) do
                            m=m+1
                            mino.operate.SD1H(OP,cxk.SD_ASP~=0 or m==1)
                            OP.DTimer=OP.DTimer-cxk.SD_ASP
                        end
                    end
                    else OP.DTimer=0 end
                end
                mino.setAnimPrePiece(OP) A.timer=mino.smoothTime
            end
        end
        if not(S.keyDown.ML or S.keyDown.MR) then OP.MTimer=0 end
        end
    end

    for i=1,#P do
        C,A=P[i].cur,P[i].smoothAnim
        local his=P[i].history
        A.timer=max(A.timer-dt,0)
        if P[i].started and P[i].deadTimer<0 and S.winState==0 then P[i].gameTimer=P[i].gameTimer+dt end

        if P[i].event[1] then
            P[i].event[1]=P[i].event[1]-dt
            if not P[i].event[3] and P[i].event[1]<=0 then remainTime=P[i].event[1] end
            while P[i].event[1] and P[i].event[1]<=0 do
                if P[i].event[3] then P[i].event[3]=P[i].event[3]+P[i].event[1] end
                if type(P[i].event[2])=='string' then
                    if mino[P[i].event[2]] then mino[P[i].event[2]](P[i])
                    elseif fLib[P[i].event[2]] then fLib[P[i].event[2]](P[i])
                    else error("Cannot find function mino."..P[i].event[2].." or fLib."..P[i].event[2]) end
                elseif type(P[i].event[2])=='function' then P[i].event[2]()
                else error('event function error') end
                rem(P[i].event,1) rem(P[i].event,1)
            end
        elseif S.winState==0 and P[i].deadTimer<0 then
            if coincide(P[i],0,-1) then P[i].LTimer=P[i].LTimer+dt P[i].FTimer=0 else
                P[i].FTimer=P[i].FTimer+dt+remainTime remainTime=0
                while P[i].FTimer>=P[i].FDelay and not coincide(P[i],0,-1) do
                    mino.operate.SD1H(P[i],false)
                    P[i].FTimer=P[i].FTimer-P[i].FDelay
                end
            end
            if P[i].LTimer>P[i].LDelay then
                P[i].LTimer=P[i].LTimer-P[i].LDelay
                if C.piece and #C.piece~=0 then
                    his.dropHeight=0
                    local die=mino.checkDie(P[i])
                    mino.blockLock(P[i],mino)
                    if die then mino.die(P[i],T.include(S.opList,i)) end
                end

                if S.winState==0 then
                    if (#P[i].loosen==0 or P[i].loosen.fallTPL==0) then
                        if P[i].EDelay==0 and P[i].CDelay==0 then mino.nextIns(P[i])
                        else mino.addEvent(P[i],P[i].EDelay,'nextIns') end
                    end
                end
                P[i].LTimer=0
            end
        end

        if P[i].deadTimer>=0 then P[i].deadTimer=P[i].deadTimer+dt end
        if P[i].winTimer>=0 then P[i].winTimer=P[i].winTimer+dt end
        if P[i].loseTimer>=0 then P[i].loseTimer=P[i].loseTimer+dt end

        if mino.rule.update and P[i].started and P[i].deadTimer<0 and S.winState==0 then mino.rule.update(P[i],dt,mino) end
        if mino.rule.always then mino.rule.always(P[i],dt,mino) end

        if mino.theme.update then mino.theme.update(P[i],dt,mino) end
        if mino.blockSkin.update then mino.blockSkin.update(P[i],dt,mino) end

        for j=#P[i].dropAnim,1,-1 do
            P[i].dropAnim[j].TTL=P[i].dropAnim[j].TTL-dt
            if P[i].dropAnim[j].TTL<=0 then rem(P[i].dropAnim,j) end
        end
    end
    if mino.rule.gameUpdate and S.winState==0 then mino.rule.gameUpdate(P,dt,mino) end
end
function mino.BGUpdate(dt)
    if not mino.unableBG then
        if mino.rule.BGUpdate then mino.rule.BGUpdate(S,dt)
        elseif scene.BG.update then scene.BG.update(dt) end
    end
end

function mino.update(dt)
    if not (love.window.hasFocus() or mino.paused) then mino.paused=true
        if mino.rule.pause then mino.rule.pause(S,mino.paused) end
    end
    if mino.paused then BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
        mino.pauseTimer=mino.pauseTimer+dt mino.pauseAnimTimer=min(mino.pauseAnimTimer+dt,.25)
    else mino.pauseAnimTimer=max(mino.pauseAnimTimer-dt,0)
        mino.waitTime=mino.waitTime-dt

        for ki,v in pairs(S.keyDown) do
            S.keyDown[ki]=love.keyboard.isDown(S.keySet[ki]) or vKey.checkActive(ki)
        end
        vKey.update(dt)
        if mino.waitTime<=0 then mino.gameUpdate(dt)
            if not S.started then
                S.started=true
                if mino.sfxPlay.start then mino.sfxPlay.start() end
                if mino.rule.start then mino.rule.start(P,mino) end
            end
        else
            for i=1,#S.opList do local OP=P[S.opList[i]]
                if S.keyDown.ML or S.keyDown.MR then
                    OP.MTimer=min(OP.MTimer+dt,S.ctrl.ASD)
                else OP.MTimer=0 end
            end
        end

        if S.event[1] then
            S.event[1]=S.event[1]-dt
            while S.event[1] and S.event[1]<=0 do
                if S.event[3] then S.event[3]=S.event[3]+S.event[1] end
                if type(S.event[2])=='string' then
                    if mino[S.event[2]] then mino[S.event[2]](S)
                    else error("Cannot find function mino."..S.event[2]) end
                elseif type(S.event[2])=='function' then S.event[2]()
                else error('stacker event function error') end
                rem(S.event,1) rem(S.event,1)
            end
        end

        if S.winState~=0 then S.endTimer=S.endTimer+dt
            if S.newRecord and (not S.NRSFXPlayed) and S.endTimer>=mino.theme.NRSFXDelay and mino.sfxPlay.newRecord then
                mino.sfxPlay.newRecord()
                S.NRSFXPlayed=true
            end
        end
    end
    vKey.animUpdate(dt)
end

function mino.draw()
    if mino.unableBG then gc.setColor(.06,.06,.06)
    gc.rectangle('fill',-1000,-600,2000,1200) end

    if mino.rule.underAllDraw then mino.rule.underAllDraw(P,mino) end
    for i=#P,1,-1 do
        C,H,A=P[i].cur,P[i].hold,P[i].smoothAnim

        gc.push()
            gc.translate(P[i].posx,P[i].posy)
            gc.scale(P[i].scale*mino.fieldScale)
            --场地
            if mino.rule.underFieldDraw then mino.rule.underFieldDraw(P[i],mino) end

            mino.theme.fieldDraw(P[i],mino)
            --垃圾槽
            if P[i].garbage then mino.theme.garbageDraw(P[i],mino) end

            if mino.rule.underStackDraw then mino.rule.underStackDraw(P[i],mino) end

            gc.push()
            gc.translate(-18*P[i].w-18,18*P[i].h+18)
            --硬降特效
            if mino.blockSkin.dropAnim then mino.blockSkin.dropAnim(P[i],mino) end
            --场地上的块&方块拖尾&消行特效
            mino.blockSkin.fieldDraw(P[i],mino)
            --松动块
            mino.blockSkin.loosenDraw(P[i],mino)

            if C.piece and #C.piece~=0 then
                --投影
                mino.blockSkin.ghostDraw(P[i],C.piece,C.x,P[i].cur.ghostY,P[i].color[C.name])
                --手上拿的
                if mino.smoothAnimAct then
                    mino.setAnimDrawPiece(P[i])
                    mino.blockSkin.curDraw(P[i],A.drawPiece,0,0,P[i].color[C.name])
                else mino.blockSkin.curDraw(P[i],C.piece,C.x,C.y,P[i].color[C.name]) end
            end

            --暂存块（浮空）
            if H.name and H.mode=='A' then gc.push()
                local holdColor=P[i].color[H.name]
                gc.setColor(holdColor[1],holdColor[2],holdColor[3],.5)
                gc.translate(36*H.x,-36*H.y)
                for k=1,#H.piece do mino.blockSkin.unitDraw(H.piece[k][1],H.piece[k][2],P[i].color[H.name]) end
            gc.pop() end

            if mino.blockSkin.overFieldDraw then mino.blockSkin.overFieldDraw(P[i],mino) end

            gc.pop()

            local w,h,x,y, s
            --暂存块（标准）
            if H.name and H.mode=='S' then gc.push()
                local holdColor=P[i].color[H.name]
                w,h,x,y=B.size(H.piece)
                s=min((w/h>2 and 4/w or 2.5/h),1)
                gc.translate(-18*P[i].w-90-20,-310)
                gc.scale(s)
                mino.blockSkin.holdDraw(P[i],H.piece,x,y,P[i].color[H.name],P[i].canHold)
            gc.pop() end

            --预览
            for j=1,#P[i].NP do
                w,h,x,y=B.size(P[i].NP[j])
                s=min((w/h>2 and 4/w or 2.5/h),1)
                gc.push('transform')
                    gc.translate(18*P[i].w+90+20,-410+100*j)
                    gc.scale(s)
                    mino.blockSkin.nextDraw(P[i],P[i].NP[j],x,y,P[i].color[P[i].next[j]])
                gc.pop()
            end

            if mino.theme.overFieldDraw then mino.theme.overFieldDraw(P[i],mino) end
            --消行文本
            mino.theme.clearTextDraw(P[i])

            if mino.rule.overFieldDraw then mino.rule.overFieldDraw(P[i],mino) end
            --Ready Set Go
            if mino.theme.readyDraw then mino.theme.readyDraw(mino.waitTime) end
            --诶你怎么死了
            if P[i].deadTimer>=0 and mino.theme.dieAnim then mino.theme.dieAnim(P[i],S,mino) end
            --赢了
            if P[i].winTimer>=0 and mino.theme.winAnim then mino.theme.winAnim(P[i],S,mino) end
            --输了
            if P[i].loseTimer>=0 and mino.theme.loseAnim then mino.theme.loseAnim(P[i],S,mino) end
        gc.pop()
    end

    vKey.draw()

    --暂停
    gc.setColor(.04,.04,.04,min(mino.pauseAnimTimer*(S.winState==0 and 4 or 2),S.winState==0 and 1 or .5))
    gc.rectangle('fill',-1000,-1000,2000,2000)
    if mino.paused then
        BUTTON.draw()
        gc.setColor(1,1,1)
        gc.printf(user.lang.modeName[mino.mode] or mino.mode,font.Bender,400,-320,4096,'right',0,.4,.4,4096,72)
        gc.printf(S.winState==0 and user.lang.game.paused or user.lang.game.result,
            font.Bender_B,0,-440,4096,'center',0,.9,.9,2048,72)
        gc.printf(curPlayTxt,font.Bender,0,330,65536,'center',0,.4,.4,32768,72)
    end
end
function mino.exit()
    if mino.rule.exit then mino.rule.exit() end
    mino.musInfo=""
    mino.exitScene=nil
    scene.sendArg=nil
    --mino.mode=nil
end
function mino.send(destScene,arg)
    destScene.exitScene=arg
end
return mino