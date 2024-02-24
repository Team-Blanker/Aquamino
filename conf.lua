function love.conf(t)
    local w=t.window
    w.title ="Aquamino Preview"
    w.icon='UI/icon.png'
    w.borderless=false
    w.resizable=true
    w.minwidth=200
    w.minheight=150
    w.width=1600
    w.height=900

    w.msaa=24
    w.vsync=0

    t.identity="AquaminoPreview"
    t.modules.touch=false

    t.gammacorrect=false
end