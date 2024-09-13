local json=require('framework/json')
local fs=love.filesystem
local f={}
function f.read(path)
    local s=fs.newFile(path)
    s:open('r')
    local success,result=pcall(json.decode,s:read())
    print('read success',path,result)
    s:close()
    if success then return result end
    print("Warning: file [ "..path.." ] is not decoded correctly, or it's empty.")
    return {}
end
function f.save(path,dataTable)
    local s=fs.newFile(path)
    s:open('w')
    s:write(json.encode(dataTable))
    s:close()
end
return f