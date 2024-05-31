local BUTTON=scene.button
local devList={
    devTeam={
        name="Team Blanker",
        member={'Aqua6623(Aquamarine6623, Kairan, 海兰)'}
    },
    program={'Aqua6623'},
    sfx={'Aqua6623'},
    art={'Aqua6623','MrZ_26'},
    UI={'Aqua6623'},
    music={
        hurtRecord={
        'たかゆき','R-side','T-Malu','守己','カモキング','龍飛','Syun Nakano','Naoki Hirai',
        'つかスタジオ','アキハバラ所司代','georhythm','Teada','Mikiya Komaba','ミレラ','周藤三日月',
        'DiscreetDragon'
        }
    },
    specialThanks={'MrZ_26'}
}
local repo={
    {'json','rxi'}
}
local about={}
function about.init()
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
                dest='menu',destScene=require('scene/menu'),swapT=.7,outT=.3,
                anim=function() anim.cover(.3,.4,.3,0,0,0) end
            })
        end
    },.2)
end
function about.mouseP(x,y,button,istouch)
    BUTTON.press(x,y,button,istouch)
end
function about.mouseR(x,y,button,istouch)
    BUTTON.release(x,y,button,istouch)
end

function about.update(dt)
    BUTTON.update(dt,adaptAllWindow:inverseTransformPoint(ms.getX()+.5,ms.getY()+.5))
end
function about.draw()
    BUTTON.draw()
end
return about