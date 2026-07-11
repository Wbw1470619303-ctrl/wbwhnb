local BS_ProtectedExecute = function(BS_protectedCode, ...)
    if game.Close ~= game.Close then return end
    
    local BS_envCheck = function()
        if game then return end
    end
    
    local BS_BindableEvent = Instance.new("BindableEvent")
    local BS_SecretStatusCode
    
    task.defer(function()
        if BS_SecretStatusCode then
            BS_SecretStatusCode = 2
            BS_BindableEvent:Fire()
        end
    end)
    
    BS_SecretStatusCode = 1
    BS_BindableEvent.Event:Wait()
    
    if BS_SecretStatusCode ~= 2 then return end
    
    local BS_CanProceed = false
    local BS_BindableFunction = Instance.new("BindableFunction")
    
    function BS_BindableFunction.OnInvoke(BS_Num, ...)
        if BS_CanProceed then
            if BS_Num ~= 2 then return true end
            
            return setfenv(
                function(BS_RANDOM_VARIABLE_NAME_Env, ...)
                    local BS_RANDOM_VARIABLE_NAME = nil
                    
                    return BS_RANDOM_VARIABLE_NAME_Env.setfenv(function(...)
                        return BS_protectedCode(...)
                    end, BS_RANDOM_VARIABLE_NAME_Env)(...)
                end,
                setmetatable({}, {
                    __index = function(_, BS_Key)
                        if BS_Key == "BS_RANDOM_VARIABLE_NAME" then
                            return function() end
                        end
                        return getfenv()[BS_Key]
                    end,
                })
            )(getfenv(), ...)
        end
        
        BS_CanProceed = true
        return nil
    end
    
    BS_CanProceed = true  
    local BS_Result = BS_BindableFunction:Invoke(2, ...)
    BS_BindableFunction:Destroy()
    return BS_Result
end

return BS_ProtectedExecute(function(...)
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
    
_G.BS_Auth_verification = true

        local function checkFileSupport()
            return pcall(function()
                local testFile = "BS_test_" .. tostring(tick()) .. ".txt"
                writefile(testFile, "test")
                local content = readfile(testFile)
                if content ~= "test" then error("读取不匹配") end
                delfile(testFile)
            end)
        end

        local SUPPORT_FILE_IO = checkFileSupport()
        local CONFIG_FILE = "BS_script/Config.json"

        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local CoreGui = game:GetService("CoreGui")
        local HttpService = game:GetService("HttpService")
        local Camera = workspace.CurrentCamera

        local Config = {EnableBypass = true}

        if SUPPORT_FILE_IO then
            local success, result = pcall(function()
                if isfile(CONFIG_FILE) then
                    local content = readfile(CONFIG_FILE)
                    return HttpService:JSONDecode(content)
                end
                return nil
            end)
            
            if success and result and typeof(result) == "table" and typeof(result.EnableBypass) == "boolean" then
                Config.EnableBypass = result.EnableBypass
            end
        end

        local BASE_WIDTH = 450
        local BASE_HEIGHT = 320

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "BS_Script_Launcher"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 999999

        if gethui then
            ScreenGui.Parent = gethui()
        elseif CoreGui:FindFirstChild("RobloxGui") then
            ScreenGui.Parent = CoreGui.RobloxGui
        else
            ScreenGui.Parent = CoreGui
        end

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
        MainFrame.Position = UDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        MainFrame.BorderSizePixel = 0
        MainFrame.ClipsDescendants = true
        MainFrame.Parent = ScreenGui

        local UIScale = Instance.new("UIScale")
        UIScale.Parent = MainFrame

        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
        })
        UIGradient.Rotation = 45
        UIGradient.Parent = MainFrame

        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Size = UDim2.new(1, 0, 0, 50)
        TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TitleBar.BorderSizePixel = 0
        TitleBar.Parent = MainFrame

        Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

        local TitleFix = Instance.new("Frame")
        TitleFix.Size = UDim2.new(1, 0, 0, 20)
        TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
        TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TitleFix.BorderSizePixel = 0
        TitleFix.Parent = TitleBar

        local TitleText = Instance.new("TextLabel")
        TitleText.Size = UDim2.new(1, -60, 1, 0)
        TitleText.Position = UDim2.new(0, 20, 0, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.Text = "tubers93 脚本启动器"
        TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleText.TextSize = 22
        TitleText.Font = Enum.Font.GothamBold
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Parent = TitleBar

        local SubTitle = Instance.new("TextLabel")
        SubTitle.Size = UDim2.new(1, -40, 0, 20)
        SubTitle.Position = UDim2.new(0, 20, 0, 55)
        SubTitle.BackgroundTransparency = 1
        SubTitle.Text = "选择是否启用反作弊绕过模块"
        SubTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
        SubTitle.TextSize = 14
        SubTitle.Font = Enum.Font.Gotham
        SubTitle.TextXAlignment = Enum.TextXAlignment.Left
        SubTitle.Parent = MainFrame

        local CloseButton = Instance.new("TextButton")
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -40, 0, 10)
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 20
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Parent = TitleBar

        Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Size = UDim2.new(1, -40, 0, 140)
        OptionsContainer.Position = UDim2.new(0, 20, 0, 85)
        OptionsContainer.BackgroundTransparency = 1
        OptionsContainer.Parent = MainFrame

        local Option1Frame = Instance.new("Frame")
        Option1Frame.Name = "EnableBypass"
        Option1Frame.Size = UDim2.new(1, 0, 0, 60)
        Option1Frame.Position = UDim2.new(0, 0, 0, 0)
        Option1Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Option1Frame.BorderSizePixel = 0
        Option1Frame.Parent = OptionsContainer

        Instance.new("UICorner", Option1Frame).CornerRadius = UDim.new(0, 12)

        local Option1Stroke = Instance.new("UIStroke")
        Option1Stroke.Color = Color3.fromRGB(60, 60, 75)
        Option1Stroke.Thickness = 2
        Option1Stroke.Parent = Option1Frame

        local Radio1 = Instance.new("Frame")
        Radio1.Size = UDim2.new(0, 24, 0, 24)
        Radio1.Position = UDim2.new(0, 15, 0.5, -12)
        Radio1.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        Radio1.BorderSizePixel = 0
        Radio1.Parent = Option1Frame

        Instance.new("UICorner", Radio1).CornerRadius = UDim.new(1, 0)

        local Radio1Inner = Instance.new("Frame")
        Radio1Inner.Size = UDim2.new(0, 12, 0, 12)
        Radio1Inner.Position = UDim2.new(0.5, -6, 0.5, -6)
        Radio1Inner.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Radio1Inner.BorderSizePixel = 0
        Radio1Inner.Visible = Config.EnableBypass
        Radio1Inner.Parent = Radio1

        Instance.new("UICorner", Radio1Inner).CornerRadius = UDim.new(1, 0)

        local Option1Text = Instance.new("TextLabel")
        Option1Text.Size = UDim2.new(1, -60, 1, 0)
        Option1Text.Position = UDim2.new(0, 50, 0, 0)
        Option1Text.BackgroundTransparency = 1
        Option1Text.Text = "启用反作弊绕过"
        Option1Text.TextColor3 = Color3.fromRGB(255, 255, 255)
        Option1Text.TextSize = 16
        Option1Text.Font = Enum.Font.GothamBold
        Option1Text.TextXAlignment = Enum.TextXAlignment.Left
        Option1Text.Parent = Option1Frame

        local Option1Desc = Instance.new("TextLabel")
        Option1Desc.Size = UDim2.new(1, -60, 0, 20)
        Option1Desc.Position = UDim2.new(0, 50, 0.5, 5)
        Option1Desc.BackgroundTransparency = 1
        Option1Desc.Text = "推荐：加载主脚本后启动绕过模块"
        Option1Desc.TextColor3 = Color3.fromRGB(120, 120, 130)
        Option1Desc.TextSize = 12
        Option1Desc.Font = Enum.Font.Gotham
        Option1Desc.TextXAlignment = Enum.TextXAlignment.Left
        Option1Desc.Parent = Option1Frame

        local Option1Button = Instance.new("TextButton")
        Option1Button.Size = UDim2.new(1, 0, 1, 0)
        Option1Button.BackgroundTransparency = 1
        Option1Button.Text = ""
        Option1Button.Parent = Option1Frame

        local Option2Frame = Instance.new("Frame")
        Option2Frame.Name = "DisableBypass"
        Option2Frame.Size = UDim2.new(1, 0, 0, 60)
        Option2Frame.Position = UDim2.new(0, 0, 0, 75)
        Option2Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Option2Frame.BorderSizePixel = 0
        Option2Frame.Parent = OptionsContainer

        Instance.new("UICorner", Option2Frame).CornerRadius = UDim.new(0, 12)

        local Option2Stroke = Instance.new("UIStroke")
        Option2Stroke.Color = Color3.fromRGB(60, 60, 75)
        Option2Stroke.Thickness = 2
        Option2Stroke.Parent = Option2Frame

        local Radio2 = Instance.new("Frame")
        Radio2.Size = UDim2.new(0, 24, 0, 24)
        Radio2.Position = UDim2.new(0, 15, 0.5, -12)
        Radio2.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        Radio2.BorderSizePixel = 0
        Radio2.Parent = Option2Frame

        Instance.new("UICorner", Radio2).CornerRadius = UDim.new(1, 0)

        local Radio2Inner = Instance.new("Frame")
        Radio2Inner.Size = UDim2.new(0, 12, 0, 12)
        Radio2Inner.Position = UDim2.new(0.5, -6, 0.5, -6)
        Radio2Inner.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Radio2Inner.BorderSizePixel = 0
        Radio2Inner.Visible = not Config.EnableBypass
        Radio2Inner.Parent = Radio2

        Instance.new("UICorner", Radio2Inner).CornerRadius = UDim.new(1, 0)

        local Option2Text = Instance.new("TextLabel")
        Option2Text.Size = UDim2.new(1, -60, 1, 0)
        Option2Text.Position = UDim2.new(0, 50, 0, 0)
        Option2Text.BackgroundTransparency = 1
        Option2Text.Text = "不启用反作弊绕过"
        Option2Text.TextColor3 = Color3.fromRGB(255, 255, 255)
        Option2Text.TextSize = 16
        Option2Text.Font = Enum.Font.GothamBold
        Option2Text.TextXAlignment = Enum.TextXAlignment.Left
        Option2Text.Parent = Option2Frame

        local Option2Desc = Instance.new("TextLabel")
        Option2Desc.Size = UDim2.new(1, -60, 0, 20)
        Option2Desc.Position = UDim2.new(0, 50, 0.5, 5)
        Option2Desc.BackgroundTransparency = 1
        Option2Desc.Text = "直接启动tubers93脚本"
        Option2Desc.TextColor3 = Color3.fromRGB(120, 120, 130)
        Option2Desc.TextSize = 12
        Option2Desc.Font = Enum.Font.Gotham
        Option2Desc.TextXAlignment = Enum.TextXAlignment.Left
        Option2Desc.Parent = Option2Frame

        local Option2Button = Instance.new("TextButton")
        Option2Button.Size = UDim2.new(1, 0, 1, 0)
        Option2Button.BackgroundTransparency = 1
        Option2Button.Text = ""
        Option2Button.Parent = Option2Frame

        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Size = UDim2.new(1, -40, 0, 20)
        StatusLabel.Position = UDim2.new(0, 20, 0, 235)
        StatusLabel.BackgroundTransparency = 1
        if SUPPORT_FILE_IO then
            StatusLabel.Text = "配置自动保存已启用"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        else
            StatusLabel.Text = "当前注入器不支持文件保存"
            StatusLabel.TextColor3 = Color3.fromRGB(200, 150, 100)
        end
        StatusLabel.TextSize = 12
        StatusLabel.Font = Enum.Font.Gotham
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
        StatusLabel.Parent = MainFrame

        local EnterButton = Instance.new("TextButton")
        EnterButton.Size = UDim2.new(1, -40, 0, 50)
        EnterButton.Position = UDim2.new(0, 20, 0, 265)
        EnterButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        EnterButton.Text = "进入主脚本"
        EnterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        EnterButton.TextSize = 18
        EnterButton.Font = Enum.Font.GothamBold
        EnterButton.Parent = MainFrame

        Instance.new("UICorner", EnterButton).CornerRadius = UDim.new(0, 12)

        local EnterGradient = Instance.new("UIGradient")
        EnterGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 255))
        })
        EnterGradient.Rotation = 90
        EnterGradient.Parent = EnterButton

        local function SaveConfig()
            if not SUPPORT_FILE_IO then return end
            pcall(function()
                writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
            end)
        end

        local function UpdateSelection()
            if Config.EnableBypass then
                Radio1Inner.Visible = true
                Radio2Inner.Visible = false
                Option1Stroke.Color = Color3.fromRGB(0, 170, 255)
                Option2Stroke.Color = Color3.fromRGB(60, 60, 75)
                Option1Frame.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
                Option2Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            else
                Radio1Inner.Visible = false
                Radio2Inner.Visible = true
                Option1Stroke.Color = Color3.fromRGB(60, 60, 75)
                Option2Stroke.Color = Color3.fromRGB(0, 170, 255)
                Option1Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                Option2Frame.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
            end
            SaveConfig()
        end

        UpdateSelection()

        Option1Button.MouseButton1Click:Connect(function()
            if not Config.EnableBypass then
                Config.EnableBypass = true
                UpdateSelection()
            end
        end)

        Option2Button.MouseButton1Click:Connect(function()
            if Config.EnableBypass then
                Config.EnableBypass = false
                UpdateSelection()
            end
        end)

        Option1Button.MouseEnter:Connect(function()
            if not Config.EnableBypass then
                TweenService:Create(Option1Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
            end
        end)

        Option1Button.MouseLeave:Connect(function()
            if not Config.EnableBypass then
                TweenService:Create(Option1Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end
        end)

        Option2Button.MouseEnter:Connect(function()
            if Config.EnableBypass then
                TweenService:Create(Option2Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
            end
        end)

        Option2Button.MouseLeave:Connect(function()
            if Config.EnableBypass then
                TweenService:Create(Option2Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end
        end)

        local Dragging = false
        local DragStart = nil
        local StartPos = nil

        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPos = MainFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - DragStart
                MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end)

        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

        EnterButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
            
            if Config.EnableBypass then
            _G.YourVariableName = true
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Wbw1470619303-ctrl/wbwhnb/refs/heads/main/tubers93%E6%B7%B7%E6%B7%86.lua"))()
            else
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Wbw1470619303-ctrl/wbwhnb/refs/heads/main/tubers93%E6%B7%B7%E6%B7%86.lua"))()             
                end)
            end
        end)

        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)}):Play()

        task.wait(0.2)
        Option1Frame.Position = UDim2.new(-1, 0, 0, 0)
        Option2Frame.Position = UDim2.new(-1, 0, 0, 75)
        TweenService:Create(Option1Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.1)
        TweenService:Create(Option2Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 75)}):Play()

        local function UpdateScale()
            local viewport = Camera.ViewportSize
            local scale = math.min(1, math.min(viewport.X / (BASE_WIDTH + 40), viewport.Y / (BASE_HEIGHT + 40)))
            UIScale.Scale = scale
        end

        UpdateScale()
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
    end

    local function BS_safeEntry()
        if not BS_probeArith() then return nil, "block:arith" end
        if not BS_probeCall()  then return nil, "block:call"  end
        if not BS_probeFS()    then return nil, "block:fs"    end
        return BS_coreLogic()
    end

    local BS_success, BS_tag = BS_safeEntry()
    if not BS_success then
        return
    end
end, ...)