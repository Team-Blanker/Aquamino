local rule={}
local fLib=require'mino/fieldLib'
function rule.init(P,mino)
    scene.BG=require('BG/squares') if scene.BG.init then scene.BG.init() end

    mino.bag={
        --'Z5','S5','J5','L5','T5','I5','P','Q','N','H','R','Y','E','F','V','W','X','U',
        'T5'
    }
    for k,v in pairs(mino.bag) do
        mino.rule.allowSpin[v]=true
        --mino.rule.allowPush[v]=true
    end
    P[1].LDelay=1e99 P[1].LDRInit=1e99 P[1].LDR=1e99

    fLib.insertField(P[1],{
        {'g1','g1',' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,},
        {'g1',' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,' ' ,},
        {'g1',' ' ,'g1','g1','g1','g1','g1','g1',' ' ,'g1',},
        {'g1',' ' ,' ' ,' ' ,'g1','g1',' ' ,' ' ,' ' ,'g1',},
        {'g1',' ' ,'g1','g1','g1','g1','g1','g1',' ' ,'g1',},
    })
end
return rule