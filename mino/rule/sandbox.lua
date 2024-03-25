local ZNHJ={}
function ZNHJ.init(P,mino)
    scene.BG=require('BG/space') scene.BG.init()

    --[[local r=rand(2)
    if r==1 then]]
        mino.musInfo="Mikiya Komaba - Look Up The Starlight"
        mus.add('music/Hurt Record/Look Up The Starlight','parts','mp3')
    --[[else
        mino.musInfo="K.Y. - NIGHT DRIVE"
        mus.add('music/Hurt Record/NIGHT DRIVE','parts','mp3')
    end]]
    mus.start()
    mino.rule.allowPush={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    mino.rule.loosen.fallTPL=.1
    mino.rule.allowSpin={Z=true,S=true,J=true,L=true,T=true,O=true,I=true,}
    for k,v in pairs(P) do
        --v.w=4
        v.LDRInit=1e99 v.FDelay=5 v.LDelay=1e99 v.LDR=1e99
    end
end
return ZNHJ