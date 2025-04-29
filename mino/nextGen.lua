local GenShin={}
local Impact=GenShin
local M,T=require'framework/mathExtend',require'framework/tableExtend'
local rand=math.random

function GenShin.bag(bag,player)
    local new=T.copy(bag)
    for i=1,#new do
        table.insert(player.next,table.remove(new,rand(#new)))
    end
end

local ES={'I','T','J','L'}
function GenShin.bagES(bag,player)
    local new=T.copy(bag)
    if player.seqGen.count==0 then
        for i=#new,1,-1 do
            table.insert(new,table.remove(new,rand(i)))
        end
        for i=1,#new do
            if T.include(ES,new[i]) then table.insert(new,1,table.remove(new,i)) break end
        end
        for i=1,#new do
            table.insert(player.next,new[i])
        end
    else
        for i=1,#new do
            table.insert(player.next,table.remove(new,rand(#new)))
        end
    end
end
function GenShin.bagp1(bag,player)
    local new=T.copy(bag)
    table.insert(new,bag[rand(#bag)])
    for i=1,#new do
        table.insert(player.next,table.remove(new,rand(#new)))
    end
end
function GenShin.bagp1FromBag(bag,player,buffer)
    if (not buffer.bag) or #buffer.bag==0 then buffer.bag=T.copy(bag) end

    local new=myTable.shuffle(bag)
    local piece=table.remove(buffer.bag,rand(#buffer.bag)) --print(piece)
    local pos=rand(#new+1)
    for i=1,3 do
    if piece==new[pos] or piece==new[pos-1] then pos=rand(#new+1) end
    end
    table.insert(new,pos,piece)
    for i=1,#new do
        table.insert(player.next,new[i])
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
function GenShin.mayhem(bag,player)
    table.insert(player.next,bag[rand(#bag)])
end
return Impact