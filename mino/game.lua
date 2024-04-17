---@diagnostic disable: deprecated
--[[
    stacker是你自己，player存储的是“玩家”的所有信息。
    stacker是可以操控多个player的。stacker.opList存储着你所操控的player序号。
]]

local gc=love.graphics
local fs=love.filesystem

local T,M=mytable,mymath

local fLib=require'mino/fieldLib'
local coincide=fLib.coincide
local B=require'mino/blocks'
local NG=require'mino/nextGen'
local SC=require'mino/spinCheck'

local pause=require'mino/special/pause'
--math.randomseed(os.time())

local mino={
    endPaused=false,
    exitScene=nil,resetStopMusic=true,unableBG=false,
    mode='',musInfo="",
    sfxPlay=nil,
    rule={
        timer=0,
        allowPush={},allowSpin={T=true},spinType='default',loosen={fallTPL=0}--TPL=Time Per Line
    },
    started=false, paused=false,pauseTimer=0,
    stacker={
        keySet={},ctrl={},opList={1},event={},
        dieAnim=function() end,
        winState=0,started=false
    },
    seqGenType='bag',
    bag={'Z','S','J','L','T','O','I'},orient={Z=0,S=0,J=0,L=0,T=0,O=0,I=0},
    player={},
    fieldScale=1,
}
local P,S=mino.player,mino.stacker

function mino.start(player) end
function mino.pause(player)
    mino.paused=true
end
function mino.freeze(player)
    --啥事不做，单纯的不让玩家操作
end
function mino.blockLock(player)
    local his=player.history
    fLib.lock(player) fLib.loosenFall(player) mino.sfxPlay.lock(player)
    if mino.rule.postCheckClear then mino.rule.postCheckClear(player,mino) end
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
        if his.line>0 and mino.rule.onLineClear then mino.rule.onLineClear(player,mino) end
    end
    if mino.rule.onPieceDrop then mino.rule.onPieceDrop(player,mino) end

    if mino.blockSkin.onPieceDrop then player.blockSkin.onPieceDrop(player,mino) end
    if mino.theme.onPieceDrop then mino.theme.onPieceDrop(player,mino) end
end

function mino.win(player)
    local w=S.winState
    S.winState=1 player.winTimer=0 if mino.sfxPlay.win then mino.sfxPlay.win() end
    if w~=1 then mino.addStackerEvent(1.5,'pause') end
end
function mino.lose(player)
    local w=S.winState
    S.winState=-1 player.loseTimer=0 if mino.sfxPlay.lose then mino.sfxPlay.lose() end
    if w~=-1 then mino.addStackerEvent(1.5,'pause') end
end
function mino.die(player,isStacker)
    player.deadTimer=0 if mino.sfxPlay.die then mino.sfxPlay.die() end
    if isStacker then
        if mino.rule.onDie then mino.rule.onDie(player,mino)
        else mino.lose(player) end
    end
end
function mino.revive(player,isStacker)
    
end
function mino.checkDie(player,isStacker)
    if coincide(player) then mino.die(player,isStacker) end
end
function mino.Ins20GDrop(player)
    while not coincide(player,0,-1) do player.cur.y=player.cur.y-1 end
    if mino.sfxPlay.touch then mino.sfxPlay.touch(player,true) end
end
function mino.operate(player,cmd)--准备重构整个操作流程
end
function mino.curIns(player)
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
    his.line=0 his.spin=false his.mini=false his.dropHeight=0
    if player.next[1] then
        C.x,C.y=ceil(player.w/2)+B.Soff[player.next[1]][1],player.h+1+B.Soff[player.next[1]][2]
        C.piece=table.remove(player.NP,1)
        A.prePiece,A.drawPiece=T.copy(C.piece),T.copy(C.piece)
        for i=1,#A.prePiece do
            A.prePiece[i][1],A.prePiece[i][2]=A.prePiece[i][1]+C.x,A.prePiece[i][2]+C.y
            A.drawPiece[i][1],A.drawPiece[i][2]=A.drawPiece[i][1]+C.x,A.drawPiece[i][2]+C.y
        end
        C.O=table.remove(player.NO,1)
        C.name=table.remove(player.next,1)
        player.canHold=true C.kickOrder=nil
    elseif player.hold.name then mino.hold(player)
    else C.piece,C.name=nil,nil end
    if C.piece then player.cur.ghostY=fLib.getGhostY(player) end
    if #player.next<=21 then NG[mino.seqGenType](mino.bag,player.next) end
    player.MTimer,player.DTimer=min(player.MTimer,S.ctrl.ASD),min(player.DTimer,S.ctrl.SD_ASD)
    player.LDR=player.LDRInit player.LTimer=0

    for i=1,#player.initOpQueue do player.initOpQueue[i]() end  player.initOpQueue={}
    if player.FDelay==0 then
        if player.event[3] then mino.addEvent(player,0,'Ins20GDrop') else
        mino.Ins20GDrop(player) end
    end
    player.started=true
    if mino.rule.onPieceEnter then mino.rule.onPieceEnter(player) end
end
function mino.checkClear(player,comboBreak,delayBreak)
    local his=player.history
    
    if his.line>0 then
        if delayBreak or player.CDelay==0 then fLib.eraseEmptyLine(player)
        else mino.addEvent(player,player.CDelay,'eraseEmptyLine') end
        his.combo=his.combo+1
        his.B2B=(his.spin or his.line>=4) and his.B2B+1 or -1
        his.CDelay=player.CDelay
    elseif comboBreak then his.combo=0 end
    his.wide=fLib.wideDetect(player)
    if mino.theme.updateClearInfo then mino.theme.updateClearInfo(player,mino) end
end

function mino.hold(player)
    local H,C,A=player.hold,player.cur,player.smoothAnim
    H.name,C.name=C.name,H.name  H.piece,C.piece=C.piece,H.piece  H.O,C.O=C.O,H.O
    if player.hold.mode=='A' then
        H.x,H.y,C.x,C.y=C.x,C.y,H.x,H.y
        while C.piece and coincide(player) and C.y<player.h+B.Soff[C.name][2] do C.y=C.y+1 end
    elseif player.hold.mode=='S' then
    if C.name then
        C.x,C.y=ceil(player.w/2)+B.Soff[C.name][1],player.h+1+B.Soff[C.name][2]
        C.O=mino.orient[C.name]
        A.prePiece=T.copy(C.piece)
        for i=1,#A.prePiece do
            A.prePiece[i][1],A.prePiece[i][2]=A.prePiece[i][1]+C.x,A.prePiece[i][2]+C.y
        end
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
    end
end

function mino.loosenDrop(player)
    local his,delay=player.history,mino.rule.loosen.fallTPL
    fLib.loosenFall(player)
    if player.loosen[1] then mino.addEvent(player,delay,'loosenDrop')
    else his.line,his.PC,his.clearLine=fLib.lineClear(player)
        mino.checkClear(player,true) mino.sfxPlay.clear(player)
        if his.line>0 and mino.rule.onLineClear then mino.rule.onLineClear(player,mino) end
        if mino.rule.onPieceDrop then mino.rule.onPieceDrop(player,mino) end
        mino.addEvent(player,player.EDelay,'curIns')
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
    if not player.smoothAnimAct then return end
    C,A=player.cur,player.smoothAnim
    for i=1,#C.piece do
        A.prePiece[i][1]=M.lerp(C.piece[i][1]+C.x,A.prePiece[i][1],A.timer/A.delay)
        A.prePiece[i][2]=M.lerp(C.piece[i][2]+C.y-(player.FDelay==0 and 0 or player.FTimer/player.FDelay),A.prePiece[i][2],A.timer/A.delay)
    end
end
function mino.setAnimDrawPiece(player)
    if not player.smoothAnimAct then return end
    C,A=player.cur,player.smoothAnim
    for i=1,#C.piece do
        A.drawPiece[i][1]=M.lerp(C.piece[i][1]+C.x,A.prePiece[i][1],A.timer/A.delay)
        A.drawPiece[i][2]=M.lerp(C.piece[i][2]+C.y-(player.FDelay==0 and 0 or player.FTimer/player.FDelay),A.prePiece[i][2],A.timer/A.delay)
    end
end
function mino.addDropAnim(player,x,ys,yf,TTL)
    player.dropAnim[#player.dropAnim+1]={x=x,ys=ys,yf=yf,TTL=TTL,TMax=TTL}
end

--初始化
local curPlayTxt
function mino.init()
    mino.profile=require'profile'

    pause.init(mino)
    mino.endPaused=false
    mino.waitTime=2
    scene.BG=require('BG/blank')
    S.winState=0 S.started=false
    mino.resetStopMusic=true
    mino.started=false mino.paused=false mino.pauseTimer=0 mino.pauseAnimTimer=0

    mino.player={}
    P,S=mino.player,mino.stacker
    S.event={}
    P[1]=fLib.newPlayer()

    do
        local pf=fs.getInfo('conf/custom') and json.decode(fs.newFile('conf/custom'):read()) or
        {block='pure',theme='simple',sfx='Dr Ocelot',smoothAnimAct=false,fieldScale=1}
        mino.fieldScale=pf.fieldScale
        mino.blockSkin=require('skin/block/'..pf.block)
        mino.theme=require('skin/theme/'..pf.theme)
        P[1].smoothAnimAct=pf.smoothAnimAct
        mino.sfxPlay=require('sfx/game/'..pf.sfx)
        mino.sfxPlay.addSFX()

        local vi=json.decode(fs.newFile('conf/video'):read()) or {unableBG=false}
        mino.unableBG=vi.unableBG

        for i=1,#P do
            P[i].color={Z={1,.16,.32},S={.5,.96,.04},J={0,.64,1},L={.99,.66,.33},T={.8,.2,1},O={1,1,0},I={.15,1,.75},
                g1={.5,.5,.5},g2={.75,.75,.75},
            }
            if fs.getInfo('conf/mino color') then T.combine(P[i].color,json.decode(fs.newFile('conf/mino color'):read())) end
        end
    end
    S.opList={1}
    S.keySet=fs.getInfo('conf/keySet') and json.decode(fs.newFile('conf/keySet'):read()) or
    {
        ML={'left'},MR={'right'},
        CW={'x'},CCW={'c'},flip={'d'},
        SD={'down'},HD={'up'},hold={'z'},
        R={'r'},pause={'escape','p'}
    }
    S.ctrl=fs.getInfo('conf/ctrl') and json.decode(fs.newFile('conf/ctrl'):read()) or
    {ASD=.15,ASP=.03,SD_ASD=0,SD_ASP=.05}
    mino.rule={
        timer=0,
        allowPush={},allowSpin={T=true},spinType='default',loosen={fallTPL=0}--TPL=Time Per Line
    }
    if mino.mode and fs.getInfo('mino/rule/'..mino.mode..'.lua') then T.combine(mino.rule,require('mino/rule/'..mino.mode)) end
    if mino.rule.init then mino.rule.init(P,mino) end

    for i=1,#P do
        while #P[i].next<3*#mino.bag do NG[mino.seqGenType](mino.bag,P[i].next) end
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
end

local success
function mino.keyP(k)
    --if k=='f1' then mino.profile.switch() end
    if T.include(S.keySet.pause,k) then mino.paused=not mino.paused
        if mino.rule.pause then mino.rule.pause(S,mino.paused) end
        if S.event[2]=='pause' then rem(S.event,1) rem(S.event,1) end
    elseif T.include(S.keySet.R,k) then
        scene.dest='game' scene.destScene=require('mino/game')
        scene.swapT=(mino.paused and 1.5 or 0) scene.outT=.5
        scene.anim=mino.paused and function() anim.cover(.5,1,.5,0,0,0) end
            or function() anim.cover(0,0,.5,0,0,0) end
        if mino.resetStopMusic then mus.stop() end
        scene.sendArg=mino.exitScene
    end
    if mino.paused then --nothing
    elseif mino.waitTime>0 then
        for i=1,#S.opList do
            local OP=P[S.opList[i]]--Player Operated by you
            if T.include(S.keySet.ML,k) then OP.moveDir='L'
            elseif T.include(S.keySet.MR,k) then OP.moveDir='R'
            end
        end
    else
    for i=1,#S.opList do
        local OP=P[S.opList[i]]
        C,A=OP.cur,OP.smoothAnim
        local his=OP.history
        if OP.deadTimer<0 and S.winState==0 then
            if OP.event[1] then--提前操作
                if T.include(S.keySet.hold,k) and OP.canInitHold then
                    OP.initOpQueue[#OP.initOpQueue+1]=function ()
                        mino.hold(OP) mino.sfxPlay.hold(OP)
                    if not C.name then local LDR=OP.LDR mino.curIns(OP) OP.LDR=LDR end
                    OP.canHold=false OP.canInitHold=true
                    end
                    OP.canInitHold=false
                elseif T.include(S.keySet.ML,k) and OP.canInitMove then
                    OP.initOpQueue[#OP.initOpQueue+1]=function ()
                        success=not coincide(OP,-1,0)
                        local landed=coincide(OP,0,-1)
                        if success then
                            C.x=C.x-1 C.moveSuccess=true his.spin=false
                            OP.cur.ghostY=fLib.getGhostY(OP)
                        end
                        OP.moveDir='L'
                        if love.keyboard.isDown(S.keySet.MR) then OP.MTimer=0 end
                        mino.sfxPlay.move(OP,success,landed)
                        OP.canInitMove=true
                    end
                    OP.canInitMove=false
                elseif T.include(S.keySet.MR,k) and OP.canInitMove then
                    OP.initOpQueue[#OP.initOpQueue+1]=function ()
                        success=not coincide(OP,1,0)
                        local landed=coincide(OP,0,-1)
                        if success then
                            C.x=C.x+1 C.moveSuccess=true his.spin=false
                            OP.cur.ghostY=fLib.getGhostY(OP)
                        end
                        OP.moveDir='R'
                        if love.keyboard.isDown(S.keySet.ML) then OP.MTimer=0 end
                        mino.sfxPlay.move(OP,success,landed)
                        OP.canInitMove=true
                    end
                    OP.canInitMove=false

                elseif T.include(S.keySet.CW,k) and OP.canInitRotate then
                    OP.initOpQueue[#OP.initOpQueue+1]=function ()
                        C.kickOrder=fLib.kick(OP,'R')
                        if C.kickOrder then OP.cur.ghostY=fLib.getGhostY(OP)
                            C.moveSuccess=true
                            if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](OP)
                            else his.spin,his.mini=false,false end
                        end
                        OP.canInitRotate=true

                        mino.sfxPlay.rotate(OP,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)
                    end
                    OP.canInitRotate=false

                elseif T.include(S.keySet.CCW,k) and OP.canInitRotate then
                    OP.initOpQueue[#OP.initOpQueue+1]=function ()
                        C.kickOrder=fLib.kick(OP,'L')
                        if C.kickOrder then OP.cur.ghostY=fLib.getGhostY(OP)
                            C.moveSuccess=true
                            if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](OP)
                            else his.spin,his.mini=false,false end
                        end
                        OP.canInitRotate=true

                        mino.sfxPlay.rotate(OP,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)
                    end
                    OP.canInitRotate=false
                elseif T.include(S.keySet.flip,k) and OP.canInitRotate then
                    OP.initOpQueue[#OP.initOpQueue+1]=function ()
                        C.kickOrder=fLib.kick(OP,'F')
                        if C.kickOrder then OP.cur.ghostY=fLib.getGhostY(OP)
                            C.moveSuccess=true
                            if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](OP)
                            else his.spin,his.mini=false,false end
                        end
                        OP.canInitRotate=true

                        mino.sfxPlay.rotate(OP,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)
                    end
                    OP.canInitRotate=false
                end
            else
                local landed=coincide(OP,0,-1)
                if T.include(S.keySet.ML,k) then
                    success=not coincide(OP,-1,0)
                    if success then mino.setAnimPrePiece(OP) A.timer=A.delay
                        C.x=C.x-1 C.moveSuccess=true his.spin=false
                        if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end
                        OP.cur.ghostY=fLib.getGhostY(OP)
                    else  end
                    OP.moveDir='L'
                    if love.keyboard.isDown(S.keySet.MR) then OP.MTimer=0 end

                    mino.sfxPlay.move(OP,success,landed)

                elseif T.include(S.keySet.MR,k) then
                    success=not coincide(OP,1,0)
                    if success then mino.setAnimPrePiece(OP) A.timer=A.delay
                        C.x=C.x+1 C.moveSuccess=true his.spin=false
                        if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end
                        OP.cur.ghostY=fLib.getGhostY(OP)
                    else  end
                    OP.moveDir='R'
                    if love.keyboard.isDown(S.keySet.ML) then OP.MTimer=0 end

                    mino.sfxPlay.move(OP,success,landed)

                elseif T.include(S.keySet.CW,k) then mino.setAnimPrePiece(OP)
                    C.kickOrder=fLib.kick(OP,'R')
                    if C.kickOrder then A.timer=A.delay
                        OP.cur.ghostY=fLib.getGhostY(OP)
                        C.moveSuccess=true
                        if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1
                        else if C.kickOrder~=1 then OP.LDR=OP.LDR-1 end
                        end
                        if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](OP)
                        else his.spin,his.mini=false,false end
                    end

                    mino.sfxPlay.rotate(OP,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)

                elseif T.include(S.keySet.CCW,k) then mino.setAnimPrePiece(OP)
                    C.kickOrder=fLib.kick(OP,'L')
                    if C.kickOrder then A.timer=A.delay
                        OP.cur.ghostY=fLib.getGhostY(OP)
                        C.moveSuccess=true
                        if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1
                        else if C.kickOrder~=1 then OP.LDR=OP.LDR-1 end
                        end
                        if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](OP)
                        else his.spin,his.mini=false,false end
                    end

                    mino.sfxPlay.rotate(OP,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)

                elseif T.include(S.keySet.flip,k) then mino.setAnimPrePiece(OP)
                    C.kickOrder=fLib.kick(OP,'F')
                    if C.kickOrder then A.timer=A.delay
                        OP.cur.ghostY=fLib.getGhostY(OP)
                        C.moveSuccess=true
                        if landed and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1
                        else if C.kickOrder~=1 then OP.LDR=OP.LDR-1 end
                        end
                        if mino.rule.allowSpin[C.name] then his.spin,his.mini=SC[mino.rule.spinType](OP)
                        else his.spin,his.mini=false,false end
                    end

                    mino.sfxPlay.rotate(OP,C.kickOrder,mino.rule.allowSpin[C.name] and his.spin)

                elseif T.include(S.keySet.HD,k) then --硬降
                    local xmin,xmax,ymin,ymax=B.edge(C.piece)
                    local xlist=B.getX(C.piece)
                    local smoothFall=(OP.smoothAnimAct and OP.FTimer/OP.FDelay or 0)
                    for j=1,#xlist do
                        local lmax=ymax
                        while not T.include(C.piece,{xlist[j],lmax}) do
                            lmax=lmax-1
                        end
                        OP.dropAnim[#OP.dropAnim+1]={
                            x=C.x+xlist[j],y=C.y-smoothFall+lmax,len=-smoothFall,
                            TMax=.5,TTL=.5, w=xmax-xmin+1,h=ymax-ymin+1,
                            color=OP.color[C.name]
                        }
                    end
                    his.dropHeight=0
                    if C.piece and #C.piece~=0 then
                        for h=1,C.y do
                            if not coincide(OP,0,-1) then his.spin=false
                                C.y=C.y-1  his.dropHeight=his.dropHeight+1
                                for j=#OP.dropAnim,#OP.dropAnim-#xlist+1,-1 do
                                    OP.dropAnim[j].len=OP.dropAnim[j].len+1
                                end
                            end
                        end

                        mino.checkDie(OP,true)
                        mino.blockLock(OP,mino)
                    end

                    if S.winState==0 then
                        if (#OP.loosen==0 or OP.loosen.fallTPL==0) then
                            if OP.EDelay==0 and OP.CDelay==0 then mino.curIns(OP)
                                else mino.addEvent(OP,OP.EDelay,'curIns')
                            end
                        end
                    end

                elseif T.include(S.keySet.SD,k) then
                    if S.ctrl.SD_ASD==0 and S.ctrl.SD_ASP==0 then
                        while not coincide(OP,0,-1) do local h=0
                            mino.setAnimPrePiece(OP) A.timer=A.delay
                            C.y=C.y-1 h=h+1 his.spin=false
                            if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
                        end
                    elseif not landed then
                        mino.setAnimPrePiece(OP) A.timer=A.delay
                        C.y=C.y-1 his.spin=false
                        if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
                    end
                    mino.sfxPlay.touch(OP,coincide(OP,0,-1))

                elseif T.include(S.keySet.hold,k) and OP.canHold then
                    mino.hold(OP) mino.sfxPlay.hold(OP)
                    if not C.name then local LDR=OP.LDR mino.curIns(OP) OP.LDR=LDR end
                    OP.canHold=false
                end

                --推土机！
                if mino.rule.allowPush[C.name] and C.kickOrder then
                    local reset=true
                    if OP.moveDir=='R' and love.keyboard.isDown(S.keySet.MR) and coincide(OP,1,0) then
                        if T.include(S.keySet.CW,k) or T.include(S.keySet.CCW,k) or T.include(S.keySet.flip,k) then reset=false
                        OP.pushAtt=OP.pushAtt+1 fLib.pushField(OP,'R')
                        end
                    end
                    if OP.moveDir=='L' and love.keyboard.isDown(S.keySet.ML) and coincide(OP,-1,0) then
                        if T.include(S.keySet.CW,k) or T.include(S.keySet.CCW,k) or T.include(S.keySet.flip,k) then reset=false
                        OP.pushAtt=OP.pushAtt+1 fLib.pushField(OP,'L')
                        end
                    end
                    if love.keyboard.isDown(S.keySet.SD) and coincide(OP,0,-1) then
                        if T.include(S.keySet.CW,k) or T.include(S.keySet.CCW,k) or T.include(S.keySet.flip,k) then reset=false
                        OP.pushAtt=OP.pushAtt+1 fLib.pushField(OP,'D')
                        end
                    end
                    if reset then OP.pushAtt=0 end
                end

                --最高下落速度
                if not T.include(S.keySet.HD,k) and OP.FDelay==0 then
                    local h=0
                    while not coincide(OP,0,-1) do C.y=C.y-1 h=h+1 his.spin=false end
                    if h>0 then mino.sfxPlay.touch(OP,true) end
                end

                local keyAct
                for key,v in pairs(S.keySet) do
                    if T.include(v,k) then keyAct=key break end
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

function mino.keyR(k)
    local key=S.keySet
    for i=1,#S.opList do
        local OP=P[S.opList[i]]
        if T.include(key.ML,k) then
            if love.keyboard.isDown(key.MR) then OP.MTimer=0 OP.moveDir='R' end
        elseif T.include(key.MR,k) then
            if love.keyboard.isDown(key.ML) then OP.MTimer=0 OP.moveDir='L' end
        end
    end
end

function mino.mouseP(x,y,button,istouch)
    if mino.paused then pause.mouseP(x,y,button,istouch) end
end
local cxk,remainTime
local L,R
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
        if love.keyboard.isDown(S.keySet.SD) then
            if OP.event[1] or coincide(OP,0,-1) then OP.DTimer=min(OP.DTimer+dt,cxk.SD_ASD)
            else OP.DTimer=OP.DTimer+dt
                while OP.DTimer>=cxk.SD_ASD and not coincide(OP,0,-1) do
                    mino.setAnimPrePiece(OP) A.timer=A.delay
                    C.y=C.y-1 his.spin=false OP.DTimer=OP.DTimer-cxk.SD_ASP
                    if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
                    mino.sfxPlay.touch(OP,coincide(OP,0,-1))
                end
                mino.setAnimPrePiece(OP)
                OP.cur.ghostY=fLib.getGhostY(OP)
            end
        else OP.DTimer=0 end

        L,R=love.keyboard.isDown(S.keySet.ML),love.keyboard.isDown(S.keySet.MR)
        if L or R then OP.MTimer=OP.MTimer+dt end
        if L then local m=0
            if coincide(OP,-1,0) then OP.MTimer=min(OP.MTimer+dt,cxk.ASD) end

            while OP.MTimer>=cxk.ASD and OP.moveDir=='L' and not coincide(OP,-1,0) do
                C.x=C.x-1 his.spin=false m=m+1
                C.moveSuccess=true OP.MTimer=OP.MTimer-cxk.ASP
                if coincide(OP,0,-1) and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end

                if S.ctrl.ASP~=0 or m==1 then mino.sfxPlay.move(OP,true,coincide(OP,0,-1)) end

                if OP.FDelay==0 then
                    while not coincide(OP,0,-1) do C.y=C.y-1 end
                else
                    if love.keyboard.isDown(S.keySet.SD) then
                    if coincide(OP,0,-1) then OP.DTimer=min(OP.DTimer+dt,cxk.SD_ASD)
                    else
                        while OP.DTimer>=cxk.SD_ASD and not coincide(OP,0,-1) do
                            C.y=C.y-1 his.spin=false OP.DTimer=OP.DTimer-cxk.SD_ASP
                            if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
                            mino.sfxPlay.touch(OP,coincide(OP,0,-1))
                        end
                    end
                    else OP.DTimer=0 end
                end
                OP.cur.ghostY=fLib.getGhostY(OP)
                mino.setAnimPrePiece(OP) A.timer=A.delay
            end
        end

        if R then local m=0
            if coincide(OP,1,0) then OP.MTimer=min(OP.MTimer+dt,cxk.ASD) end

            while OP.MTimer>=cxk.ASD and OP.moveDir=='R' and not coincide(OP,1,0) do
                C.x=C.x+1 his.spin=false m=m+1
                OP.cur.ghostY=fLib.getGhostY(OP)
                C.moveSuccess=true OP.MTimer=OP.MTimer-cxk.ASP
                if coincide(OP,0,-1) and OP.LDR>0 then OP.LTimer=0 OP.LDR=OP.LDR-1 end

                if S.ctrl.ASP~=0 or m==1 then mino.sfxPlay.move(OP,true,coincide(OP,0,-1)) end

                if OP.FDelay==0 then
                    while not coincide(OP,0,-1) do C.y=C.y-1 end
                else
                    if love.keyboard.isDown(S.keySet.SD) then
                    if coincide(OP,0,-1) then OP.DTimer=min(OP.DTimer+dt,cxk.SD_ASD)
                    else
                        while OP.DTimer>=cxk.SD_ASD and not coincide(OP,0,-1) do
                            C.y=C.y-1 his.spin=false OP.DTimer=OP.DTimer-cxk.SD_ASP
                            if mino.sfxPlay.SD then mino.sfxPlay.SD(OP) end
                            mino.sfxPlay.touch(OP,coincide(OP,0,-1))
                        end
                    end
                    else OP.DTimer=0 end
                end
                mino.setAnimPrePiece(OP) A.timer=A.delay
            end
        end
        if not(L or R) then OP.MTimer=0 end
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
                    C.y=C.y-1 his.spin=false P[i].FTimer=P[i].FTimer-P[i].FDelay
                    mino.sfxPlay.touch(P[i],coincide(P[i],0,-1))
                    P[i].cur.ghostY=fLib.getGhostY(P[i])
                end
            end
            if P[i].LTimer>P[i].LDelay then
                P[i].LTimer=P[i].LTimer-P[i].LDelay
                if C.piece and #C.piece~=0 then
                    his.dropHeight=0
                    mino.checkDie(P[i],T.include(S.opList,i))
                    mino.blockLock(P[i],mino)
                end

                if S.winState==0 then
                    if (#P[i].loosen==0 or P[i].loosen.fallTPL==0) then
                        if P[i].EDelay==0 and P[i].CDelay==0 then mino.curIns(P[i])
                        else mino.addEvent(P[i],P[i].EDelay,'curIns') end
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
end
function mino.BGUpdate(dt)
    if mino.rule.BGUpdate then mino.rule.BGUpdate(S,dt)
    elseif scene.BG.update then scene.BG.update(dt) end
end

function mino.update(dt)
    if not (love.window.hasFocus() or mino.paused) then mino.paused=true
        if mino.rule.pause then mino.rule.pause(S,mino.paused) end
    end
    if mino.paused then pause.update(dt) mino.pauseTimer=mino.pauseTimer+dt mino.pauseAnimTimer=min(mino.pauseAnimTimer+dt,.25)
    else mino.pauseAnimTimer=max(mino.pauseAnimTimer-dt,0)
        mino.waitTime=mino.waitTime-dt
        if mino.waitTime<=0 then mino.gameUpdate(dt)
            if not S.started then
                S.started=true
                if mino.sfxPlay.start then mino.sfxPlay.start() end
                if mino.rule.start then mino.rule.start(P,mino) end
            end
        else
            for i=1,#S.opList do local OP=P[S.opList[i]]
                if love.keyboard.isDown(S.keySet.ML) or love.keyboard.isDown(S.keySet.MR) then
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
    end
end

function mino.draw()
    if mino.unableBG then gc.setColor(.06,.06,.06)
    gc.rectangle('fill',-1000,-600,2000,1200) end

    for i=#P,1,-1 do
        C,H,A=P[i].cur,P[i].hold,P[i].smoothAnim

        gc.push()
            gc.translate(P[i].posx,P[i].posy)
            gc.scale(P[i].scale*mino.fieldScale)
            --场地
            if mino.rule.underFieldDraw then mino.rule.underFieldDraw(P[i],mino) end

            mino.theme.fieldDraw(P[i],mino)

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
                if P[i].smoothAnimAct then
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
            if P[i].deadTimer>=0 and mino.theme.dieAnim then mino.theme.dieAnim(P[i],mino) end
            --赢了
            if P[i].winTimer>=0 and mino.theme.winAnim then mino.theme.winAnim(P[i],mino) end
            --输了
            if P[i].loseTimer>=0 and mino.theme.loseAnim then mino.theme.loseAnim(P[i],mino) end
        gc.pop()
    end
    --暂停
    gc.setColor(.04,.04,.04,min(mino.pauseAnimTimer*(S.winState==0 and 4 or 2),S.winState==0 and 1 or .5))
    gc.rectangle('fill',-1000,-1000,2000,2000)
    if mino.paused then
        pause.button.draw()
        gc.setColor(1,1,1)
        gc.printf(S.winState==0 and user.lang.game.paused or user.lang.game.result,
            font.Exo_2,0,-440,65536,'center',0,1,1,32768,84)
        gc.printf(curPlayTxt,font.Exo_2,0,330,65536,'center',0,.4,.4,32768,84)
    end
end
function mino.exit()
    mino.musInfo=""
    mino.exitScene=nil
    scene.sendArg=nil
    --mino.mode=nil
end
function mino.send(destScene,arg)
    destScene.exitScene=arg
end
return mino