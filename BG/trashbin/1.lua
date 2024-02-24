-- this background should not be used.
local bg={}
function bg.init()
    bg.flOre=gc.newImage('assets/pic/flOre.png')
    bg.w,bg.h=bg.flOre:getPixelDimensions()
    bg.txt=gc.newCanvas(1000,128)
    gc.setCanvas(bg.txt)
    gc.printf("FUCK U",Exo_2_SB,500,64,1000,'center',0,1,1,500,84)
    gc.setCanvas()
    print('success')
end
function bg.draw()
    local t=scene.time
    gc.clear(t%.3<.1 and {.5,0,0} or t%.3<.2 and {0,.5,0} or {0,0,.5})
    local p1,p2=sin(t%2*math.pi),cos(t%2*math.pi)
    gc.draw(bg.flOre,0,0,3*t%2*math.pi,1,1,bg.w/2,bg.h/2)
    for i=0,2,1/4 do
        gc.draw(bg.flOre,500*cos((t-i)%2*math.pi),500*sin((t-i)%2*math.pi),(i+.5)*math.pi,.666,.666,bg.w/2,bg.h/2)
    end
    for i=0,2,1/8 do
        gc.draw(bg.flOre,800*cos((.4*t-i)%2*math.pi),800*sin((.4*t-i)%2*math.pi),(i+.5)*math.pi,.333,.333,bg.w/2,bg.h/2)
    end
    for i=1,25 do
       gc.draw(bg.txt,384*(i%5)-848,216*ceil(i/5)-648,((2.5*t+.75*i)*1.5)%2*math.pi,1,1,500,64)
    end
end
return bg