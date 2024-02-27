--Use ZZZTOJ wrapper from 26F Studio

require'zzz'
local bot_zzz={}
function bot_zzz.renderField(player)
    if player.w~=10 then error('Field width must be 10') end
    local boolField={}
    for y=1,#player.field do
        for x=1,10 do
            boolField[10*(y-1)+x]=next(player.field[y][x]) and true or false
        end
    end
    while #boolField < 400 do
        boolField[#boolField+1]=false
    end
    return boolField
end
function bot_zzz.getExecution(player)
    return zzz.run(bot_zzz.renderField(player),player.cur.name)
end
return bot_zzz