local ZNHJ={}
function ZNHJ.init(P,mino)
    scene.BG=require('BG/stars') --scene.BG.init()

    --3 4 5春天 6 7 8夏天 9 10 11 秋天 12 1 2 冬天
    local m=(os.date('*t').month-3)/4
    if m<1 then    --春
        mino.musInfo="Teada - 花ノ雨"
        mus.add('music/Hurt Record/Rain of Flowers','parts','mp3')
    elseif m<2 then--夏
        mino.musInfo="Mikiya Komaba - Look Up The Starlight"
        mus.add('music/Hurt Record/Look Up The Starlight','parts','mp3')
    elseif m<3 then--秋
        mino.musInfo="ミレラ - Got Of The Wind"
        mus.add('music/Hurt Record/Got Of The Wind','parts','mp3')
    else           --冬
        mino.musInfo="周藤三日月 - 冬の人工衛星"
        mus.add('music/Hurt Record/Winter Satellite','parts','mp3')
    end
    mus.start()
    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    for k,v in pairs(P) do
        --v.w=4
        v.LDRInit=1e99 v.FDelay=5 v.LDelay=1e99 v.LDR=1e99
    end
end

--[[local b=require'mino/blocks'
function ZNHJ.onPieceEnter(player)
    local c=player.cur
    c.piece=b.giant(c.piece)
    if (c.x+c.piece[1][1])%1~=0 then
        c.x,c.y=c.x+.5,c.y+.5
    end
end]]
return ZNHJ