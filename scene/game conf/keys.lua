local cfk=user.lang.conf.keys

local BUTTON=scene.button
local key={
    keySet={},
    keyName={},
    banned={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12', 'f17','f18',
        'tab','backspace',
        'audiomute','audioplay','volumeup','volumedown',
        'numlock','capslock','scrolllock',
        'printscreen'
    }
}
local M,T=mymath,mytable
function key.read()
    key.keySet={
        ML={'left'},MR={'right'},
        CW={'x'},CCW={'c'},flip={'d'},
        SD={'down'},HD={'up'},hold={'z'},
        R={'r'},pause={'escape','p'}
    }
    if fs.getInfo('conf/keySet') then
        T.combine(key.keySet,json.decode(fs.newFile('conf/keySet'):read()))
    end
    for i=1,#key.keyName do
        if not key.keySet[key.keyName[i]] then key.keySet[key.keyName[i]]={} end
    end
    for k,v in pairs(key.keySet) do
        if not T.include(key.keyName,k) then v=nil end
    end
end
function key.save()
    local s=fs.newFile('conf/keySet')
    s:open('w')
    s:write(json.encode(key.keySet))
end

function key.init()
    cfk=user.lang.conf.keys

    key.keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}
    key.read()
    key.order=nil

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    })
end
function key.keyP(k)
    if key.order then
        local K=key.keySet[key.keyName[key.order]]
        if k=='backspace' then key.keySet[key.keyName[key.order]]={}
        else local n=T.include(K,k)
            if n then table.remove(K,n) elseif #K<3 then
                for o,v in pairs(key.keySet) do local conflict=T.include(v,k)
                    if conflict then table.remove(v,conflict) end
                end
                if not T.include(key.banned,k) then table.insert(K,k) end
            end
        end
    --[[elseif k=='escape' then key.quit() love.event.quit()]] end
end
function key.mouseP(x,y,button,istouch)
    if not (button==1 and BUTTON.press(x,y,button,istouch)) then
        if button==1 and (x>-800 and x<800 and y>-300 and y<300) then
            local o=ceil(y/100)+3+(x>0 and 6 or 0)
            key.order=o<=#key.keyName and o~=key.order and o or nil
            print(key.order)
        else key.order=nil end
    end
end
function key.mouseR(x,y,button,istouch)
    BUTTON.release(x,y,button,istouch)
end
function key.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function key.draw()
    gc.setColor(1,1,1,.5)
    for i=0,5 do
        gc.rectangle('fill',-800,-300+100*i,200,100)
        gc.rectangle('fill',   0,-300+100*i,200,100)
    end
    gc.setColor(1,1,1,.25)
    if key.order then gc.rectangle('fill',key.order>6 and 200 or -600,(key.order-1)%6*100-300,600,100) end
    gc.setColor(1,1,1)
    gc.printf(user.lang.conf.main.keys,font.Bender,0,-430,1280,'center',0,1,1,640,76)
    gc.printf(cfk.info,font.JB,800,400,8000,'right',0,.3,.3,8000,192)
    for i=0,5 do
        if cfk.keyName[i+1] then gc.printf(cfk.keyName[i+1],font.Bender_B,-700,-250+100*i,2000,'center',0,cfk.kScale,cfk.kScale,1000,76) end
        if cfk.keyName[i+7] then gc.printf(cfk.keyName[i+7],font.Bender_B, 100,-250+100*i,2000,'center',0,cfk.kScale,cfk.kScale,1000,76) end
    end
    gc.setColor(.5,1,.875)
    for i=1,#key.keyName do local K=key.keySet[key.keyName[i]]
        for j=1,#K do
            gc.printf(K[j]:len()==1 and K[j]:upper() or K[j],
            font.JB,(i>6 and 100 or -700)+200*j,-300+100*((i-1)%6)+128*.4,2000,'center',0,.4,.4,1000,84)
        end
    end
    gc.setColor(.84,1,.92)
    gc.setLineWidth(4)
    for i=0,6 do gc.line(-800,-300+100*i,800,-300+100*i) end
    BUTTON.draw()
end
function key.exit()
    key.save()
end
return key