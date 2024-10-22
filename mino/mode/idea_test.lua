local T=mytable
local ins,rem=table.insert,table.remove

local rule={}
local fLib=require'mino/fieldLib'
function rule.init(P,mino)
    scene.BG=require('BG/zone') scene.BG.init(0,.5,60,4,40/60,8)
    mino.musInfo="龍飛 - アシタノカタチ"
    mus.add('music/Hurt Record/Shape of Tomorrow','whole','ogg',12.375,48.75)
    mus.start()

    sfx.add({
        sq='sfx/mode/general/sq.wav',
    })

    mino.seqGenType='pairs'
    mino.bag={
        --'I','J','L','O'
        'Z','S','J','L','T','O','I', --'Z','S','J','L','T','O','I',
        --'Z5','S5','J5','L5','T5','I5','P','Q','N','H','R','Y','E','F','V','W','X','U',
        --'I6','U6','T6','O6','wT','Ht','XT','Tr','A','Pl',
        --'Pl','Pl','Tr','Tr',
        --'OZ','OS','bZ','bS','TZ','TS',
        --'lSt','rSt','lHk','rHk'
    }
    mino.color.gold={.9,.81,.045}
    mino.color.silver={.8,.8,.88}
    mino.rule.allowSpin={}
    mino.rule.allowPush={}
    for k,v in pairs(mino.bag) do
        mino.rule.allowSpin[v]=true
        mino.rule.allowPush[v]=true
    end
    mino.rule.loosen.fallTPL=.1
    for k,v in pairs(P) do
        --v.w=12
        v.LDRInit=1e99 v.FDelay=5 v.LDelay=1e99 v.LDR=1e99

        v.sqAnimList={}
    end
end

local b=require'mino/blocks'
--[[function rule.onPieceSummon(player)
    local c=player.cur
    if rand()<1/2 then
        table.remove(c.piece,rand(#c.piece))
    end
    if c.name~='I6' and rand()<1/14 then
        c.piece=b.giant(c.piece)
    end
end]]
local idList,nameList={},{}
local sqAnimTMax=.2

local checkOrder={
    'gold','silver'
}
local checkFunc={
    gold=function (nList)
        return #nList==1
    end,
    silver=function ()
        return true
    end
}
function rule.postCheckClear(player,mino)--正方拼合，先检测金，再检测银
local sq=player.sqAnimList
    for o=1,#checkOrder do

    for y=1,#player.field-3 do for x=1,player.w-3 do
        for i=1,#idList do idList[i]=nil end
        for i=1,#nameList do nameList[i]=nil end
        local sqc=false
        for yt=0,3 do
            if sqc then break end
            for xt=0,3 do
                if (not player.field[y+yt][x+xt].name) or T.include(checkOrder,player.field[y+yt][x+xt].name) then sqc=true break end
                if player.field[y+yt][x+xt].id and not T.include(idList,player.field[y+yt][x+xt].id) then
                    table.insert(idList,player.field[y+yt][x+xt].id)
                    if not T.include(nameList,player.field[y+yt][x+xt].name) then
                        table.insert(nameList,player.field[y+yt][x+xt].name)
                    end
                end
            end
        end
        if (not sqc) and #idList==4 then
            local sqtp=checkOrder[o]
            if checkFunc[sqtp](nameList) then
                ins(sq,{type=sqtp,x=36*(x+1-player.w/2),y=-36*(y+1-player.h/2),t=0})
                for yt=0,3 do  for xt=0,3 do
                    player.field[y+yt][x+xt].name=sqtp
                end  end
                sfx.play('sq',1,1,fLib.getSourcePos(player,mino.stereo,x+1.5))
            end
        end
    end  end

    end
end
function rule.update(player,dt)
    local sq=player.sqAnimList
    for i=#sq,1,-1 do
        sq[i].t=sq[i].t+dt
        if sq[i].t>sqAnimTMax then rem(sq,i) end
    end
end
function rule.overFieldDraw(player)
    local sq=player.sqAnimList
    gc.setColor(1,1,1)
    if player.cur.name then gc.printf(player.cur.name,font.Bender_B,-18*player.w-110,0,1000,'center',0,.5,.5,500,72) end

    for i=1,#sq do
        if sq[i].type=='gold' then gc.setColor(1,.9,.2) else gc.setColor(.95,.95,.95) end
        local ti=sq[i].t/sqAnimTMax
        local sz=36*(4+1.25*ti)
        gc.setLineWidth(6*(1-ti))
        gc.rectangle('line',-sz/2+sq[i].x,-sz/2+sq[i].y,sz,sz)
    end
end
return rule