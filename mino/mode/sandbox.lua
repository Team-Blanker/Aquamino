local sb={}
local fLib=require'mino/fieldLib'

local musTag={'sandbox'}
function sb.init(P,mino)
    scene.BG=require('BG/stars')

    mino.resetStopMusic=false

    local m=(os.date('*t').month-3)%12

    if not mus.checkTag('sandbox') then
        --3 4 5春天 6 7 8夏天 9 10 11 秋天 12 1 2 冬天
        if m<3 then    --春
            mus.add('music/Hurt Record/Rain of Flowers','parts','ogg')
        elseif m<6 then--夏
            mus.add('music/Hurt Record/Look Up The Starlight','parts','ogg')
        elseif m<9 then--秋
            mus.add('music/Hurt Record/Got Of The Wind','parts','ogg')
        else           --冬
            mus.add('music/Hurt Record/Winter Satellite','parts','ogg')
        end
        mus.setTag(musTag)
    end
    mus.start()

    if m<3 then    --春
        mino.musInfo="Teada - 花ノ雨"
    elseif m<6 then--夏
        mino.musInfo="Mikiya Komaba - Look Up The Starlight"
    elseif m<9 then--秋
        mino.musInfo="ミレラ - Got Of The Wind"
    else           --冬
        mino.musInfo="周藤三日月 - 冬の人工衛星"
    end

    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    for k,v in pairs(P) do
        --v.w=4
        v.LDRInit=1e99 v.FDelay=10 v.LDelay=1e99 v.LDR=1e99
    end
end
return sb