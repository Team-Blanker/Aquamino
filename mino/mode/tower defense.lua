local M,T=mymath,mytable

local bot_cc=require'mino/bot/cc'

local rule={}

local barOrder={'Z','S','L','J','H'}
local specialBrick={'Z','S','L','J'}

--属性克制：J->Z->S->L->J
--灵感来源：水克火 火克风 风克土 土克水
local restraintOrder={Z=1,S=2,L=3,J=4}

local function checkEmpty(list)
    local k
    for i=#list,1,-1 do
        if list[i].block then return k end
        k=i
    end
    --print(k)
    return k
end

local brickW,brickH=40,8
local brickPlaceH=300

local barLvMax=5

local SBrickColor
local freq=60/128
local NColor={1,1,1} local HColor={1,1,1}
function rule.init(P,mino,modeInfo)
    HColor={1,1,1}
    rule.gameTimer=0

    mino.musInfo="龍飛 - AUTOMATA"
    scene.BG=require('BG/blank')
    mus.add('music/Hurt Record/AUTOMATA','whole','ogg',4/7,260*60/140)
    mus.start()

    mino.seqSync=true
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.enableMiniSpin=false
    P[1].preview=3 P[1].posOffset.failDrop={x=0,y=0} P[1].failDrop=false P[1].failDropTimer=0
    P[1].failDropParList={}
    for i=1,100 do
        P[1].failDropParList[i]={x=-300+600*rand(),y=-300+600*rand(),t=i/40+4*(rand()-.5),sz=120+240*rand()}
    end
    P[1].posx=-540 P[1].posy=-60
    P[2]=T.copy(P[1]) P[2].posx=540
    P[1].side='L' P[2].side='R'
    P[1].id=1 P[2].id=2
    P[1].isBot=false P[2].isBot=true P[2].FDelay=1e99

    P[1].mtp=1 P[2].mtp=1.5
    P[1].Emtp=1 P[2].Emtp=1
    P[1].Hmtp=1 P[2].Hmtp=1

    rule.freezed=false

    rule.wallBelong={L=1,R=2}
    mino.fieldScale=600/720

    mino.stacker.opList={1}

    SBrickColor=mino.color
    --bot
    rule.botThread=bot_cc.newThread(1,P,2)
    bot_cc.startThread(rule.botThread,nil)
    rule.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(P[2]),
    B2B=P[2].history.B2B>0,
    combo=P[2].history.combo,
    })
    rule.expect={}
    rule.opDelay=modeInfo.arg.bot_DropDelay
    rule.opTimer=0

    rule.botSpin=specialBrick[rand(#specialBrick)]
    rule.botspinT,rule.botspinTMax=30,30
    --攻击/防御
    rule.atk={
        L=false,R=false,nextL=nil,nextR=nil,
        switchTimer=60,switchT=60,round=1,
        atkBar=0,wheelBar=8,--攻击格格数，总格数
        wheel={--屏幕上方显示的转盘
            cur=0,next=nil,--到位前转几圈
            decided=false,
        }
    }
    rule.HP={L=100,R=100,max=100}
    --积攒条
    rule.brickBar={
        L={
            Z={lvl=0,bar=0},
            S={lvl=0,bar=0},
            L={lvl=0,bar=0},
            J={lvl=0,bar=0},
            H={lvl=0,bar=0},
        },
        R={
            Z={lvl=0,bar=0},
            S={lvl=0,bar=0},
            L={lvl=0,bar=0},
            J={lvl=0,bar=0},
            H={lvl=0,bar=0},
        },
    }
    --生成砖块
    rule.brick={}
    rule.brick.L={}
    for i=0,brickH do
        rule.brick.L[i+1]={}
        for j=0,brickW do
            rule.brick.L[i+1][j+1]={
                pos={-20*brickW-80+10+20*j,brickPlaceH+10+20*i},block=j<2 and 'H' or nil,
                hp=j<20 and 6 or 0,hpMax=j<2 and 6 or 0
            }
        end
    end
    rule.brick.R={}
    for i=0,brickH do
        rule.brick.R[i+1]={}
        for j=0,brickW do
            rule.brick.R[i+1][j+1]={
                pos={ 20*brickW+80-10-20*j,brickPlaceH+10+20*i},block=j<2 and 'H' or nil,
                hp=j<2 and 6 or 0,hpMax=j<2 and 6 or 0
            }
        end
    end

    rule.brickToBuild={
        L={N=0,Z=0,S=0,L=0,J=0,H=0},
        R={N=0,Z=0,S=0,L=0,J=0,H=0},
        index={L=rand(6),R=rand(6)}
    }
    --炮弹
    rule.bullet={L={},R={}}--存炮弹，L代表射向左边的，R同理
    rule.bulletVel=12--炮弹速度，单位是格/秒
    rule.bulletToShoot={
        L={N=0,Z=0,S=0,L=0,J=0,H=0},
        R={N=0,Z=0,S=0,L=0,J=0,H=0},
        index={L=rand(6),R=rand(6)}
    }
    --{type=(Z/S/J/L/N/H),h=20,t=.5} ZSJL 元素属性    N/H 普通/坚固
    rule.explodeAnim={}--爆炸粒子列表
    rule.explodeAnimTMax=.2
    --生成指针
    rule.pointer={
        L={phase=1,pos=1,moveT=60/128,bl=0},
        R={phase=1,pos=1,moveT=60/128,bl=0},
    }
end

local function searchBlock(side)
    local btb=rule.brickToBuild
    for i=1,#barOrder do
        btb.index[side]=btb.index[side]%#barOrder+1
        local id=barOrder[btb.index[side]]
        if btb[side][id]>0 then
            btb[side][id]=btb[side][id]-1
            return id
        end
    end
end
local function searchBullet(side)
    local bts=rule.bulletToShoot
    for i=1,#barOrder do
        bts.index[side]=bts.index[side]%#barOrder+1
        local id=barOrder[bts.index[side]]
        if bts[side][id]>0 then
            bts[side][id]=bts[side][id]-1
            return id
        end
    end
end
local function placeBlock(brick,block)
    brick.block=block
    brick.hp=block=='H' and 6 or 8
    brick.hpMax=brick.hp
end

local function bulletShoot(side,posy,type)--子弹源自哪一方，纵坐标，属性
    if not type then return end
    local bl=side=='L' and rule.bullet.R or rule.bullet.L
    table.insert(bl,{type=type,h=brickW+3,t=1/rule.bulletVel,posy=posy})
end
local function bulletCollide(bullet,brick)
    if not brick then return end
    if brick.block=='H' then brick.hp=brick.hp-1
    else
        if restraintOrder[bullet.type] then
            if restraintOrder[bullet.type]%4+1==restraintOrder[brick.block] then brick.hp=0
            else brick.hp=brick.hp-2 end
        else brick.hp=brick.hp-1 end
    end
    if brick.hp<=0 then brick.block=nil end
end

local spinStart,spinEnd=8,1.5
local abl,epp
function rule.gameUpdate(P,dt,mino)
    --bot定时操作
    rule.opTimer=rule.opTimer+dt
    if rule.opTimer>1 and rule.HP[P[2].side]>0 then
        rule.botThread.sendChannel:push({op='require'})
        local op=rule.botThread.recvChannel:demand()
        if op then
        rule.expect=op.expect
        bot_cc.operate(P[2],op,false,mino)
        rule.opTimer=rule.opTimer-rule.opDelay
        end
    end

    --游戏逻辑更新
    rule.gameTimer=rule.gameTimer+dt

    rule.botspinT=rule.botspinT-dt
    if rule.botspinT<=0 then
        rule.botspinT=rule.botspinT+rule.botspinTMax
        rule.botSpin=specialBrick[rand(#specialBrick)]
        print(rule.botSpin)
    end

    for i=1,#P do
        for k,v in pairs(rule.brickBar[P[i].side]) do
            v.bar=max(v.bar-dt*.1*(.5+.5*v.lvl),0)
            if v.bar==0 then
                if v.lvl~=0 then
                    if rule.atk[P[i].side] then
                    rule.bulletToShoot[P[i].side][k]=2^v.lvl*2
                    else
                    rule.brickToBuild[P[i].side][k]=2^v.lvl
                    end
                    rule.pointer[P[i].side].moveT=rule.pointer[P[i].side].moveT%(60/2048)
                end
                v.lvl=0
            end
        end
    end
    for k,v in pairs(rule.pointer) do
        v.moveT=v.moveT-dt
        if v.moveT<=0 then local rt=v.moveT
            local cb=searchBullet(k)
            local sb=searchBlock(k)
            if cb or sb then v.moveT=60/2048+rt else v.moveT=60/128+rt end

            bulletShoot(k,v.pos,cb)

            local eb=checkEmpty(rule.brick[k][v.pos])
            if eb then placeBlock(rule.brick[k][v.pos][eb],sb) end

            v.phase=v.phase%(2*brickH)+1
            v.pos=v.phase<=brickH and v.phase or 2*brickH+1-v.phase
        end
    end
    --炮弹碰撞
    for k,v in pairs(rule.bullet) do
        for i=#v,1,-1 do
            v[i].t=v[i].t-dt
            if v[i].t<=0 then
                if v[i].h<0 then table.remove(v,i) rule.HP[k]=rule.HP[k]-1
                else
                    local brick=rule.brick[k][v[i].posy][v[i].h]
                    if brick and brick.block then
                        abl=table.remove(v,i)
                        if abl.type=='H' then
                            for x=-2,2 do local a=2-abs(x)
                            for y=-a,a do
                                brick=rule.brick[k][abl.posy+y] and rule.brick[k][abl.posy+y][abl.h+1+x]
                                bulletCollide(abl,brick)
                                ins(rule.explodeAnim,{
                                    x=k=='L' and -(20*brickW+100)+20*abl.h or (20*brickW+100)-20*abl.h,
                                    y=brickPlaceH+20*abl.posy-10,
                                    t=rule.explodeAnimTMax
                                })
                            end
                            end
                        else bulletCollide(abl,brick) end
                    else v[i].h=v[i].h-1 v[i].t=v[i].t+1/rule.bulletVel end
                end
            end
        end
    end

    for i=#rule.explodeAnim,1,-1 do
        epp=rule.explodeAnim[i]
        epp.t=epp.t-dt
        if epp.t<=0 then rem(rule.explodeAnim,i) end
    end

    --若有一方失败
    if not rule.freezed then
    for i=1,#P do
        if rule.HP[P[i].side]<=0 then
            for j=1,#P do mino.addEvent(P[j],1e99,'freeze') end
            rule.freezed=true
        break end
    end
    end

    for i=1,#P do
        P[i].failDrop=rule.HP[P[i].side]<=0
        if P[i].failDrop then
            P[i].failDropTimer=P[i].failDropTimer+dt
            P[i].posOffset.failDrop.y=300*P[i].failDropTimer^2
        end
    end

    --随机决定攻防，转盘旋转
    local a=rule.atk
    if not rule.freezed then a.switchTimer=a.switchTimer-dt end
    if a.switchTimer<=spinStart and not a.wheel.next then
        a.wheel.next=10+6*rand()
    elseif a.switchTimer<=spinEnd and not a.wheel.decided then
        a.nextL,a.nextR=(a.wheel.cur+a.wheel.next+.5)%1<a.atkBar/a.wheelBar,(a.wheel.cur+a.wheel.next)%1<a.atkBar/a.wheelBar
        a.wheel.decided=true
    elseif a.switchTimer<=0 then
        a.round=a.round+1
        a.atkBar=a.atkBar+1
        a.wheel.cur=(a.wheel.cur+a.wheel.next)%1 a.wheel.next=nil
        a.L,a.R=a.nextL,a.nextR a.wheel.decided=false
        a.switchTimer=a.switchTimer+a.switchT
    end

    local b=abs(rule.gameTimer%(2*freq)/freq-1)
    HColor[1],HColor[2],HColor[3]=b,b,b
end

local bb
local function addBar(side,k,v)
    bb=rule.brickBar[side]
    if bb[k].lvl<barLvMax then bb[k].bar=bb[k].bar+v end
end
function rule.onLineClear(player,mino)
    --[[if player.name==1 then
        b.L[#b.L+1]={}
        e=b.L[#b.L]
        e.body=lp.newBody(rule.world,0,0,'dynamic')
        e.shape=lp.newCircleShape(16)
        e.fixture=love.physics.newFixture(e.body,e.shape,2000)
    else
    end]]
    local his=player.history
    local sd=player.side
    local PCmtp=his.PC and 3 or 1
    if his.spin then
        if T.include(specialBrick,his.name) then
            addBar(sd,his.name,his.combo<3 and 1.25 or 0.25)
            addBar(sd,'H',.125*his.line*player.Hmtp*PCmtp)
        else
            addBar(sd,'H',.25*his.line*player.Hmtp)
            if player.isBot then
                addBar(sd,rule.botSpin,.75)
            else
                for k,v in pairs(specialBrick) do
                    addBar(sd,v,.125*player.mtp)
                end
            end
        end
    elseif his.line==4 then
        if player.isBot and not rule.atk[player.side] then
            addBar(sd,'H',.25*player.Hmtp*PCmtp)
            addBar(sd,rule.botSpin,.75)
        else addBar(sd,'H',.625*player.Hmtp*PCmtp) end
        for k,v in pairs(specialBrick) do
            addBar(sd,v,.25*player.mtp)
        end
    else
        if T.include(specialBrick,his.name) then
            addBar(sd,his.name,.125*his.line*player.mtp/his.combo)
        end
        for k,v in pairs(specialBrick) do
            addBar(sd,v,.125*his.line*player.mtp/his.combo)
        end
    end
end
function rule.afterPieceDrop(player,mino)
    for k,v in pairs(rule.brickBar[player.side]) do
        while v.bar>=1 do v.bar=v.bar-.5 v.lvl=min(v.lvl+1,barLvMax) end
    end

    --给bot刷新数据
    if player==mino.player[2] then
    rule.botThread.sendChannel:push({op='send',
    boolField=bot_cc.renderField(player),
    B2B=player.history.B2B>0,
    combo=player.history.combo,
    garbage=0
    })
    end
end
function rule.onNextGen(player,nextStart,mino)
    if player==mino.player[2] then
    bot_cc.sendNext(rule.botThread,player,nextStart)
    end
end

local draw,rect,line,setColor,setLineWidth=gc.draw,gc.rectangle,gc.line,gc.setColor,gc.setLineWidth
--800*240
local lpic=gc.newImage('pic/mode/core destruction/ldpic.png')
local rpic=gc.newImage('pic/mode/core destruction/rdpic.png')

local ATKTxt={txt=gc.newText(font.Bender,'ATK')}
ATKTxt.w,ATKTxt.h=ATKTxt.txt:getDimensions()
local DEFTxt={txt=gc.newText(font.Bender,'DEF')}
DEFTxt.w,DEFTxt.h=DEFTxt.txt:getDimensions()
local tau=2*math.pi

local e

local epp,epw,hpr,rsz,txt
local atk,atkr
function rule.underAllDraw()
    --说明图
    draw(lpic,-540,-480,0,1,1,400,120)
    draw(rpic, 540,-480,0,1,1,400,120)
    --砖块
    for i=1,brickH do
        for j=1,brickW do
            e=rule.brick.L[i][j]

            setColor(1,.5,0,.08+(i+j)%2*.08)
            rect('fill',e.pos[1]-10,e.pos[2]-10,20,20)

            if e.block then
                if     e.block=='N' then setColor(NColor)
                elseif e.block=='H' then setColor(HColor)
                else   setColor(SBrickColor[e.block]) end

                hpr=e.hp/e.hpMax
                rsz=20-10*hpr
                gc.setLineWidth(10*hpr)
                rect('line',e.pos[1]-rsz/2,e.pos[2]-rsz/2,rsz,rsz)
            end
        end
    end

    for i=1,brickH do
        for j=1,brickW do
            e=rule.brick.R[i][j]

            setColor(0,.5,1,.08+(i+j)%2*.08)
            rect('fill',e.pos[1]-10,e.pos[2]-10,20,20)

            if e.block then
                if     e.block=='N' then setColor(NColor)
                elseif e.block=='H' then setColor(HColor)
                else   setColor(SBrickColor[e.block]) end

                hpr=e.hp/e.hpMax
                rsz=20-10*hpr
                gc.setLineWidth(10*hpr)
                rect('line',e.pos[1]-rsz/2,e.pos[2]-rsz/2,rsz,rsz)
            end
        end
    end

    --炮弹
    local rbl,rbr=rule.bullet.L,rule.bullet.R
    for i=1,#rbl do
        e=rbl[i]
        if     e.type=='N' then setColor(NColor)
        elseif e.type=='H' then setColor(HColor)
        else   setColor(SBrickColor[e.type]) end
        gc.circle('fill',-20*(brickW+4)+(e.h+e.t*rule.bulletVel)*20,brickPlaceH-10+20*e.posy,6)
    end
    for i=1,#rbr do
        e=rbr[i]
        if     e.type=='N' then setColor(NColor)
        elseif e.type=='H' then setColor(HColor)
        else   setColor(SBrickColor[e.type]) end
        gc.circle('fill', 20*(brickW+4)-(e.h+e.t*rule.bulletVel)*20,brickPlaceH-10+20*e.posy,6)
    end
    --高级炮弹爆炸动画
    setColor(1,1,1)
    for i=1,#rule.explodeAnim do
        epp=rule.explodeAnim[i]
        epw=epp.t/rule.explodeAnimTMax
        gc.setLineWidth(10*epw)
        gc.circle('line',epp.x,epp.y,30-20*epw,4)
    end

    --指针
    local lp,rp=20*rule.pointer.L.pos,20*rule.pointer.R.pos
    if rule.atk.L then setColor(1,.5,0) gc.polygon('fill',  0,brickPlaceH+lp,  0,brickPlaceH-20+lp, 10,brickPlaceH-10+lp)
    else               setColor(1,1,1)  gc.polygon('fill',-10,brickPlaceH+lp,-10,brickPlaceH-20+lp,-20,brickPlaceH-10+lp)
    end
    if rule.atk.R then setColor(0,.5,1) gc.polygon('fill',  0,brickPlaceH+rp,  0,brickPlaceH-20+rp,-10,brickPlaceH-10+rp)
    else               setColor(1,1,1)  gc.polygon('fill', 10,brickPlaceH+rp, 10,brickPlaceH-20+rp, 20,brickPlaceH-10+rp)
    end

    --转盘
    atk=rule.atk atkr=atk.wheel
    for i=1,atk.wheelBar do
        local a1,a2=(i-1)/atk.wheelBar,i/atk.wheelBar
        local rn=atkr.next and atkr.next*(1-max((atk.switchTimer-spinEnd)/(spinStart-spinEnd),0)^2) or 0
        if atk.wheelBar+1-i<=atk.atkBar then setColor(1,.2,.2) else setColor(.5,1,.875) end
        gc.arc('fill',0,-390,100,(atkr.cur+a1+rn)*tau,(atkr.cur+a2+rn)*tau,1)
    end

    if atk.switchTimer>spinStart then
    setColor(.25,.25,.25,.5)
    gc.arc('fill',0,-390,100,-.25*tau,((atk.switchTimer-spinStart)/(atk.switchT-spinStart)-.25)*tau,64)
    end

    gc.setLineWidth(7.5*2^.5)
    setColor(1,.5,0) gc.circle('fill',-135,-390,10,4) gc.line(-155,-410,-175,-390,-155,-370)
    setColor(0,.5,1) gc.circle('fill', 135,-390,10,4) gc.line( 155,-410, 175,-390, 155,-370)
    --当前状态，攻/防
    local st=rule.atk.switchTimer-rule.atk.switchT
    if rule.atk.L then
        setColor(1,.2,.2)
        draw(ATKTxt.txt,-100,-100,0,.75,.75,ATKTxt.w/2,ATKTxt.h/2)
        setColor(1,.2,.2,1+2*st)
        draw(ATKTxt.txt,-100,-100,0,.75-.75*st,.75-.5*st,ATKTxt.w/2,ATKTxt.h/2)
    else
        setColor(.5,1,.875)
        draw(DEFTxt.txt,-100,-100,0,.75,.75,DEFTxt.w/2,DEFTxt.h/2)
        setColor(.5,1,.875,1+2*st)
        draw(DEFTxt.txt,-100,-100,0,.75-.75*st,.75-.5*st,DEFTxt.w/2,DEFTxt.h/2)
    end
    if rule.atk.R then
        setColor(1,.2,.2)
        draw(ATKTxt.txt, 100, 100,0,.75,.75,ATKTxt.w/2,ATKTxt.h/2)
        setColor(1,.2,.2,1+2*st)
        draw(ATKTxt.txt, 100, 100,0,.75-.75*st,.75-.5*st,ATKTxt.w/2,ATKTxt.h/2)
    else
        setColor(.5,1,.875)
        draw(DEFTxt.txt, 100, 100,0,.75,.75,DEFTxt.w/2,DEFTxt.h/2)
        setColor(.5,1,.875,1+2*st)
        draw(DEFTxt.txt, 100, 100,0,.75-.75*st,.75-.5*st,DEFTxt.w/2,DEFTxt.h/2)
    end
    setLineWidth(6)
    setColor(1,1,1)
    line(-120,120,120,-120)
    --当前轮数
    setColor(1,1,1)
    gc.printf(string.format("Round %d",rule.atk.round),font.Bender,0,-260,20000,'center',0,.5,.5,10000,72)
end
function rule.underFieldDraw(player,mino)
    w,h=player.w,player.h
    local c
    for i=1,#barOrder do
        local o=barOrder[i]
        if     o=='N' then c=NColor
        elseif o=='H' then c=HColor
        else   c=mino.color[o] end

        local bb=rule.brickBar[player.side][o]
        setColor(c[1],c[2],c[3],.3)
        rect('fill',18*player.w+30,18*player.h-40*i-10,160,30)
        setColor(c)
        rect('fill',18*player.w+30,18*player.h-40*i-10,160*bb.bar,30)
        setColor(1-c[1],1-c[2],1-c[3])
        gc.printf(string.format(bb.lvl==barLvMax and "%d [MAX]" or "%d",2^bb.lvl),font.Bender_B,18*player.w+35,18*player.h-40*i+5,2000,'left',0,.2,.2,0,72)
    end
    setColor(1,1,1)
    gc.printf(string.format("HP\n%d/%d",rule.HP[player.side],rule.HP.max),font.Bender,18*player.w+35,0,2000,'left',0,.33,.33,0,72)
end
function rule.overAllDraw()
    --下一轮是攻是防
    local k=atk.switchTimer>=spinEnd/3 and max(atk.switchTimer/spinEnd-2/3,0)*3 or 1-atk.switchTimer/spinEnd*3
    local y=k^3*-600-60

    if rule.atk.nextL then txt=ATKTxt else txt=DEFTxt end
    setColor(.1,.1,.1,.3)
    for i=-3,3,6 do for j=-3,3,6 do
    draw(txt.txt,-540+i,y+j,0,.75,.75,txt.w/2,txt.h/2)
    end end
    if rule.atk.nextL then setColor(1,.2,.2) else setColor(.5,1,.875) end
    draw(txt.txt,-540,y,0,.75,.75,txt.w/2,txt.h/2)

    if rule.atk.nextR then txt=ATKTxt else txt=DEFTxt end
    setColor(.1,.1,.1,.3)
    for i=-3,3,6 do for j=-3,3,6 do
    draw(txt.txt, 540+i,y+j,0,.75,.75,txt.w/2,txt.h/2)
    end end
    if rule.atk.nextR then setColor(1,.2,.2) else setColor(.5,1,.875) end
    draw(txt.txt, 540,y,0,.75,.75,txt.w/2,txt.h/2)
end

local fdt,fdp,pszt
function rule.overFieldDraw(player,mino)
    setColor(1,1,1)
    if player.failDrop then
        fdt=player.failDropTimer
        for i=1,#player.failDropParList do
            fdp=player.failDropParList[i]
            if fdt>=fdp.t and fdt<=fdp.t+.2 then pszt=(fdt-fdp.t)/.2
                gc.setLineWidth(fdp.sz*.25*(1-pszt))
                gc.circle('line',fdp.x,fdp.y,fdp.sz*pszt)
            end
        end
    end
end

function rule.exit()
    bot_cc.destroyThread(rule.botThread)
end
return rule