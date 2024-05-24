local skin={}
local COLOR=require('framework/color')
local M=mymath
local setColor,draw,setShader,rect=gc.setColor,gc.draw,gc.setShader,gc.rectangle

function skin.setDropAnimTTL(player)
    return .25
end
skin.pic=gc.newImage('skin/block/glossy/glossy.png')
--skin.pic:setFilter('nearest')
local sd=fs.newFile('shader/grayscale stain.glsl'):read()
skin.sd=gc.newShader(sd)
function skin.init(player)
    player.laTimer=0
    player.laTMax=.1
end
function skin.update(player,dt)
    player.laTimer=player.laTimer+dt
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
                    gc.setColor(player.color[F[y][x].name])
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
local laCanvas=gc.newCanvas(36,36)
function skin.overFieldDraw(player)
    local h=player.history local p=h.piece
    if p then
        gc.push()
        gc.origin()
        gc.setCanvas(laCanvas)
        gc.clear(0,0,0,0)
        gc.setColor(1,1,1)
        gc.rectangle('fill',(-.5+1.5*(player.laTimer/player.laTMax))*36,0,18,36)
        --gc.rectangle('fill',0,0,36,36)
        gc.setCanvas()
        gc.pop()

        for i=1,#p do
        gc.setColor(1,1,1,.5)
        gc.draw(laCanvas,36*(p[i][1]+h.x),-36*(p[i][2]+h.y),0,1,1,18,18)
        end
    end
end
function skin.curDraw(player,piece,x,y,color)
    for i=1,#piece do
        setColor(1,1,1,1-player.LTimer/player.LDelay)
        rect('fill',36*(x+piece[i][1])-18,-36*(y+piece[i][2])-21,36,42)
        rect('fill',36*(x+piece[i][1])-21,-36*(y+piece[i][2])-18,42,36)
    end
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
    setShader()
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(canHold and color or {.5,.5,.5})
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
    setShader()
end
function skin.nextDraw(player,piece,x,y,color,order)
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
        local clr=player.color[ls[i].info.name]
        setColor(clr[1],clr[2],clr[3],0.5)
        draw(skin.pic,36*ls[i].x,-36*(ls[i].y+N),0,1,1,18,18)
    end
end
function skin.ghostDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color[1],color[2],color[3],.5)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
    setShader()
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
function skin.clearEffect(y,h,alpha,width)
end
return skin