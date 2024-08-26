local cos,sin,pi=math.cos,math.sin,math.pi
local min,max=math.min,math.max

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
function sfx.play(key,volume,pitch,pos)--音频名，音量，音高，位置（-1到1，映射到一个半圆弧上）
    local fpos
    if pos then fpos=max(min(pos,1),-1) else fpos=0 end
    local x,y=sin(fpos*pi/2),cos(fpos*pi/2)

    local name=sfx.key[key]

    if not (sfx.pack[name] and sfx.buffer[name]) then return false end
    if not volume then volume=1 end if not pitch then pitch=1 end

    if sfx.pack[name]:isPlaying() then
        local buffer=sfx.buffer[name]
        for i=1,#buffer do
            if not buffer[i].sfx:isPlaying() then--如果缓冲区有没播放的音频，放这个
                buffer[i].sfx:setVolume(sfx.volume*volume) buffer[i].sfx:setPitch(pitch)
                if buffer[i].sfx:getChannelCount()==1 then buffer[i].sfx:setPosition(x,y) end
                buffer[i].sfx:play() buffer[i].TTL=sfx.TTL return true
            end
        end
        if #buffer<sfx.cloneLim then--如果没超出复制上限，复制一个出来放
        buffer[#buffer+1]={sfx=sfx.pack[name]:clone(),TTL=sfx.TTL}
        buffer[#buffer].sfx:setVolume(sfx.volume*volume) buffer[#buffer].sfx:setPitch(pitch)
        if buffer[#buffer].sfx:getChannelCount()==1 then buffer[#buffer].sfx:setPosition(x,y) end
        buffer[#buffer].sfx:play()
        else--否则，找快放完的那个重新放一遍
            local k,t=0,0
            for i=1,#buffer do
                local tell=buffer[i].sfx:tell()
                if tell>t then k=i t=tell end
            end
            buffer[k].sfx:seek(0)
            buffer[k].sfx:setVolume(sfx.volume*volume) buffer[#buffer].sfx:setPitch(pitch)
            if buffer[k].sfx:getChannelCount()==1 then buffer[k].sfx:setPosition(x,y) end
            buffer[k].sfx:play()
        end
    else--如果本体没放，放本体
        sfx.pack[name]:setVolume(sfx.volume*volume) sfx.pack[name]:setPitch(pitch)
        if sfx.pack[name]:getChannelCount()==1 then sfx.pack[name]:setPosition(x,y) end
        sfx.pack[name]:play()
    end
    return true--执行到这里肯定找了个音频放了
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