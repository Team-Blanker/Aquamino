local skin={}
local COLOR=require('framework/color')
local setColor,rect,draw=gc.setColor,gc.rectangle,gc.draw
local pic=gc.newImage('skin/block/glass/glass.png')
pic:setFilter('nearest')
function skin.unitDraw(player,x,y,color,alpha)
    setColor(color[1],color[2],color[3],.25)
    rect('fill',-18+36*x,-18-36*y,36,36)
    setColor(color[1],color[2],color[3],color[4] or alpha or 1)
    rect('fill',-18+36*x,-18-36*y,36,36)
end
local blockCanvas=gc.newCanvas(36,36)
local fieldCanvas=gc.newCanvas(36*50,36*100)--最多支持50*100场地
gc.setCanvas(blockCanvas)
setColor(1,1,1)
rect('fill',0,0,36,36)
gc.setCanvas()
function skin.fieldDraw(player,mino)
    local h=0 local n=player.event[1] and player.event[1]/player.history.CDelay
    local F=player.field

    gc.push()
    gc.origin()
    gc.setCanvas(fieldCanvas)
    gc.clear(0,0,0,0)
    for y=1,#player.field do
        if player.field[y][1] then
        for x=1,player.w do
            local C=player.color[F[y][x].name]
            if F[y][x] and next(F[y][x]) and C then
                setColor(C[1],C[2],C[3],1)
                draw(blockCanvas,36*x-36,3600-36*y-36)
            end
        end
        end
    end
    gc.setCanvas()
    gc.pop()

    setColor(1,1,1,.05)
    draw(fieldCanvas,18,-3600+18)
    for i=1,6 do  for j=1,4 do
        local a,b=i*3*cos(j*math.pi/2),i*3*sin(j*math.pi/2)
        draw(fieldCanvas,18+a,-3600+18+b)
    end  end

    h=0
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        for x=1,player.w do
            local C=player.color[F[y][x].name]
            if F[y][x] and next(F[y][x]) and C then
                setColor(C)
                draw(pic,-18+36*x,-18-36*h)
            end
        end
        else h=h+1
            setColor(1,1,1,n)
            rect('fill',18,-36*h-18,36*player.w,36)
        end
    end
end
function skin.curDraw(player,piece,x,y,color)
    for i=1,#piece do
        setColor(color[1],color[2],color[3],.25+.25*(1-player.LTimer/player.LDelay))
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36)
        setColor(color)
        draw(pic,-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]))
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
        local clr=player.color[ls[i].info.name]
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