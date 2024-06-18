local gc=love.graphics

local rule={}
function rule.init(P,mino)
    scene.BG=require('BG/sprint') scene.BG.init(127,.471987,2,64)
    mino.musInfo="たかゆき - Exciter"
    mus.add('music/Hurt Record/Exciter','whole','ogg',30.709,192*60/127)
    mus.start()

    mino.seqGenType='bagES'
    for i=1,#P do P[i].line=0 end
end
function rule.onLineClear(player,mino)
    player.line=player.line+player.history.line
    if player.line>=40 then mino.win(player) end
    if not mino.unableBG then scene.BG.newProgress(min(player.line/40,1)) end
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
        gc.circle('fill',lx,y,9,4)
        gc.circle('fill',rx,y,9,4)
    end
end
return rule