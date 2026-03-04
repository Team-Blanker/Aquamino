local mode={}
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

--[[ruleSet.xxx={
    init=function()
    seqGen='',
    allowSpin={},
    atkScale=num,defScale=num,
    garbageType='normal'/'bomb',
    setAtkScale=function(),
    setDefScale=function(),
    atkCalculate=function(),
    garbageSummon=function(),
    garbageCap=function(),
    update=function(),
    specialBlock=bool,
    specialBlockRequire=num,（特殊方块暂时还没有写）
}]]
local ruleSet={
    basic={--接近多数游戏的对战玩法
        w=10,h=20,
        seqGen='bag',
        spinType='default',
        allowSpin={T=true},
        atkScale=1,defScale=1,
        garbageType='normal',
        atkCalculate=function(player)
            local l,s,m,b,c
            local his=player.history
            l,s,m,b,c=his.line,his.spin,his.mini,his.B2B,his.combo

            local pc=his.PC and 8 or 0 --全消加成
            local bl=(s and not m) and 2*l or l>=4 and l or l-1 --基础攻击
            local ba=b>0 and 1 or 0 --B2B加成
            local ca=min(c/3,3) --连消加成
            return floor(bl+ba+ca+pc)
        end,
        garbageSummon=function(player,atk)
            return {
                amount=atk,
                block='g1',
                cut=1e99,
                cutOffset=0,
                M_OC=1,
                appearT=0,
                time=.5,
            }
        end,
        garbageCap=function(t)
            return 8
        end,
        specialBlock=false,
    },
    allspin={
        w=10,h=20,
        seqGen='bag',
        spinType='default',
        allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true},
        atkScale=1,defScale=1,
        garbageType='normal',
        atkCalculate=function(player)
            local l,s,m,b,c,p
            local his=player.history
            l,s,m,b,c,p=his.line,his.spin,his.mini,his.B2B,his.combo,his.name

            local pc=0 --全消加成
            local bl=(s and not m) and 2*l or l>=4 and l or l-1 --基础攻击
            local ba=b>0 and 1+min((b-1)/5,3) and 1 or 0 --B2B加成
            local ca=min(c/3,1) --连消加成
            return floor(bl+ba+ca+pc)
        end,
        garbageSummon=function(player,atk)
            return {
                amount=atk,
                block='g1',
                cut=1e99,
                cutOffset=0,
                M_OC=1,
                appearT=0,
                time=.5,
            }
        end,
        garbageCap=function(t)
            return 8
        end,
        specialBlock=false,
    },
    allspin2={
        w=10,h=20,
        seqGen='bag',
        spinType='default',
        allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true},
        atkScale=1,defScale=1,
        garbageType='normal',
        afterPieceDrop=function(player)
            local his=player.history
            if his.spin and his.line==0 then
                battle.charge(player,his.mini and 1 or 2)
            elseif his.line>0 then
                battle.chargeRelease(player)
            end
        end,
        atkCalculate=function(player)
            local l,s,m,b,c,p,w
            local his=player.history
            l,s,m,b,p=his.line,his.spin,his.mini,his.B2B,his.name
            w,c=(his.wide>4 and 1 or his.wide),min(his.combo,12)

            local pc=his.PC and 4 or 0 --全消加成
            local bl=(s and not m) and (p=='T' and 2*l or l) or l>=4 and l or l-1 --基础攻击
            local ba=b>0 and 1 or 0 --B2B加成
            local ca=max((c-3)/(2^w)+1,0) --连消加成
            return floor(bl+ba+ca+pc+player.charge)
        end,
        garbageSummon=function(player,atk)
            local his=player.history
            local w=(his.wide>4 and 1 or his.wide)
            return {
                amount=atk,
                block='g1',
                cut=1e99,
                cutOffset=0,
                M_OC=(w>=2 and w<=4) and (4-w)*.025 or his.PC and 0 or 1,
                appearT=0,
                time=.5,
            }
        end,
        garbageCap=function(t)
            return 8
        end,
        specialBlock=false,
    },
    aqua={
        w=10,h=20,
        seqGen='bagp1FromBag',
        spinType='default',
        allowSpin={T=true},
        atkScale=1,defScale=1,
        garbageType='normal',
        atkCalculate=function(player)
            local l,s,m,b,w,c
            local his=player.history
            l,s,m,b=his.line,his.spin,his.mini,his.B2B
            w,c=(his.wide>4 and 1 or his.wide),min(his.combo,12)

            local pc=his.PC and 6 or 0
            local bl=(s and not m) and 2*l-1 or l>=4 and 1.5*l-1.5 or l-.5 --基础攻击
            local ba=b>0 and min((3+b)/4,2.5) or 0 --B2B加成
            local ca=max((c-3)/(2^w)+.5,0)+(((l>=4 or his.spin) and c>1) and 1 or 0) --连消加成
            return l==0 and 0 or floor((bl+ba+ca+pc)*max((player.gameTimer-60)/60,1))
        end,
        garbageSummon=function(player,atk)
            local l,s,m,b,w,c
            local his=player.history
            l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo
            return {
                amount=atk,
                block='g1',
                cut=(w==4 or his.PC) and 1e99 or s and atk/2+b or 1e99,
                cutOffset=0,
                M_OC=(w>=2 and w<=4) and (4-w)*.025 or his.PC and 0 or max(1/(max(b,1)-0.1*(c-3)),.2),
                appearT=0,
                time=.5,
            }
        end,
        garbageCap=function(t)
            return 4
        end,
        specialBlock=true,
        specialBlockRequire=28,
    },
    shrink={
        w=10,h=24,
        setAtkScale=function (player)
            return .5
        end,
        seqGen='bag',
        spinType='default',
        allowSpin={T=true},
        atkScale=1,defScale=1,
        garbageType='normal',
        atkCalculate=function(player)
            local l,s,m,b,c,p,w
            local his=player.history
            l,s,m,b,p=his.line,his.spin,his.mini,his.B2B,his.name
            w,c=(his.wide>4 and 1 or his.wide),min(his.combo,12)

            local pc=his.PC and 6 or 0 --全消加成
            local bl=(s and not m) and (p=='T' and 2*l or l) or l>=4 and 1.5*l-1.5 or l-1 --基础攻击
            local ba=b>0 and min(floor(b^.5*2)/2,3) or 0 --B2B加成
            local ca=max((c-3)/(2^w)+1,0) --连消加成
            return floor(bl+ba+ca+pc)
        end,
        garbageSummon=function(player,atk)
            local his=player.history
            local w=(his.wide>4 and 1 or his.wide)
            return {
                amount=atk,
                block='g1',
                cut=1e99,
                cutOffset=0,
                M_OC=((w>=2 and w<=4) and (4-w)*.025 or his.PC and 0 or 1)*max(min((player.gameTimer-15)/15,1),0),
                appearT=0,
                time=.5,
            }
        end,
        garbageCap=function(t)
            return 8
        end,
        update=function (player,dt)
            if player.gameTimer<40 then
                player.h=24-floor(player.gameTimer/10)
            elseif player.gameTimer<60 then
                player.h=20
            else
                player.h=20-min(max(floor(player.gameTimer/10-8),0),10)
            end
        end,
        specialBlock=false,
    },
    bomb={
        w=10,h=20,
        seqGen='bag',
        spinType='default',
        allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true},
        atkScale=1,defScale=1,
        garbageType='bomb',
        atkCalculate=function(player)
            local l,s,m,b,c
            local his=player.history
            l,s,m,b,c=his.line,his.spin,his.mini,his.B2B,his.combo

            local pc=his.PC and 4 or 0 --全消加成
            local bl=(s and not m) and 2*l or l>=4 and 1.5*l-1.5 or l-1 --基础攻击
            local ba=b>0 and 1 or 0 --B2B加成
            local ca=min(c/3,3) --连消加成
            return floor(bl+ba+ca+pc)
        end,
        garbageSummon=function(player,atk)
            local l,s,m,b,w,c
            local his=player.history
            l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo
            return {
                amount=atk,
                block='g1',
                cut=1e99,
                cutOffset=0,
                M_OC=(w>=2 and w<=4) and (4-w)*.025 or his.PC and 0 or max(1/max(b+1,1),.1),
                appearT=0,
                time=.5,
            }
        end,
        garbageCap=function(t)
            return max(math.ceil(t/45),2)
        end,
        specialBlock=false,
    },
}
function mode.init(P,mino,modeInfo)
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

    mode.ruleName=modeInfo.arg.ruleSet
    mode.ruleNameTxt="[ "..user.lang.menu.arg.battle.ruleSetName[mode.ruleName].." ]"

    mino.seqGen=ruleSet[mode.ruleName].seqGen
    mino.seqSync=true

    mino.rule.allowSpin=ruleSet[mode.ruleName].allowSpin
    mino.rule.spinType=ruleSet[mode.ruleName].spinType

    mino.rule.specialBlock=ruleSet[mode.ruleName].specialBlock
    mino.rule.specialBlockRequire=ruleSet[mode.ruleName].specialBlockRequire

    P[1].w,P[1].h=ruleSet[mode.ruleName].w,ruleSet[mode.ruleName].h
    P[1].atk=0
    P[1].garbageClear=0
    P[1].line=0
    P[1].specialBlockMeter=0
    P[1].garbageCap=ruleSet[mode.ruleName].garbageCap(0)
    P[1].garbageCap=8

    P[2]=myTable.copy(P[1])

    --mino.bag={'I'}
    --P[1].w=4

    if modeInfo.arg.playerPos=='left' then P[1].posX=-400 P[2].posX=400
    else P[1].posX=400 P[2].posX=-400 end
    P[2].LDelay=1e99 P[2].FDelay=1e99 --P[2].summonHeightAlign=1
    P[1].target=2 P[2].target=1
    mino.fieldScale=min(mino.fieldScale,1)
    battle.init(P[1]) battle.init(P[2]) fLib.setRS(P[2],'SRS_origin')
    P[1].garbageCap=ruleSet[mode.ruleName].garbageCap(0) P[2].garbageCap=ruleSet[mode.ruleName].garbageCap(0)
    if ruleSet[mode.ruleName].init then ruleSet[mode.ruleName].init(P[1]) ruleSet[mode.ruleName].init(P[2]) end

    mode.botThread=bot_cc.newThread(1,P,2)
    bot_cc.startThread(mode.botThread,nil)
    mode.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(P[2]),
    B2B=P[2].history.B2B>0,
    combo=P[2].history.combo,
    })

    mode.expect={}
    mode.opDelay=1/modeInfo.arg.bot_PPS
    mode.opTimer=0
end

local msgSend=false
function mode.gameUpdate(P,dt,mino)
    mode.opTimer=mode.opTimer+dt
    if mode.opTimer>0 then
        if not msgSend then
        mode.botThread.sendChannel:push({op='require'})
        msgSend=true
        end
        local op=mode.botThread.recvChannel:pop()
        if op and msgSend then
        mode.expect=op.expect
        bot_cc.operate(P[2],op,false,mino)
        mode.opTimer=mode.opTimer-mode.opDelay
        msgSend=false
        end
    end
    if P[2].deadTimer>=0 then mino.win(P[1]) end
    for k,v in pairs(P) do
        v.garbageCap=ruleSet[mode.ruleName].garbageCap(v.gameTimer)
        if ruleSet[mode.ruleName].update then ruleSet[mode.ruleName].update(v,dt) end
    end
end

function mode.always(player,dt)
    battle.update(player,dt)
end
function mode.afterCheckClear(player,mino)
    if player.history.line==0 then
        if   ruleSet[mode.ruleName].garbageType=='normal' then battle.stdAtkRecv(player,mino)
        elseif ruleSet[mode.ruleName].garbageType=='bomb' then battle.stdBombAtkRecv(player,mino) end
    else battle.defense(player,ruleSet[mode.ruleName].atkCalculate(player),mino)
    end
end
function mode.onLineClear(player,mino)
    local his=player.history
    player.line=player.line+his.line
    player.atk=player.atk+ruleSet[mode.ruleName].atkCalculate(player)
    battle.sendAtk(player,mino.player[player.target],battle.atkGen(player,ruleSet[mode.ruleName].atkCalculate,ruleSet[mode.ruleName].garbageSummon))

    if player.history.clearLine then
        for k,v in pairs(player.history.clearLine) do
            if v.type=='garbage' then
                player.garbageClear=player.garbageClear+1
            end
        end
    end
end
function mode.afterPieceDrop(player,mino)
    if ruleSet[mode.ruleName].afterPieceDrop then ruleSet[mode.ruleName].afterPieceDrop(player) end

    if player==mino.player[2] then
    mode.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(player),
    B2B=player.history.B2B>0,
    combo=player.history.combo,
    garbage=battle.getGarbageAmount(player)
    })
    end
end
function mode.onNextGen(player,nextStart,mino)
    if player==mino.player[2] then
    bot_cc.sendNext(mode.botThread,player,nextStart)
    end
end
local efftxt
local fw=font.JB:getWidth("ABCDEFG")/2
function mode.underAllDraw()
    gc.setColor(1,1,1,.5)
    gc.printf(mode.ruleNameTxt,font.Bender,0,480,4000,'center',0,.4,.4,2000,font.height.Bender/2)
end
function mode.underFieldDraw(player)
    gc.setColor(1,1,1)
    efftxt=(player.gameTimer==0 and "0.00" or string.format("%.2f",player.stat.block/player.gameTimer))
    gc.printf(efftxt,font.JB,-18*player.w-28-fw*.2,18*player.h-176,2000,'right',0,.25,.25,2000,font.height.JB/2)
    efftxt=(player.gameTimer==0 and "0.0" or string.format("%.1f",player.atk/player.gameTimer*60))
    gc.printf(efftxt,font.JB,-18*player.w-28-fw*.2,18*player.h-136,2000,'right',0,.25,.25,2000,font.height.JB/2)
    efftxt=(player.gameTimer==0 and "0.0" or string.format("%.1f",(player.atk+player.garbageClear)/player.gameTimer*100))
    gc.printf(efftxt,font.JB,-18*player.w-28-fw*.2,18*player.h-96,2000,'right',0,.25,.25,2000,font.height.JB/2)
    efftxt=(player.stat.block==0 and "0.00" or string.format("%.2f",player.atk/player.stat.block))
    gc.printf(efftxt,font.JB,-18*player.w-28-fw*.2,18*player.h-56,2000,'right',0,.25,.25,2000,font.height.JB/2)

    gc.printf("PPS",font.JB,-18*player.w-28,18*player.h-172,2000,'right',0,.2,.2,2000,font.height.JB/2)
    gc.printf("APM",font.JB,-18*player.w-28,18*player.h-132,2000,'right',0,.2,.2,2000,font.height.JB/2)
    gc.printf("VS.",font.JB,-18*player.w-28,18*player.h-92,2000,'right',0,.2,.2,2000,font.height.JB/2)
    gc.printf("APP",font.JB,-18*player.w-28,18*player.h-52,2000,'right',0,.2,.2,2000,font.height.JB/2)
end
function mode.overFieldDraw(player,mino)
    if player==mino.player[2] then
    gc.setColor(1,1,1)
    if mode.expect then
        for i=1,#mode.expect,2 do
            gc.setLineWidth(3)
            gc.rectangle('line',36*(mode.expect[i]-player.w/2-1)+3,-36*(mode.expect[i+1]-player.h/2)+3,30,30)
        end
    end
    end
end
function mode.exit()
    bot_cc.destroyThread(mode.botThread)
end
return mode