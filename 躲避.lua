local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Confirmed = false

WindUI:Popup({
    Title = "DEBRIS ORBIT V2",
    IconThemed = true,
    Content = "欢迎尊贵的用户" .. game.Players.LocalPlayer.Name .. "使用DEBRIS ORBIT 当前版本型号:V2",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                Confirmed = true
                createUI()
            end,
            Variant = "Primary",
        }
    }
})
function createUI()
    local Window = WindUI:CreateWindow({
        Title = "DEBRIS ORBIT",
        Icon = "palette",
    Author = "尊贵的"..game.Players.localPlayer.Name.."欢迎使用DEBRIS ORBIT", 
        Folder = "Premium",
        Size = UDim2.fromOffset(550, 320),
        Theme = "Light",
        User = {
            Enabled = true,
            Anonymous = true,
            Callback = function()
            end
        },
        SideBarWidth = 200,
        HideSearchBar = false,  
    })

    Window:Tag({
        Title = "躲避",
        Color = Color3.fromHex("#00ffff") 
    })

    Window:EditOpenButton({
    Title = "DEBRIS ORBIT V1",
    Icon = "crown",
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 3,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#FF0000")),
        ColorSequenceKeypoint.new(0.2, Color3.fromHex("#FFA500")),
        ColorSequenceKeypoint.new(0.4, Color3.fromHex("#FFFF00")),
        ColorSequenceKeypoint.new(0.6, Color3.fromHex("#00FF00")),
        ColorSequenceKeypoint.new(0.65, Color3.fromHex("#00FFFF")),
        ColorSequenceKeypoint.new(0.8, Color3.fromHex("#0000FF")),
        ColorSequenceKeypoint.new(0.9, Color3.fromHex("#8A2BE2")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#FFFFFF"))
    }),
    Draggable = true,
})
local Main = Window:Tab({Title = "主要", Icon = "settings"})
local ActiveAutoWin = false
local ActiveAutoFarmMoney = false
local AutoFarmSummerEvent = false

Main:Toggle({
    Title = "自动获胜",
    Default = false,
    Callback = function(state)
        ActiveAutoWin = state
        if ActiveAutoWin then
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动获胜已开启",
                Duration = 4
            })
            
            spawn(function()
                while ActiveAutoWin do
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if character and rootPart then
                        if character:GetAttribute("Downed") then
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                            task.wait(0.5)
                        end

                        if not character:GetAttribute("Downed") then
                            local securityPart = Instance.new("Part")
                            securityPart.Name = "SecurityPartTemp"
                            securityPart.Size = Vector3.new(10, 1, 10)
                            securityPart.Position = Vector3.new(0, 500, 0)
                            securityPart.Anchored = true
                            securityPart.Transparency = 1
                            securityPart.CanCollide = true
                            securityPart.Parent = Workspace

                            rootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                            securityPart:Destroy()
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动获胜已关闭",
                Duration = 4
            })
        end
    end
})
Main:Toggle({
    Title = "自动刷钱",
    Default = false,
    Callback = function(state)
        ActiveAutoFarmMoney = state
        if ActiveAutoFarmMoney then
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动刷钱已开启",
                Duration = 4
            })
            
            spawn(function()
                while ActiveAutoFarmMoney do
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if character and rootPart then
                        if character:GetAttribute("Downed") then
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                            task.wait(0.5)
                        end

                        local downedPlayerFound = false
                        local playersInGame = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
                        if playersInGame then
                            for _, v in pairs(playersInGame:GetChildren()) do
                                if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:GetAttribute("Downed") then
                                    rootPart.CFrame = v.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                    ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, v)
                                    task.wait(0.5)
                                    downedPlayerFound = true
                                    break
                                end
                            end
                        end

                        if not downedPlayerFound then
                            -- 如果没有找到倒地的玩家，等待
                        end

                        local securityPart = Instance.new("Part")
                        securityPart.Name = "SecurityPartTemp"
                        securityPart.Size = Vector3.new(10, 1, 10)
                        securityPart.Position = Vector3.new(0, 500, 0)
                        securityPart.Anchored = true
                        securityPart.Transparency = 1
                        securityPart.CanCollide = true
                        securityPart.Parent = Workspace
                        rootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)

                    else
                    
                    end
                    task.wait(1)
                end
            end)
        else
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动刷钱已关闭",
                Duration = 4
            })
        end
    end
})

local Main = Window:Tab({Title = "投票", Icon = "settings"})

Main:Section({Title = "投票功能"})

local selectedMapNumber = 1
local autoVoteEnabled = false
local voteConnection = nil

local function fireVoteServer(selectedMapNumber)
    local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
    if eventsFolder then
        local playerFolder = eventsFolder:WaitForChild("Player", 10)
        if playerFolder then
            local voteEvent = playerFolder:WaitForChild("Vote", 10)
            if voteEvent and typeof(voteEvent) == "Instance" and voteEvent:IsA("RemoteEvent") then
                local args = {
                    [1] = selectedMapNumber
                }
                voteEvent:FireServer(unpack(args))
            end
        end
    end
end

Main:Dropdown({
    Title = "选择地图",
    Values = {"地图 1", "地图 2", "地图 3", "地图 4"},
    Default = "地图 1",
    Callback = function(value)
        if value == "地图 1" then
            selectedMapNumber = 1
        elseif value == "地图 2" then
            selectedMapNumber = 2
        elseif value == "地图 3" then
            selectedMapNumber = 3
        elseif value == "地图 4" then
            selectedMapNumber = 4
        end
        WindUI:Notify({
            Title = "提示提示",
            Content = "已选择: " .. value,
            Duration = 4
        })
    end
})

Main:Button({
    Title = "投票",
    Callback = function()
        fireVoteServer(selectedMapNumber)
        WindUI:Notify({
            Title = "提示提示",
            Content = "已投票给地图 " .. selectedMapNumber,
            Duration = 4
        })
    end
})

Main:Toggle({
    Title = "自动投票",
    Default = false,
    Callback = function(state)
        autoVoteEnabled = state
        if autoVoteEnabled then
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动投票已开启",
                Duration = 4
            })
            
            if not voteConnection then
                voteConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    fireVoteServer(selectedMapNumber)
                end)
            end
        else
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动投票已关闭",
                Duration = 4
            })
            
            if voteConnection then
                voteConnection:Disconnect()
                voteConnection = nil
            end
        end
    end
})

local Main = Window:Tab({Title = "复活", Icon = "settings"})

Main:Section({Title = "复活功能"})
local autoReviveEnabled = false
local lastCheckTime = 0
local checkInterval = 5

Main:Button({
    Title = "复活自己",
    Callback = function()
        local player = LocalPlayer
        local character = player.Character
        if character and character:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            WindUI:Notify({
                Title = "提示提示",
                Content = "✅已复活!",
                Duration = 4
            })
        else
            WindUI:Notify({
                Title = "提示提示",
                Content = "你还没有倒地!",
                Duration = 4
            })
        end
    end
})

Main:Toggle({
    Title = "自动复活自己",
    Default = false,
    Callback = function(state)
        autoReviveEnabled = state
        if autoReviveEnabled then
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动复活已开启",
                Duration = 4
            })
        else
            WindUI:Notify({
                Title = "提示提示",
                Content = "自动复活已关闭",
                Duration = 4
            })
        end
    end
})
game:GetService("RunService").Heartbeat:Connect(function()
    if autoReviveEnabled then
        if tick() - lastCheckTime >= checkInterval then
            lastCheckTime = tick()
            local player = LocalPlayer
            local character = player.Character
            if character and character:GetAttribute("Downed") then
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end
    end
end)
end
