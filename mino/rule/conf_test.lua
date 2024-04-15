local ZNHJ={}
function ZNHJ.init(P,mino)
    scene.BG=require'BG/settings'
    mino.resetStopMusic=false
    mino.rule.allowSpin={T=true}
    mino.waitTime=.5
    mino.musInfo="R-side - Nine Five"
    local date=os.date('*t')
    if date.month==4 and date.day==14 then
        mino.musInfo="T-Malu - Winter Story"
    else
        mino.musInfo="R-side - Nine Five"
    end
end
return ZNHJ