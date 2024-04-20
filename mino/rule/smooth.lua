local gc=love.graphics

local rule={}
function rule.init(P,mino)
    scene.BG=require('BG/sprint') scene.BG.init(127,.471987,2,64)
    mino.musInfo="たかゆき - Exciter"
    mus.add('music/Hurt Record/Exciter','whole','mp3',30.709,192*60/127)
    mus.start()
    for i=1,#P do P[i].line=0 P[i].FDelay=0 P[i].LDelay=3 P[i].LDRInit=32 end
    mino.stacker.ctrl.ASD=0 mino.stacker.ctrl.ASP=0
end
function rule.onLineClear(player,mino)
    player.line=player.line+player.history.line
    if player.line>=40 then mino.win(player) end
    scene.BG.newProgress(min(player.line/40,1))
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..max(40-player.line,0),font.JB,-18*player.w-110,0,800,'center',0,.75,.75,400,84)
end
function rule.overFieldDraw(player)
    gc.push()
    local remain=max(40-player.line,0)
    if remain<=player.h and remain>0 then
        local lx,rx,y=-18*player.w,18*player.w,18*(player.h-2*remain)
        local clr=(remain<=10 and player.gameTimer%.2<.1) and {.6,1,.2,1} or {1,1,1,1}
        gc.setColor(clr)
        gc.setLineWidth(2)
        gc.line(lx,y,rx,y)
        gc.circle('fill',lx,y,9,4)
        gc.circle('fill',rx,y,9,4)
    end
    gc.pop()
end
return rule