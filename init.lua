--necessary loading.
local fs=love.filesystem
fs.createDirectory('conf')
fs.createDirectory('player')
fs.createDirectory('bot')


local bot=fs.newFile('mino/bot/dllai.dll'):read()
local saveBot=fs.newFile('bot/dllai.dll')
saveBot:open('w')
saveBot:write(bot)
saveBot:close()

--require('mino/bot/ai')

do
    local audio=require'scene/game conf/audio'
    audio.read() audio.save()
    local video=require'scene/game conf/video'
    video.read() video.save()
    local hand=require'scene/game conf/handling'
    hand.read() hand.save()
    local key=require'scene/game conf/keys'
    key.read() key.save()
    local custom=require'scene/game conf/custom'
    custom.read() custom.save()
    local lang=require'scene/game conf/language'
    lang.read() lang.save()
end

do
    if fs.getInfo('player/game stat') then
        local s=fs.newFile('player/game stat')
        local k=json.decode(s:read())
        win.stat.launch=k.launch+1
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