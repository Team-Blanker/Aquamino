local T=myTable
local ins,rem=table.insert,table.remove

local rule={}

local rsq
local fLib=require'mino/fieldLib'
function rule.init(P,mino)
    rsq=user.lang.rule.square

    scene.BG=require('BG/squares') scene.BG.setBGColor(1.2,1,.3)

    mino.musInfo="K.Y. - Birth and Death"
    mus.add('music/Hurt Record/Birth and Death','parts','ogg',12.375,48.75)

    sfx.add({
        sq='sfx/mode/general/sq.wav',
    })

    --mino.bag={'Z','Z','S','S','J','J','J','J','L','L','L','L','O','O','O','I','I','I','T','T','T','T'}
    mino.bag={'J','L','O','I','T','T'}
    mino.seqGenType='mayhem'

    mino.color.plum={.96,.48,.84}
    mino.color.gold={.9,.81,.045}
    mino.color.silver={.8,.8,.88}

    mino.texType.plum=1
    mino.texType.gold=1
    mino.texType.silver=1

    mino.rule.allowSpin={}
    mino.rule.allowPush={}

    for k,v in pairs(mino.bag) do
        mino.rule.allowSpin[v]=false
        mino.rule.allowPush[v]=false
    end

    for k,v in pairs(P) do
        --v.w=12
    
        v.LDRInit=1e99 v.LDelay=1e99 v.LDR=1e99

        v.sqAnimList={}

        v.sqPoint=0
    end
end

function rule.start()
    mus.start()
end
function rule.pause(stacker,paused)
    if stacker.started and stacker.winState==0 then
    if paused then mus.pause() else mus.start() end
    end
end

local b=require'mino/blocks'

local idList,nameList={},{}
local sqAnimTMax=.2

local checkOrder={
    'plum','gold','silver'
}
local checkFunc={
    plum=function (nList)
        return #nList==1
    end,
    gold=function (nList)
        return #nList<=2
    end,
    silver=function ()
        return true
    end
}
local effectColor={plum={.96,.48,.84},gold={1,.9,.2},silver={.95,.95,.95}}
local sqPoint={plum=4,gold=2,silver=1}

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

                player.sqPoint=player.sqPoint+sqPoint[sqtp]

                sfx.play('sq',1,1,fLib.getSourcePos(player,mino.stereo,x+1.5))
            end
        end
    end  end

    end
end

local colorList={-9999,{1.2,1,.3},0,{1.2,1,.3},60,{1,1,1.2},120,{.5,.75,1},150,{.9,.27,.225}}
function rule.gameUpdate(P,dt,mino)
    for i=#colorList-1,1,-2 do
        if P[1].gameTimer>=colorList[i] then
            local c0,c1=colorList[i-1],colorList[i+1]
            local t=min(P[1].gameTimer-colorList[i],2)/2
            if not mino.unableBG then
                scene.BG.setBGColor(t*c1[1]+(1-t)*c0[1],t*c1[2]+(1-t)*c0[2],t*c1[3]+(1-t)*c0[3])
            end
            break
        end
    end
    if P[1].gameTimer>=180 then mino.win(P[1]) end
end
function rule.update(player,dt,mino)
    local sq=player.sqAnimList
    for i=#sq,1,-1 do
        sq[i].t=sq[i].t+dt
        if sq[i].t>sqAnimTMax then rem(sq,i) end
    end
end

function rule.underFieldDraw(player)
    local x=-18*player.w-110
    local t=max(180-player.gameTimer,0)
    gc.setColor(1,1,1)
    gc.printf(player.sqPoint,font.JB,x,-48,6000,'center',0,.625,.625,3000,96)
    gc.printf(rsq.amount,font.JB_B,x,0,6000,'center',0,.2,.2,3000,96)
    gc.printf(string.format("%01d:%02d",t/60,t%60),font.JB,x,56,6000,'center',0,.4,.4,3000,96)
    gc.printf(rsq.time,font.JB_B,x,96,6000,'center',0,.2,.2,3000,96)
end
function rule.overFieldDraw(player)
    local sq=player.sqAnimList
    for i=1,#sq do
        gc.setColor(effectColor[sq[i].type])
        local ti=sq[i].t/sqAnimTMax
        local sz=36*(4+1.25*ti)
        gc.setLineWidth(6*(1-ti))
        gc.rectangle('line',-sz/2+sq[i].x,-sz/2+sq[i].y,sz,sz)
    end

    if player.gameTimer>=180 then
    elseif player.gameTimer>=170 then
        gc.setColor(1,1,1,max(2-player.gameTimer%1*2.5,0)^.5)
        gc.printf(ceil(180-player.gameTimer),font.Bender_B,0,0,6000,'center',0,.75,.75,3000,font.height.Bender_B/2)
    elseif player.gameTimer>=150 then
        local t=max(153-player.gameTimer,0)
        gc.setColor(1,1,1,t)
        gc.printf(rsq.remainTime[3],font.Bender,0,0,6000,'center',0,.5+.05*(3-t)/3,.5+.05*(3-t)/3,3000,font.height.Bender/2)
    elseif player.gameTimer>=120 then
        gc.setColor(1,1,1,max(123-player.gameTimer,0)^.5)
        gc.printf(rsq.remainTime[2],font.Bender,0,-18*player.h,6000,'center',0,.4,.4,3000,128)
    elseif player.gameTimer>=60 then
        gc.setColor(1,1,1,max(63-player.gameTimer,0)^.5)
        gc.printf(rsq.remainTime[1],font.Bender,0,-18*player.h,6000,'center',0,.4,.4,3000,128)
    end
end

function rule.scoreSave(P,mino)
    local pb=file.read('player/best score')
    local ispb=pb.square and P[1].sqPoint>pb.square.sqPoint or false
    if not pb.square or P[1].sqPoint>pb.square.sqPoint then
        pb.square={sqPoint=P[1].sqPoint,date=os.date("%Y/%m/%d  %H:%M:%S")}
        file.save('player/best score',pb)
    end
    return ispb
end
return rule