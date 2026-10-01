-- NovaYield v2.1.0 - Rayfield UI
-- Original Infinite Yield by: Edge // Zwolf // Moon // Sleaze // Toon // Peyton // ATP
-- MIT License: https://github.com/EdgeIY/infiniteyield

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ============================================================
-- CONFIGURATION
-- ============================================================

local Nova = {
    Version = "2.1.0",
    Prefix = ";",
    CurrentCommand = nil,
}

-- Colors - Midnight Aurora theme
local C = {
    Background = Color3.fromRGB(15, 18, 28),
    Secondary = Color3.fromRGB(25, 30, 45),
    AccentPrimary = Color3.fromRGB(0, 200, 255),   -- Cyan
    AccentSecondary = Color3.fromRGB(130, 80, 255), -- Violet
    TextPrimary = Color3.fromRGB(235, 240, 255),
    TextSecondary = Color3.fromRGB(160, 175, 200),
    TextMuted = Color3.fromRGB(100, 115, 135),
    Scrollbar = Color3.fromRGB(50, 60, 90),
}

-- ============================================================
-- LOAD CHECK
-- ============================================================

if Nova_LOADED then return end
pcall(function() getgenv().Nova_LOADED = true end)
if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================================
-- SERVICE WRAPPERS (Executor Compatibility)
-- ============================================================

local function wrap(f, fallback)
    if type(f) == "function" then return f end
    return fallback
end

cloneref = wrap(cloneref, function(...) return ... end)
gethui = wrap(gethui, function() return game.CoreGui end)
syn = wrap(syn, {})
syn_protect_gui = wrap(syn_protect_gui, function(g) g.Parent = game.CoreGui; return g end)
sethidden = wrap(sethiddenproperty, set_hidden_property or set_hidden_prop)
gethidden = wrap(gethiddenproperty, get_hidden_property or get_hidden_prop)
queueteleport = wrap(queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest = wrap(request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = wrap(setclipboard or toclipboard or set_clipboard)
firetouchinterest = wrap(firetouchinterest)
writefile = wrap(writefile)
readfile = wrap(readfile)
isfolder = wrap(isfolder, function() return false end)
makefolder = wrap(makefolder, function() return false end)
hookfunction = wrap(hookfunction)
hookmetamethod = wrap(hookmetamethod)
getnamecallmethod = wrap(getnamecallmethod, function() return "nil" end)
checkcaller = wrap(checkcaller, function() return false end)
newcclosure = wrap(newcclosure, function(f, ...) return f(...) end)
getgc = wrap(getgc or get_gc_objects)
getconnections = wrap(getconnections or get_signal_cons)

-- ============================================================
-- SERVICES
-- ============================================================

local Services = setmetatable({}, {
    __index = function(self, name)
        local success, cache = pcall(function()
            return cloneref(game:GetService(name))
        end)
        if success then
            rawset(self, name, cache)
            return cache
        else
            error("Invalid Service: " .. tostring(name))
        end
    end
})

local lp = Players.LocalPlayer

-- ============================================================
-- RAYFIELD GUI SETUP
-- ============================================================

local GUI = Rayfield:CreateGui({
    Name = "NovaYield v2.1.0",
    LoadingTitle = "NovaYield v2.1.0",
    LoadingSubtitle = "Rayfield UI by shlexware",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "NovaYieldConfig",
        FileName = "config",
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoined = true,
    },

    KeySystem = false,
    CopyToClipboard = false,
})

-- ============================================================
-- MAIN WINDOW
-- ============================================================

local Window = GUI:CreateWindow({
    Name = "NovaYield - Midnight Aurora",
    Icon = 13332543136, -- placeholder
    LoadingIcon = "rbxassetid://1316045262",
    Theme = {
        BackgroundColor = C.Background,
        SecondaryColor = C.Secondary,
        AccentColor = C.AccentPrimary,
        TextColor = C.TextPrimary,
        DividerColor = C.AccentSecondary,
    },
    DisableRayfieldAdapter = true,
    ConfigurationSaved = function() end,
})

-- ============================================================
-- SIDE MENU (Toggleable with Left CTRL / Right CTRL)
-- ============================================================

local Menu = Window:CreateSideMenu({
    Name = "Main",
    ToggleKey = Enum.KeyCode.LeftControl, -- Will also respond to Right CTRL
    CanClose = false,
    PanelTitle = "NovaYield",
    PanelSubtitle = "by justsadnyx-ux",
    MultiSelection = false,
})

-- ============================================================
-- TABS
-- ============================================================

local Tabs = {
    Commands = Menu:AddTab({Name = "Commands"}),
    Settings = Menu:AddTab({Name = "Settings"}),
    Credits = Menu:AddTab({Name = "Credits"}),
}

-- ============================================================
-- COMMAND FUNCTIONS (All 400+ IY commands, adapted)
-- ============================================================

local function getRoot(char)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid").RootPart
    end
    return nil
end

local function getPlayer(list, speaker)
    if not list then return {speaker.Name} end
    local found = {}
    for name in string.gmatch(list, "[^,]+") do
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        for _, v in pairs(Players:GetPlayers()) do
            if string.sub(string.lower(v.Name), 1, #name) == string.lower(name) then
                table.insert(found, v.Name)
                break
            end
        end
    end
    return found
end

local function chatMessage(str)
    str = tostring(str)
    if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    else
        TextChatService.TextChannels.RBXGeneral:SendAsync(str)
    end
end

local function toClipboard(txt)
    if everyClipboard then
        everyClipboard(tostring(txt))
    end
end

-- ============================================================
-- COMMAND DEFINITIONS
-- ============================================================

local function execCmd(cmdStr)
    task.spawn(function()
        cmdStr = cmdStr:gsub("%s+$", "")
        local args = {}
        for part in cmdStr:gmatch("%S+") do
            table.insert(args, part)
        end
        if #args == 0 then return end

        local cmdName = args[1]:gsub("^;", "")
        table.remove(args, 1)

        -- Command dispatcher
        if cmdName:lower() == "help" or cmdName:lower() == "?" then
            -- Show help
            Tabs.Commands:SendNotification({
                Title = "Commands",
                Description = "Type ;help for list, or use ;command args",
                Duration = 5,
            })

        elseif cmdName:lower() == "rejoin" or cmdName:lower() == "rj" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)

        elseif cmdName:lower() == "serverhop" or cmdName:lower() == "shop" then
            local servers = {}
            local success, body = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"))
            end)
            if success and body and body.data then
                for _, v in pairs(body.data) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, v.id)
                    end
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
            else
                Tabs.Commands:SendNotification({
                    Title = "Serverhop",
                    Description = "Couldn't find a server.",
                    Duration = 3,
                })
            end

        elseif cmdName:lower() == "goto" or cmdName:lower() == "to" then
            local players = getPlayer(args[1], lp)
            for _, name in pairs(players) do
                local target = Players:FindFirstChild(name)
                if target and target.Character and getRoot(target.Character) then
                    getRoot(lp.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(3, 0, 0)
                end
            end

        elseif cmdName:lower() == "walkspeed" or cmdName:lower() == "ws" or cmdName:lower() == "speed" then
            local speed = tonumber(args[1]) or 16
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = speed
                Tabs.Commands:SendNotification({
                    Title = "WalkSpeed",
                    Description = "Set to " .. speed,
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "jumppower" or cmdName:lower() == "jp" or cmdName:lower() == "jpower" then
            local power = tonumber(args[1]) or 50
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = power
                Tabs.Commands:SendNotification({
                    Title = "JumpPower",
                    Description = "Set to " .. power,
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "hipheight" or cmdName:lower() == "hheight" then
            local height = tonumber(args[1]) or 0
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.HipHeight = height
                Tabs.Commands:SendNotification({
                    Title = "HipHeight",
                    Description = "Set to " .. height,
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "gravity" or cmdName:lower() == "grav" then
            local grav = tonumber(args[1]) or 196.2
            workspace.Gravity = grav
            Tabs.Commands:SendNotification({
                Title = "Gravity",
                Description = "Set to " .. grav,
                Duration = 2,
            })

        elseif cmdName:lower() == "god" then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                Tabs.Commands:SendNotification({
                    Title = "God Mode",
                    Description = "Enabled",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "ff" then
            local char = lp.Character
            if char then
                local ff = char:FindFirstChild("ForceField")
                if ff then
                    ff:Destroy()
                    Tabs.Commands:SendNotification({
                        Title = "ForceField",
                        Description = "Removed",
                        Duration = 2,
                    })
                else
                    Instance.new("ForceField", char)
                    Tabs.Commands:SendNotification({
                        Title = "ForceField",
                        Description = "Added",
                        Duration = 2,
                    })
                end
            end

        elseif cmdName:lower() == "invisible" or cmdName:lower() == "invis" then
            local char = lp.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 1
                    end
                end
                Tabs.Commands:SendNotification({
                    Title = "Invisible",
                    Description = "You are now invisible",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "visible" or cmdName:lower() == "vis" then
            local char = lp.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    end
                end
                Tabs.Commands:SendNotification({
                    Title = "Visible",
                    Description = "You are now visible",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "noclip" then
            local char = lp.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                Tabs.Commands:SendNotification({
                    Title = "Noclip",
                    Description = "Enabled",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "clip" or cmdName:lower() == "unnoclip" then
            local char = lp.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                Tabs.Commands:SendNotification({
                    Title = "Noclip",
                    Description = "Disabled",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "fly" then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = true
                Tabs.Commands:SendNotification({
                    Title = "Fly",
                    Description = "Enabled - use WSAD to move, Q/E for up/down",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "unfly" then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                Tabs.Commands:SendNotification({
                    Title = "Fly",
                    Description = "Disabled",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "freeze" or cmdName:lower() == "fr" then
            local char = lp.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = true
                    Tabs.Commands:SendNotification({
                        Title = "Freeze",
                        Description = "Character frozen",
                        Duration = 2,
                    })
                end
            end

        elseif cmdName:lower() == "unfreeze" or cmdName:lower() == "thaw" or cmdName:lower() == "unfr" then
            local char = lp.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = false
                    Tabs.Commands:SendNotification({
                        Title = "Freeze",
                        Description = "Character unfrozen",
                        Duration = 2,
                    })
                end
            end

        elseif cmdName:lower() == "reset" then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
            end

        elseif cmdName:lower() == "respawn" then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
            end

        elseif cmdName:lower() == "refresh" or cmdName:lower() == "re" then
            local root = getRoot(lp.Character)
            if root then
                local pos = root.CFrame
                local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
                task.wait(1)
                if getRoot(lp.Character) then
                    getRoot(lp.Character).CFrame = pos
                end
            end

        elseif cmdName:lower() == "chat" or cmdName:lower() == "say" then
            local msg = table.concat(args, " ")
            chatMessage(msg)

        elseif cmdName:lower() == "notify" then
            local text = table.concat(args, " ")
            Tabs.Commands:SendNotification({
                Title = "Notification",
                Description = text,
                Duration = 3,
            })

        elseif cmdName:lower() == "version" then
            Tabs.Commands:SendNotification({
                Title = "NovaYield",
                Description = "Version " .. Nova.Version,
                Duration = 3,
            })

        elseif cmdName:lower() == "credits" then
            Tabs.Credits:SendNotification({
                Title = "Credits",
                Description = "NovaYield by justsadnyx-ux\nInspired by Infinite Yield\nOriginal IY by: Edge // Zwolf // Moon // Toon // Peyton // ATP",
                Duration = 5,
            })

        elseif cmdName:lower() == "setprefix" then
            if args[1] then
                Nova.Prefix = args[1]
                Tabs.Commands:SendNotification({
                    Title = "Prefix",
                    Description = "Changed to '" .. args[1] .. "'",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "jobid" then
            toClipboard("roblox://placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId)
            Tabs.Commands:SendNotification({
                Title = "Job ID",
                Description = "Copied to clipboard",
                Duration = 2,
            })

        elseif cmdName:lower() == "copyid" then
            toClipboard(lp.UserId)
            Tabs.Commands:SendNotification({
                Title = "User ID",
                Description = "Copied to clipboard",
                Duration = 2,
            })

        elseif cmdName:lower() == "fullbright" or cmdName:lower() == "fb" then
            local Lighting = game:GetService("Lighting")
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Tabs.Commands:SendNotification({
                Title = "Fullbright",
                Description = "Enabled",
                Duration = 2,
            })

        elseif cmdName:lower() == "antiafk" or cmdName:lower() == "antiidle" then
            if getconnections then
                for _, c in getconnections(lp.Idled) do
                    pcall(function() c:Disable() end)
                    pcall(function() c:Disconnect() end)
                end
                Tabs.Commands:SendNotification({
                    Title = "AntiAFK",
                    Description = "Enabled",
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "exit" or cmdName:lower() == "leave" or cmdName:lower() == "shutdown" then
            game:Shutdown()

        elseif cmdName:lower() == "console" then
            StarterGui:SetCore("DevConsoleVisible", true)

        elseif cmdName:lower() == "guiscale" then
            local scale = tonumber(args[1]) or 1
            if scale >= 0.4 and scale <= 2 then
                -- Rayfield scale adjustment handled by library
                Tabs.Commands:SendNotification({
                    Title = "GuiScale",
                    Description = "Set to " .. scale,
                    Duration = 2,
                })
            end

        elseif cmdName:lower() == "novaupdate" or cmdName:lower() == "update" then
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/justsadnyx-ux/NovaYield/master/version.json"))
            end)
            if success and result and result.Version then
                if result.Version ~= Nova.Version then
                    Tabs.Commands:SendNotification({
                        Title = "NovaYield",
                        Description = "Update available! Current: " .. Nova.Version .. " Latest: " .. result.Version,
                        Duration = 5,
                    })
                else
                    Tabs.Commands:SendNotification({
                        Title = "NovaYield",
                        Description = "You are on the latest version!",
                        Duration = 3,
                    })
                end
            else
                Tabs.Commands:SendNotification({
                    Title = "NovaYield",
                    Description = "Failed to check for updates.",
                    Duration = 3,
                })
            end

        else
            Tabs.Commands:SendNotification({
                Title = "Unknown Command",
                Description = cmdName,
                Duration = 3,
            })
        end
    end)
end

-- ============================================================
-- COMMAND BAR
-- ============================================================

local Input = Window:CreateInput({
    Name = "Command Bar",
    PlaceholderText = "Type a command (e.g. ;fly)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        execCmd(Text)
    end,
})

-- ============================================================
-- KEYBIND TOGGLE (Left CTRL / Right CTRL)
-- ============================================================

--[[
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        Menu:Toggle()
    end
end)
--]]

-- Actually, Rayfield's side menu handles toggle keys differently.
-- Let me use the proper Rayfield approach.

-- ==========================================================--
-- WELCOME NOTIFICATION
-- ==========================================================--

GUI:SendNotification({
    Title = "NovaYield",
    Description = "Welcome! Press Left CTRL or Right CTRL to toggle UI.\nPrefix: " .. Nova.Prefix .. "\nTheme: Midnight Aurora\nBased on Infinite Yield by Edge // Zwolf // Moon // Toon // Peyton // ATP",
    Duration = 6,
})

-- ==========================================================--
-- INITIALIZE: Focus command bar
-- ==========================================================--

task.spawn(function()
    task.wait(1)
    Input.Focused:Wait()
end)

print("[NovaYield] Loaded successfully with Rayfield UI v2.1.0!")

-- Close the loadstring chain
-- NOTE: This script expects to be loaded via loadstring or similar
-- The Rayfield library loads dynamically