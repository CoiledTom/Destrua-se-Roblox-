local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
	Speed = 0, -- velocidade da câmera: 0 = gruda | 6 = suave | 10 = natural | 18 = firme
	AimPart = "UpperTorso", -- parte que vai grudar: "Head" | "UpperTorso" (peito) | "LowerTorso" (cintura) | "HumanoidRootPart" (centro) | "Torso" (peito R6)
	MaxDistance = 1000, -- passou dessa distância, troca de alvo
	TeamCheck = true, -- true = ignora seu time | false = mira em todos
	Commands = { "/open", "-cam", "/cam", "-lock", "/lock", "-aim", "/aim" }, -- palavras do chat que abrem o painel
}

-- se a parte escolhida não existir (R6/R15), usa uma dessas
local FALLBACK_PARTS = { "UpperTorso", "Torso", "HumanoidRootPart" }

local THEME = {
	bg = Color3.fromRGB(12, 13, 17),
	stroke = Color3.fromRGB(60, 62, 72),
	text = Color3.fromRGB(235, 235, 240),
	sub = Color3.fromRGB(150, 152, 165),
	off = Color3.fromRGB(45, 46, 52),
	accent = Color3.fromRGB(255, 122, 26),
}

local enabled = false
local lockedPlayer = nil
local smoothedRotation = nil

local Gui = Instance.new("ScreenGui")
Gui.Name = "CamLockGui"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 10
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(1, 0)
Main.Position = UDim2.new(1, -15, 0, 20)
Main.Size = UDim2.fromOffset(180, 92)
Main.BackgroundColor3 = THEME.bg
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.stroke
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -46, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "CAMLOCK"
Title.TextColor3 = THEME.text
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.Position = UDim2.new(1, -6, 0.5, 0)
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = THEME.sub
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local ToggleButton = Instance.new("TextButton")
ToggleButton.Position = UDim2.fromOffset(10, 42)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.BackgroundColor3 = THEME.off
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = THEME.sub
ToggleButton.TextSize = 15
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local function UpdateButton()
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	TweenService:Create(ToggleButton, info, {
		BackgroundColor3 = enabled and THEME.accent or THEME.off,
		TextColor3 = enabled and Color3.new(1, 1, 1) or THEME.sub,
	}):Play()

	ToggleButton.Text = enabled and "ON" or "OFF"
end

local function SetEnabled(value)
	enabled = value
	lockedPlayer = nil
	smoothedRotation = nil
	UpdateButton()
end

local function ShowPanel()
	Main.Position = UDim2.new(1, -15, 0, 20)
	Main.Visible = true
end

ToggleButton.Activated:Connect(function()
	SetEnabled(not enabled)
end)

CloseButton.Activated:Connect(function()
	Main.Visible = false
end)

local dragging = false
local dragInput, dragStart, startPosition

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		SetEnabled(not enabled)
	end
end)

local function IsCommand(text)
	local clean = text:lower():match("^%s*(.-)%s*$")

	for _, command in ipairs(CONFIG.Commands) do
		if clean == command:lower() then
			return true
		end
	end

	return false
end

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
	TextChatService.MessageReceived:Connect(function(message)
		local source = message.TextSource

		if source and source.UserId == LocalPlayer.UserId and IsCommand(message.Text) then
			ShowPanel()
		end
	end)
else
	LocalPlayer.Chatted:Connect(function(message)
		if IsCommand(message) then
			ShowPanel()
		end
	end)
end

local function IsLocalAlive()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	return humanoid ~= nil and humanoid.Health > 0
end

local function GetMyPosition(camera)
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	return root and root.Position or camera.CFrame.Position
end

local function FindAimPart(character)
	local part = character:FindFirstChild(CONFIG.AimPart)

	if part and part:IsA("BasePart") then
		return part
	end

	for _, name in ipairs(FALLBACK_PARTS) do
		part = character:FindFirstChild(name)

		if part and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function GetAimPart(player, myPosition)
	if player == LocalPlayer then
		return nil
	end

	if CONFIG.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
		return nil
	end

	local character = player.Character
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	local part = FindAimPart(character)
	if not part then
		return nil
	end

	if (part.Position - myPosition).Magnitude > CONFIG.MaxDistance then
		return nil
	end

	return part
end

local function AcquireTarget(camera, myPosition)
	local bestPlayer = nil
	local bestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local part = GetAimPart(player, myPosition)

		if part then
			local _, onScreen = camera:WorldToViewportPoint(part.Position)

			if onScreen then
				local distance = (part.Position - myPosition).Magnitude

				if distance < bestDistance then
					bestDistance = distance
					bestPlayer = player
				end
			end
		end
	end

	return bestPlayer
end

RunService:BindToRenderStep("CamLockStep", Enum.RenderPriority.Last.Value, function(dt)
	if not enabled then
		return
	end

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	if not IsLocalAlive() then
		lockedPlayer = nil
		smoothedRotation = nil
		return
	end

	local myPosition = GetMyPosition(camera)
	local part = lockedPlayer and GetAimPart(lockedPlayer, myPosition)

	if not part then
		lockedPlayer = AcquireTarget(camera, myPosition)
		part = lockedPlayer and GetAimPart(lockedPlayer, myPosition)

		if not part then
			smoothedRotation = nil
			return
		end
	end

	local origin = camera.CFrame.Position
	local direction = part.Position - origin

	if direction.Magnitude < 0.1 or math.abs(direction.Unit.Y) > 0.999 then
		return
	end

	local goalRotation = CFrame.lookAt(Vector3.zero, direction)

	if not smoothedRotation then
		smoothedRotation = camera.CFrame.Rotation
	end

	local speed = CONFIG.Speed

	if speed and speed > 0 then
		smoothedRotation = smoothedRotation:Lerp(goalRotation, 1 - math.exp(-speed * dt))
	else
		smoothedRotation = goalRotation
	end

	camera.CFrame = CFrame.new(origin) * smoothedRotation
end)
