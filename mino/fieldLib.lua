--[[
变量介绍：
场地(field)——存储当前场地上方块信息。按照field[y][x]寻找对应的砖格。
松动块(loosen)——存储所有松动块。结构同field。
场地初始为空，如果方块有部分放在了场地外就加一行，如果满了就把这行去掉，loosen同理
]]
--[[*未来计划：
block={
    name='Z',loosen=false,
    color={1,0,0},colorName='Red',
}
空气一律为{}
]]
local M=require'framework/mathExtend'
local T=require'framework/tableExtend'
local B=require'mino/blocks'
local IRS_RS=require('mino/rotateSys/IRS-RS')

local fieldLib={}

function fieldLib.newPlayer(arg)
    local stdPlayer={
        started=false,alive=true,gameTimer=0,deadTimer=-1,loseTimer=-1,winTimer=-1,

        event={0,'start',0,'nextIns'},
        initOpQueue={},--I_S操作序列
        posX=0,posY=0,r=0,scale=1,
        boardOffset={--版面晃动的偏移和参数
            x=0,y=0,
            a={0,0},--加速度
            vel={0,0},--速度
            angle=0,--角度
            angvel=0,--角速度
            angacc=0,--角加速度
            force={--各种受力/力矩
                move={0,0},
            },
            triggered={l=false,r=false,d=false}--长按触发的版面晃动
        },
        posOffset={},--其它的坐标偏移列表，由规则包定义
        finalPosX=0,finalPosY=0,
        field={},w=10,h=20,loosen={},
        moveDir='',pushAtt=0,

        RS_name='SRS',
        RS=nil,
        next={},NO={},NP={},preview=6,--NO next所有块朝向  NP next所有块“实体”
        hold={mode='S'},canHold=true,
        canInitMove=true,canInitRotate=true,canInitHold=true,

        summonHeightAlign=0, --方块生成高度修正

        CDelay=0,EDelay=0,
        MTimer=0,DTimer=0,
        FDelay=1,FTimer=0,
        LDelay=1,LTimer=0,LDR=16,LDRInit=16,

        seqGen={count=0,buffer={}},
        history={--上一个块放下的时候做了什么
            name=nil,piece={},x=0,y=0,O=0,
            dropHeight=0,kickOrder=0,
            clearLine={},
            line=0,spin=false,mini=false,PC=false,combo=0,B2B=-1,push=0,
            CDelay=0,wide=0,
        },
        cur={--当前块的所有信息
            name=nil,piece={},x=5,y=21,O=0,ghostY=0,spin=false,mini=false,
            moveSuccess=false,
            kickOrder=0
        },
        stat={--统计数据
            block=0
        },

        nWideDetect={},--空n列检测，仅消行时使用，不消就清空
        fallAfterClear=true,

        smoothAnim={prepiece={},drawPiece={},timer=0,preCenter={0,0},drawCenter={0,0}},
        dropAnim={}
        --e.g. dropAnim[1]={x=0,ys=0,yf=0,TMax=0.5,TTL=0.5}
    }
    if type(arg)=='table' then T.combine(stdPlayer,arg) end
    stdPlayer.RS=require('mino/rotateSys/'..stdPlayer.RS_name)
    return stdPlayer
end

function fieldLib.setRS(player,RS)
    player.RS_name=RS
    player.RS=require('mino/rotateSys/'..RS)
end
--场地
function fieldLib.addLine(player)--加一行
    local line={}
    for i=1,player.w do line[i]={} end
    player.field[#player.field+1]=line
end
function fieldLib.blockType(player,x,y)--获取特定位置的砖格信息
    if x<1 or x>player.w then return {name='wall'}
    elseif y<1 then return {name='bottom'}
    elseif y>#player.field then return {}
    elseif player.field[y][x] then return player.field[y][x]
    else return {name='cleared'} end
end

function fieldLib.isBlock(player,x,y)
    if x<1 or x>player.w or y<1 or y>#player.field then return false
    elseif player.field[y][x] and next(player.field[y][x]) then return true
    else return false end
end
function fieldLib.isEdge(player,x,y)
    return x<1 or x>player.w or y<1
end
function fieldLib.isAir(player,x,y)
    if x<1 or x>player.w or y<1 then return false end
    if y>#player.field or not next(player.field[y][x]) then return true
    else return false end
end

--方块旋转&spin判定

local gOffd={--大方块附加的踢墙偏移（向下）
    R={{ 0, 0},{ 0,-1},{ 0, 1},{-1, 0},{-1,-1},{-1, 1}},
    L={{ 0, 0},{ 0,-1},{ 0, 1},{ 1, 0},{ 1,-1},{ 1, 1}},
    F={{ 0, 0},{-1, 0},{ 1, 0},{ 0,-1},{-1,-1},{ 1,-1}}
}
local gOffu={--大方块附加的踢墙偏移（向上）
    R={{ 1, 0},{1, -1},{ 1, 1}},
    L={{-1, 0},{-1,-1},{-1, 1}},
    F={{ 0, 1},{-1, 1},{ 1, 1}}
}

local data={}
function fieldLib.kick(player,mode)

    if fieldLib.coincide(player) then --如果重叠，先检测IRS_RS的踢
        local ko=fieldLib.coincideKick(player,mode)
        if ko then return ko end
    end

    local cur=player.cur
    --local originPiece,originO=T.copy(cur.piece),cur.O--先存一个，万一你没踢成功呢
    local originO=cur.O
    local RS=player.RS

    if RS.getData then RS.getData(data,player,fieldLib,originO+1,mode) end

    cur.O=B.rotate(cur.piece,cur.O,mode)
    if RS.kick then
        local kickOrder=RS.kick(player,mode)
        if kickOrder then return kickOrder end
    else
        local ukick=RS.getKickTable and RS.getKickTable(data,cur.name,originO+1,mode) or RS.kickTable[cur.name] and RS.kickTable[cur.name][mode][originO+1]
        if ukick and player.LDR>0 then
            local x,y
            if cur.piece.sz=='giant' then
                for i=1,#ukick do
                    for j=1,#gOffd[mode] do
                        x,y=ukick[i][1]*2+gOffd[mode][j][1],ukick[i][2]*2+gOffd[mode][j][2]
                        if not fieldLib.coincide(player,x,y) then cur.x,cur.y=cur.x+x,cur.y+y
                        return i end
                    end
                    for j=1,#gOffu[mode] do
                        x,y=ukick[i][1]*2+gOffu[mode][j][1],ukick[i][2]*2+gOffu[mode][j][2]
                        if not fieldLib.coincide(player,x,y) then cur.x,cur.y=cur.x+x,cur.y+y
                        return i end
                    end
                end
            else
                for i=1,#ukick do
                    x,y=ukick[i][1],ukick[i][2]
                    if not fieldLib.coincide(player,x,y) then cur.x,cur.y=cur.x+x,cur.y+y
                    return i end
                end
            end
        else
            if not fieldLib.coincide(player,x,y) then return 1 end
        end
    end
    --cur.piece,cur.O=T.copy(originPiece),originO
    cur.O=B.antiRotate(cur.piece,cur.O,mode)

    for k,v in pairs(data) do v=nil end
end
function fieldLib.coincideKick(player,mode)
    local cur=player.cur
    --local originPiece,originO=T.copy(cur.piece),cur.O--先存一个，万一你没踢成功呢
    local originO=cur.O
    local RS=IRS_RS

    if RS.getData then RS.getData(data,player,fieldLib,originO+1,mode) end

    cur.O=B.rotate(cur.piece,cur.O,mode)
    if RS.kick then
        local kickOrder=RS.kick(player,mode)
        if kickOrder then return kickOrder end
    else
        local ukick=RS.getKickTable and RS.getKickTable(data,cur.name,originO+1,mode) or RS.kickTable[cur.name] and RS.kickTable[cur.name][mode][originO+1]
        if ukick and player.LDR>0 then
            local x,y
            if cur.piece.sz=='giant' then
                for i=1,#ukick do
                    for j=1,#gOffd[mode] do
                        x,y=ukick[i][1]*2+gOffd[mode][j][1],ukick[i][2]*2+gOffd[mode][j][2]
                        if not fieldLib.coincide(player,x,y) then cur.x,cur.y=cur.x+x,cur.y+y
                        return i end
                    end
                    for j=1,#gOffu[mode] do
                        x,y=ukick[i][1]*2+gOffu[mode][j][1],ukick[i][2]*2+gOffu[mode][j][2]
                        if not fieldLib.coincide(player,x,y) then cur.x,cur.y=cur.x+x,cur.y+y
                        return i end
                    end
                end
            else
                for i=1,#ukick do
                    x,y=ukick[i][1],ukick[i][2]
                    if not fieldLib.coincide(player,x,y) then cur.x,cur.y=cur.x+x,cur.y+y
                    return i end
                end
            end
        else
            if not fieldLib.coincide(player,x,y) then return 1 end
        end
    end
    --cur.piece,cur.O=T.copy(originPiece),originO
    cur.O=B.antiRotate(cur.piece,cur.O,mode)

    for k,v in pairs(data) do v=nil end
end

function fieldLib.isImmobile(player)
    local kokodayo=fieldLib.coincide
    local r=kokodayo(player, 1, 0)
    local l=kokodayo(player,-1, 0)
    local u=kokodayo(player, 0, 1)
    local d=kokodayo(player, 0,-1)
    return u and d and l and r
end
function fieldLib.corner(player)
    local x,y,c=player.cur.x,player.cur.y,0
    if x%1~=0 then return 4 end--非整数坐标方块(I O 大方块等)直接判定为四个“角”都有东西
    local bt=fieldLib.blockType local lc=fieldLib.isLoosen
    if next(bt(player,x-1,y-1)) or lc(player,x-1,y-1) then c=c+1 end
    if next(bt(player,x-1,y+1)) or lc(player,x-1,y+1) then c=c+1 end
    if next(bt(player,x+1,y-1)) or lc(player,x+1,y-1) then c=c+1 end
    if next(bt(player,x+1,y+1)) or lc(player,x+1,y+1) then c=c+1 end
    return c
end

--获取阴影坐标
function fieldLib.getGhostY(player)
    local gy=0
    if #player.cur.piece~=0 then
        while not fieldLib.coincide(player,0,gy-1) do gy=gy-1 end
        return gy+player.cur.y
    end
end

--方块与场地相关
function fieldLib.entryPlace(player)--方块进场时使用，决定方块出块位置
    local c=player.cur
    local x,y,ox,oy=B.size(c.piece)
    local dx,dy=ceil(player.w/2),player.h+1
    c.x=dx+ox+(x%2==0 and .5 or 0)
    local d=y/2+oy-0.5--旋转中心距离下底的高度
    c.y=dy+d+player.summonHeightAlign
end
function fieldLib.coincide(player,offX,offY)
    local c,ls=player.cur,player.loosen
    if not c.piece or #c.piece==0 then error("Attempt to test a empty piece") end
    if not offX then offX=0 end  if not offY then offY=0 end
    for i=1,#c.piece do
        local x,y=c.piece[i][1]+c.x+offX,c.piece[i][2]+c.y+offY
        if not fieldLib.isAir(player,x,y) then return true end
        for j=1,#ls do
            if ls[j].x==x and ls[j].y==y then return true end
        end
    end
    return false
end
function fieldLib.lock(player)
    local C=player.cur
    local his=player.history

    player.stat.block=player.stat.block+1

    for i=1,#C.piece do
        local x=C.x+C.piece[i][1]
        local y=C.y+C.piece[i][2]
        while not player.field[y] do fieldLib.addLine(player)  end
        if not player.field[y][x].bomb then player.field[y][x]={name=C.name,loosen=false,id=player.stat.block} end

        for i=y-1,1,-1 do
        if fieldLib.isBlock(player,x,i) then
            if player.field[i][x].bomb then
                player.field[i].triggered=true
                player.field[i].triggerPos=x
            else break end
        else break end
        end
    end
    his.piece,his.name,his.o,his.x,his.y=C.piece,C.name,C.o,C.x,C.y
    C.piece,C.name,C.o={},nil,nil
    player.FTimer=0 player.pushAtt=0
end
--消行操作与检测
function fieldLib.lineClear(player)
    local cnt=0 local field=player.field
    local PC=true
    local cLine={}
    for y=#field,1,-1 do
        local pass=true
        for x=1,player.w do
            if not next(field[y][x]) then pass=false break end
            if field[y].bombGarbage and not field[y].triggered then pass=false break end
        end
        if pass then cLine[y]=field[y] field[y]={} cnt=cnt+1 end
    end
    for y=#field,1,-1 do for x=1,#field[y] do
        if next(field[y][x]) then PC=false break end
    end end
    return cnt,PC,cLine
end
function fieldLib.eraseEmptyLine(player)
    for y=#player.field,1,-1 do
        if #player.field[y]==0 then
            if player.fallAfterClear then
            table.remove(player.field,y)
            else for x=1,player.w do player.field[y][x]={} end end
        end
    end
    if player.history.PC then player.field={} end
end
function fieldLib.wideDetect(player)--空n列检测，n<=4时数值才有意义
    local his=player.history
    local wd=player.nWideDetect

    if his.line>0 then
        wd[#wd+1]={}
        for i=1,#his.piece do table.insert(wd[#wd],his.piece[i][1]+his.x) end
    else player.nWideDetect={} return -1 --代表不检测
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
--垃圾进场
function fieldLib.garbage(player,block,atk,hole)
    local field=player.field
    local h=#field
    local gb={}
    for i=1,player.w do gb[i]=(type(block)=='table' and T.copy(block) or {name=block}) end
    if type(hole)=='number' then gb[hole]={}
    else for i=1,#hole do gb[hole[i]]={} end end
    for i=1,atk do
        for j=h,1,-1 do field[j+1]=field[j] end
        field[1]=T.copy(gb)
        if player.cur.piece and #player.cur.piece~=0 and fieldLib.coincide(player) then player.cur.y=player.cur.y+1 end
    end
    if h+atk>3*player.h then for i=3*player.h,(h+atk) do field[i]=nil end end

    player.cur.ghostY=fieldLib.getGhostY(player)
end
function fieldLib.bombGarbage(player,block,atk,hole)
    local field=player.field
    local h=#field
    local gb={bombGarbage=true,triggered=false}
    for i=1,player.w do gb[i]=(type(block)=='table' and T.copy(block) or {name=block}) end
    if type(hole)=='number' then gb[hole]={name='bomb',bomb=true}
    else for i=1,#hole do gb[hole[i]]={} end end
    for i=1,atk do
        for j=h,1,-1 do field[j+1]=field[j] end
        field[1]=T.copy(gb)
        if player.cur.piece and #player.cur.piece~=0 and fieldLib.coincide(player) then player.cur.y=player.cur.y+1 end
    end
    if h+atk>3*player.h then for i=3*player.h,(h+atk) do field[i]=nil end end

    player.cur.ghostY=fieldLib.getGhostY(player)
end
function fieldLib.insertField(player,field)--导入场地/涨入特定垃圾，field里的砖格均以字符串表示
    for y=1,#field do
        table.insert(player.field,1,{})
        for x=1,player.w do
            if field[y][x] and field[y][x]~=' ' then player.field[1][x]={name=field[y][x]}
            else player.field[1][x]={} end
        end
    end
end

--？
function fieldLib.freefall(piece,name,px,py,field)
    for i=1,#field do  for j=#piece,1,-1 do
        if piece[j][2]+py==i then
            local x,y=px+piece[j][1],py+piece[j][2]
            if y==1 or next(field[y-1][x]) then
                field[y][x]={name=name} table.remove(piece,j)
            end
        end
    end end
    return px,py-1
end

--Push机制
function fieldLib.isLoosen(player,x,y)
    local ls=player.loosen
    for i=1,#ls do if x==ls[i].x and y==ls[i].y then return i end end
end
function fieldLib.loosenFall(player)
    local field,ls=player.field,player.loosen
    local fall=true
    --获取松动块的最低高度和最高高度
    local minH,maxH=ls[1] and ls[1].y,ls[1] and ls[1].y
    for i=2,#ls do
        minH=ls[i].y<minH and ls[i].y or minH
        maxH=ls[i].y>maxH and ls[i].y or maxH
    end
    --从下往上一层一层往下掉
    for y=(minH or 0),(maxH or 0) do  for i=#ls,1,-1 do
        if ls[i].y==y then
            if next(fieldLib.blockType(player,ls[i].x,ls[i].y-1)) then
            field[ls[i].y][ls[i].x]=ls[i].info field[ls[i].y][ls[i].x].loosen=true table.remove(ls,i)
            end
        end
    end  end
    for i=1,#ls do ls[i].y=ls[i].y-1 end
end
function fieldLib.pushField(player,mode) --loosen[1]={x=1,y=1,name='Z'}
    local P=player local C=P.cur
    local piece,field,ls=C.piece,P.field,P.loosen
    local dir={L={-1,0},R={1,0},D={0,-1}}
    local testP,BTM={},{} --BTM=Block To Move
    local canMove,moreTest=true,true

    local looseBlock={} --本应有两个返回值，是否有方块被转松，是否有松动块被推动，后者可用canMove表示
    --生成检测点并向指定方向移动
    for i=1,#piece do testP[i]={piece[i][1]+dir[mode][1]+C.x,piece[i][2]+dir[mode][2]+C.y} end

    --第一次检测

    for i=#testP,1,-1 do --对于所有检测点
        local testO=fieldLib.isLoosen(player,testP[i][1],testP[i][2]) --Test Order,检测松动块序号
        if fieldLib.isEdge(player,testP[i][1],testP[i][2]) then --如果检测到墙
            canMove=false moreTest=false --不移动松动块，不进行之后的检测
            table.remove(testP,i) --销毁检测点
        elseif fieldLib.isBlock(player,testP[i][1],testP[i][2]) then --如果检测到了固定块
            canMove=false moreTest=false --不移动松动块，不进行之后的检测
            if P.pushAtt>=3 then --如果旋转计数>=3
                table.insert(ls,{x=testP[i][1],y=testP[i][2],info=field[testP[i][2]][testP[i][1]]}) --将它加入松动块列表
                table.insert(looseBlock,{x=testP[i][1],y=testP[i][2],info=field[testP[i][2]][testP[i][1]]})
                field[testP[i][2]][testP[i][1]]={} --去掉场地上对应的块
            end
            table.remove(testP,i) --最后销毁检测点
        elseif testO then --如果检测到了松动块
            table.insert(BTM,table.remove(ls,testO)) --将对应松动块暂时加入BTM
            testP[i]={testP[i][1]+dir[mode][1],testP[i][2]+dir[mode][2]} --移动该检测点
        else table.remove(testP,i) end --再然后就是检测到空气了，去死吧你
    end

    --之后的检测：

    if moreTest then  for i=#testP,1,-1 do --如果继续测试，对于所有检测点
        local testO=fieldLib.isLoosen(player,testP[i][1],testP[i][2]) --=Test Order,检测松动块序号
        if fieldLib.isEdge(player,testP[i][1],testP[i][2]) then canMove=false --如果检测到墙，不移动松动块
        elseif fieldLib.isBlock(player,testP[i][1],testP[i][2]) then --如果检测到了固定块
            table.insert(ls,{x=testP[i][1],y=testP[i][2],info=field[testP[i][2]][testP[i][1]]}) --将它加入松动块列表
            table.insert(looseBlock,{x=testP[i][1],y=testP[i][2],info=field[testP[i][2]][testP[i][1]]})
            canMove=false field[testP[i][2]][testP[i][1]]={} --不移动松动块
        elseif testO then --如果检测到了松动块
            while testO do --只要检测到了松动块
                table.insert(BTM,table.remove(ls,testO))  --将对应松动块暂时加入BTM
                testP[i]={testP[i][1]+dir[mode][1],testP[i][2]+dir[mode][2]} --移动该检测点
                testO=fieldLib.isLoosen(player,testP[i][1],testP[i][2]) --看看检测点还在不在松动块上
            end
            --最终判定
            if fieldLib.isEdge(player,testP[i][1],testP[i][2]) then canMove=false --如果检测到墙，不移动松动块
            elseif next(fieldLib.blockType(player,testP[i][1],testP[i][2])) then --如果检测到了固定块
                table.insert(ls,{x=testP[i][1],y=testP[i][2],info=field[testP[i][2]][testP[i][1]]}) --将它加入松动块列表
                table.insert(looseBlock,{x=testP[i][1],y=testP[i][2],info=field[testP[i][2]][testP[i][1]]})
                canMove=false field[testP[i][2]][testP[i][1]]={} --不移动松动块并去掉场地上对应的块
            end
        end
        table.remove(testP,i) --检测点：我滴任务，完成啦！
    end  end

    if canMove then --如果松动块可以移动
        for i=1,#BTM do BTM[i].x=BTM[i].x+dir[mode][1] BTM[i].y=BTM[i].y+dir[mode][2] end --把BTM里的所有松动块朝指定方向移一格
    end
    for i=1,#BTM do table.insert(ls,BTM[i]) end --放回松动块列表，结束

    return looseBlock,canMove
end

--玩家，立体声参数，哪个地方的数据（cur/history）(如果是数字直接输入)
function fieldLib.getSourcePos(player,stereo,bdata)--获取音频播放位置
    stereo=stereo or 0
    local x
    if type(bdata)=='string' then
        x=(player[bdata].x-.5-player.w/2)*36*player.scale
    elseif type(bdata)=='number' then
        x=(bdata-.5-player.w/2)*36*player.scale
    else x=0 end
    return M.clamp((player.finalPosX+x)/960,-1,1)*stereo
end
return fieldLib