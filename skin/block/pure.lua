local skin={}
local COLOR=require('framework/color')
local setColor,rect=gc.setColor,gc.rectangle
function skin.unitDraw(player,x,y,color,alpha)
    setColor(color[1],color[2],color[3],color[4] or alpha or 1)
    rect('fill',-18+36*x,-18-36*y,36,36)
end
function skin.fieldDraw(player,mino)
    local h=0 local n=player.event[1] and player.event[1]/player.history.CDelay
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        for x=1,player.w do
            local F=player.field
            if F[y][x] and next(F[y][x]) and player.color[F[y][x].name] then
                setColor(player.color[F[y][x].name])
                rect('fill',-18+36*x,-18-36*h,36,36)
            end
        end
        else h=h+n
            setColor(1,1,1)
            rect('fill',18,-36*h-18,36*player.w,n*36)
            if not player.fallAfterClear then h=h+1-n end
        end
    end
end
function skin.curDraw(player,piece,x,y,color)
    for i=1,#piece do
        setColor(1,1,1,1-player.LTimer/player.LDelay)
        rect('fill',36*(x+piece[i][1])-21,-36*(y+piece[i][2])-21,42,42)
    end
    for i=1,#piece do
        setColor(color[1],color[2],color[3],color[4] or alpha or 1)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
    end
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    for i=1,#piece do
        setColor(color[1],color[2],color[3],player.canHold and 1 or .4)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
    end
end
function skin.nextDraw(player,piece,x,y,color,order)
    for i=1,#piece do
        setColor(color)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
    end
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
        rect('fill',-18+36*ls[i].x,-18-36*(ls[i].y+N),36,36)
    end
end
function skin.dropAnim(player)
    local DA=player.dropAnim
    for i=1,#DA do
        local c=DA[i].color
        setColor(c[1],c[2],c[3],0.2*DA[i].TTL/DA[i].TMax*(1+.5*DA[i].h/DA[i].w))
        gc.setLineWidth(36)
        rect('fill',36*(DA[i].x)-18,-36*(DA[i].y+.5),36,36*DA[i].len)
    end
end
function skin.ghostDraw(player,piece,x,y,color)
    for i=1,#piece do
        skin.unitDraw(player,x+piece[i][1],y+piece[i][2],color,.5)
    end
end
function skin.clearEffect(y,h,alpha,width)
end
return skin