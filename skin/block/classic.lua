local skin={}
local COLOR=require('framework/color')
local M=myMath
local setColor,draw,setShader=gc.setColor,gc.draw,gc.setShader
local arc,circle,rect=gc.arc,gc.circle,gc.rectangle

skin.defaultTexType={
    Z=1,S=1,J=1,L=1,T=2,O=2,I=2,
    g1=1,g2=1,
    gb=1,bomb=2,

    Z5=1,S5=1,J5=1,L5=1,T5=2,I5=2,
    N =1,H =1,F =1,E =1,R =1,Y =1,
    P =1,Q =1,X =2,W =2,V =2,U =2,
}


function skin.setDropAnimTTL(player)
    return .25
end
skin.pic={gc.newImage('skin/block/classic/tex1.png'),gc.newImage('skin/block/classic/tex2.png')}
skin.curPic={gc.newImage('skin/block/classic/ctex1.png'),gc.newImage('skin/block/classic/ctex2.png')}
skin.sd=gc.newShader('shader/grayscale stain.glsl')

local skinsz=64

local bb=gc.newCanvas(36,36)
gc.setCanvas(bb)
setColor(1,1,1)
rect('fill',0,0,36,36)
gc.setCanvas()
function skin.init(player)
    player.laTimer=0
    player.laTMax=.2

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
function skin.unitDraw(player,x,y,clr,alpha,texType)
    setColor(clr[1],clr[2],clr[3],clr[4] or alpha or 1)
    setShader(skin.sd)
    draw(skin.pic[texType],36*x,-36*y,0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
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
                    draw(skin.pic[mino.texType[F[y][x].name]],36*x,-36*h,0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
                end
            end
        else h=h+1 end
    end
    h=0
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        else h=h+1
            local l=player.history.clearLine[y]
            for x=1,ceil(player.w/2) do
                if x<n*player.w/2 then
                setColor(mino.color[l[x].name])
                draw(skin.pic[mino.texType[l[x].name]],36*x,-36*h,0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)

                local x1=player.w+1-x
                setColor(mino.color[l[x1].name])
                draw(skin.pic[mino.texType[l[x1].name]],36*x1,-36*h,0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
                end
            end
        end
    end
    setShader()
end
function skin.overFieldDraw(player)
end
local t
local tau=2*math.pi
function skin.curDraw(player,piece,x,y,color,tex)
    for i=1,#piece do
        local s=.1+.15*(1-player.LTimer/player.LDelay) setColor(s,s,s)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
    end
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color)
        draw(skin.curPic[tex],36*(x+piece[i][1]),-36*(y+piece[i][2]),0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
    end
    setShader()
end
function skin.AscHoldDraw(player,piece,x,y,color,tex)
end
function skin.holdDraw(player,piece,x,y,color,canHold,tex)
    setShader(skin.sd)
    for i=1,#piece do

        if canHold then setColor(color) else setColor(.5,.5,.5) end
        draw(skin.pic[tex],36*(x+piece[i][1]),-36*(y+piece[i][2]),0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
    end
    setShader()
end
function skin.previewDraw(piece,x,y,color,tex)--设置内预览方块材质用
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color)
        draw(skin.pic[tex],36*(x+piece[i][1]),-36*(y+piece[i][2]),0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
    end
    setShader()
end
function skin.nextDraw(player,piece,x,y,color,tex)
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color)
        draw(skin.pic[tex],36*(x+piece[i][1]),-36*(y+piece[i][2]),0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
    end
    setShader()
end
function skin.loosenDraw(player,mino)
    local ls=player.loosen
    local delay=mino.rule.loosen.fallTPL
    local t=player.event[2]=='loosenDrop' and player.event[1]
        or player.event[2] and delay or 0
    local N=(delay~=0 and t) and t/delay or 0

    setShader(skin.sd)
    for i=1,#ls do
        local clr=mino.color[ls[i].info.name]
        setColor(clr[1],clr[2],clr[3],0.5)
        draw(skin.pic[mino.texType[ls[i].info.name]],36*ls[i].x,-36*(ls[i].y+N),0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
    end
    setShader()
end
function skin.ghostDraw(player,piece,x,y,color,tex)
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color[1],color[2],color[3],.5)
        draw(skin.pic[tex],36*(x+piece[i][1]),-36*(y+piece[i][2]),0,36/skinsz,36/skinsz,skinsz/2,skinsz/2)
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