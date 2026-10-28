local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if _G.InfiniteStaminaRunning then return end
_G.InfiniteStaminaRunning = true

task.spawn(function()
    local success, sprintModule = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("Game", 5):WaitForChild("Sprint", 5))
    end)
    
    if success and sprintModule then
        pcall(function()
            local consumeStamina = sprintModule.consume_stamina
            local upvalues = getupvalues(consumeStamina)
            for _, v in pairs(upvalues) do
                if type(v) == "table" and rawget(v, "sprint_bar") then
                    local sprintBar = v.sprint_bar
                    if sprintBar and sprintBar.update then
                        local originalUpdate = sprintBar.update
                        sprintBar.update = function(...)
                            return originalUpdate(function()
                                return 1 
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

print("Infinite Stamina Activated (No Teleport Bug)")
