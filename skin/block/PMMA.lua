local fadeTime=.75

local skin={}
local COLOR=require('framework/color')
local fLib=require'mino/fieldLib'
local M=myMath
local setColor,setLineWidth,draw,setShader=gc.setColor,gc.setLineWidth,gc.draw,gc.setShader
local arc,circle,rect=gc.arc,gc.circle,gc.rectangle
function skin.setDropAnimTTL(player)
    return .25
end
skin.basepic=gc.newImage('skin/block/PMMA/base.png')
skin.shadepic=gc.newImage('skin/block/PMMA/shade.png')
skin.edgepic=gc.newImage('skin/block/PMMA/edge.png')
skin.basepic:setFilter('nearest')
skin.edgepic:setFilter('nearest')

skin.sd=gc.newShader('shader/grayscale stain.glsl')

local bb=gc.newCanvas(4,4)
gc.setCanvas(bb)
gc.clear(1,1,1)
gc.setCanvas()
function skin.init(player)
    player.laTimer=0
    player.laTMax=.1

    player.skinSpinTimer=0
    player.spinAct=false
    player.pList={}
end
local c,p
local vel,angle
function skin.keyP(player,k,mino)
    c=player.cur p=c.piece
    if (k=='CW' or k=='CCW' or k=='flip') and player.cur.kickOrder and player.cur.spin then
        player.spinAct=player.cur.spin
        player.skinSpinTimer=0

        for i=1,#c.piece do
            local mx=k=='CW' and p[i][1]+p[i][2] or k=='CCW' and p[i][1]-p[i][2] or k=='flip' and p[i][1]*2^.5
            local my=k=='CW' and p[i][2]-p[i][1] or k=='CCW' and p[i][2]+p[i][1] or k=='flip' and p[i][2]*2^.5
            for j=1,4 do
                vel=8*rand()-4 angle=2*math.pi*rand()
                ins(player.pList,{x=p[i][1]+c.x+rand()-.5,y=p[i][2]+c.y+rand()-.5,vx=vel*cos(angle)+4*mx,vy=vel*sin(angle)+4*my,t=0})
            end
        end
    end
    if (k=='ML' or k=='MR') and not c.moveSuccess then
        local d=k=='ML' and -1 or 1
        local ay=(mino.smoothAnimAct and mino.smoothFallType==2 and player.FDelay~=0) and player.FTimer/player.FDelay or 0
        for i=1,#p do
            if not fLib.isAir(player,c.x+p[i][1]+d,c.y+p[i][2]) then
                for j=1,rand(2) do
                    vel=1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x+.5*d,y=p[i][2]+c.y-ay+rand()-.5,vx=vel*cos(angle)-d,vy=vel*sin(angle),t=0})
                end
            end
        end
    end
end
function skin.onPieceMove(player,mino,dx,dy,landed)
    if dx~=0 then
        c=player.cur p=c.piece
        for i=1,#p do
            --下方摩擦
            if not fLib.isAir(player,c.x+p[i][1],c.y+p[i][2]-1) then
                for j=1,1 do
                    vel=1+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x+rand()-.5,y=p[i][2]+c.y-.5,vx=dx*5+vel*cos(angle),vy=vel*sin(angle),t=0})
                end
            end
            if not fLib.isAir(player,c.x+p[i][1]-dx,c.y+p[i][2]-1) then
                for j=1,1 do
                    vel=1+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x-dx+rand()-.5,y=p[i][2]+c.y-.5,vx=dx*5+vel*cos(angle),vy=vel*sin(angle),t=0})
                end
            end
            --上方摩擦
            if not fLib.isAir(player,c.x+p[i][1],c.y+p[i][2]+1) then
                for j=1,(rand()<.25 and 1 or 0) do
                    vel=1+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x+rand()-.5,y=p[i][2]+c.y+.5,vx=dx*5+vel*cos(angle),vy=vel*sin(angle),t=0})
                end
            end
            if not fLib.isAir(player,c.x+p[i][1]-dx,c.y+p[i][2]+1) then
                for j=1,(rand()<.25 and 1 or 0) do
                    vel=2+2*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x-dx+rand()-.5,y=p[i][2]+c.y+.5,vx=dx*5+vel*cos(angle),vy=vel*sin(angle),t=0})
                end
            end
        end
    end
    if dy~=0 then
        c=player.cur p=c.piece
        for i=1,#p do
            --左侧摩擦
            if not fLib.isAir(player,c.x+p[i][1]-1,c.y+p[i][2]) then
                for j=1,(rand()<.25 and 1 or 0) do
                    vel=1+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x-.5,y=p[i][2]+c.y+rand()-.5,vx=vel*cos(angle)+.25,vy=dy*8+vel*sin(angle),t=0})
                end
            end
            if not fLib.isAir(player,c.x+p[i][1]-1,c.y+p[i][2]-dy) then
                for j=1,(rand()<.25 and 1 or 0) do
                    vel=1+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x-.5,y=p[i][2]+c.y-dy+rand()-.5,vx=vel*cos(angle)+.25,vy=dy*8+vel*sin(angle),t=0})
                end
            end
            --右侧摩擦
            if not fLib.isAir(player,c.x+p[i][1]+1,c.y+p[i][2]) then
                for j=1,(rand()<.25 and 1 or 0) do
                    vel=1+1*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x+.5,y=p[i][2]+c.y+rand()-.5,vx=vel*cos(angle)-.25,vy=dy*8+vel*sin(angle),t=0})
                end
            end
            if not fLib.isAir(player,c.x+p[i][1]+1,c.y+p[i][2]-dy) then
                for j=1,(rand()<.25 and 1 or 0) do
                    vel=2+2*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=p[i][1]+c.x+.5,y=p[i][2]+c.y-dy+rand()-.5,vx=vel*cos(angle)-.25,vy=dy*6+vel*sin(angle),t=0})
                end
            end
        end
    end
end
local his,p
function skin.onPieceDrop(player,mino)
    his=player.history p=his.piece
    for i=1,#his.piece do
        local bt=fLib.blockType(player,p[i][1]+his.x,p[i][2]+his.y-1)
        if next(bt) and bt.id~=player.stat.block then
            for j=1,2+rand(0,2) do
                vel=4*rand() angle=2*math.pi*rand()
                ins(player.pList,{x=p[i][1]+his.x+rand()-.5,y=p[i][2]+his.y-.5,vx=vel*cos(angle),vy=vel*sin(angle)+1,t=0})
            end
        end
    end
end
function skin.onLineClear(player,mino)
    for k,v in pairs(player.history.clearLine) do
        for i=1,#v do
            for j=1,4 do
                vel=4*rand() angle=2*math.pi*rand()
                ins(player.pList,{x=i+rand()-.5,y=k+rand()-.5,vx=vel*cos(angle),vy=vel*sin(angle),t=0})
            end
            if v[i].bomb then
                for j=1,32 do
                    vel=16*rand() angle=2*math.pi*rand()
                    ins(player.pList,{x=i+.5*cos(angle),y=k+rand()-.5,vx=vel*cos(angle),vy=vel*sin(angle),t=0})
                end
            end
        end
    end
end
function skin.update(player,dt)
    player.laTimer=player.laTimer+dt

    if player.spinAct then player.skinSpinTimer=player.skinSpinTimer+dt
    else player.skinSpinTimer=0 end

    local pList=player.pList
    for i=#pList,1,-1 do
        pList[i].t=pList[i].t+dt
        pList[i].vy=pList[i].vy-6*dt
        pList[i].x=pList[i].x+pList[i].vx*dt
        pList[i].y=pList[i].y+pList[i].vy*dt
        if pList[i].t>fadeTime then rem(pList,i) end
    end
end

function skin.afterPieceDrop(player)
    if player.history.line==0 then player.laTimer=0 end
end
function skin.unitDraw(player,x,y,clr,alpha)
    setColor(clr[1],clr[2],clr[3],clr[4] or alpha or 1)
    rect('fill',-18+36*x+1,-18-36*y+1,34,34)
    setShader(skin.sd)
    draw(skin.basepic,36*x,-36*y,0,.5,.5,36,36)
    draw(skin.shadepic,36*x,-36*y,0,.5,.5,36,36)
    draw(skin.edgepic,36*x,-36*y,0,.5,.5,36,36)
    setShader()
end
function skin.fieldDraw(player,mino)
    local h=0 local n=player.event[1] and player.event[1]/player.history.CDelay

    setShader(skin.sd)
    local F=player.field
    for y=1,#F do
        if F[y][1] then h=h+1
            for x=1,player.w do
                if F[y][x] and next(F[y][x]) then
                    setColor(mino.color[F[y][x].name])
                    draw(skin.basepic,36*x,-36*y,0,.5,.5,36,36)
                    draw(skin.shadepic,36*x,-36*y,0,.5,.5,36,36)
                    draw(skin.edgepic,36*x,-36*y,0,.5,.5,36,36)
                end
            end
        else h=h+1 end
    end
    setShader()
    h=0
    for y=1,#F do
        if F[y][1] then h=h+1
        setColor(1,1,1)
        setLineWidth(3)
        for x=1,player.w do
            if F[y][x] and F[y][x].bomb then
                circle('line',36*x,-36*h,12,4)
            end
        end
        else h=h+1
            setColor(1,1,1,n)
            rect('fill',18,-36*h-18,36*player.w,36)
        end
    end
end
local laCanvas=gc.newCanvas(36,36)
function skin.overFieldDraw(player,mino)
    local h=player.history local p=h.piece
    if p then
        gc.push()
        gc.origin()
        gc.setCanvas(laCanvas)
        gc.clear(0,0,0,0)
        gc.setColor(1,1,1)
        gc.rectangle('fill',(-.5+1.5*(player.laTimer/player.laTMax))*36,0,18,36)
        --gc.rectangle('fill',0,0,36,36)
        gc.setDefaultCanvas()
        gc.pop()

        for i=1,#p do
        gc.setColor(1,1,1,.5)
        gc.draw(laCanvas,36*(p[i][1]+h.x),-36*(p[i][2]+h.y),0,1,1,18,18)
        end
    end
    local pList=player.pList
    for i=1,#pList do
        arg=min(1-pList[i].t/fadeTime,1)

        if pList[i].color then setColor(pList[i].color)
        else setColor(1,1,1)
        end
        local s=1-pList[i].t/fadeTime
        circle('fill',36*pList[i].x,-36*pList[i].y,s^.5*2)
        if pList[i].color then setColor(pList[i].color[1],pList[i].color[2],pList[i].color[3],.5)
        else setColor(1,1,1,.5)
        end
        circle('fill',36*pList[i].x,-36*pList[i].y,s^.5*3)
    end
end
local t
local tau=2*math.pi
function skin.curDraw(player,piece,x,y,color)
    local s=2/3+1/3*(1-player.LTimer/player.LDelay)^.5
    local r,g,b=color[1]*s,color[2]*s,color[3]*s
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(r,g,b)
        draw(skin.basepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.shadepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.edgepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    setShader(skin.sd)
    for i=1,#piece do
        if canHold then gc.setColor(color) else gc.setColor(.5,.5,.5) end
        draw(skin.basepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.shadepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.edgepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.previewDraw(piece,x,y,color)--设置内预览方块材质用
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.basepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.shadepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.edgepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.nextDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.basepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.shadepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.edgepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.loosenDraw(player,mino)
    local ls=player.loosen
    local delay=mino.rule.loosen.fallTPL
    local t=player.event[2]=='loosenDrop' and player.event[1]
        or player.event[2] and delay or 0
    local N=(delay~=0 and t) and t/delay or 0
    for i=1,#ls do
        local clr=mino.color[ls[i].info.name]
        setColor(clr[1],clr[2],clr[3],0.5)
        draw(skin.basepic,36*ls[i].x,-36*(ls[i].y+N),0,.5,.5,36,36)
        draw(skin.shadepic,36*ls[i].x,-36*(ls[i].y+N),0,.5,.5,36,36)
        draw(skin.edgepic,36*ls[i].x,-36*(ls[i].y+N),0,.5,.5,36,36)
    end
end
function skin.ghostDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color[1],color[2],color[3],.5)
        draw(skin.basepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.shadepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
        draw(skin.edgepic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.setDropAnimTTL(player,mino)
    return .15*player.history.dropHeight/player.h
end
function skin.dropAnim(player)
    local DA=player.dropAnim
    for i=1,#DA do
        local t=DA[i].TTL/DA[i].TMax
        local l=DA[i].len
        local c=DA[i].color
        setColor(c[1],c[2],c[3],.125*t*(1+.5*DA[i].h/DA[i].w))
        gc.setLineWidth(36)
        rect('fill',36*(DA[i].x)-18,36*(-DA[i].y+.5+l*(1-t)),36,36*l*t)
    end
end
function skin.clearEffect(y,h,alpha,width)
end
return skin