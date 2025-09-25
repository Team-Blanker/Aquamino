local spinCheck={}
local fLib=require('mino/fieldLib')
local M,T=myMath,myTable
--function spinchech.xx(player)
--...
--return spin,mini
--end
local cPiece={Z=true,S=true,J=true,L=true,T=true}
local cRequire={Z=4,S=4,J=3,L=3,T=3}
local cPoint={
    -- 1   1
    --ZZ2 2SS
    --2OZ SO2
    -- 1   1
    Z={{-1, 0},{ 1, 1},{-1, 0},{ 1, 1},{ 0, 2},{ 0,-1}},
    S={{ 1, 0},{-1, 1},{ 1, 0},{-1, 1},{ 0, 2},{ 0,-1}},
    --JXX XXL
    --JOJ LOL
    --X X X X
    J={{ 0, 1},{ 1, 1},{-1,-1},{ 1,-1}},
    L={{ 0, 1},{-1, 1},{-1,-1},{ 1,-1}},
    --XTX
    --TOT
    --X X
    T={{-1, 1},{ 1, 1},{-1,-1},{ 1,-1}},
}
--手打旋转矩阵……
local orientMult={
    [0]={ 1, 0, 0, 1},
    [1]={ 0, 1,-1, 0},
    [2]={-1, 0, 0,-1},
    [3]={ 0,-1, 1, 0},
}
local function corner(player)
    local C=player.cur
    local x,y,o,c=C.x,C.y,C.O,0
    local ia=fLib.isAir local lc=fLib.isLoosen
    local pList=cPoint[C.name]
    for i=1,#pList do
        local ox,oy=pList[i][1]*orientMult[o][1]+pList[i][2]*orientMult[o][2],pList[i][1]*orientMult[o][3]+pList[i][2]*orientMult[o][4]
        print(ox,oy)
    if (not ia(player,x+ox,y+oy) or lc(player,x+ox,y+oy)) then c=c+1 end
    end
    return c
end
function spinCheck.default(player)
    local C=player.cur
    if cPiece[C.name] then
        if fLib.isImmobile(player) then return true,corner(player)<cRequire[C.name]
        else return false,false end
    elseif C.name=='I' then
        return fLib.isImmobile(player),C.O%2==0
    elseif C.name=='O' then
        if fLib.isImmobile(player) then return true,true
        else return false,false end
    else
        if fLib.isImmobile(player) then return true,false
        else return false,false end
    end
end
function spinCheck.noMini(player)
    if fLib.isImmobile(player) then return true,false
    else return false,false end
end
function spinCheck.AllMini(player)
    local C=player.cur
    if C.name=='T' then
        if fLib.isImmobile(player) then return true,fLib.corner(player)<3
        else return false,false end
    else
        if fLib.isImmobile(player) then return true,true
        else return false,false end
    end
end
return spinCheck