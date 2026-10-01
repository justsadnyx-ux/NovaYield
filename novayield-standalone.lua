--[[
    ============================================================
    NovaYield v1.1.0
    ============================================================
    
    A standalone Roblox command script with a custom UI.
    Inspired by Infinite Yield (https://github.com/EdgeIY/infiniteyield)
    Original IY by: Edge // Zwolf // Moon // Sleaze // Toon // Peyton // ATP
    Licensed under MIT
    
    Theme: Midnight Aurora
    ============================================================
]]

if NOVA_LOADED then return end
pcall(function() getgenv().NOVA_LOADED = true end)
if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================================
-- CONFIGURATION
-- ============================================================

local NOVA = {
    Name = "NovaYield",
    Version = "1.1.0",
    Prefix = ";",
    
    Colors = {
        BgDarkest  = Color3.fromRGB(12, 14, 20),
        BgDark     = Color3.fromRGB(18, 21, 32),
        BgMedium   = Color3.fromRGB(28, 32, 48),
        BgLight    = Color3.fromRGB(42, 48, 72),
        BgLightest = Color3.fromRGB(58, 66, 96),
        AccentPrimary   = Color3.fromRGB(0, 200, 255),
        AccentSecondary = Color3.fromRGB(130, 80, 255),
        TextPrimary   = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(160, 170, 200),
        TextMuted     = Color3.fromRGB(100, 110, 140),
        TextOnAccent  = Color3.fromRGB(10, 12, 18),
        Scrollbar = Color3.fromRGB(50, 58, 88),
    },
}

local C = NOVA.Colors

-- ============================================================
-- EXECUTOR COMPATIBILITY
-- ============================================================

local function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
gethui = missing("function", gethui or get_hidden_gui)
syn = missing("table", syn)
syn_protect_gui = missing("function", syn and syn.protect_gui)
sethidden = missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden = missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport = missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest = missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
writefile = missing("function", writefile)
readfile = missing("function", readfile)
isfile = missing("function", isfile)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f, ...) return f(...) end)
getgc = missing("function", getgc or get_gc_objects)
getconnections = missing("function", getconnections or get_signal_cons)

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

local Players = Services.Players
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local RunService = Services.RunService
local StarterGui = Services.StarterGui
local Lighting = Services.Lighting
local TeleportService = Services.TeleportService
local ReplicatedStorage = Services.ReplicatedStorage
local TextChatService = Services.TextChatService

local PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
local COREGUI = Services.CoreGui or PlayerGui
local IYMouse = cloneref(Players.LocalPlayer:GetMouse())
local PlaceId, JobId = game.PlaceId, game.JobId

-- ============================================================
-- UI CONSTRUCTION
-- ============================================================

local function randomString()
    local length = math.random(10, 20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

-- Parent GUI
local PARENT = nil
if gethui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.Parent = gethui()
    PARENT = Main
elseif syn_protect_gui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    syn_protect_gui(Main)
    Main.Parent = COREGUI
    PARENT = Main
else
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.Parent = COREGUI
    PARENT = Main
end

-- ScaledHolder
local ScaledHolder = Instance.new("Frame")
ScaledHolder.Name = randomString()
ScaledHolder.Size = UDim2.fromScale(1, 1)
ScaledHolder.BackgroundTransparency = 1
ScaledHolder.Parent = PARENT

local Scale = Instance.new("UIScale")
Scale.Name = randomString()
Scale.Parent = ScaledHolder

-- Main Holder
local Holder = Instance.new("Frame")
Holder.Name = "NovaYield"
Holder.Parent = ScaledHolder
Holder.Active = true
Holder.BackgroundColor3 = C.BgDarkest
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(1, -290, 1, -270)
Holder.Size = UDim2.new(0, 280, 0, 260)
Holder.ZIndex = 10

-- Accent lines
local TopAccent = Instance.new("Frame")
TopAccent.Name = "TopAccent"
TopAccent.Parent = Holder
TopAccent.BackgroundColor3 = C.AccentPrimary
TopAccent.BorderSizePixel = 0
TopAccent.Position = UDim2.new(0, 0, 0, 0)
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.ZIndex = 11

local BottomAccent = Instance.new("Frame")
BottomAccent.Name = "BottomAccent"
BottomAccent.Parent = Holder
BottomAccent.BackgroundColor3 = C.AccentSecondary
BottomAccent.BorderSizePixel = 0
BottomAccent.Position = UDim2.new(0, 0, 1, -2)
BottomAccent.Size = UDim2.new(1, 0, 0, 2)
BottomAccent.ZIndex = 11

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Holder
Title.Active = true
Title.BackgroundColor3 = C.BgDark
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 24)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Text = "  " .. NOVA.Name .. " v" .. NOVA.Version
Title.TextColor3 = C.TextPrimary
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 10

-- Command Bar
local Cmdbar = Instance.new("TextBox")
Cmdbar.Name = "Cmdbar"
Cmdbar.Parent = Holder
Cmdbar.BackgroundColor3 = C.BgLight
Cmdbar.BorderSizePixel = 0
Cmdbar.Position = UDim2.new(0, 8, 0, 30)
Cmdbar.Size = UDim2.new(1, -16, 0, 28)
Cmdbar.Font = Enum.Font.Gotham
Cmdbar.TextSize = 14
Cmdbar.Text = ""
Cmdbar.TextColor3 = C.TextPrimary
Cmdbar.PlaceholderText = "Command Bar (" .. NOVA.Prefix .. ")"
Cmdbar.PlaceholderColor3 = C.TextMuted
Cmdbar.TextXAlignment = Enum.TextXAlignment.Left
Cmdbar.ZIndex = 10
Cmdbar.ClearTextOnFocus = false

local CmdbarPadding = Instance.new("UIPadding")
CmdbarPadding.Parent = Cmdbar
CmdbarPadding.PaddingLeft = UDim.new(0, 8)

-- Command List
local CMDsF = Instance.new("ScrollingFrame")
CMDsF.Name = "CMDs"
CMDsF.Parent = Holder
CMDsF.BackgroundTransparency = 1
CMDsF.BorderSizePixel = 0
CMDsF.Position = UDim2.new(0, 8, 0, 64)
CMDsF.Size = UDim2.new(1, -16, 1, -70)
CMDsF.ScrollBarImageColor3 = C.Scrollbar
CMDsF.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.CanvasSize = UDim2.new(0, 0, 0, 0)
CMDsF.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.ScrollBarThickness = 4
CMDsF.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.VerticalScrollBarInset = Enum.ScrollBarInset.Always
CMDsF.ZIndex = 10

local cmdListLayout = Instance.new("UIListLayout")
cmdListLayout.Parent = CMDsF
cmdListLayout.Padding = UDim.new(0, 2)
cmdListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Settings Button
local SettingsButton = Instance.new("TextButton")
SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = Holder
SettingsButton.BackgroundColor3 = C.BgMedium
SettingsButton.BorderSizePixel = 0
SettingsButton.Position = UDim2.new(1, -30, 0, 2)
SettingsButton.Size = UDim2.new(0, 24, 0, 20)
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.TextSize = 12
SettingsButton.Text = "S"
SettingsButton.TextColor3 = C.TextPrimary
SettingsButton.ZIndex = 10

-- Settings Panel
local Settings = Instance.new("Frame")
Settings.Name = "Settings"
Settings.Parent = Holder
Settings.Active = true
Settings.BackgroundColor3 = C.BgDark
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(0, 0, 0, 260)
Settings.Size = UDim2.new(0, 280, 0, 200)
Settings.ZIndex = 10

local SettingsAccent = Instance.new("Frame")
SettingsAccent.Name = "SettingsAccent"
SettingsAccent.Parent = Settings
SettingsAccent.BackgroundColor3 = C.AccentSecondary
SettingsAccent.BorderSizePixel = 0
SettingsAccent.Position = UDim2.new(0, 0, 0, 0)
SettingsAccent.Size = UDim2.new(1, 0, 0, 1)
SettingsAccent.ZIndex = 11

-- Notification
local Notification = Instance.new("Frame")
Notification.Name = randomString()
Notification.Parent = ScaledHolder
Notification.BackgroundColor3 = C.BgDark
Notification.BorderSizePixel = 0
Notification.Position = UDim2.new(1, -280, 1, 20)
Notification.Size = UDim2.new(0, 260, 0, 90)
Notification.ZIndex = 10
Notification.Visible = false

local NotifAccent = Instance.new("Frame")
NotifAccent.Name = "Accent"
NotifAccent.Parent = Notification
NotifAccent.BackgroundColor3 = C.AccentPrimary
NotifAccent.BorderSizePixel = 0
NotifAccent.Position = UDim2.new(0, 0, 0, 0)
NotifAccent.Size = UDim2.new(0, 3, 0, 1)
NotifAccent.ZIndex = 11

local NotifTitle = Instance.new("TextLabel")
NotifTitle.Name = "Title"
NotifTitle.Parent = Notification
NotifTitle.BackgroundColor3 = C.BgMedium
NotifTitle.BorderSizePixel = 0
NotifTitle.Size = UDim2.new(1, 0, 0, 22)
NotifTitle.Font = Enum.Font.GothamBold
NotifTitle.TextSize = 13
NotifTitle.Text = "Notification"
NotifTitle.TextColor3 = C.TextPrimary
NotifTitle.ZIndex = 10
NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

local NotifTitlePadding = Instance.new("UIPadding")
NotifTitlePadding.Parent = NotifTitle
NotifTitlePadding.PaddingLeft = UDim.new(0, 10)

local NotifText = Instance.new("TextLabel")
NotifText.Name = "Text"
NotifText.Parent = Notification
NotifText.BackgroundTransparency = 1
NotifText.BorderSizePixel = 0
NotifText.Position = UDim2.new(0, 10, 0, 26)
NotifText.Size = UDim2.new(1, -20, 0, 58)
NotifText.Font = Enum.Font.Gotham
NotifText.TextSize = 13
NotifText.Text = ""
NotifText.TextColor3 = C.TextSecondary
NotifText.TextWrapped = true
NotifText.ZIndex = 10
NotifText.TextXAlignment = Enum.TextXAlignment.Left
NotifText.TextYAlignment = Enum.TextYAlignment.Top

local NotifClose = Instance.new("TextButton")
NotifClose.Name = "CloseButton"
NotifClose.Parent = Notification
NotifClose.BackgroundTransparency = 1
NotifClose.Position = UDim2.new(1, -24, 0, 2)
NotifClose.Size = UDim2.new(0, 20, 0, 20)
NotifClose.Font = Enum.Font.GothamBold
NotifClose.TextSize = 14
NotifClose.Text = "X"
NotifClose.TextColor3 = C.TextPrimary
NotifClose.ZIndex = 10

-- ============================================================
-- DRAG SYSTEM
-- ============================================================

local dragging = false
local dragStart = Vector2.new()
local startPos = UDim2.new()

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Holder.Position
    end
end)

Title.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================

local notifyCount = 0

local function notify(text, text2, length)
    task.spawn(function()
        local LnotifyCount = notifyCount + 1
        notifyCount = notifyCount + 1
        
        Notification.Visible = true
        if text2 then
            NotifTitle.Text = text
            NotifText.Text = text2
        else
            NotifTitle.Text = "Notification"
            NotifText.Text = text
        end
        
        Notification.Position = UDim2.new(1, -280, 1, 20)
        Notification:TweenPosition(UDim2.new(1, -280, 1, -110), "InOut", "Quart", 0.3, true)
        
        NotifClose.MouseButton1Click:Connect(function()
            Notification:TweenPosition(UDim2.new(1, -280, 1, 20), "InOut", "Quart", 0.3, true)
            task.wait(0.35)
            Notification.Visible = false
        end)
        
        task.wait(length or 4)
        
        if LnotifyCount == notifyCount then
            Notification:TweenPosition(UDim2.new(1, -280, 1, 20), "InOut", "Quart", 0.3, true)
            task.wait(0.35)
            Notification.Visible = false
            notifyCount = 0
        end
    end)
end

-- ============================================================
-- COMMAND SYSTEM
-- ============================================================

local cmds = {}
local customAlias = {}
local prefix = NOVA.Prefix
local SettingsOpen = false

local function addcmd(name, alias, func)
    cmds[#cmds + 1] = {
        NAME = name,
        ALIAS = alias or {},
        FUNC = func,
    }
end

local function findCmd(cmd_name)
    for i, v in pairs(cmds) do
        if v.NAME:lower() == cmd_name:lower() then
            return v
        end
        for _, a in pairs(v.ALIAS) do
            if a:lower() == cmd_name:lower() then
                return v
            end
        end
    end
    return customAlias[cmd_name:lower()]
end

local function execCmd(cmdStr)
    cmdStr = cmdStr:gsub("%s+$", "")
    task.spawn(function()
        local args = {}
        for part in cmdStr:gmatch("%S+") do
            table.insert(args, part)
        end
        
        if #args == 0 then return end
        
        local cmdName = args[1]:gsub("^" .. prefix, "")
        table.remove(args, 1)
        
        local cmd = findCmd(cmdName)
        if cmd then
            local success, err = pcall(cmd.FUNC, args, Players.LocalPlayer)
            if not success then
                notify("Error", tostring(err), 3)
            end
        else
            notify("Unknown Command", cmdName, 3)
        end
    end)
end

-- ============================================================
-- HELPER FUNCTIONS
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

local function toClipboard(txt)
    if everyClipboard then
        everyClipboard(tostring(txt))
        notify("Clipboard", "Copied to clipboard")
    else
        notify("Clipboard", "Your exploit doesn't support clipboard")
    end
end

local function chatMessage(str)
    str = tostring(str)
    if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    else
        TextChatService.TextChannels.RBXGeneral:SendAsync(str)
    end
end

-- ============================================================
-- COMMANDS
-- ============================================================

addcmd("help", {}, function(args, speaker)
    notify("NovaYield", "Type " .. prefix .. " in the command bar. Click a command to auto-fill.", 4)
end)

addcmd("rejoin", {"rj"}, function(args, speaker)
    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
    notify("NovaYield", "Server hopping...")
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = HttpService:JSONDecode(req)
    if body and body.data then
        for _, v in pairs(body.data) do
            if v.playing < v.maxPlayers and v.id ~= JobId then
                table.insert(servers, v.id)
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
    else
        notify("Serverhop", "Couldn't find a server.")
    end
end)

addcmd("goto", {"to"}, function(args, speaker)
    local players = getPlayer(args[1], speaker)
    for _, name in pairs(players) do
        local target = Players:FindFirstChild(name)
        if target and target.Character and getRoot(target.Character) then
            getRoot(speaker.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(3, 0, 0)
        end
    end
end)

addcmd("walkspeed", {"ws", "speed"}, function(args, speaker)
    local speed = tonumber(args[1]) or 16
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speed
        notify("WalkSpeed", "Set to " .. speed)
    end
end)

addcmd("jumppower", {"jp", "jpower"}, function(args, speaker)
    local power = tonumber(args[1]) or 50
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.UseJumpPower then
            hum.JumpPower = power
        else
            hum.JumpHeight = power
        end
        notify("JumpPower", "Set to " .. power)
    end
end)

addcmd("hipheight", {"hheight"}, function(args, speaker)
    local height = tonumber(args[1]) or 0
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.HipHeight = height
        notify("HipHeight", "Set to " .. height)
    end
end)

addcmd("gravity", {"grav"}, function(args, speaker)
    local grav = tonumber(args[1]) or 196.2
    workspace.Gravity = grav
    notify("Gravity", "Set to " .. grav)
end)

addcmd("god", {}, function(args, speaker)
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        notify("God Mode", "Enabled")
    end
end)

addcmd("ff", {}, function(args, speaker)
    local char = speaker.Character
    if char then
        local ff = char:FindFirstChild("ForceField")
        if ff then
            ff:Destroy()
            notify("ForceField", "Removed")
        else
            Instance.new("ForceField", char)
            notify("ForceField", "Added")
        end
    end
end)

addcmd("invisible", {"invis"}, function(args, speaker)
    local char = speaker.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
        notify("Invisible", "You are now invisible")
    end
end)

addcmd("visible", {"vis"}, function(args, speaker)
    local char = speaker.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        notify("Visible", "You are now visible")
    end
end)

addcmd("noclip", {}, function(args, speaker)
    local char = speaker.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        notify("Noclip", "Enabled")
    end
end)

addcmd("clip", {"unnoclip"}, function(args, speaker)
    local char = speaker.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        notify("Noclip", "Disabled")
    end
end)

addcmd("fly", {}, function(args, speaker)
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        notify("Fly", "Enabled - use WSAD to move, Q/E for up/down")
    end
end)

addcmd("unfly", {}, function(args, speaker)
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        notify("Fly", "Disabled")
    end
end)

addcmd("freeze", {"fr"}, function(args, speaker)
    local char = speaker.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = true
            notify("Freeze", "Character frozen")
        end
    end
end)

addcmd("unfreeze", {"thaw", "unfr"}, function(args, speaker)
    local char = speaker.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
            notify("Freeze", "Character unfrozen")
        end
    end
end)

addcmd("reset", {}, function(args, speaker)
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
    end
end)

addcmd("respawn", {}, function(args, speaker)
    local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
    end
end)

addcmd("refresh", {"re"}, function(args, speaker)
    local root = getRoot(speaker.Character)
    if root then
        local pos = root.CFrame
        local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        task.wait(1)
        if getRoot(speaker.Character) then
            getRoot(speaker.Character).CFrame = pos
        end
    end
end)

addcmd("chat", {"say"}, function(args, speaker)
    local msg = table.concat(args, " ")
    chatMessage(msg)
end)

addcmd("notify", {}, function(args, speaker)
    notify("Notification", table.concat(args, " "))
end)

addcmd("version", {}, function(args, speaker)
    notify(NOVA.Name, "Version " .. NOVA.Version .. "\nTheme: Midnight Aurora", 4)
end)

addcmd("credits", {}, function(args, speaker)
    notify("Credits", "NovaYield by justsadnyx-ux\nInspired by Infinite Yield\nOriginal IY by: Edge // Zwolf // Moon // Toon // Peyton // ATP", 5)
end)

addcmd("setprefix", {}, function(args, speaker)
    if args[1] then
        prefix = args[1]
        notify("Prefix", "Changed to '" .. args[1] .. "'")
    end
end)

addcmd("jobid", {}, function(args, speaker)
    toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd("copyid", {}, function(args, speaker)
    toClipboard(speaker.UserId)
end)

addcmd("fullbright", {"fb"}, function(args, speaker)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    notify("Fullbright", "Enabled")
end)

addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, c in getconnections(speaker.Idled) do
            pcall(function() c:Disable() end)
            pcall(function() c:Disconnect() end)
        end
        notify("AntiAFK", "Enabled")
    end
end)

addcmd("exit", {"leave", "shutdown"}, function(args, speaker)
    game:Shutdown()
end)

addcmd("console", {}, function(args, speaker)
    StarterGui:SetCore("DevConsoleVisible", true)
end)

addcmd("guiscale", {}, function(args, speaker)
    local scale = tonumber(args[1]) or 1
    if scale >= 0.4 and scale <= 2 then
        Scale.Scale = scale
        notify("GuiScale", "Set to " .. scale)
    end
end)

addcmd("novaupdate", {"update"}, function(args, speaker)
    notify("NovaYield", "Checking for updates...", 2)
    local success, result = pcall(function()
        local versionJson = game:HttpGet("https://raw.githubusercontent.com/justsadnyx-ux/NovaYield/master/version.json")
        return HttpService:JSONDecode(versionJson)
    end)
    if success and result and result.Version then
        if result.Version ~= NOVA.Version then
            notify("NovaYield", "Update available! Current: " .. NOVA.Version .. " Latest: " .. result.Version, 5)
        else
            notify("NovaYield", "You are on the latest version!", 3)
        end
    else
        notify("NovaYield", "Failed to check for updates.", 3)
    end
end)

-- ============================================================
-- COMMAND LIST UI
-- ============================================================

local function createCommandButtons()
    for i, cmd in pairs(cmds) do
        local btn = Instance.new("TextButton")
        btn.Name = "CMD"
        btn.Parent = CMDsF
        btn.BackgroundColor3 = C.BgMedium
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Text = "  " .. prefix .. cmd.NAME
        btn.TextColor3 = C.TextPrimary
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 10
        btn.Visible = false
        btn.LayoutOrder = i
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = C.BgLightest
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = C.BgMedium
        end)
        
        btn.MouseButton1Click:Connect(function()
            Cmdbar.Text = prefix .. cmd.NAME
            Cmdbar:CaptureFocus()
        end)
    end
end

createCommandButtons()

-- ============================================================
-- COMMAND BAR LOGIC
-- ============================================================

local function updateCommandList(filter)
    filter = filter or ""
    filter = filter:lower()
    
    for _, child in pairs(CMDsF:GetChildren()) do
        if child:IsA("TextButton") then
            if filter == "" then
                child.Visible = true
            else
                local cmdName = child.Text:lower()
                if string.find(cmdName, filter) then
                    child.Visible = true
                else
                    child.Visible = false
                end
            end
        end
    end
    
    local visibleCount = 0
    for _, child in pairs(CMDsF:GetChildren()) do
        if child:IsA("TextButton") and child.Visible then
            visibleCount = visibleCount + 1
        end
    end
    CMDsF.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 26)
end

Cmdbar.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = Cmdbar.Text:gsub("^" .. prefix, "")
        execCmd(text)
        Cmdbar.Text = ""
        updateCommandList("")
    end
end)

Cmdbar:GetPropertyChangedSignal("Text"):Connect(function()
    if Cmdbar:IsFocused() then
        local text = Cmdbar.Text:gsub("^" .. prefix, "")
        updateCommandList(text)
    end
end)

-- ============================================================
-- SETTINGS TOGGLE
-- ============================================================

SettingsButton.MouseButton1Click:Connect(function()
    SettingsOpen = not SettingsOpen
    if SettingsOpen then
        Settings:TweenPosition(UDim2.new(0, 0, 0, 260), "InOut", "Quart", 0.25, true)
        CMDsF.Visible = false
    else
        CMDsF.Visible = true
        Settings:TweenPosition(UDim2.new(0, 0, 0, 260), "InOut", "Quart", 0.25, true)
    end
end)

-- ============================================================
-- KEYBIND TOGGLE
-- ============================================================

local uiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        Holder.Visible = uiVisible
    end
end)

-- ============================================================
-- AUTO-UPDATE SYSTEM
-- ============================================================

local function checkForUpdate()
    local success, result = pcall(function()
        local versionJson = game:HttpGet("https://raw.githubusercontent.com/justsadnyx-ux/NovaYield/master/version.json")
        return HttpService:JSONDecode(versionJson)
    end)
    
    if success and result and result.Version then
        if result.Version ~= NOVA.Version then
            notify("NovaYield", "Update available! Current: " .. NOVA.Version .. " Latest: " .. result.Version .. "\nRun " .. prefix .. "novaupdate to update.", 6)
        end
    end
end

task.spawn(function()
    task.wait(3)
    checkForUpdate()
end)

-- ============================================================
-- WELCOME
-- ============================================================

task.spawn(function()
    task.wait(1)
    notify(NOVA.Name, "Welcome! Press Right Shift to toggle.\nPrefix: " .. prefix, 4)
end)

print("[" .. NOVA.Name .. "] Loaded successfully!")
