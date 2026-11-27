-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
    â                     DANDY'S WORLD â XLUNAHUB                         â
    â               Universal Advanced Automation Suite                    â
    â                   Engineered for Supreme Quality                     â
    â                         Author: By XLunaHUB                          â
    â                       Default: STRICTLY ALL OFF                      â
    ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
]]

-- ==================== CORE SERVICES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ==================== CLEANUP PREVIOUS INSTANCE ====================
if getgenv()._DANDYS_WORLD_CLEANUP then
    pcall(getgenv()._DANDYS_WORLD_CLEANUP)
end

-- ==================== GAME MODULES & REMOTES ====================
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local SkillcheckUpdate = Events and Events:WaitForChild("SkillcheckUpdate", 10)
local AntiCheatTrigger = Events and Events:WaitForChild("AntiCheatTrigger", 10)

local HudPort = nil
pcall(function()
    HudPort = require(ReplicatedStorage.SharedUtils.HudPort)
end)
local Skillchecks = HudPort and HudPort.get("Skillchecks")

local Audio = nil
pcall(function()
    Audio = require(ReplicatedStorage.SharedUtils.Audio)
end)

local SkillCheckController = nil
pcall(function()
    SkillCheckController = require(ReplicatedStorage.Modules.ClientUI.SkillCheckController)
end)

-- ==================== WINDUI LIBRARY LOADER ====================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ==================== STATE CONFIGURATION (ALL OFF DEFAULT) ====================
local State = {
    -- Automation
    AutoSkillCheck = false,
    AutoInteractGen = false,
    AutoDisengageDanger = false,
    DangerDistance = 35,
    AutoCollectItems = false,
    ItemCollectRange = 25,
    AutoTeleportElevator = false,

    -- Visuals (ESP)
    TwistedESP = false,
    GeneratorESP = false,
    ItemsESP = false,
    ElevatorESP = false,
    FullBright = false,
    TwistedRadar = false,

    -- Player & Mobility
    InfiniteStamina = false,
    SpeedHack = false,
    WalkSpeed = 25,
    Noclip = false,
    AntiAFK = false,
}

-- Cooldown tracker to prevent disengage/re-engage infinite thrashing
local DangerDisengageCooldown = 0

-- ==================== ANTI-CHEAT METAMETHOD DETOUR ====================
local oldNamecall
if hookmetamethod and getnamecallmethod and checkcaller then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and method == "FireServer" then
            if self == AntiCheatTrigger or (self and self.Name == "AntiCheatTrigger") then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
end

local function applyCollisionExemption(char)
    if char then
        pcall(function()
            char:SetAttribute("CollisionExempt", true)
        end)
    end
end
applyCollisionExemption(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(applyCollisionExemption)

-- ==================== CONFIG PROFILE SYSTEM ====================
local ConfigFolder = "DandysWorld_Configs"
pcall(function()
    if makefolder then makefolder(ConfigFolder) end
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
            WindUI:Notify({Title = "Config Saved", Content = "Saved profile: " .. name, Duration = 3})
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
                WindUI:Notify({Title = "Config Loaded", Content = "Loaded profile: " .. name .. ". Re-toggle values to update.", Duration = 3})
            end
        else
            WindUI:Notify({Title = "Config Missing", Content = "File not found: " .. path, Duration = 3})
        end
    end)
end

local function ResetConfig()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    WindUI:Notify({Title = "Config Reset", Content = "All features reset to OFF.", Duration = 3})
end

-- ==================== AUTO SKILL CHECK ENGINE (NATURAL & CLEAN) ====================
if SkillcheckUpdate then
    SkillcheckUpdate.OnClientInvoke = function(a1, a2, a3)
        if State.AutoSkillCheck then
            -- 1. Realistic human reaction window (120ms - 180ms) prevents instantaneous response kicks
            task.wait(0.12 + math.random() * 0.06)

            -- 2. Trigger Great / Gold hit effects
            pcall(function()
                if Audio and Audio.PlayOne then
                    Audio:PlayOne("Sounds.UI.SkillCheck.Correct")
                    Audio:PlayOne("Sounds.UI.SkillCheck.GoldAreaHit")
                end
                if Skillchecks and Skillchecks.fire then
                    Skillchecks:fire("result", "great")
                end
                -- Clean up any residual skill check wheel or prompt UI immediately
                if SkillCheckController and SkillCheckController.hideAllUI then
                    SkillCheckController.hideAllUI()
                end
            end)

            -- 3. Return appropriate success signature based on minigame variant
            if type(a2) == "table" then
                if a2.type == "treadmill" or a2.type == "stealthlock" then
                    return true
                else
                    return "supercomplete"
                end
            end
            return "supercomplete"
        end

        if SkillCheckController and SkillCheckController.handleInvoke then
            return SkillCheckController.handleInvoke(a1, a2, a3)
        end
        return "noinput"
    end
end

-- ==================== ESP SYSTEM CORE (OPTIMIZED FOLDER TRAVERSAL) ====================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "XLunaHUB_ESP_Storage"
pcall(function()
    if gethui then
        ESPFolder.Parent = gethui()
    else
        ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

local ActiveESPTargets = {}

local function createBillboard(name, targetPart, color, textOffset)
    if not targetPart or not targetPart:IsA("BasePart") then return nil end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_" .. name
    bb.Adornee = targetPart
    bb.Size = UDim2.new(0, 160, 0, 40)
    bb.StudsOffset = textOffset or Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.ResetOnSpawn = false
    bb.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = bb

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Dist"
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextSize = 11
    distLabel.TextStrokeTransparency = 0.4
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Parent = bb

    return bb, label, distLabel
end

local function createHighlight(model, color)
    if not model or not model:IsA("Model") then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.Adornee = model
    hl.FillColor = color
    hl.FillTransparency = 0.65
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.1
    hl.Parent = ESPFolder
    return hl
end

local function clearAllESP()
    for _, item in pairs(ActiveESPTargets) do
        if item.bb then pcall(function() item.bb:Destroy() end) end
        if item.hl then pcall(function() item.hl:Destroy() end) end
    end
    table.clear(ActiveESPTargets)
    ESPFolder:ClearAllChildren()
end

-- ==================== LIGHTING / FULLBRIGHT CORE ====================
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
}

local function applyFullBright(enabled)
    if enabled then
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end

-- ==================== INVENTORY CHECK HELPER ====================
local function hasFreeInventorySlot()
    local char = LocalPlayer.Character
    local inv = char and char:FindFirstChild("Inventory")
    if not inv then return true end
    local s1 = inv:FindFirstChild("Slot1")
    local s2 = inv:FindFirstChild("Slot2")
    local s3 = inv:FindFirstChild("Slot3")
    return (s1 and s1.Value == "None") or (s2 and s2.Value == "None") or (s3 and s3.Value == "None")
end

-- ==================== SPEED MANAGEMENT (SMOOTH & ANTI-STUTTER) ====================
local function updateSpeed()
    local char = LocalPlayer.Character
    local stats = char and char:FindFirstChild("Stats")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local wsVal = stats and stats:FindFirstChild("WalkSpeed")
    local rsVal = stats and stats:FindFirstChild("RunSpeed")

    if State.SpeedHack then
        if wsVal then wsVal.Value = State.WalkSpeed end
        if rsVal then rsVal.Value = State.WalkSpeed + 8 end
        if hum then hum.WalkSpeed = State.WalkSpeed end
    else
        if wsVal then wsVal.Value = 15 end
        if rsVal then rsVal.Value = 25 end
        if hum then hum.WalkSpeed = 15 end
    end
end
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 10)
    char:WaitForChild("Stats", 10)
    updateSpeed()
end)

-- ==================== MAIN LOOP WORKERS ====================

-- 1. Automation Worker (Auto Generator Repair, Auto Disengage, Auto Item Collect)
task.spawn(function()
    while true do
        task.wait(0.25)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local playerPos = root and root.Position

        if char and root and playerPos then
            local currentRoom = workspace:FindFirstChild("CurrentRoom")
            local activeMap = currentRoom and currentRoom:GetChildren()[1]
            local isDecoding = char:FindFirstChild("Decoding") and char.Decoding.Value ~= nil

            -- A. Auto Disengage on Danger Check
            if State.AutoDisengageDanger and isDecoding and activeMap and activeMap:FindFirstChild("Monsters") then
                for _, monster in ipairs(activeMap.Monsters:GetChildren()) do
                    if monster:IsA("Model") and monster ~= char then
                        local mPart = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildWhichIsA("BasePart")
                        if mPart then
                            local mDist = (playerPos - mPart.Position).Magnitude
                            if mDist <= State.DangerDistance then
                                local gen = char.Decoding.Value
                                local stopEv = gen and gen:FindFirstChild("Stats") and gen.Stats:FindFirstChild("StopInteracting")
                                if stopEv then
                                    stopEv:FireServer("Stop")
                                    DangerDisengageCooldown = tick() + 3.0 -- 3 seconds safety cooldown
                                    WindUI:Notify({
                                        Title = "â ï¸ DANGER DETECTED",
                                        Content = monster.Name .. " approaching (" .. math.floor(mDist) .. " studs)! Disengaged.",
                                        Duration = 2.5
                                    })
                                    task.wait(1.5)
                                    break
                                end
                            end
                        end
                    end
                end
            end

            -- B. Auto Interact Generator (With Danger Cooldown & Availability Check)
            if State.AutoInteractGen and not isDecoding and tick() >= DangerDisengageCooldown and activeMap and activeMap:FindFirstChild("Generators") then
                for _, gen in ipairs(activeMap.Generators:GetChildren()) do
                    if gen:IsA("Model") and gen:FindFirstChild("Stats") then
                        local comp = gen.Stats:FindFirstChild("Completed")
                        local activePlayer = gen.Stats:FindFirstChild("ActivePlayer")
                        -- Only interact if not completed and not occupied by another player
                        local isAvailable = (activePlayer and (activePlayer.Value == nil or activePlayer.Value == char))
                        if comp and not comp.Value and isAvailable then
                            local gPart = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
                            if gPart then
                                local gDist = (playerPos - gPart.Position).Magnitude
                                if gDist <= 14 then
                                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then
                                        prompt.MaxActivationDistance = 32
                                        prompt.RequiresLineOfSight = false
                                        fireproximityprompt(prompt)
                                        task.wait(0.8)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- C. Auto Collect Items (Smart Capsule Priority & Free Slot Verification)
            if State.AutoCollectItems and activeMap and activeMap:FindFirstChild("Items") then
                local freeSlotAvailable = hasFreeInventorySlot()
                for _, item in ipairs(activeMap.Items:GetChildren()) do
                    if item:IsA("Model") then
                        local isCapsule = item.Name == "ResearchCapsule" or item.Name:find("Capsule")
                        -- Research capsules always collectable; other items require free inventory slot
                        if isCapsule or freeSlotAvailable then
                            local iPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                            if iPart then
                                local iDist = (playerPos - iPart.Position).Magnitude
                                if iDist <= State.ItemCollectRange then
                                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- D. Auto Teleport to Elevator When Floor Completed
            if State.AutoTeleportElevator then
                local info = workspace:FindFirstChild("Info")
                local compGens = info and info:FindFirstChild("GeneratorsCompleted") and info.GeneratorsCompleted.Value or 0
                local reqGens = info and info:FindFirstChild("RequiredGenerators") and info.RequiredGenerators.Value or 999
                if compGens >= reqGens and reqGens > 0 then
                    local el = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Elevator")
                    local elSpawn = el and (el:FindFirstChild("SpawnZones") or el:FindFirstChild("ElevatorHitBox") or el.PrimaryPart)
                    if elSpawn then
                        local elDist = (playerPos - elSpawn.Position).Magnitude
                        if elDist > 25 then
                            root.CFrame = CFrame.new(elSpawn.Position + Vector3.new(0, 3, 0))
                            WindUI:Notify({Title = "Elevator Reached", Content = "All generators complete. Teleported inside Elevator!", Duration = 3})
                            task.wait(3.5)
                        end
                    end
                end
            end
        end
    end
end)

-- 2. ESP Render Worker (Clean Direct Folder Iteration - Zero Duplicates)
task.spawn(function()
    while true do
        task.wait(0.4)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local playerPos = root and root.Position or Vector3.new()

        if not (State.TwistedESP or State.GeneratorESP or State.ItemsESP or State.ElevatorESP) then
            clearAllESP()
        else
            local currentRoom = workspace:FindFirstChild("CurrentRoom")
            local activeMap = currentRoom and currentRoom:GetChildren()[1]

            -- A. Twisted Monsters ESP
            if State.TwistedESP and activeMap and activeMap:FindFirstChild("Monsters") then
                for _, monster in ipairs(activeMap.Monsters:GetChildren()) do
                    if monster:IsA("Model") and monster ~= char then
                        local mPart = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildWhichIsA("BasePart")
                        if mPart then
                            local id = "Twisted_" .. monster.Name .. "_" .. monster:GetDebugId()
                            local chasing = monster:FindFirstChild("Chasing")
                            local isChasing = chasing and chasing.Value == true
                            local color = isChasing and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(255, 140, 0)
                            local dist = math.floor((playerPos - mPart.Position).Magnitude)

                            if not ActiveESPTargets[id] then
                                local bb, title, distLabel = createBillboard("Twisted", mPart, color, Vector3.new(0, 3, 0))
                                local hl = createHighlight(monster, color)
                                ActiveESPTargets[id] = {bb = bb, title = title, distLabel = distLabel, hl = hl, target = monster}
                            end

                            local esp = ActiveESPTargets[id]
                            if esp and esp.title and esp.distLabel then
                                local stateText = isChasing and " [CHASING â ï¸]" or " [PATROL]"
                                esp.title.Text = "ð¹ " .. monster.Name .. stateText
                                esp.title.TextColor3 = color
                                esp.distLabel.Text = dist .. " studs"
                                if esp.hl then esp.hl.FillColor = color; esp.hl.OutlineColor = color end
                            end
                        end
                    end
                end
            end

            -- B. Generators ESP
            if State.GeneratorESP and activeMap and activeMap:FindFirstChild("Generators") then
                for _, gen in ipairs(activeMap.Generators:GetChildren()) do
                    if gen:IsA("Model") and gen:FindFirstChild("Stats") then
                        local gPart = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
                        if gPart then
                            local id = "Gen_" .. gen.Name .. "_" .. gen:GetDebugId()
                            local cur = gen.Stats:FindFirstChild("CurrentAmount") and gen.Stats.CurrentAmount.Value or 0
                            local req = gen.Stats:FindFirstChild("RequiredAmount") and gen.Stats.RequiredAmount.Value or 45
                            local comp = gen.Stats:FindFirstChild("Completed") and gen.Stats.Completed.Value or false
                            local dist = math.floor((playerPos - gPart.Position).Magnitude)

                            local color = comp and Color3.fromRGB(50, 255, 50) or (cur > 0 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 200, 255))

                            if not ActiveESPTargets[id] then
                                local bb, title, distLabel = createBillboard("Generator", gPart, color, Vector3.new(0, 4, 0))
                                local hl = createHighlight(gen, color)
                                ActiveESPTargets[id] = {bb = bb, title = title, distLabel = distLabel, hl = hl, target = gen}
                            end

                            local esp = ActiveESPTargets[id]
                            if esp and esp.title and esp.distLabel then
                                esp.title.Text = "â¡ Generator " .. (comp and "[DONE]" or string.format("[%.1f/%d]", cur, req))
                                esp.title.TextColor3 = color
                                esp.distLabel.Text = dist .. " studs"
                                if esp.hl then esp.hl.FillColor = color; esp.hl.OutlineColor = color end
                            end
                        end
                    end
                end
            end

            -- C. Items ESP (Direct Model Inspection - Zero Duplicate Labels)
            if State.ItemsESP and activeMap and activeMap:FindFirstChild("Items") then
                for _, item in ipairs(activeMap.Items:GetChildren()) do
                    if item:IsA("Model") then
                        local iPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if iPart then
                            local id = "Item_" .. item.Name .. "_" .. item:GetDebugId()
                            local dist = math.floor((playerPos - iPart.Position).Magnitude)
                            local color = Color3.fromRGB(255, 230, 100)
                            if item.Name:find("Capsule") then
                                color = Color3.fromRGB(255, 215, 0)
                            elseif item.Name:find("Candy") then
                                color = Color3.fromRGB(100, 180, 255)
                            elseif item.Name:find("Tape") or item.Name:find("Medkit") then
                                color = Color3.fromRGB(100, 255, 120)
                            end

                            if not ActiveESPTargets[id] then
                                local bb, title, distLabel = createBillboard("Item", iPart, color, Vector3.new(0, 2.0, 0))
                                ActiveESPTargets[id] = {bb = bb, title = title, distLabel = distLabel, target = item}
                            end

                            local esp = ActiveESPTargets[id]
                            if esp and esp.title and esp.distLabel then
                                esp.title.Text = "ð¦ " .. item.Name
                                esp.distLabel.Text = dist .. " studs"
                            end
                        end
                    end
                end
            end

            -- D. Elevator ESP
            if State.ElevatorESP then
                local el = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Elevator")
                local elPart = el and (el.PrimaryPart or el:FindFirstChild("SpawnZones") or el:FindFirstChildWhichIsA("BasePart"))
                if elPart then
                    local id = "Elevator_Static"
                    local dist = math.floor((playerPos - elPart.Position).Magnitude)
                    local color = Color3.fromRGB(0, 255, 200)

                    if not ActiveESPTargets[id] then
                        local bb, title, distLabel = createBillboard("Elevator", elPart, color, Vector3.new(0, 5, 0))
                        ActiveESPTargets[id] = {bb = bb, title = title, distLabel = distLabel, target = el}
                    end

                    local esp = ActiveESPTargets[id]
                    if esp and esp.title and esp.distLabel then
                        esp.title.Text = "ð ELEVATOR [SAFE ZONE]"
                        esp.distLabel.Text = dist .. " studs"
                    end
                end
            end

            -- Clean up invalidated items
            for id, esp in pairs(ActiveESPTargets) do
                if not esp.target or not esp.target.Parent then
                    if esp.bb then pcall(function() esp.bb:Destroy() end) end
                    if esp.hl then pcall(function() esp.hl:Destroy() end) end
                    ActiveESPTargets[id] = nil
                end
            end
        end
    end
end)

-- 3. Player Modifications (Infinite Stamina, Speed, Safe Noclip)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        -- Infinite Stamina & Anti-Fatigue
        if State.InfiniteStamina then
            local stats = char:FindFirstChild("Stats")
            local curStam = stats and stats:FindFirstChild("CurrentStamina")
            local maxStam = stats and stats:FindFirstChild("Stamina")
            if curStam and maxStam and curStam.Value < maxStam.Value then
                curStam.Value = maxStam.Value
            end
            if char:GetAttribute("StaminaFatigued") then
                char:SetAttribute("StaminaFatigued", nil)
            end
        end
    end
end)

-- Safe Noclip (Preserves floor collision while letting player pass walls)
RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.CanCollide = false
                end
            end
        end
    end
end)

-- 4. Anti-AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ==================== CREATE WINDUI INTERFACE ====================
local Window = WindUI:CreateWindow({
    Title = "Dandy's World",
    Author = "By XLunaHUB",
    Folder = "DandysWorld_XLunaHUB",
    Icon = "sun",
    Size = UDim2.fromOffset(620, 480),
    Theme = "Dark",
    OpenButton = {
        Title = "Dandy's World",
        Icon = "sun",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("FFA500"),
            Color3.fromHex("FFD700")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

-- LeftControl Keybind Toggle (Dedicated Debounced Single Listener - Never Conflicts)
local toggleDebounce = false
local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl and not toggleDebounce then
        toggleDebounce = true
        pcall(function() Window:Toggle() end)
        task.delay(0.3, function() toggleDebounce = false end)
    end
end)

-- Standalone Floating Draggable Button
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "XLunaHUB_FloatingToggle"
floatGui.ResetOnSpawn = false
pcall(function()
    if gethui then
        floatGui.Parent = gethui()
    else
        floatGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

local floatBtn = Instance.new("TextButton")
floatBtn.Name = "ToggleBtn"
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 20, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
floatBtn.Text = "ð»"
floatBtn.TextSize = 26
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.AutoButtonColor = true
floatBtn.Parent = floatGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 25)
btnCorner.Parent = floatBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 170, 0)
btnStroke.Thickness = 2
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Parent = floatBtn

-- Dragging logic for floatBtn
do
    local dragging, dragInput, dragStart, startPos
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

-- ==================== TABS SETUP ====================
local TabAutomation = Window:Tab({Title = "Automation", Icon = "cog"})
local TabVisuals = Window:Tab({Title = "Visuals (ESP)", Icon = "eye"})
local TabPlayer = Window:Tab({Title = "Player Mods", Icon = "user"})
local TabTeleport = Window:Tab({Title = "Teleport", Icon = "navigation"})
local TabConfig = Window:Tab({Title = "Config", Icon = "file-text"})

-- ==================== TAB 1: AUTOMATION ====================
TabAutomation:Section({Title = "Extraction & Skill Checks", TextSize = 15})

TabAutomation:Toggle({
    Title = "Auto Perfect Skill Check",
    Desc = "Guarantees 100% Great (Gold Zone) / Supercomplete skill checks with zero fails.",
    Value = State.AutoSkillCheck,
    Callback = function(val)
        State.AutoSkillCheck = val
    end
})

TabAutomation:Toggle({
    Title = "Auto Repair Generator",
    Desc = "Automatically starts and sustains generator repair when standing nearby.",
    Value = State.AutoInteractGen,
    Callback = function(val)
        State.AutoInteractGen = val
    end
})

TabAutomation:Section({Title = "Safety & Survival", TextSize = 15})

TabAutomation:Toggle({
    Title = "Auto Disengage on Danger",
    Desc = "Instantly cancels generator repair when a Twisted monster comes within range.",
    Value = State.AutoDisengageDanger,
    Callback = function(val)
        State.AutoDisengageDanger = val
    end
})

TabAutomation:Slider({
    Title = "Danger Disengage Distance",
    Desc = "Distance in studs to trigger safety disengagement.",
    Step = 1,
    Value = {Min = 15, Max = 70, Default = 35},
    Callback = function(val)
        State.DangerDistance = val
    end
})

TabAutomation:Section({Title = "Loot & Floor Navigation", TextSize = 15})

TabAutomation:Toggle({
    Title = "Auto Collect Items",
    Desc = "Automatically picks up Research Capsules, Candies, Tape, and Medkits.",
    Value = State.AutoCollectItems,
    Callback = function(val)
        State.AutoCollectItems = val
    end
})

TabAutomation:Slider({
    Title = "Item Vacuum Range",
    Desc = "Studs radius to collect nearby items.",
    Step = 1,
    Value = {Min = 10, Max = 50, Default = 25},
    Callback = function(val)
        State.ItemCollectRange = val
    end
})

TabAutomation:Toggle({
    Title = "Auto Teleport to Elevator",
    Desc = "Automatically teleports player safely into Elevator when all generators finish.",
    Value = State.AutoTeleportElevator,
    Callback = function(val)
        State.AutoTeleportElevator = val
    end
})

-- ==================== TAB 2: VISUALS (ESP) ====================
TabVisuals:Section({Title = "Entity & World ESP", TextSize = 15})

TabVisuals:Toggle({
    Title = "Twisted Monsters ESP",
    Desc = "Highlights monsters with distance and real-time Aggro/Patrol tracking.",
    Value = State.TwistedESP,
    Callback = function(val)
        State.TwistedESP = val
        if not val then clearAllESP() end
    end
})

TabVisuals:Toggle({
    Title = "Generators ESP",
    Desc = "Shows all generators, live progress (XX/45), and completion state.",
    Value = State.GeneratorESP,
    Callback = function(val)
        State.GeneratorESP = val
        if not val then clearAllESP() end
    end
})

TabVisuals:Toggle({
    Title = "Items ESP",
    Desc = "Shows Research Capsules, Candies, Tape, and items through walls.",
    Value = State.ItemsESP,
    Callback = function(val)
        State.ItemsESP = val
        if not val then clearAllESP() end
    end
})

TabVisuals:Toggle({
    Title = "Elevator ESP",
    Desc = "Always pinpoints the safe Elevator room with live distance.",
    Value = State.ElevatorESP,
    Callback = function(val)
        State.ElevatorESP = val
        if not val then clearAllESP() end
    end
})

TabVisuals:Section({Title = "Atmosphere & Vision", TextSize = 15})

TabVisuals:Toggle({
    Title = "Full Bright / Night Vision",
    Desc = "Removes darkness and blackouts, fully illuminating the rooms.",
    Value = State.FullBright,
    Callback = function(val)
        State.FullBright = val
        applyFullBright(val)
    end
})

-- ==================== TAB 3: PLAYER MODS ====================
TabPlayer:Section({Title = "Stamina & Movement", TextSize = 15})

TabPlayer:Toggle({
    Title = "Infinite Stamina",
    Desc = "Eliminates stamina drain and prevents fatigue when sprinting.",
    Value = State.InfiniteStamina,
    Callback = function(val)
        State.InfiniteStamina = val
    end
})

TabPlayer:Toggle({
    Title = "WalkSpeed Modifier",
    Desc = "Enables custom movement speed safely without anticheat trip.",
    Value = State.SpeedHack,
    Callback = function(val)
        State.SpeedHack = val
        updateSpeed()
    end
})

TabPlayer:Slider({
    Title = "Custom WalkSpeed",
    Desc = "Target movement speed (default: 25).",
    Step = 1,
    Value = {Min = 16, Max = 45, Default = 25},
    Callback = function(val)
        State.WalkSpeed = val
        if State.SpeedHack then
            updateSpeed()
        end
    end
})

TabPlayer:Section({Title = "Collision & Utilities", TextSize = 15})

TabPlayer:Toggle({
    Title = "Noclip",
    Desc = "Walks through walls safely using built-in collision exemption.",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end
})

TabPlayer:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents Roblox 20-minute idle disconnection.",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end
})

-- ==================== TAB 4: TELEPORT ====================
TabTeleport:Section({Title = "Instant Navigation", TextSize = 15})

TabTeleport:Button({
    Title = "Teleport to Elevator",
    Desc = "Safely teleports inside Elevator (Match safe zone or Lobby match gates).",
    Callback = function()
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local currentRoom = workspace:FindFirstChild("CurrentRoom")
            if currentRoom then
                -- In-Game Match Elevator
                local el = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Elevator")
                local spawnZone = el and (el:FindFirstChild("SpawnZones") or el:FindFirstChild("ElevatorHitBox") or el.PrimaryPart)
                if spawnZone then
                    root.CFrame = CFrame.new(spawnZone.Position + Vector3.new(0, 3, 0))
                    WindUI:Notify({Title = "Teleported", Content = "Moved inside Elevator safe zone!", Duration = 2})
                    return
                end
            else
                -- Lobby Match Gate Elevators
                local elFolder = workspace:FindFirstChild("Elevators")
                local centerGate = elFolder and elFolder:FindFirstChild("CenterGate")
                local gatePart = centerGate and (centerGate.PrimaryPart or centerGate:FindFirstChildWhichIsA("BasePart"))
                if gatePart then
                    root.CFrame = CFrame.new(gatePart.Position + Vector3.new(0, 3, 0))
                    WindUI:Notify({Title = "Teleported", Content = "Moved inside Lobby Center Match Gate!", Duration = 2})
                    return
                end
            end
            WindUI:Notify({Title = "Not Found", Content = "Elevator location could not be resolved.", Duration = 2})
        end)
    end
})

TabTeleport:Button({
    Title = "Teleport to Nearest Generator",
    Desc = "Teleports to the exact interaction spot of the closest uncompleted generator.",
    Callback = function()
        pcall(function()
            local currentRoom = workspace:FindFirstChild("CurrentRoom")
            local activeMap = currentRoom and currentRoom:GetChildren()[1]
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not activeMap or not activeMap:FindFirstChild("Generators") or not root then
                WindUI:Notify({Title = "Notice", Content = "Generators only exist inside active game floors.", Duration = 2})
                return
            end

            local nearestSpot = nil
            local nearestDist = math.huge

            for _, gen in ipairs(activeMap.Generators:GetChildren()) do
                if gen:IsA("Model") and gen:FindFirstChild("Stats") then
                    local comp = gen.Stats:FindFirstChild("Completed")
                    if comp and not comp.Value then
                        local tpPos = gen:FindFirstChild("TeleportPositions") and gen.TeleportPositions:FindFirstChild("TeleportPosition")
                        local part = tpPos or gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local d = (root.Position - part.Position).Magnitude
                            if d < nearestDist then
                                nearestDist = d
                                nearestSpot = tpPos and tpPos.CFrame or CFrame.new(part.Position + Vector3.new(0, 2.5, 0))
                            end
                        end
                    end
                end
            end

            if nearestSpot then
                root.CFrame = nearestSpot
                WindUI:Notify({Title = "Teleported", Content = "Moved to nearest Generator valve!", Duration = 2})
            else
                WindUI:Notify({Title = "Not Found", Content = "No uncompleted generators found.", Duration = 2})
            end
        end)
    end
})

-- ==================== TAB 5: CONFIG ====================
TabConfig:Section({Title = "Profile Storage", TextSize = 15})

local SelectedProfile = "default"

TabConfig:Dropdown({
    Title = "Select Profile",
    Desc = "Choose existing configuration.",
    Values = GetConfigList(),
    Value = "default",
    Callback = function(val)
        SelectedProfile = val
    end
})

TabConfig:Button({
    Title = "Save Config",
    Desc = "Save current settings to profile.",
    Callback = function()
        SaveConfig(SelectedProfile)
    end
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Load selected profile settings.",
    Callback = function()
        LoadConfig(SelectedProfile)
    end
})

TabConfig:Button({
    Title = "Reset to Default (ALL OFF)",
    Desc = "Turn off all active automation and mods.",
    Callback = function()
        ResetConfig()
    end
})

-- ==================== CLEANUP REGISTRATION ====================
getgenv()._DANDYS_WORLD_CLEANUP = function()
    pcall(function()
        keybindConn:Disconnect()
        floatGui:Destroy()
        clearAllESP()
        applyFullBright(false)
        if Window and Window.Destroy then Window:Destroy() end
    end)
end

-- ==================== TELEPORT PERSISTENCE ====================
local queueTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queueTeleport then
    LocalPlayer.OnTeleport:Connect(function(state)
        pcall(function()
            queueTeleport([[
                task.spawn(function()
                    local path = "E:/SC/Dandys World/DandysWorld_XLunaHUB.lua"
                    if isfile and isfile(path) then
                        loadfile(path)()
                    elseif readfile then
                        loadstring(readfile(path))()
                    end
                end)
            ]])
        end)
    end)
end

-- ==================== INITIALIZATION NOTIFICATION ====================
WindUI:Notify({
    Title = "XLunaHUB Loaded",
    Content = "ð» Dandy's World Suite initialized. Press LeftCtrl or tap ð» to toggle UI.",
    Duration = 4
})
print("[XLunaHUB] Dandy's World Automation Suite v2 initialized successfully!")
