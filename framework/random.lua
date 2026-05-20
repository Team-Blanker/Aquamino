local abs,min,max=math.abs,math.min,math.max

--使用Xorshift（异或位移）实现的随机数生成器，由于是32位整数，其周期为2^32-1
local rng={}
rng.generator={}
function rng.newGenerator(name,seed)
    if seed then seed=(seed-1)%4294967295+1 end
    rng.generator[name]={seed=seed or os.time()-6623}
    rng.generator[name].num=rng.generator[name].seed
    rng.generator[name].iteration=0
end
function rng.setSeed(name,seed)
    if not name or not rng.generator[name] then error('RNG name is not correct, or the RNG you find do not exist') end
    if not seed then error('Specify the RNG seed!') end
    seed=(seed-1)%4294967295+1
    rng.generator[name].seed=seed
    rng.generator[name].num=seed
    rng.generator[name].iteration=0
end
function rng.destroy(name)
    rng.generator[name]=nil
end

function rng.getSeed(name)
    if not name or not rng.generator[name] then error('RNG name is not correct, or the RNG you find do not exist') end
    return rng.generator[name].seed
end
function rng.getIteration(name)
    if not name or not rng.generator[name] then error('RNG name is not correct, or the RNG you find do not exist') end
    return rng.generator[name].iteration
end

function rng.iterate(name)
    if not name or not rng.generator[name] then error('RNG name is not correct, or the RNG you find do not exist') end
    local g=rng.generator[name]
    g.num=bit.bxor(g.num,bit.lshift(g.num,13))
    g.num=bit.bxor(g.num,bit.rshift(g.num,17))
    g.num=bit.bxor(g.num,bit.lshift(g.num, 5))

    g.iteration=g.iteration+1
end

function rng.random(name,a,b)
    rng.iterate(name)
    if a and type(a)~='number' then error('RNG arguments should be numbers') end
    if b and type(b)~='number' then error('RNG arguments should be numbers') end
    if a then a=math.modf(a) end  if b then b=math.modf(b) end --参数截断取整
    local num=rng.generator[name].num
    if not a then --无参数，返回[0,1)
        return num/4294967296+.5
    elseif a and not b then --单个参数，返回[1,a]
    return num%a+1
    else --两个参数，返回[a,b]
    return num%(abs(b-a)+1)+min(a,b)
    end
end
return rng