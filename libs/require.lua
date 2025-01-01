local originalRequire = require
local loadedModules = {}


package = package or {}
package.path = package.path or "?.lua;"
package.preload = package.preload or {}
package.loaded = setmetatable(package.loaded or {}, {
    __index = loadedModules,
    __newindex = function() error("Modification of package.loaded is not allowed.") end,
    __metatable = false,
})

local tempData = {}

--- Get the module and resource info based on the module name
---@param moduleName string
---@return string? resource
---@return string modulePath
local function getModuleInfo(moduleName)
    local resource = moduleName:match("^@(.-)/.+")
    if resource then
        return resource, moduleName:sub(#resource + 3)
    end

    local idx = 4 -- Stack level for tracing the calling script
    while true do
        local source = debug.getinfo(idx, "S") and debug.getinfo(idx, "S").source
        if not source then return nil, moduleName end

        resource = source:match("^@@([^/]+)/.+")
        if resource then
            return resource, moduleName
        end
        idx = idx + 1
    end
end


--- Search for a module file in the given paths
---@param moduleName string
---@param searchPath string
---@return string? filename
---@return string? errorMessage
function package.searchpath(moduleName, searchPath)
    local resource, modulePath = getModuleInfo(moduleName:gsub("%.", "/"))
    local attemptedPaths = {}

    for pathTemplate in searchPath:gmatch("[^;]+") do
        local fileName = pathTemplate:gsub("%?", modulePath)
        local targetResource = GetCurrentResourceName()
        local fileContent = LoadResourceFile(targetResource, fileName)

        if fileContent then
            tempData[1] = fileContent
            tempData[2] = targetResource
            return fileName
        end

        table.insert(attemptedPaths, ("No file '@%s/%s'"):format(targetResource, fileName))
    end

    return nil, table.concat(attemptedPaths, "\n\t")
end

--- Load a module from a file
---@param moduleName string
---@param environment? table
---@return function|nil loaderFunction
---@return string? errorMessage
local function loadModule(moduleName, environment)
    local fileName, errorMessage = package.searchpath(moduleName, package.path)
    if fileName then
        local fileContent = tempData[1]
        local resource = tempData[2]
        tempData = {}
        return assert(load(fileContent, ("@@%s/%s"):format(resource, fileName), "t", environment or _ENV))
    end
    return nil, errorMessage
end

-- Custom package searchers
package.searchers = {
    function(moduleName)
        local success, result = pcall(originalRequire, moduleName)
        if success then return result end
        return nil, result
    end,
    function(moduleName)
        if package.preload[moduleName] then
            return package.preload[moduleName]
        end
        return nil, ("No field package.preload['%s']"):format(moduleName)
    end,
    function(moduleName)
        return loadModule(moduleName)
    end,
}

-- Override the global `require` function
---@param moduleName string
---@return any
_G.require = function(moduleName)
    if type(moduleName) ~= "string" then
        error(("Module name must be a string, got '%s'"):format(type(moduleName)), 2)
    end

    if loadedModules[moduleName] then
        return loadedModules[moduleName]
    end

    loadedModules[moduleName] = "__loading"

    local errors = {}
    for _, searcher in ipairs(package.searchers) do
        local result, errMsg = searcher(moduleName)
        if result then
            if type(result) == "function" then
                result = result()
            end
            loadedModules[moduleName] = result
            return result
        end
        table.insert(errors, errMsg)
    end

    loadedModules[moduleName] = nil
    error(("Cannot load module '%s'\n\t%s"):format(moduleName, table.concat(errors, "\n\t")), 2)
end

return require
