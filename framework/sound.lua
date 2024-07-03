local sfx={
    volume=1,
    key={},
    pack={},
    buffer={},
    timer=0,
    TTL=1,
    cloneLim=16
}
function sfx.add(arg)
    for k,v in pairs(arg) do
        sfx.key[k]=v
        if not sfx.pack[v] and love.filesystem.getInfo(v) then sfx.pack[v]=love.audio.newSource(v,'static') end
        sfx.buffer[v]={}
    end
end
function sfx.play(key,volume,pitch)
    local name=sfx.key[key]
    if not (sfx.pack[name] and sfx.buffer[name]) then return -1 end
    if not volume then volume=1 end if not pitch then pitch=1 end
    if sfx.pack[name]:isPlaying() then
        local newClone=true
        local buffer=sfx.buffer[name]
        for i=1,#buffer do
            if not buffer[i].sfx:isPlaying() then--如果缓冲区有没播放的音频，放这个
                buffer[i].sfx:setVolume(sfx.volume*volume) buffer[i].sfx:setPitch(pitch)
                buffer[i].sfx:play() buffer[i].TTL=sfx.TTL newClone=false break
            end
        end
        if newClone then
        if #buffer<sfx.cloneLim then--如果没超出复制上限，复制一个出来放
        buffer[#buffer+1]={sfx=sfx.pack[name]:clone(),TTL=sfx.TTL}
        buffer[#buffer].sfx:setPitch(pitch) buffer[#buffer].sfx:play()
        else--否则，找快放完的那个重新放一遍
            local k,t=0,0
            for i=1,#buffer do
                local tell=buffer[i].sfx:tell()
                if tell>t then k=i t=tell end
            end
            buffer[k].sfx:seek(0) buffer[k].sfx:play()
        end
        end
    else--如果本体没放，放本体
        sfx.pack[name]:setVolume(sfx.volume*volume) sfx.pack[name]:setPitch(pitch)
        sfx.pack[name]:play()
    end
end
function sfx.update(dt)
    for name,buffer in pairs(sfx.buffer) do for i=buffer,1,-1 do
        buffer[i].TTL=buffer[i].TTL-dt
        if buffer[i].TTL<=0 then table.remove(buffer,i) end
    end end
end
function sfx.clear()
    sfx.key={}
end
return sfx