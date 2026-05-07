local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider  = game:GetService("ContentProvider")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local CLR = {
    BG_MAIN    = Color3.fromRGB(15, 15, 17),
    BG_SEC     = Color3.fromRGB(24, 24, 27),
    ACCENT     = Color3.fromRGB(255, 190, 0),
    TEXT_PRI   = Color3.fromRGB(245, 245, 245),
    TEXT_SEC   = Color3.fromRGB(160, 160, 165),
    DANGER     = Color3.fromRGB(255, 75, 75)
}

local ICONS = {
    eye      = "rbxassetid://10723346959",
    user     = "rbxassetid://10747373176",
    users    = "rbxassetid://10747373426",
    close    = "rbxassetid://10747384394",
    min_on   = "rbxassetid://10734896206",
    min_off  = "rbxassetid://10734924532",
    chev_d   = "rbxassetid://10709790948",
}

local function preloadIcons()
    local assetsToLoad = {}
    for _, id in pairs(ICONS) do
        local tempImg = Instance.new("ImageLabel")
        tempImg.Image = id
        table.insert(assetsToLoad, tempImg)
    end
    task.spawn(function()
        pcall(function() ContentProvider:PreloadAsync(assetsToLoad) end)
    end)
end
preloadIcons()

local viewEnabled    = false
local isMinimized    = false
local dropdownOpen   = false
local selectedPlayer = nil
local connections    = {} 
local playerButtons  = {}

if CoreGui:FindFirstChild("ViewPlayer_PremiumUI") then
    CoreGui.ViewPlayer_PremiumUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViewPlayer_PremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 190)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -95)
MainFrame.BackgroundColor3 = CLR.BG_MAIN
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CLR.ACCENT
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 120, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Spectate"
TitleLabel.TextColor3 = CLR.ACCENT
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local PlayerCountFrame = Instance.new("Frame")
PlayerCountFrame.Size = UDim2.new(0, 40, 0, 20)
PlayerCountFrame.Position = UDim2.new(0, 95, 0.5, 0)
PlayerCountFrame.AnchorPoint = Vector2.new(0, 0.5)
PlayerCountFrame.BackgroundTransparency = 1
PlayerCountFrame.Parent = Header

local UsersIcon = Instance.new("ImageLabel")
UsersIcon.Size = UDim2.new(0, 14, 0, 14)
UsersIcon.Position = UDim2.new(0, 0, 0.5, 0)
UsersIcon.AnchorPoint = Vector2.new(0, 0.5)
UsersIcon.BackgroundTransparency = 1
UsersIcon.ScaleType = Enum.ScaleType.Fit
UsersIcon.Image = ICONS.users
UsersIcon.ImageColor3 = CLR.TEXT_SEC
UsersIcon.Parent = PlayerCountFrame

local CountText = Instance.new("TextLabel")
CountText.Size = UDim2.new(1, -18, 1, 0)
CountText.Position = UDim2.new(0, 18, 0, 0)
CountText.BackgroundTransparency = 1
CountText.Text = #Players:GetPlayers()
CountText.TextColor3 = CLR.TEXT_SEC
CountText.Font = Enum.Font.GothamMedium
CountText.TextSize = 12
CountText.TextXAlignment = Enum.TextXAlignment.Left
CountText.Parent = PlayerCountFrame

local HeaderLayout = Instance.new("UIListLayout")
HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
HeaderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
HeaderLayout.Padding = UDim.new(0, 5)
HeaderLayout.Parent = Header

local HeaderPadding = Instance.new("UIPadding")
HeaderPadding.PaddingRight = UDim.new(0, 10)
HeaderPadding.Parent = Header

local function createIconButton(name, iconId, color, size, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = parent

    local icon = Instance.new("ImageLabel")
    icon.Size = size or UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Image = iconId
    icon.ImageColor3 = color
    icon.Parent = btn

    return btn, icon
end

local MinBtn, MinIcon = createIconButton("MinBtn", ICONS.min_on, CLR.TEXT_PRI, nil, Header)
local CloseBtn, CloseIcon = createIconButton("CloseBtn", ICONS.close, CLR.TEXT_PRI, nil, Header)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 0, 154) 
Content.Position = UDim2.new(0, 0, 0, 36)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 15)
ContentPadding.PaddingRight = UDim.new(0, 15)
ContentPadding.PaddingTop = UDim.new(0, 5)
ContentPadding.PaddingBottom = UDim.new(0, 15)
ContentPadding.Parent = Content

local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(1, 0, 0, 40)
TargetFrame.BackgroundTransparency = 1
TargetFrame.Parent = Content

local AvatarBg = Instance.new("Frame")
AvatarBg.Size = UDim2.new(0, 32, 0, 32)
AvatarBg.Position = UDim2.new(0, 0, 0.5, 0)
AvatarBg.AnchorPoint = Vector2.new(0, 0.5)
AvatarBg.BackgroundColor3 = CLR.BG_SEC
AvatarBg.Parent = TargetFrame
Instance.new("UICorner", AvatarBg).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", AvatarBg).Color = CLR.TEXT_SEC

local TargetAvatar = Instance.new("ImageLabel")
TargetAvatar.Size = UDim2.new(1, 0, 1, 0)
TargetAvatar.BackgroundTransparency = 1
TargetAvatar.Image = ICONS.user
TargetAvatar.ImageColor3 = CLR.TEXT_SEC
TargetAvatar.ScaleType = Enum.ScaleType.Fit
TargetAvatar.Parent = AvatarBg
Instance.new("UICorner", TargetAvatar).CornerRadius = UDim.new(1, 0)

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -45, 1, 0)
TargetName.Position = UDim2.new(0, 42, 0, 0)
TargetName.BackgroundTransparency = 1
TargetName.Text = "Nenhum jogador"
TargetName.TextColor3 = CLR.TEXT_SEC
TargetName.Font = Enum.Font.GothamMedium
TargetName.TextSize = 14
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetFrame

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, 0, 0, 34)
DropdownBtn.Position = UDim2.new(0, 0, 0, 50)
DropdownBtn.BackgroundColor3 = CLR.BG_SEC
DropdownBtn.Text = " Selecionar Alvo..."
DropdownBtn.TextColor3 = CLR.TEXT_PRI
DropdownBtn.Font = Enum.Font.Gotham
DropdownBtn.TextSize = 13
DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
DropdownBtn.AutoButtonColor = false
DropdownBtn.Parent = Content

local DropPadding = Instance.new("UIPadding")
DropPadding.PaddingLeft = UDim.new(0, 10)
DropPadding.Parent = DropdownBtn

Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", DropdownBtn).Color = Color3.fromRGB(40, 40, 45)

local DropIcon = Instance.new("ImageLabel")
DropIcon.Size = UDim2.new(0, 16, 0, 16)
DropIcon.Position = UDim2.new(1, -26, 0.5, 0)
DropIcon.AnchorPoint = Vector2.new(0, 0.5)
DropIcon.BackgroundTransparency = 1
DropIcon.ScaleType = Enum.ScaleType.Fit
DropIcon.Image = ICONS.chev_d
DropIcon.ImageColor3 = CLR.TEXT_SEC
DropIcon.Parent = DropdownBtn

local SpecBtn = Instance.new("TextButton")
SpecBtn.Size = UDim2.new(1, 0, 0, 36)
SpecBtn.Position = UDim2.new(0, 0, 1, -36)
SpecBtn.BackgroundColor3 = CLR.BG_SEC
SpecBtn.Text = "Espectar Câmera"
SpecBtn.TextColor3 = CLR.TEXT_PRI
SpecBtn.Font = Enum.Font.GothamBold
SpecBtn.TextSize = 13
SpecBtn.AutoButtonColor = false
SpecBtn.Parent = Content

Instance.new("UICorner", SpecBtn).CornerRadius = UDim.new(0, 6)
local SpecStroke = Instance.new("UIStroke")
SpecStroke.Color = CLR.ACCENT
SpecStroke.Transparency = 1
SpecStroke.Parent = SpecBtn

local SpecIcon = Instance.new("ImageLabel")
SpecIcon.Size = UDim2.new(0, 16, 0, 16)
SpecIcon.Position = UDim2.new(0.5, 60, 0.5, 0)
SpecIcon.AnchorPoint = Vector2.new(0.5, 0.5)
SpecIcon.BackgroundTransparency = 1
SpecIcon.ScaleType = Enum.ScaleType.Fit
SpecIcon.Image = ICONS.eye
SpecIcon.ImageColor3 = CLR.TEXT_SEC
SpecIcon.Parent = SpecBtn

local DropList = Instance.new("ScrollingFrame")
DropList.Size = UDim2.new(1, 0, 0, 0)
DropList.Position = UDim2.new(0, 0, 0, 90)
DropList.BackgroundColor3 = CLR.BG_SEC
DropList.BorderSizePixel = 0
DropList.ScrollBarThickness = 8 
DropList.ScrollBarImageColor3 = CLR.ACCENT
DropList.ClipsDescendants = true
DropList.ZIndex = 5
DropList.Active = true 
DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y 
DropList.CanvasSize = UDim2.new(0, 0, 0, 0) 
DropList.Parent = Content
Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6)

local DropListLayout = Instance.new("UIListLayout")
DropListLayout.SortOrder = Enum.SortOrder.Name
DropListLayout.Padding = UDim.new(0, 5) 
DropListLayout.Parent = DropList

local DropListPadding = Instance.new("UIPadding")
DropListPadding.PaddingTop = UDim.new(0, 6)
DropListPadding.PaddingBottom = UDim.new(0, 25) 
DropListPadding.PaddingLeft = UDim.new(0, 4)
DropListPadding.PaddingRight = UDim.new(0, 4)
DropListPadding.Parent = DropList

local function tween(obj, props, time)
    local t = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, t, props):Play()
end

local function applyHover(btn, colorEnter, colorLeave)
    table.insert(connections, btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = colorEnter}) end))
    table.insert(connections, btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = colorLeave}) end))
end

local function applyIconHover(btn, icon, colorEnter, colorLeave)
    table.insert(connections, btn.MouseEnter:Connect(function() tween(icon, {ImageColor3 = colorEnter}) end))
    table.insert(connections, btn.MouseLeave:Connect(function() tween(icon, {ImageColor3 = colorLeave}) end))
end

applyIconHover(CloseBtn, CloseIcon, CLR.DANGER, CLR.TEXT_PRI)
applyIconHover(MinBtn, MinIcon, CLR.ACCENT, CLR.TEXT_PRI)
applyHover(DropdownBtn, Color3.fromRGB(35, 35, 40), CLR.BG_SEC)
applyHover(SpecBtn, Color3.fromRGB(35, 35, 40), CLR.BG_SEC)

task.spawn(function()
    while ScreenGui.Parent do
        tween(MainStroke, {Transparency = 0.8}, 1.5)
        task.wait(1.5)
        tween(MainStroke, {Transparency = 0.2}, 1.5)
        task.wait(1.5)
    end
end)

local function stopSpectate()
    viewEnabled = false
    Camera.CameraSubject = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    tween(SpecStroke, {Transparency = 1})
    tween(SpecBtn, {BackgroundColor3 = CLR.BG_SEC})
    SpecIcon.ImageColor3 = CLR.TEXT_SEC
    SpecBtn.Text = "Espectar Câmera"
end

local function selectPlayer(player)
    selectedPlayer = player
    DropdownBtn.Text = " " .. player.DisplayName
    TargetName.Text = player.DisplayName
    TargetName.TextColor3 = CLR.TEXT_PRI
    TargetAvatar.ImageColor3 = Color3.new(1,1,1)
    
    TargetAvatar.Image = "rbxthumb://type=HeadShot&id="..player.UserId.."&w=48&h=48"
    AvatarBg.UIStroke.Color = CLR.ACCENT
    
    dropdownOpen = false
    tween(DropList, {Size = UDim2.new(1, 0, 0, 0)})
    tween(DropIcon, {Rotation = 0})
    
    if viewEnabled then stopSpectate() end
end

local function toggleSpectate()
    if not selectedPlayer then return end
    
    viewEnabled = not viewEnabled
    if viewEnabled then
        local targetChar = selectedPlayer.Character
        if targetChar and targetChar:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetChar.Humanoid
            tween(SpecStroke, {Transparency = 0})
            SpecBtn.Text = "Parar Espectador"
            SpecIcon.ImageColor3 = CLR.ACCENT
        else
            viewEnabled = false
        end
    else
        stopSpectate()
    end
end

local function refreshPlayerList()
    CountText.Text = #Players:GetPlayers()

    for _, btn in pairs(playerButtons) do
        btn:Destroy()
    end
    table.clear(playerButtons)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Name = player.DisplayName
            pBtn.Size = UDim2.new(1, 0, 0, 26)
            pBtn.BackgroundColor3 = CLR.BG_MAIN
            pBtn.Text = "  " .. player.DisplayName
            pBtn.TextColor3 = CLR.TEXT_PRI
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 12
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.AutoButtonColor = false
            pBtn.Parent = DropList
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            applyHover(pBtn, CLR.BG_SEC, CLR.BG_MAIN)
            
            table.insert(connections, pBtn.MouseButton1Click:Connect(function()
                selectPlayer(player)
            end))

            table.insert(playerButtons, pBtn)
        end
    end
    
    if selectedPlayer and not Players:FindFirstChild(selectedPlayer.Name) then
        selectedPlayer = nil
        stopSpectate()
        DropdownBtn.Text = " Selecionar Alvo..."
        TargetName.Text = "Nenhum jogador"
        TargetName.TextColor3 = CLR.TEXT_SEC
        TargetAvatar.Image = ICONS.user
        TargetAvatar.ImageColor3 = CLR.TEXT_SEC
        AvatarBg.UIStroke.Color = CLR.TEXT_SEC
    end
end

table.insert(connections, Players.PlayerAdded:Connect(refreshPlayerList))
table.insert(connections, Players.PlayerRemoving:Connect(refreshPlayerList))
refreshPlayerList()

table.insert(connections, DropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        tween(DropList, {Size = UDim2.new(1, 0, 0, 85)}) 
        tween(DropIcon, {Rotation = 180})
    else
        tween(DropList, {Size = UDim2.new(1, 0, 0, 0)})
        tween(DropIcon, {Rotation = 0})
    end
end))

table.insert(connections, SpecBtn.MouseButton1Click:Connect(toggleSpectate))

table.insert(connections, MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        if dropdownOpen then
            dropdownOpen = false
            tween(DropList, {Size = UDim2.new(1, 0, 0, 0)})
            tween(DropIcon, {Rotation = 0})
        end
        tween(MainFrame, {Size = UDim2.new(0, 280, 0, 36)})
        MinIcon.Image = ICONS.min_off
        tween(MinIcon, {ImageColor3 = CLR.TEXT_SEC})
    else
        tween(MainFrame, {Size = UDim2.new(0, 280, 0, 190)})
        MinIcon.Image = ICONS.min_on
        tween(MinIcon, {ImageColor3 = CLR.TEXT_PRI})
    end
end))

table.insert(connections, CloseBtn.MouseButton1Click:Connect(function()
    stopSpectate()
    for _, conn in ipairs(connections) do conn:Disconnect() end
    ScreenGui:Destroy()
end))

local dragging, dragStart, startPos

table.insert(connections, Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

table.insert(connections, ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        stopSpectate()
        for _, conn in ipairs(connections) do conn:Disconnect() end
    end
end))

table.insert(connections, LocalPlayer.CharacterAdded:Connect(function()
    if viewEnabled then stopSpectate() end
end))