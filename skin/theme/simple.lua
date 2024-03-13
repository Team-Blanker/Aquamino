local simple={}
local T,M=mytable,mymath
local setColor,rect,line,circle,printf,draw=gc.setColor,gc.rectangle,gc.line,gc.circle,gc.printf,gc.draw

local gts
function simple.init(player)
    gts=user.lang.game.theme.simple
    simple.next=gc.newText(font.Bender_B,"N E X T") simple.hold=gc.newText(font.Bender_B,"H O L D")
    simple.nextW,simple.nextH=simple.next:getWidth(),simple.next:getHeight()
    simple.holdW,simple.holdH=simple.hold:getWidth(),simple.hold:getHeight()
    simple.clearInfo=T.copy(player.history)
    simple.PCInfo={} simple.txtTimer=0 simple.txtTMax=0
    simple.parList={}
end
function simple.updateClearInfo(player,mino)
    local his=player.history
    if his.line>0 or his.spin then simple.clearInfo=T.copy(player.history) end
    if his.PC then simple.PCInfo[#simple.PCInfo+1]=3 end
    simple.txtTMax=his.line>0 and (his.line>4 and .1 or his.spin and .8 or .5) or .5
    simple.txtTimer=simple.txtTMax
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
    --printf("H O L D",font.Bender_B,-W/2-110,-375,800,'center',0,.2,.2,400,76)
    --printf("N E X T",font.Bender_B, W/2+110,-375,800,'center',0,.2,.2,400,76)
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
        printf(timeTxt,font.Consolas_B,-W/2-31+i%2*6,H/2-19+6*floor(i/2),800,'right',0,.25,.25,800,56)
    end
    setColor(.5,1,.75)
    printf(timeTxt,font.Consolas_B,-W/2-28,H/2-16,800,'right',0,.25,.25,800,56)
end
--[[function simple.overFieldDraw(player,mino)
    local his=player.history
    local w,h=player.w,player.h
    if his.x~=0 then circle('fill',36*(his.x-w/2-.5),36*(-his.y+h/2+.5),12,4) end
end]]
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
local clearTxt={'Single','Double','Triple','Aquad'} local txt
function simple.clearTextDraw(player)
    W,H=36*player.w,36*player.h
    local CInfo=simple.clearInfo
    print(next(CInfo))
    gc.translate(-W/2-20,-250)
    if CInfo.combo>1 then
        txt=""..CInfo.combo.." chain"..(CInfo.combo>19 and "?!?!" or CInfo.combo>15 and "!!" or CInfo.combo>7 and "!" or "")

        setColor(.1,.1,.1,.3)
        for i=0,3 do
            printf(txt,font.Bender_B,-19+i%2*6,9+6*floor(i/2),1200,'right',0,.25,.25,1200,76)
        end
        setColor(scene.time%.2<.1 and {1,1,1} or M.lerp({1,1,1},{.5,1,.75},min((CInfo.combo-8)/8,1)))
        printf(txt,font.Bender_B,-16,12,1200,'right',0,.25,.25,1200,76)
    end
    gc.translate(W/2+20,250)
    txt=(
        (CInfo.B2B>0 and CInfo.line>0 and "B2B " or "")
        ..(CInfo.spin and (CInfo.mini and "weak " or "")..CInfo.name.."-spin " or "")
        ..(clearTxt[min(CInfo.line,4)] or "")
    )

    local alpha=min(simple.txtTimer*1.5/simple.txtTMax,1)*.9
    --[[setColor(CInfo.line>=4 and {0,.4,.2,.3*alpha*alpha} or {.1,.1,.1,.3*alpha*alpha})
    for i=0,3 do
        printf(txt,font.Exo_2_SB,-3+i%2*6,387+6*floor(i/2),4000,'center',0,.375,.375,2000,0)
    end]]
    if CInfo.line>=4 then setColor(.5,1,.75,alpha)
    elseif CInfo.spin and not CInfo.mini then
        local c=player.color[CInfo.name]
        setColor(c[1]+.2*(1-c[1]),c[2]+.2*(1-c[2]),c[3]+.2*(1-c[3]),alpha)
    else setColor(1,1,1,alpha) end
    local s=(CInfo.line>=4 and .75 or .5)
    printf(txt,font.Bender,0,0,4000,'center',0,s,s,2000,76)

    for i=1,#simple.PCInfo do
        local t=simple.PCInfo[i]
        local ti=3-t
        local a,b,c,s=.3,.35,.4,1.35
        if ti>c then local ts=ti-c
        gc.push('transform')
        gc.scale(ts+1)
        setColor(1,.9,.2,1-3*ts)
        printf("ALL",font.Bender_B,0,-68,1000,'center',0,.9,.9,500,76)
        printf("CLEAR",font.Bender_B,0,28,1000,'center',0,.9,.9,500,76)
        gc.pop()
        end
        gc.push('transform')
        gc.scale(ti<a and (s-s*((ti-a)/a)^2) or ti<b and s or max(s+(s-1)/(c-b)*(b-ti),1))
        setColor(1,.96,.2,t>1 and min(ti*20,1) or t)
        printf("ALL",font.Bender_B,0,-68,1000,'center',0,.9,.9,500,76)
        printf("CLEAR",font.Bender_B,0,28,1000,'center',0,.9,.9,500,76)
        gc.pop()
    end
end

function simple.checkClear(player)
    local his=player.history
    if his.PC then ins(his.PCInfo,3) end
end
function simple.update(player,dt)
    local PCInfo=simple.PCInfo
    for i=#PCInfo,1,-1 do PCInfo[i]=PCInfo[i]-dt
        if PCInfo[i]<=0 then rem(PCInfo,i) end
    end
    simple.txtTimer=max(simple.txtTimer-dt,0)
end

function simple.dieAnim(player)
    setColor(1,1,1,player.deadTimer*4)
    printf(gts.lose,font.Bender_B,-200,0,400,'center',0,1,1,200,76)
end
function simple.winAnim(player)
    setColor(1,1,1,1-player.winTimer*4)
    printf(gts.win,font.Bender_B,0,0,400,'center',0,1+player.winTimer*4,1+player.winTimer*4,200,76)
    setColor(1,1,1)
    printf(gts.win,font.Bender_B,-200,0,400,'center',0,1,1,200,76)
end
return simple