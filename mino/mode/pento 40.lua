local gc=love.graphics
local fLib=require'mino/fieldLib'
local rule={}
function rule.init(P,mino)
    scene.BG=require('BG/arrows') scene.BG.init(117.5,-0.443,0)
    mino.musInfo="Naoki Hirai - flex"
    mus.add('music/Hurt Record/flex','whole','ogg',.443,196*60/117.5)
    mus.start()

    mino.bag={
        'Z5','S5','J5','L5','T5','I5','P','Q','N','H','R','Y','E','F','V','W','X','U',
    }
    for k,v in pairs(mino.bag) do
        mino.rule.allowSpin[v]=true
        --mino.rule.allowPush[v]=true
    end
    P[1].line=0 P[1].LDRInit=32 P[1].LDR=32
end
function rule.onLineClear(player,mino)
    player.line=player.line+player.history.line
    if player.line>=40 then mino.win(player) end
    --if not mino.unableBG then scene.BG.newProgress(min(player.line/40,1)) end
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..max(40-player.line,0),font.JB,-18*player.w-110,0,800,'center',0,.625,.625,400,84)
end
local clra,clrb={.6,1,.2,1},{1,1,1,1}
function rule.overFieldDraw(player)
    local remain=max(40-player.line,0)
    if remain<=player.h and remain>0 then
        local lx,rx,y=-18*player.w,18*player.w,18*(player.h-2*remain)
        gc.setColor((remain<=10 and player.gameTimer%.2<.1) and clra or clrb)
        gc.setLineWidth(2)
        gc.line(lx,y,rx,y)
        gc.arc('fill','closed',lx,y,8,-math.pi/2,  math.pi/2,2)
        gc.arc('fill','closed',rx,y,8, math.pi/2,3*math.pi/2,2)
    end
end

return rule