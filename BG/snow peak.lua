local bg={}
function bg.init()
    bg.pic=gc.newImage('BG/res/snow peak/BG.png')
    bg.pic:setFilter('nearest')
    bg.s1=gc.newImage('BG/res/snow peak/snow1.png')
    bg.s1:setFilter('nearest')
    bg.s2=gc.newImage('BG/res/snow peak/snow2.png')
    bg.s2:setFilter('nearest')
    bg.s3=gc.newImage('BG/res/snow peak/snow3.png')
    bg.s3:setFilter('nearest')
    bg.danger=false
    bg.dangerT=0
    bg.snowParList={}--[1]={x,y,a,as,sz,type,t}
end
function bg.update(dt)
    for i=#bg.snowParList,1,-1 do
        local pt=bg.snowParList[i]
        local v=1200*pt.sz^2
        pt.x,pt.y=pt.x+v*dt,pt.y+v*dt
        pt.a=pt.a+pt.as*dt
        pt.TTL=pt.TTL-dt
        if pt.TTL<=0 then table.remove(bg.snowParList,i) end
    end
    bg.dangerUpdate(dt)
end
function bg.dangerUpdate(dt)
    bg.dangerT=bg.danger and min(2,bg.dangerT+dt) or max(0,bg.dangerT-2*dt)
    if bg.danger then
        if dt*20>rand() then
        table.insert(bg.snowParList,{
            x=3000*rand()-180-2040,y=-600,
            a=2*math.pi*rand(),as=.1*math.pi*(rand()-.5),
            sz=1,type=3,TTL=4
        })
        end
        if dt*15>rand() then
        table.insert(bg.snowParList,{
            x=3000*rand()-180-2040,y=-600,
            a=2*math.pi*rand(),as=.1*math.pi*(rand()-.5),
            sz=1.5,type=3,TTL=4
        })
        end
        if dt*10>rand() then
        table.insert(bg.snowParList,{
            x=3000*rand()-180-2040,y=-600,
            a=2*math.pi*rand(),as=.1*math.pi*(rand()-.5),
            sz=2,type=3,TTL=4
        })
        end
    end
end
function bg.draw()
    gc.push()
    local w,h=bg.pic:getPixelDimensions()
    gc.scale(1920/w)
    gc.draw(bg.pic,0,0,0,1,1,w/2,h/2)
    gc.pop()
    gc.setColor(0,0,0,bg.dangerT*.35)
    gc.rectangle('fill',-1000,-600,2000,1200)

    gc.setColor(1,1,1)
    for i=1,#bg.snowParList do
        local pt=bg.snowParList[i]
        gc.draw(bg.s3,pt.x,pt.y,pt.a,3*pt.sz,3*pt.sz,3,3)
    end
end
return bg