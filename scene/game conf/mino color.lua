local T=myTable

local BUTTON,SLIDER=scene.button,scene.slider
local blocks=require'mino/blocks'
local cfcc=user.lang.conf.custom.colorSet

local bc={blockIndex=1}
local defaultColor={
    Z={.9,.15,.3},S={.45,.9,0},J={0,.6,.9},L={.9,.6,.3},T={.75,.18,.9},O={.9,.9,0},I={.15,.9,.67},
    g1={.5,.5,.5},g2={.75,.75,.75}
}
local extraBlockList={
    g1={{ 1, 0},{-1, 0},{ 0, 1},{ 0,-1}},
    g2={{ 0, 0},{ 1, 1},{-1, 1},{ 1,-1},{-1,-1}}
}

local texTypeRange={classic=2,glass=2}
local bList={'Z','S','J','L','T','O','I','g1','g2'}
local skinName
function bc.read()
    local pf={block='pure',theme='simple',sfx='Dr Ocelot',smoothAnimAct=false,fieldScale=1}
    myTable.combine(pf,file.read('conf/custom'))
    bc.blockSkin=require('skin/block/'..pf.block)
    skinName=pf.block

    bc.color=myTable.copy(defaultColor)
    local c=file.read('conf/mino color')
    myTable.combine(bc.color,c)

    bc.texType=T.copy(bc.blockSkin.defaultTexType or {})
    if fs.getInfo('conf/mino textype') then T.combine(bc.texType,file.read('conf/mino textype')[skinName])
    end
    --print(next(bc.texType))
end
function bc.save()
    file.save('conf/mino color',bc.color)

    local ttp=file.read('conf/mino textype')
    ttp[skinName]=bc.texType
    file.save('conf/mino textype',ttp)
end
bc.txt={rAll={},rCur={},texType={}}
function bc.init()
    scene.BG=require'BG/settings'

    sfx.add({
        swap='sfx/general/optionSwitch.wav',
        click='sfx/general/buttonChoose.wav',
        quit='sfx/general/confSwitch.wav',
    })

    cfcc=user.lang.conf.custom.colorSet

    local ra=bc.txt.rAll
    ra.txt=gc.newText(font.Bender,cfcc.rAll)
    ra.w,ra.h=ra.txt:getDimensions()
    ra.s=min(315/ra.w,.5)
    local rc=bc.txt.rCur
    rc.txt=gc.newText(font.Bender,cfcc.rCur)
    rc.w,rc.h=rc.txt:getDimensions()
    rc.s=min(315/rc.w,.5)

    local tt=bc.txt.texType
    tt.txt=gc.newText(font.Bender,cfcc.texType)
    tt.w,tt.h=tt.txt:getDimensions()
    tt.s=min(360/tt.w,.4)

    bc.read()

    BUTTON.create('quit',{
        x=-700,y=400,type='rect',w=200,h=100,
        draw=function(bt,t)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(win.UI.back,0,0,0,1,1,60,35)
        end,
        event=function()
            sfx.play('quit')
            scene.switch({
                dest='custom',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
                anim=function() anim.confBack(.1,.05,.1,0,0,0) end
            })
        end
    })

    BUTTON.create('textureChoose',{
        x=0,y=120,type='rect',w=450,h=80,success=false,
        draw=function(bt,t,ct,cp)
            local o,l=bc.texType[bList[bc.blockIndex]] or 1,texTypeRange[skinName] or 1
            local w,h=bt.w,bt.h
            if bt.success then local a=1-6*ct
                gc.setColor(1,1,1,a)
                gc.setLineWidth(3)
                local off=h/2*(1-a)
                if cp[1]<0 then gc.line(-(w-h)/2-off,h/2,-w/2-off,0,-(w-h)/2-off,-h/2)
                else gc.line((w-h)/2+off,h/2,w/2+off,0,(w-h)/2+off,-h/2)
                end
            end
            gc.setColor(.44,.88,.77)
            gc.draw(tt.txt,0,-h/2-10,0,tt.s,tt.s,tt.w/2,tt.h)
            gc.setLineWidth(3)
            gc.polygon('line',-w/2,0,-(w-h)/2,h/2,(w-h)/2,h/2,w/2,0,(w-h)/2,-h/2,-(w-h)/2,-h/2)
            if o>1 then gc.line(-(w-h)/2,h/2-16,-w/2+16,0,-(w-h)/2,-h/2+16) end
            if o<l then gc.line( (w-h)/2,h/2-16, w/2-16,0, (w-h)/2,-h/2+16) end
            gc.setColor(1,1,1)
            gc.printf(o,font.Bender,0,0,1280,'center',0,.4,.4,640,font.height.Bender/2)
        end,
        event=function(x,y,bt)
            local o,l=bc.texType[bList[bc.blockIndex]],texTypeRange[skinName]
            if not l then return end
            local success=false
            if x<0 then
                if o>1 then o=o-1 success=true end
            elseif o<l then o=o+1 success=true
            end
            bc.texType[bList[bc.blockIndex]]=o
            bt.success=success
            if success then sfx.play('swap') end
        end
    },.2)
    BUTTON.create('resetAllColor',{
        x=0,y=400,type='rect',w=350,h=100,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            gc.setColor(.5,.5,.5,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(.8,.8,.8)
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(ra.txt,0,0,0,ra.s,ra.s,ra.w/2,ra.h/2)
            gc.setColor(1,1,1,1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
        end,
        event=function()
            sfx.play('click')
            bc.color=myTable.copy(defaultColor)
            SLIDER.setPos('colorR',bc.color[bList[bc.blockIndex]][1])
            SLIDER.setPos('colorG',bc.color[bList[bc.blockIndex]][2])
            SLIDER.setPos('colorB',bc.color[bList[bc.blockIndex]][3])
        end
    },.2)
    BUTTON.create('resetCurColor',{
        x=400,y=400,type='rect',w=350,h=100,
        draw=function(bt,t,ct)
            local w,h=bt.w,bt.h
            local dc=defaultColor[bList[bc.blockIndex]]
            gc.setColor(dc[1]/2,dc[2]/2,dc[3]/2,.3+t)
            gc.rectangle('fill',-w/2,-h/2,w,h)
            gc.setColor(dc[1],dc[2],dc[3])
            gc.setLineWidth(3)
            gc.rectangle('line',-w/2,-h/2,w,h)
            gc.setColor(1,1,1)
            gc.draw(rc.txt,0,0,0,rc.s,rc.s,rc.w/2,rc.h/2)
            gc.setColor(dc[1],dc[2],dc[3],1-4*ct)
            gc.rectangle('line',-w/2-ct*80,-h/2-ct*80,w+ct*160,h+ct*160)
        end,
        event=function()
            sfx.play('click')
            for i=1,3 do
            bc.color[bList[bc.blockIndex]][i]=defaultColor[bList[bc.blockIndex]][i]
            end
            SLIDER.setPos('colorR',bc.color[bList[bc.blockIndex]][1])
            SLIDER.setPos('colorG',bc.color[bList[bc.blockIndex]][2])
            SLIDER.setPos('colorB',bc.color[bList[bc.blockIndex]][3])
        end
    },.2)

    BUTTON.create('switchL',{
        x=-660,y=-250,type='rect',w=250,h=500,ec=false,
        draw=function(bt,t,ct)
            if bc.blockIndex~=1 then
                gc.setLineWidth(20)
                gc.setColor(1,1,1,.5+1.5*t)
                gc.line(50,-100,-50,0,50,100)
            end
            if bt.ec and ct<.2 then
                gc.setLineWidth(16-ct*128)
                gc.setColor(1,1,1,.8-ct*6.4)
                gc.line(50-ct*600,-100,-50-ct*600,0,50-ct*600,100)
            end
        end,
        event=function(x,y,bt)
            if bc.blockIndex~=1 then sfx.play('swap') bt.ec=true else bt.ec=false end
            bc.blockIndex=max(1,bc.blockIndex-1)
            SLIDER.setPos('colorR',bc.color[bList[bc.blockIndex]][1])
            SLIDER.setPos('colorG',bc.color[bList[bc.blockIndex]][2])
            SLIDER.setPos('colorB',bc.color[bList[bc.blockIndex]][3])
        end
    },.2)
    BUTTON.create('switchR',{
        x=660,y=-250,type='rect',w=150,h=300,ec=false,
        draw=function(bt,t,ct)
            if bc.blockIndex~=#bList then
                gc.setLineWidth(20)
                gc.setColor(1,1,1,.5+1.5*t)
                gc.line(-50,-100,50,0,-50,100)
            end
            if bt.ec and ct<.2 then
                gc.setLineWidth(16-ct*128)
                gc.setColor(1,1,1,.8-ct*6.4)
                gc.line(-50+ct*600,-100,50+ct*600,0,-50+ct*600,100)
            end
        end,
        event=function(x,y,bt)
            if bc.blockIndex~=#bList then sfx.play('swap') bt.ec=true else bt.ec=false end
            bc.blockIndex=min(bc.blockIndex+1,#bList)
            SLIDER.setPos('colorR',bc.color[bList[bc.blockIndex]][1])
            SLIDER.setPos('colorG',bc.color[bList[bc.blockIndex]][2])
            SLIDER.setPos('colorB',bc.color[bList[bc.blockIndex]][3])
        end
    },.2)
    SLIDER.create('colorR',{
        x=-480,y=250,type='hori',sz={400,32},button={32,32},
        gear=0,pos=bc.color[bList[bc.blockIndex]][1],
        sliderDraw=function(g,sz)
            local v=bc.color[bList[bc.blockIndex]][1]
            gc.setColor(.5+.5*v,.5-.5*v,.5-.5*v,.5)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,.5,.5)
            gc.printf(string.format("R:%.2f(%.2X)",v,v*255+.5),font.JB,-210,-48,1000,'left',0,1/3,1/3,0,84)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bc.color[bList[bc.blockIndex]][1]=pos
        end
    })
    SLIDER.create('colorG',{
        x=0,y=250,type='hori',sz={400,32},button={32,32},
        gear=0,pos=bc.color[bList[bc.blockIndex]][2],
        sliderDraw=function(g,sz)
            local v=bc.color[bList[bc.blockIndex]][2]
            gc.setColor(.5-.5*v,.5+.5*v,.5-.5*v,.5)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(.5,1,.5)
            gc.printf(string.format("G:%.2f(%.2X)",v,v*255+.5),font.JB,-210,-48,1000,'left',0,1/3,1/3,0,84)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bc.color[bList[bc.blockIndex]][2]=pos
        end
    })
    SLIDER.create('colorB',{
        x=480,y=250,type='hori',sz={400,32},button={32,32},
        gear=0,pos=bc.color[bList[bc.blockIndex]][3],
        sliderDraw=function(g,sz)
            local v=bc.color[bList[bc.blockIndex]][3]
            gc.setColor(.5-.5*v,.5-.5*v,.5+.5*v,.5)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(.5,.5,1)
            gc.printf(string.format("B:%.2f(%.2X)",v,v*255+.5),font.JB,-210,-48,1000,'left',0,1/3,1/3,0,84)
        end,
        buttonDraw=function(pos,sz)
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
        end,
        always=function(pos)
            bc.color[bList[bc.blockIndex]][3]=pos
        end
    })
end
function bc.keyP(k)
    if k=='escape' then
        scene.switch({
            dest='custom',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
            anim=function() anim.confBack(.1,.05,.1,0,0,0) end
        })
    end
end
function bc.mouseP(x,y,button,istouch)
    if not BUTTON.press(x,y) and SLIDER.mouseP(x,y,button,istouch) then
    end
end
function bc.mouseR(x,y,button,istouch)
    BUTTON.release(x,y)
    SLIDER.mouseR(x,y,button,istouch)
end
function bc.update(dt)
    BUTTON.update(dt,adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
    if SLIDER.acting then SLIDER.always(SLIDER.list[SLIDER.acting],
        adaptWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)) end
end
local w,h,x,y
function bc.draw()
    gc.setColor(1,1,1)
    gc.printf(cfcc.title,font.Bender,0,-460,1280,'center',0,.8,.8,640,font.height.Bender/2)

    BUTTON.draw() SLIDER.draw()

    if bc.blockSkin.previewDraw then
        gc.push('transform')
        w,h,x,y=blocks.size(blocks[bList[bc.blockIndex]] or extraBlockList[bList[bc.blockIndex]])
        gc.translate(0,-250)
        gc.scale(2.5/max(h/2.4,1))
        bc.blockSkin.previewDraw(blocks[bList[bc.blockIndex]] or extraBlockList[bList[bc.blockIndex]],x,y,bc.color[bList[bc.blockIndex]],bc.texType[bList[bc.blockIndex]])
        gc.pop()

        gc.push('transform')
        gc.translate(-400,-250)
        gc.scale(1.5/max(h/2.4,1))
        if bc.blockIndex-1>0 then
            w,h,x,y=blocks.size(blocks[bList[bc.blockIndex-1]] or extraBlockList[bList[bc.blockIndex-1]])
            bc.blockSkin.previewDraw(blocks[bList[bc.blockIndex-1]] or extraBlockList[bList[bc.blockIndex-1]],x,y,bc.color[bList[bc.blockIndex-1]],bc.texType[bList[bc.blockIndex-1]])
        end
        gc.pop()

        gc.push('transform')
        gc.translate(400,-250)
        gc.scale(1.5/max(h/2.4,1))
        if bc.blockIndex+1<=#bList then
            w,h,x,y=blocks.size(blocks[bList[bc.blockIndex+1]] or extraBlockList[bList[bc.blockIndex+1]])
            bc.blockSkin.previewDraw(blocks[bList[bc.blockIndex+1]] or extraBlockList[bList[bc.blockIndex+1]],x,y,bc.color[bList[bc.blockIndex+1]],bc.texType[bList[bc.blockIndex+1]])
        end
        gc.pop()
    end

    gc.setColor(1,1,1)
    gc.printf(bList[bc.blockIndex],font.Bender,0,-80,1280,'center',0,.6,.6,640,font.height.Bender/2)
end
function bc.exit()
    bc.save()
end
return bc