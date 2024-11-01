local ffi=require'ffi'
local head=love.filesystem.newFile('mino/bot/coldclear.h'):read()
ffi.cdef(head)
local c=ffi.C
local gamePath=love.filesystem.getWorkingDirectory()
local SBPath=love.filesystem.getSourceBaseDirectory()
print(gamePath)
local os=love.system.getOS()
local CC
if os=='Windows' then
    CC=ffi.load(gamePath..'/cold_clear.dll')
elseif os=='Linux' then
    CC=ffi.load(SBPath..'/Aquamino/cold_clear.so')
end
--CCAsyncBot *cc_launch_async(CCOptions *options, CCWeights *weights, CCBook *book, CCPiece *queue,
--uint32_t count),
--[[
option={
    mode=0/1/2(0G/20G/仅硬降)
    spawn_rule=0/1/2([19]或[20]列/[21]列并在出生时立刻降落一格/？)
    pcloop=0/1/2(不PC/以最快速度PC/攻击向PC)
    min_nodes=最少搜索节点数，数量一般在几千以上？
    max_nodes=最多搜索节点数
    threads=线程数？……默认设为1好了
    use_hold=布尔值，是否使用hold
    speculate=bag出块下是否进行剩余块推测，不使用，false掉
}
]]
local defaultOption={
    mode=0,
    spawn_rule=0,
    pcloop=0,
    min_nodes=2000,
    max_nodes=100000,
    threads=1,
    use_hold=true,
    speculate=false
}

local defaultWeight={
    back_to_back=0,
    bumpiness=0,
    bumpiness_sq=0,
    row_transitions=0,
    height=0,
    top_half=0,
    top_quarter=0,
    jeopardy=0,
    cavity_cells=0,
    cavity_cells_sq=0,
    overhang_cells=0,
    overhang_cells_sq=0,
    covered_cells=0,
    covered_cells_sq=0,
    tslot={0,0,0,0},
    well_depth=0,
    max_well_depth=0,
    well_column={0,0,0,0,0,0,0,0,0,0},

    b2b_clear=0,
    clear1=0,
    clear2=0,
    clear3=0,
    clear4=0,
    tspin1=0,
    tspin2=0,
    tspin3=0,
    mini_tspin1=0,
    mini_tspin2=0,
    perfect_clear=0,
    combo_garbage=0,
    move_time=0,
    wasted_t=0,

    use_bag=false,
    timed_jeopardy=false,--垃圾行时间相关参数？
    stack_pc_damage=true,
}

local seqRenderList={Z=6,S=5,J=4,L=3,T=2,O=1,I=0}
local opRenderList={[0]='ML','MR','rotateCW','rotateCCW','SD_drop'}

local NULL=ffi.new('void*')
local ccWrap={}

--设置，权重
function ccWrap.newBot(option,weight)--生成一个新bot
    local cco=ffi.new('CCOptions',{})
    CC.cc_default_options(cco)
    if option then for k,v in pairs(option) do
        cco[k]=v
    end end
    cco.min_nodes=256
    cco.max_nodes=32768
    cco.speculate=false
    local ccw=ffi.new('CCWeights',{})
    CC.cc_default_weights(ccw)
    if weight then for k,v in pairs(weight) do
        ccw[k]=v
    end end
    ccw.use_bag=false

    return {bot=CC.cc_launch_async(cco,ccw,NULL,NULL,0),move=ffi.new('CCMove',{})}
end
function ccWrap.updateBot(bot,CField,B2B,combo)
    CC.cc_reset_async(bot.bot,CField,B2B,combo)
end
function ccWrap.requestMove(bot,garbage)
    CC.cc_request_next_move(bot.bot,garbage or 0)
end
function ccWrap.destroyBot(bot)
    CC.cc_destroy_async(bot.bot)
end
function ccWrap.getOperation(bot)
    local result=1
    repeat result=CC.cc_poll_next_move(bot.bot,bot.move,NULL,NULL)
        --print(result)
    until tonumber(result)~=1

    --print('result:'..tonumber(result),bot.move.movement_count)
    if result==2 then return {} end
    local op={}
    for i=1,bot.move.movement_count do
        op[i]=opRenderList[tonumber(bot.move.movements[i-1])]
    end
    op.hold=bot.move.hold
    op.expect={}
    for i=0,3 do
        op.expect[2*i+1]=tonumber(bot.move.expected_x[i])+1
        op.expect[2*i+2]=tonumber(bot.move.expected_y[i])+1
    end
    return op
end
function ccWrap.addNextPiece(bot,piece)
    local p=ffi.new('CCPiece',seqRenderList[piece])
    CC.cc_add_next_piece_async(bot.bot,p)
end
function ccWrap.fieldToC(boolField)
    return ffi.new('bool[400]',boolField)
end

--[[thread内arg格式：
arg={
    op='send' 传输参数/'require' 拿操作,
    boolField=cc.renderField(player),
    B2B=player.history.B2B>0,
    combo=player.history.combo,
}
]]
local th=love.thread
function ccWrap.newThread(channelIndex,P,index)
    local thread={}
    thread.destroyed=false
    thread.channelIndex=channelIndex
    thread.sendChannel=th.getChannel("cc_recv"..channelIndex)
    thread.sendChannel:clear()
    thread.nextSendChannel=th.getChannel("cc_nextRecv"..channelIndex)
    thread.nextSendChannel:clear()
    thread.recvChannel=th.getChannel("cc_send"..channelIndex)
    thread.recvChannel:clear()
    thread.thread=th.newThread([[
        require'love.system'
        local cc=require('mino/bot/cc')
        local channelIndex,option,weight=...
        local bot=cc.newBot(option,weight)
        local firstMoveRequested=false
        local th=love.thread
        local s,r,nr=th.getChannel("cc_send"..channelIndex),th.getChannel("cc_recv"..channelIndex),th.getChannel("cc_nextRecv"..channelIndex)
        local sCount,rCount=0,0
        while true do
            next=nr:pop()
            if next then
                for i=1,#next do
                    cc.addNextPiece(bot,next[i])
                end
                --print('added '..#next..' pieces')

                --if not firstMoveRequested then cc.requestMove(bot) firstMoveRequested=true end
            end
            arg=r:demand()
            if arg then
            --print(arg.op)
                if arg.op=='send' then
                    sCount=sCount+1
                    cc.updateBot(bot,cc.fieldToC(arg.boolField),arg.B2B,arg.combo)
                    cc.requestMove(bot,arg.garbage)
                elseif arg.op=='require' then
                    rCount=rCount+1
                    --print(0)
                    local op=cc.getOperation(bot)
                    --print(1)
                    s:push(op)
                elseif arg.op=='destroy' then
                    cc.destroyBot(bot)
                    print('BOT DESTROYED')
                    break
                end
                --print(s:getCount(),r:getCount(),arg.op)
            end
        end
    ]])
    return thread
end
function ccWrap.startThread(thread,option,weight)
    thread.thread:start(thread.channelIndex,option,weight)
end
function ccWrap.destroyThread(thread)
    thread.sendChannel:push({op='destroy'})
    while thread.thread:isRunning() do
        --nothing 
    end
    --thread.thread:kill()
    thread.destroyed=true
    thread.thread:release()
end
function ccWrap.sendNext(thread,player,nextStart)
    local n={}
    for i=nextStart,#player.next do
        n[#n+1]=player.next[i]
    end
    thread.nextSendChannel:push(n)
end
function ccWrap.renderField(player)
    assert(player.w==10,'Field width must be 10')
    local boolField={}
    for y=1,min(#player.field,40) do
        for x=1,10 do
            boolField[10*(y-1)+x]=next(player.field[y][x]) and true or false
        end
    end
    for i=#boolField+1,400 do
        boolField[i]=false
    end
    --[[for i=39,0,-1 do
        local l=''
        for j=1,10 do
        l=l..(boolField[i*10+j] and '[]' or '  ')
        end
        print(l)
    end]]
    return boolField
end
function ccWrap.operate(player,op,isPlayer,mino)
    if op.hold then mino.operate.hold(player) end
    for i=1,#op do
        mino.operate[op[i]](player,false)
    end
    mino.operate.HD(player,isPlayer)
end
return ccWrap