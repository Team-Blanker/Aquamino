local SLIDER=scene.slider
local lst={}

function lst.button()
end
function lst.slider(menu)
    local argTxt=user.lang.menu.arg
    SLIDER.create('battle_botDropDelay',{
        x=0,y=0,type='hori',sz={800,32},button={32,32},
        gear=0,pos=1-(menu.option.battle.bot_DropDelay-.2)/1.8,
        act=function ()
            return menu.lvl==2 and menu.selectedMode=='battle'
        end,
        sliderDraw=function(g,sz)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(argTxt.battle.bot_PPS..": %.2f",1/menu.option.battle.bot_DropDelay),
                font.JB,-416,-48,114514,'left',0,.3125,.3125,0,84)
            end
        end,
        buttonDraw=function(pos,sz)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
            end
        end,
        always=function(pos)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            menu.option.battle.bot_DropDelay=2-1.8*pos
            end
        end
    })
end
return lst