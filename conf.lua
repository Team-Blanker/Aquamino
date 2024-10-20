function love.conf(t)
    local w=t.window
    w.title="Aquamino Beta V0.3"
    w.icon='pic/UI/icon.png'
    w.borderless=false
    w.resizable=true
    w.minwidth=640
    w.minheight=480
    w.width=1600
    w.height=900

    w.msaa=24
    w.vsync=0

    w.highdpi=true

    t.version='11.4'

    t.identity="Aquamino"
    t.externalstorage=true

    t.gammacorrect=false
end