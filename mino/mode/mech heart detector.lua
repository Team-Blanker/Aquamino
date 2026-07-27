local setColor,rect,arc,printf=gc.setColor,gc.rectangle,gc.arc,gc.printf

local sb={}
local fLib=require'mino/fieldLib'

local musTag={'sandbox'}
function sb.init(P,mino)
    scene.BG=require('BG/stars')

    mino.resetStopMusic=false

    local m=(os.date('*t').month-3)%12

    if not mus.checkTag('sandbox') then
        --3 4 5春天 6 7 8夏天 9 10 11 秋天 12 1 2 冬天
        if m<3 then    --春
            mus.add('music/Hurt Record/Rain of Flowers','parts','ogg')
        elseif m<6 then--夏
            mus.add('music/Hurt Record/Look Up The Starlight','parts','ogg')
        elseif m<9 then--秋
            mus.add('music/Hurt Record/Got Of The Wind','parts','ogg')
        else           --冬
            mus.add('music/Hurt Record/Winter Satellite','parts','ogg')
        end
        mus.setTag(musTag)
    end
    mus.start()

    if m<3 then    --春
        mino.musInfo="Teada - 花ノ雨"
    elseif m<6 then--夏
        mino.musInfo="Mikiya Komaba - Look Up The Starlight"
    elseif m<9 then--秋
        mino.musInfo="ミレラ - Got Of The Wind"
    else           --冬
        mino.musInfo="周藤三日月 - 冬の人工衛星"
    end

    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}

    --mino.bag={'Z','S','J','L','O','P'}
    for k,v in pairs(P) do
        --v.w=4
        v.LDRInit=1e99 v.FDelay=10 v.LDelay=1e99 v.LDR=1e99

        v.shapeSus=0
        v.spinSus=0

        v.wideSpinDetect={}--空n列Spin检测，仅Spin时记录，普通消除清空
    end
end
function sb.wideSpinDetect(player)--空n列检测，n<=4时数值才有意义
    local his=player.history
    local wd=player.wideSpinDetect

    if his.spin then
        if his.name~='I' then
        wd[#wd+1]={}
        for i=1,#his.piece do table.insert(wd[#wd],his.piece[i][1]+his.x) end
        end
    elseif his.line<4 then table.remove(wd,1) return -1 --不是spin且不是消四不检测，强制去掉最后一个元素
    end

    if #wd<4 then return -1
    elseif #wd>4 then table.remove(wd,1) end--去掉过早放置的方块信息

    local min,max=player.w,1
    for i=1,4 do  for j=1,#wd[i] do
        if wd[i][j]<min then min=wd[i][j] end
        if wd[i][j]>max then max=wd[i][j] end
    end end
    return max-min+1
end

local shapeSusValue={0,0,2,4,8,12,16,20}

--机心坑形状，镜像的就把场地镜像过来检测
local mechHeartShape={
    {0,0,0,1},
    {1,0,0,1},
    {1,0,0,0},
}

local function xor(a,b)--异或函数
    local v=0
    if a then v=v+1 end if b then v=v+1 end
    return v==1
end
function sb.mechShapeDetect(player)
    local F=player.field
    local shapeSus=0
    local shapeLayer=0
    local y=1
    local mechX
    ----检测标准机心----
    --print('---')
    while y<=#F do
        local match=true
        if mechX then
            for x1=1,mechX-1 do
                if not next(F[y][x1]) then match=false break end--机心只有坑有洞，其余为完整堆叠
            end
            for x1=mechX+4,10 do
                if not next(F[y][x1]) then match=false break end--机心只有坑有洞，其余为完整堆叠
            end
            for i=1,4 do
                if xor(next(F[y][mechX+i-1]),mechHeartShape[shapeLayer%3+1][i]==1) then match=false break end--有砖格不匹配
            end
            if not match then mechX=nil end
        else
            for x=1,10 do--检测机心形状
            if not next(F[y][x]) then--查找这一行的第一个空洞，并依此为基准
                --print(x)
                if x>7 then match=false break--机心洞左下角不可能在第八列出现
                else
                    for x1=x+4,10 do
                        if not next(F[y][x1]) then match=false break end--机心只有坑有洞，其余为完整堆叠
                    end
                end
                for i=1,4 do
                    if xor(next(F[y][x+i-1]),mechHeartShape[shapeLayer%3+1][i]==1) then match=false break end--有砖格不匹配
                end
                if match then mechX=x end
                break--查找并检测完毕，跳出循环
            end
        end
        end
        --print(shapeLayer,match)
        if match then shapeLayer=shapeLayer+1 y=y+1--这一行检测成功，跳下一行
        else--这一行检测失败
            if shapeLayer==0 then y=y+1--不是机心最底一行，跳下一行
            else shapeSus=shapeSus+shapeSusValue[min(shapeLayer,8)] shapeLayer=0 end--否则还可能是机心最底一行，记录数据，从这一行开始重新检测
        end
    end
    --print('...')
    ----检测镜像机心----
    --镜像场地，所有F[y][x]替换成F[y][11-x]
    shapeLayer=0
    y=1
    mechX=nil
    while y<=#F do
        local match=true
        if mechX then
            for x1=1,mechX-1 do
                if not next(F[y][11-x1]) then match=false break end--机心只有坑有洞，其余为完整堆叠
            end
            for x1=mechX+4,10 do
                if not next(F[y][11-x1]) then match=false break end--机心只有坑有洞，其余为完整堆叠
            end
            for i=1,4 do
                if xor(next(F[y][11-mechX-i+1]),mechHeartShape[shapeLayer%3+1][i]==1) then match=false break end--有砖格不匹配
            end
            if not match then mechX=nil end
        else
            for x=1,10 do--检测机心形状
            if not next(F[y][11-x]) then--查找这一行的第一个空洞，并依此为基准
                --print(11-x)
                if x>7 then match=false break--机心洞左下角不可能在第八列出现
                else
                    for x1=x+4,10 do
                        if not next(F[y][11-x1]) then match=false break end--机心只有坑有洞，其余为完整堆叠
                    end
                end
                for i=1,4 do
                    if xor(next(F[y][11-x-i+1]),mechHeartShape[shapeLayer%3+1][i]==1) then match=false break end--有砖格不匹配
                end
                if match then mechX=x end
                break--查找并检测完毕，跳出循环
            end
        end
        end
        --print(shapeLayer,match)
        if match then shapeLayer=shapeLayer+1 y=y+1--这一行检测成功，跳下一行
        else--这一行检测失败
            if shapeLayer==0 then y=y+1--不是机心最底一行，跳下一行
            else shapeSus=shapeSus+shapeSusValue[min(shapeLayer,8)] shapeLayer=0 end--否则还可能是机心最底一行，记录数据，从这一行开始重新检测
        end
    end
    --print('---')
    return min(shapeSus,20)
end
function sb.afterCheckClear(player,mino)
    if player.history.line>0 then local w=sb.wideSpinDetect(player)
        if w==4 then player.spinSus=min(player.spinSus+3,14)
        elseif w==5 then player.spinSus=min(player.spinSus+1,14)
        else player.spinSus=0 end
    end
    player.shapeSus=sb.mechShapeDetect(player)
end
function sb.underFieldDraw(player)
    local sz1=player.shapeSus/20
    local sz2=player.spinSus/20
    gc.push()
        gc.translate(-18*player.w-110,36)
        setColor(.1,.1,.1,.8)
        rect('fill',-90,-210,180,420)
        setColor(1,1,1)
        gc.setLineWidth(4)
        rect('line',-47,-152,94,304)

        setColor(1,.2,.2,.8)
        rect('fill',-45,150-300*sz1,90,300*sz1)
        setColor(.6,1,.2,.8)
        rect('fill',-45,150-300*min(sz1+sz2,1),90,300*(sz2-max(sz1+sz2-1,0)))

        setColor(1,1,1,.1)
        rect('fill',-45,-150,90,300)
        setColor(1,1,1)
        --printf("Lv."..player.stormLv,font.JB_B,0,-180,1000,'center',0,1/3,1/3,500,font.height.JB_B/2)
        printf(("%d/%d"):format(player.spinSus+player.shapeSus,20),
        font.JB,0,180,1000,'center',0,.25,.25,500,font.height.JB_B/2)
    gc.pop()
end
return sb