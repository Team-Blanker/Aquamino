--necessary loading.
local fs=love.filesystem
fs.createDirectory('conf')
fs.createDirectory('player')
fs.createDirectory('bot')

do
    local audio=require'scene/game conf/audio'
    audio.read() audio.save()
    local video=require'scene/game conf/video'
    video.read() video.save()
    local hand=require'scene/game conf/handling'
    hand.read() hand.save()
    local key=require'scene/game conf/keys'
    key.read() key.save()
    local VKey=require'scene/game conf/virtualKey'
    VKey.read() VKey.save()
    local custom=require'scene/game conf/custom'
    custom.read() custom.save()
    local clr=require'scene/game conf/mino color'
    clr.read() clr.save()
    local bb=require'scene/game conf/board bounce'
    bb.read() bb.save()
    local lang=require'scene/game conf/language'
    lang.read() lang.save()
end

do
    if fs.getInfo('player/game stat') then
        local k=file.read('player/game stat')
        k.version=nil
        mytable.combine(win.stat,k)
        win.stat.launch=win.stat.launch+1
        file.save('player/game stat',win.stat)
    else
        win.stat.launch=1
        file.save('player/game stat',win.stat)
    end
end
do
    local s=file.read('player/best score')
    file.save('player/best score',s)
end