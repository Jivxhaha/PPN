local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoLevel_Enabled = _G.AutoLevel_Enabled or false
local AutoLevel = _G.AutoLevel or function() end

local AutoRebirth_Active = false
local AutoRebirth_Enabled = false
local WasAutoLevelRunning = false
local AUTO_FIRE = false

local function fireProximity(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration)
        prompt:InputHoldEnd()
        return true
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1)
        
        local playerData = game:GetService("Players").LocalPlayer.Data
        local levelValue = playerData.Level.Value
        
        if AUTO_FIRE and levelValue == 999 and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local part = prompt.Parent
                        if part:IsA("BasePart") then
                            local distance = (part.Position - hrp.Position).Magnitude
                            if distance <= 15 then
                                fireProximity(prompt)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function AutoRebirth(state)
    AutoRebirth_Enabled = state
    
    if AutoRebirth_Enabled then
        if not AutoRebirth_Active then
            AutoRebirth_Active = true
            spawn(function()
                while AutoRebirth_Enabled do
                    local playerData = game:GetService("Players").LocalPlayer.Data
                    local levelValue = playerData.Level.Value
                    
                    if levelValue >= 999 and AutoRebirth_Enabled then
                        
                        WasAutoLevelRunning = AutoLevel_Enabled
                        
                        if AutoLevel_Enabled then
                            AutoLevel(false)
                            wait(1)
                        end
                        
                        local character = LocalPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local trainer = workspace.Game.Trainers:FindFirstChild("🍄")
                            if trainer then
                                local interactionPart = nil
                                
                                if trainer:IsA("Model") then
                                    interactionPart = trainer.PrimaryPart or trainer:FindFirstChildWhichIsA("BasePart")
                                elseif trainer:IsA("BasePart") then
                                    interactionPart = trainer
                                end
                                
                                if interactionPart then
                                    character.HumanoidRootPart.CFrame = interactionPart.CFrame + Vector3.new(0, 3, 0)
                                    wait(1)
                                    
                                    AUTO_FIRE = true
                                    
                                    local maxWaitTime = 15
                                    local waitTime = 0
                                    local rebirthSuccess = false
                                    
                                    while waitTime < maxWaitTime and AutoRebirth_Enabled do
                                        local currentLevel = playerData.Level.Value
                                        if currentLevel == 0 then
                                            rebirthSuccess = true
                                            
                                            wait(3)
                                            
                                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                                            if humanoid then
                                                humanoid.Health = 0
                                            end
                                            
                                            local characterAddedConnection
                                            characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
                                                characterAddedConnection:Disconnect()
                                                wait(3)
                                                
                                                AUTO_FIRE = false
                                                
                                                if WasAutoLevelRunning and AutoRebirth_Enabled then
                                                    AutoLevel(true)
                                                end
                                            end)
                                            
                                            break
                                        end
                                        wait(1)
                                        waitTime = waitTime + 1
                                    end
                                    
                                    if not rebirthSuccess then
                                        AUTO_FIRE = false
                                        
                                        if WasAutoLevelRunning and AutoRebirth_Enabled then
                                            AutoLevel(true)
                                        end
                                    end
                                else
                                    AUTO_FIRE = false
                                end
                            else
                                AUTO_FIRE = false
                            end
                        else
                            AUTO_FIRE = false
                        end
                    else
                        if AutoRebirth_Enabled then
                            local currentLevel = playerData.Level.Value
                            if currentLevel % 100 == 0 then
                                -- Do nothing
                            end
                        end
                    end
                    
                    if AutoRebirth_Enabled then
                        wait(5)
                    end
                end
                
                AUTO_FIRE = false
                AutoRebirth_Active = false
            end)
        end
    else
        AutoRebirth_Active = false
        AUTO_FIRE = false
    end
    
    return AutoRebirth_Enabled
end

return AutoRebirth
