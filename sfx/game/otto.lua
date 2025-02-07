local otto={}
function otto.addSFX()
    sfx.add({
        start='sfx/game/otto/start.wav',
        die='sfx/game/otto/die.wav',
        lose='sfx/game/otto/lose.wav',
        win='sfx/game/otto/win.wav',
        newRecord='sfx/game/otto/newRecord.wav',

        move='sfx/game/otto/move.wav',
        moveFail='sfx/game/otto/move fail.wav',
        landedMove='sfx/game/otto/landed move.wav',
        lock='sfx/game/otto/lock.wav',
        hold='sfx/game/otto/hold.wav',
        rotate='sfx/game/otto/rotate.wav',
        spin='sfx/game/otto/spin.wav',
        rotateFail='sfx/game/otto/rotate fail.wav',
        touch='sfx/game/otto/touch.wav',

        ['1']='sfx/game/otto/1.wav',
        ['2']='sfx/game/otto/1.wav',
        ['3']='sfx/game/otto/1.wav',
        ['4']='sfx/game/otto/4.wav',
        mini='sfx/game/otto/mini.wav',
        spin0='sfx/game/otto/spin0.wav',
        spin1='sfx/game/otto/spin1.wav',
        spin2='sfx/game/otto/spin2.wav',
        spin3='sfx/game/otto/spin3.wav',
        ['4wide']='sfx/game/otto/4wide.wav',
        PC='sfx/game/otto/PC.wav',
        B2B='sfx/game/otto/B2B.wav',
        B2BBreak='sfx/game/otto/B2BBreak.wav',
        megacombo='sfx/game/otto/megacombo.wav',
        wtf='sfx/game/otto/wtf.wav',

        bomb='sfx/game/otto/bomb.wav',

        loose='sfx/game/otto/loose.wav',
        push='sfx/game/otto/push.wav'
    })
end
function otto.start()
    sfx.play('start')
end
function otto.move(player,success,landed)
    if success then
        if landed and sfx.key.landedMove then sfx.play('landedMove') else sfx.play('move') end
    else sfx.play('moveFail') end
end
function otto.rotate(player,success,spin)
    if success then
        if spin then sfx.play('spin')
        else sfx.play('rotate')end
    else sfx.play('rotateFail') end
end
function otto.hold(player)
    sfx.play('hold')
end
function otto.touch(player,touch)
    if touch then sfx.play('touch') end
end
function otto.lock(player)
    sfx.play('lock')
end
function otto.clear(player)
    local his=player.history
    local clearType=(his.spin and 'spin' or '')..min(his.line,(his.spin and 3 or 4))
    local pitch=his.line==0 and 1 or min(2^((his.combo-1)/12),2.848)
    local vol=his.mini and 0 or 1
    if (his.spin and 1 or 0)+floor(his.line/4)+(his.PC and 1 or 0)>=2 then
        sfx.play('wtf') return
    end
    sfx.play(clearType,vol,pitch)
    if his.wide==4 and his.line>0 then sfx.play('4wide') end
    if his.mini then sfx.play('mini') end
    if his.PC then sfx.play('PC') end
    if his.B2B>0 and his.line>0 then sfx.play('B2B',1,2^(min(his.B2B-1,18)/12)) end
    if his.combo>=18 then sfx.play('megacombo') end
    for k,v in pairs(his.clearLine) do
        if v.bombGarbage then sfx.play('bomb',1,pitch) end
    end
end
function otto.B2BBreak()
    sfx.play('B2BBreak')
end
function otto.loose()
    sfx.play('loose')
end
function otto.push()
    sfx.play('push')
end
function otto.win()
    sfx.play('win')
end
function otto.die()
    sfx.play('die')
end
function otto.lose()
    sfx.play('lose')
end
function otto.newRecord()
    sfx.play('newRecord')
end
return otto