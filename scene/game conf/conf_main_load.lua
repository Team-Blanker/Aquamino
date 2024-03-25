local cf=user.lang.conf
local cfm=cf.main
scene.button.create('quit',{
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
            dest='menu',destScene=require(scene.cur.exitScene or 'scene/menu'),swapT=.7,outT=.3,
            anim=function() anim.cover(.3,.4,.3,0,0,0) end
        })
    end
},.2)
scene.button.create('test',{
    x=700,y=400,type='rect',w=200,h=100,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.5,.5,.5,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.8,.8,.8)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cf.test,font.Exo_2,0,0,1280,'center',0,.5,.5,640,84)
    end,
    event=function()
        scene.switch({
            dest='game',destScene=require'mino/game',
            swapT=.7,outT=.3,
            anim=function() anim.cover(.3,.4,.3,0,0,0) end
        })
        scene.sendArg='game conf/conf_main'
    end
},.2)

scene.button.create('keys',{
    x=360,y=-200,type='rect',w=600,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.25,.5,.375,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.4,.8,.6)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cfm.keys,font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/keys'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('ctrl',{
    x=360,y=0,type='rect',w=600,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.125,.25,.5,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.2,.4,.8)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cfm.ctrl,font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/handling'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('others',{
    x=260,y=200,type='rect',w=400,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.15,.125,.5,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.24,.2,.8)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cfm.other,font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/others'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('language',{
    x=580,y=200,type='rect',w=160,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.5,.125,.375,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.8,.2,.6)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.draw(win.UI.lang,0,0,0,1.5,1.5,50,50)
    end,
    event=function()
        scene.switch({
            dest='language',destScene=require('scene/game conf/language'),
            swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)

scene.button.create('audio',{
    x=-360,y=-200,type='rect',w=600,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.5,.25,.25,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.8,.4,.4)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cfm.audio,font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/audio'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('video',{
    x=-360,y=0,type='rect',w=600,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.5,.375,.125,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.8,.6,.2)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cfm.video,font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/video'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('custom',{
    x=-360,y=200,type='rect',w=600,h=160,
    draw=function(bt,t)
        local w,h=bt.w,bt.h
        gc.setColor(.15,.5,.125,.8+t)
        gc.rectangle('fill',-w/2,-h/2,w,h)
        gc.setColor(.24,.8,.2)
        gc.setLineWidth(3)
        gc.rectangle('line',-w/2,-h/2,w,h)
        gc.setColor(1,1,1)
        gc.printf(cfm.custom,font.Exo_2,0,0,1280,'center',0,.8,.8,640,84)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)