local sb={}
local fLib=require'mino/fieldLib'
function sb.init(P,mino)
    scene.BG=require('BG/stars')

    --3 4 5春天 6 7 8夏天 9 10 11 秋天 12 1 2 冬天
    local m=(os.date('*t').month-3)%12
    if m<3 then    --春
        mino.musInfo="Teada - 花ノ雨"
        mus.add('music/Hurt Record/Rain of Flowers','parts','ogg')
    elseif m<6 then--夏
        mino.musInfo="Mikiya Komaba - Look Up The Starlight"
        mus.add('music/Hurt Record/Look Up The Starlight','parts','ogg')
    elseif m<9 then--秋
        mino.musInfo="ミレラ - Got Of The Wind"
        mus.add('music/Hurt Record/Got Of The Wind','parts','ogg')
    else           --冬
        mino.musInfo="周藤三日月 - 冬の人工衛星"
        mus.add('music/Hurt Record/Winter Satellite','parts','ogg')
    end
    mus.start()
    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    for k,v in pairs(P) do
        --v.w=4
        v.LDRInit=1e99 v.FDelay=10 v.LDelay=1e99 v.LDR=1e99
    end
end
return sb