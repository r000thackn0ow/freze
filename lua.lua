local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Setup RemoteEvents
local jumpscareEvent = ReplicatedStorage:FindFirstChild("JumpscareEvent")
if not jumpscareEvent then
    jumpscareEvent = Instance.new("RemoteEvent")
    jumpscareEvent.Name = "JumpscareEvent"
    jumpscareEvent.Parent = ReplicatedStorage
end

local freezeEvent = ReplicatedStorage:FindFirstChild("FreezePlayerEvent")
if not freezeEvent then
    freezeEvent = Instance.new("RemoteEvent")
    freezeEvent.Name = "FreezePlayerEvent"
    freezeEvent.Parent = ReplicatedStorage
end

-- Track frozen players
local frozenPlayers = {}

-- Inject LocalScripts ke semua player (jumpscare + freeze listener)
for _, player in pairs(Players:GetPlayers()) do
    if player:FindFirstChild("PlayerGui") then
        if not player.PlayerGui:FindFirstChild("JumpscareListener") then
            local listener = Instance.new("LocalScript")
            listener.Name = "JumpscareListener"
            listener.Source = [[
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local JumpscareEvent = ReplicatedStorage:WaitForChild("JumpscareEvent")
                local FreezeEvent = ReplicatedStorage:WaitForChild("FreezePlayerEvent")
                local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                local UserInputService = game:GetService("UserInputService")
                local RunService = game:GetService("RunService")
                local frozen = false

                -- Jumpscare handler
                JumpscareEvent.OnClientEvent:Connect(function()
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Color3.new(1, 0, 0)
                    frame.ZIndex = 1000
                    frame.Parent = playerGui

                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = "BOO!!!"
                    text.TextColor3 = Color3.new(1, 1, 1)
                    text.TextScaled = true
                    text.Font = Enum.Font.GothamBlack
                    text.Parent = frame

                    local sound = Instance.new("Sound", frame)
                    sound.SoundId = "rbxassetid://183763515"
                    sound.Volume = 1
                    sound:Play()

                    wait(2)
                    frame:Destroy()
                end)

                -- Freeze movement handler
                FreezeEvent.OnClientEvent:Connect(function(freeze)
                    frozen = freeze
                end)

                -- Disable WASD and movement if frozen
                RunService.RenderStepped:Connect(function()
                    if frozen then
                        -- Lock mouse and hide cursor
                        UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
                        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                    else
                        UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    end
                end)

                -- Block all keyboard input if frozen
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if frozen and not gameProcessed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            -- Block key
                        end
                    end
                end)
                UserInputService.InputChanged:Connect(function(input, gameProcessed)
                    if frozen and not gameProcessed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            -- Block key changes
                        end
                    end
                end)
            ]]
            listener.Parent = player.PlayerGui
        end
    end
end

-- Fungsi freeze/unfreeze player by name
local function setFreezeByName(name, freeze)
    local target = Players:FindFirstChild(name)
    if target then
        frozenPlayers[name] = freeze and true or nil
        freezeEvent:FireClient(target, freeze)
    end
end

-- Buat GUI admin di player kamu
local function createAdminGui(player)
    local playerGui = player:WaitForChild("PlayerGui")

    if playerGui:FindFirstChild("AdminFreezeGui") then
        playerGui.AdminFreezeGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminFreezeGui"
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 140)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = screenGui

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, -20, 0, 50)
    textbox.Position = UDim2.new(0, 10, 0, 10)
    textbox.PlaceholderText = "Masukkan nama player"
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame

    local freezeButton = Instance.new("TextButton")
    freezeButton.Size = UDim2.new(1, -20, 0, 40)
    freezeButton.Position = UDim2.new(0, 10, 0, 70)
    freezeButton.Text = "Freeze Player"
    freezeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    freezeButton.TextColor3 = Color3.new(1,1,1)
    freezeButton.Parent = frame

    local unfreezeButton = Instance.new("TextButton")
    unfreezeButton.Size = UDim2.new(1, -20, 0, 40)
    unfreezeButton.Position = UDim2.new(0, 10, 0, 110)
    unfreezeButton.Text = "Unfreeze Player"
    unfreezeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    unfreezeButton.TextColor3 = Color3.new(1,1,1)
    unfreezeButton.Parent = frame

    freezeButton.MouseButton1Click:Connect(function()
        local targetName = textbox.Text
        if targetName ~= "" then
            setFreezeByName(targetName, true) -- Freeze permanen
        end
    end)

    unfreezeButton.MouseButton1Click:Connect(function()
        local targetName = textbox.Text
        if targetName ~= "" then
            setFreezeByName(targetName, false) -- Unfreeze
        end
    end)
end

-- Buat GUI untuk player pertama (misal admin kamu)
local me = Players.LocalPlayer or Players:GetPlayers()[1]
if me and me:FindFirstChild("PlayerGui") then
    createAdminGui(me)
end
