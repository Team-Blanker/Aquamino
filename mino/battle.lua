local fLib=require'mino/fieldLib'
local battle={}
function battle.init(player)
    player.garbage={}
    player.lastHole=rand(player.w)
end
function battle.sendAtk(player,dest,atk)
    --[[arg={
    amount=垃圾行数量
    block=什么颜色的方块，建议使用'g1' 'g2'
    M_IS=Messiness In Set，该组垃圾行内孔洞散乱度
    M_OC=Messiness On Change，该组与上一组垃圾的洞位置不一致的概率
    M_IS=0 M_OC=1即标准对战垃圾
    }]]
    ins(dest.garbage,atk)
end
function battle.atkRecv(player,atk)
    if atk.amount==0 then return end
    print(atk.M_IS)
    player.lastHole=rand()<atk.M_OC and rand(player.w) or player.lastHole
    local h
    for i=1,atk.amount do
        h=(rand()<atk.M_IS) and rand(player.w) or player.lastHole
        fLib.garbage(player,atk.block,1,h)
    end
    player.lastHole=h
end
function battle.defense(player,amount)
    while player.garbage[1] and amount>0 do
        if amount>=player.garbage[1].amount then amount=amount-rem(player.garbage,1).amount
        else player.garbage[1].amount=player.garbage[1].amount-amount break end
    end
end
function battle.stdAtkCalculate(player)
    local his=player.history
    local l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo

    local bl=(s and not m) and 2*l-1 or l>=4 and l or l-.5
    local ba=b>0 and (3+b)/4 or 0
    local ca=(w>=2 and w<=4) and min(c-1,.5) or min((c-1)/3+.01,3.34)
    local pc=his.PC and 6.67 or 0
    return l==0 and 0 or floor(bl+ba+ca+pc)
end
function battle.stdAtkGen(player)
    local his=player.history
    local l,s,m,w,b,c=his.line,his.spin,his.mini,his.wide,his.B2B,his.combo

    local bl=(s and not m) and 2*l-1 or l>=4 and l or l-.5
    local ba=b>0 and (3+b)/4 or 0
    local ca=(w>=2 and w<=4) and min(c-1,.5) or min((c-1)/3+.01,3.67)
    local pc=his.PC and 6.67 or 0
    local atk=floor(bl+ba+ca+pc)
    if atk==0 then return end
    return {
        amount=atk,
        block='g1',
        M_IS=(w==4 or his.PC) and 0 or s and (.2-.05*b) or 0,
        M_OC=(w==4 or his.PC) and 0 or b>0 and 1/b or 1
    }
end
return battle