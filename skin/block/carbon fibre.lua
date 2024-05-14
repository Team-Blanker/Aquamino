local skin={}
skin.sticker=gc.newImage('skin/block/carbon fibre/sticker1.png')
skin.sticker:setFilter('nearest')
skin.shadow=gc.newImage('skin/block/carbon fibre/ghost.png')

local ins,rem=table.insert,table.remove
local rect,setColor=gc.rectangle,gc.setColor

local stickerTTL=.5
local fadeTime=.2

function skin.init(player)
    player.stickerList={}
end
function skin.onLineClear(player)
    for k,v in pairs(player.history.clearLine) do
        for i=1,#v do
            if not v[i].loosen then ins(player.stickerList,{x=i,y=k,vx=3*(rand()-.5),avel=1.5*(rand()-.5),timer=0}) end
        end
    end
end
function skin.onLoose(player,lBlock)
    for i=1,#lBlock do
        if not lBlock[i].info.loosen then
        ins(player.stickerList,{x=lBlock[i].x,y=lBlock[i].y,vx=3*(rand()-.5),avel=1.5*(rand()-.5),timer=0})
        end
    end
end
function skin.unitDraw(player,x,y,color,alpha)
    setColor(color[1],color[2],color[3],alpha)
    rect('fill',-18+36*x,-18-36*y,36,36,4)
end
function skin.update(player,dt)
    local sList=player.stickerList
    for i=#sList,1,-1 do
        sList[i].timer=sList[i].timer+dt
        if sList[i].timer>stickerTTL then rem(sList,i) end
    end
end
function skin.fieldDraw(player,mino)
    local h=0 local n=player.event[1] and player.event[1]/player.history.CDelay
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        for x=1,player.w do
            local F=player.field
            if F[y][x] and next(F[y][x]) then
                setColor(player.color[F[y][x].name])
                rect('fill',-18+36*x,-18-36*h,36,36,4)
                if not F[y][x].loosen then setColor(1,1,1) gc.draw(skin.sticker,36*x,-36*h,0,1,1,18,18) end
            end
        end
        else h=h+n gc.push()
            gc.translate(18,-36*h-18)
            setColor(1,1,1)
            rect('fill',0,0,36*player.w,n*36)
        gc.pop() end
    end
end
function skin.curDraw(player,piece,x,y,clr)
    for i=1,#piece do
        setColor(1,1,1,1-player.LTimer/player.LDelay)
        rect('fill',36*(x+piece[i][1])-21,-36*(y+piece[i][2])-21,42,42,7)
    end
    for i=1,#piece do
        setColor(clr)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36,4)
        setColor(1,1,1) gc.draw(skin.sticker,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    for i=1,#piece do
        if canHold then setColor(color) else setColor(.5,.5,.5) end
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36,4)
        setColor(1,1,1) gc.draw(skin.sticker,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
    end
end
function skin.nextDraw(player,piece,x,y,color,order)
    for i=1,#piece do
        setColor(color)
        rect('fill',-18+36*(x+piece[i][1]),-18-36*(y+piece[i][2]),36,36,4)
        setColor(1,1,1) gc.draw(skin.sticker,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,1,1,18,18)
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
        setColor(clr[1],clr[2],clr[3],.5)
        rect('fill',-18+36*ls[i].x,-18-36*(ls[i].y+N),36,36)
    end
end
function skin.overFieldDraw(player)
    local sList=player.stickerList
    for i=1,#sList do
        gc.setColor(1,1,1,(stickerTTL-sList[i].timer)/fadeTime)
        local sx=sList[i].x+sList[i].vx*sList[i].timer
        local sh=sList[i].y-sList[i].timer^2/max(player.CDelay,.1)*2.5
        local sr=sList[i].avel*sList[i].timer
        gc.draw(skin.sticker,36*sx,-36*sh,sr,1,1,18,18)
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
        gc.push()
        gc.translate(36*(x+piece[i][1]),-36*(y+piece[i][2]))
        setColor(1,1,1,.5)
        gc.setLineWidth(2)
        rect('line',-18,-18,36,36)
        rect('line',-12,-12,24,24)
        gc.pop()
    end
end
function skin.clearEffect(y,h,alpha,width)
end
return skin