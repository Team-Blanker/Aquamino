local ZNHJ={}
function ZNHJ.init(P,mino)
    scene.BG=require('BG/space') scene.BG.init()

    mino.musInfo="Mikiya Komaba - Look Up The Starlight"
    mus.add('music/Hurt Record/Look Up The Starlight','parts','mp3',20.879,336*60/125)
    mus.start()
    mino.rule.allowPush={O=true}
    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    for k,v in pairs(P) do
        --v.w=8
        v.LDRInit=1e99 v.FDelay=5 v.LDelay=1e99 v.LDR=1e99
    end
end
return ZNHJ