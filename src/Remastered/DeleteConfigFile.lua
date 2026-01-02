local KNOWN_DEFAULT = "Tempt-Config.json"

local function findConfigFilename()
    if type(_G) == "table" and _G.CONFIG_FILE then
        return tostring(_G.CONFIG_FILE)
    end

    local searchParents = {
        workspace,
        game:GetService("CoreGui"),
        game:GetService("ReplicatedStorage"),
        (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.PlayerGui)
    }

    for _, parent in ipairs(searchParents) do
        if parent then
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("ModuleScript") or obj:IsA("LocalScript") or obj:IsA("Script") then
                    local ok, src = pcall(function() return obj.Source end)
                    if ok and type(src) == "string" then
                        local cfg = src:match('CONFIG_FILE%s*=%s*[\"\']([^\"\']+)[\"\']')
                        if cfg and #cfg > 0 then
                            return cfg
                        end
                    end
                end
            end
        end
    end

    return KNOWN_DEFAULT
end

local function deleteConfigFile(path)
    local delCandidates = {delfile, deletefile, removefile}
    for _, fn in ipairs(delCandidates) do
        if type(fn) == "function" then
            local ok, res = pcall(fn, path)
            if ok then
                return true, "deleted via exploit delete function"
            end
        end
    end

    return false, "no supported api to del config file"
end

local cfg = findConfigFilename()
print("Detected config filename:", cfg)
local ok, msg = deleteConfigFile(cfg)
if ok then
    print("Success:", msg)
else
    print("Failed:", msg)
    print("update the del method if ur exec doesnt support it")
end
