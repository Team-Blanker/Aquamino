local skin={}
local COLOR=require('framework/color')
local M=mymath
local setColor,draw,setShader,rect=gc.setColor,gc.draw,gc.setShader,gc.rectangle

skin.pic=gc.newImage('skin/block/wheelchair/wheelchair.png')
local sd=fs.newFile('shader/grayscale stain.glsl'):read()
skin.sd=gc.newShader(sd)
function skin.unitDraw(player,x,y,clr,alpha)
    setColor(clr[1],clr[2],clr[3],clr[4] or alpha or 1)
    setShader(skin.sd)
    draw(skin.pic,36*x,-36*y,0,.5,.5,36,36)
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
                    if F[y][x].loosen then setColor(.75,.75,.75) else setColor(mino.color[F[y][x].name]) end
                    draw(skin.pic,36*x,-36*h,0,.5,.5,36,36)
                end
            end
        else h=h+(player.fallAfterClear and n or 1) end
    end
    setShader()
    h=0
    for y=1,#player.field do
        if player.field[y][1] then h=h+1
        else h=h+n
            setColor(1,1,1)
            rect('fill',18,-36*h-18,36*player.w,n*36)
            if not player.fallAfterClear then h=h+1-n end
        end
    end
end
function skin.curDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.AscHoldDraw(player,piece,x,y,color)
end
function skin.holdDraw(player,piece,x,y,color,canHold)
    setShader(skin.sd)
    for i=1,#piece do
        setColor(canHold and color or {.5,.5,.5})
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    gc.setShader()
end
function skin.previewDraw(piece,x,y,color)--设置内预览方块材质用
    setShader(skin.sd)
    for i=1,#piece do
        gc.setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.nextDraw(player,piece,x,y,color,order)
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.loosenDraw(player,mino)
    local ls=player.loosen
    local delay=mino.rule.loosen.fallTPL
    local t=player.event[2]=='loosenDrop' and player.event[1]
        or player.event[2] and delay or 0
    local N=(delay~=0 and t) and t/delay or 0
    gc.push()
    setColor(1,1,1)
    for i=1,#ls do
        draw(skin.pic,36*ls[i].x,-36*(ls[i].y+N),0,.5,.5,36,36)
    end
    gc.pop()
end
function skin.ghostDraw(player,piece,x,y,color)
    setShader(skin.sd)
    for i=1,#piece do
        setColor(color[1],color[2],color[3],.5)
        draw(skin.pic,36*(x+piece[i][1]),-36*(y+piece[i][2]),0,.5,.5,36,36)
    end
    setShader()
end
function skin.clearEffect(y,h,alpha,width)
end
return skin