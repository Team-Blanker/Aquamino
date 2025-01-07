local bg={}
function bg.init()
    bg.pic=gc.newImage('BG/res/snow/BG.png')
    bg.pic:setFilter('linear')
    bg.danger=false
    bg.dangerT=0
    bg.snowParList={}--[1]={x,y,a,as,sz,type,t}
end
function bg.update(dt)
    for i=#bg.snowParList,1,-1 do
        local pt=bg.snowParList[i]
        local v=4800/pt.dis
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
        if dt*48>rand() then
        table.insert(bg.snowParList,{
            x=3000*rand()-180-2040,y=-600,
            a=2*math.pi*rand(),as=.1*math.pi*(rand()-.5),
            dis=1+rand()*2,
            type=rand(3),TTL=4
        })
        bg.snowParList[#bg.snowParList].sz=(2+rand())/bg.snowParList[#bg.snowParList].dis
        end
    end
end
function bg.draw()
    gc.push()
    local w,h=bg.pic:getPixelDimensions()
    gc.scale(1920/w)
    gc.setColor(.9,.9,.9)
    gc.draw(bg.pic,0,0,0,1,1,w/2,h/2)
    gc.pop()
    gc.setColor(0,0,0,bg.dangerT*.35)
    gc.rectangle('fill',-1000,-600,2000,1200)

    gc.setColor(1,1,1)
    for i=1,#bg.snowParList do
        local pt=bg.snowParList[i]
        gc.arc('fill',pt.x,pt.y,12*pt.sz,pt.a,pt.a+2*math.pi,3+pt.type)
    end
end
return bg