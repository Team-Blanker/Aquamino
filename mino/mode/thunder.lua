local fLib,block=require'mino/fieldLib',require'mino/blocks'
local rule={}
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
function rule.init(P,mino)
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.enableMiniSpin=false
    scene.BG=require('BG/rain') scene.BG.init()
    scene.BG.density=80 scene.BG.angle=0
    scene.BG.thunderDensity=0
    mino.musInfo="DiscreetDragon - Thunderbolt"
    mus.add('music/Hurt Record/Thunderbolt','whole','ogg',15.857,240*6/14)
    mus.start()
    sfx.add({
        lvup='sfx/mode/general/level up.wav',
        top='sfx/mode/thunder/top.wav',
        thunder1='sfx/mode/thunder/thunder1.ogg',
        thunder2='sfx/mode/thunder/thunder2.ogg',
        thunder3='sfx/mode/thunder/thunder3.ogg',
        thunder4='sfx/mode/thunder/thunder4.ogg',
        thunder5='sfx/mode/thunder/thunder5.ogg',
    })
    for k,v in pairs(P) do
        v.stormLv=1
        v.point=0
        v.step={r=-3,e=-3,x=-3}
        v.thunderPreviewList={}
        v.thunderAnimList={}
        v.scoreTxt={}--[1]={x,y,v,g,color,size,TTL,Tmax}
        v.top=false
    end
end
function rule.addLightning(player,x,y,sz,extp)
    local lx,ly=36*(x-.5-player.w/2),-36*(y-.5-player.h/2)
    local px,py=lx,ly
    local pos={lx,ly}
    for i=1,8 do
        lx=lx+80*(rand()-.5)
        ly=ly-120-60*(rand()-.5)
        pos[#pos+1]=lx pos[#pos+1]=ly
    end
    player.thunderAnimList[#player.thunderAnimList+1]={
        x=px,y=py,sz=sz,extp=extp,lnPos=pos,TTL=tAnimTTL
    }
end
function rule.remove(player,x,y)
    if fLib.isBlock(player,x,y) then player.field[y][x]={} end
    rule.addLightning(player,x,y,1,'r')
end
function rule.explode(player,x,y,sz)--菱形爆炸
    for i=1-sz,sz-1 do
        for j=1-sz+abs(i),sz-1-abs(i) do
            if fLib.isBlock(player,x+i,y+j) then player.field[y+j][x+i]={} end
        end
    end
    rule.addLightning(player,x,y,sz,'e')
end
function rule.explodeX(player,x,y,sz)--X形爆炸
    if sz<0 then return end
    for i=1-sz,sz-1 do
        if fLib.isBlock(player,x+i,y+i) then player.field[y+i][x+i]={} end
        if fLib.isBlock(player,x+i,y-i) then player.field[y-i][x+i]={} end
    end
    rule.addLightning(player,x,y,sz,'x')
end
function rule.find(player,x)
    if x then
        for j=#player.field,1,-1 do
            if next(player.field[j][x]) then
                s=true return x,j
            end
        end
        return x,0
    end
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
function rule.onPieceDrop(player,mino)
    local tpl=player.thunderPreviewList
    for i=1,#tpl do
        local ex,ey=rule.find(player,tpl[1].x)
        if     tpl[1].type=='r' then rule.remove  (player,ex,ey,1)
        elseif tpl[1].type=='e' then rule.explode (player,ex,ey,2)
        elseif tpl[1].type=='x' then rule.explodeX(player,ex,ey,2)
        end
        player.explodePos={x=ex,y=ey}
        sfx.play('thunder'..rand(5),.8+.2*rand(),.95+.1*rand())
        rem(player.thunderPreviewList,1)
    end
    local his=player.history
    --print(player.history.line)
    if player.point%100~=99 then
        player.point=player.point+1
    elseif his.line>0 and player.point%100==99 then sfx.play('top') end
end
function rule.onLineClear(player,mino)
    local his=player.history
    local point=2^his.line-1+his.combo-1+(his.spin and 1 or 0)
    player.point=player.point+point

    local x,y,ox,oy=block.size(player.history.piece)
    table.insert(player.scoreTxt,{
        x=36*(his.x-ox)-18-18*player.w,y=-36*(his.y-oy)+18*player.h,v={0,-90},g=90,TTL=.4,tMax=.4,
        size=40,color={1,1,1,.8},score=point
    })
    if player.point>=player.stormLv*100 then
        if player.stormLv==10 then mino.win(player) return end
        player.stormLv=min(player.stormLv+1,10) sfx.play('lvup') player.top=false

        if not mino.unableBG then
        scene.BG.density=20+60*player.stormLv
        if player.stormLv>5 then scene.BG.thunderDensity=.2 scene.BG.angle=.25
        scene.BG.addLightning() end
        end

        local n=-3-2*max(player.stormLv-6,0)
        player.step.r,player.step.e,player.step.x=n,n,n
        player.thunderPreviewList={}
    end
end
function rule.afterPieceDrop(player)
    local his=player.history
    if player.point%100~=99 then
        if his.spin and his.line==0 then
            local x,y,ox,oy=block.size(player.history.piece)

            player.point=player.point+1
            table.insert(player.scoreTxt,{
            x=36*(his.x-ox)-18-18*player.w,y=-36*(his.y-oy)+18*player.h,v={0,-90},g=90,TTL=.4,tMax=.4,
            size=40,color={1,1,1,.8},score=1
            })
        end
    end
    if player.point%100==99 and not player.top then sfx.play('top') player.top=true end
    if event[player.stormLv].step.r>0 then player.step.r=player.step.r+1
        if player.step.r>=event[player.stormLv].step.r then
            local f=event[player.stormLv].freq.r
            while f>0 do
                if rand()<f then
                    local ex,ey=rule.find(player)
                    ins(player.thunderPreviewList,{x=ex,y=ey,type='r',t=0})
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
                    local ex,ey=rule.find(player)
                    ins(player.thunderPreviewList,{x=ex,y=ey,type='e',t=0})
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
                    local ex,ey=rule.find(player)
                    ins(player.thunderPreviewList,{x=ex,y=ey,type='x',t=0})
                end
                f=f-1
            end
            player.step.x=0
        end
    end
    local _
    for i=1,#player.thunderPreviewList do
        _,player.thunderPreviewList[i].y=rule.find(player,player.thunderPreviewList[i].x)
    end
end
local tList,tpl
function rule.always(player,dt)
    tList=player.thunderAnimList
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
    tpl=player.thunderPreviewList
    for i=1,#tpl do
        tpl[i].t=tpl[i].t+dt
    end
end
function rule.underFieldDraw(player)
    local x=-18*player.w-110

    if player.point%100==99 then gc.setColor(1,.75,.5) else gc.setColor(1,1,1) end
    gc.printf(""..player.point,font.JB_B,x,-36,2048,'center',0,.5,.5,1024,84)
    gc.printf(""..player.stormLv*100,font.JB_B,x,36,2048,'center',0,.5,.5,1024,84)
    gc.printf("Level "..player.stormLv,font.JB_B,-player.w*18-28,288,2048,'right',0,0.25,0.25,2048,84)
    gc.setLineWidth(7)
    gc.line(-player.w*18-170,0,-player.w*18-50,0)

    gc.printf(""..player.stat.block,font.JB,x,116,6000,'center',0,.4,.4,3000,font.height.JB/2)
    gc.printf(user.lang.rule.thunder.piece,font.JB_B,x,156,6000,'center',0,.2,.2,3000,font.height.JB_B/2)
end
local indicate=gc.newCanvas(36,180)
gc.setCanvas(indicate)
for i=1,90 do
    gc.setColor(1,1,1,i/90)
    gc.rectangle('fill',0,i*2-2,36,2)
    gc.setColor(1,1,1)
end
gc.setCanvas()
function rule.underStackDraw(player)
    local tpl=player.thunderPreviewList
    for i=1,#tpl do
        gc.setColor(.8,.8,.84,.45+sin(tpl[i].t*math.pi*1.5)*.1)
        gc.draw(indicate,tpl[i].x*36-36-18*player.w,-tpl[i].y*36+18*player.h-180)
    end
end
local alpha,szarg
function rule.overFieldDraw(player)
    tList=player.thunderAnimList
    for i=1,#tList do
        alpha=tList[i].TTL/tAnimTTL
        if tList[i].extp=='x' then gc.setColor(.7,.85,1,alpha/2) else gc.setColor(1,1,1,alpha/2) end
        gc.setLineWidth(10+10*tList[i].sz)
        gc.line(tList[i].lnPos)
        if tList[i].extp=='x' then gc.setColor(.7,.85,1,alpha/2) else gc.setColor(1,1,1,alpha/2) end
        gc.setLineWidth(8+8*tList[i].sz)
        gc.line(tList[i].lnPos)
        gc.setColor(1,1,1,alpha)
        gc.setLineWidth(6+6*tList[i].sz)
        gc.line(tList[i].lnPos)
        if tList[i].extp=='r' then
            gc.setColor(1,1,1,alpha*2)
            gc.rectangle('fill',tList[i].x-18,tList[i].y-18,36,36)
        elseif tList[i].extp=='e' then
            gc.circle('fill',tList[i].x,tList[i].y,36*tList[i].sz-36+20*(1-alpha),4)
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
    local tpl=player.thunderPreviewList
    for i=1,#tpl do
        gc.setColor(1,1,1,1-tpl[i].t/.25)
        --if     tpl[i].type=='r' then
            gc.setLineWidth(6-18*tpl[i].t)
            gc.rectangle('line',tpl[i].x*36-36-18*player.w-36*tpl[i].t,-tpl[i].y*36+18*player.h-36*tpl[i].t,36+72*tpl[i].t,36+72*tpl[i].t)
        --[[elseif tpl[i].type=='e' then
            gc.setLineWidth(8-32*tpl[i].t)
            gc.circle('line',tpl[i].x*36-18-18*player.w,-tpl[i].y*36+18*player.h+18,36+36*tpl[i].t,4)
        elseif tpl[i].type=='x' then
            gc.setLineWidth(18+36*tpl[i].t)
            gc.line(tpl[i].x*36-18*player.w-54-36*tpl[i].t,-tpl[i].y*36+18*player.h-18-36*tpl[i].t,tpl[i].x*36-18*player.w+18+36*tpl[i].t,-tpl[i].y*36+18*player.h+54+36*tpl[i].t)
            gc.line(tpl[i].x*36-18*player.w-54-36*tpl[i].t,-tpl[i].y*36+18*player.h+54+36*tpl[i].t,tpl[i].x*36-18*player.w+18+36*tpl[i].t,-tpl[i].y*36+18*player.h-18-36*tpl[i].t)
        end]]
    end
    for i=1,#tpl do
        if     tpl[i].type=='r' then
            gc.setLineWidth(4)
            gc.setColor(.8,.8,.84,.36+sin(tpl[i].t*math.pi*1.5)*.08)
            gc.rectangle('fill',tpl[i].x*36-36-18*player.w,-tpl[i].y*36+18*player.h,36,36)
            gc.setColor(1,1,1,.8)
            gc.rectangle('line',tpl[i].x*36-36-18*player.w,-tpl[i].y*36+18*player.h,36,36)
        elseif tpl[i].type=='e' then
            gc.setColor(.8,.8,.84,.36+sin(tpl[i].t*math.pi*1.5)*.08)
            gc.circle('fill',tpl[i].x*36-18-18*player.w,-tpl[i].y*36+18*player.h+18,45,4)
        elseif tpl[i].type=='x' then
            gc.setColor(.8,.8,.84,.36+sin(tpl[i].t*math.pi*1.5)*.08)
            gc.setLineWidth(18)
            gc.line(tpl[i].x*36-18*player.w-54,-tpl[i].y*36+18*player.h-18,tpl[i].x*36-18*player.w+18,-tpl[i].y*36+18*player.h+54)
            gc.line(tpl[i].x*36-18*player.w-54,-tpl[i].y*36+18*player.h+54,tpl[i].x*36-18*player.w+18,-tpl[i].y*36+18*player.h-18)
        end
    end
end

function rule.scoreSave(P,mino)
    local pb=file.read('player/best score')
    if not pb.thunder.piece then pb.thunder.piece=9999 end
    local ispb=pb.thunder and (P[1].point>=1000 and P[1].stat.block<pb.thunder.piece or P[1].point>pb.thunder.point)
    if not pb.thunder or ispb then
    pb.thunder={point=P[1].point,piece=P[1].stat.block,date=os.date("%Y/%m/%d  %H:%M:%S")}
    file.save('player/best score',pb)
    end
    return ispb
end
return rule