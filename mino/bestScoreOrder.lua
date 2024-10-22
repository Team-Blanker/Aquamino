return {
    ['40 lines']=function(t)
        return string.format('%.3f"',t.time)
    end,
    marathon=function(t)
        return string.format('Lv.%d  %d lines  %d\'%.3f"',t.level,t.line,t.time/60,t.time%60)
    end,
    ['ice storm']=function(t)
        return string.format('Lv.%d  %d/%d  %d\'%.3f"',t.level,t.score,t.lvlscore,t.time/60,t.time%60)
    end,
    thunder=function(t)
        return string.format('%d points  %d\'%.3f"',t.point,t.time/60,t.time%60)
    end,
    smooth=function(t)
        return string.format('%.3f"',t.time)
    end,
    levitate=function(t)
        return string.format('%.3f"',t.time)
    end,
    square=function(t)
        return string.format('%d squares',t.sqPoint)
    end,
    master=function(t)
        return string.format('Lv.M%d  %d lines  %d\'%.3f"',t.level,t.line,t.time/60,t.time%60)
    end,
    multitasking=function(t)
        return string.format('Lv.%d  %d lines  %d\'%.3f"',t.level,t.line,t.time/60,t.time%60)
    end,
    ['dig 40']=function(t)
        return string.format('%d pieces  %.3f"',t.piece,t.time)
    end,
    laser=function(t)
        return string.format('%d points  %d\'%.3f"',t.point,t.time/60,t.time%60)
    end,
    backfire=function(t)
        return string.format('%.3f"  x%.2f',t.time,t.eff)
    end,
}