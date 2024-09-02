local plastic_v2={}
function plastic_v2.addSFX()
    sfx.add({
        lose='sfx/game/plastic_v2/lose.wav',
        win='sfx/game/plastic_v2/win.wav',
        newRecord='sfx/game/plastic_v2/newRecord.wav',

        move='sfx/game/plastic_v2/move.wav',
        moveFail='sfx/game/plastic_v2/move fail.wav',
        HD='sfx/game/plastic_v2/hard drop.wav',
        lock='sfx/game/plastic_v2/lock.wav',
        hold='sfx/game/plastic_v2/hold.wav',
        rotate='sfx/game/plastic_v2/rotate.wav',
        spin='sfx/game/plastic_v2/spin.wav',
        rotateFail='sfx/game/plastic_v2/rotate fail.wav',
        touch='sfx/game/plastic_v2/touch.wav',

        ['1']='sfx/game/plastic_v2/1.wav',
        ['2']='sfx/game/plastic_v2/2.wav',
        ['3']='sfx/game/plastic_v2/3.wav',
        ['4']='sfx/game/plastic_v2/4.wav',
        combo='sfx/game/plastic_v2/combo.wav',

        B2BBreak='sfx/game/plastic_v2/B2BBreak.wav',

        spinClear='sfx/game/plastic_v2/spin clear.wav',
        PC='sfx/game/plastic_v2/PC.wav',

        loose='sfx/game/plastic_v2/loose.wav',
        push='sfx/game/plastic_v2/push.wav'
    })
end
function plastic_v2.move(player,success,landed,stereo)
    if success then sfx.play('move',1,1,stereo) end
end
function plastic_v2.rotate(player,success,spin,stereo)
    if success then
        if spin then sfx.play('spin',1,1,stereo) end
        sfx.play('rotate',1,1,stereo)
    else sfx.play('rotateFail',1,1,stereo) end
end
function plastic_v2.hold(player,stereo)
    sfx.play('hold',1,1,stereo)
end
function plastic_v2.touch(player,touch)
    if touch then sfx.play('touch',1,1,stereo) end
end
function plastic_v2.lock(player,stereo)
    if player.history.dropHeight>0 then sfx.play('HD',1,1,stereo) end
    sfx.play('lock',1,1,stereo)
end
function plastic_v2.clear(player,stereo)
    local his=player.history
    local pitch=his.line==0 and 1 or min(2^((his.combo-1)/12),2.848)
    sfx.play(''..min(his.line,4))
    if his.spin then sfx.play('spinClear',his.line>0 and 1 or .5,his.mini and .75 or 1,stereo) end
    if his.line>0 then sfx.play('combo',1,pitch,stereo) end
    if his.PC then sfx.play('PC',1,1,stereo) end
end
function plastic_v2.B2BBreak(player,b2b,stereo)
    sfx.play('B2BBreak',1,1,stereo)
end
function plastic_v2.loose(player,stereo)
    sfx.play('loose',1,1,stereo)
end
function plastic_v2.push(player,stereo)
    sfx.play('push',1,1,stereo)
end
function plastic_v2.lose()
    sfx.play('lose')
end
function plastic_v2.win()
    sfx.play('win')
end
function plastic_v2.newRecord()
    sfx.play('newRecord')
end
return plastic_v2
