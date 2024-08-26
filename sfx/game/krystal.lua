local krystal={}
function krystal.addSFX()
    sfx.add({
        lose='sfx/game/krystal/lose.wav',
        win='sfx/game/krystal/win.wav',
        newRecord='sfx/game/krystal/newRecord.wav',

        move='sfx/game/krystal/move.wav',
        moveFail='sfx/game/krystal/move fail.wav',
        landedMove='sfx/game/krystal/landed move.wav',
        lock='sfx/game/krystal/lock.wav',
        hold='sfx/game/krystal/hold.wav',
        rotate='sfx/game/krystal/rotate.wav',
        spin='sfx/game/krystal/spin.wav',
        rotateFail='sfx/game/krystal/rotate fail.wav',
        touch='sfx/game/krystal/touch.wav',

        ['1']='sfx/game/krystal/1.wav',
        ['2']='sfx/game/krystal/2.wav',
        ['3']='sfx/game/krystal/3.wav',
        ['4']='sfx/game/krystal/4.wav',
        spin0='sfx/game/krystal/spin0.wav',
        spin1='sfx/game/krystal/spin1.wav',
        spin2='sfx/game/krystal/spin2.wav',
        spin3='sfx/game/krystal/spin3.wav',
        PC='sfx/game/krystal/PC.wav',

        loose='sfx/game/krystal/loose.wav',
        push='sfx/game/krystal/push.wav'
    })
end
function krystal.move(player,success,landed,stereo)
    if success then
        if landed and sfx.key.landedMove then sfx.play('landedMove',1,1,stereo) else sfx.play('move',1,1,stereo) end
    else sfx.play('moveFail',1,1,stereo) end
end
function krystal.rotate(player,success,spin,stereo)
    if success then
        if spin then sfx.play('spin',1,1,stereo)
        else sfx.play('rotate',1,1,stereo)end
    else sfx.play('rotateFail',1,1,stereo) end
end
function krystal.hold(player,stereo)
    sfx.play('hold',1,1,stereo)
end
function krystal.touch(player,touch,stereo)
    if touch then sfx.play('touch',1,1,stereo) end
end
function krystal.lock(player,stereo)
    sfx.play('lock',1,1,stereo)
end
function krystal.clear(player,stereo)
    local his=player.history
    local clearType=(his.spin and 'spin' or '')..min(his.line,(his.spin and 3 or 4))
    local pitch=(his.line==0 or his.spin) and 1 or min(2^((his.combo-1)/12),2.848)
    sfx.play(clearType,1,pitch,stereo)
    if his.PC then sfx.play('PC',1,1,stereo) end
end
function krystal.loose(player,stereo)
    sfx.play('loose',1,1,stereo)
end
function krystal.push(player,stereo)
    sfx.play('push',1,1,stereo)
end
function krystal.lose()
    sfx.play('lose')
end
function krystal.win()
    sfx.play('win')
end
function krystal.newRecord()
    sfx.play('newRecord')
end
return krystal