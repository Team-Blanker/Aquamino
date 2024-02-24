--inspired by Algodoo

--[[recommended world type:
world1={
    w
    obj={
        obstacle={}
        entity={...}
        ...
    }
    propertyList={
        obj={
            onCollide=function() end
        }
    }
}
]]
local physics={}
local LP=love.physics
function physics.init()--清空一切，从头再来
    physics.world={}
end
function physics.newWorld(name,xg,yg,sleep)--新世界，meter设为
    physics.world[name]=LP.newWorld(xg,yg,sleep)
    physics.world[name]:setMeter(1024)
end
function physics.createObject(world,objType,arg)
    local obj={body=nil,shape=nil,fixture=nil}
    --[[local propertyList={
        onCollide=nil,update=nil,onSpawn=nil,onDie=nil,collideSet={true}
    }]]
    if objType=='circle' then
        obj.body=love.physics.newBody(world,arg.posx,arg.posy,arg.bodyType)
        obj.shape=love.physics.newCircleShape(arg.r)
        obj.fixture=love.physics.newFixture(obj.body,obj.shape,arg.density)
    elseif objType=='rect' then
    elseif objType=='pie' then
    elseif objType=='poly' or objType=='polygon' then
    else error([[
objType incorrect.Correct types are:\n
poly(polygon) rect circle pie
]]) end
    arg.posx,arg.posy,arg.bodyType=nil,nil,nil
    if not arg.collideSet then arg.collideSet={true} end
    return obj,arg
end
--[[usage:
local ppList=nil
obj,pplist=physics.createObject(w,t,arg)
propertyList[obj].propertyList=ppList
]]
return physics