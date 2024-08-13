local spinCheck={}
local fLib=require('mino/fieldLib')
local M,T=mymath,mytable
--return spin,mini
function spinCheck.default(player)
    local C=player.cur
    if C.name=='T' then
        if fLib.isImmobile(player) then return true,fLib.corner(player)<3
        else return false,false end
    else
        if fLib.isImmobile(player) then return true,false
        else return false,false end
    end
end
return spinCheck