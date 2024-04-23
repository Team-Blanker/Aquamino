local rule={}
function rule.init(P,mino)
    scene.BG=require('BG/zone') scene.BG.init(0,.5,60,4,40/60,8)
    mino.musInfo="龍飛 - アシタノカタチ"
    mus.add('music/Hurt Record/Shape of Tomorrow','whole','ogg',12.375,48.75)
    mus.start()

    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    for k,v in pairs(P) do
        --v.w=4
        v.LDRInit=1e99 v.FDelay=5 v.LDelay=1e99 v.LDR=1e99
    end
end

local b=require'mino/blocks'
function rule.onPieceSummon(player)
    local c=player.cur
    if rand()<1/2 then
        table.remove(c.piece,rand(#c.piece))
    end
    if rand()<1/7 then
        c.piece=b.giant(c.piece)
    end
end
return rule