-- Komaru Hub loader
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/KomaruHubRBX/Roblox/main/loader.lua"))()

local SLATE_URL = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"

local CATALOG = {
    {
        Key = "mm2",
        Name = "Murder Mystery 2",
        Places = { 142823291 },
        Universe = 66654135,
        Loader = "https://raw.githubusercontent.com/KomaruHubRBX/Roblox/main/KomaruHub.lua",
        Listed = true,
        Tone = Color3.fromRGB(124, 92, 255),
    },
}

local Players = game:GetService("Players")

local function thumb(placeId)
    return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", placeId)
end

local function launch(entry)
    return pcall(function()
        return loadstring(game:HttpGet(entry.Loader), "@" .. entry.Key)()
    end)
end

local function arm(element, action)
    if type(element) ~= "table" then
        return
    end
    local last = 0
    for _, part in ipairs({ element.button, element.card, element.hitbox }) do
        if typeof(part) == "Instance" then
            pcall(function()
                part.Active = true
                part.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1
                        and input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    if os.clock() - last < 0.5 then
                        return
                    end
                    last = os.clock()
                    action()
                end)
            end)
        end
    end
end

local function matchPlace(placeId, universeId)
    for _, entry in ipairs(CATALOG) do
        if entry.Universe and entry.Universe == universeId then
            return entry
        end
    end
    for _, entry in ipairs(CATALOG) do
        for _, id in ipairs(entry.Places) do
            if id == placeId then
                return entry
            end
        end
    end
    return nil
end

local supported = matchPlace(game.PlaceId, game.GameId)
if supported then
    local ok, err = launch(supported)
    if not ok then
        warn("Komaru Hub: " .. supported.Name .. " failed to start - " .. tostring(err))
    end
    return
end

if type(_G.KomaruLoader) == "table" then
    pcall(function()
        _G.KomaruLoader.Window:Destroy()
    end)
end
_G.KomaruLoader = {}

local Slate = loadstring(game:HttpGet(SLATE_URL), "@Slate")()

pcall(function()
    Slate.Cleanup()
end)
pcall(function()
    Slate:PreloadIcons({ "lucide" })
end)

local Window = Slate:CreateWindow({
    Name = "Komaru Hub",
    Subtitle = "script loader",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.LeftControl,
})

pcall(function()
    Slate.Theme.Preset("Ash")
end)
pcall(function()
    Slate:SetFontFamily("JosefinSans")
end)
pcall(function()
    Window:SetBackdrop("aurora")
end)
pcall(function()
    local corner = Window.root:FindFirstChildOfClass("UICorner")
    if corner then
        corner.CornerRadius = UDim.new(0, 6)
    end
    local stroke = Window.root:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Thickness = 0
    end
end)

_G.KomaruLoader.Window = Window

local Tab = Window:CreateTab({ Name = "Scripts", Icon = "layout-grid" })

local placeName = "this game"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info and info.Name then
        placeName = info.Name
    end
end)

do
    local notice = Tab:CreateSection({ Name = "Unsupported game" })
    notice:Paragraph({
        Name = "No script for " .. placeName,
        Description = "Every script below reads its own game data on start and will stall here.",
    })
end

do
    local list = Tab:CreateSection({ Name = "Available scripts" })
    local grid = list:Grid({ Columns = 2, Height = 206, MinWidth = 196 })

    for _, entry in ipairs(CATALOG) do
        if entry.Listed then
            local start = function()
                Slate:Notify({
                    Title = "Komaru Hub",
                    Description = "Starting " .. entry.Name,
                    Icon = "play",
                    Duration = 5,
                })
                task.spawn(function()
                    local finished, ok, err = false, nil, nil
                    task.spawn(function()
                        ok, err = launch(entry)
                        finished = true
                    end)
                    local waited = 0
                    while not finished and waited < 6 do
                        task.wait(0.25)
                        waited += 0.25
                    end
                    if not finished then
                        Slate:Notify({
                            Title = "Komaru Hub",
                            Description = entry.Name .. " is stuck waiting for its own game data",
                            Icon = "triangle-alert",
                            Tone = "Warning",
                            Duration = 10,
                        })
                    elseif not ok then
                        Slate:Notify({
                            Title = "Komaru Hub",
                            Description = entry.Name .. " failed: " .. tostring(err),
                            Icon = "circle-alert",
                            Tone = "Danger",
                            Duration = 10,
                        })
                    else
                        Slate:Notify({
                            Title = "Komaru Hub",
                            Description = entry.Name .. " started",
                            Icon = "circle-check",
                            Tone = "Success",
                            Duration = 8,
                        })
                    end
                end)
            end
            local card = grid:Invite({
                Name = entry.Name,
                Icon = thumb(entry.Places[1]),
                Stats = {
                    { Text = "Place " .. tostring(entry.Places[1]), Dot = entry.Tone },
                },
                Game = "ROBLOX",
                GameIcon = "gamepad-2",
                Tone = entry.Tone,
                Glyph = "play",
                ButtonText = "Run",
                ButtonColor = entry.Tone,
                CopiedText = "Starting",
                Callback = start,
            })
            arm(card, start)
        end
    end
end

do
    local close = Tab:CreateSection({ Name = "Menu" })
    close:Button({
        Name = "Close menu",
        Icon = "x",
        Callback = function()
            pcall(function()
                Window:Destroy()
            end)
            _G.KomaruLoader = nil
        end,
    })
end

Slate:Notify({
    Title = "Komaru Hub",
    Description = "No script for " .. placeName .. ". Pick one below to run it anyway.",
    Icon = "triangle-alert",
    Tone = "Warning",
    Duration = 10,
})
