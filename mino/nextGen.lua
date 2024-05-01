local GenShin={}
local Impact=GenShin
local M,T=require'framework/mathextend',require'framework/tableextend'
local rand=math.random

function GenShin.bag(bag,player)
    local new=T.copy(bag)
    for i=1,#new do
        table.insert(player.next,table.remove(new,rand(#new)))
    end
end
function GenShin.pairs(bag,player)
    local cb=T.copy(bag)
    local a,b=rem(cb,rand(#cb)),rem(cb,rand(#cb))
    local new={a,a,a,b,b,b}
    for i=1,#new do
        table.insert(player.next,table.remove(new,rand(#new)))
    end
end
function GenShin.history(bag,player)
end
return Impact