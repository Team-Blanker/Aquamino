local fLib=require'mino/fieldLib'
local block=require'mino/blocks'

local max,min=math.max,math.min

local battle={}
function battle.init(player)
    player.garbage={} player.atkAnimList={} player.defAnimList={}
    player.lastHole=rand(player.w)
    player.defAmount=0
    player.atkScale=1 player.defScale=1
    player.atkMinusByDef=true

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
    M_OC=Messiness On Change，该组与上一组垃圾的洞位置不一致的概率
    appearT=垃圾进入缓冲槽动画时间参数
    time=垃圾缓冲时间
    cut=1e99 M_OC=1即标准对战垃圾
    }]]
    ins(dest.garbage,atk)
end
function battle.atkRecv(player,atk)
    if atk.amount==0 then return end
    player.lastHole=rand()<atk.M_OC and rand(player.w) or player.lastHole
    local h
    local l=0
    --print(atk.cut)
    for i=1,atk.amount do
        l=l+1
        local sw=rand()<(l-atk.cut)
        h=sw and rand(player.w) or player.lastHole
        player.lastHole=h
        if sw then l=1 end
        fLib.garbage(player,atk.block,1,h)
    end
end
function battle.getGarbageAmount(player)
    local n=0
    for i=1,#player.garbage do
        n=n+player.garbage[i].amount
    end
    return n
end
function battle.defense(player,amount,mino)
    local n=amount*player.defScale
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
    l,s,m,b=his.line,his.spin,his.mini,his.B2B
    w,c=(his.wide>4 and 1 or his.wide),min(his.combo,12)
    if his.PC then return 4+l else

    local bl=(s and not m) and 2*l-1 or l>=4 and 1.5*l-1.5 or l-.5 --基础攻击
    local ba=b>0 and min((3+b)/4,2.5) or 0 --B2B加成
    local ca=max((c-3)/(2+w)+(l>=4 and 1.5 or .5),0) --连消加成
    return l==0 and 0 or floor(bl+ba+ca)
    end
end
function battle.stdAtkGen(player,time)
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

    return {
        amount=totalatk,
        block='g1',
        cut=(w==4 or his.PC) and 1e99 or s and totalatk/2+b+.25 or 1e99,
        M_OC=(w>=2 and w<=4) and (4-w)*.025 or his.PC and 0 or max(1/(max(b,1)-0.1*(c-3)),.2),
        appearT=0,
        time=time or .5,
    }
end
function battle.stdAtkRecv(player)
    local amount=0
    local i=1
    while i<=#player.garbage do
        if player.garbage[i].time<=0 then
            battle.atkRecv(player,player.garbage[i])
            amount=amount+player.garbage[i].amount
            rem(player.garbage,i)
        else i=i+1 end
    end
    return amount
end
--炸弹垃圾行
function battle.bombAtkRecv(player,atk)
    if atk.amount==0 then return end
    player.lastHole=rand()<atk.M_OC and rand(player.w) or player.lastHole
    local h
    local l=0
    --print(atk.cut)
    for i=1,atk.amount do
        l=l+1
        local sw=rand()<(l-atk.cut)
        h=sw and rand(player.w) or player.lastHole
        player.lastHole=h
        if sw then l=1 end
        fLib.bombGarbage(player,atk.block,1,h)
    end
end
function battle.stdBombAtkCalculate(player)
    local his=player.history
    l,s,m,b=his.line,his.spin,his.mini,his.B2B
    w,c=(his.wide>4 and 1 or his.wide),min(his.combo,12)
    if his.PC then return 4+l else

    local bl=max(((s and not m) and l+min(l-1,3) or 0),(l>=4 and 1.5*l-1.5 or l-.5)) --基础攻击
    local ba=b>0 and min((3+b)/4,2.5) or 0 --B2B加成
    local ca=max((c-3)/(2+2^(w-1))+(l>=4 and 1.5 or .5),0) --连消加成
    return l==0 and 0 or floor(bl+ba+ca)
    end
end
function battle.stdBombAtkGen(player,time)
    local his=player.history
    l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo

    local atk=battle.stdBombAtkCalculate(player)
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

    return {
        amount=totalatk,
        block='g1',
        cut=(w==4 or his.PC) and s and 1.5 or 2.5,
        M_OC=(w>=2 and w<=4) and (4-w)*.025 or his.PC and 0 or max(1/(max(b,1)-0.1*(c-3)),.2),
        appearT=0,
        time=time or .5,
    }
end
function battle.stdBombAtkRecv(player)
    local amount=0
    local i=1
    while i<=#player.garbage do
        if player.garbage[i].time<=0 then
            battle.bombAtkRecv(player,player.garbage[i])
            amount=amount+player.garbage[i].amount
            rem(player.garbage,i)
        else i=i+1 end
    end
    return amount
end
return battle