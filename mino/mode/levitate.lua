local gc=love.graphics
local fLib=require'mino/fieldLib'
local rule={}
function rule.init(P,mino)
    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    scene.BG=require('BG/jog') scene.BG.init(117.5,-0.443,0)
    mino.musInfo="Naoki Hirai - flex"
    mus.add('music/Hurt Record/flex','whole','ogg',.443,196*60/117.5)
    mus.start()
    P[1].line=0 P[1].LDRInit=20 P[1].fallAfterClear=false
end
function rule.onLineClear(player,mino)
    --[[local lh={}
    --排序
    for k,v in pairs(player.history.clearLine) do
        local o=#lh+1
        for i=1,#lh do
            if k<lh[i] then o=i break end
        end
        ins(lh,o,k)
    end
    --插入空行
    for i=1,#lh do
        local line={}
        for j=1,player.w do line[j]={} end
        ins(player.field,lh[i],line)
    end]]

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