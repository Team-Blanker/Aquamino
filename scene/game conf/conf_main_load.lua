local cf=user.lang.conf
local cfm=cf.main
local arcs,arcf=math.pi/2,5*math.pi/2
scene.button.create('quit',{
    x=-750,y=250*3^.5,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.5,.5,.5,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(.8,.8,.8)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.draw(win.UI.back,0,0,0,1.5,1.5,60,35)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require(scene.cur.exitScene or 'scene/menu'),swapT=.7,outT=.3,
            anim=function() anim.cover(.3,.4,.3,0,0,0) end
        })
    end
},.2)
scene.button.create('test',{
    x=750,y=250*3^.5,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.5,.5,.5,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(.8,.8,.8)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.printf(cf.test,font.Bender,0,0,1280,'center',0,.75,.75,640,76)
    end,
    event=function()
        scene.switch({
            dest='game',destScene=require'mino/game',
            swapT=.7,outT=.3,
            anim=function() anim.cover(.3,.4,.3,0,0,0) end
        })
    end
},.2)

scene.button.create('keys',{
    x=250,y=250*3^.5,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.25,.5,.4375,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(.5,1,.875)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.printf(cfm.keys,font.Bender,0,0,1280,'center',0,.75,.75,640,76)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/keys'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('ctrl',{
    x=500,y=0,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.125,.25,.5,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(.25,.5,1)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.printf(cfm.ctrl,font.Bender,0,0,1280,'center',0,.75,.75,640,76)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/handling'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('language',{
    x=250,y=-250*3^.5,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.5,.125,.375,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,.25,.75)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
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
    x=-250,y=-250*3^.5,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.5,.25,.25,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,.5,.5)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.printf(cfm.audio,font.Bender,0,0,1280,'center',0,.75,.75,640,76)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/audio'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('video',{
    x=-500,y=0,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.5,.375,.125,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,.75,.25)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.printf(cfm.video,font.Bender,0,0,1280,'center',0,.75,.75,640,76)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/video'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)
scene.button.create('custom',{
    x=-250,y=250*3^.5,type='circle',r=250,
    draw=function(bt,t)
        gc.setColor(.15,.5,.125,.3+t)
        gc.arc('fill',0,0,bt.r,arcs,arcf,6)
        gc.setColor(.3,1,.25)
        gc.setLineWidth(9)
        gc.arc('line','closed',0,0,bt.r,arcs,arcf,6)
        gc.setColor(1,1,1)
        gc.printf(cfm.custom,font.Bender,0,0,1280,'center',0,.75,.75,640,76)
    end,
    event=function()
        scene.switch({
            dest='menu',destScene=require('scene/game conf/custom'),swapT=.15,outT=.1,
            anim=function() anim.cover(.1,.05,.1,0,0,0) end
        })
    end
},.2)