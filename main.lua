if os.getenv('LOCAL_LUA_DEBUGGER_VSCODE')=='1' then
    require('lldebugger').start()
end

loopTime=0

drawCtrl={dtRestrict=1/165,timer=0,FPS=0,count=0,FPStimer=0}
drawCtrl.timer=drawCtrl.dtRestrict
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    if love.timer then love.timer.step() end

    local dt=0

    return function()
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        if love.timer then dt = love.timer.step()
            if drawCtrl.dtRestrict~=0 then drawCtrl.timer=drawCtrl.timer+dt end
            drawCtrl.FPStimer=drawCtrl.FPStimer+dt
        end

        if love.update then love.update(dt) end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(0,0,0)

            if drawCtrl.timer>=drawCtrl.dtRestrict then
                if love.draw then love.draw() end
                love.graphics.present() drawCtrl.count=drawCtrl.count+1
                while drawCtrl.timer>drawCtrl.dtRestrict do drawCtrl.timer=drawCtrl.timer-drawCtrl.dtRestrict end
                if drawCtrl.FPStimer>1 then
                    drawCtrl.FPS=drawCtrl.count/math.floor(drawCtrl.FPStimer) drawCtrl.count=0
                    drawCtrl.FPStimer=drawCtrl.FPStimer-math.floor(drawCtrl.FPStimer)
                end
            end
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

mainLoop=love.run()

gc=love.graphics
fs=love.filesystem
kb=love.keyboard
ms=love.mouse
touch=love.touch

mymath=require'framework/mathextend' mytable=require'framework/tableextend'
anim=require'scene/swapAnim'
COLOR=require'framework/color'
json=require'framework/json'

rand=math.random
sin=math.sin cos=math.cos
floor=math.floor ceil=math.ceil
max=math.max min=math.min
abs=math.abs

ins,rem=table.insert,table.remove

math.randomseed(os.time()-6623)
for i=1,5 do rand() end

do
    gc.setDefaultFilter('linear','linear',16)
end

font={
    SYHT=gc.newFont('font/SourceHanSans-Regular.otf',128),
    Bender=gc.newFont('font/Bender.otf',128),
    Bender_B=gc.newFont('font/Bender-Bold.otf',128),
    Bender_L=gc.newFont('font/Bender-Light.otf',128),
    JB=gc.newFont('font/JetBrainsMono-Medium.ttf',128),
    JB_B=gc.newFont('font/JetBrainsMono-Bold.ttf',128),
    JB_L=gc.newFont('font/JetBrainsMono-Light.ttf',128),

    LED=gc.newFont('font/UniDreamLED.ttf',128)
}
font.Bender:setFallbacks(font.SYHT) font.Bender_B:setFallbacks(font.SYHT) font.Bender_L:setFallbacks(font.SYHT)
font.JB:setFallbacks(font.SYHT) font.JB_B:setFallbacks(font.SYHT)

canop=true--=can operate，是决定玩家是否能操作的变量

love.window.setMode(love.window.getMode()) --看似废话，但是如果去掉的话在我的框架里窗口颜色就会出神秘问题（至少Love 11.4如此）

function love.resize(w,h)
    win.H=h
    win.W=w
    adaptAllWindow=love.math.newTransform(
        win.W/2,win.H/2,0,
        win.H/win.W<9/16 and win.H/1080 or win.W/1920,win.H/win.W<9/16 and win.H/1080 or win.W/1920
    )
    win.scale=win.H/win.W<9/16 and win.H/1080 or win.W/1920
    gc.setScissor(0,0,w,h)
    print('Window resized:',w,h)
end

win={
    stat={launch=0,version="preview 0008",totalTime=0},
    showInfo=false,
    fullscr=false,
    distractTime=0,
    date=os.date('*t'),
    W=gc.getWidth(),
    W_win=gc.getWidth(),
    H=gc.getHeight(),
    H_win=gc.getHeight(),
    x=0,y=0,
    x_win=0,y_win=0,
    scale=1,
    changeFullscr=function()
        win.setFullscr(not win.fullscr)
    end,
    setFullscr=function(fsc)
        if win.fullscr==fsc then return else win.fullscr=fsc end
        if win.fullscr then
            win.W_win,win.H_win=gc.getDimensions()
            win.x_win,win.y_win=love.window.getPosition()
        else
            win.W,win.H=win.W_win,win.H_win
            win.x,win.y=win.x_win,win.y_win
        end
        adaptAllWindow=love.math.newTransform(
            win.W/2,win.H/2,0,
            win.H/win.W<9/16 and win.H/1080 or win.W/1920,win.H/win.W<9/16 and win.H/1080 or win.W/1920
        )
        love.window.setFullscreen(win.fullscr)
        win.W,win.H=gc.getDimensions()
        win.scale=win.H/win.W<9/16 and win.H/1080 or win.W/1920
        love.resize(win.W,win.H)
    end,
    UI={
        back=gc.newImage('pic/UI/sign/back.png'), --120*70
        lang=gc.newImage('pic/UI/sign/language.png')  --100*100
    }
}
win.H=gc.getHeight()
win.W=gc.getWidth()

user={
    langName='English',
    lang=nil
}
user.lang=require('language/'..user.langName)

scene={
    watermark=true,
    totalTime=0,
    enterNewScene=false,
    cur=require('scene/warning'),pos='warning',
    dest=nil,destScene=nil,
    BG=require('BG/blank'),
    nextBG=nil,
    time=0,
    swapT=0,
    outT=0,
    anim=nil,--过场动画
    latest=nil,
    path={'intro'},
    switch=function(arg)
        for k,v in pairs(arg) do scene[k]=v end
    end,
    sendArg=nil,
    recvArg=nil,

    button=require'framework/control/button',
    slider=require'framework/control/slider'
}

--scene.cur=require('territory/territory')
--scene.cur=require('mino/game') scene.cur.mode='battle_test'

win.x,win.y=love.window.getPosition()
win.x_win,win.y_win=love.window.getPosition()
win.scale=win.H/win.W<9/16 and win.H/1080 or win.W/1920
adaptAllWindow=love.math.newTransform(
    win.W/2,win.H/2,0,
    win.H/win.W<9/16 and win.H/1080 or win.W/1920,win.H/win.W<9/16 and win.H/1080 or win.W/1920
)

mus=require'framework/music' sfx=require'framework/sound'
voice={
    pack={},
    buffer={},
    timer=0
}

--[[]]require'init'--[[]]
scene.cur.init()
if scene.BG.init then scene.BG.init() end

lastkeyP=nil lastkeyR=nil

function love.keypressed(k)
    lastkeyP=k
    if k=='f10' then win.showInfo=not win.showInfo
    elseif k=='f11' then
        win.changeFullscr()
    elseif canop and scene.cur.keyP then
        scene.cur.keyP(k)
    end
    if scene.cur.detectKeyP then scene.cur.detectKeyP(k) end
end
function love.keyreleased(k)
    if not win.isAdjusting and canop and scene.cur.keyR then
        scene.cur.keyR(k)
    end
end
function love.mousepressed(x,y,button,istouch)
    local rx,ry=adaptAllWindow:inverseTransformPoint(x+.5,y+.5)
    if scene.cur.mouseP and canop then
        scene.cur.mouseP(rx,ry,button,istouch)
    end
end


function love.mousereleased(x,y,button,istouch)
    local rx,ry=adaptAllWindow:inverseTransformPoint(x+.5,y+.5)
    if scene.cur.mouseR and canop then
    scene.cur.mouseR(rx,ry,button,istouch) end
end

function mainUpdate(dt)
    if love.window.hasFocus() then win.distractTime=-1 else
        win.distractTime=max(win.distractTime,0)
        win.distractTime=win.distractTime+dt
    end

    if scene.dest or scene.destScene then canop=false
        if scene.swapT>0 then scene.swapT=scene.swapT-dt
        else scene.outT=scene.outT+scene.swapT scene.swapT=0
            local sendArg,recvArg=scene.sendArg,scene.recvArg
            local tosend=scene.cur.send
            if scene.cur.exit then scene.cur.exit() end
            scene.button.create() scene.slider.create()
            scene.pos=scene.dest
            if scene.destScene then scene.cur=scene.destScene scene.destScene=nil
            else scene.cur=require('scene/'..scene.dest) end
            sfx.pack={} sfx.buffer={}
            if tosend then tosend(scene.cur,sendArg) end scene.sendArg=nil
            if scene.nextBG then scene.BG=require('BG/'..scene.nextBG)
                if scene.BG.init then scene.BG.init() end
            end
            if scene.cur.init then scene.cur.init() scene.enterNewScene=true end
            if scene.cur.recv then scene.cur.recv(recvArg) end scene.recvArg=nil
            canop=true scene.dest=nil
            scene.time=0
        end
    else canop=true
        if scene.outT>0 then scene.outT=scene.outT-dt
        else scene.outT=0 scene.anim=nil end
    end


    scene.time,scene.totalTime,sfx.timer=scene.time+dt,scene.totalTime+dt,sfx.timer+dt

    if scene.cur.update then scene.cur.update(dt) end
    if scene.cur.BGUpdate then scene.cur.BGUpdate(dt)
    elseif scene.BG.update then scene.BG.update(dt) end

    if sfx.timer>5 then
        for i=#sfx.buffer,1,-1 do
            if not sfx.buffer[i]:isPlaying() then table.remove(sfx.buffer,i) end
        end
        sfx.timer=sfx.timer-5
    end
end
local animInit=false
function love.update(dt)
    if not animInit then anim.init() animInit=true end
    local dtRemain=dt
    while dtRemain>=1/256 do
        if scene.enterNewScene then
            dtRemain=0
        else
            mainUpdate(1/256) dtRemain=dtRemain-1/256
        end
    end
    if scene.enterNewScene then scene.enterNewScene=false else mainUpdate(dtRemain) end
    mus.update(dt)
    mus.distract(mus.distractCut and win.distractTime>0 and 1 or 0)
end
function love.draw()
    local dpiS=love.window.getDPIScale()
    local rw,rh=dpiS*win.W,dpiS*win.H

    --[[画面显示：找到最大的16:9的矩形，居中，以该矩形的中心为原点，向右为x轴正方向，向下为y轴正方向，
    矩形长边为1920单位，短边为1080单位，以此为基准进行绘制]]
    gc.applyTransform(adaptAllWindow)
    local rx,ry=gc.inverseTransformPoint(ms.getX()+.5,ms.getY()+.5)
    gc.setColor(1,1,1)--若未说明，图像绘制统一为白色，下同
    if scene.BG.draw then scene.BG.draw() end
    gc.setColor(1,1,1)
    if scene.cur.draw then scene.cur.draw() end
    if scene.watermark then
        gc.setColor(.5,1,.875,.15+.0*sin(scene.totalTime*5*math.pi))
        gc.printf("作者：Aqua6623",font.JB_B,480*sin(scene.totalTime/2*math.pi),-440,5000,'center',0,.5,.5,2500,84)
        gc.printf("作者：Aqua6623",font.JB_B,-480*sin(scene.totalTime/2*math.pi), 440,5000,'center',0,.5,.5,2500,84)
        --gc.printf("未经授权禁止转载",Consolas_B,-480*sin(scene.totalTime/2*math.pi),440,5000,'center',0,.5,.5,2500,84)
    end
    gc.setColor(1,1,1)
    if scene.anim then scene.anim() end
    gc.setColor(1,1,1,.5)
    gc.print("TPS: "..love.timer.getFPS()..", FPS:"..drawCtrl.FPS..", gcinfo: "..gcinfo(),font.Bender_B,-950,510,0,.2,.2)

    gc.origin()

    local aw,ah=win.H/win.W<9/16 and win.H*16/9 or win.W,win.H/win.W<9/16 and win.H or win.W*9/16
    gc.setColor(0,0,0)
    gc.rectangle('fill',0,0,(win.W-aw)/2,win.H)
    gc.rectangle('fill',(win.W+aw)/2,0,(win.W-aw)/2,win.H)
    gc.rectangle('fill',0,0,win.W,(win.H-ah)/2)
    gc.rectangle('fill',0,(win.H+ah)/2,win.W,(win.H-ah)/2)

    gc.setColor(1,1,1)
    if win.showInfo then
        local infoL="Current scene: "..scene.pos.."\nCursor pos:"..("%.2f,%.2f"):format(rx,ry)
        if canop then infoL=infoL.."\nYou can operate now"
        else infoL=infoL.."\nYou can\'t operate now" end
        infoR="You\'ve stayed here for "..string.format("%.2f",scene.time).."s".."\nRes:"..win.W.."*"..win.H.."\nReal res:"..rw.."*"..rh.."\nWindow mode position:"..win.x_win..","..win.y_win.."\n"..drawCtrl.timer.."/"..drawCtrl.dtRestrict.."\n"..(lastkeyP and lastkeyP or "")
        gc.print(infoL,font.Bender,10,25,0,.15,.15)
        gc.printf(infoR,font.Bender,win.W-10-114514*.15,25,114514,'right',0,.15,.15)
    end
end

function love.quit()
    if fs.getInfo('player/game stat') then
        win.stat.totalTime=win.stat.totalTime+scene.totalTime
        local s=fs.newFile('player/game stat')
        s:open('w')
        s:write(json.encode(win.stat))
        s:close()
    else
        local s=fs.newFile('player/game stat')
        win.stat.launch=1
        s:open('w')
        s:write(json.encode(win.stat))
        s:close()
    end
end