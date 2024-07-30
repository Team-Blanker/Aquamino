local mus={
    volume=0.8,
    type='parts',
    path='',
    tag={},
    intro=nil,ITrans=nil,loop=nil,
    introEnd=false,swapDelay=0,
    loopTime=0,--循环了几次
    whole=nil,
    paused=false,stopped=false,
    distractCut=false,
    add=function(path,mode,form,loopStart,loopLen)
        local isSameMusic=(mus.path==path and mus.type==mode)
        mus.stop()
        assert(mode=='parts' or mode=='whole',"music type must be 'parts' or 'whole'")
        mus.path=path mus.type=mode
        if mode=='parts' then
            if not isSameMusic then
            if fs.getInfo(path..'/intro.'..form) then mus.intro=love.audio.newSource(path..'/intro.'..form,'stream') end
            if fs.getInfo(path..'/loop.'..form) then mus.loop=love.audio.newSource(path..'/loop.'..form,'stream') end
            if fs.getInfo(path..'/ITrans.'..form) then mus.ITrans=love.audio.newSource(path..'/ITrans.'..form,'stream') end
            end
            if mus.intro then mus.intro:seek(0) end
            if mus.loop then mus.loop:seek(0) end
            if mus.ITrans then mus.ITrans:seek(0) end
        elseif not isSameMusic and fs.getInfo(path..'/whole.'..form) then mus.whole=love.audio.newSource(path..'/whole.'..form,'stream')
            mus.loopStart=loopStart mus.loopLen=loopLen
        end
        if mus.whole then mus.whole:seek(0) end--新的音乐文件，第一次seek会卡
        mus.tag={} mus.loopTime=0
    end,
    setTag=function(arg)
        assert(type(arg)=='table','Tags must be a list')
        mus.tag=arg
    end,
    checkTag=function(tag)
        for k,v in pairs(mus.tag) do
            if v==tag then return true end
        end
        return false
    end,
    start=function()
        if mus.type=='parts' then
            if mus.intro then mus.intro:setVolume(mus.volume) end
            if mus.ITrans then mus.ITrans:setVolume(mus.volume) end
            if mus.loop then mus.loop:setVolume(mus.volume) mus.loop:setLooping(true) end
            mus.introEnd=false
            if mus.intro then mus.intro:play() print("Music started")
            elseif mus.loop then mus.loop:play() print("Music started") else print("Music not exist") end
        elseif mus.type=='whole' then 
            if mus.whole then mus.whole:setVolume(mus.volume) mus.whole:play() print("Music started")
            else print("Music not exist") end
        end
        mus.paused,mus.stopped=false,false
    end,
    stop=function()
        mus.stopped=true
        if mus.intro then mus.intro:stop() end
        if mus.ITrans then mus.ITrans:stop() end
        if mus.loop then mus.loop:stop() end
        if mus.whole then mus.whole:stop() end
    end,
    pause=function()
        mus.paused=true
        if mus.intro then mus.intro:pause() end
        if mus.ITrans then mus.ITrans:pause() end
        if mus.loop then mus.loop:pause() end
        if mus.whole then mus.whole:pause() end
    end,
    setPitch=function(p)
        if mus.intro then mus.intro:setPitch(p) end
        if mus.ITrans then mus.ITrans:setPitch(p) end
        if mus.loop then mus.loop:setPitch(p) end
        if mus.whole then mus.whole:setPitch(p) end
    end,
    update=function(dt)
        if mus.type=='parts' then
            if not mus.intro or not mus.loop then return -1 end
            if not mus.paused and not mus.stopped then
                if mus.swapDelay==0 then
                    if not mus.intro:isPlaying() and not mus.introEnd then
                        if mus.ITrans then mus.ITrans:play() print("Playing ITrans") end
                        mus.loop:play() print("Music looping")
                        mus.introEnd=true
                    elseif mus.intro:getDuration()-mus.intro:tell()<=max(.008,mus.swapDelay) and not mus.introEnd then
                        if mus.ITrans then mus.ITrans:play() print("Playing ITrans") end
                        mus.loop:play() print("Music looping")
                        mus.introEnd=true
                    end
                end
            end
        elseif mus.whole then
            if mus.whole:tell()>=mus.loopStart+mus.loopLen then mus.whole:seek(mus.whole:tell()-mus.loopLen) end
            mus.loopTime=mus.loopTime+1
        end
    end,
    setMainVolume=function(volume)
        mus.volume=volume
        if mus.intro then mus.intro:setVolume(mus.volume) end
        if mus.ITrans then mus.ITrans:setVolume(mus.volume) end
        if mus.loop then mus.loop:setVolume(mus.volume) end
        if mus.whole then mus.whole:setVolume(mus.volume) end
    end,
    setVolume=function(volume)
        if mus.intro then mus.intro:setVolume(mus.volume*volume) end
        if mus.ITrans then mus.ITrans:setVolume(mus.volume*volume) end
        if mus.loop then mus.loop:setVolume(mus.volume*volume) end
        if mus.whole then mus.whole:setVolume(mus.volume*volume) end
    end,
    distract=function(time)
        local vol=mus.volume*max(min(1-time,1),0)
        if mus.intro then mus.intro:setVolume(vol) end
        if mus.ITrans then mus.ITrans:setVolume(vol) end
        if mus.loop then mus.loop:setVolume(vol) end
        if mus.whole then mus.whole:setVolume(vol) end
    end
}
return mus