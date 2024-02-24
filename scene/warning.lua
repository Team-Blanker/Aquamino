local warn={}
local bannedkey={'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12','tab'}
function warn.init()
    scene.BG=require'BG/blank'
end
function warn.switch()
    scene.switch({
        dest='intro',swapT=.7,outT=.3,
        anim=function() anim.cover(.3,.4,.3,0,0,0) end
    })
end
function warn.keyP(k)
    if k=='escape' then love.event.quit() else warn.switch() end
end
function warn.mouseP(x,y,button,istouch)
    warn.switch()
end
local title="光敏性癫痫警告"
local txt="极小部分人可能会在看到特定视觉图像（包括可能出现在视频游戏中的闪烁效果或图案）时出现癫痫症状。\n此类症状包括头晕目眩、视线模糊、眼睛或面部抽搐、四肢抽搐、迷失方向感、精神错乱或短暂的意识丧失。\n\n即使没有癫痫史的人也可能出现此类症状。\n如果你出现任何症状，请立即停止游戏并咨询医生。"
function warn.draw()
    gc.clear(.08,.08,.08)

    gc.setColor(1,1,1,2*scene.time-.5)
    gc.printf(title,Exo_2,0,-300,1000,'center',0,.6,.6,500,84)
    gc.setColor(.5,1,.75,2*scene.time-.5)
    gc.printf(txt,Exo_2,0,-160,4000,'center',0,50/128,50/128,2000,84)

end
--function intro.send() scene.cur.modename[1]="40行" end
return warn