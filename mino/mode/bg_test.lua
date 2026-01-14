local rule={}
function rule.init(P,mino)
    scene.BG=require'BG/sqdance'
    mino.resetStopMusic=false
    mino.rule.allowSpin={T=true}
    --mino.waitTime=.5
    mino.musInfo="R-side - Nine Five"
    P[1].LDelay=1e99
    P[1].LDR=1e99
    P[1].LDRInit=1e99
    local date=os.date('*t')
    mino.musInfo="滚木"
end
return rule