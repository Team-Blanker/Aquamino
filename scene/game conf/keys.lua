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
    scene.BG=require'BG/space' scene.BG.init()

    key.keyName={'ML','MR','CW','CCW','flip','SD','HD','hold','R','pause'}
    key.name={'左移','右移','顺转','逆转','翻转','软降','硬降','暂存','重开','暂停'}
    key.read()
    key.order=nil

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.8+t)
            gc.rectangle('fill',-w/2,-h/2,w,h,6)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h,6)
            gc.setColor(1,1,1)
            gc.printf("返回",Exo_2_SB,0,0,1280,'center',0,.5,.5,640,84)
        end,
        event=function()
            scene.switch({
                dest='conf',destScene=require('scene/game conf/conf_main'),swapT=.15,outT=.1,
                anim=function() anim.cover(.1,.05,.1,0,0,0) end
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
    if not (button==1 and BUTTON.click(x,y,button,istouch)) then
        if button==1 and (x>-800 and x<800 and y>-300 and y<300) then
            local o=ceil(y/100)+3+(x>0 and 6 or 0)
            key.order=o<=#key.keyName and o~=key.order and o or nil
            print(key.order)
        else key.order=nil end
    end
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
    gc.printf("键位设置",SYHT,0,-460,1280,'center',0,1,1,640,64)
    gc.printf("点击添加键位绑定（最多3个）\nBackspace清空选定键位\n按下已绑定键位以删除该绑定",Consolas,
    800,400,2000,'right',0,.3,.3,2000,192)
    for i=0,5 do
        if key.name[i+1] then gc.printf(key.name[i+1],SYHT,-700,-268+100*i,2000,'center',0,.5,.5,1000,64) end
        if key.name[i+7] then gc.printf(key.name[i+7],SYHT, 100,-268+100*i,2000,'center',0,.5,.5,1000,64) end
    end
    gc.setColor(.5,1,.75)
    for i=1,#key.keyName do local K=key.keySet[key.keyName[i]]
        for j=1,#K do
            gc.printf(K[j]:len()==1 and K[j]:upper() or K[j],
            Consolas,(i>6 and 100 or -700)+200*j,-300+100*((i-1)%6)+128*.4,2000,'center',0,.4,.4,1000,56)
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