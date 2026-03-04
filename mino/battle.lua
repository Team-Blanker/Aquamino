local fLib=require'mino/fieldLib'
local block=require'mino/blocks'

local max,min=math.max,math.min

local battle={}
function battle.init(player)
    player.garbage={} player.atkAnimList={} player.defAnimList={} player.recvAnimList={}
    player.lastHole=rand(player.w)
    player.defAmount=0 player.atkUsedToDef=0
    player.atkScale=1 player.defScale=1
    player.atkMinusByDef=true

    player.charge=0--充能，不管是什么意义上的
    player.lastReleaseCharge=0
    player.chargeAnimTimer=1e99
    player.chargeAnimType='release'

    player.garbageCap=1e99

    player.spikeTimer=0
    player.spikeCount=0
    player.defSpikeCount=0

    player.spikeAnimTimer=0 player.spikeAnimTMax=.75
    player.spikeAnimCount=0
    player.defSpikeAnimCount=0
end
function battle.sendAtk(player,dest,atk)
    if not atk then return end
    --[[atk={
    amount=垃圾行数量
    block=什么颜色的方块，建议使用'g1' 'g2'
    cut=该组垃圾会被切割成几行一组一起进入，允许浮点数
    cutOffset=假设该组垃圾有amount+这玩意，从这玩意开始继续切
    M_OC=Messiness On Change，该组与上一组垃圾的洞位置不一致的概率
    appearT=垃圾进入缓冲槽动画时间参数
    time=垃圾缓冲时间
    cut=1e99 M_OC=1即标准对战垃圾
    }]]
    ins(dest.garbage,atk)
    --return atk.amount
end
function battle.atkRecv(player,atk,mino)
    if atk.amount==0 then return end
    player.lastHole=rand()<atk.M_OC and rand(player.w) or player.lastHole
    local h
    local l=atk.cutOffset or 0
    --print(atk.cut)
    for i=1,atk.amount do
        l=l+1
        local sw=rand()<(l-atk.cut)
        h=sw and rand(player.w) or player.lastHole
        player.lastHole=h
        if sw then l=l-atk.cut end
        fLib.garbage(player,atk.block,1,h,'garbage')
    end
    if mino.theme.updateRecvAnim then mino.theme.updateRecvAnim(player,atk) end
    return l
end
function battle.getGarbageAmount(player)
    local n=0
    for i=1,#player.garbage do
        n=n+player.garbage[i].amount
    end
    return n
end
function battle.defense(player,amount,mino,defScale)
    defScale=defScale or player.defScale
    local n=floor(amount*defScale)
    local remList={}
    local defAmount=0
    while player.garbage[1] and n>0 do
        if n>=player.garbage[1].amount then
            remList[#remList+1]={pos=amount-n,amount=player.garbage[1].amount}
            defAmount=defAmount+player.garbage[1].amount
            n=n-rem(player.garbage,1).amount
        else
            player.garbage[1].amount=player.garbage[1].amount-n
            remList[#remList+1]={pos=amount-n,amount=n}
            defAmount=defAmount+n
        break end
    end
    --remList[i]={pos,amount}
    if mino.theme.updateDefenseAnim then mino.theme.updateDefenseAnim(player,remList) end

    player.defAmount=defAmount --抵消了多少攻击
    player.atkUsedToDef=ceil(defAmount/defScale) --实际用掉了多少攻击来抵消
end
function battle.update(player,dt)
    for i=1,#player.garbage do
        player.garbage[i].time=player.garbage[i].time-dt
    end
    player.spikeTimer=max(player.spikeTimer-dt,0)
    if player.spikeTimer==0 then player.spikeCount=0 player.defSpikeCount=0 end

    player.spikeAnimTimer=max(player.spikeAnimTimer-dt,0)
end

local l,s,m,w,b,c
function battle.stdAtkCalculate(player)
    local his=player.history
    l,s,m,b,c=his.line,his.spin,his.mini,his.B2B,his.combo

    local pc=his.PC and 8 or 0 --全消加成
    local bl=(s and not m) and 2*l or l>=4 and l or l-1 --基础攻击
    local ba=b>0 and 1 or 0 --B2B加成
    local ca=min(c/3,3) --连消加成
    return floor(bl+ba+ca+pc)
end
function battle.atkGen(player,atkCalculate,garbageSummon,atkScale)
    atkScale=atkScale or player.atkScale

    local his=player.history

    local atk=atkCalculate(player)
    local def=(player.atkMinusByDef and player.atkUsedToDef or 0)
    local totalatk=(atk-def)*atkScale
    player.defAmount=0 player.atkUsedToDef=0

    if atk>0 then
        player.spikeCount=player.spikeCount+atk
        player.defSpikeCount=player.defSpikeCount+def
        player.spikeTimer=1

        player.spikeAnimCount=player.spikeCount
        player.defSpikeAnimCount=player.defSpikeCount
        player.spikeAnimTimer=player.spikeAnimTMax

        local x,y,ox,oy=block.size(his.piece)
        ins(player.atkAnimList,{x=his.x-ox,y=his.y-oy,t=0,amount=atk,defAmount=def,B2B=his.B2B})
    end

    if totalatk<=0 then return end

    return garbageSummon(player,totalatk)
end
function battle.stdAtkGen(player,t)
    local his=player.history
    l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo

    local atk=battle.stdAtkCalculate(player)
    local def=(player.atkMinusByDef and player.defAmount or 0)
    local totalatk=(atk-def)*player.atkScale
    player.defAmount=0

    if atk>0 then
        player.spikeCount=player.spikeCount+atk
        player.defSpikeCount=player.defSpikeCount+def
        player.spikeTimer=1

        player.spikeAnimCount=player.spikeCount
        player.defSpikeAnimCount=player.defSpikeCount
        player.spikeAnimTimer=player.spikeAnimTMax

        local x,y,ox,oy=block.size(player.history.piece)
        ins(player.atkAnimList,{x=player.history.x-ox,y=player.history.y-oy,t=0,amount=atk,defAmount=def,B2B=player.history.B2B})
    end

    if totalatk<=0 then return end

    return battle.stdGarbageSummon(player,totalatk,t)
end
function battle.stdGarbageSummon(player,atk,t)
    local his=player.history
    l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo
    return {
        amount=atk,
        block='g1',
        cut=1e99,
        cutOffset=0,
        M_OC=1,
        appearT=0,
        time=t or .5,
    }
end
function battle.stdAtkRecv(player,mino)
    local amount=0
    local i=1
    while i<=#player.garbage and amount<player.garbageCap do
        if player.garbage[i].time<=0 then
            if amount+player.garbage[i].amount<=player.garbageCap then
                battle.atkRecv(player,player.garbage[i],mino)
                amount=amount+player.garbage[i].amount
                rem(player.garbage,i)
            else
                local oa,sa=player.garbage[i].amount,player.garbageCap-amount
                player.garbage[i].amount=sa
                local cutOffset=battle.atkRecv(player,player.garbage[i],mino)
                player.garbage[i].amount=oa-sa
                amount=player.garbageCap
                player.garbage[i].M_OC=0
                player.garbage[i].cutOffset=cutOffset
            end
        else i=i+1 end
    end
    return amount
end
--炸弹垃圾行
function battle.bombAtkRecv(player,atk,mino)
    if atk.amount==0 then return end
    player.lastHole=rand()<atk.M_OC and rand(player.w) or player.lastHole
    local h
    local l=atk.cutOffset or 0
    --print(atk.cut)
    for i=1,atk.amount do
        l=l+1
        local sw=rand()<(l-atk.cut)
        h=sw and rand(player.w) or player.lastHole
        player.lastHole=h
        if sw then l=1 end
        fLib.bombGarbage(player,atk.block,1,h)
    end
    if mino.theme.updateRecvAnim then mino.theme.updateRecvAnim(player,atk,mino) end
    return l
end
function battle.stdBombAtkRecv(player,mino)
    local amount=0
    local i=1
    while i<=#player.garbage and amount<player.garbageCap do
        if player.garbage[i].time<=0 then
            if amount+player.garbage[i].amount<=player.garbageCap then
                battle.bombAtkRecv(player,player.garbage[i],mino)
                amount=amount+player.garbage[i].amount
                rem(player.garbage,i)
            else
                local oa,sa=player.garbage[i].amount,player.garbageCap-amount
                player.garbage[i].amount=sa
                local cutOffset=battle.bombAtkRecv(player,player.garbage[i],mino)
                player.garbage[i].amount=oa-sa
                amount=player.garbageCap
                player.garbage[i].M_OC=0
                player.garbage[i].cutOffset=cutOffset
            end
        else i=i+1 end
    end
    return amount
end
function battle.charge(player,amount)
    player.charge=player.charge+amount
    player.chargeAnimTimer=0
    player.chargeAnimType='charge'
end
function battle.chargeRelease(player)
    player.lastReleaseCharge=player.charge
    player.charge=0
    player.chargeAnimTimer=0
    player.chargeAnimType='release'
end
return battle