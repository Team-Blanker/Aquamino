local ZNHJ={}
function ZNHJ.init(P,mino)
    scene.BG=require'BG/settings'
    mino.resetStopMusic=false
    mino.rule.allowSpin={T=true}
    mino.waitTime=.5
    mino.musInfo="R-side - Nine Five"
end
return ZNHJ