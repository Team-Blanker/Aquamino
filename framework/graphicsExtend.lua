local gc=love.graphics

local gcExtend={}

function gcExtend.centerRect(mode,x,y,w,h,rx,ry,seg)
    if not h then h=w end
    gc.rectangle(mode,x-w/2,y-h/2,w,h,rx,ry,seg)
end

return gcExtend