local simple={}
local T,M=mytable,mymath
local setColor,rect,line,circle,printf,draw=gc.setColor,gc.rectangle,gc.line,gc.circle,gc.printf,gc.draw

local gts
function simple.init(player)
    gts=user.lang.game.theme.simple
    simple.next=gc.newText(font.Bender_B,"N E X T") simple.hold=gc.newText(font.Bender_B,"H O L D")
    simple.nextW,simple.nextH=simple.next:getWidth(),simple.next:getHeight()
    simple.holdW,simple.holdH=simple.hold:getWidth(),simple.hold:getHeight()

    simple.winTxt=gc.newText(font.Bender_B,gts.win) simple.loseTxt=gc.newText(font.Bender_B,gts.lose)
    simple.wtW,simple.wtH=simple.winTxt:getWidth(),simple.winTxt:getHeight()
    simple.ltW,simple.ltH=simple.loseTxt:getWidth(),simple.loseTxt:getHeight()

    player.clearInfo=T.copy(player.history)
    player.clearTxt=gc.newText(font.Bender)
    player.spinTxt={txt=gc.newText(font.Bender),x=0}
    player.PCInfo={} player.clearTxtTimer=0 player.clearTxtTMax=0
end
local W,H,timeTxt
function simple.fieldDraw(player,mino)
    W,H=36*player.w,36*player.h
    setColor(.1,.1,.1,.8)
    rect('fill',-W/2,-H/2,W,H)
    rect('fill',W/2+20,-360,180,100*player.preview)
    rect('fill',-W/2-200,-360,180,100)
    setColor(1,1,1)
    rect('fill',W/2+20,-390,180,30)
    rect('fill',-W/2-200,-390,180,30)
    gc.setLineWidth(1)
    rect('line',W/2+20.5,-359.5,179,100*player.preview-1)
    rect('line',-W/2-199.5,-359.5,179,99)

    setColor(1,1,1)
    gc.setLineWidth(2)
    line(-W/2-1,-H/2,-W/2-1,H/2+1,W/2+1,H/2+1,W/2+1,-H/2)
    line(-W/2-19,-H/2,-W/2-19,H/2+1,W/2+19,H/2+1,W/2+19,-H/2)

    setColor(0,0,0)
    draw(simple.hold,-W/2-110,-375,0,.2,.2,simple.holdW/2,simple.holdH/2)
    draw(simple.next, W/2+110,-375,0,.2,.2,simple.nextW/2,simple.nextH/2)

    gc.setLineWidth(2)
    setColor(1,1,1,.1)
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
    printf(("%02d"):format(min(player.LDR,99)),font.Bender_B,-W/2+4,H/2+2+64*.2,400,'left',0,5/32,5/32,0,76)
    local t=player.gameTimer
    timeTxt=string.format("%d:%d%.3f",t/60,t/10%6,t%10)
    setColor(.2,.4,.3,.3)
    --计时
    for i=0,3 do
        printf(timeTxt,font.JB_B,-W/2-30+i%2*4,H/2-18+4*floor(i/2),800,'right',0,.25,.25,800,84)
    end
    setColor(.5,1,.75)
    printf(timeTxt,font.JB_B,-W/2-28,H/2-16,800,'right',0,.25,.25,800,84)
end
function simple.setDefenseAnim(player,defList)
    
end
function simple.garbageDraw(player,mino)
    local W,H=36*player.w,36*player.h
    local tga=0 --总垃圾数
    for i=1,#player.garbage do
        tga=tga+player.garbage[i].amount
        gc.setColor(1,.75,.75)
        rect('fill',-W/2-18,H/2-36*tga,16,36*player.garbage[i].amount)
        gc.setColor(1,0,0)
        rect('fill',-W/2-17,H/2-36*tga+2,14,36*player.garbage[i].amount-4)
        gc.setColor(1,1,1)
        rect('fill',-W/2-15,H/2-36*tga+4,4,1) rect('fill',-W/2-15,H/2-36*tga+4,1,4)
    end
end
function simple.readyDraw(t)
    if t>1 then
    elseif t>.5 then setColor(1,1,1,min((t-.5)/.25,1))
        printf("READY",font.Bender_B,0,0,1000,'center',0,.9,.9,500,76)
    elseif t>0 then setColor(1,1,1,min(t/.25,1))
        printf("SET",font.Bender_B,0,0,1000,'center',0,.9,.9,500,76)
    elseif t>-.5 then setColor(1,1,1,min((t+.5)/.25,1))
        printf("GO!",font.Bender_B,0,0,1000,'center',0,1.2,1.2,500,76)
    end
end

local clearTxt={
    'Single','Double','Triple','Aquad',
    'Boron','Carbon','Nitrogen','Oxygen',
    'Fluorine','Neon','Sodium','Magnesium',
    'Aluminium','Silicon','Phosphorus','Sulfur',
    'Chlorine','Argon','Potassium','Calcium','AAAUUUGGGHHH'
}
local clearClr={
    [0]={1,1,1},
    {1,1,1},{1,1,1},{1,1,1},{.5,1,.75},
    {.8,1,0},{.8,.8,.8},{.64,.6,1},{.5,.75,1},
    {.5,1,.5},{1,.9,.5},{1,1,.2},{1,1,1},
    {1,1,1},{1,1,1},{1,0,0},{.64,.6,1},
    {.75,1,.5},{1,.5,.96},{.7,.6,1},{1,.5,.4},{1,1,1}
}
local ctxt
function simple.updateClearInfo(player,mino)
    local his=player.history
    if his.line>0 or his.spin then player.clearInfo=T.copy(player.history)
        player.clearTxtTMax=his.line>0 and (his.line>=4 and 1 or his.spin and .8 or .5) or .5
        player.clearTxtTimer=player.clearTxtTMax

        local CInfo=player.clearInfo

        local t1=(CInfo.B2B>0 and CInfo.line>0 and "B2B " or "")..((CInfo.spin and CInfo.mini) and "weak " or "")
        local t2=CInfo.name
        local t3=(CInfo.spin and "-spin " or "")..(clearTxt[min(CInfo.line,#clearTxt)] or "")

        player.clearTxt:set({{1,1,1},t1,{0,0,0,0},(CInfo.spin and t2 or ""),{1,1,1},t3})

        if CInfo.spin then
        player.spinTxt.x=-player.clearTxt:getWidth()/2+gc.newText(font.Bender,t1):getWidth()+gc.newText(font.Bender,t2):getWidth()/2
        player.spinTxt.txt=gc.newText(font.Bender,t2)
        else player.spinTxt.txt=gc.newText(font.Bender) end

    else player.clearInfo.combo=his.combo player.clearInfo.wide=-1 end
    if his.PC then player.PCInfo[#player.PCInfo+1]=2.5 end
end
function simple.clearTextDraw(player)
    W,H=36*player.w,36*player.h
    local CInfo=player.clearInfo
    gc.translate(-W/2-20,-250)
    if CInfo.combo>1 then
        ctxt=""..CInfo.combo.." chain"..(CInfo.combo>19 and "?!?!" or CInfo.combo>15 and "!!" or CInfo.combo>7 and "!" or "")..(CInfo.wide==4 and "\n4-wide" or "")

        setColor(.1,.1,.1,.3)
        for i=0,3 do
            printf(ctxt,font.Bender_B,-19+i%2*6,9+6*floor(i/2),1200,'right',0,.25,.25,1200,76)
        end
        setColor(scene.time%.2<.1 and {1,1,1} or M.lerp({1,1,1},{.5,1,.75},min((CInfo.combo-8)/8,1)))
        printf(ctxt,font.Bender_B,-16,12,1200,'right',0,.25,.25,1200,76)
    end
    gc.translate(W/2+20,250)

    local alpha=min(player.clearTxtTimer*1.5/player.clearTxtTMax,1)*.9
    local s=(CInfo.line>=4 and 1-.05*player.clearTxtTimer or .5)
    local r,g,b
    if CInfo.spin and not CInfo.mini then
        local c=player.color[CInfo.name]
        r,g,b=c[1]+.3*(1-c[1]),c[2]+.3*(1-c[2]),c[3]+.3*(1-c[3])
    else
        local c=clearClr[min(CInfo.line,#clearClr)]
        r,g,b=c[1],c[2],c[3]
    end
    if CInfo.line>8 then
        setColor(r,g,b,alpha*min(CInfo.line-8,8)/96)
        for i=1,3 do
            for j=1,8 do
                local m,n=2*i*cos(j*math.pi/4),2*i*sin(j*math.pi/4)
                gc.draw(player.clearTxt,0,0,0,s,s,player.clearTxt:getWidth()/2,player.clearTxt:getHeight()/2)
            end
        end
    end
    local beta=alpha*(player.clearTxtTimer%.2>=.1 and .4 or .6)
    setColor(r,g,b,beta)
    if CInfo.wide==4 and CInfo.line==1 then printf("4-wide",font.Bender,0,-64*s-20,4000,'center',0,.333,.333,2000,76) end

    setColor(r,g,b,alpha)
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
        printf("ALL",font.Bender,0,-68,1000,'center',0,.9,.9,500,76)
        printf("CLEAR",font.Bender,0,28,1000,'center',0,.9,.9,500,76)
        gc.pop()
        end
        gc.push('transform')
        gc.scale(ti<a and (s-s*((ti-a)/a)^2) or ti<b and s or max(s+(s-1)/(c-b)*(b-ti),1))

        setColor(1,.96,.2,min(t,1)*.1)
        for j=1,8 do
            local ox,oy=4*cos(j/4*math.pi),4*sin(j/4*math.pi)
            printf("ALL",font.Bender,ox,-68+oy,1000,'center',0,.9,.9,500,76)
            printf("CLEAR",font.Bender,ox,28+oy,1000,'center',0,.9,.9,500,76)
        end
        setColor(1,.96,.2,t)
        printf("ALL",font.Bender,0,-68,1000,'center',0,.9,.9,500,76)
        printf("CLEAR",font.Bender,0,28,1000,'center',0,.9,.9,500,76)
        gc.pop()
    end
end

function simple.update(player,dt)
    local PCInfo=player.PCInfo
    for i=#PCInfo,1,-1 do PCInfo[i]=PCInfo[i]-dt
        if PCInfo[i]<=0 then rem(PCInfo,i) end
    end
    player.clearTxtTimer=max(player.clearTxtTimer-dt,0)
end

function simple.loseAnim(player)
    setColor(1,1,1,player.deadTimer*4)
    draw(simple.loseTxt,-simple.ltW/2,-simple.ltH/2)
end
function simple.winAnim(player)
    setColor(1,1,1,1-player.winTimer*4)
    draw(simple.winTxt,0,0,0,1+player.winTimer*4,1+player.winTimer*4,simple.wtW/2,simple.wtH/2)
    --printf(gts.win,font.Bender_B,0,0,400,'center',0,1+player.winTimer*4,1+player.winTimer*4,200,76)
    setColor(1,1,1)
    draw(simple.winTxt,0,0,0,1,1,simple.wtW/2,simple.wtH/2)
    --printf(gts.win,font.Bender_B,0,0,400,'center',0,1,1,200,76)
end
return simple