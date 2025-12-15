local simple={}
local T,M=myTable,myMath
local setColor,rect,line,circle,printf,draw=gc.setColor,gc.rectangle,gc.line,gc.circle,gc.printf,gc.draw

local atkAnimTMax=.5
local defAnimTMax=.2
local recvAnimTMax=.2
local cooldownAnimTMax=.25
local dangerAnimTMax=.2
local gts
function simple.init(player)
    gts=user.lang.game.theme.simple
    simple.next=gc.newText(font.JB,"NEXT") simple.hold=gc.newText(font.JB,"HOLD")
    simple.nextW,simple.nextH=simple.next:getWidth(),simple.next:getHeight()
    simple.holdW,simple.holdH=simple.hold:getWidth(),simple.hold:getHeight()

    simple.winTxt=gc.newText(font.Bender_B,gts.win) 
    simple.wtW,simple.wtH=simple.winTxt:getWidth(),simple.winTxt:getHeight()

    simple.loseTxt=gc.newText(font.Bender_B,gts.lose)
    simple.ltW,simple.ltH=simple.loseTxt:getWidth(),simple.loseTxt:getHeight()

    simple.newRecordTxt=gc.newText(font.Bender_B,gts.newRecord)
    simple.nrtW,simple.nrtH=simple.newRecordTxt:getWidth(),simple.newRecordTxt:getHeight()

    player.clearInfo=T.copy(player.history)
    player.clearTxt=gc.newText(font.Bender)
    player.spinTxt={txt=gc.newText(font.Bender),x=0}
    player.PCInfo={} player.clearTxtTimer=0 player.clearTxtTMax=0
    player.dangerAnimTimer=0
    player.B2BAnimTimer=1e99

    simple.NRSFXDelay=.8--破纪录音效多长时间后播放
end
local W,H,timeTxt
function simple.getNextPos(player)
    return 18*player.w+90+20,-18*max(player.h,20)-50,100
end
function simple.fieldDraw(player,mino)
    --[[
    setColor(1,1,1)
    gc.setLineWidth(4)
    rect('line',-400,-400,800,800)
    ]]

    local darg=player.dangerAnimTimer/dangerAnimTMax

    W,H=36*player.w,36*player.h
    local aH=36*max(player.h,20)
    setColor(.1,.1,.1,.8)
    rect('fill',-W/2,-H/2,W,H)
    rect('fill',W/2+20,-aH/2,180,100*player.preview)
    rect('fill',-W/2-200,-aH/2,180,100)

    setColor(1,1-.8*darg,1-.8*darg)
    --rect('fill',W/2+20,-aH/2-30,180,30)
    --rect('fill',-W/2-200,-aH/2-30,180,30)
    gc.setLineWidth(2)
    rect('line',W/2+20,-aH/2,180,100*player.preview)
    rect('line',-W/2-200,-aH/2,180,100)

    setColor(1,1-.8*darg,1-.8*darg)
    gc.setLineWidth(2)
    line(-W/2-1,-H/2,-W/2-1,H/2+1,W/2+1,H/2+1,W/2+1,-H/2)
    line(-W/2-19,-H/2,-W/2-19,H/2+1,W/2+19,H/2+1,W/2+19,-H/2)

    setColor(1,1,1,.18)
    draw(simple.hold,-W/2-205,-aH/2+50,-math.pi/2,.3,.3,simple.holdW/2,0)
    draw(simple.next, W/2+205,-aH/2+50,math.pi/2,.3,.3,simple.nextW/2,0)

    for i=1,player.preview do
        printf(tostring(i),font.JB_L,W/2+25,-aH/2+100*i-100,800,'left',0,.25,.25,0,0)
    end
    gc.setLineWidth(2)
    setColor(1,1-.8*darg,1-.8*darg,.1)
    --网格
    for y=-.5*player.h+1,.5*player.h-1 do
        line(-W/2,36*y,W/2,36*y)
    end
    for x=-.5*player.w+1,.5*player.w-1 do
        line(36*x,-H/2,36*x,H/2)
    end
    --锁延重置&次数
    setColor(.25,.5,.375,.4)
    rect('fill',-W/2,H/2+4,W,20)
    setColor(.5,1,.75)
    rect('fill',-W/2,H/2+4,W*(1-player.LTimer/player.LDelay),20)
    setColor(0,0,0)
    printf(("%02d"):format(min(player.LDR,99)),font.JB_B,-W/2+4,H/2+2+64*.2,400,'left',0,5/32,5/32,0,font.height.JB_B/2)
    printf(("%dms"):format(min(player.LDelay*1000,9999)),font.JB_B,W/2-4,H/2+2+64*.2,800,'right',0,5/32,5/32,800,font.height.JB_B/2)
    --计时
    local t=player.gameTimer
    timeTxt=string.format("%d:%d%d.%03d",t/60,t/10%6,t%10,t%1*1000)
    --timeTxt=string.format("%d:%d%.3f",t/60,t/10%6,t%10)
    setColor(.2,.4,.3,.3)
    for i=0,3 do
        printf(timeTxt,font.JB_B,-W/2-30+i%2*4,H/2-18+4*floor(i/2),800,'right',0,.25,.25,800,font.height.JB_B/2)
    end
    setColor(.5,1,.75)
    printf(timeTxt,font.JB_B,-W/2-28,H/2-16,800,'right',0,.25,.25,800,font.height.JB_B/2)
end

function simple.updateDefenseAnim(player,defList)
    local dal=player.defAnimList
    for i=1,#defList do
        dal[#dal+1]=defList[i]
        dal[#dal].t=0
    end
end
function simple.updateRecvAnim(player,atk)
    local ral=player.recvAnimList
    ral[#ral+1]={amount=atk.amount,t=0}
end
function simple.garbageDraw(player,mino)
    local W,H=36*player.w,36*player.h
    local t,rt
    local dal=player.defAnimList
    local ral=player.recvAnimList
    local tga=0 --总垃圾数
    for i=1,#dal do
        t=max(1-dal[i].t/defAnimTMax*2,0)
        tga=tga+dal[i].amount*t
    end
    for i=1,#ral do
        t=max(1-ral[i].t/recvAnimTMax*2,0)
        tga=tga+ral[i].amount*t
    end
    for i=1,#player.garbage do
        local g=player.garbage[i]
        tga=tga+g.amount
        if tga-g.amount<=40 then
            rt=-g.time/cooldownAnimTMax
            t=(1-min(g.appearT,.075)/.075)^2
            gc.setColor(1,1,1,2-2*rt)
            gc.setLineWidth(2)
            rect('line',-W/2-18-8*rt,H/2-36*(tga+t*.75)-12*rt,16+16*rt,36*g.amount+24*rt)

            if g.time>0 then gc.setColor(.6,.45,.45,1-t) else gc.setColor(1,.75,.75,1-t) end
            rect('fill',-W/2-18,H/2-36*(tga+t*.75),16,36*g.amount)
            if g.time>0 then gc.setColor(.5,0,0,1-t) else gc.setColor(1,0,0,1-t) end
            rect('fill',-W/2-17,H/2-36*(tga+t*.75)+2,14,36*g.amount-4)
            gc.setColor(1,1,1,1-t)
            rect('fill',-W/2-15,H/2-36*(tga+t*.75)+4,4,1) rect('fill',-W/2-15,H/2-36*(tga+t*.75)+4,1,4)
        end
    end

    for i=1,#dal do
        t=dal[i].t/defAnimTMax
        setColor(1,1,1,1-t)
        rect('fill',-W/2-18-8*t,H/2-36*(dal[i].amount+dal[i].pos)-12*t,16+16*t,36*dal[i].amount+24*t)
    end

    if player.garbageCap then
        local darg=player.dangerAnimTimer/dangerAnimTMax
        setColor(.5+.5*darg,1,.875+.125*darg)
        gc.setLineWidth(1)
        line(-W/2-18,H/2-36*player.garbageCap,-W/2-2,H/2-36*player.garbageCap)
    end
end

local spikeColor={[0]={1,1,1,.5},{.96,.96,.96,1},{.5,1,.875,1},{.6,.8,1,1},{.8,.6,1,1}}
function simple.overFieldDraw(player)
    local aal=player.atkAnimList
    if aal then
    for i=1,#aal do
        t=aal[i].t/atkAnimTMax
        local bv=min(max(aal[i].B2B,0)*.2,1)
        local s=min((aal[i].amount-aal[i].defAmount/2-1+6)/24,.625)

        gc.setColor(1,1-.2*bv,1-bv,1.5-1.5*t)
        gc.printf(aal[i].amount-aal[i].defAmount,font.Bender,-W/2+36*aal[i].x-18,H/2-36*(aal[i].y+(2-t)*t),2000,'center',0,s,s,1000,font.height.Bender/2)

        if aal[i].defAmount>0 then
        gc.setColor(.6,.9,1,1.5-1.5*t)
        gc.printf("-"..aal[i].defAmount,font.Bender,-W/2+36*aal[i].x-18,H/2-36*(aal[i].y-(2-t)*t/2),2000,'center',0,s*.8,s*.8,1000,font.height.Bender/2)
        end
    end
    end

    local spk,dspk=player.spikeAnimCount,player.defSpikeAnimCount
    if spk and spk>=8 then

        local sc=spikeColor[min(floor((spk-dspk)/8),4)]

        local ts=.3+.05*min(floor((spk-dspk)/8),4)

        gc.setColor(sc[1],sc[2],sc[3],sc[4]*(player.spikeAnimTimer/player.spikeAnimTMax*2)^.5)
        local ah=(spk-dspk>=8 and 80*ts/.35 or 0)*max( (player.spikeAnimTMax-player.spikeAnimTimer)/.2*(1-(player.spikeAnimTMax-player.spikeAnimTimer)/.2),0 )
        if dspk>0 then
            gc.printf(string.format("%d SPIKE (-%d)",spk,dspk),font.Bender,0,-H/5-ah,4000,'center',0,ts,ts,2000,font.height.Bender/2)
        else
            gc.printf(string.format("%d SPIKE",spk),font.Bender,0,-H/5-ah,4000,'center',0,ts,ts,2000,font.height.Bender/2)
        end
    end
end

function simple.readyDraw(t)
    if t>1 then
    elseif t>.5 then setColor(1,1,1,min((t-.5)/.25,1))
        printf("READY",font.Bender_B,0,0,1000,'center',0,.9,.9,500,72)
    elseif t>0 then setColor(1,1,1,min(t/.25,1))
        printf("SET",font.Bender_B,0,0,1000,'center',0,.9,.9,500,72)
    elseif t>-.5 then setColor(1,1,1,min((t+.5)/.25,1))
        printf("GO!",font.Bender_B,0,0,1000,'center',0,1.2,1.2,500,72)
    end
end

local clearTxt={
    'Single','Double','Triple','Aquad',
    'Boron','Carbon','Nitrogen','Oxygen',
    'Fluorine','Neon','Sodium','Magnesium',
    'Aluminium','Silicon','Phosphorus','Sulfur',
    'Chlorine','Argon','Potassium','Calcium','NUCLEAR FUSION'
}
local clearClr={
    [0]={1,1,1},
    {1,1,1},{1,1,1},{1,1,1},{.5,1,.75},
    {.8,1,0},{.8,.8,.8},{.64,.6,1},{.5,.75,1},
    {.5,1,.5},{1,.9,.5},{1,1,.2},{1,1,1},
    {1,1,1},{1,1,1},{1,0,0},{.64,.6,1},
    {.75,1,.5},{1,.5,.96},{.7,.6,1},{1,.5,.4},
}
function simple.updateClearInfo(player,mino)
    local his=player.history
    if his.line>0 or his.spin then player.clearInfo=T.copy(player.history)
        player.clearTxtTMax=his.line>0 and (his.line>=4 and 1 or his.spin and .8 or .5) or .5
        player.clearTxtTimer=player.clearTxtTMax

        local CInfo=player.clearInfo

        local t1=(CInfo.B2B>0 and CInfo.line>0 and "B2B " or "")
        local t2=CInfo.name
        local t3=(CInfo.spin and (CInfo.line>0 and "-Spin " or "-Spin") or "")..(clearTxt[min(CInfo.line,#clearTxt)] or "")

        player.clearTxt:set({{1,1,1},t1,{0,0,0,0},(CInfo.spin and t2 or ""),{1,1,1},t3})

        if CInfo.spin then
        player.spinTxt.x=-player.clearTxt:getWidth()/2+gc.newText(font.Bender,t1):getWidth()+gc.newText(font.Bender,t2):getWidth()/2
        player.spinTxt.txt=gc.newText(font.Bender,t2)
        else player.spinTxt.txt=gc.newText(font.Bender) end

    else player.clearInfo.combo=his.combo player.clearInfo.wide=-1 end
    if his.PC then player.PCInfo[#player.PCInfo+1]=2.5 end
end
local ctxt,btxt
function simple.clearTextDraw(player,mino)
    W,H=36*player.w,36*player.h
    local CInfo=player.clearInfo
    gc.translate(-W/2-20,-250)
    if CInfo.combo>1 then
        ctxt=""..CInfo.combo.." chain"--[[..(CInfo.combo>19 and "?!?!" or CInfo.combo>15 and "!!" or CInfo.combo>7 and "!" or "")..(CInfo.wide==4 and "\n4-wide" or "")]]

        setColor(.1,.1,.1,.15)
        for i=1,8 do
            printf(ctxt,font.JB_B,-8+3*cos(i*math.pi/4),12+3*sin(i*math.pi/4),1200,'right',0,.25,.25,1200,font.height.JB_B/2)
        end
        if scene.time%.2<.1 then setColor(1,1,1) else local k=min((CInfo.combo-8)/8,1)
        setColor(1-.5*k,1,1-.125*k) end
        printf(ctxt,font.JB_B,-8,12,1200,'right',0,.25,.25,1200,font.height.JB_B/2)
    end

    btxt="B2B x"..max(player.history.B2B,0)
    if player.history.B2B>0 then
        local bc=(min(player.history.B2B,11)-1)/10
        setColor(.4,.36-.16*bc,.2,.15)
        for i=1,8 do
            printf(btxt,font.JB_B,-8+3*cos(i*math.pi/4),57+3*sin(i*math.pi/4),1200,'right',0,5/16,5/16,1200,font.height.JB_B/2)
        end
        setColor(1,.9-.5*bc,.4)
        printf(btxt,font.JB_B,-8,57,1200,'right',0,5/16,5/16,1200,font.height.JB_B/2)
    else
        setColor(.75,.75,.75,1-(player.B2BAnimTimer/.25)^2)
        printf(btxt,font.JB_B,-8,57,1200,'right',0,5/16,5/16,1200,font.height.JB_B/2)
    end
    gc.translate(W/2+20,250)

    local a1=min(player.clearTxtTimer*1.5/player.clearTxtTMax,1)*.9
    local s=(CInfo.spin and .5 or CInfo.line>=4 and 1-.05*player.clearTxtTimer or .5)
    local r,g,b

    if CInfo.line>20 then
        if player.clearTxtTimer%.12<.06 then
            r,g,b=1,1,1
        else
            r,g,b=1,.9,.6
        end
    elseif CInfo.spin and not CInfo.mini then
        local c=mino.color[CInfo.name]
        r,g,b=c[1]+.3*(1-c[1]),c[2]+.3*(1-c[2]),c[3]+.3*(1-c[3])
    else
        local c=clearClr[min(CInfo.line,#clearClr)]
        r,g,b=c[1],c[2],c[3]
    end
    if CInfo.line>8 then
        setColor(r,g,b,a1*min(CInfo.line-8,8)/96)
        for i=1,3 do
            for j=1,8 do
                local m,n=2*i*cos(j*math.pi/4),2*i*sin(j*math.pi/4)
                gc.draw(player.clearTxt,0,0,0,s,s,player.clearTxt:getWidth()/2,player.clearTxt:getHeight()/2)
            end
        end
    end
    local a2=a1*(player.clearTxtTimer%.2>=.1 and .4 or .6)
    setColor(1,1,1,a2)
    local t=""
    if CInfo.wide>=2 and CInfo.wide<=4 then t=t..CInfo.wide.."-wide" end
    if (CInfo.spin and CInfo.mini) then t=t..(t=="" and "weak" or " weak") end
    if t~="" then printf(t,font.Bender,0,-64*s-20,4000,'center',0,1/3,1/3,2000,72) end

    setColor(r,g,b,a1)
    gc.draw(player.clearTxt,0,0,0,s,s,player.clearTxt:getWidth()/2,player.clearTxt:getHeight()/2)
    local angle=-max(2*(player.clearTxtTimer/player.clearTxtTMax-.5),0)^3*math.pi/2
    gc.draw(player.spinTxt.txt,s*player.spinTxt.x,0,angle,s,s,player.spinTxt.txt:getWidth()/2,player.spinTxt.txt:getHeight()/2)

    for i=1,#player.PCInfo do
        local t=player.PCInfo[i]
        local ti=2.5-t
        local a,b,c,s=.3,.35,.4,1.35
        if ti>c then local ts=ti-c
        gc.push('transform')
        gc.scale(ts+1)
        setColor(1,.9,.2,1-3*ts)
        printf("ALL",font.Bender,0,-68,1000,'center',0,.9,.9,500,72)
        printf("CLEAR",font.Bender,0,28,1000,'center',0,.9,.9,500,72)
        gc.pop()
        end
        gc.push('transform')
        gc.scale(ti<a and (s-s*((ti-a)/a)^2) or ti<b and s or max(s+(s-1)/(c-b)*(b-ti),1))

        setColor(1,.96,.2,min(t,1)*.1)
        for j=1,8 do
            local ox,oy=4*cos(j/4*math.pi),4*sin(j/4*math.pi)
            printf("ALL",font.Bender,ox,-68+oy,1000,'center',0,.9,.9,500,72)
            printf("CLEAR",font.Bender,ox,28+oy,1000,'center',0,.9,.9,500,72)
        end
        setColor(1,.96,.2,t)
        printf("ALL",font.Bender,0,-68,1000,'center',0,.9,.9,500,72)
        printf("CLEAR",font.Bender,0,28,1000,'center',0,.9,.9,500,72)
        gc.pop()
    end
end

local function checkDanger(player)
    local gbamount=0
    if player.garbage then
        for i=1,#player.garbage do
            gbamount=gbamount+player.garbage[i].amount
        end
    end

    local c=ceil(player.w/2)
    for x=c-1,c+2 do
        for y=#player.field,1,-1 do
            if player.field[y][x] then
            if next(player.field[y][x]) and y+gbamount>=player.h-3 then return true end
            end
        end
    end
    return false
end
function simple.update(player,dt)
    local PCInfo=player.PCInfo
    for i=#PCInfo,1,-1 do PCInfo[i]=PCInfo[i]-dt
        if PCInfo[i]<=0 then rem(PCInfo,i) end
    end

    player.clearTxtTimer=max(player.clearTxtTimer-dt,0)

    if checkDanger(player) then player.dangerAnimTimer=min(dangerAnimTMax,player.dangerAnimTimer+dt)
    else player.dangerAnimTimer=max(0,player.dangerAnimTimer-dt) end

    player.B2BAnimTimer=(player.history.B2B>0 and 0 or player.B2BAnimTimer+dt)

    if player.garbage then
        for i=1,#player.garbage do
            player.garbage[i].appearT=player.garbage[i].appearT+dt
        end
    end

    if player.defAnimList then
        local dal=player.defAnimList
        for i=#dal,1,-1 do
            dal[i].t=dal[i].t+dt
            if dal[i].t>=defAnimTMax then rem(dal,i) end
        end
    end
    if player.atkAnimList then
        local aal=player.atkAnimList
        for i=#aal,1,-1 do
            aal[i].t=aal[i].t+dt
            if aal[i].t>=atkAnimTMax then rem(aal,i) end
        end
    end
    if player.recvAnimList then
        local ral=player.recvAnimList
        for i=#ral,1,-1 do
            ral[i].t=ral[i].t+dt
            if ral[i].t>=recvAnimTMax then rem(ral,i) end
        end
    end
end

local c1=gc.newCanvas(250,1)
gc.setCanvas(c1)
for i=1,100 do
    gc.setColor(1,1,1,(1-i/100)^.5)
    gc.points(100.5-i,.5,149.5+i,.5)
end
setColor(1,1,1)
rect('fill',100,0,50,1)
gc.setCanvas()

local NRparAmount=100
local NRpar={}
for i=1,NRparAmount do
    NRpar[i]={x=rand()-.5,y=rand()-.5,alpha=.5+.5*rand()}
    NRpar[i].fx=NRpar[i].x*600+(rand()-.5)*300
    NRpar[i].fy=NRpar[i].y*150+(rand()-.5)*75
end

local tw,th
local function recordAnim(time)
    tw,th=simple.nrtW,simple.nrtH

    if time>.8 then
    local s=time>=1 and 1 or ((time-.8)/.2)^4
    setColor(.5,1,.875,.6)
    draw(c1,0,-128,0,(80+tw*.6)/250*s,th*.6,125,.5)
    setColor(.5,1,.875)
    draw(c1,0,-128-th*.3-2,0,(80+tw*.6)/250*s,4,125,.5)
    draw(c1,0,-128+th*.3+2,0,(80+tw*.6)/250*s,4,125,.5)

    setColor(1,1,1)
    draw(simple.newRecordTxt,0,-128,0,.6*s,.6,tw/2,th/2)
    end

    if time>=1 then
    local t=(time-1)/.75
    local parg=t<1 and t*(2-t) or 1
    setColor(.5,1,.875)
    for i=1,NRparAmount do
        circle('fill',tw*.6*NRpar[i].x+parg*NRpar[i].fx,-128+th*.6*NRpar[i].y+parg*NRpar[i].fy,6*(1-parg),4)
    end
    end
end

gc.setCanvas()
function simple.loseAnim(player,stacker)
    setColor(1,1,1,player.deadTimer*4)
    draw(simple.loseTxt,-simple.ltW/2,-simple.ltH/2)

    if stacker.newRecord then
        recordAnim(player.deadTimer)
    end
end
function simple.winAnim(player,stacker)
    setColor(1,1,1,1-player.winTimer*4)
    draw(simple.winTxt,0,0,0,1+player.winTimer*4,1+player.winTimer*4,simple.wtW/2,simple.wtH/2)
    setColor(1,1,1)
    draw(simple.winTxt,0,0,0,1,1,simple.wtW/2,simple.wtH/2)

    if stacker.newRecord then
        recordAnim(player.winTimer)
    end
end

function simple.getResultShowDelay(stacker)
    return stacker.newRecord and 2.5 or 1.5
end
return simple