-- ═══════════════════════════════════════════════════════════════════════════════
-- ARVR-Quest 风格 UI 库 v14 - 双面板重构版 (手势切换+隐藏UI+🍎浮动按钮)
-- 作者: tubers93
-- 重构: 左面板=标签页列表 | 右面板=内容区 | 顶部=调试控制栏
-- 新增: 🔀 合并/拆分 | 👁️ 固定/跟随 | 🖐️ 手势开关 | 🍎 隐藏UI浮动按钮
-- ═══════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════════════
-- 工具函数
-- ═══════════════════════════════════════════════════════════════════════════════
local function Create(className, properties, parent)
    local object = Instance.new(className)
    if properties then
        for propertyName, propertyValue in pairs(properties) do
            local success, errorMessage = pcall(function()
                object[propertyName] = propertyValue
            end)
            if not success then
                warn("[ARVR UI] 设置属性失败: " .. tostring(propertyName) .. " - " .. tostring(errorMessage))
            end
        end
    end
    if parent then
        object.Parent = parent
    end
    return object
end

local function PlayTween(object, duration, properties, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function IsFirstPerson()
    local character = LocalPlayer.Character
    if not character then return false end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    local distance = (Camera.CFrame.Position - head.Position).Magnitude
    return distance < 2.5
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 触摸防误触 + CanvasSize 自动更新 辅助函数
-- ═══════════════════════════════════════════════════════════════════════════════
local function SetupAutoCanvas(scrollingFrame, padding)
    local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout") or scrollingFrame:FindFirstChildOfClass("UIGridLayout")
    if layout then
        local function update()
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (padding or 20))
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
        task.delay(0.1, update)
    end
end

local function SetupTouchProtection(element, onClick)
    local isDragging = false
    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            local startPos = Vector2.new(input.Position.X, input.Position.Y)
            local conn, endConn
            conn = UserInputService.InputChanged:Connect(function(changed)
                if changed == input then
                    local currentPos = Vector2.new(changed.Position.X, changed.Position.Y)
                    if (currentPos - startPos).Magnitude > 12 then
                        isDragging = true
                    end
                end
            end)
            endConn = UserInputService.InputEnded:Connect(function(ended)
                if ended == input then
                    pcall(function() conn:Disconnect() end)
                    pcall(function() endConn:Disconnect() end)
                end
            end)
        end
    end)
    element.MouseButton1Click:Connect(function()
        if isDragging then
            isDragging = false
            return
        end
        onClick()
    end)
end

local function SetupFrameTouchProtection(frame, onClick)
    local isDragging = false
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            local startPos = Vector2.new(input.Position.X, input.Position.Y)
            local conn, endConn
            conn = UserInputService.InputChanged:Connect(function(changed)
                if changed == input then
                    local currentPos = Vector2.new(changed.Position.X, changed.Position.Y)
                    if (currentPos - startPos).Magnitude > 12 then
                        isDragging = true
                    end
                end
            end)
            endConn = UserInputService.InputEnded:Connect(function(ended)
                if ended == input then
                    pcall(function() conn:Disconnect() end)
                    pcall(function() endConn:Disconnect() end)
                    if not isDragging then
                        onClick()
                    end
                    isDragging = false
                end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 颜色主题配置
-- ═══════════════════════════════════════════════════════════════════════════════
local Theme = {
    Background = Color3.fromRGB(10, 10, 16),
    BackgroundTransparent = Color3.fromRGB(22, 22, 32),
    Accent = Color3.fromRGB(120, 180, 255),
    AccentGlow = Color3.fromRGB(200, 220, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 170, 190),
    Success = Color3.fromRGB(100, 255, 150),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 200, 80),
    Info = Color3.fromRGB(120, 180, 255),
    Stroke = Color3.fromRGB(50, 60, 80),
    Glass = Color3.fromRGB(255, 255, 255),
    PanelBack = Color3.fromRGB(8, 12, 30),
    ControlBar = Color3.fromRGB(15, 18, 28),
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 启动动画系统 - Vision Pro 3D空间部署效果
-- ═══════════════════════════════════════════════════════════════════════════════
local StartupAnimation = {}

function StartupAnimation:Play(parentGui, onComplete)
    local animationFolder = Create("Folder", {Name = "ARVR_StartupAnimation"}, parentGui)

    local character = LocalPlayer.Character
    if not character then
        if onComplete then onComplete() end
        return
    end
    local head = character:WaitForChild("Head")

    local anchorPart = Create("Part", {
        Name = "DeployAnchor",
        Size = Vector3.new(0.1, 0.1, 0.1),
        Anchored = true,
        CanCollide = false,
        Transparency = 1,
    }, workspace)

    local billboard = Create("BillboardGui", {
        Name = "VisionPro_DeployBillboard",
        Adornee = anchorPart,
        Size = UDim2.new(0, 250, 0, 60),
        AlwaysOnTop = true,
        MaxDistance = 100,
        LightInfluence = 0,
    }, PlayerGui)

    local deployText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0.5, 0, 0.5, -8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "APPLE vision pro",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextTransparency = 1,
        TextStrokeColor3 = Color3.fromRGB(150, 210, 255),
        TextStrokeTransparency = 0.8,
    }, billboard)

    local subText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "正在部署...",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextTransparency = 1,
        TextStrokeColor3 = Color3.fromRGB(150, 210, 255),
        TextStrokeTransparency = 0.85,
    }, billboard)

    local particles = {}
    local particleCount = 80
    local rectHalfW = 3.0
    local rectHalfH = 2.0
    local rectDepth = 0.15

    for i = 1, particleCount do
        local p = Create("Part", {
            Name = "DeployParticle_" .. i,
            Size = Vector3.new(0.04, 0.04, 0.04),
            Anchored = true,
            CanCollide = false,
            Transparency = 1,
            Color = Color3.fromRGB(
                180 + math.random(75),
                210 + math.random(45),
                255
            ),
            Material = Enum.Material.Neon,
        }, workspace)

        Create("SpecialMesh", {
            MeshType = Enum.MeshType.Sphere,
            Scale = Vector3.new(1, 1, 1),
        }, p)

        local offsetX, offsetY, offsetZ
        local edgeBias = math.random()

        if edgeBias > 0.55 then
            local side = math.random(1, 4)
            local t = math.random() * 2 - 1
            if side == 1 then
                offsetX = t * rectHalfW
                offsetY = rectHalfH + (math.random() - 0.5) * 0.15
            elseif side == 2 then
                offsetX = t * rectHalfW
                offsetY = -rectHalfH + (math.random() - 0.5) * 0.15
            elseif side == 3 then
                offsetX = -rectHalfW + (math.random() - 0.5) * 0.15
                offsetY = t * rectHalfH
            else
                offsetX = rectHalfW + (math.random() - 0.5) * 0.15
                offsetY = t * rectHalfH
            end
        else
            offsetX = (math.random() * 2 - 1) * rectHalfW * 0.88
            offsetY = (math.random() * 2 - 1) * rectHalfH * 0.88
        end
        offsetZ = (math.random() - 0.5) * rectDepth

        table.insert(particles, {
            object = p,
            relPos = Vector3.new(0, 0, 0),
            targetU = offsetX,
            targetV = offsetY,
            targetZ = offsetZ,
            phase = "idle",
            speed = 2.0 + math.random() * 2.5,
            delay = math.random() * 0.5,
            size = 0.03 + math.random() * 0.04,
        })
    end

    local posConnection = RunService.RenderStepped:Connect(function(dt)
        local headCF = head.CFrame
        local distance = IsFirstPerson() and 2.0 or 3.5
        local centerPos = headCF.Position + headCF.LookVector * distance + headCF.UpVector * 0.5

        anchorPart.CFrame = CFrame.new(centerPos)

        for _, pData in ipairs(particles) do
            if pData.phase == "idle" then
                pData.object.CFrame = CFrame.new(centerPos)
            elseif pData.phase == "scatter" then
                local targetOffset = headCF.RightVector * pData.targetU + headCF.UpVector * pData.targetV + headCF.LookVector * pData.targetZ
                pData.relPos = pData.relPos:Lerp(targetOffset, dt * pData.speed)
                pData.object.CFrame = CFrame.new(centerPos + pData.relPos)
            elseif pData.phase == "gather" then
                pData.relPos = pData.relPos:Lerp(Vector3.new(0, 0, 0), dt * pData.speed * 1.5)
                pData.object.CFrame = CFrame.new(centerPos + pData.relPos)
            elseif pData.phase == "collapse" then
                pData.object.CFrame = CFrame.new(centerPos)
                pData.object.Size = pData.object.Size:Lerp(Vector3.new(0.01, 0.01, 0.01), dt * 8)
            end
        end
    end)

    task.delay(0.1, function()
        PlayTween(deployText, 0.6, {TextTransparency = 0})
    end)

    task.delay(0.4, function()
        PlayTween(subText, 0.5, {TextTransparency = 0})
    end)

    task.delay(0.6, function()
        for _, pData in ipairs(particles) do
            task.delay(pData.delay, function()
                pData.phase = "scatter"
                pData.object.Transparency = 0.05
                pData.object.Size = Vector3.new(pData.size, pData.size, pData.size)
            end)
        end
    end)

    task.delay(2.5, function()
        deployText.Text = "部署完成"
        subText.Text = "系统启动中"
        for _, pData in ipairs(particles) do
            pData.phase = "gather"
        end
    end)

    task.delay(3.5, function()
        for _, pData in ipairs(particles) do
            pData.phase = "collapse"
            pData.object.Transparency = 1
        end
        PlayTween(deployText, 0.3, {TextTransparency = 1})
        PlayTween(subText, 0.3, {TextTransparency = 1})
    end)

    task.delay(4.0, function()
        if posConnection then
            posConnection:Disconnect()
            posConnection = nil
        end
        pcall(function() billboard:Destroy() end)
        pcall(function() anchorPart:Destroy() end)
        for _, pData in ipairs(particles) do
            pcall(function() pData.object:Destroy() end)
        end
        pcall(function() animationFolder:Destroy() end)

        if onComplete then
            onComplete()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 核心 ARVR 双面板 UI 类
-- ═══════════════════════════════════════════════════════════════════════════════
local ARVR_UI = {}
ARVR_UI.__index = ARVR_UI

-- 全局状态
ARVR_UI.Scale = 1.0
ARVR_UI.Direction = 1  -- 1 = 正常, -1 = 翻转
ARVR_UI.IsVisible = true

function ARVR_UI.new(title)
    local self = setmetatable({}, ARVR_UI)
    self.Title = title or "ARVR UI"
    self.Tabs = {}
    self.TabList = {}
    self.CurrentTab = nil
    self.IsFirstPerson = false
    self.PositionConnection = nil
    self.IsMerged = false      -- 合并状态
    self.IsFixed = false       -- 固定状态
    self.Connections = {}      -- 存储额外连接
    self.UseGesture = false    -- 手势默认关闭
    self.IKTarget = nil        -- IK目标零件
    self.IKControl = nil       -- IK控制器
    self.IsHidden = false      -- UI是否隐藏
    self.AppleButton = nil     -- 🍎浮动按钮
    self.AppleGui = nil        -- 🍎浮动按钮Gui
    self.AppleConnections = {} -- 🍎按钮的连接

    -- ═══════════════════════════════════════════════════════════════════════════════
    -- 左面板: 标签页列表 + 顶部控制栏
    -- ═══════════════════════════════════════════════════════════════════════════════
    self.LeftPanelPart = Create("Part", {
        Name = "ARVR_LeftPanel",
        Size = Vector3.new(2.2, 3.5, 0.05),
        Anchored = true,
        CanCollide = true,
        Transparency = 0.3,
        Color = Theme.PanelBack,
        Material = Enum.Material.SmoothPlastic,
    }, workspace)

    self.LeftSurfaceGui = Create("SurfaceGui", {
        Name = "ARVR_LeftSurfaceGui",
        Parent = self.LeftPanelPart,
        Face = Enum.NormalId.Front,
        SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
        CanvasSize = Vector2.new(440, 700),
        PixelsPerStud = 200,
        AlwaysOnTop = true,
        ResetOnSpawn = false,
    }, self.LeftPanelPart)

    -- 左面板背面: APPLE vision pro 🍎
    self.LeftBackSurfaceGui = Create("SurfaceGui", {
        Name = "ARVR_LeftBackSurfaceGui",
        Parent = self.LeftPanelPart,
        Face = Enum.NormalId.Back,
        SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
        CanvasSize = Vector2.new(440, 700),
        PixelsPerStud = 200,
        AlwaysOnTop = true,
        ResetOnSpawn = false,
    }, self.LeftPanelPart)

    self.LeftBackFrame = Create("Frame", {
        Name = "LeftBackFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(5, 5, 10),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, self.LeftBackSurfaceGui)

    -- 顶部装饰线
    local leftBackTopLine = Create("Frame", {
        Name = "TopLine",
        Size = UDim2.new(0.6, 0, 0, 2),
        Position = UDim2.new(0.2, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 120),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, self.LeftBackFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, leftBackTopLine)

    -- APPLE 文字
    Create("TextLabel", {
        Name = "AppleText",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0.38, 0),
        BackgroundTransparency = 1,
        Text = "APPLE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
        TextTransparency = 0.05,
    }, self.LeftBackFrame)

    -- vision pro 文字
    Create("TextLabel", {
        Name = "VisionProText",
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0.46, 0),
        BackgroundTransparency = 1,
        Text = "vision pro",
        TextColor3 = Color3.fromRGB(180, 180, 200),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextTransparency = 0.1,
    }, self.LeftBackFrame)

    -- 🍎 图标
    Create("TextLabel", {
        Name = "AppleIcon",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0.52, 0),
        BackgroundTransparency = 1,
        Text = "🍎",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 40,
    }, self.LeftBackFrame)

    -- 底部装饰线
    local leftBackBotLine = Create("Frame", {
        Name = "BotLine",
        Size = UDim2.new(0.6, 0, 0, 2),
        Position = UDim2.new(0.2, 0, 0.62, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 120),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, self.LeftBackFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, leftBackBotLine)

    -- 版本号
    Create("TextLabel", {
        Name = "VersionText",
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0.88, 0),
        BackgroundTransparency = 1,
        Text = "tubers93 | ARVR v14",
        TextColor3 = Color3.fromRGB(80, 80, 100),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextTransparency = 0.3,
    }, self.LeftBackFrame)

    self.LeftMainFrame = Create("Frame", {
        Name = "LeftMainFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
    }, self.LeftSurfaceGui)
    Create("UICorner", {CornerRadius = UDim.new(0, 14)}, self.LeftMainFrame)
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1.5, Transparency = 0.4}, self.LeftMainFrame)

    -- 左面板顶部控制栏
    self.LeftControlBar = Create("Frame", {
        Name = "LeftControlBar",
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.ControlBar,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, self.LeftMainFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, self.LeftControlBar)

    -- 左面板标题
    self.LeftTitleLabel = Create("TextLabel", {
        Name = "LeftTitle",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "📑 标签页",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self.LeftControlBar)

    -- 左面板控制按钮容器
    self.LeftControlButtons = Create("Frame", {
        Name = "LeftControlButtons",
        Size = UDim2.new(0.5, -10, 1, -4),
        Position = UDim2.new(0.5, 5, 0, 2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, self.LeftControlBar)

    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, self.LeftControlButtons)

    -- 左面板标签页区域
    self.Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Size = UDim2.new(1, -16, 1, -56),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, self.LeftMainFrame)

    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, self.Sidebar)
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, self.Sidebar)
    SetupAutoCanvas(self.Sidebar, 20)

    -- ═══════════════════════════════════════════════════════════════════════════════
    -- 右面板: 内容区域 + 顶部控制栏
    -- ═══════════════════════════════════════════════════════════════════════════════
    self.RightPanelPart = Create("Part", {
        Name = "ARVR_RightPanel",
        Size = Vector3.new(4.0, 3.5, 0.05),
        Anchored = true,
        CanCollide = true,
        Transparency = 0.3,
        Color = Theme.PanelBack,
        Material = Enum.Material.SmoothPlastic,
    }, workspace)

    self.RightSurfaceGui = Create("SurfaceGui", {
        Name = "ARVR_RightSurfaceGui",
        Parent = self.RightPanelPart,
        Face = Enum.NormalId.Front,
        SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
        CanvasSize = Vector2.new(800, 700),
        PixelsPerStud = 200,
        AlwaysOnTop = true,
        ResetOnSpawn = false,
    }, self.RightPanelPart)

    -- 右面板背面: APPLE vision pro 🍎
    self.RightBackSurfaceGui = Create("SurfaceGui", {
        Name = "ARVR_RightBackSurfaceGui",
        Parent = self.RightPanelPart,
        Face = Enum.NormalId.Back,
        SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
        CanvasSize = Vector2.new(800, 700),
        PixelsPerStud = 200,
        AlwaysOnTop = true,
        ResetOnSpawn = false,
    }, self.RightPanelPart)

    self.RightBackFrame = Create("Frame", {
        Name = "RightBackFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(5, 5, 10),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, self.RightBackSurfaceGui)

    -- 顶部装饰线
    local rightBackTopLine = Create("Frame", {
        Name = "TopLine",
        Size = UDim2.new(0.4, 0, 0, 2),
        Position = UDim2.new(0.3, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 120),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, self.RightBackFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, rightBackTopLine)

    -- APPLE 文字
    Create("TextLabel", {
        Name = "AppleText",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0.38, 0),
        BackgroundTransparency = 1,
        Text = "APPLE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 38,
        TextTransparency = 0.05,
    }, self.RightBackFrame)

    -- vision pro 文字
    Create("TextLabel", {
        Name = "VisionProText",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0.46, 0),
        BackgroundTransparency = 1,
        Text = "vision pro",
        TextColor3 = Color3.fromRGB(180, 180, 200),
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        TextTransparency = 0.1,
    }, self.RightBackFrame)

    -- 🍎 图标
    Create("TextLabel", {
        Name = "AppleIcon",
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0.52, 0),
        BackgroundTransparency = 1,
        Text = "🍎",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 48,
    }, self.RightBackFrame)

    -- 底部装饰线
    local rightBackBotLine = Create("Frame", {
        Name = "BotLine",
        Size = UDim2.new(0.4, 0, 0, 2),
        Position = UDim2.new(0.3, 0, 0.62, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 120),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, self.RightBackFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, rightBackBotLine)

    -- 版本号
    Create("TextLabel", {
        Name = "VersionText",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0.88, 0),
        BackgroundTransparency = 1,
        Text = "tubers93 | ARVR v14",
        TextColor3 = Color3.fromRGB(80, 80, 100),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextTransparency = 0.3,
    }, self.RightBackFrame)

    self.RightMainFrame = Create("Frame", {
        Name = "RightMainFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
    }, self.RightSurfaceGui)
    Create("UICorner", {CornerRadius = UDim.new(0, 14)}, self.RightMainFrame)
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1.5, Transparency = 0.4}, self.RightMainFrame)

    -- 右面板顶部控制栏
    self.RightControlBar = Create("Frame", {
        Name = "RightControlBar",
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.ControlBar,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, self.RightMainFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, self.RightControlBar)

    -- 右面板标题
    self.RightTitleLabel = Create("TextLabel", {
        Name = "RightTitle",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "⚡ 功能面板",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self.RightControlBar)

    -- 右面板控制按钮容器
    self.RightControlButtons = Create("Frame", {
        Name = "RightControlButtons",
        Size = UDim2.new(0.5, -10, 1, -4),
        Position = UDim2.new(0.5, 5, 0, 2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, self.RightControlBar)

    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, self.RightControlButtons)

    -- 右面板内容区域
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -16, 1, -56),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
    }, self.RightMainFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 12)}, self.ContentArea)

    -- ═══════════════════════════════════════════════════════════════════════════════
    -- 单面板模式下的合并侧边栏
    -- ═══════════════════════════════════════════════════════════════════════════════
    self.MergedSidebar = Create("ScrollingFrame", {
        Name = "MergedSidebar",
        Size = UDim2.new(0.30, -12, 1, -56),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, self.RightMainFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 10)}, self.MergedSidebar)
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.5}, self.MergedSidebar)

    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, self.MergedSidebar)
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, self.MergedSidebar)
    SetupAutoCanvas(self.MergedSidebar, 20)

    -- 创建调试控制按钮
    self:CreateControlButtons()

    -- 启动粒子效果 + 启动动画
    StartupAnimation:Play(PlayerGui, function()
        self:StartPositionLoop()
    end)

    return self
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 创建调试控制按钮 (缩小/放大/方向/合并/固定/手势/隐藏/关闭)
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:CreateControlButtons()
    local controls = {
        {Icon = "➖", Name = "Shrink", Tip = "缩小UI"},
        {Icon = "➕", Name = "Enlarge", Tip = "放大UI"},
        {Icon = "🔄", Name = "Flip", Tip = "翻转方向"},
        {Icon = "🔀", Name = "Merge", Tip = "合并/拆分UI"},
        {Icon = "👁️", Name = "Fix", Tip = "固定/跟随UI"},
        {Icon = "🖐️", Name = "Gesture", Tip = "手势开关"},
        {Icon = "🍎", Name = "Hide", Tip = "隐藏UI"},
        {Icon = "❌", Name = "Close", Tip = "关闭UI"},
    }

    local function MakeButton(parent, data, callback)
        local btn = Create("TextButton", {
            Name = "CtrlBtn_" .. data.Name,
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = Theme.BackgroundTransparent,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Text = data.Icon,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            AutoButtonColor = false,
        }, parent)
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}, btn)

        btn.MouseEnter:Connect(function()
            PlayTween(btn, 0.15, {BackgroundTransparency = 0.1, BackgroundColor3 = Theme.Accent})
        end)
        btn.MouseLeave:Connect(function()
            PlayTween(btn, 0.15, {BackgroundTransparency = 0.3, BackgroundColor3 = Theme.BackgroundTransparent})
        end)
        btn.MouseButton1Click:Connect(function()
            PlayTween(btn, 0.1, {BackgroundTransparency = 0})
            task.wait(0.1)
            PlayTween(btn, 0.2, {BackgroundTransparency = 0.3})
            if callback then callback() end
        end)

        return btn
    end

    for _, ctrl in ipairs(controls) do
        MakeButton(self.LeftControlButtons, ctrl, function()
            self:HandleControl(ctrl.Name)
        end)
    end

    for _, ctrl in ipairs(controls) do
        MakeButton(self.RightControlButtons, ctrl, function()
            self:HandleControl(ctrl.Name)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 控制按钮处理逻辑
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:HandleControl(action)
    if action == "Shrink" then
        ARVR_UI.Scale = math.max(0.5, ARVR_UI.Scale - 0.15)
        self:Notify({Title = "UI缩放", Content = "缩放: " .. string.format("%.0f%%", ARVR_UI.Scale * 100), Duration = 2})
    elseif action == "Enlarge" then
        ARVR_UI.Scale = math.min(2.0, ARVR_UI.Scale + 0.15)
        self:Notify({Title = "UI缩放", Content = "缩放: " .. string.format("%.0f%%", ARVR_UI.Scale * 100), Duration = 2})
    elseif action == "Flip" then
        ARVR_UI.Direction = ARVR_UI.Direction * -1
        self:Notify({Title = "UI方向", Content = ARVR_UI.Direction == 1 and "正常方向" or "翻转方向", Duration = 2})
    elseif action == "Merge" then
        self:ToggleMerge()
    elseif action == "Fix" then
        self.IsFixed = not self.IsFixed
        if self.IsFixed then
            self:Notify({Title = "UI固定", Content = "UI已固定，不再跟随头部移动", Duration = 2})
        else
            self:Notify({Title = "UI跟随", Content = "UI已恢复跟随头部移动", Duration = 2})
        end
    elseif action == "Gesture" then
        self:ToggleGesture()
    elseif action == "Hide" then
        self:HideUI()
    elseif action == "Close" then
        self:Destroy()
        self:Notify({Title = "UI关闭", Content = "UI已销毁", Duration = 2})
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 合并/拆分 UI 逻辑
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:ToggleMerge()
    self.IsMerged = not self.IsMerged

    if self.IsMerged then
        self.LeftPanelPart.Transparency = 1
        self.LeftPanelPart.CanCollide = false
        self.LeftSurfaceGui.Enabled = false
        self.LeftBackSurfaceGui.Enabled = false

        self.MergedSidebar.Visible = true

        self.ContentArea.Size = UDim2.new(0.68, -16, 1, -56)
        self.ContentArea.Position = UDim2.new(0.32, 0, 0, 48)

        if self.CurrentTab and self.Tabs[self.CurrentTab] then
            local tab = self.Tabs[self.CurrentTab]
            if tab.MergedButton then
                PlayTween(tab.MergedButton, 0.2, {
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.85,
                })
                tab.MergedButton.TextColor3 = Theme.Text
            end
        end

        self:Notify({Title = "UI模式", Content = "已切换为单面板模式", Duration = 2})
    else
        self.LeftPanelPart.Transparency = 0.3
        self.LeftPanelPart.CanCollide = true
        self.LeftSurfaceGui.Enabled = true
        self.LeftBackSurfaceGui.Enabled = true

        self.MergedSidebar.Visible = false

        self.ContentArea.Size = UDim2.new(1, -16, 1, -56)
        self.ContentArea.Position = UDim2.new(0, 8, 0, 48)

        self:Notify({Title = "UI模式", Content = "已切换为双面板模式", Duration = 2})
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 手势系统切换 (点击按钮开启/关闭)
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:ToggleGesture()
    self.UseGesture = not self.UseGesture

    if self.UseGesture then
        self:InitGesture()
        self:Notify({Title = "手势系统", Content = "🖐️ 右手IK手势已开启", Duration = 2})
    else
        self:DisableGesture()
        self:Notify({Title = "手势系统", Content = "🖐️ 右手IK手势已关闭", Duration = 2})
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 手势系统初始化 (使用IKControl让右手跟随准星)
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:InitGesture()
    -- 准星UI
    if self.CursorLabel then
        self.CursorLabel.Parent:Destroy()
        self.CursorLabel = nil
    end

    local cursorGui = Create("ScreenGui", {Name = "GestureCursor"}, PlayerGui)
    local cursorLabel = Create("TextLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "+",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 28,
    }, cursorGui)
    self.CursorLabel = cursorLabel

    -- 鼠标/触摸位置追踪 + 点击检测
    local camera = workspace.CurrentCamera
    self.LastMousePos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    self.IsClicking = false

    local inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self.LastMousePos = Vector2.new(input.Position.X, input.Position.Y)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            self.LastMousePos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    table.insert(self.Connections, inputChangedConn)

    -- 检测点击/触摸开始（手指伸出）
    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) then
            self.IsClicking = true
        end
    end)
    table.insert(self.Connections, inputBeganConn)

    -- 检测点击/触摸结束（手指收回）
    local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) then
            self.IsClicking = false
        end
    end)
    table.insert(self.Connections, inputEndedConn)

    -- 创建IK目标零件 (不可见)
    if self.IKTarget then
        pcall(function() self.IKTarget:Destroy() end)
    end
    self.IKTarget = Create("Part", {
        Name = "ARVR_IKTarget",
        Size = Vector3.new(0.1, 0.1, 0.1),
        Anchored = true,
        CanCollide = false,
        Transparency = 1,
    }, workspace)

    -- 尝试为本地角色的右手设置IK控制器
    local function setupIK()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        -- 移除旧的IKControl
        if self.IKControl then
            pcall(function() self.IKControl:Destroy() end)
            self.IKControl = nil
        end

        -- 创建新的IKControl (适用于R15)
        local ik = Instance.new("IKControl")
        ik.Type = Enum.IKControlType.Position
        ik.Target = self.IKTarget
        ik.ChainRoot = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
        ik.EndEffector = char:FindFirstChild("RightHand") or nil
        ik.SmoothTime = 0.08
        ik.Weight = 1
        ik.Parent = humanoid
        self.IKControl = ik
    end

    setupIK()
    -- 角色重生时重新设置IK
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupIK()
    end)
    table.insert(self.Connections, charAddedConn)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 关闭手势系统
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:DisableGesture()
    -- 隐藏准星
    if self.CursorLabel then
        pcall(function() self.CursorLabel.Parent:Destroy() end)
        self.CursorLabel = nil
    end

    -- 移除IK控制器
    if self.IKControl then
        pcall(function() self.IKControl:Destroy() end)
        self.IKControl = nil
    end

    -- 移除IK目标
    if self.IKTarget then
        pcall(function() self.IKTarget:Destroy() end)
        self.IKTarget = nil
    end

    -- 重置点击状态
    self.IsClicking = false

    -- 清理手势相关连接（保留其他连接）
    local newConnections = {}
    for _, conn in ipairs(self.Connections) do
        if conn then
            local ok, isInput = pcall(function()
                -- 尝试判断是否是输入相关的连接
                return conn.Connected ~= nil
            end)
            if ok and isInput then
                -- 断开输入相关的连接
                pcall(function() conn:Disconnect() end)
            else
                table.insert(newConnections, conn)
            end
        end
    end
    self.Connections = {}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 隐藏UI - 显示🍎浮动按钮
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:HideUI()
    self.IsHidden = true
    ARVR_UI.IsVisible = false

    -- 隐藏双面板
    self.LeftPanelPart.Transparency = 1
    self.LeftPanelPart.CanCollide = false
    self.LeftSurfaceGui.Enabled = false
    self.LeftBackSurfaceGui.Enabled = false

    self.RightPanelPart.Transparency = 1
    self.RightPanelPart.CanCollide = false
    self.RightSurfaceGui.Enabled = false
    self.RightBackSurfaceGui.Enabled = false

    -- 创建🍎浮动按钮
    self:CreateAppleButton()

    self:Notify({Title = "UI隐藏", Content = "点击🍎按钮恢复UI", Duration = 2})
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 创建🍎浮动按钮 (屏幕左侧，可拖动，圆形)
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:CreateAppleButton()
    -- 清理旧的
    if self.AppleGui then
        pcall(function() self.AppleGui:Destroy() end)
    end
    for _, conn in ipairs(self.AppleConnections) do
        pcall(function() conn:Disconnect() end)
    end
    self.AppleConnections = {}

    self.AppleGui = Create("ScreenGui", {
        Name = "ARVR_AppleButton",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    -- 圆形外框容器
    local appleFrame = Create("Frame", {
        Name = "AppleFrame",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
    }, self.AppleGui)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, appleFrame)
    Create("UIStroke", {
        Color = Color3.fromRGB(255, 50, 50),
        Thickness = 2.5,
        Transparency = 0.2,
    }, appleFrame)

    -- 🍎 图标
    local appleIcon = Create("TextLabel", {
        Name = "AppleIcon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "🍎",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 24,
    }, appleFrame)

    -- 发光效果
    local glow = Create("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0, -4, 0, -4),
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
    }, appleFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, glow)

    -- 发光动画
    local glowTween = TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.7,
    })
    glowTween:Play()

    self.AppleButton = appleFrame

    -- 拖动功能
    local dragging = false
    local dragStartPos = nil
    local frameStartPos = nil

    local inputBeganConn = appleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            frameStartPos = appleFrame.Position
            input.Handled = true
        end
    end)
    table.insert(self.AppleConnections, inputBeganConn)

    local inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            appleFrame.Position = UDim2.new(
                frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
    table.insert(self.AppleConnections, inputChangedConn)

    local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                -- 检查是否是点击（移动距离很小）
                local currentPos = Vector2.new(input.Position.X, input.Position.Y)
                local delta = currentPos - dragStartPos
                if delta.Magnitude < 5 then
                    -- 是点击，恢复UI
                    self:ShowUI()
                end
            end
        end
    end)
    table.insert(self.AppleConnections, inputEndedConn)

    -- 悬停效果
    appleFrame.MouseEnter:Connect(function()
        PlayTween(appleFrame, 0.2, {Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(appleFrame.Position.X.Scale, appleFrame.Position.X.Offset - 3, appleFrame.Position.Y.Scale, appleFrame.Position.Y.Offset - 3)})
    end)
    appleFrame.MouseLeave:Connect(function()
        PlayTween(appleFrame, 0.2, {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(appleFrame.Position.X.Scale, appleFrame.Position.X.Offset + 3, appleFrame.Position.Y.Scale, appleFrame.Position.Y.Offset + 3)})
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 恢复UI显示
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:ShowUI()
    self.IsHidden = false
    ARVR_UI.IsVisible = true

    -- 销毁🍎按钮
    if self.AppleGui then
        pcall(function() self.AppleGui:Destroy() end)
        self.AppleGui = nil
    end
    for _, conn in ipairs(self.AppleConnections) do
        pcall(function() conn:Disconnect() end)
    end
    self.AppleConnections = {}
    self.AppleButton = nil

    -- 恢复双面板
    if self.IsMerged then
        self.LeftPanelPart.Transparency = 1
        self.LeftPanelPart.CanCollide = false
        self.LeftSurfaceGui.Enabled = false
    else
        self.LeftPanelPart.Transparency = 0.3
        self.LeftPanelPart.CanCollide = true
        self.LeftSurfaceGui.Enabled = true
        self.LeftBackSurfaceGui.Enabled = true
    end

    self.RightPanelPart.Transparency = 0.3
    self.RightPanelPart.CanCollide = true
    self.RightSurfaceGui.Enabled = true
    self.RightBackSurfaceGui.Enabled = true

    self:Notify({Title = "UI恢复", Content = "双面板UI已显示", Duration = 2})
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 核心: 双面板位置跟随 + 手势更新循环
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:StartPositionLoop()
    self.PositionConnection = RunService.RenderStepped:Connect(function()
        if not ARVR_UI.IsVisible then
            if self.CursorLabel then self.CursorLabel.Visible = false end
            return
        end

        -- 手势更新：移动IK目标到射线命中点
        if self.UseGesture and self.IKTarget then
            if self.CursorLabel then
                self.CursorLabel.Position = UDim2.new(0, self.LastMousePos.X, 0, self.LastMousePos.Y)
                self.CursorLabel.Visible = true
            end

            local camera = workspace.CurrentCamera
            local ray = camera:ScreenPointToRay(self.LastMousePos.X, self.LastMousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            raycastParams.FilterDescendantsInstances = {self.LeftPanelPart, self.RightPanelPart}
            local result = workspace:Raycast(ray.Origin, ray.Direction * 50, raycastParams)

            if result and result.Instance then
                -- 命中面板，IK目标设为命中点偏前一点(让手指看起来像在触摸)
                local normal = result.Normal
                -- 点击时手指伸出更多，模拟点击动作
                local clickOffset = self.IsClicking and 0.15 or 0.05
                self.IKTarget.CFrame = CFrame.new(result.Position + normal * clickOffset)
            else
                -- 未命中面板，将IK目标放在右肩前方自然位置
                local char = LocalPlayer.Character
                if char then
                    local rightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                    if rightUpperArm then
                        local defaultPos = rightUpperArm.Position + Vector3.new(1, 0, 0)
                        self.IKTarget.CFrame = CFrame.new(defaultPos)
                    end
                end
            end
        end

        -- 面板位置更新
        if self.IsFixed then return end

        local character = LocalPlayer.Character
        if not character then return end
        local head = character:FindFirstChild("Head")
        if not head then return end

        local headCF = head.CFrame
        local isFirstPerson = IsFirstPerson()
        self.IsFirstPerson = isFirstPerson

        local baseDistance = isFirstPerson and 2.2 or 3.5
        local distance = baseDistance * ARVR_UI.Scale
        local panelGap = 0.3 * ARVR_UI.Scale

        local centerPos = headCF.Position + headCF.LookVector * distance + headCF.UpVector * 0.3

        local leftOffset = headCF.RightVector * (-1.3 * ARVR_UI.Scale - panelGap)
        local leftPos = centerPos + leftOffset
        local leftTargetCF = CFrame.lookAt(leftPos, headCF.Position)
        if ARVR_UI.Direction == -1 then
            leftTargetCF = leftTargetCF * CFrame.Angles(0, math.rad(180), 0)
        end
        self.LeftPanelPart.CFrame = self.LeftPanelPart.CFrame:Lerp(leftTargetCF, 0.12)
        self.LeftPanelPart.Size = Vector3.new(2.2 * ARVR_UI.Scale, 3.5 * ARVR_UI.Scale, 0.05 * ARVR_UI.Scale)

        local rightOffset
        if self.IsMerged then
            rightOffset = headCF.RightVector * (0.5 * ARVR_UI.Scale)
        else
            rightOffset = headCF.RightVector * (2.0 * ARVR_UI.Scale + panelGap)
        end
        local rightPos = centerPos + rightOffset
        local rightTargetCF = CFrame.lookAt(rightPos, headCF.Position)
        if ARVR_UI.Direction == -1 then
            rightTargetCF = rightTargetCF * CFrame.Angles(0, math.rad(180), 0)
        end
        self.RightPanelPart.CFrame = self.RightPanelPart.CFrame:Lerp(rightTargetCF, 0.12)
        self.RightPanelPart.Size = Vector3.new(4.0 * ARVR_UI.Scale, 3.5 * ARVR_UI.Scale, 0.05 * ARVR_UI.Scale)

        local modeText = isFirstPerson and " [VR]" or " [HUD]"
        self.LeftTitleLabel.Text = "📑 标签页" .. modeText
        self.RightTitleLabel.Text = "⚡ 功能面板" .. modeText
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 销毁UI
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:Destroy()
    if self.PositionConnection then
        self.PositionConnection:Disconnect()
        self.PositionConnection = nil
    end
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    for _, conn in ipairs(self.AppleConnections) do
        pcall(function() conn:Disconnect() end)
    end
    self.AppleConnections = {}

    pcall(function() self.LeftPanelPart:Destroy() end)
    pcall(function() self.RightPanelPart:Destroy() end)
    if self.IKControl then
        pcall(function() self.IKControl:Destroy() end)
    end
    if self.IKTarget then
        pcall(function() self.IKTarget:Destroy() end)
    end
    if self.CursorLabel then
        pcall(function() self.CursorLabel.Parent:Destroy() end)
    end
    if self.AppleGui then
        pcall(function() self.AppleGui:Destroy() end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tab 系统
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:Tab(data)
    if type(data) == "string" then
        data = {Title = data, Icon = ""}
    end

    local tabName = data.Title or "Tab"
    local tabIcon = data.Icon or ""

    local tabData = {
        Name = tabName,
        Icon = tabIcon,
        Sections = {},
        Content = nil,
        Button = nil,
        MergedButton = nil,
    }

    table.insert(self.TabList, tabData)
    self.Tabs[tabName] = tabData

    -- 左面板标签按钮
    local tabButton = Create("TextButton", {
        Name = "TabButton_" .. tabName,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        AutoButtonColor = false,
    }, self.Sidebar)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, tabButton)
    tabData.Button = tabButton

    -- 合并面板标签按钮
    local mergedTabButton = Create("TextButton", {
        Name = "TabButton_" .. tabName,
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        AutoButtonColor = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, self.MergedSidebar)
    Create("UICorner", {CornerRadius = UDim.new(0, 6)}, mergedTabButton)
    tabData.MergedButton = mergedTabButton

    tabData.Content = Create("ScrollingFrame", {
        Name = "TabContent_" .. tabName,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        ClipsDescendants = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, self.ContentArea)
    Create("UIListLayout", {Padding = UDim.new(0, 8)}, tabData.Content)
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, tabData.Content)
    SetupAutoCanvas(tabData.Content, 20)

    -- 使用触摸防误触
    SetupTouchProtection(tabButton, function()
        self:SelectTab(tabName)
    end)
    tabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabName then
            PlayTween(tabButton, 0.2, {BackgroundTransparency = 0.5})
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabName then
            PlayTween(tabButton, 0.2, {BackgroundTransparency = 0.8})
        end
    end)

    SetupTouchProtection(mergedTabButton, function()
        self:SelectTab(tabName)
    end)
    mergedTabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabName then
            PlayTween(mergedTabButton, 0.2, {BackgroundTransparency = 0.5})
        end
    end)
    mergedTabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabName then
            PlayTween(mergedTabButton, 0.2, {BackgroundTransparency = 0.8})
        end
    end)

    if #self.TabList == 1 then
        self:SelectTab(tabName)
    end

    return tabData
end

function ARVR_UI:SelectTab(tabName)
    if self.CurrentTab == tabName then return end

    if self.CurrentTab and self.Tabs[self.CurrentTab] then
        local oldTab = self.Tabs[self.CurrentTab]
        if oldTab.Button then
            PlayTween(oldTab.Button, 0.2, {BackgroundColor3 = Theme.BackgroundTransparent, BackgroundTransparency = 0.8})
            oldTab.Button.TextColor3 = Theme.TextDim
        end
        if oldTab.MergedButton then
            PlayTween(oldTab.MergedButton, 0.2, {BackgroundColor3 = Theme.BackgroundTransparent, BackgroundTransparency = 0.8})
            oldTab.MergedButton.TextColor3 = Theme.TextDim
        end
        oldTab.Content.Visible = false
    end

    self.CurrentTab = tabName
    local newTab = self.Tabs[tabName]
    if newTab.Button then
        PlayTween(newTab.Button, 0.2, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.85})
        newTab.Button.TextColor3 = Theme.Text
    end
    if newTab.MergedButton then
        PlayTween(newTab.MergedButton, 0.2, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.85})
        newTab.MergedButton.TextColor3 = Theme.Text
    end
    newTab.Content.Visible = true
    self.RightTitleLabel.Text = "⚡ " .. tabName
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Section 系统
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:CreateSection(tabData, title, isOpen)
    local sectionData = {
        Frame = nil,
        Elements = {},
    }
    table.insert(tabData.Sections, sectionData)

    sectionData.Frame = Create("Frame", {
        Name = "Section_" .. title,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, tabData.Content)
    Create("UICorner", {CornerRadius = UDim.new(0, 12)}, sectionData.Frame)
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.6}, sectionData.Frame)
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, sectionData.Frame)
    Create("UIListLayout", {Padding = UDim.new(0, 6)}, sectionData.Frame)

    Create("TextLabel", {
        Name = "SectionTitle",
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sectionData.Frame)

    local sectionAPI = {}
    function sectionAPI:Button(text, callback)
        return ARVR_UI:CreateButton(sectionData, text, callback)
    end
    function sectionAPI:Toggle(text, flag, default, callback)
        return ARVR_UI:CreateToggle(sectionData, text, flag, default, callback)
    end
    function sectionAPI:Slider(text, flag, min, max, default, callback)
        return ARVR_UI:CreateSlider(sectionData, text, flag, min, max, default, callback)
    end
    function sectionAPI:Dropdown(text, flag, options, callback)
        return ARVR_UI:CreateDropdown(sectionData, text, flag, options, callback)
    end
    function sectionAPI:Textbox(text, flag, placeholder, callback)
        return ARVR_UI:CreateTextbox(sectionData, text, flag, placeholder, callback)
    end
    function sectionAPI:Label(text)
        return ARVR_UI:CreateLabel(sectionData, text)
    end
    return sectionAPI
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- UI 组件实现
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:CreateButton(sectionData, text, callback)
    local button = Create("TextButton", {
        Name = "Button_" .. text,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        AutoButtonColor = false,
    }, sectionData.Frame)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, button)

    local function onClick()
        if callback then
            local success, err = pcall(callback)
            if not success then warn("[ARVR UI] 按钮回调错误: " .. tostring(err)) end
        end
        PlayTween(button, 0.1, {BackgroundTransparency = 0.7})
        task.wait(0.1)
        PlayTween(button, 0.2, {BackgroundTransparency = 0.9})
    end

    SetupTouchProtection(button, onClick)
    button.MouseEnter:Connect(function()
        PlayTween(button, 0.2, {BackgroundTransparency = 0.8})
    end)
    button.MouseLeave:Connect(function()
        PlayTween(button, 0.2, {BackgroundTransparency = 0.9})
    end)
    return button
end

function ARVR_UI:CreateToggle(sectionData, text, flag, default, callback)
    local state = default or false
    local toggleFrame = Create("Frame", {
        Name = "Toggle_" .. text,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, sectionData.Frame)
    Create("TextLabel", {
        Name = "ToggleLabel",
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toggleFrame)
    local switchFrame = Create("Frame", {
        Name = "Switch",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -46, 0.5, -10),
        BackgroundColor3 = state and Theme.Success or Theme.Stroke,
        BorderSizePixel = 0,
    }, toggleFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, switchFrame)
    local knob = Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, switchFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)

    local function Toggle()
        state = not state
        local targetColor = state and Theme.Success or Theme.Stroke
        local targetPosition = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        PlayTween(switchFrame, 0.2, {BackgroundColor3 = targetColor})
        PlayTween(knob, 0.2, {Position = targetPosition})
        if callback then
            local success, err = pcall(callback, state)
            if not success then warn("[ARVR UI] 开关回调错误: " .. tostring(err)) end
        end
    end

    SetupFrameTouchProtection(toggleFrame, Toggle)
    return {GetState = function() return state end}
end

function ARVR_UI:CreateSlider(sectionData, text, flag, min, max, default, callback)
    local value = default or min or 0
    min = min or 0
    max = max or 100
    local sliderFrame = Create("Frame", {
        Name = "Slider_" .. text,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, sectionData.Frame)
    local valueLabel = Create("TextLabel", {
        Name = "ValueLabel",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text .. ": " .. value,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sliderFrame)
    local barBackground = Create("Frame", {
        Name = "BarBackground",
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
    }, sliderFrame)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, barBackground)
    local barFill = Create("Frame", {
        Name = "BarFill",
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, barBackground)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, barFill)

    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - barBackground.AbsolutePosition.X) / barBackground.AbsoluteSize.X, 0, 1)
        value = math.floor(min + pos * (max - min))
        barFill.Size = UDim2.new(pos, 0, 1, 0)
        valueLabel.Text = text .. ": " .. value
        if callback then
            local success, err = pcall(callback, value)
            if not success then warn("[ARVR UI] 滑条回调错误: " .. tostring(err)) end
        end
    end

    barBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    return {GetValue = function() return value end}
end

function ARVR_UI:CreateDropdown(sectionData, text, flag, options, callback)
    local optionsList = options or {}
    local selected = optionsList[1] or ""
    local isOpen = false
    local dropdownFrame = Create("Frame", {
        Name = "Dropdown_" .. text,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, sectionData.Frame)
    local dropdownButton = Create("TextButton", {
        Name = "DropdownButton",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Text = text .. ": " .. selected .. " ▼",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        AutoButtonColor = false,
    }, dropdownFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, dropdownButton)
    local optionsContainer = Create("Frame", {
        Name = "OptionsContainer",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    }, dropdownFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, optionsContainer)
    Create("UIListLayout", {Padding = UDim.new(0, 2)}, optionsContainer)

    local function BuildOptions()
        for _, child in ipairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, option in ipairs(optionsList) do
            local optionButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Text = option,
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 51,
            }, optionsContainer)
            
            local function onOptClick()
                selected = option
                dropdownButton.Text = text .. ": " .. selected .. " ▼"
                isOpen = false
                optionsContainer.Visible = false
                dropdownFrame.Size = UDim2.new(1, 0, 0, 34)
                if callback then
                    local success, err = pcall(callback, selected)
                    if not success then warn("[ARVR UI] 下拉框回调错误: " .. tostring(err)) end
                end
            end
            
            SetupTouchProtection(optionButton, onOptClick)
            optionButton.MouseEnter:Connect(function()
                optionButton.TextColor3 = Theme.Text
            end)
            optionButton.MouseLeave:Connect(function()
                optionButton.TextColor3 = Theme.TextDim
            end)
        end
    end
    BuildOptions()

    local function ToggleDropdown()
        isOpen = not isOpen
        optionsContainer.Visible = isOpen
        if isOpen then
            local count = #optionsList
            dropdownFrame.Size = UDim2.new(1, 0, 0, 34 + count * 28)
            optionsContainer.Size = UDim2.new(1, 0, 0, count * 28)
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 34)
        end
    end
    
    SetupTouchProtection(dropdownButton, ToggleDropdown)

    return {
        GetSelected = function() return selected end,
        SetOptions = function(newOptions)
            optionsList = newOptions
            BuildOptions()
        end,
    }
end

function ARVR_UI:CreateTextbox(sectionData, text, flag, placeholder, callback)
    local textboxFrame = Create("Frame", {
        Name = "Textbox_" .. text,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, sectionData.Frame)
    Create("TextLabel", {
        Name = "TextboxLabel",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, textboxFrame)
    local textBox = Create("TextBox", {
        Name = "InputBox",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = Theme.BackgroundTransparent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder or "输入...",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
    }, textboxFrame)
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}, textBox)
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Transparency = 0.5}, textBox)

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            local success, err = pcall(callback, textBox.Text)
            if not success then warn("[ARVR UI] 输入框回调错误: " .. tostring(err)) end
        end
    end)
    return {GetText = function() return textBox.Text end}
end

function ARVR_UI:CreateLabel(sectionData, text)
    local label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sectionData.Frame)
    return {SetText = function(newText) label.Text = newText end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 通知系统
-- ═══════════════════════════════════════════════════════════════════════════════
function ARVR_UI:Notify(data)
    local character = LocalPlayer.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboard = Create("BillboardGui", {
        Size = UDim2.new(0, 280, 0, 56),
        StudsOffset = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = true,
        MaxDistance = 50,
    }, PlayerGui)
    billboard.Adornee = head

    local notificationFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
    }, billboard)
    Create("UICorner", {CornerRadius = UDim.new(0, 10)}, notificationFrame)
    Create("UIStroke", {Color = Theme.Accent, Thickness = 1}, notificationFrame)

    Create("TextLabel", {
        Size = UDim2.new(1, -12, 0, 20),
        Position = UDim2.new(0, 6, 0, 4),
        BackgroundTransparency = 1,
        Text = data.Title or "通知",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, notificationFrame)

    Create("TextLabel", {
        Size = UDim2.new(1, -12, 0, 18),
        Position = UDim2.new(0, 6, 0, 26),
        BackgroundTransparency = 1,
        Text = data.Content or "",
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, notificationFrame)

    task.delay(data.Duration or 3, function()
        pcall(function() billboard:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 兼容层包装 - 标准UI库格式 (兼容tubers93脚本切换系统)
-- ═══════════════════════════════════════════════════════════════════════════════
local ARVR_Library = {}

function ARVR_Library:new(title)
    local ui = ARVR_UI.new(title)
    local window = {}
    window.Title = title

    -- 创建Tab - 兼容调用: Tab("标题", "图标")
    function window:Tab(tabTitle, icon)
        -- 过滤纯数字 icon（避免显示 asset id 如 '118759541854879'）
        local iconStr = icon or ""
        if iconStr ~= "" and tonumber(iconStr) then
            iconStr = ""  -- 纯数字字符串当作无图标
        end
        local data = {Title = tabTitle, Icon = iconStr}
        local tab = ui:Tab(data)
        local tabAPI = {}

        -- 创建Section - 兼容调用: section("标题", true/false)
        -- 直接返回原始 sectionAPI，它内部通过闭包正确引用了 sectionData.Frame
        function tabAPI:section(sectionTitle, isOpen)
            return ui:CreateSection(tab, sectionTitle, isOpen)
        end

        return tabAPI
    end

    -- 通知系统
    function window:Notify(data)
        ui:Notify(data)
    end

    -- ARVR 特有控制功能
    function window:ToggleMerge()
        ui:ToggleMerge()
    end

    function window:ToggleGesture()
        ui:ToggleGesture()
    end

    function window:HideUI()
        ui:HideUI()
    end

    function window:ShowUI()
        ui:ShowUI()
    end

    function window:Destroy()
        ui:Destroy()
    end

    return window
end

-- 兼容大写 New
ARVR_Library.New = ARVR_Library.new

return ARVR_Library
