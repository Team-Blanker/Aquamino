local rule={}
local fLib=require'mino/fieldLib'
function rule.init(P,mino)
    scene.BG=require('BG/zone') scene.BG.init(0,.5,60,4,40/60,8)
    mino.musInfo="龍飛 - アシタノカタチ"
    mus.add('music/Hurt Record/Shape of Tomorrow','whole','ogg',12.375,48.75)
    mus.start()

    --mino.seqGenType='pairs'
    mino.bag={
        'Z','S','J','L','T','O','I', 'Z','S','J','L','T','O','I',
        'Z5','S5','J5','L5','T5','I5','P','Q','N','H','R','Y','E','F','V','W','X','U',
        'I6','U6','T6','O6','wT','Ht','XT','Tr','A','Pl',
        'Pl','Pl','Tr','Tr',
        'OZ','OS','bZ','bS','TZ','TS',
        'lSt','rSt','lHk','rHk'
    }
    mino.rule.allowSpin={}
    mino.rule.allowPush={}
    for k,v in pairs(mino.bag) do
        mino.rule.allowSpin[v]=true
        mino.rule.allowPush[v]=true
    end
    mino.rule.loosen.fallTPL=.1
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
    if c.name~='I6' and rand()<1/14 then
        c.piece=b.giant(c.piece)
    end
end
function rule.overFieldDraw(player)
    gc.setColor(1,1,1)
    if player.cur.name then gc.printf(player.cur.name,font.Bender_B,-18*player.w-110,0,1000,'center',0,.5,.5,500,72) end
end
return rule