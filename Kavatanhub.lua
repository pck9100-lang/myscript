local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')
local player = Players.LocalPlayer

task.spawn(function()
    local splashGui = player.PlayerGui:WaitForChild('SplashScreenGui', 5)

    if splashGui then
        local frame = splashGui:FindFirstChild('Frame')

        if frame then
            frame.Visible = false
        end

        local redBackdrop = splashGui:FindFirstChild('RedBackdrop')

        if redBackdrop and redBackdrop:FindFirstChild('UIGradient') then
            local gradient = redBackdrop.UIGradient

            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0.421, 0.411, 0.498)),
            })
        end
    end
end)

local modeSelected = false

local function RunNormalMode()
    if getgenv then
        getgenv().identifyexecutor = nil
    end
    if getfenv then
        getfenv().identifyexecutor = nil
    end

    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local Net = require(ReplicatedStorage.Modules.Core.Net)
    local UI = require(ReplicatedStorage.Modules.Core.UI)

    task.spawn(function()
        local TransitionUI = nil

        while not TransitionUI do
            for _, v in pairs(getgc(true))do
                if type(v) == 'table' and rawget(v, 'conditional_transition') then
                    TransitionUI = v

                    break
                end
            end

            task.wait(0.1)
        end

        TransitionUI.transition = function()
            return
        end
        TransitionUI.conditional_transition = function()
            return
        end

        if TransitionUI.enabled then
            TransitionUI.enabled.set(false)
        end
        if TransitionUI.conditional_enabled then
            TransitionUI.conditional_enabled.set(false)
        end
    end)
    task.spawn(function()
        workspace:SetAttribute('SkipCreator', true)

        local CC = nil

        while not CC do
            for _, v in pairs(getgc(true))do
                if type(v) == 'table' and rawget(v, 'is_in_creator') and rawget(v, 'finish') then
                    CC = v

                    break
                end
            end

            task.wait(0.1)
        end

        CC.is_in_creator.hook(function(isIn)
            if isIn then
                CC.finish(false)
            end
        end)

        if CC.leaving_creator then
            CC.leaving_creator.set(true)
        end
    end)
    task.spawn(function()
        local PlayButton = UI.get('PlayButton')

        if PlayButton then
            for _, connection in pairs(getconnections(PlayButton.MouseButton1Click))do
                connection:Fire()
            end
        end
    end)

    modeSelected = true
end
local function RunGodMode()
    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local UI = require(ReplicatedStorage.Modules.Core.UI)
    local Net = require(ReplicatedStorage.Modules.Core.Net)
    local Char = require(ReplicatedStorage.Modules.Core.Char)

    local function ExecuteGodModeStrict()
        local hrp = Char.get_hrp()

        if not hrp then
            return false
        end

        local frozenCFrame = hrp.CFrame
        local oldSend = Net.send

        Net.send = function(name, ...)
            if name == 'replicate_cc_cframe' then
                if type(oldSend) == 'function' then
                    return oldSend(name, frozenCFrame)
                end

                return
            end
            if name == 'leave_character_creator' or name == 'player_created_outfit' then
                return nil
            end
            if type(oldSend) == 'function' then
                return oldSend(name, ...)
            end
        end

        task.spawn(function()
            while task.wait(0.1) do
                if hrp and hrp.Parent then
                    hrp.Anchored = false
                end
            end
        end)

        for _, v in pairs(getgc(true))do
            if type(v) == 'table' and rawget(v, 'leaving_creator') and type(v.leaving_creator) == 'table' then
                v.leaving_creator.set(true)

                break
            end
        end

        pcall(function()
            Net.send('request_respawn')
        end)
        task.wait(6.2)
        pcall(function()
            return Net.get('death_screen_request_respawn')
        end)

        return true
    end

    task.spawn(function()
        local TransitionUI = nil

        while not TransitionUI do
            for _, v in pairs(getgc(true))do
                if type(v) == 'table' and rawget(v, 'conditional_transition') then
                    TransitionUI = v

                    break
                end
            end

            task.wait(0.5)
        end

        local oldTransition = TransitionUI.conditional_transition

        TransitionUI.conditional_transition = function(self, p15, p16, p17)
            local originalWait = TransitionUI.conditional_enabled.wait

            TransitionUI.conditional_enabled.wait = function(...)
                local startTime = tick()

                ExecuteGodModeStrict()

                local elapsed = tick() - startTime

                if elapsed < 8 then
                    task.wait(8 - elapsed)
                end

                return nil
            end

            local res = oldTransition(self, p15, p16, p17)

            TransitionUI.conditional_enabled.wait = originalWait

            return res
        end
    end)
    task.spawn(function()
        local CC = nil

        while not CC do
            for _, v in pairs(getgc(true))do
                if type(v) == 'table' and rawget(v, 'is_in_creator') and rawget(v, 'finish') then
                    CC = v

                    break
                end
            end

            task.wait(0.1)
        end

        CC.is_in_creator.hook(function(isIn)
            if isIn then
                task.wait(0)
                CC.finish(false)
            end
        end)
    end)

    local PlayButton = UI.get('PlayButton')

    if PlayButton then
        for _, v in pairs(getconnections(PlayButton.MouseButton1Click))do
            v:Fire()
        end
    end

    modeSelected = true
end

if player:GetAttribute('InSplashScreen') == true then
    if player.PlayerGui:FindFirstChild('FreemiumHub') then
        player.PlayerGui.PremiumHub:Destroy()
    end

    local ScreenGui = Instance.new('ScreenGui')

    ScreenGui.Name = 'PremiumHub'
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new('Frame')

    MainFrame.Name = 'MainFrame'
    MainFrame.Size = UDim2.new(0, 450, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local BackgroundImg = Instance.new('ImageLabel')

    BackgroundImg.Name = 'BackgroundImage'
    BackgroundImg.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImg.BackgroundTransparency = 1
    BackgroundImg.Image = ""
    BackgroundImg.ImageTransparency = 0.7
    BackgroundImg.ScaleType = Enum.ScaleType.Crop
    BackgroundImg.ZIndex = 0
    BackgroundImg.Parent = MainFrame

    local BGCorners = Instance.new('UICorner')

    BGCorners.CornerRadius = UDim.new(0, 20)
    BGCorners.Parent = BackgroundImg

    local UICorner = Instance.new('UICorner')

    UICorner.CornerRadius = UDim.new(0, 20)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new('UIStroke')

    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(0, 0, 0)
    UIStroke.Transparency = 0.4
    UIStroke.Parent = MainFrame

    local Logo = Instance.new('ImageLabel')

    Logo.Name = 'Logo'
    Logo.Size = UDim2.new(0, 60, 0, 60)
    Logo.Position = UDim2.new(0.5, -30, 0, 20)
    Logo.BackgroundTransparency = 1
    Logo.Image = ""
    Logo.ZIndex = 2
    Logo.Parent = MainFrame

    local Title = Instance.new('TextLabel')

    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 85)
    Title.BackgroundTransparency = 1
    Title.Text = 'Kavatan Hub | Block Spin 🔫'
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.ZIndex = 2
    Title.Parent = MainFrame

    local Subtitle = Instance.new('TextLabel')

    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0, 120)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = 'Select mode to play'
    Subtitle.TextColor3 = Color3.fromRGB(150, 210, 255)
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.ZIndex = 2
    Subtitle.Parent = MainFrame

    local function createModeButton(name, text, pos, isSpecial)
        local btn = Instance.new('TextButton')

        btn.Name = name
        btn.Size = UDim2.new(0, 380, 0, 45)
        btn.Position = pos
        btn.BackgroundColor3 = isSpecial and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = isSpecial and 0.2 or 0.9
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(10, 10, 10)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 16
        btn.AutoButtonColor = false
        btn.ZIndex = 2
        btn.Parent = MainFrame

        local bCorner = Instance.new('UICorner')

        bCorner.CornerRadius = UDim.new(0, 10)
        bCorner.Parent = btn

        local bStroke = Instance.new('UIStroke')

        bStroke.Thickness = 1.5
        bStroke.Color = Color3.fromRGB(0, 0, 0)
        bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStroke.Transparency = 0.5
        bStroke.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = isSpecial and 0 or 0.7,
                Size = UDim2.new(0, 390, 0, 48),
                Position = pos + UDim2.new(0, -5, 0, -1.5),
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = isSpecial and 0.2 or 0.9,
                Size = UDim2.new(0, 380, 0, 45),
                Position = pos,
            }):Play()
        end)

        return btn
    end

    local NormalBtn = createModeButton('NormalMode', 'Normal Mode', UDim2.new(0.5, -190, 0, 155), false)
    local GodBtn = createModeButton('GodMode', 'God Mode', UDim2.new(0.5, -190, 0, 210), true)

    NormalBtn.MouseButton1Click:Connect(function()
        MainFrame:TweenPosition(UDim2.new(0.5, -225, 1.1, 0), 'In', 'Back', 0.5)
        task.wait(0.5)
        ScreenGui:Destroy()
        RunNormalMode()
    end)
    GodBtn.MouseButton1Click:Connect(function()
        MainFrame:TweenPosition(UDim2.new(0.5, -225, 1.1, 0), 'In', 'Back', 0.5)
        task.wait(0.5)
        ScreenGui:Destroy()
        RunGodMode()
    end)

    repeat
        task.wait(0.1)
    until modeSelected
else
    modeSelected = true
end


a=game:GetService("Players")

b=game:GetService("RunService")

c=game:GetService"ReplicatedStorage"

d=game:GetService"UserInputService"

e=game:GetService"TweenService"

f=game:GetService"Debris"

g=game:GetService"Workspace"

h=game:GetService"ContextActionService"

i=c:WaitForChild"Remotes"

Net= require(c.Modules.Core.Net)

j=require(c.Modules.Core.Util)

k=require(c.Modules.Game.UI.BuyPromptUI)

l=require(c.Modules.Game.Emotes.EmotesUI)

m=require(c.Modules.Game.Emotes.EmotesList)

n=require(c.Modules.Core.UI)

o=require(c.Modules.Core.Char)

CrateController = require(c.Modules.Game.CrateSystem.Crate)

p=c:WaitForChild"Items"

q=p:WaitForChild"melee"

r=a.LocalPlayer

s=r.Character or r.CharacterAdded:Wait()

t=s:WaitForChild"Humanoid"

u=s:WaitForChild"HumanoidRootPart"

v=a.LocalPlayer

local w={}

x=workspace:WaitForChild"DroppedItems"


-- ── Executor Bypass ──────────────────────────────

if getgenv then

    getgenv().identifyexecutor = nil

end

if getfenv then

    getfenv().identifyexecutor = nil

end



y=g.CurrentCamera,

r:GetMouse()

z=d.TouchEnabled and not d.KeyboardEnabled



local A

pcall(

function()

A=loadstring(game:HttpGet"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")()

end

)

local B

if A then

B=

A:CreateWindow

{

Title="Kavatan Hub | Block Spin 🔫",

Icon="",

Author="Block Spin",

Folder="Boss",

Size=UDim2.fromOffset(650,400),

Theme="Dark",

Transparent=true,

Resizable=true,

KeyCode=Enum.KeyCode.G

}



Window:EditOpenButton({

    Title = "Kavatan Hub | Block Spin 🔫",

    Icon = "",

    CornerRadius = UDim.new(0,16),

    StrokeThickness = 2,

    Color = ColorSequence.new( -- gradient

        Color3.fromHex("#000000"), 

        Color3.fromHex("#000000")

    ),

    OnlyMobile = false,

    Enabled = true,

    Draggable = true,

})



Window:Tag({

    Title = "PVP | Paid",

    Icon = "github",

    Color = Color3.fromHex("#000000"),

    Radius = 13,

})



else

B={

Tab=function(C)

return{

Section=function()

end,

Toggle=function()

end,

Slider=function()

end,

Button=function()

end,

Input=function()

return{}

end,

Divider=function()

end

}

end

}

end



local C=B.ConfigManager

local D=C:CreateConfig"CathubConfig"

local E

pcall(

function()

E=c:WaitForChild("Remotes",5):WaitForChild("Send",5)

end

)


local Radius = 250
local CheckInterval = 0.1
local ActiveConnections = {}

local PingHistory = {}
local MaxHistory = 10

local G=false

local H=120

local I

local J

local K=Drawing.new"Line"

K.Thickness=1

K.Color=Color3.fromRGB(0,0,0)

K.Transparency=1

K.Visible=false



local L={}

local M=false

local N=false

local O=false

local P={}



local Q=false

local R=0.05

local S=false

local T=false

local U=40

local V=false

local W=false

local X

local Y=10

local Z

local _

local aa

local ab=state

local ac=0

local ad=false




local ae=1

local af=0.4

local ag=false

local ah

local ai=getgenv or function()

return _G

end

ai().Sky=false

ai().SkyAmount=1500

ai().MultiShoot = false

local aj=false

local ak=false

local JumpHeight = 30

local al={}

local am=-100

local an=30

local ao=0.1









local ap=20

local aq=0

local ar=0

local as=false



local at={Common=

Color3.fromRGB(255,255,255),Uncommon=

Color3.fromRGB(99,255,52),Rare=

Color3.fromRGB(51,170,255),Epic=

Color3.fromRGB(237,44,255),Legendary=

Color3.fromRGB(255,150,0),Omega=

Color3.fromRGB(255,20,51)

}

local au={}

local av={}

local aw=false

local ax

local ay=false

local az={}

local aA=100

local aB={}



local aC

pcall(

function()

for aD,aE in ipairs(getgc(true))do

if typeof(aE)=="table"and rawget(aE,"event")and rawget(aE,"func")then

aC=aE

break

end

end

end

)



local function getPing()

local aD=r:FindFirstChild"PlayerGui"

if not aD then

return 0.2

end



local aE=aD:FindFirstChild"NetworkStats"

if not aE then

return 0.2

end



local aF=aE:FindFirstChild"PingLabel"

if not aF then

return 0.01

end



local aG=aF.Text

if typeof(aG)~="string"then

return 0.01

end



local aH=tonumber(aG:match"%d+")

if not aH then

return 0.01

end



local aI=aH/1000

if aI<0 or aI>2 then

aI=0.01

end



return aI

end



local function isPlayerExcluded(aD)

for aE,aF in ipairs(P)do

if aF~=""and string.find(string.lower(aD),string.lower(aF))then

return true

end

end

return false

end

local function getClosestTarget()

local aD

local aE=H

local aF=Vector2.new(y.ViewportSize.X/2,y.ViewportSize.Y/2)

for aG,aH in ipairs(a:GetPlayers())do

if aH~=r and aH.Character then

local aI=aH.Character:FindFirstChild"Head"

local aJ=aH.Character:FindFirstChild"Humanoid"

local aK=aH.Character:FindFirstChild"HumanoidRootPart"

if aI and aJ and aJ.Health>0 and aK then

local aL,aM=y:WorldToViewportPoint(aI.Position)

if aM then

local aN=Vector2.new(aL.X,aL.Y)

local aO=(aN-aF).Magnitude

if aO<=H and not isPlayerExcluded(aH.Name)then

if aO<aE then

aE=aO

aD=aH

end

end

end

end

end

end

return aD

end

local function predictPosition(targetPart, targetPlayer)
    if not targetPart then
        return Vector3.zero
    end
    
    local velocity = calculateVelocity(targetPlayer) or Vector3.zero
    local ping = (getPing and getPing()) or 0.05
    
    -- Clamp ping ให้อยู่ในช่วงที่เหมาะสม
    if ping < 0 then ping = 0.05 end
    if ping > 1 then ping = 0.15 end
    
    -- คำนวณตำแหน่งในอนาคตด้วย velocity + ping compensation
    local predictedPos = targetPart.Position + (velocity * ping * 1.15)
    
    -- ถ้าเป็น Head เพิ่ม compensation เล็กน้อยให้โดนหัวแม่นขึ้น
    if targetPart.Name == "Head" then
        predictedPos = predictedPos + Vector3.new(0, 0.08, 0)
    else
        -- ถ้าไม่ใช่ Head ให้เล็งตรงกลางช่วงบนของ torso
        predictedPos = predictedPos + Vector3.new(0, 0.5, 0)
    end
    
    return predictedPos
end



local function isBehindWall(aD,aE)
	if not aD or not aE then
		return false
	end
	local aF=aE-aD
	if aF.Magnitude<1 then
		return false
	end
	local aG={}
	local aH=r.Character
	if aH then
		table.insert(aG,aH)
	end
	local aI=I and I.Character
	if aI then
		table.insert(aG,aI)
	end
	local aJ=workspace:Raycast(aD,aF,RaycastParams.new())
	if not aJ then
		return false
	end
	local aK=aJ.Instance
	return aK and not table.find(aG,aK.Parent)
end



local function setupCharacter(aD)

s=aD

t=aD:WaitForChild"Humanoid"

u=aD:WaitForChild"HumanoidRootPart"

if _ then

pcall(

function()

_:Disconnect()

end

)

end

_=

b.RenderStepped:Connect(

function()

if Q and t and u then

if t.MoveDirection.Magnitude>0 then

u.CFrame=u.CFrame+(t.MoveDirection.Unit*R)

end

end

end

)

end

local function isDowned()

local aD=o.get_hum()

if not aD then

return false

end





if aD.Health<=0 then

return false

end



return aD:GetAttribute"HasBeenDowned"or aD:GetAttribute"IsDead"

end



local function getHRP()

local aD=o.current_char.get()

if not aD then

return

end

return aD:FindFirstChild"HumanoidRootPart"

end



local function teleportUnderground()

local aD=getHRP()

if not aD then

return

end

if not ah then

local aE=aD.CFrame

ah=aE+Vector3.new(0,am,0)

end

    aD.CFrame.new(ah.Position)
end



local function flickerAndMove()

if ag then

return

end

ag=true



task.spawn(

function()

while ag and enabled and isDowned()do

local aD=o.get_hum()

if aD and aD.Health<=0 then

break

end



local aE=getHRP()

if aE and ah then

local aF=math.random()*math.pi*2

local aG=Vector3.new(math.cos(aF),0,math.sin(aF))*an

local aH=ah.Position+aG



aE.CFrame=CFrame.new(aH)

task.wait(0.05)

aE.CFrame=ah

end



task.wait(ao)

end



ag=false

end

)

end



local function NetGet(...)

if not aC or not aC.func then

return

end

local aD={...}

for aE,aF in ipairs(aD)do

if typeof(aF)=="Instance"then

if aF:IsA"Model"and#aF:GetChildren()==0 then

local aG=g:FindFirstChild"DroppedItems"

if aG then

local aH=aG:FindFirstChildWhichIsA"Model"

if aH then

aD[aE]=aH

else

return

end

else

return

end

end

end

end

aC.func=(aC.func or 0)+1

local aE,aF=

pcall(

function()

local aE=c:WaitForChild"Remotes":WaitForChild"Get"

return aE:InvokeServer(aC.func,unpack(aD))

end

)

if not aE then

warn("[NetGet Error]",aF)

end

return aF

end




local function GetDroppedItemsContainer()
    return workspace:FindFirstChild("DroppedItems")
end

local function PickupItem(Item, Character)
    local PickupZone = Item:FindFirstChild("PickUpZone")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if PickupZone and HumanoidRootPart then
        
        pcall(function()
            firetouchinterest(PickupZone, HumanoidRootPart, 0)
            firetouchinterest(PickupZone, HumanoidRootPart, 1)
        end)
    end
end


local function CheckAndPickup()
    local Character = r.Charact
