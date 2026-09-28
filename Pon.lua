-- [[ SERVER TELEPORT GUI SCRIPT ]] --
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerTeleportGui"
ScreenGui.ResetOnSpawn = false

-- จัดการ Parent สำหรับ Executor
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- สร้างกรอบหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 210)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- หัวข้อ 🍀 SERVER TELEPORT 🍀
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🍀 SERVER TELEPORT 🍀"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

-- ฟังก์ชันสร้างปุ่มกดเลือกวาร์ป
local function createTeleportButton(parent, position, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 50)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- สีเขียว
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 16
    Button.Font = Enum.Font.SourceSansBold
    Button.Selectable = true
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- ระบบ Server Hop (ย้ายไปเซิร์ฟเวอร์อื่น)
local function HopServer()
    local PlaceId = game.PlaceId
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
end

-- ระบบ Server Solo (หาเซิร์ฟเวอร์คนน้อย/คนเดียว)
local function SoloServer()
    local PlaceId = game.PlaceId
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and result and result.data then
        local targetServer = nil
        local minPlayers = math.huge

        for _, server in ipairs(result.data) do
            if server.playing < minPlayers and server.id ~= game.JobId and server.playing > 0 then
                minPlayers = server.playing
                targetServer = server.id
            end
        end

        if targetServer then
            TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, LocalPlayer)
        else
            HopServer()
        end
    end
end

-- ปุ่มเลือก Server Hop
createTeleportButton(MainFrame, UDim2.new(0.05, 0, 0.20, 0), "Server Hop", function()
    HopServer()
end)

-- ปุ่มเลือก Server Solo
createTeleportButton(MainFrame, UDim2.new(0.05, 0, 0.50, 0), "Server Solo", function()
    SoloServer()
end)

-- ข้อความข้างล่างสุด @peemxshop60517 [TikTok]
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Name = "FooterLabel"
FooterLabel.Size = UDim2.new(1, 0, 0, 25)
FooterLabel.Position = UDim2.new(0, 0, 0.85, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "@peemxshop60517 [TikTok]"
FooterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FooterLabel.TextSize = 11
FooterLabel.Font = Enum.Font.SourceSans
FooterLabel.Parent = MainFrame
