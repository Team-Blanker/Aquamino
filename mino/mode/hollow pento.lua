local gc=love.graphics
local fLib=require'mino/fieldLib'
local rule={}

local center={
    Z5=1,
    S5=1,
    J5=2,
    L5=3,
    T5=1,
    I5=1,
    P =1,
    Q =1,
    N =3,
    H =3,
    F =1,
    E =1,
    R =2,
    Y =3,
    X =1,
    W =1,
    V =3,
    U =1,
}
function rule.init(P,mino)
    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
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
function rule.onPieceSummon(player)
    local c=player.cur
    table.remove(c.piece,center[c.name])
end
function rule.onLineClear(player,mino)
    player.line=player.line+player.history.line
end
function rule.underFieldDraw(player)
    gc.setColor(1,1,1)
    gc.printf(player.line,font.JB,-18*player.w-110,0,800,'center',0,.625,.625,400,84)
end
--[[local clra,clrb={.6,1,.2,1},{1,1,1,1}
function rule.overFieldDraw(player)
    local remain=max(player.line,0)
    if remain<=player.h and remain>0 then
        local lx,rx,y=-18*player.w,18*player.w,18*(player.h-2*remain)
        gc.setColor((remain<=10 and player.gameTimer%.2<.1) and clra or clrb)
        gc.setLineWidth(2)
        gc.line(lx,y,rx,y)
        gc.arc('fill','closed',lx,y,8,-math.pi/2,  math.pi/2,2)
        gc.arc('fill','closed',rx,y,8, math.pi/2,3*math.pi/2,2)
    end
end]]

return rule