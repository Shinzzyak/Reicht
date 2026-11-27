-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ============================================================================
    99 NIGHTS IN THE FOREST â ELITE AUTOMATION SUITE
    Universal Architecture: Lobby & In-Match Survival Support
    Author: By XLunaHUB
    Language: English
    Initial State: STRICTLY ALL OFF
    ============================================================================
--]]

-- Clean previous instance if re-executed
if getgenv()._XLUNA_99NIGHTS_CLEANUP then
    pcall(getgenv()._XLUNA_99NIGHTS_CLEANUP)
end

-- ==================== CORE SERVICES ====================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")

local LP = Players.LocalPlayer

-- Detect Match vs Lobby
local LOBBY_PLACE_ID = 79546208627805
local isMatch = (game.PlaceId ~= LOBBY_PLACE_ID)

-- ==================== CLEANUP LINGERING UI ====================
pcall(function()
    local targets = {CoreGui, (gethui and gethui()), LP and LP:FindFirstChild("PlayerGui")}
    for _, parent in ipairs(targets) do
        if parent then
            for _, name in ipairs({"WindUI", "XLuna_99Nights_FloatingToggle", "XLuna_ESP_Holder"}) do
                local found = parent:FindFirstChild(name)
                if found then found:Destroy() end
            end
        end
    end
end)

-- ==================== LOAD WINDUI LIBRARY ====================
local WindUI
local okLoad, resLoad = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if okLoad and resLoad then
    WindUI = resLoad
else
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end

-- ==================== REMOTES & PROTOCOLS ====================
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local RE = {
    -- Match Remotes
    RequestOpenItemChest      = RemoteEvents and RemoteEvents:FindFirstChild("RequestOpenItemChest"),
    RequestHotbarItem         = RemoteEvents and RemoteEvents:FindFirstChild("RequestHotbarItem"),
    RequestBagStoreItem       = RemoteEvents and RemoteEvents:FindFirstChild("RequestBagStoreItem"),
    RequestBagDropItem        = RemoteEvents and RemoteEvents:FindFirstChild("RequestBagDropItem"),
    RequestConsumeItem        = RemoteEvents and RemoteEvents:FindFirstChild("RequestConsumeItem"),
    RequestBurnItem           = RemoteEvents and RemoteEvents:FindFirstChild("RequestBurnItem"),
    RequestSelfRevive         = RemoteEvents and RemoteEvents:FindFirstChild("RequestSelfRevive"),
    RequestRevivePlayer       = RemoteEvents and RemoteEvents:FindFirstChild("RequestRevivePlayer"),
    RequestReviveAll          = RemoteEvents and RemoteEvents:FindFirstChild("RequestReviveAll"),
    ToolDamageObject          = RemoteEvents and RemoteEvents:FindFirstChild("ToolDamageObject"),
    RequestDestroyFoliage     = RemoteEvents and RemoteEvents:FindFirstChild("RequestDestroyFoliage"),

    -- Lobby Remotes
    TeleportEvent                  = RemoteEvents and RemoteEvents:FindFirstChild("TeleportEvent"),
    RequestClaimDailyRequestReward = RemoteEvents and RemoteEvents:FindFirstChild("RequestClaimDailyRequestReward"),
    RequestClaimBadgeDiamonds      = RemoteEvents and RemoteEvents:FindFirstChild("RequestClaimBadgeDiamonds"),
    RequestPurchaseClass           = RemoteEvents and RemoteEvents:FindFirstChild("RequestPurchaseClass"),
    RequestLevelUpClass            = RemoteEvents and RemoteEvents:FindFirstChild("RequestLevelUpClass"),
    UpdateEquipped                 = RemoteEvents and RemoteEvents:FindFirstChild("UpdateEquipped"),
    RequestInputCode               = RemoteEvents and RemoteEvents:FindFirstChild("RequestInputCode"),
}

-- ==================== STATE CONFIGURATION (DEFAULT: STRICTLY ALL OFF) ====================
local State = {
    -- In-Match Survival & Fire
    AutoFeedCampfire     = false,
    AutoEatFood          = false,
    AutoSelfRevive       = false,
    AutoReviveTeammates  = false,

    -- In-Match Chests & Loot
    AutoOpenChests       = false,
    AutoLootVacuum       = false,

    -- In-Match Combat & Foliage
    KillAura             = false,
    KillAuraRadius       = 25,
    AutoClearFoliage     = false,

    -- Lobby Specific
    AutoClaimDailyQuests = false,
    AutoRollDailyQuests  = false,
    AutoClaimBadges      = false,
    AutoLevelUpClass     = false,
    SelectedClassToEquip = "Camper",
    SelectedClassToBuy   = "Ranger",
    SelectedTeleporter   = "Teleporter 1",

    -- Movement & Character
    SpeedHack            = false,
    WalkSpeed            = 16,
    JumpHack             = false,
    JumpPower            = 50,
    InfiniteJump         = false,
    Noclip               = false,
    FlyHack              = false,
    FlySpeed             = 45,

    -- Visuals & ESP
    CampfireESP          = false,
    ChestsESP            = false,
    MobsESP              = false,
    FoodESP              = false,
    TeammatesESP         = false,
    PlayerESP            = false,
    StationsESP          = false,
    Fullbright           = false,

    -- Core / Utility
    AntiAFK              = false,
}

-- Campground Coordinates (Match)
local CAMP_POSITIONS = {
    ["Campfire (Main)"]     = Vector3.new(0.00, 1.50, 0.00),
    ["Crafting Bench"]      = Vector3.new(19.91, 3.30, -3.24),
    ["Scrapper"]            = Vector3.new(20.95, 1.20, -5.24),
    ["Notice Board"]        = Vector3.new(-79.91, 10.00, -5.48),
    ["Warp Portal"]         = Vector3.new(10.39, 4.54, -0.90),
}

-- Lobby POI Coordinates
local LOBBY_POSITIONS = {
    ["Spawn Location"]        = Vector3.new(25.20, 3.50, -7.78),
    ["Daily Quests Board"]    = Vector3.new(56.85, 4.00, -1.98),
    ["Daily Quests Lever"]    = Vector3.new(51.40, 4.00, 11.60),
    ["Class Shop"]            = Vector3.new(6.30, 4.00, 31.95),
    ["Ranger NPC (Shop)"]     = Vector3.new(16.40, -15.00, 33.00),
    ["Medic NPC (Shop)"]      = Vector3.new(-3.73, -15.00, 30.89),
    ["Currency Exchanger"]    = Vector3.new(34.41, 4.00, 37.97),
    ["Teleporter 1 (Lobby)"]  = Vector3.new(-28.39, 10.53, -32.63),
    ["Teleporter 2 (Lobby)"]  = Vector3.new(-18.50, 10.53, 0.42),
    ["Teleporter 3 (Lobby)"]  = Vector3.new(-24.50, 10.53, 33.92),
}

local CLASS_LIST = {
    "Camper", "Ranger", "Lumberjack", "Support", "Medic", "Hunter", "Cook",
    "Chef", "Fisherman", "Explorer", "Scavenger", "Escape Artist", "Gambler",
    "Base Defender", "Feaster", "Nightcrawler", "Beastmaster", "Alien Scientist",
    "Alien", "Assassin", "Grenadier", "Woodsman", "Pyromaniac", "Undead",
    "Poison Master", "Blacksmith", "Witch", "Vampire", "Gunslinger",
    "Big Game Hunter", "Bunny", "Elemental", "Fire Bandit", "Engineer",
    "Farmer", "Brawler", "Zookeeper", "Berserker", "Cyborg", "Snowman",
    "Gifting Elf", "Ghost Ranger", "Brute"
}
table.sort(CLASS_LIST)

-- ==================== CONFIG PROFILE STORAGE ====================
local ConfigFolder = "XLuna_99Nights_Configs"
pcall(function()
    if makefolder and not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end)

local function GetConfigList()
    local list = {}
    pcall(function()
        if listfiles then
            for _, f in ipairs(listfiles(ConfigFolder)) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end)
    if #list == 0 then table.insert(list, "default") end
    return list
end

local function SaveConfig(name)
    name = (name and name ~= "") and name or "default"
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(State)
            writefile(ConfigFolder .. "/" .. name .. ".json", data)
            WindUI:Notify({Title = "Config Saved", Content = "Saved profile: " .. name, Duration = 2.5})
        end
    end)
end

local function LoadConfig(name)
    name = (name and name ~= "") and name or "default"
    pcall(function()
        local path = ConfigFolder .. "/" .. name .. ".json"
        if isfile and isfile(path) then
            local raw = readfile(path)
            local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if State[k] ~= nil then
                        State[k] = v
                    end
                end
                WindUI:Notify({Title = "Config Loaded", Content = "Loaded profile: " .. name, Duration = 2.5})
            end
        else
            WindUI:Notify({Title = "Config Missing", Content = "File not found: " .. path, Duration = 2.5})
        end
    end)
end

-- ==================== HELPER FUNCTIONS ====================
local function GetCharacter()
    return LP and LP.Character
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function SafeTeleport(targetPos)
    local hrp = GetRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(targetPos)
    end
end

local function GetCampfire()
    local camp = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground") and workspace.Map.Campground:FindFirstChild("MainFire")
    if not camp then
        camp = workspace:FindFirstChild("MainFire")
    end
    return camp
end

local function GetItemBag()
    if LP:FindFirstChild("Inventory") then
        for _, it in ipairs(LP.Inventory:GetChildren()) do
            if it:HasTag("ItemBag") or it.Name:find("Sack") or it.Name:find("Bag") then
                return it
            end
        end
    end
    return nil
end

local function GetEquippedWeapon()
    if LP.Character then
        for _, it in ipairs(LP.Character:GetChildren()) do
            if it:IsA("Model") and (it:GetAttribute("WeaponDamage") or it:GetAttribute("ToolName")) then
                return it
            end
        end
    end
    if LP:FindFirstChild("Inventory") then
        for _, it in ipairs(LP.Inventory:GetChildren()) do
            if it:IsA("Model") and (it:GetAttribute("WeaponDamage") or it:GetAttribute("ToolName")) then
                return it
            end
        end
    end
    return nil
end

-- ==================== CREATE WINDUI WINDOW ====================
local windowTitle = isMatch and "99 Nights: Survival Match" or "99 Nights: Forest Lobby"
local Window = WindUI:CreateWindow({
    Title = windowTitle,
    Author = "By XLunaHUB",
    Folder = "XLuna_99Nights",
    Icon = "tree-pine",
    Size = UDim2.fromOffset(630, 490),
    Theme = "Dark",
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "tree-pine",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("10B981"),
            Color3.fromHex("047857")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

-- LeftControl Clean Toggle Keybind
local isToggling = false
local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        if not isToggling then
            isToggling = true
            pcall(function() Window:Toggle() end)
            task.delay(0.2, function() isToggling = false end)
        end
    end
end)

-- Standalone Floating Draggable Button
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "XLuna_99Nights_FloatingToggle"
floatGui.ResetOnSpawn = false
pcall(function()
    if gethui then
        floatGui.Parent = gethui()
    elseif CoreGui then
        floatGui.Parent = CoreGui
    else
        floatGui.Parent = LP:WaitForChild("PlayerGui")
    end
end)

local floatBtn = Instance.new("TextButton")
floatBtn.Name = "ToggleButton"
floatBtn.Size = UDim2.fromOffset(46, 46)
floatBtn.Position = UDim2.new(0.04, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
floatBtn.Text = "ð"
floatBtn.TextSize = 22
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.AutoButtonColor = true
floatBtn.Parent = floatGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 23)
btnCorner.Parent = floatBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 2
btnStroke.Color = Color3.fromRGB(4, 120, 87)
btnStroke.Parent = floatBtn

do
    local dragging = false
    local dragInput, dragStart, startPos
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    floatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    floatBtn.MouseButton1Click:Connect(function()
        pcall(function() Window:Toggle() end)
    end)
end

-- ==================== IN-MATCH SURVIVAL SUITE TABS ====================
if isMatch then
    local TabSurvival = Window:Tab({Title = "Survival & Fire", Icon = "flame"})
    local TabChests   = Window:Tab({Title = "Chests & Loot",   Icon = "package"})
    local TabCombat   = Window:Tab({Title = "Combat & Harvest",Icon = "sword"})
    local TabNav      = Window:Tab({Title = "Navigation",      Icon = "compass"})
    local TabVisuals  = Window:Tab({Title = "Visuals & ESP",   Icon = "eye"})
    local TabMovement = Window:Tab({Title = "Movement",        Icon = "gauge"})
    local TabConfig   = Window:Tab({Title = "Config",          Icon = "settings"})

    -- ---------- TAB 1: SURVIVAL & CAMPFIRE ----------
    TabSurvival:Section({Title = "Campfire Fuel Automation"})

    TabSurvival:Toggle({
        Title = "Auto Feed Campfire",
        Desc = "Automatically feeds nearby logs, coal, and canisters into the fire",
        Value = false,
        Callback = function(val)
            State.AutoFeedCampfire = val
        end
    })

    TabSurvival:Button({
        Title = "Feed Campfire Now",
        Desc = "Feeds available burnable items in camp into the campfire immediately",
        Callback = function()
            local camp = GetCampfire()
            if not camp or not RE.RequestBurnItem then
                WindUI:Notify({Title = "Campfire", Content = "Campfire not found", Duration = 2.5})
                return
            end

            local campPos = Vector3.new(0, 1.5, 0)
            local fed = 0
            if workspace:FindFirstChild("Items") then
                for _, it in ipairs(workspace.Items:GetChildren()) do
                    if it:GetAttribute("BurnFuel") then
                        local pos = it:IsA("Model") and it:GetPivot().Position or (it:IsA("BasePart") and it.Position)
                        if pos and (pos - campPos).Magnitude < 40 then
                            pcall(function()
                                RE.RequestBurnItem:FireServer(camp, it)
                                fed = fed + 1
                            end)
                            task.wait(0.1)
                        end
                    end
                end
            end
            WindUI:Notify({Title = "Campfire", Content = "Fed " .. fed .. " items to the fire!", Duration = 2.5})
        end
    })

    TabSurvival:Section({Title = "Health & Hunger Management"})

    TabSurvival:Toggle({
        Title = "Auto Eat Food",
        Desc = "Automatically consumes Carrots, Stew, or Berries when Hunger < 75",
        Value = false,
        Callback = function(val)
            State.AutoEatFood = val
        end
    })

    TabSurvival:Button({
        Title = "Eat Nearest Food Now",
        Desc = "Consumes the closest food item to replenish hunger immediately",
        Callback = function()
            local hrp = GetRootPart()
            if not hrp or not RE.RequestConsumeItem or not workspace:FindFirstChild("Items") then return end

            local closestFood, minDist = nil, math.huge
            for _, it in ipairs(workspace.Items:GetChildren()) do
                if it:GetAttribute("RestoreHunger") then
                    local pos = it:IsA("Model") and it:GetPivot().Position or (it:IsA("BasePart") and it.Position)
                    if pos then
                        local d = (pos - hrp.Position).Magnitude
                        if d < minDist then
                            minDist = d
                            closestFood = it
                        end
                    end
                end
            end

            if closestFood then
                pcall(function()
                    RE.RequestConsumeItem:InvokeServer(closestFood)
                end)
                WindUI:Notify({Title = "Hunger", Content = "Consumed " .. closestFood.Name, Duration = 2.5})
            else
                WindUI:Notify({Title = "Hunger", Content = "No food found nearby", Duration = 2.5})
            end
        end
    })

    TabSurvival:Section({Title = "Revive Automation"})

    TabSurvival:Toggle({
        Title = "Auto Self-Revive",
        Desc = "Automatically revives yourself instantly whenever knocked down",
        Value = false,
        Callback = function(val)
            State.AutoSelfRevive = val
        end
    })

    TabSurvival:Button({
        Title = "Self Revive Now",
        Desc = "Fires instant revive signal to recover character",
        Callback = function()
            if RE.RequestSelfRevive then
                pcall(function()
                    RE.RequestSelfRevive:FireServer()
                end)
                WindUI:Notify({Title = "Revive", Content = "Sent self-revive signal", Duration = 2})
            end
        end
    })

    TabSurvival:Toggle({
        Title = "Auto Revive Teammates",
        Desc = "Automatically sends revive signal to knocked teammates",
        Value = false,
        Callback = function(val)
            State.AutoReviveTeammates = val
        end
    })

    TabSurvival:Button({
        Title = "Revive All Teammates Now",
        Desc = "Triggers team-wide revive sweep",
        Callback = function()
            local count = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character and RE.RequestRevivePlayer then
                    pcall(function()
                        RE.RequestRevivePlayer:FireServer(plr.Character)
                        count = count + 1
                    end)
                    task.wait(0.15)
                end
            end
            WindUI:Notify({Title = "Revive", Content = "Sent revive to " .. count .. " players", Duration = 2.5})
        end
    })

    -- ---------- TAB 2: CHESTS & LOOT MAGNET ----------
    TabChests:Section({Title = "Chest Sweep Automation"})

    TabChests:Button({
        Title = "Open All Chests (Map-Wide)",
        Desc = "Instantly sweeps and opens all unopened chests across the entire map",
        Callback = function()
            task.spawn(function()
                if not RE.RequestOpenItemChest or not workspace:FindFirstChild("Items") then
                    WindUI:Notify({Title = "Chests", Content = "Chest remote or items folder not found", Duration = 2.5})
                    return
                end

                local uid = tostring(LP.UserId)
                local opened = 0
                for _, it in ipairs(workspace.Items:GetChildren()) do
                    if it:GetAttribute("Interaction") == "ItemChest" and not it:GetAttribute(uid .. "Opened") and not it:GetAttribute("Locked") then
                        pcall(function()
                            RE.RequestOpenItemChest:FireServer(it)
                            opened = opened + 1
                        end)
                        task.wait(0.08)
                    end
                end
                WindUI:Notify({Title = "Chests", Content = "Successfully unlocked " .. opened .. " chests!", Duration = 3})
            end)
        end
    })

    TabChests:Toggle({
        Title = "Auto Open Nearby Chests",
        Desc = "Continuously detects and unlocks unopened chests within 80 studs",
        Value = false,
        Callback = function(val)
            State.AutoOpenChests = val
        end
    })

    TabChests:Section({Title = "Loot Magnet & Item Vacuum"})

    TabChests:Toggle({
        Title = "Auto Loot Vacuum",
        Desc = "Automatically sweeps valuables (Ammo, Coal, Food, Gems) into bag",
        Value = false,
        Callback = function(val)
            State.AutoLootVacuum = val
        end
    })

    TabChests:Button({
        Title = "Vacuum Nearby Items to Bag Now",
        Desc = "Packs all items within 40 studs into your bag",
        Callback = function()
            local sack = GetItemBag()
            local hrp = GetRootPart()
            if not sack or not hrp or not RE.RequestBagStoreItem or not workspace:FindFirstChild("Items") then
                WindUI:Notify({Title = "Loot Vacuum", Content = "Bag or items folder not available", Duration = 2.5})
                return
            end

            local stored = 0
            for _, it in ipairs(workspace.Items:GetChildren()) do
                local pos = it:IsA("Model") and it:GetPivot().Position or (it:IsA("BasePart") and it.Position)
                if pos and (pos - hrp.Position).Magnitude < 40 and it:GetAttribute("Interaction") == "Item" then
                    pcall(function()
                        RE.RequestBagStoreItem:InvokeServer(sack, it)
                        stored = stored + 1
                    end)
                    task.wait(0.1)
                end
            end
            WindUI:Notify({Title = "Loot Vacuum", Content = "Packed " .. stored .. " items into bag!", Duration = 2.5})
        end
    })

    TabChests:Button({
        Title = "Drop All Items from Bag",
        Desc = "Empties all items stored in your bag onto the ground",
        Callback = function()
            local sack = GetItemBag()
            if sack and RE.RequestBagDropItem then
                pcall(function()
                    RE.RequestBagDropItem:FireServer(sack)
                end)
                WindUI:Notify({Title = "Bag", Content = "Dropped all bag items", Duration = 2})
            end
        end
    })

    -- ---------- TAB 3: COMBAT & FOLIAGE ----------
    TabCombat:Section({Title = "Mob Combat Automation"})

    TabCombat:Toggle({
        Title = "Mob Kill Aura",
        Desc = "Attacks hostile mobs (Wolves, Cultists, Bears) within range",
        Value = false,
        Callback = function(val)
            State.KillAura = val
        end
    })

    TabCombat:Slider({
        Title = "Kill Aura Radius (Studs)",
        Step = 1,
        Value = {Min = 10, Max = 50, Default = 25},
        Callback = function(val)
            State.KillAuraRadius = val
        end
    })

    TabCombat:Section({Title = "Foliage & Tree Harvesting"})

    TabCombat:Toggle({
        Title = "Auto Clear Nearby Trees",
        Desc = "Continuously clears trees and foliage within 25 studs for wood",
        Value = false,
        Callback = function(val)
            State.AutoClearFoliage = val
        end
    })

    TabCombat:Button({
        Title = "Chop Nearest Tree Now",
        Desc = "Immediately destroys the nearest tree to harvest logs",
        Callback = function()
            local hrp = GetRootPart()
            if not hrp or not RE.RequestDestroyFoliage or not workspace:FindFirstChild("Map") then return end

            local foliage = workspace.Map:FindFirstChild("Foliage")
            if not foliage then return end

            local closestTree, minDist = nil, math.huge
            for _, model in ipairs(foliage:GetChildren()) do
                if model.Name:find("Tree") or model.Name:find("Foliage") then
                    local pos = model:IsA("Model") and model:GetPivot().Position or (model:IsA("BasePart") and model.Position)
                    if pos then
                        local d = (pos - hrp.Position).Magnitude
                        if d < minDist then
                            minDist = d
                            closestTree = model
                        end
                    end
                end
            end

            if closestTree then
                pcall(function()
                    RE.RequestDestroyFoliage:InvokeServer(closestTree)
                end)
                WindUI:Notify({Title = "Foliage", Content = "Harvested tree!", Duration = 2.5})
            else
                WindUI:Notify({Title = "Foliage", Content = "No tree found nearby", Duration = 2.5})
            end
        end
    })

    -- ---------- TAB 4: NAVIGATION ----------
    TabNav:Section({Title = "Campground POI Teleports"})

    local campPoiNames = {}
    for name in pairs(CAMP_POSITIONS) do table.insert(campPoiNames, name) end
    table.sort(campPoiNames)

    local selectedCampPoi = campPoiNames[1]
    TabNav:Dropdown({
        Title = "Select Campground Location",
        Values = campPoiNames,
        Value = selectedCampPoi,
        Callback = function(val)
            selectedCampPoi = val
        end
    })

    TabNav:Button({
        Title = "Teleport to Selected Station",
        Desc = "Instantly teleports to the selected camp station",
        Callback = function()
            local target = CAMP_POSITIONS[selectedCampPoi]
            if target then
                SafeTeleport(target + Vector3.new(0, 2, 0))
                WindUI:Notify({Title = "Teleport", Content = "Arrived at: " .. selectedCampPoi, Duration = 2})
            end
        end
    })

    TabNav:Section({Title = "Fast World Shortcuts"})

    TabNav:Button({
        Title = "Teleport to Campfire (Center)",
        Desc = "Instantly returns to the main campfire (0, 1.5, 0)",
        Callback = function()
            SafeTeleport(Vector3.new(0, 3.5, 0))
            WindUI:Notify({Title = "Teleport", Content = "Returned to Main Campfire", Duration = 2})
        end
    })

    TabNav:Button({
        Title = "Teleport to Nearest Unopened Chest",
        Desc = "Navigates your character directly to the closest chest",
        Callback = function()
            local hrp = GetRootPart()
            if not hrp or not workspace:FindFirstChild("Items") then return end

            local uid = tostring(LP.UserId)
            local closestChest, minDist = nil, math.huge
            for _, it in ipairs(workspace.Items:GetChildren()) do
                if it:GetAttribute("Interaction") == "ItemChest" and not it:GetAttribute(uid .. "Opened") and not it:GetAttribute("Locked") then
                    local pos = it:IsA("Model") and it:GetPivot().Position or it.Position
                    if pos then
                        local d = (pos - hrp.Position).Magnitude
                        if d < minDist then
                            minDist = d
                            closestChest = it
                        end
                    end
                end
            end

            if closestChest then
                local pos = closestChest:IsA("Model") and closestChest:GetPivot().Position or closestChest.Position
                SafeTeleport(pos + Vector3.new(0, 3, 0))
                WindUI:Notify({Title = "Teleport", Content = "Teleported to " .. closestChest.Name, Duration = 2.5})
            else
                WindUI:Notify({Title = "Teleport", Content = "No unopened chests remaining!", Duration = 2.5})
            end
        end
    })

    -- ---------- TAB 5: VISUALS & ESP ----------
    TabVisuals:Section({Title = "Match 3D ESP Overlays"})

    TabVisuals:Toggle({
        Title = "Campfire Fuel & Distance ESP",
        Desc = "Displays fuel remaining, target, and distance to main campfire",
        Value = false,
        Callback = function(val)
            State.CampfireESP = val
        end
    })

    TabVisuals:Toggle({
        Title = "Chests ESP (Unopened Only)",
        Desc = "Highlights all unopened chests across the map with distance & tier",
        Value = false,
        Callback = function(val)
            State.ChestsESP = val
        end
    })

    TabVisuals:Toggle({
        Title = "Hostile Mobs ESP",
        Desc = "Highlights Wolves, Cultists, Bears with HP and distance",
        Value = false,
        Callback = function(val)
            State.MobsESP = val
        end
    })

    TabVisuals:Toggle({
        Title = "Food & Animals ESP",
        Desc = "Highlights Carrots, Berries, Bunnies, and Deer",
        Value = false,
        Callback = function(val)
            State.FoodESP = val
        end
    })

    TabVisuals:Toggle({
        Title = "Teammates ESP",
        Desc = "Highlights player teammates with HP, distance, and downed state",
        Value = false,
        Callback = function(val)
            State.TeammatesESP = val
        end
    })

    TabVisuals:Section({Title = "Environment Lighting"})

    local origFogEnd = Lighting.FogEnd
    local origBrightness = Lighting.Brightness
    local origAmbient = Lighting.Ambient
    local origOutdoorAmbient = Lighting.OutdoorAmbient
    local origClockTime = Lighting.ClockTime

    TabVisuals:Toggle({
        Title = "Fullbright / Night Vision",
        Desc = "Eliminates forest darkness and fog for clear visibility",
        Value = false,
        Callback = function(val)
            State.Fullbright = val
            if val then
                Lighting.FogEnd = 1e6
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                Lighting.ClockTime = 14
            else
                Lighting.FogEnd = origFogEnd
                Lighting.Brightness = origBrightness
                Lighting.Ambient = origAmbient
                Lighting.OutdoorAmbient = origOutdoorAmbient
                Lighting.ClockTime = origClockTime
            end
        end
    })

    -- ---------- TAB 6: MOVEMENT ----------
    TabMovement:Section({Title = "WalkSpeed & JumpPower"})

    TabMovement:Toggle({
        Title = "Enable Custom WalkSpeed",
        Desc = "Enforces custom player movement speed",
        Value = false,
        Callback = function(val)
            State.SpeedHack = val
            local char = GetCharacter()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val and State.WalkSpeed or 16 end
        end
    })

    TabMovement:Slider({
        Title = "WalkSpeed Multiplier",
        Step = 1,
        Value = {Min = 16, Max = 150, Default = 16},
        Callback = function(val)
            State.WalkSpeed = val
            if State.SpeedHack then
                local char = GetCharacter()
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
    })

    TabMovement:Toggle({
        Title = "Enable Custom JumpPower",
        Desc = "Enforces custom player jump strength",
        Value = false,
        Callback = function(val)
            State.JumpHack = val
            local char = GetCharacter()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val and State.JumpPower or 50
            end
        end
    })

    TabMovement:Slider({
        Title = "JumpPower Multiplier",
        Step = 1,
        Value = {Min = 50, Max = 250, Default = 50},
        Callback = function(val)
            State.JumpPower = val
            if State.JumpHack then
                local char = GetCharacter()
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = val
                end
            end
        end
    })

    TabMovement:Toggle({
        Title = "Infinite Jump",
        Desc = "Allows unlimited jumps mid-air without ground contact",
        Value = false,
        Callback = function(val)
            State.InfiniteJump = val
        end
    })

    TabMovement:Section({Title = "Noclip & Flight"})

    TabMovement:Toggle({
        Title = "Noclip",
        Desc = "Phases through trees, rocks, fences, and structures",
        Value = false,
        Callback = function(val)
            State.Noclip = val
        end
    })

    TabMovement:Toggle({
        Title = "Fly Mode",
        Desc = "Smooth 3D flight (WASD + Space to ascend, LeftShift to descend)",
        Value = false,
        Callback = function(val)
            State.FlyHack = val
        end
    })

    TabMovement:Slider({
        Title = "Fly Speed",
        Step = 1,
        Value = {Min = 20, Max = 150, Default = 45},
        Callback = function(val)
            State.FlySpeed = val
        end
    })

    -- ---------- TAB 7: CONFIG ----------
    TabConfig:Section({Title = "Profile Manager"})

    local configNameInput = "default"
    local configDropdownValues = GetConfigList()

    local ConfigDropdown = TabConfig:Dropdown({
        Title = "Select Profile",
        Values = configDropdownValues,
        Value = configDropdownValues[1] or "default",
        Callback = function(val)
            configNameInput = val
        end
    })

    TabConfig:Button({
        Title = "Save Current Config",
        Desc = "Saves current settings to disk profile",
        Callback = function()
            SaveConfig(configNameInput)
            pcall(function()
                ConfigDropdown:SetValues(GetConfigList())
            end)
        end
    })

    TabConfig:Button({
        Title = "Load Selected Config",
        Desc = "Restores settings from chosen profile",
        Callback = function()
            LoadConfig(configNameInput)
        end
    })

    TabConfig:Button({
        Title = "Reset All to Default (ALL OFF)",
        Desc = "Disables all active automation modules immediately",
        Callback = function()
            for k in pairs(State) do
                if type(State[k]) == "boolean" then
                    State[k] = false
                end
            end
            WindUI:Notify({Title = "Reset Complete", Content = "All features are set to OFF", Duration = 2.5})
        end
    })

    TabConfig:Section({Title = "Security & Anti-Detection"})

    TabConfig:Toggle({
        Title = "Anti-AFK",
        Desc = "Prevents Roblox 20-minute idle disconnection",
        Value = false,
        Callback = function(val)
            State.AntiAFK = val
        end
    })

    TabConfig:Button({
        Title = "Unload Automation Suite",
        Desc = "Cleanly disconnects all hooks and removes GUI",
        Callback = function()
            if getgenv()._XLUNA_99NIGHTS_CLEANUP then
                pcall(getgenv()._XLUNA_99NIGHTS_CLEANUP)
            end
        end
    })

-- ==================== LOBBY SUITE TABS ====================
else
    local TabLobby      = Window:Tab({Title = "Lobby & Quests", Icon = "sparkles"})
    local TabMatchmaker = Window:Tab({Title = "Matchmaking",    Icon = "compass"})
    local TabClasses    = Window:Tab({Title = "Classes & Shop", Icon = "shield"})
    local TabMovement   = Window:Tab({Title = "Movement",       Icon = "gauge"})
    local TabVisuals    = Window:Tab({Title = "Visuals & ESP",  Icon = "eye"})
    local TabConfig     = Window:Tab({Title = "Config",         Icon = "settings"})

    -- TAB 1: LOBBY & QUESTS
    TabLobby:Section({Title = "Daily Quests Automation"})

    TabLobby:Toggle({
        Title = "Auto Claim Daily Quests",
        Desc = "Continuously claims rewards for completed daily quests (Slots 1, 2, 3)",
        Value = false,
        Callback = function(val)
            State.AutoClaimDailyQuests = val
        end
    })

    TabLobby:Button({
        Title = "Roll Daily Quests Now",
        Desc = "Safely triggers the Quest Lever proximity prompt and restores position",
        Callback = function()
            task.spawn(function()
                local prompt = workspace:FindFirstChild("DailyQuests")
                    and workspace.DailyQuests:FindFirstChild("PromptPart")
                    and workspace.DailyQuests.PromptPart:FindFirstChild("PromptAttachment")
                    and workspace.DailyQuests.PromptPart.PromptAttachment:FindFirstChild("ProximityPrompt")

                local hrp = GetRootPart()
                if prompt and hrp then
                    local oldCF = hrp.CFrame
                    hrp.CFrame = workspace.DailyQuests.PromptPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.2)
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(prompt) end
                    end)
                    task.wait(0.8)
                    hrp.CFrame = oldCF
                    WindUI:Notify({Title = "Daily Quests", Content = "Quests rolled successfully!", Duration = 2.5})
                else
                    WindUI:Notify({Title = "Daily Quests", Content = "Daily Quest lever not found in workspace", Duration = 2.5})
                end
            end)
        end
    })

    TabLobby:Button({
        Title = "Claim All Completed Quests Now",
        Desc = "Instantly claims all completed daily quest rewards",
        Callback = function()
            local claimedCount = 0
            if LP:FindFirstChild("DailyQuests") and RE.RequestClaimDailyRequestReward then
                for _, q in ipairs(LP.DailyQuests:GetChildren()) do
                    if q:GetAttribute("Completed") == true and q:GetAttribute("Rewarded") ~= true then
                        local num = q:GetAttribute("QuestNumber") or tonumber(q.Name:match("%d+"))
                        if num then
                            pcall(function()
                                RE.RequestClaimDailyRequestReward:InvokeServer(num)
                                claimedCount = claimedCount + 1
                            end)
                            task.wait(0.2)
                        end
                    end
                end
            end
            WindUI:Notify({Title = "Daily Quests", Content = "Claimed " .. claimedCount .. " quest rewards!", Duration = 2.5})
        end
    })

    TabLobby:Section({Title = "Badges & Free Diamonds"})

    TabLobby:Toggle({
        Title = "Auto Claim Badge Diamonds",
        Desc = "Sweeps all unclaimed badge achievements and collects free diamonds",
        Value = false,
        Callback = function(val)
            State.AutoClaimBadges = val
        end
    })

    TabLobby:Button({
        Title = "Claim All Badge Diamonds Now",
        Desc = "One-click sweep of all unclaimed badge achievements",
        Callback = function()
            local count = 0
            local unclaimed = LP:FindFirstChild("UnclaimedBadges")
            if unclaimed and RE.RequestClaimBadgeDiamonds then
                for idStr, isAvailable in pairs(unclaimed:GetAttributes()) do
                    if isAvailable == true then
                        local idNum = tonumber(idStr)
                        if idNum then
                            pcall(function()
                                RE.RequestClaimBadgeDiamonds:FireServer(idNum)
                                count = count + 1
                            end)
                            task.wait(0.1)
                        end
                    end
                end
            end
            WindUI:Notify({Title = "Badge Rewards", Content = "Claimed diamonds for " .. count .. " badges!", Duration = 2.5})
        end
    })

    TabLobby:Section({Title = "Promo Codes"})

    TabLobby:Button({
        Title = "Redeem Common Public Codes",
        Desc = "Attempts redemption of active public codes with safe throttling",
        Callback = function()
            task.spawn(function()
                if not RE.RequestInputCode then return end
                local testCodes = {"100kmembers", "release", "forest", "99nights", "update", "halloween", "diamonds"}
                for _, code in ipairs(testCodes) do
                    pcall(function()
                        RE.RequestInputCode:InvokeServer(code, false)
                    end)
                    task.wait(2.2)
                end
                WindUI:Notify({Title = "Promo Codes", Content = "Finished submitting public codes list", Duration = 3})
            end)
        end
    })

    -- TAB 2: MATCHMAKING & TELEPORTS
    TabMatchmaker:Section({Title = "Teleporters (Fast Queue Entry)"})

    TabMatchmaker:Dropdown({
        Title = "Select Teleporter",
        Values = {"Teleporter 1", "Teleporter 2", "Teleporter 3"},
        Value = "Teleporter 1",
        Callback = function(val)
            State.SelectedTeleporter = val
        end
    })

    TabMatchmaker:Button({
        Title = "Join Selected Teleporter",
        Desc = "Safely steps into the EnterPart of the selected teleporter",
        Callback = function()
            local num = State.SelectedTeleporter:match("%d+")
            local tpModel = workspace:FindFirstChild("Teleporter" .. tostring(num))
            local enterPart = tpModel and tpModel:FindFirstChild("EnterPart")
            if enterPart then
                SafeTeleport(enterPart.Position + Vector3.new(0, 1.5, 0))
                WindUI:Notify({Title = "Teleporter", Content = "Entered " .. State.SelectedTeleporter, Duration = 2.5})
            else
                WindUI:Notify({Title = "Teleporter", Content = "Teleporter EnterPart not found", Duration = 2.5})
            end
        end
    })

    TabMatchmaker:Button({
        Title = "Leave Teleporter Queue",
        Desc = "Sends Remove signal to step out of any active queue",
        Callback = function()
            if RE.TeleportEvent then
                pcall(function() RE.TeleportEvent:FireServer("Remove") end)
                WindUI:Notify({Title = "Teleporter", Content = "Left teleporter queue", Duration = 2})
            end
        end
    })

    TabMatchmaker:Section({Title = "Fast World Navigation"})

    local locNames = {}
    for name in pairs(LOBBY_POSITIONS) do table.insert(locNames, name) end
    table.sort(locNames)

    local selectedFastLoc = locNames[1]
    TabMatchmaker:Dropdown({
        Title = "Select Destination",
        Values = locNames,
        Value = selectedFastLoc,
        Callback = function(val)
            selectedFastLoc = val
        end
    })

    TabMatchmaker:Button({
        Title = "Teleport to Destination",
        Desc = "Instantly teleports your character to the selected POI",
        Callback = function()
            local target = LOBBY_POSITIONS[selectedFastLoc]
            if target then
                SafeTeleport(target)
                WindUI:Notify({Title = "Teleport", Content = "Arrived at: " .. selectedFastLoc, Duration = 2})
            end
        end
    })

    -- TAB 3: CLASSES & SHOP
    TabClasses:Section({Title = "Active Class Management"})

    TabClasses:Toggle({
        Title = "Auto Level Up Class",
        Desc = "Automatically levels up active class when level threshold is achieved",
        Value = false,
        Callback = function(val)
            State.AutoLevelUpClass = val
        end
    })

    TabClasses:Dropdown({
        Title = "Select Class to Equip",
        Values = CLASS_LIST,
        Value = "Camper",
        Callback = function(val)
            State.SelectedClassToEquip = val
        end
    })

    TabClasses:Button({
        Title = "Equip Selected Class",
        Desc = "Equips the chosen class from your unlocked library",
        Callback = function()
            if RE.UpdateEquipped then
                pcall(function() RE.UpdateEquipped:FireServer(State.SelectedClassToEquip) end)
                WindUI:Notify({Title = "Class Equip", Content = "Equipped class: " .. State.SelectedClassToEquip, Duration = 2.5})
            end
        end
    })

    TabClasses:Section({Title = "Class Shop (Unlock with Diamonds)"})

    TabClasses:Dropdown({
        Title = "Select Class to Purchase",
        Values = CLASS_LIST,
        Value = "Ranger",
        Callback = function(val)
            State.SelectedClassToBuy = val
        end
    })

    TabClasses:Button({
        Title = "Purchase Selected Class",
        Desc = "Purchases class with Diamonds via RequestPurchaseClass remote",
        Callback = function()
            if RE.RequestPurchaseClass then
                pcall(function() RE.RequestPurchaseClass:FireServer(State.SelectedClassToBuy) end)
                WindUI:Notify({Title = "Class Shop", Content = "Sent purchase request for: " .. State.SelectedClassToBuy, Duration = 3})
            end
        end
    })

    -- TAB 4: MOVEMENT
    TabMovement:Section({Title = "WalkSpeed & JumpPower"})

    TabMovement:Toggle({
        Title = "Enable Custom WalkSpeed",
        Desc = "Enforces custom player movement speed",
        Value = false,
        Callback = function(val)
            State.SpeedHack = val
            local char = GetCharacter()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val and State.WalkSpeed or 16 end
        end
    })

    TabMovement:Slider({
        Title = "WalkSpeed Multiplier",
        Step = 1,
        Value = {Min = 16, Max = 150, Default = 16},
        Callback = function(val)
            State.WalkSpeed = val
            if State.SpeedHack then
                local char = GetCharacter()
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
    })

    TabMovement:Toggle({
        Title = "Enable Custom JumpPower",
        Desc = "Enforces custom player jump strength",
        Value = false,
        Callback = function(val)
            State.JumpHack = val
            local char = GetCharacter()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val and State.JumpPower or 50
            end
        end
    })

    TabMovement:Slider({
        Title = "JumpPower Multiplier",
        Step = 1,
        Value = {Min = 50, Max = 250, Default = 50},
        Callback = function(val)
            State.JumpPower = val
            if State.JumpHack then
                local char = GetCharacter()
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = val
                end
            end
        end
    })

    TabMovement:Toggle({
        Title = "Infinite Jump",
        Desc = "Allows unlimited jumps mid-air without ground contact",
        Value = false,
        Callback = function(val)
            State.InfiniteJump = val
        end
    })

    TabMovement:Section({Title = "Noclip & Flight"})

    TabMovement:Toggle({
        Title = "Noclip",
        Desc = "Phases through all collision boundaries, fences, and walls",
        Value = false,
        Callback = function(val)
            State.Noclip = val
        end
    })

    TabMovement:Toggle({
        Title = "Fly Mode",
        Desc = "Smooth 3D flight (WASD + Space to ascend, LeftShift to descend)",
        Value = false,
        Callback = function(val)
            State.FlyHack = val
        end
    })

    TabMovement:Slider({
        Title = "Fly Speed",
        Step = 1,
        Value = {Min = 20, Max = 150, Default = 45},
        Callback = function(val)
            State.FlySpeed = val
        end
    })

    -- TAB 5: VISUALS
    TabVisuals:Section({Title = "3D ESP Overlays"})

    TabVisuals:Toggle({
        Title = "Player ESP",
        Desc = "Highlights players with name, health, and distance tags",
        Value = false,
        Callback = function(val)
            State.PlayerESP = val
        end
    })

    TabVisuals:Toggle({
        Title = "Interactive Stations ESP",
        Desc = "Highlights Quest Boards, Class Shops, and NPCs",
        Value = false,
        Callback = function(val)
            State.StationsESP = val
        end
    })

    TabVisuals:Section({Title = "World Environment"})

    local origFogEnd = Lighting.FogEnd
    local origBrightness = Lighting.Brightness
    local origAmbient = Lighting.Ambient
    local origOutdoorAmbient = Lighting.OutdoorAmbient
    local origClockTime = Lighting.ClockTime

    TabVisuals:Toggle({
        Title = "Fullbright / Night Vision",
        Desc = "Removes darkness and fog for crystal-clear visibility",
        Value = false,
        Callback = function(val)
            State.Fullbright = val
            if val then
                Lighting.FogEnd = 1e6
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                Lighting.ClockTime = 14
            else
                Lighting.FogEnd = origFogEnd
                Lighting.Brightness = origBrightness
                Lighting.Ambient = origAmbient
                Lighting.OutdoorAmbient = origOutdoorAmbient
                Lighting.ClockTime = origClockTime
            end
        end
    })

    -- TAB 6: CONFIG
    TabConfig:Section({Title = "Profile Manager"})

    local configNameInput = "default"
    local configDropdownValues = GetConfigList()

    local ConfigDropdown = TabConfig:Dropdown({
        Title = "Select Profile",
        Values = configDropdownValues,
        Value = configDropdownValues[1] or "default",
        Callback = function(val)
            configNameInput = val
        end
    })

    TabConfig:Button({
        Title = "Save Current Config",
        Desc = "Saves current settings to disk profile",
        Callback = function()
            SaveConfig(configNameInput)
            pcall(function() ConfigDropdown:SetValues(GetConfigList()) end)
        end
    })

    TabConfig:Button({
        Title = "Load Selected Config",
        Desc = "Restores settings from chosen profile",
        Callback = function()
            LoadConfig(configNameInput)
        end
    })

    TabConfig:Button({
        Title = "Reset All to Default (ALL OFF)",
        Desc = "Disables all active automation modules immediately",
        Callback = function()
            for k in pairs(State) do
                if type(State[k]) == "boolean" then State[k] = false end
            end
            WindUI:Notify({Title = "Reset Complete", Content = "All features are set to OFF", Duration = 2.5})
        end
    })

    TabConfig:Section({Title = "Security & Anti-Detection"})

    TabConfig:Toggle({
        Title = "Anti-AFK",
        Desc = "Prevents Roblox 20-minute idle disconnection",
        Value = false,
        Callback = function(val)
            State.AntiAFK = val
        end
    })

    TabConfig:Button({
        Title = "Unload Automation Suite",
        Desc = "Cleanly disconnects all hooks and removes GUI",
        Callback = function()
            if getgenv()._XLUNA_99NIGHTS_CLEANUP then
                pcall(getgenv()._XLUNA_99NIGHTS_CLEANUP)
            end
        end
    })
end

-- ==================== SYSTEM LOOPS & RUNTIME LOGIC ====================

-- 1. Anti-AFK Connection
local afkConn = LP.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- 2. Infinite Jump Connection
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 3. Noclip Stepped Connection
local noclipConn = RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 4. Speed & Jump Persistence Stepped Connection
local speedConn = RunService.Stepped:Connect(function()
    local char = GetCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.SpeedHack and hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
        if State.JumpHack and hum.JumpPower ~= State.JumpPower then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPower
        end
    end
end)

-- 5. Smooth Flight Loop
local flyBodyVel, flyBodyGyro
local flyConn = RunService.RenderStepped:Connect(function()
    local char = GetCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if State.FlyHack and hrp and hum then
        if not flyBodyVel or flyBodyVel.Parent ~= hrp then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Velocity = Vector3.zero
            flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or flyBodyGyro.Parent ~= hrp then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.CFrame = hrp.CFrame
            flyBodyGyro.P = 9e4
            flyBodyGyro.Parent = hrp
        end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flyBodyVel.Velocity = moveDir.Unit * State.FlySpeed
        else
            flyBodyVel.Velocity = Vector3.zero
        end
        flyBodyGyro.CFrame = cam.CFrame
    else
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    end
end)

-- 6. Fullbright Enforcement
local fullbrightConn = Lighting.Changed:Connect(function()
    if State.Fullbright then
        Lighting.FogEnd = 1e6
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.ClockTime = 14
    end
end)

-- 7. High-Performance ESP Container
local espFolder = Instance.new("Folder")
espFolder.Name = "XLuna_ESP_Holder"
pcall(function()
    if CoreGui then espFolder.Parent = CoreGui else espFolder.Parent = workspace end
end)

local function ClearESP(prefix)
    for _, item in ipairs(espFolder:GetChildren()) do
        if not prefix or item.Name:sub(1, #prefix) == prefix then
            item:Destroy()
        end
    end
end

-- ESP Update Heartbeat (Every 1.0s)
local lastESPUpdate = 0
local espHeartbeat = RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastESPUpdate < 1.0 then return end
    lastESPUpdate = now

    local hrp = GetRootPart()
    local myPos = hrp and hrp.Position or Vector3.zero

    -- MATCH: Campfire ESP
    if isMatch and State.CampfireESP then
        local camp = GetCampfire()
        if camp then
            local tagId = "ESP_Campfire"
            local bb = espFolder:FindFirstChild(tagId)
            if not bb then
                bb = Instance.new("BillboardGui")
                bb.Name = tagId
                bb.Size = UDim2.fromOffset(150, 40)
                bb.AlwaysOnTop = true
                bb.Adornee = camp:IsA("Model") and (camp.PrimaryPart or camp:FindFirstChildWhichIsA("BasePart")) or camp

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(249, 115, 22)
                label.TextStrokeTransparency = 0.2
                label.TextSize = 13
                label.Font = Enum.Font.GothamBold
                label.Parent = bb
                bb.Parent = espFolder
            end
            if bb and bb:FindFirstChild("Label") then
                local fuel = camp:GetAttribute("FuelRemaining") or 0
                local target = camp:GetAttribute("FuelTarget") or 160
                local dist = math.floor((myPos - Vector3.new(0, 1.5, 0)).Magnitude)
                bb.Label.Text = string.format("ð¥ Campfire [%dm]\nFuel: %d / %d", dist, fuel, target)
            end
        end
    else
        ClearESP("ESP_Campfire")
    end

    -- MATCH: Chests ESP
    if isMatch and State.ChestsESP and workspace:FindFirstChild("Items") then
        local uid = tostring(LP.UserId)
        for _, it in ipairs(workspace.Items:GetChildren()) do
            if it:GetAttribute("Interaction") == "ItemChest" and not it:GetAttribute(uid .. "Opened") and not it:GetAttribute("Locked") then
                local tagId = "ESP_Chest_" .. it.Name .. "_" .. it:GetDebugId()
                local bb = espFolder:FindFirstChild(tagId)
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = tagId
                    bb.Size = UDim2.fromOffset(130, 30)
                    bb.AlwaysOnTop = true
                    bb.Adornee = it:IsA("Model") and (it.PrimaryPart or it:FindFirstChildWhichIsA("BasePart")) or it

                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.fromScale(1, 1)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(234, 179, 8)
                    label.TextStrokeTransparency = 0.2
                    label.TextSize = 12
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bb
                    bb.Parent = espFolder
                end
                if bb and bb:FindFirstChild("Label") then
                    local pos = it:IsA("Model") and it:GetPivot().Position or it.Position
                    local dist = math.floor((myPos - pos).Magnitude)
                    bb.Label.Text = string.format("ð¦ %s\n[%dm]", it.Name, dist)
                end
            end
        end
    else
        ClearESP("ESP_Chest_")
    end

    -- MATCH: Hostile Mobs ESP
    if isMatch and State.MobsESP and workspace:FindFirstChild("Characters") then
        local hostileTypes = {["Wolf"] = true, ["Alpha Wolf"] = true, ["Mossy Wolf"] = true, ["Bear"] = true, ["Cultist"] = true, ["Crossbow Cultist"] = true, ["Bat"] = true, ["Scorpion"] = true}
        for _, mob in ipairs(workspace.Characters:GetChildren()) do
            if hostileTypes[mob.Name] and mob:FindFirstChild("HumanoidRootPart") then
                local tagId = "ESP_Mob_" .. mob.Name .. "_" .. mob:GetDebugId()
                local bb = espFolder:FindFirstChild(tagId)
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = tagId
                    bb.Size = UDim2.fromOffset(130, 30)
                    bb.AlwaysOnTop = true
                    bb.Adornee = mob.HumanoidRootPart

                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.fromScale(1, 1)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(239, 68, 68)
                    label.TextStrokeTransparency = 0.2
                    label.TextSize = 12
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bb
                    bb.Parent = espFolder
                end
                if bb and bb:FindFirstChild("Label") then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local hp = hum and math.floor(hum.Health) or (mob:GetAttribute("Health") or 100)
                    local dist = math.floor((myPos - mob.HumanoidRootPart.Position).Magnitude)
                    bb.Label.Text = string.format("ð %s [%dm]\n%d HP", mob.Name, dist, hp)
                end
            end
        end
    else
        ClearESP("ESP_Mob_")
    end

    -- MATCH: Food & Animals ESP
    if isMatch and State.FoodESP then
        if workspace:FindFirstChild("Characters") then
            for _, animal in ipairs(workspace.Characters:GetChildren()) do
                if (animal.Name == "Bunny" or animal.Name == "Deer") and animal:FindFirstChild("HumanoidRootPart") then
                    local tagId = "ESP_Animal_" .. animal.Name .. "_" .. animal:GetDebugId()
                    local bb = espFolder:FindFirstChild(tagId)
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name = tagId
                        bb.Size = UDim2.fromOffset(120, 24)
                        bb.AlwaysOnTop = true
                        bb.Adornee = animal.HumanoidRootPart

                        local label = Instance.new("TextLabel")
                        label.Name = "Label"
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(74, 222, 128)
                        label.TextStrokeTransparency = 0.2
                        label.TextSize = 11
                        label.Font = Enum.Font.GothamMedium
                        label.Parent = bb
                        bb.Parent = espFolder
                    end
                    if bb and bb:FindFirstChild("Label") then
                        local dist = math.floor((myPos - animal.HumanoidRootPart.Position).Magnitude)
                        bb.Label.Text = string.format("ð¥ %s [%dm]", animal.Name, dist)
                    end
                end
            end
        end
    else
        ClearESP("ESP_Animal_")
    end

    -- MATCH & LOBBY: Teammates / Players ESP
    if (State.PlayerESP or State.TeammatesESP) then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local pHrp = char.HumanoidRootPart
                local hum = char:FindFirstChildOfClass("Humanoid")
                local tagId = "ESP_Player_" .. plr.Name

                local bb = espFolder:FindFirstChild(tagId)
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = tagId
                    bb.Size = UDim2.fromOffset(130, 36)
                    bb.AlwaysOnTop = true
                    bb.Adornee = pHrp

                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.fromScale(1, 1)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(56, 189, 248)
                    label.TextStrokeTransparency = 0.2
                    label.TextSize = 12
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bb
                    bb.Parent = espFolder
                end

                if bb and bb:FindFirstChild("Label") then
                    local dist = math.floor((myPos - pHrp.Position).Magnitude)
                    local hp = hum and math.floor(hum.Health) or 100
                    local downed = char:GetAttribute("Downed") and " [DOWNED]" or ""
                    bb.Label.Text = string.format("%s%s\n[%d HP | %dm]", plr.DisplayName, downed, hp, dist)
                end
            end
        end
    else
        ClearESP("ESP_Player_")
    end

    -- LOBBY: Stations ESP
    if not isMatch and State.StationsESP then
        for name, pos in pairs(LOBBY_POSITIONS) do
            local tagId = "ESP_Station_" .. name
            local bb = espFolder:FindFirstChild(tagId)
            if not bb then
                bb = Instance.new("BillboardGui")
                bb.Name = tagId
                bb.Size = UDim2.fromOffset(140, 24)
                bb.AlwaysOnTop = true

                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 1
                part.Position = pos
                part.Parent = bb
                bb.Adornee = part

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(251, 191, 36)
                label.TextStrokeTransparency = 0.2
                label.TextSize = 12
                label.Font = Enum.Font.GothamMedium
                label.Parent = bb
                bb.Parent = espFolder
            end

            if bb and bb:FindFirstChild("Label") then
                local dist = math.floor((myPos - pos).Magnitude)
                bb.Label.Text = string.format("ð %s [%dm]", name, dist)
            end
        end
    else
        ClearESP("ESP_Station_")
    end
end)

-- 8. Background Automation Worker Loop
local isAutomationRunning = true
task.spawn(function()
    while isAutomationRunning do
        task.wait(1.2)

        -- IN-MATCH AUTOMATIONS
        if isMatch then
            local hrp = GetRootPart()
            local myPos = hrp and hrp.Position

            -- A. Auto Self Revive
            if State.AutoSelfRevive and RE.RequestSelfRevive and LP.Character then
                local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                if (hum and hum.Health <= 0) or LP.Character:GetAttribute("Downed") == true then
                    pcall(function() RE.RequestSelfRevive:FireServer() end)
                end
            end

            -- B. Auto Revive Knocked Teammates
            if State.AutoReviveTeammates and RE.RequestRevivePlayer and myPos then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character and plr.Character:GetAttribute("Downed") == true then
                        local pHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if pHrp and (pHrp.Position - myPos).Magnitude < 30 then
                            pcall(function() RE.RequestRevivePlayer:FireServer(plr.Character) end)
                            task.wait(0.2)
                        end
                    end
                end
            end

            -- C. Auto Eat Food (When Hunger < 75)
            if State.AutoEatFood and RE.RequestConsumeItem and myPos and workspace:FindFirstChild("Items") then
                local hunger = LP:GetAttribute("Hunger") or 100
                if hunger < 75 then
                    for _, it in ipairs(workspace.Items:GetChildren()) do
                        if it:GetAttribute("RestoreHunger") then
                            local pos = it:IsA("Model") and it:GetPivot().Position or (it:IsA("BasePart") and it.Position)
                            if pos and (pos - myPos).Magnitude < 25 then
                                pcall(function() RE.RequestConsumeItem:InvokeServer(it) end)
                                task.wait(0.5)
                                break
                            end
                        end
                    end
                end
            end

            -- D. Auto Feed Campfire
            if State.AutoFeedCampfire and RE.RequestBurnItem and workspace:FindFirstChild("Items") then
                local camp = GetCampfire()
                if camp then
                    local campPos = Vector3.new(0, 1.5, 0)
                    for _, it in ipairs(workspace.Items:GetChildren()) do
                        if it:GetAttribute("BurnFuel") then
                            local pos = it:IsA("Model") and it:GetPivot().Position or (it:IsA("BasePart") and it.Position)
                            if pos and (pos - campPos).Magnitude < 30 then
                                pcall(function() RE.RequestBurnItem:FireServer(camp, it) end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end

            -- E. Auto Open Nearby Chests
            if State.AutoOpenChests and RE.RequestOpenItemChest and myPos and workspace:FindFirstChild("Items") then
                local uid = tostring(LP.UserId)
                for _, it in ipairs(workspace.Items:GetChildren()) do
                    if it:GetAttribute("Interaction") == "ItemChest" and not it:GetAttribute(uid .. "Opened") and not it:GetAttribute("Locked") then
                        local pos = it:IsA("Model") and it:GetPivot().Position or it.Position
                        if pos and (pos - myPos).Magnitude < 60 then
                            pcall(function() RE.RequestOpenItemChest:FireServer(it) end)
                            task.wait(0.2)
                        end
                    end
                end
            end

            -- F. Auto Loot Vacuum (Store into bag)
            if State.AutoLootVacuum and RE.RequestBagStoreItem and myPos and workspace:FindFirstChild("Items") then
                local sack = GetItemBag()
                if sack then
                    local valuableNames = {["Coal"]=true, ["Carrot"]=true, ["Cake"]=true, ["Berry"]=true, ["Bolt"]=true, ["Fuel Canister"]=true, ["Revolver Ammo"]=true, ["Rifle Ammo"]=true, ["Coin Stack"]=true}
                    for _, it in ipairs(workspace.Items:GetChildren()) do
                        if valuableNames[it.Name] and it:GetAttribute("Interaction") == "Item" then
                            local pos = it:IsA("Model") and it:GetPivot().Position or (it:IsA("BasePart") and it.Position)
                            if pos and (pos - myPos).Magnitude < 35 then
                                pcall(function() RE.RequestBagStoreItem:InvokeServer(sack, it) end)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end

            -- G. Mob Kill Aura
            if State.KillAura and RE.ToolDamageObject and myPos and workspace:FindFirstChild("Characters") then
                local weapon = GetEquippedWeapon()
                if weapon then
                    local hostileTypes = {["Wolf"] = true, ["Alpha Wolf"] = true, ["Mossy Wolf"] = true, ["Bear"] = true, ["Cultist"] = true, ["Crossbow Cultist"] = true, ["Bat"] = true, ["Scorpion"] = true}
                    for _, mob in ipairs(workspace.Characters:GetChildren()) do
                        if hostileTypes[mob.Name] and mob:FindFirstChild("HumanoidRootPart") then
                            local dist = (mob.HumanoidRootPart.Position - myPos).Magnitude
                            if dist <= State.KillAuraRadius then
                                local hitId = tostring(math.random(10000, 999999)) .. "_" .. math.abs(LP.UserId)
                                pcall(function()
                                    RE.ToolDamageObject:InvokeServer(mob, weapon, hitId, LP.Character.HumanoidRootPart.CFrame, false)
                                end)
                                task.wait(0.15)
                            end
                        end
                    end
                end
            end

            -- H. Auto Clear Foliage
            if State.AutoClearFoliage and RE.RequestDestroyFoliage and myPos and workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Foliage") then
                for _, foliage in ipairs(workspace.Map.Foliage:GetChildren()) do
                    if foliage.Name:find("Tree") or foliage.Name:find("Foliage") then
                        local pos = foliage:IsA("Model") and foliage:GetPivot().Position or (foliage:IsA("BasePart") and foliage.Position)
                        if pos and (pos - myPos).Magnitude < 25 then
                            pcall(function() RE.RequestDestroyFoliage:InvokeServer(foliage) end)
                            task.wait(0.4)
                            break
                        end
                    end
                end
            end

        -- LOBBY AUTOMATIONS
        else
            -- Auto Claim Completed Daily Quests
            if State.AutoClaimDailyQuests and RE.RequestClaimDailyRequestReward and LP:FindFirstChild("DailyQuests") then
                for _, q in ipairs(LP.DailyQuests:GetChildren()) do
                    if q:GetAttribute("Completed") == true and q:GetAttribute("Rewarded") ~= true then
                        local num = q:GetAttribute("QuestNumber") or tonumber(q.Name:match("%d+"))
                        if num then
                            pcall(function() RE.RequestClaimDailyRequestReward:InvokeServer(num) end)
                            task.wait(0.5)
                        end
                    end
                end
            end

            -- Auto Claim Unclaimed Badges
            if State.AutoClaimBadges and RE.RequestClaimBadgeDiamonds then
                local unclaimed = LP:FindFirstChild("UnclaimedBadges")
                if unclaimed then
                    for idStr, isAvailable in pairs(unclaimed:GetAttributes()) do
                        if isAvailable == true then
                            local idNum = tonumber(idStr)
                            if idNum then
                                pcall(function() RE.RequestClaimBadgeDiamonds:FireServer(idNum) end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end

            -- Auto Level Up Active Class
            if State.AutoLevelUpClass and RE.RequestLevelUpClass and LP:FindFirstChild("ClassProgress") then
                for _, c in ipairs(LP.ClassProgress:GetChildren()) do
                    if c:GetAttribute("CanLevelUp") == true then
                        pcall(function() RE.RequestLevelUpClass:FireServer(c.Name) end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- ==================== MASTER CLEANUP HANDLER ====================
getgenv()._XLUNA_99NIGHTS_CLEANUP = function()
    isAutomationRunning = false

    pcall(function() keybindConn:Disconnect() end)
    pcall(function() afkConn:Disconnect() end)
    pcall(function() jumpConn:Disconnect() end)
    pcall(function() noclipConn:Disconnect() end)
    pcall(function() speedConn:Disconnect() end)
    pcall(function() flyConn:Disconnect() end)
    pcall(function() fullbrightConn:Disconnect() end)
    pcall(function() espHeartbeat:Disconnect() end)

    if flyBodyVel then pcall(function() flyBodyVel:Destroy() end) end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end

    -- Reset Lighting
    pcall(function()
        Lighting.FogEnd = origFogEnd
        Lighting.Brightness = origBrightness
        Lighting.Ambient = origAmbient
        Lighting.OutdoorAmbient = origOutdoorAmbient
        Lighting.ClockTime = origClockTime
    end)

    -- Reset Character
    pcall(function()
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)

    -- Destroy UI & ESP
    pcall(function() floatGui:Destroy() end)
    pcall(function() espFolder:Destroy() end)
    pcall(function() Window:Destroy() end)

    getgenv()._XLUNA_99NIGHTS_CLEANUP = nil
end

WindUI:Notify({
    Title = "XLunaHUB Loaded",
    Content = (isMatch and "Survival Match Suite" or "Lobby Suite") .. " Ready! LeftControl to toggle.",
    Duration = 3.5
})
