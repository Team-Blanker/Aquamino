local gc=love.graphics
local bg={}
local r,g,b
function bg.init()
    bg.time=0

    local mzk=win.date.month==3 and win.date.day==22--水月生日
    local gg=win.date.month==1 and win.date.day==7--澄闪生日
    local pp=win.date.month==6 and win.date.day==12--佩佩生日
    if mzk then r,g,b=.4,.4,1
    elseif gg then r,g,b=1,.75,1
    else r,g,b=.5,1,.875 end
end
function bg.update(dt)
    bg.time=bg.time+dt
end
function bg.draw()
    gc.clear(.05,.05,.05)
    gc.setLineWidth(12)
    gc.setColor(r,g,b,.05)
    local t=bg.time/2%1*120
    for i=-1080,1080,120 do
        gc.line(i+t,-540,i+t,540)
    end
    for i=-660,660,120 do
        gc.line(-960,i+t,960,i+t)
    end
    gc.setColor(r,g,b,.2)
    for i=-1080,1080,120 do
        gc.line(i-t,-540,i-t,540)
    end
    for i=-600,600,120 do
        gc.line(-960,i-t,960,i-t)
    end
end
return bg