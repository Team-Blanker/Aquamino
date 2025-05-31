local M = {}

local os_ext_map = {
    Windows = 'dll',
    Linux = 'so',
    ['OS X'] = 'dylib'
}

function M.getCCLibName()
    local os = love.system.getOS()
    local ext = os_ext_map[os]
    if ext then
        return 'cold_clear.' .. ext
    else
        return nil
    end
end

return M
