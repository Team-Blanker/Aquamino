return {
    ['40 lines']=function(t)
        return string.format('%d.%03d"',t.time,t.time%1*1000)
    end,
    marathon=function(t)
        return string.format('Lv.%d  %d lines  %d\'%02d.%03d""',t.level,t.line,t.time/60,t.time%60,t.time%1*1000)
    end,
    ['ice storm']=function(t)
        if t.complete then
            return string.format('COMPLETED %d\'%02d.%03d""',t.time/60,t.time%60,t.time%1*1000)
        else
            return string.format('Lv.%d  %d/%d  %d\'%02d.%03d""',t.level,t.score,t.lvlscore,t.time/60,t.time%60,t.time%1*1000)
        end
    end,
    thunder=function(t)
        return string.format('%d points  %d pieces',t.point,t.piece or 9999)
    end,
    smooth=function(t)
        return string.format('%d.%03d"',t.time,t.time%1*1000)
    end,
    levitate=function(t)
        return string.format('%d.%03d"',t.time,t.time%1*1000)
    end,
    square=function(t)
        return string.format('%d squares',t.sqPoint)
    end,
    master=function(t)
        return string.format('Lv.M%d  %d lines  %d\'%02d.%03d""',t.level,t.line,t.time/60,t.time%60,t.time%1*1000)
    end,
    multitasking=function(t)
        return string.format('Lv.%d  %d lines  %d\'%02d.%03d""',t.level,t.line,t.time/60,t.time%60,t.time%1*1000)
    end,
    ['dig 40']=function(t)
        return string.format('%d pieces  %d.%03d"',t.piece,t.time,t.time%1*1000)
    end,
    ['dig bomb']=function(t)
        return string.format('%d pieces  %d.%03d"',t.piece,t.time,t.time%1*1000)
    end,
    laser=function(t)
        return string.format('%d points  %d\'%02d.%03d""',t.point,t.time/60,t.time%60,t.time%1*1000)
    end,
    backfire=function(t)
        return string.format('%d.%03d"  x%.2f',t.time,t.time%1*1000,t.eff)
    end,
}