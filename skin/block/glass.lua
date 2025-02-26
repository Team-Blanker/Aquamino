local fadeTime=1/3

local skin={}
local COLOR=require('framework/color')
local setColor,rect,draw=gc.setColor,gc.rectangle,gc.draw
local pic=gc.newImage('skin/block/glass/glass.png')
local glowpic=gc.newImage('skin/block/glass/glow.png')
local bombpic=gc.newImage('skin/block/glass/bomb.png')
pic:setFilter('nearest')

skin.defaultTexType={
    Z=1,S=1,J=1,L=1,T=1,O=1,I=1,
    g1=1,g2=1,
    gb=1,bomb=1,

    Z5=1,S5=1,J5=1,L5=1,T5=1,I5=1,
    N =1,H =1,F =1,E =1,R =1,Y =1,
    P =1,Q =1,X =1,W =1,V =1,U =1,
}

function skin.unitDraw(player,x,y,color,alpha)
    setColor(color[1],color[2],color[3],.25)
    rect('fill',-18+36*x,-18-36*y,36,36)
    setColor(color[1],color[2],color[3],color[4] or alpha or 1)
    draw(pic,-18+36*x,-18-36*y)
end
function skin.init(player)
    player.skinSpinTimer=0
    player.spinAct=false

    player.pList={}
end
local c,p
function skin.keyP(player,k,mino)
    if (k=='CW' or k=='CCW' or k=='flip') and player.cur.kickOrder and player.cur.spin then
        player.spinAct=player.cur.spin
        player.skinSpinTimer=0

        if mino.moreParticle then
            c=player.cur p=c.piece

            for i=1,#c.piece do
                local mx=k=='CW' and p[i][1]+p[i][2] or k=='CCW' and p[i][1]-p[i][2] or k=='flip' and p[i][1]*2^.5
                local my=k=='CW' and p[i][2]-p[i][1] or k=='CCW' and p[i][2]+p[i][1] or k=='flip' and p[i][2]*2^.5
                for j=1,3 do
                    vel=.5+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{name='spin',x=p[i][1]+c.x+rand()-.5,y=p[i][2]+c.y+rand()-.5,vx=vel*cos(angle)+4*mx,vy=vel*sin(angle)+4*my,timer=0})
                end
            end
        end
    end
end
local vel,angle
function skin.onLineClear(player,mino)
    if mino.moreParticle then
        for k,v in pairs(player.history.clearLine) do
            for i=1,#v do
                for j=1,4 do
                    vel=.5+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{name=v[i].name,x=i+rand()-.5,y=k+rand()-.5,vx=vel*cos(angle),vy=vel*sin(angle),timer=0})
                end
                --[[if v[i].bomb then
                    for j=1,20 do
                        vel=4+2*rand() angle=2*math.pi*rand()
                        ins(player.pList,{name=v[i].name,x=i+cos(angle),y=k+sin(angle),vx=vel*cos(angle),vy=vel*sin(angle),timer=0})
                    end
                end]]
            end
        end
    end
end
local his,p
function skin.onPieceDrop(player,mino)
    if mino.moreParticle then
        his=player.history p=his.piece
        for i=1,#his.piece do
            for j=1,2 do
                vel=.5+1*rand() angle=2*math.pi*rand()
                ins(player.pList,{name=his.name,x=p[i][1]+his.x+rand()-.5,y=p[i][2]+his.y+rand()-.5,vx=vel*cos(angle),vy=vel*sin(angle),timer=0})
            end
        end
    end
end
function skin.update(player,dt)
    if player.spinAct then player.skinSpinTimer=player.skinSpinTimer+dt
    else player.skinSpinTimer=0 end

    local pList=player.pList
    for i=#pList,1,-1 do
        pList[i].timer=pList[i].timer+dt
        if pList[i].timer>fadeTime then rem(pList,i) end
    end
end

function skin.fieldDraw(player,mino)
    local h=0 local n=player.event[1] and player.event[1]/player.history.CDelay
    local F=player.field

    gc.setBlendMode('add','alphamultiply')
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        for x=1,player.w do
            local C=mino.color[F[y][x].name]
            if F[y][x] and next(F[y][x]) and C and mino.texType[F[y][x].name]==1 then
                setColor(C)
                draw(glowpic,36*x,-36*h,0,1,1,36,36)
            end
        end
        else h=h+1
        end
    end
    gc.setBlendMode('alpha','alphamultiply')

    h=0
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        for x=1,player.w do
            local C=mino.color[F[y][x].name]
            if F[y][x] and next(F[y][x]) and C then

                setColor(C[1],C[2],C[3],.15)
                rect('fill',-18+36*x,-18-36*h,36,36)
                setColor(C)
                draw(pic,-18+36*x,-18-36*h)

                if F[y][x].bomb then
                setColor(1,1,1,.75)
                draw(bombpic,-18+36*x,-18-36*h)
                end
            end
        end
        else h=h+1
            setColor(1,1,1,n)
            rect('fill',18,-36*h-18,36*player.w,36)
        end
    end
end
local arg,c
function skin.overFieldDraw(player,mino)
    local pList=player.pList
    for i=1,#pList do
        arg=min(1-pList[i].timer/fadeTime,1)
        c=mino.color[pList[i].name]
        local sx=pList[i].x+pList[i].vx*pList[i].timer
        local sy=pList[i].y+pList[i].vy*pList[i].timer
        if pList[i].name=='spin' then setColor(1,1,1) else setColor(.25+.75*c[1],.25+.75*c[2],.25+.75*c[3]) end
        rect('fill',36*sx-3*arg,-36*sy-3*arg,6*arg,6*arg)
    end
end
function skin.curDraw(player,piece,x,y,color)
    for i=1,#piece do
        setColor(color[1],color[2],color[3],.25+.3*(1-player.LTimer/player.LDelay))
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
        setColor(color)
        draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
        if player.spinAct then
            setColor(1,1,1,1-player.skinSpinTimer*4)
            draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
        end
    end
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    for i=1,#piece do
        if canHold then setColor(color[1],color[2],color[3],.25) else setColor(.5,.5,.5,.25) end
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
        if canHold then setColor(color) else setColor(.5,.5,.5) end
        draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
    end
end
function skin.previewDraw(piece,x,y,color,tex)--设置内预览方块材质用
    for i=1,#piece do
        if tex==1 then
            setColor(color)
            draw(glowpic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,36,36)
        end
        setColor(color[1],color[2],color[3],.25)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
        setColor(color)
        draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
    end
end
function skin.nextDraw(player,piece,x,y,color,order)
    for i=1,#piece do
        setColor(color[1],color[2],color[3],.25)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
        setColor(color)
        draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
    end
end
function skin.loosenDraw(player,mino)
    local ls=player.loosen
    local delay=mino.rule.loosen.fallTPL
    local t=player.event[2]=='loosenDrop' and player.event[1]
        or player.event[2] and delay or 0
    local N=(delay~=0 and t) and t/delay or 0
    for i=1,#ls do
        local clr=mino.color[ls[i].info.name]
        setColor(clr[1],clr[2],clr[3],0.75)
        draw(pic,-18+36*ls[i].x,-18-36*(ls[i].y+N))
    end
end
function skin.dropAnim(player)
    local DA=player.dropAnim
    for i=1,#DA do
        local c=DA[i].color
        setColor(c[1],c[2],c[3],0.125*DA[i].TTL/DA[i].TMax*(1+.25*DA[i].h/DA[i].w))
        gc.setLineWidth(36)
        rect('fill',36*(DA[i].x)-18,-36*(DA[i].y+.5),36,36*DA[i].len)
    end
end
function skin.ghostDraw(player,piece,x,y,color)
    setColor(1,1,1,.75)
    for i=1,#piece do
        draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
    end
end
function skin.clearEffect(y,h,alpha,width)
end
return skin