-- Komaru Hub loader
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/KomaruHubRBX/Roblox/main/loader.lua"))()

local BASE = "https://raw.githubusercontent.com/KomaruHubRBX/Roblox/main/"

local CATALOG = {
    {
        Key = "mm2",
        Name = "Murder Mystery 2",
        Places = { 142823291 },
        Universe = 66654135,
        Loader = BASE .. "KomaruHub.lua",
        Listed = true,
        Tone = Color3.fromRGB(124, 92, 255),
    },
}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local function launch(entry)
    return pcall(function()
        return loadstring(game:HttpGet(entry.Loader), "@" .. entry.Key)()
    end)
end

local function matchPlace(placeId, universeId)
    for _, entry in ipairs(CATALOG) do
        if entry.Universe and entry.Universe == universeId then return entry end
        for _, id in ipairs(entry.Places) do
            if id == placeId then return entry end
        end
    end
    return nil
end

local supported = matchPlace(game.PlaceId, game.GameId)
if supported and supported.Listed then
    local ok, err = launch(supported)
    if not ok then
        warn("Komaru Hub: " .. supported.Name .. " failed - " .. tostring(err))
    end
    return
end

if type(_G.KomaruLoader) == "table" and _G.KomaruLoader.Window then
    pcall(function() _G.KomaruLoader.Window:Destroy() end)
end
_G.KomaruLoader = {}

local ACCENT = Color3.fromRGB(124, 92, 255)
local BG = Color3.fromRGB(16, 14, 22)
local CARD = Color3.fromRGB(26, 23, 36)
local TEXT = Color3.fromRGB(236, 233, 244)
local MUTED = Color3.fromRGB(150, 144, 168)

local gui = Instance.new("ScreenGui")
gui.Name = "KomaruLoader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483000
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or ACCENT
    s.Thickness = thickness or 1.5
    s.Parent = obj
    return s
end

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.fromOffset(680, 440)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = BG
window.BorderSizePixel = 0
window.Parent = gui
corner(window, 14)
stroke(window, ACCENT, 1.5)

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.new(0, 22, 0, 16)
header.Size = UDim2.new(1, -110, 0, 30)
header.Font = Enum.Font.GothamBold
header.TextSize = 22
header.TextXAlignment = Enum.TextXAlignment.Left
header.TextColor3 = TEXT
header.Text = "KOMARU HUB"
header.Parent = window

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.new(0, 22, 0, 44)
sub.Size = UDim2.new(1, -110, 0, 18)
sub.Font = Enum.Font.GothamMedium
sub.TextSize = 12
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextColor3 = MUTED
sub.Text = "script loader"
sub.Parent = window

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -40, 0, 16)
close.BackgroundColor3 = CARD
close.TextColor3 = MUTED
close.Font = Enum.Font.GothamBold
close.TextSize = 15
close.Text = "✕"
close.BorderSizePixel = 0
close.Parent = window
corner(close, 8)

local line = Instance.new("Frame")
line.Position = UDim2.new(0, 20, 0, 74)
line.Size = UDim2.new(1, -40, 0, 1)
line.BackgroundColor3 = Color3.fromRGB(44, 40, 60)
line.BorderSizePixel = 0
line.Parent = window

local placeName = "this game"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info and info.Name then placeName = info.Name end
end)

local note = Instance.new("TextLabel")
note.BackgroundTransparency = 1
note.Position = UDim2.new(0, 22, 0, 88)
note.Size = UDim2.new(1, -44, 0, 18)
note.Font = Enum.Font.GothamMedium
note.TextSize = 12
note.TextXAlignment = Enum.TextXAlignment.Left
note.TextColor3 = MUTED
note.Text = "No script for " .. placeName .. ". Pick one below to run it anyway."
note.Parent = window

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 20, 0, 116)
scroll.Size = UDim2.new(1, -40, 1, -136)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = window

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromOffset(310, 116)
layout.CellPadding = UDim2.fromOffset(12, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function notify(title, text, color)
    local toast = Instance.new("TextLabel")
    toast.Size = UDim2.new(0.9, 0, 0, 40)
    toast.Position = UDim2.new(0.05, 0, 1, -110)
    toast.BackgroundColor3 = CARD
    toast.BorderSizePixel = 0
    toast.Font = Enum.Font.GothamMedium
    toast.TextSize = 13
    toast.TextColor3 = color or TEXT
    toast.Text = title .. "  ·  " .. text
    toast.Parent = window
    corner(toast, 10)
    stroke(toast, color or ACCENT, 1)
    task.delay(4, function()
        if toast and toast.Parent then
            task.spawn(function()
                for i = 0, 10 do
                    toast.BackgroundTransparency = i / 10
                    task.wait(0.02)
                end
                toast:Destroy()
            end)
        end
    end)
end

local function makeCard(entry, order)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = scroll
    corner(card, 12)
    stroke(card, Color3.fromRGB(48, 42, 66), 1)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -28, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = TEXT
    title.Text = entry.Name
    title.Parent = card

    local id = Instance.new("TextLabel")
    id.BackgroundTransparency = 1
    id.Position = UDim2.new(0, 14, 0, 38)
    id.Size = UDim2.new(1, -28, 0, 18)
    id.Font = Enum.Font.GothamMedium
    id.TextSize = 11
    id.TextXAlignment = Enum.TextXAlignment.Left
    id.TextColor3 = MUTED
    id.Text = "Place " .. tostring(entry.Places[1]) .. "  ·  ROBLOX"
    id.Parent = card

    local run = Instance.new("TextButton")
    run.Size = UDim2.fromOffset(92, 30)
    run.Position = UDim2.new(1, -106, 1, -42)
    run.BackgroundColor3 = entry.Tone or ACCENT
    run.BorderSizePixel = 0
    run.Font = Enum.Font.GothamBold
    run.TextSize = 13
    run.TextColor3 = Color3.fromRGB(255, 255, 255)
    run.Text = "Run"
    run.Parent = card
    corner(run, 8)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(8, 8)
    dot.Position = UDim2.new(1, -24, 1, -20)
    dot.BackgroundColor3 = entry.Tone or ACCENT
    dot.BorderSizePixel = 0
    dot.Parent = card
    corner(dot, 4)
    dot.Visible = false

    local busy = false
    run.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        run.Text = "..."
        notify("Komaru Hub", "Запуск " .. entry.Name, TEXT)
        task.spawn(function()
            local ok, err = launch(entry)
            busy = false
            run.Text = "Run"
            if ok then
                notify("Komaru Hub", entry.Name .. " запущен", Color3.fromRGB(110, 220, 140))
                task.wait(0.6)
                gui.Enabled = false
            else
                notify("Komaru Hub", "Ошибка: " .. tostring(err), Color3.fromRGB(255, 110, 110))
            end
        end)
    end)
    return card
end

local idx = 0
for _, entry in ipairs(CATALOG) do
    if entry.Listed then
        idx += 1
        makeCard(entry, idx)
    end
end

scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
    _G.KomaruLoader = nil
end)

local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local d = input.Position - dragStart
    window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

_G.KomaruLoader.Window = window
_G.KomaruLoader.Gui = gui
_G.KomaruLoader.Catalog = CATALOG
