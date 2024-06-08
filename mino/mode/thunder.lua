local fLib=require'mino/fieldLib'
local thunder={}
local tAnimTTL=.25 --local wind=-2*rand(2)-3
local event={
    {step={r=2,e=0,x=0},freq={r=1,e=0,x=0}},
    {step={r=1,e=0,x=0},freq={r=1,e=0,x=0}},
    {step={r=1,e=0,x=0},freq={r=1.3,e=0,x=0}},
    {step={r=1,e=4,x=0},freq={r=1.6,e=0.15,x=0}},
    {step={r=1,e=2,x=0},freq={r=1,e=.25,x=0}},
    {step={r=1,e=2,x=0},freq={r=1,e=.5,x=0}},
    {step={r=1,e=1,x=1},freq={r=.3,e=.4,x=.15}},
    {step={r=1,e=0,x=2},freq={r=.5,e=0,x=.25}},
    {step={r=2,e=0,x=1},freq={r=.25,e=0,x=.4}},
    {step={r=0,e=0,x=2},freq={r=0,e=0,x=1}},
}
function thunder.init(P,mino)
    mino.rule.allowPush={}
    mino.rule.allowSpin={}
    scene.BG=require('BG/rain') scene.BG.init()
    scene.BG.density=40 scene.BG.angle=0
    scene.BG.thunderDensity=0
    mino.musInfo="DiscreetDragon - Thunderbolt"
    mus.add('music/Hurt Record/Thunderbolt','whole','ogg',15.857,240*6/14)
    mus.start()
    sfx.add({
        lvup='sfx/rule/general/level up.wav',
        top='sfx/rule/thunder/top.wav',
        thunder='sfx/rule/thunder/thunder1.wav'
    })
    for k,v in pairs(P) do
        v.stormLv=1
        v.point=0
        v.step={r=-4,e=-4,x=-4}
        v.thunderList={}
        v.scoreTxt={}--[1]={x,y,v,g,color,size,TTL,Tmax}
        v.top=false
    end
end
function thunder.addLightning(player,x,y,sz,extp)
    local lx,ly=36*(x-.5-player.w/2),-36*(y-.5-player.h/2)
    local px,py=lx,ly
    local pos={lx,ly}
    for i=1,8 do
        lx=lx+80*(rand()-.5)
        ly=ly-120-60*(rand()-.5)
        pos[#pos+1]=lx pos[#pos+1]=ly
    end
    player.thunderList[#player.thunderList+1]={
        x=px,y=py,sz=sz,extp=extp,lnPos=pos,TTL=tAnimTTL
    }
end
function thunder.remove(player,x,y)
    if fLib.isBlock(player,x,y) then player.field[y][x]={} end
    thunder.addLightning(player,x,y,1,'r')
end
function thunder.explode(player,x,y,sz)--菱形爆炸
    for i=1-sz,sz-1 do
        for j=1-sz+abs(i),sz-1-abs(i) do
            if fLib.isBlock(player,x+i,y+j) then player.field[y+j][x+i]={} end
        end
    end
    thunder.addLightning(player,x,y,sz,'e')
end
function thunder.explodeX(player,x,y,sz)--X形爆炸
    if sz<0 then return end
    for i=1-sz,sz-1 do
        if fLib.isBlock(player,x+i,y+i) then player.field[y+i][x+i]={} end
        if fLib.isBlock(player,x+i,y-i) then player.field[y-i][x+i]={} end
    end
    thunder.addLightning(player,x,y,sz,'x')
end
function thunder.find(player)
    local tc={}
    for i=1,player.w do tc[i]=i end
    local s=false
    for i=1,player.w do
        local ex=table.remove(tc,rand(#tc))
        for j=#player.field,1,-1 do
            if next(player.field[j][ex]) then
                s=true return ex,j
            end
        end
    end
    return rand(player.w),1 --啥都没找到，随便返回一个值
end
function thunder.onPieceDrop(player,mino)
    if event[player.stormLv].step.r>0 then player.step.r=player.step.r+1
        if player.step.r>=event[player.stormLv].step.r then
            local f=event[player.stormLv].freq.r
            while f>0 do
                if rand()<f then
                local ex,ey=thunder.find(player)
                    thunder.remove(player,ex,ey,1)
                    player.explodePos={x=ex,y=ey}
                    sfx.play('thunder',.8,.95+.1*rand())
                    --sfx.play('thunder',1,.5)
                end
                f=f-1
            end
            player.step.r=0
        end
    end
    if event[player.stormLv].step.e>0 then player.step.e=player.step.e+1
        if player.step.e>=event[player.stormLv].step.e then
            local f=event[player.stormLv].freq.e
            while f>0 do
                if rand()<f then
                local ex,ey=thunder.find(player)
                    thunder.explode(player,ex,ey,2)
                    player.explodePos={x=ex,y=ey}
                    sfx.play('thunder',.8,.95+.1*rand())
                    --sfx.play('thunder',1,.5)
                end
                f=f-1
            end
            player.step.e=0
        end
    end
    if event[player.stormLv].step.x>0 then player.step.x=player.step.x+1
        if player.step.x>=event[player.stormLv].step.x then
            local f=event[player.stormLv].freq.x
            while f>0 do
                if rand()<f then
                local ex,ey=thunder.find(player)
                    thunder.explodeX(player,ex,ey,2)
                    player.explodePos={x=ex,y=ey}
                    sfx.play('thunder',.45+.1*rand(),.95+.1*rand())
                    --sfx.play('thunder',1,.5)
                end
                f=f-1
            end
            player.step.x=0
        end
    end

    if player.point%100~=99 then
        player.point=player.point+1
    elseif player.history.line>0 and player.point%100==99 then sfx.play('top') end
end
function thunder.onLineClear(player,mino)
    local his=player.history
    local point=2^player.history.line-1+player.history.combo-1
    player.point=player.point+point
    table.insert(player.scoreTxt,{
        x=36*his.x-18-18*player.w,y=-36*his.y+18*player.h,v={0,-90},g=90,TTL=.4,tMax=.4,
        size=40,color={1,1,1,.8},score=point
    })
    if player.point>=player.stormLv*100 then
        if player.stormLv==10 then mino.win(player) return end
        player.stormLv=min(player.stormLv+1,10) sfx.play('lvup') player.top=false

        if not mino.unableBG then
        scene.BG.density=10+30*player.stormLv
        if player.stormLv>5 then scene.BG.thunderDensity=.2 scene.BG.angle=.25
        scene.BG.addLightning() end
        end

        local n=-4-2*max(player.stormLv-6,0)
        player.step.r,player.step.e,player.step.x=n,n,n
    end
end
function thunder.afterPieceDrop(player)
    if player.point%100==99 and not player.top then sfx.play('top') player.top=true end
end
local tList
function thunder.always(player,dt)
    tList=player.thunderList
    for i=#tList,1,-1 do
        tList[i].TTL=tList[i].TTL-dt
        if tList[i].TTL<0 then rem(tList,i) end
    end
    local txt=player.scoreTxt
    for i=#txt,1,-1 do
        txt[i].TTL=txt[i].TTL-dt
        if txt[i].TTL<=0 then table.remove(txt,i) else
            txt[i].x,txt[i].y=txt[i].x+txt[i].v[1]*dt,txt[i].y+txt[i].v[2]*dt
            txt[i].v[2]=txt[i].v[2]+txt[i].g*dt
        end
    end
end
function thunder.underFieldDraw(player)
    if player.point%100==99 then gc.setColor(1,.75,.5) else gc.setColor(1,1,1) end
    gc.printf(""..player.point,font.JB_B,-player.w*18-110,-36,2048,'center',0,.5,.5,1024,84)
    gc.printf(""..player.stormLv*100,font.JB_B,-player.w*18-110,36,2048,'center',0,.5,.5,1024,84)
    gc.printf("Level "..player.stormLv,font.JB_B,-player.w*18-28,288,2048,'right',0,0.25,0.25,2048,84)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)
end
local alpha,szarg
function thunder.overFieldDraw(player)
    tList=player.thunderList
    for i=1,#tList do
        alpha=tList[i].TTL/tAnimTTL
        if tList[i].extp=='x' then gc.setColor(.7,.85,1,alpha/2) else gc.setColor(1,1,1,alpha/2) end
        gc.setLineWidth(16+16*tList[i].sz)
        gc.line(tList[i].lnPos)
        gc.setColor(1,1,1,alpha)
        gc.setLineWidth(9+9*tList[i].sz)
        gc.line(tList[i].lnPos)
        if tList[i].extp=='r' then
            gc.setColor(1,1,1,alpha*2)
            gc.rectangle('fill',tList[i].x-18,tList[i].y-18,36,36)
        elseif tList[i].extp=='e' then
            gc.circle('fill',tList[i].x-18,tList[i].y-18,36*tList[i].sz-36+20*(1-alpha),4)
        else
            gc.setColor(.9,.95,1,alpha*2)
            gc.rectangle('fill',tList[i].x-18,tList[i].y-18,36,36)
            gc.setLineWidth(24)
            szarg=18*tList[i].sz*min((1-alpha)*4,1)
            gc.line(tList[i].x+szarg,tList[i].y+szarg,tList[i].x-szarg,tList[i].y-szarg)
            gc.line(tList[i].x-szarg,tList[i].y+szarg,tList[i].x+szarg,tList[i].y-szarg)
        end
    end
    local txt=player.scoreTxt
    for i=1,#txt do
        local clr=txt[i].color
        gc.setColor(clr[1],clr[2],clr[3],clr[4]*txt[i].TTL/txt[i].tMax)
        gc.printf("+"..txt[i].score,font.JB_B,txt[i].x,txt[i].y,5000,'center',0,txt[i].size/128,txt[i].size/128,2500,84)
    end
end
return thunder