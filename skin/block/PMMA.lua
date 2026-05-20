local fadeTime=1/3

local skin={}
local COLOR=require('framework/color')
local M=myMath
local setColor,draw,setShader=gc.setColor,gc.draw,gc.setShader
local arc,circle,rect=gc.arc,gc.circle,gc.rectangle
function skin.setDropAnimTTL(player)
    return .25
end
skin.basepic=gc.newImage('skin/block/PMMA/base.png')
skin.shadepic=gc.newImage('skin/block/PMMA/shade.png')
skin.edgepic=gc.newImage('skin/block/PMMA/edge.png')
skin.basepic:setFilter('nearest')
skin.edgepic:setFilter('nearest')

skin.bombpic=gc.newImage('skin/block/PMMA/bomb.png')
skin.sd=gc.newShader('shader/grayscale stain.glsl')

local bb=gc.newCanvas(36,36)
gc.setCanvas(bb)
setColor(1,1,1)
rect('fill',0,0,36,36)
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
                    ins(player.pList,{name=c.name,x=p[i][1]+c.x+rand()-.5,y=p[i][2]+c.y+rand()-.5,vx=vel*cos(angle)+4*mx,vy=vel*sin(angle)+4*my,t=0})
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
        for x=1,player.w do
            if F[y][x] and F[y][x].bomb then
                setColor(1,1,1)
                draw(skin.bombpic,36*x,-36*h,0,.5,.5,36,36)
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

        local sx=pList[i].x+pList[i].vx*pList[i].t
        local sy=pList[i].y+pList[i].vy*pList[i].t
        if pList[i].color then setColor(pList[i].color)
        else c=mino.color[pList[i].name] setColor(.5+.5*c[1],.5+.5*c[2],.5+.5*c[3],1-pList[i].t/fadeTime)
        end
        circle('fill',36*sx,-36*sy,6,4)
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