local gc=love.graphics
local setColor,rect,arc,printf=gc.setColor,gc.rectangle,gc.arc,gc.printf

local M,T=myMath,myTable
local B=require'mino/blocks'
local fLib=require'mino/fieldLib'
local floor=math.floor

local rule={}

function rule.init(P,mino,modeInfo)
    scene.BG=require('BG/snow') scene.BG.init()
    mino.musInfo="カモキング - 大氷河時代"
    mus.add('music/Hurt Record/The Great Ice Age','whole','ogg',14.884,63)
    mus.start()
    --P[1].w=4
    --P[1].h=4
    --[[fLib.insertField(P[1],{
        {'g1','g1',' ',' '},
        {'g1',' ',' ',' '},
    })]]
    --mino.bag={'I'}

    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    --mino.rule.enableMiniSpin=false
    sfx.add({
        smash='sfx/mode/ice storm/smash.wav',
        --lvup='sfx/mode/ice storm/level up.wav'
    })
    mino.seqGenType='bagp1FromBag'
    rule.allowPush={}
    rule.scoreUp=480
    rule.scoreBase=960

    P[1].iceOpacity=modeInfo.arg.iceOpacity

    P[1].stormLv=1
    P[1].iceScore=0
    P[1].iceFreezeTime=0

    P[1].smashCombo=0
    P[1].scAnimTimer=0

    P[1].ruleAnim={
        score={preScore=0,t=0,tMax=.15},
        ice={},iceTMax=.3, smashParList={},
        lvupT=3,
        scoreTxt={},--[1]={x,y,v,g,color,size,TTL,Tmax}
    }
    for j=1,P[1].w do
        P[1].ruleAnim.ice[j]={preH=0,t=0}
    end
    P[1].iceColumn={}
    for j=1,P[1].w do
        P[1].iceColumn[j]={H=-1,topTimer=0,speed=0,speedmax=0,dvps=0,appearT=0,topDeco={}}
        for i=1,10,2 do
            P[1].iceColumn[j].topDeco[i]=5+2*rand()--大小
            P[1].iceColumn[j].topDeco[i+1]=rand()*2*math.pi--角度
        end
    end
    rule.rise(P[1],rand(2,P[1].w-1))
end
function rule.addScore(player,score)
    local A=player.ruleAnim.score
    A.preScore=player.iceScore A.t=A.tMax
    player.iceScore=player.iceScore+score
end
function rule.rise(player,col)
    local ice=player.iceColumn[col]
    if ice.H<0 then ice.H=0
        ice.speed=(player.stormLv<12 and .0125+player.stormLv*.0125 or .2)*(.75+.5*rand())
    end
end
function rule.destroy(player,col,scoring,mtp,sfxPlay)
    if not mtp then mtp=1 end
    local A=player.ruleAnim
    local ice,AIce=player.iceColumn[col],A.ice[col]

    local smash=false
    local h1,h2=.2,.4
    if ice and ice.H~=-1 then
        if scoring then local score=floor((ice.H<=h1 and 320 or ice.H<=h2 and 240 or 160)*mtp)
            rule.addScore(player,score)
            if player.stormLv<12 then
                table.insert(player.ruleAnim.scoreTxt,{
                    x=36*col+18,y=-36*player.h*min(ice.H,.5),v={128*(rand()-.5),-90},g=864,TTL=.8,tMax=.4,
                    size=72,color=(ice.H<=h1 and {1,.7,.4,1} or ice.H<=h2 and {1,.9,.1,1} or {.6,.8,1,1}),
                    score=score
                })
            end

            for i=1,10,2 do
                player.iceColumn[col].topDeco[i]=5+2*rand()--大小
                player.iceColumn[col].topDeco[i+1]=rand()*2*math.pi--角度
            end
        end

        if sfxPlay then sfx.play('smash') end
        smash=true

        local H=M.lerp(min(ice.H,1),A.ice[col].preH,(A.ice[col].t/A.iceTMax)^2)
        for i=1,floor((1+.4*rand())*H*player.h+.5) do
            table.insert(player.ruleAnim.smashParList,{
                x=36*(col+rand()),y=36*(-rand()*min(ice.H,1)*player.h),v={60*(rand()-.5),60*(rand()-.5)},g=1024,TTL=3
            })
        end
        for i=1,floor(H*player.h+.5) do
            table.insert(player.ruleAnim.smashParList,{
                x=36*(col+rand()),y=36*(.5-rand()-i),v={60*(rand()-.5),60*(rand()-.5)},g=1024,TTL=3
            })
        end

        ice.H=-1 ice.topTimer=0 ice.appearT=0
        AIce.preH,AIce.t=0,0
    end

    local clear=true
    for i=1,player.w do if player.iceColumn[i].H>=0 then clear=false break end end
    if clear then rule.rise(player,rand(player.w)) end

    return smash
end
function rule.decrease(player,col,amount,mtp)
    if not mtp then mtp=1 end
    local A=player.ruleAnim
    local ice=player.iceColumn[col]
    local his=player.history
    if ice and ice.H~=-1 then
        if player.stormLv<12 then
            table.insert(player.ruleAnim.scoreTxt,{
                x=36*col+18,y=-36*player.h*min(ice.H,1),v={0,-90},g=90,TTL=.4,tMax=.4,
                size=(his.line==4 and 40 or min(28+4*his.combo,64)),color={1,1,1,.8},score=floor(amount*160*mtp)
            })
        end
        A.ice[col]={
            --preH=ice.H,
            preH=M.lerp(min(ice.H,1),A.ice[col].preH, (A.ice[col].t/A.iceTMax)^2 ),
            t=A.iceTMax
        }
        ice.H=max(0,min(ice.H,1)-amount)
        rule.addScore(player,floor(amount*160*mtp))
        ice.topTimer=0
    end
end
local function getsl(player)
    return player.stormLv<12 and rule.scoreUp*(player.stormLv-1)+rule.scoreBase or 8400
end

function rule.lvup(player,mino)
    local A=player.ruleAnim
    if player.iceScore>=getsl(player) then
        for i=1,player.w do
            rule.destroy(player,i,false,0,true)
        end
        if 12==player.stormLv then mino.win(player) return end
        rule.rise(player,rand(2,player.w-1))
        A.preScore=rule.scoreUp*(player.stormLv-1)+rule.scoreBase
        player.iceScore=0 A.t=A.tMax
        player.stormLv=player.stormLv+1
        --sfx.play('lvup')
        A.lvupT=0
    end
end

function rule.update(player,dt,mino)
    local A=player.ruleAnim
    if rand()<((player.stormLv-1)/50+.1)*dt then
        local col=rand(player.w) rule.rise(player,col)
    end
    if player.iceFreezeTime<=0 then
    for i=1,player.w do local ice=player.iceColumn[i]
        if ice.H>=2 then ice.topTimer=ice.topTimer+dt
            --if ice.topTimer>=3 then mino.die(player) mino.lose(player) end
        elseif ice.H>=0 then ice.H=min(ice.H+dt*ice.speed,2) end
    end
    else player.iceFreezeTime=max(player.iceFreezeTime-dt,0) end

    for i=1,player.w do local ice=player.iceColumn[i]
        if ice.H>=0 then A.ice[i].t=max(A.ice[i].t-dt,0) ice.appearT=ice.appearT+dt end
    end

    A.lvupT=A.lvupT+dt
end
function  rule.always(player,dt,mino)
    local A=player.ruleAnim
    local txt=A.scoreTxt
    A.score.t=max(A.score.t-dt,0)
    local PL=A.smashParList
    for i=#PL,1,-1 do
        PL[i].TTL=PL[i].TTL-dt
        if PL[i].TTL<=0 then table.remove(PL,i) else
            PL[i].x,PL[i].y=PL[i].x+PL[i].v[1]*dt,PL[i].y+PL[i].v[2]*dt
            PL[i].v[2]=PL[i].v[2]+PL[i].g*dt
        end
    end
    for i=#txt,1,-1 do
        txt[i].TTL=txt[i].TTL-dt
        if txt[i].TTL<=0 then table.remove(txt,i) else
            txt[i].x,txt[i].y=txt[i].x+txt[i].v[1]*dt,txt[i].y+txt[i].v[2]*dt
            txt[i].v[2]=txt[i].v[2]+txt[i].g*dt
        end
    end

    local danger=mino.stacker.winState~=1 and player.stormLv>=12
    for i=1,player.w do local ice=player.iceColumn[i]
        if ice.H>=1.75 then danger=true break end
    end
    if not mino.unableBG then scene.BG.danger=danger end

    if player.smashCombo>2 then
        player.scAnimTimer=player.scAnimTimer+dt
    else player.scAnimTimer=0 end
end

function rule.afterPieceDrop(player,mino)
    local his=player.history
    local r=B.getX(his.piece)

    if his.spin and his.line==0 then for i=1,#his.piece do
        rule.decrease(player,his.piece[i][1]+his.x,.3,1.5)
    end end
    rule.lvup(player,mino)
    for i=1,player.w do local ice=player.iceColumn[i]
        if ice.topTimer>=3 then mino.die(player,true) break end
    end
end
local function getmtp(v)
    return min(1+max(0,(v-1)/16),2)
end
function rule.onLineClear(player,mino)
    local his=player.history
    local r=B.getX(his.piece)
    local PIC=player.iceColumn

    --local x=B.size(his.piece)

    local iceSmash=0
    for i=1,#r do for j=1,1 do
        if his.combo-j>0 then
            rule.decrease(player,r[i]+j+his.x,(his.combo-1)*.05/j)
            rule.decrease(player,r[i]-j+his.x,(his.combo-1)*.05/j)
        end
    end end
    if his.line>=4 then
        local k=his.piece[1][1]+his.x
        for i=k-1,k+1 do
            iceSmash=rule.destroy(player,i,true,(i==k and 2.5 or 1.5)*getmtp(player.smashCombo+iceSmash),true) and iceSmash+1 or iceSmash
        end
        if PIC[k-2] then rule.decrease(player,k-2,1,.625) end
        if PIC[k+2] then rule.decrease(player,k+2,1,.625) end

        player.iceFreezeTime=player.iceFreezeTime+.5
    else
        if his.spin then
            if his.mini then--Mini Spin削弱
                for i=1,#r do rule.decrease(player,r[i]+his.x,1,.625) end
            else
                for i=1,#r do
                    iceSmash=rule.destroy(player,r[i]+his.x,true,(.8+.2*his.line)*getmtp(player.smashCombo+iceSmash),true) and iceSmash+1 or iceSmash
                end
            end
        else
            for i=1,#r do rule.decrease(player,r[i]+his.x,his.line*.2*(.75+.25*his.combo)) end
        end
    end
    if his.PC then player.iceFreezeTime=player.iceFreezeTime+2.5 end
    rule.lvup(player,mino)

    if iceSmash~=0 then player.smashCombo=player.smashCombo+iceSmash
    elseif not (his.B2B>=0 and his.line>0) then player.smashCombo=max(player.smashCombo-2,0) end
end
function rule.underFieldDraw(player)
    local A=player.ruleAnim.score
    local score,tar=player.iceScore,rule.scoreUp*(player.stormLv-1)+rule.scoreBase
    local sz=M.lerp(score,A.preScore,(A.t/A.tMax)^2)/tar
    gc.push()
        gc.translate(-18*player.w-110,36)
        setColor(.1,.1,.1,.8)
        rect('fill',-90,-210,180,420)
        setColor(1,1,1)
        gc.setLineWidth(4)
        rect('line',-47,-152,94,304)
        if player.stormLv<12 then
            setColor(.4,.8,1,.8)
            rect('fill',-45,150-300*sz,90,300*sz)
        end
        setColor(1,1,1,.1)
        rect('fill',-45,-150,90,300)
        setColor(1,1,1)
        printf("Lv."..player.stormLv,font.JB_B,0,-180,1000,'center',0,1/3,1/3,500,font.height.JB_B/2)
        printf(player.stormLv<12 and ("%d/%d"):format(score,tar) or "???/???",
        font.JB,0,180,1000,'center',0,.25,.25,500,font.height.JB_B/2)
        if player.smashCombo>1 then
            setColor(1,1,1,.25+.25*max(player.smashCombo-2,1)/8*(1-player.scAnimTimer%.25/.25))
            printf(player.smashCombo>16 and "MAX" or "x"..player.smashCombo,font.JB,0,0,5000,'center',0,1/3,1/3,2500,font.height.JB_B/2)
        end
    gc.pop()
end

local ict=gc.newCanvas(14,1)
gc.setCanvas(ict)
for i=1,7 do
    setColor(1,1,1,(8-i)/10)
    gc.points(i-.5,.5,14-i+.5,.5)
    --setColor(1,1,1,1/3)
    --rect('fill',0,0,14,1)
end
gc.setCanvas()
local r,g,b,larg
function rule.overFieldDraw(player)
    gc.push()
    local FW,FH=36*player.w,36*player.h
    gc.translate(-FW/2-36,FH/2)
    local A=player.ruleAnim
    for i=1,player.w do
        local ice,deco=player.iceColumn[i],player.iceColumn[i].topDeco
        if ice.H>=0 then
            larg=ice.H>=1.5 and abs(player.gameTimer%.25-.125)*8 or 0
            r=ice.H==2 and .8 or ice.H>=1 and M.lerp(.6, 1,larg) or .4
            g=ice.H==2 and .1 or ice.H>=1 and M.lerp(.9,.8,larg) or .8
            b=ice.H==2 and .1 or ice.H>=1 and M.lerp( 1,.8,larg) or  1
            --冰柱显示的高度
            local H=M.lerp(min(ice.H,1),A.ice[i].preH,(A.ice[i].t/A.iceTMax)^2)
            --“底座”
            --setColor(.6,.9,1,2.5*ice.appearT)
            --rect('fill',36*i,-2,36,2)
            --“柱体”
            setColor(r,g,b,.4*player.iceOpacity)
            rect('fill',36*i+4,-FH*H,28,FH*H)
            gc.draw(ict,36*(i+.5),-FH*H,0,2,FH*H,7,0)
            setColor(r,g,b,.3*player.iceOpacity)
            if ice.H>=1 then
            rect('fill',36*i+4,-FH*(ice.H-1),28,FH*(ice.H-1))
            end
            setColor(.6,.9,1,1)
            --rect('fill',36*i,-FH*H,4,FH*H)
            --rect('fill',36*i+32,-FH*H,4,FH*H)
            for j=1,5 do
                arc('fill','closed',36*(i+.5)+6*(j-3),-FH*H,deco[2*j-1]*min((2*ice.appearT)^.5,1)     ,deco[2*j],deco[2*j]+3/2*math.pi,3)
                arc('fill','closed',36*(i+.5)+6*(j-3),0    ,deco[2*j-1]*min((4*ice.appearT)^.5,1)*1.25,deco[2*j],deco[2*j]+3/2*math.pi,3)
            end
        end
    end
    setColor(.6,.9,1,min(player.deadTimer*2,0.8))
    rect('fill',36,-FH,FW,FH)

    setColor(.6,.84,1,.8)
    local PL=player.ruleAnim.smashParList
    for i=1,#PL do
        rect('fill',PL[i].x-12,PL[i].y-12,24,24)
    end
    local txt=A.scoreTxt
    for i=1,#txt do
        local clr=txt[i].color
        setColor(clr[1],clr[2],clr[3],clr[4]*txt[i].TTL/txt[i].tMax)
        printf(""..txt[i].score,font.JB_B,txt[i].x,txt[i].y,5000,'center',0,txt[i].size/128,txt[i].size/128,2500,font.height.JB_B/2)
    end
    gc.translate(18*player.w+36,-18*player.h)
    local t=A.lvupT
    setColor(1,1,1,1.8-t/.3)
    printf("LEVEL UP",font.Bender_B,0,-1200*(t-.16)*t+FH*.05,5000,'center',0,.8,.8,2500,font.height.Bender_B/2)

    gc.pop()
end
function rule.scoreSave(P,mino)
    local pb=file.read('player/best score')
    local isHighScore=pb['ice storm'] and (P[1].stormLv>pb['ice storm'].level or (P[1].stormLv==pb['ice storm'].level and P[1].iceScore>pb['ice storm'].score))
    local ispb
    if pb['ice storm'] then
        if mino.stacker.winState>0 then
            ispb=(not pb['ice storm'].complete or P[1].gameTimer<pb['ice storm'].time)
        else ispb=isHighScore end
    end
    if not pb['ice storm'] or ispb then
    pb['ice storm']={
        complete=mino.stacker.winState>0,
        level=P[1].stormLv,score=P[1].iceScore,lvlscore=getsl(P[1]),
        time=P[1].gameTimer,date=os.date("%Y/%m/%d  %H:%M:%S")
    }
    file.save('player/best score',pb)
    end
    return ispb
end
return rule