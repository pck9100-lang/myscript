-- โหลด Rayfield UI Library แบบปลอดภัย
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("ไม่สามารถโหลด Rayfield UI ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือตัวรันของคุณ")
    return
end

-- สร้างหน้าต่างหลัก (Window) พร้อมระบบบันทึกตั้งค่า
local Window = Rayfield:CreateWindow({
   Name = "⚡ของบักปอน⚡🫵🐃",
   LoadingTitle = "Pon Hub",
   LoadingSubtitle = "by บักปอน",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PonHubConfig",
      FileName = "PonHubSettings"
   },
   KeySystem = false
})

-- สร้าง Tabs
local MainTab = Window:CreateTab("🏠 หน้าหลัก", 4483362458)
local VisualTab = Window:CreateTab("👁️ ESP & ภาพ", 4483362458)
local SettingsTab = Window:CreateTab("⚙ ตั้งค่า", 4483362458)

-- ================= ตัวแปรระบบ =================
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- ================= TAB หน้าหลัก =================

MainTab:CreateSection("🎒 ระบบคัดลอก/ดูปไอเทม (Dupe Tool)")

-- ฟังก์ชันดูปไอเทมคัดลอกทุกอย่างรวมถึงอนิเมชั่น
MainTab:CreateButton({
   Name = "📦 กดเพื่อดูปไอเทมที่ถืออยู่ (Dupe Held Item)",
   Callback = function()
      pcall(function()
          if not character then return end
          
          -- ค้นหา Tool ที่กำลังถือในตัวละคร
          local heldTool = character:FindFirstChildOfClass("Tool")
          
          if not heldTool then
              Rayfield:Notify({
                  Title = "⚡ของบักปอน⚡",
                  Content = "⚠️ กรุณาถือไอเทมในมือก่อนกดดูป!",
                  Duration = 2
              })
              return
          end

          -- ทำการคัดลอก (Clone) ไอเทมรวมถึง Children / Animations / Scripts ทั้งหมด
          local clonedTool = heldTool:Clone()
          
          -- ย้ายไอเทมที่คัดลอกไปยัง Backpack ของผู้เล่น
          clonedTool.Parent = player:WaitForChild("Backpack")
          
          Rayfield:Notify({
              Title = "⚡ของบักปอน⚡",
              Content = "✅ ดูปไอเทม '" .. heldTool.Name .. "' พร้อมอนิเมชั่นลงกระเป๋าแล้ว!",
              Duration = 2.5
          })
      end)
   end,
})

MainTab:CreateSection("⚡ ระบบเคลื่อนไหว (Movement)")

-- 1. WalkSpeed
local speedValue = 50
local speedEnabled = false

MainTab:CreateToggle({
   Name = "เปิด/ปิด เพิ่มความเร็วเดิน",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      speedEnabled = Value
   end,
})

MainTab:CreateInput({
   Name = "ปรับความเร็วเดิน",
   PlaceholderText = "50",
   RemoveTextAfterFocusLost = false,
   Flag = "SpeedInputValue",
   Callback = function(Text)
      local num = tonumber(Text)
      if num then speedValue = num end
   end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if speedEnabled and humanoid then
            pcall(function()
                humanoid.WalkSpeed = speedValue
            end)
        end
    end
end)

-- 2. Inf Jump
local infJumpEnabled = false
MainTab:CreateToggle({
   Name = "กระโดดไม่จำกัด",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      infJumpEnabled = Value
   end,
})

uis.JumpRequest:Connect(function()
    if infJumpEnabled and humanoid then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- 3. JumpPower
local jumpPowerValue = 100
local jumpPowerEnabled = false

MainTab:CreateToggle({
   Name = "เปิด/ปิด กระโดดสูง",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value)
      jumpPowerEnabled = Value
   end,
})

MainTab:CreateInput({
   Name = "ปรับความสูงกระโดด",
   PlaceholderText = "100",
   RemoveTextAfterFocusLost = false,
   Flag = "JumpInputvalue",
   Callback = function(Text)
      local num = tonumber(Text)
      if num then jumpPowerValue = num end
   end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if jumpPowerEnabled and humanoid then
            pcall(function()
                if humanoid.UseJumpPower then
                    humanoid.JumpPower = jumpPowerValue
                else
                    humanoid.JumpHeight = jumpPowerValue / 3
                end
            end)
        end
    end
end)

-- 4. Slow Fall
local slowFallEnabled = false
local bodyVelocity = nil

MainTab:CreateToggle({
   Name = "ลอยตัวตกช้าๆ",
   CurrentValue = false,
   Flag = "SlowFall",
   Callback = function(Value)
      slowFallEnabled = Value
      if not Value and bodyVelocity then
          bodyVelocity:Destroy()
          bodyVelocity = nil
      end
   end,
})

task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            if hrp and humanoid then
                if slowFallEnabled then
                    if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                        if not hrp:FindFirstChild("SmoothSlowFall") then
                            bodyVelocity = Instance.new("BodyVelocity")
                            bodyVelocity.Name = "SmoothSlowFall"
                            bodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
                            bodyVelocity.Velocity = Vector3.new(0, -12, 0)
                            bodyVelocity.Parent = hrp
                        end
                    else
                        if hrp:FindFirstChild("SmoothSlowFall") then
                            hrp.SmoothSlowFall:Destroy()
                        end
                    end
                else
                    if hrp:FindFirstChild("SmoothSlowFall") then
                        hrp.SmoothSlowFall:Destroy()
                        bodyVelocity = nil
                    end
                end
            end
        end)
    end
end)

-- 5. Noclip
local noclipEnabled = false
MainTab:CreateToggle({
   Name = "เดินทะลุกำแพง",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
      noclipEnabled = Value
   end,
})

runService.Stepped:Connect(function()
    if noclipEnabled and character then
        pcall(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- ================= ระบบ Pon Hub =================
MainTab:CreateSection("✈ มุดดินขึ้นลง (Pon Hub)")

local ponDepthEnabled = false
local ponStep = 73
local ponCompactPanel = nil

local savedCFrame = nil
local savedPartMarker = nil
local savedBillboard = nil

local function togglePonCompactPanel(state)
    if state then
        if not ponCompactPanel then
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "PonHubCompactPanel"
            screenGui.ResetOnSpawn = false
            
            if gethui then
                screenGui.Parent = gethui()
            else
                screenGui.Parent = game:GetService("CoreGui")
            end
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 210, 0, 185)
            frame.Position = UDim2.new(0.8, -105, 0.2, 0)
            frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            frame.BorderSizePixel = 0
            frame.Active = true
            frame.Draggable = true
            frame.ClipsDescendants = true
            frame.Parent = screenGui
            
            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 8)
            uiCorner.Parent = frame
            
            local bgImage = Instance.new("ImageLabel")
            bgImage.Size = UDim2.new(1, 0, 1, 0)
            bgImage.BackgroundTransparency = 1
            bgImage.Image = "rbxassetid://107242277494498"
            bgImage.ScaleType = Enum.ScaleType.Crop
            bgImage.ImageTransparency = 0.3
            bgImage.Parent = frame

            local darkOverlay = Instance.new("Frame")
            darkOverlay.Size = UDim2.new(1, 0, 1, 0)
            darkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            darkOverlay.BackgroundTransparency = 0.45
            darkOverlay.Parent = frame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -35, 0, 30)
            title.Position = UDim2.new(0, 10, 0, 4)
            title.BackgroundTransparency = 1
            title.Text = "Pon Hub"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.FredokaOne
            title.TextSize = 20
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = frame

            local minimizedBar = Instance.new("TextButton")
            minimizedBar.Size = UDim2.new(0, 120, 0, 32)
            minimizedBar.Position = frame.Position
            minimizedBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            minimizedBar.TextColor3 = Color3.fromRGB(255, 255, 255)
            minimizedBar.Font = Enum.Font.FredokaOne
            minimizedBar.TextSize = 14
            minimizedBar.Text = "➕ Pon Hub"
            minimizedBar.Visible = false
            minimizedBar.Active = true
            minimizedBar.Draggable = true
            Instance.new("UICorner", minimizedBar).CornerRadius = UDim.new(0, 8)
            minimizedBar.Parent = screenGui

            local btnMinimize = Instance.new("TextButton")
            btnMinimize.Size = UDim2.new(0, 26, 0, 26)
            btnMinimize.Position = UDim2.new(1, -30, 0, 6)
            btnMinimize.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            btnMinimize.Text = "-"
            btnMinimize.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnMinimize.Font = Enum.Font.GothamBold
            btnMinimize.TextSize = 16
            Instance.new("UICorner", btnMinimize).CornerRadius = UDim.new(0, 6)
            btnMinimize.Parent = frame

            btnMinimize.MouseButton1Click:Connect(function()
                minimizedBar.Position = frame.Position
                frame.Visible = false
                minimizedBar.Visible = true
            end)

            minimizedBar.MouseButton1Click:Connect(function()
                frame.Position = minimizedBar.Position
                frame.Visible = true
                minimizedBar.Visible = false
            end)

            local btnUnder = Instance.new("TextButton")
            btnUnder.Size = UDim2.new(0.43, 0, 0, 26)
            btnUnder.Position = UDim2.new(0.05, 0, 0, 38)
            btnUnder.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            btnUnder.Text = "➕ มุดลง"
            btnUnder.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnUnder.Font = Enum.Font.GothamBold
            btnUnder.TextSize = 12
            Instance.new("UICorner", btnUnder).CornerRadius = UDim.new(0, 6)
            btnUnder.Parent = frame
            
            btnUnder.MouseButton1Click:Connect(function()
                if hrp then
                    hrp.CFrame = hrp.CFrame - Vector3.new(0, ponStep, 0)
                end
            end)
            
            local btnSky = Instance.new("TextButton")
            btnSky.Size = UDim2.new(0.43, 0, 0, 26)
            btnSky.Position = UDim2.new(0.52, 0, 0, 38)
            btnSky.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            btnSky.Text = "➕ ลอยฟ้า"
            btnSky.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnSky.Font = Enum.Font.GothamBold
            btnSky.TextSize = 12
            Instance.new("UICorner", btnSky).CornerRadius = UDim.new(0, 6)
            btnSky.Parent = frame
            
            btnSky.MouseButton1Click:Connect(function()
                if hrp then
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, ponStep, 0)
                end
            end)

            local depthLabel = Instance.new("TextLabel")
            depthLabel.Size = UDim2.new(0.9, 0, 0, 18)
            depthLabel.Position = UDim2.new(0.05, 0, 0, 70)
            depthLabel.BackgroundTransparency = 1
            depthLabel.Text = "ระยะความลึก: " .. ponStep
            depthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            depthLabel.Font = Enum.Font.GothamBold
            depthLabel.TextSize = 13
            depthLabel.TextXAlignment = Enum.TextXAlignment.Left
            depthLabel.Parent = frame

            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(0.9, 0, 0, 28)
            sliderBg.Position = UDim2.new(0.05, 0, 0, 92)
            sliderBg.BackgroundColor3 = Color3.fromRGB(230, 190, 60)
            sliderBg.BorderSizePixel = 0
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 14)
            sliderBg.Parent = frame

            local sliderKnob = Instance.new("TextButton")
            sliderKnob.Size = UDim2.new(0, 28, 0, 28)
            sliderKnob.Position = UDim2.new(0, 0, 0, 0)
            sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderKnob.Text = tostring(ponStep)
            sliderKnob.TextColor3 = Color3.fromRGB(0, 0, 0)
            sliderKnob.Font = Enum.Font.GothamBold
            sliderKnob.TextSize = 11
            Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(0, 14)
            sliderKnob.Parent = sliderBg

            local dragging = false
            sliderKnob.MouseButton1Down:Connect(function() dragging = true end)
            uis.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            uis.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = input.Position.X
                    local bgPos = sliderBg.AbsolutePosition.X
                    local bgSize = sliderBg.AbsoluteSize.X - sliderKnob.AbsoluteSize.X
                    local relX = math.clamp(mousePos - bgPos, 0, bgSize)
                    local percentage = relX / bgSize
                    
                    sliderKnob.Position = UDim2.new(percentage, 0, 0, 0)
                    ponStep = math.floor(percentage * 200)
                    sliderKnob.Text = tostring(ponStep)
                    depthLabel.Text = "ระยะความลึก: " .. ponStep
                end
            end)

            local btnSet = Instance.new("TextButton")
            btnSet.Size = UDim2.new(0.43, 0, 0, 26)
            btnSet.Position = UDim2.new(0.05, 0, 0, 130)
            btnSet.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
            btnSet.Text = "📌 บันทึกจุด"
            btnSet.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnSet.Font = Enum.Font.GothamBold
            btnSet.TextSize = 11
            Instance.new("UICorner", btnSet).CornerRadius = UDim.new(0, 6)
            btnSet.Parent = frame
            
            btnSet.MouseButton1Click:Connect(function()
                if hrp then
                    savedCFrame = hrp.CFrame
                    if savedPartMarker then savedPartMarker:Destroy() end
                    
                    savedPartMarker = Instance.new("Part")
                    savedPartMarker.Size = Vector3.new(1, 1, 1)
                    savedPartMarker.Position = hrp.Position
                    savedPartMarker.Anchored = true
                    savedPartMarker.Transparency = 1
                    savedPartMarker.CanCollide = false
                    savedPartMarker.Parent = workspace
                    
                    savedBillboard = Instance.new("BillboardGui")
                    savedBillboard.Size = UDim2.new(0, 150, 0, 40)
                    savedBillboard.StudsOffset = Vector3.new(0, 2, 0)
                    savedBillboard.AlwaysOnTop = true
                    savedBillboard.Parent = savedPartMarker
                    
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "📍 จุดที่บันทึกไว้"
                    txt.TextColor3 = Color3.fromRGB(0, 255, 128)
                    txt.TextStrokeTransparency = 0.3
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 12
                    txt.Parent = savedBillboard
                    
                    Rayfield:Notify({Title = "⚡ของบักปอน⚡", Content = "บันทึกจุดเรียบร้อย!", Duration = 1.5})
                end
            end)

            local btnTp = Instance.new("TextButton")
            btnTp.Size = UDim2.new(0.43, 0, 0, 26)
            btnTp.Position = UDim2.new(0.52, 0, 0, 130)
            btnTp.BackgroundColor3 = Color3.fromRGB(220, 130, 40)
            btnTp.Text = "⚡ วาร์ปไปจุดที่เซฟ"
            btnTp.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnTp.Font = Enum.Font.GothamBold
            btnTp.TextSize = 11
            Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 6)
            btnTp.Parent = frame
            
            btnTp.MouseButton1Click:Connect(function()
                if savedCFrame and hrp then
                    hrp.CFrame = savedCFrame
                    Rayfield:Notify({Title = "⚡ของบักปอน⚡", Content = "วาร์ปกลับจุดที่เซฟแล้ว!", Duration = 1.5})
                else
                    Rayfield:Notify({Title = "⚡ของบักปอน⚡", Content = "ยังไม่ได้บันทึกจุด!", Duration = 1.5})
                end
            end)
            
            ponCompactPanel = screenGui
        else
            ponCompactPanel.Enabled = true
            local frame = ponCompactPanel:FindFirstChildOfClass("Frame")
            if frame then frame.Visible = true end
        end
    else
        if ponCompactPanel then
            ponCompactPanel.Enabled = false
        end
    end
end

MainTab:CreateToggle({
   Name = "เปิดแผงควบคุมมุดดิน",
   CurrentValue = false,
   Flag = "PonDepthToggle",
   Callback = function(Value)
      ponDepthEnabled = Value
      togglePonCompactPanel(Value)
   end,
})


-- ================= TAB ESP & ภาพ =================

VisualTab:CreateSection("👁 ระบบมองทะลุกำแพง (ESP)")

-- 1. Player ESP
local playerEspEnabled = false
VisualTab:CreateToggle({
   Name = "มองชื่อผู้เล่น",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(Value)
      playerEspEnabled = Value
      if not Value then
          for _, p in ipairs(game.Players:GetPlayers()) do
              if p.Character and p.Character:FindFirstChild("Head") then
                  if p.Character.Head:FindFirstChild("RainbowPlayerESP") then
                      p.Character.Head.RainbowPlayerESP:Destroy()
                  end
              end
          end
      end
   end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if playerEspEnabled then
            pcall(function()
                local hue = (tick() % 5) / 5
                local rainbowCol = Color3.fromHSV(hue, 1, 1)
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                        local head = p.Character.Head
                        local billboard = head:FindFirstChild("RainbowPlayerESP")
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "RainbowPlayerES
