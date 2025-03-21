local skin={}
local COLOR=require('framework/color')
local M=myMath
local setColor,draw,setShader=gc.setColor,gc.draw,gc.setShader
local arc,circle,rect=gc.arc,gc.circle,gc.rectangle
function skin.setDropAnimTTL(player)
    return .25
end
skin.pic=gc.newImage('skin/block/bubble/bubble.png')
skin.sd=gc.newShader('shader/grayscale stain.glsl')

local bb=gc.newCanvas(42,42)
gc.setCanvas(bb)
setColor(1,1,1)
rect('fill',0,0,42,42)
rect('fill',3,0,36,42)
rect('fill',0,3,42,36)
gc.setCanvas()
function skin.init(player)
    player.laTimer=0
    player.laTMax=.1

    player.skinSpinTimer=0
    player.spinAct=false
    player.spinOp=''
end
function skin.keyP(player,k)
    if (k=='CW' or k=='CCW' or k=='flip') and player.cur.kickOrder then
    player.spinAct=player.cur.spin
    if player.cur.spin then player.skinSpinTimer=0 end
    player.spinOp=k
    end
end
function skin.update(player,dt)
    player.laTimer=player.laTimer+dt

    if player.spinAct then player.skinSpinTimer=player.skinSpinTimer+dt
    else player.skinSpinTimer=0 end
end

function skin.afterPieceDrop(player)
    if player.history.line==0 then player.laTimer=0 end
end
function skin.unitDraw(player,x,y,clr,alpha)
    setColor(clr[1],clr[2],clr[3],clr[4] or alpha or 1)
    setShader(skin.sd)
    draw(skin.pic,36*x,-36*y,0,1,1,18,18)
    setShader()
end
function skin.fieldDraw(player,mino)
    local h=0 local n=player.event[1] and player.event[1]/player.history.CDelay

    setShader(skin.sd)
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
            for x=1,player.w do
                local F=player.field
                if F[y][x] and next(F[y][x]) then
                    setColor(mino.color[F[y][x].name])
                    draw(skin.pic,36*x,-36*h,0,1,1,18,18)
                    setColor(0,0,0,.125)
                    draw(skin.pic,36*x,-36*h,0,1,1,18,18)
                end
            end
        else h=h+1 end
    end
    setShader()
    h=0
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        else h=h+1
            setColor(1,1,1,n)
            rect('fill',18,-36*h-18,36*player.w,36)
        end
    end
end
function skin.overFieldDraw(player)
    local h=player.history local p=h.piece
    setShader(skin.sd)
    if p then
        for i=1,#p do
        setColor(1,1,1,.5*(1-player.laTimer/player.laTMax))
        draw(skin.pic,36*(p[i][1]+h.x),-36*(p[i][2]+h.y),0,1,1,18,18)
        end
    end
    setShader()
end
local t
local tau=2*math.pi
function skin.curDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
        setColor(0,0,0,(player.LTimer/player.LDelay)*.125)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
    setShader()
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    setShader(skin.sd)
    for i=1,#piece do
        if canHold then gc.setColor(color) else gc.setColor(.5,.5,.5) end
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
    setShader()
end
function skin.previewDraw(piece,x,y,color)--设置内预览方块材质用
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
    setShader()
end
function skin.nextDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
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
        draw(skin.pic,36*ls[i].x,-36*(ls[i].y+N),0,1,1,18,18)
    end
end
function skin.ghostDraw(player,piece,x,y,color)
    setShader(skin.sd)
    gc.setColor(color[1],color[2],color[3],.5)
    for i=1,#piece do
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
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
