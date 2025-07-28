local gc=love.graphics
local fLib=require'mino/fieldLib'
local rule={}
function rule.init(P,mino)
    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    scene.BG=require('BG/arrows') scene.BG.init()
    mino.musInfo="Naoki Hirai - flex"
    mus.add('music/Hurt Record/flex','whole','ogg',.443,196*60/117.5)
    mus.start()
    P[1].line=0 P[1].LDRInit=80 P[1].LDR=80 P[1].fallAfterClear=false
end
function rule.onLineClear(player,mino)
    player.line=player.line+player.history.line
    if player.line>=40 then mino.win(player) end
    --if not mino.unableBG then scene.BG.newProgress(min(player.line/40,1)) end
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(""..max(40-player.line,0),font.JB,-18*player.w-110,0,800,'center',0,.625,.625,400,font.height.JB/2)
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

function rule.scoreSave(P,mino)
    if mino.stacker.winState~=1 then return false end
    local pb=file.read('player/best score')
    local ispb=pb.levitate and P[1].gameTimer<pb.levitate.time or false
    if not pb.levitate or P[1].gameTimer<pb.levitate.time then
        pb.levitate={time=P[1].gameTimer,date=os.date("%Y/%m/%d  %H:%M:%S")}
        file.save('player/best score',pb)
    end
    return ispb
end
return rule