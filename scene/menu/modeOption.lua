local BUTTON,SLIDER=scene.button,scene.slider
local lst={}
lst.slTxt={}
function lst.button()
    local argTxt=user.lang.menu.arg
    BUTTON.setLayer(2)
end
function lst.slider(menu)
    local argTxt=user.lang.menu.arg
    local opt=menu.option
    SLIDER.create('battle_botDropDelay',{
        x=0,y=-64,type='hori',sz={800,32},button={32,32},
        gear=0,pos=(1/opt.battle.bot_DropDelay-.2)/4.8,
        act=function ()
            return menu.lvl==2 and menu.selectedMode=='battle'
        end,
        sliderDraw=function(g,sz)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(argTxt.battle.bot_PPS..":%.2f",1/opt.battle.bot_DropDelay),
                font.JB,-416,-48,10000,'left',0,1/3,1/3,0,84)
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
            opt.battle.bot_DropDelay=1/(4.8*pos+.2)
            end
        end
    })
    local ppl,ppr=argTxt.battle.player.pos..":"..argTxt.battle.player.left,argTxt.battle.player.pos..":"..argTxt.battle.player.right
    SLIDER.create('battle_playerPos',{
        x=0,y=64,type='hori',sz={500,32},button={32,32},
        gear=2,pos=opt.battle.playerPos=='left' and 0 or 1,
        act=function ()
            return menu.lvl==2 and menu.selectedMode=='battle'
        end,
        sliderDraw=function(g,sz)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf((opt.battle.playerPos=='left' and ppl or ppr),
                font.JB,0,-48,10000,'center',0,1/3,1/3,5000,84)
            end
        end,
        buttonDraw=function(pos,sz)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos==0 and -.5 or .5),0,20,4)
            end
        end,
        always=function(pos)
            if menu.lvl==2 and menu.selectedMode=='battle' then
            opt.battle.playerPos=pos==0 and 'left' or 'right'
            end
        end
    })
    SLIDER.create('cd_botDropDelay',{
        x=0,y=-64,type='hori',sz={800,32},button={32,32},
        gear=0,pos=(1/opt['tower defense'].bot_DropDelay-.2)/4.8,
        act=function ()
            return menu.lvl==2 and menu.selectedMode=='tower defense'
        end,
        sliderDraw=function(g,sz)
            if menu.lvl==2 and menu.selectedMode=='tower defense' then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            gc.printf(string.format(argTxt.battle.bot_PPS..":%.2f",1/opt['tower defense'].bot_DropDelay),
                font.JB,-416,-48,10000,'left',0,1/3,1/3,0,84)
            end
        end,
        buttonDraw=function(pos,sz)
            if menu.lvl==2 and menu.selectedMode=='tower defense' then
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
            end
        end,
        always=function(pos)
            if menu.lvl==2 and menu.selectedMode=='tower defense' then
            opt['tower defense'].bot_DropDelay=1/(4.8*pos+.2)
            end
        end
    })
    SLIDER.create('IceStorm_iceOpacity',{
        x=0,y=-64,type='hori',sz={800,32},button={32,32},
        gear=0,pos=(opt['ice storm'].iceOpacity-.5)*2,
        act=function ()
            return menu.lvl==2 and menu.selectedMode=='ice storm'
        end,
        sliderDraw=function(g,sz)
            if menu.lvl==2 and menu.selectedMode=='ice storm' then
            gc.setColor(.5,.5,.5,.8)
            gc.polygon('fill',-sz[1]/2-8,0,-sz[1]/2,-8,sz[1]/2,-8,sz[1]/2+8,0,sz[1]/2,8,-sz[1]/2,8)
            gc.setColor(1,1,1)
            local tw=font.JB:getWidth(argTxt['ice storm'].iceOpacity)
            local aw=692
            gc.printf(argTxt['ice storm'].iceOpacity,
                font.JB,-400,-48,10000,'left',0,min(aw/tw,.3125),min(aw/tw,.3125),16,84)
            gc.printf(string.format(":%3d%%",opt['ice storm'].iceOpacity*100+.5),
                font.JB,-400+min(tw*.3125,aw),-48,10000,'left',0,1/3,1/3,16,84)
            end
        end,
        buttonDraw=function(pos,sz)
            if menu.lvl==2 and menu.selectedMode=='ice storm' then
            gc.setColor(1,1,1)
            gc.circle('fill',sz[1]*(pos-.5),0,20,4)
            end
        end,
        always=function(pos)
            if menu.lvl==2 and menu.selectedMode=='ice storm' then
            opt['ice storm'].iceOpacity=pos/2+.5
            end
        end
    })
end
return lst