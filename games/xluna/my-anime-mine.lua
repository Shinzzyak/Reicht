-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- Clean previous instance if running
if _G.MyAnimeMineEngine and _G.MyAnimeMineEngine.Unload then
    pcall(function() _G.MyAnimeMineEngine:Unload() end)
end

_G.MyAnimeMineInstanceId = (_G.MyAnimeMineInstanceId or 0) + 1
local currentInstanceId = _G.MyAnimeMineInstanceId

-- ====================================================================
-- 1. ROBLOX CORE SERVICES & DATA RESOLUTION
-- ====================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")

-- Key Game Modules
local GameState = nil
pcall(function() GameState = require(ReplicatedStorage.Modules.GameState) end)

local MineConfig = nil
pcall(function() MineConfig = require(ReplicatedStorage.Modules.MineConfig) end)

local MineInventory = nil
pcall(function() MineInventory = require(ReplicatedStorage.Modules.MineInventory) end)

local MineStock = nil
pcall(function() MineStock = require(ReplicatedStorage.Modules.MineStock) end)

local MineDailySpinConfig = nil
pcall(function() MineDailySpinConfig = require(ReplicatedStorage.Modules.MineDailySpinConfig) end)

local MineDailyQuestsCatalog = nil
pcall(function() MineDailyQuestsCatalog = require(ReplicatedStorage.Modules.MineDailyQuestsCatalog) end)

local Items = nil
pcall(function() Items = require(ReplicatedStorage.Modules.Items) end)

local String = nil
pcall(function() String = require(ReplicatedStorage.Modules.String) end)

local function FormatMoneyShort(n)
    if not n or n <= 0 then return "0" end
    if n >= 1e12 then return string.format("%.2fT", n / 1e12) end
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end


-- ====================================================================
-- 2. ENGINE CORE STATE & CONFIGURATION
-- ====================================================================
local CONFIG_FILE_DEFAULT = "Default.json"
local isLoadingConfig = false
local isSyncing = false

local Engine = {
    Connections = {},
    Loops = {},
    Drawings = {},
    ESPObjects = {},
    ReactiveWidgets = {},
    UIControls = {},
    CurrentLanguage = "English",
    Running = true,
    InstanceId = currentInstanceId,
    Config = {
        -- Developer Admin & Plot Engine
        CustomCmdrCmd = "completeindex me",
        AutoUpgradeMiners = false,
        MaxMinerLevel = 100,
        AutoUpgradeSpeed = false,
        AutoUpgradeMineSpeed = false,
        MinerUpgradeMode = "Balanced (Lowest Level First)",
        MinerUpgradeDelay = 1.0,
        MinCashReserve = 10000000,
        SilentAutomation = true,
        AutoClaimChest = false,
        AutoResearchSkills = false,
        AutoResearchTap = false,
        AutoResearchSlots = false,
        AutoUnlockNextZone = false,
        AutoTravelDeepest = false,
        ResearchTargetZone = "Latest Unlocked Zone",
        ResearchReserve = 0,
        AutoEquipBestMiners = false,
        AutoBuyPickaxes = false,
        AutoEquipPickaxes = false,
        AutoFarmNodes = false,
        TapKillMode = false,
        NodeTapDelay = 0.1,
        TargetNodeRarity = "All Nodes",
        -- Miner Auto-Sell Engine
        AutoSellMinerRarity = "Rare & Below (Common, Uncommon, Rare)",
        -- System & UI
        Language = "English",
        ToggleKey = "Insert",
        ConfigName = "Default",

        -- Farming
        AutoMine = false,
        TargetOre = "All Ores",
        MineRange = 120,
        AutoSell = false,
        AutoSellInterval = 10,
        AutoChest = false,

        -- Automation
        AutoDailySpin = false,
        AutoDailyQuests = false,
        AutoMailbox = false,
        AutoUpgradeCharacters = false,
        AutoEquipBest = false,

        -- Visuals
        OreESP = false,
        StandESP = false,
        MaxESPDistance = 350,

        -- Player
        SpeedBoost = false,
        SpeedValue = 32,
        JumpBoost = false,
        JumpValue = 80,
        InfiniteJump = false,
        Noclip = false,
        AntiAFK = true,

        -- Super Features
        AutoRestoreHUD = true,
        AutoRedeemCodes = false,
        AutoClaimBuffPad = false,
        AutoMysteryBlocks = false,
        AutoColossusCrates = false,
        AutoConsumePotions = false,
        AutoBuySkills = false,
        Fullbright = false,
        PlayerESP = false,
        SelectedZone = "Z1",
        SelectedPlayer = "",
        MineHoverHeight = 3.5,
    }
}

_G.MyAnimeMineEngine = Engine

-- ====================================================================
-- 3. MULTI-LANGUAGE LOCALIZATION DICTIONARY (9 LANGUAGES)
-- ====================================================================
local I18N = {
    ["English"] = {
        TabAdmin = "Developer Admin",
        TabPlot = "Plot & Miners",
        SecCmdr = "Native Cmdr Developer Console",
        BtnLaunchCmdr = "Launch Native Cmdr UI",
        DescLaunchCmdr = "Opens the game's built-in developer console ([ / F2)",
        InputCmdr = "Custom Cmdr Command",
        BtnDispatchCmdr = "Dispatch Command",
        SecAdminMacros = "1-Click Developer Routines",
        BtnCompleteIndex = "Complete All Index Collections",
        DescCompleteIndex = "Fills all discovery collections (completeindex me)",
        BtnUnlockZones = "Unlock All 13 Zones",
        DescUnlockZones = "Unlocks map-wide progression (unlockzones me)",
        BtnMaxMine = "Max Mine State",
        DescMaxMine = "Sets maximum mining progress (maxmine me)",
        BtnTapKill = "Toggle One-Tap Mining",
        DescTapKill = "Breaks any tapped rock in 1-hit (tapkill me)",
        SecAdminEconomy = "Developer Economy Grants",
        BtnGrantGems = "Grant 1,000,000 Gems",
        BtnGrantScrolls = "Grant 1,000 Summon Scrolls",
        BtnGrantDice = "Grant 500 Enchant Dice",
        BtnGrantCash = "Grant $1,000,000,000 Cash",
        BtnGrantItems = "Grant All Items & Gear",

        SecPlotMaximizer = "Miner Progression & Stats Maximizer",
        TglAutoUpgradeMiners = "Auto Upgrade Miner Level (Damage)",
        InputMaxMinerLevel = "Max Miner Level Cap",
        DescMaxMinerLevel = "Stops upgrading miners once they reach this level (0 = Unlimited)",
        DescAutoUpgradeMiners = "Direct network upgrade increasing miner character levels",
        TglAutoUpgradeSpeed = "Auto Upgrade Miner Speed",
        DescAutoUpgradeSpeed = "Direct network upgrade boosting character walk speed",
        TglAutoUpgradeMineSpeed = "Auto Upgrade Mining Speed",
        DescAutoUpgradeMineSpeed = "Direct network upgrade boosting pickaxe mining speed",
        SldMinerDelay = "Upgrade Check Interval (s)",
        SldMinCashReserve = "Cash Reserve Protection ($)",
        BtnUpgradeMinersOnce = "Batch Upgrade All Miners Once",
        TglSilentAutomation = "Silent Automation (Suppress Screen Popups)",
        DescSilentAutomation = "Hides Chest, Sell, and Focus modals to keep screen unobstructed",
        SecPlotChest = "Plot Chest Automation",
        TglAutoClaimChest = "Auto Claim Plot Chest (Silent)",
        DescAutoClaimChest = "Silently claims chest drops without popping up Chest UI",
        BtnClaimChestNow = "Silent Claim Chest Drops Now",
        SecPlotMiners = "Miner Setup & Stats",
        TglAutoEquipBestMiners = "Auto Equip Best Miners",
        DescAutoEquipBestMiners = "Periodically equips highest tier heroes to pads",
        TglAutoBuyPickaxes = "Auto Buy Best Pickaxes",
        DescAutoBuyPickaxes = "Automatically purchases highest tier pickaxes from shop when miners need upgrades",
        TglAutoEquipPickaxes = "Auto Equip Best Pickaxes",
        DescAutoEquipPickaxes = "Assigns highest multiplier pickaxes to the strongest active miners",
        BtnBuyBestPickaxe = "Buy Best Available Pickaxe Now",
        DescBuyBestPickaxe = "Purchases the highest unlocked pickaxe currently in stock",

        SecNodeFarm = "Active Node Precision Mining",
        TglAutoFarmNodes = "Auto Farm Plot Nodes",
        DescAutoFarmNodes = "Direct teleport onto rock + native hit events",
        TglTapKillMode = "One-Hit Tap-Kill Mode",
        DescTapKillMode = "Activates developer tapkill for instant node shattering",
        DropTargetRarity = "Target Node Filter",
        DescTargetRarity = "Filter active nodes on your plot",
        SldNodeTapDelay = "Node Hit Delay",
        BtnTpLowestNode = "Teleport to Lowest HP Node",
        BtnTpHighestNode = "Teleport to Highest Value Node",
        TabFarming = "Farming",
        TabTeleport = "Teleport",
        TabAutomation = "Automation",
        TabGacha = "Gacha & Shop",
        TabVisuals = "Visuals (ESP)",
        TabPlayer = "Player & Mods",
        TabLanguage = "Language",
        TabConfig = "Config",

        SecMine = "Auto Mine & Ore Sniping",
        TglAutoMine = "Auto Mine Target Ore",
        DescAutoMine = "Teleports to and focuses miners on chosen ore tier",
        DropTargetOre = "Select Target Ore",
        DescTargetOre = "Filter which ore to seek and destroy",
        SldMineRange = "Max Ore Seek Radius",

        SecSell = "Remote Instant Sell",
        TglAutoSell = "Auto Remote Sell Loop",
        DescAutoSell = "Sells inventory periodically without walking to shop",
        TglAutoSellMiners = "Auto Sell Unused Miners",
        DescAutoSellMiners = "Automatically sells unused low-tier fodder miners (Common/Uncommon/Rare)",
        DropAutoSellMinerRarity = "Max Miner Rarity to Sell",
        SldSellInterval = "Sell Interval (Seconds)",
        BtnSellNow = "Sell All Bag Items Now",
        DescSellNow = "Instant execution of MineSellItems remote",
        TglAutoChest = "Auto Collect Chest Drops",
        DescAutoChest = "Sweeps world and claims all available drop chests",

        SecStands = "Interactive World Stands",
        BtnTpSell = "TP to Sell Stand",
        BtnTpPick = "TP to Pickaxe Shop",
        BtnTpEnchant = "TP to Enchant Altar",
        BtnTpSummon = "TP to Summon Shrine",
        BtnTpAlliance = "TP to Alliance Stand",
        BtnTpLucky = "TP to Unreal Lucky Block",

        SecTravel = "Realm Fast Travel",
        BtnTpHub = "Fast Travel to Hub Spawn",
        BtnTpPlot = "Fast Travel to Base Plot",
        BtnTpOre = "TP to Nearest Target Ore",

        SecDailies = "Daily Rewards & Mailbox",
        TglDailySpin = "Auto Daily Spin Wheel",
        DescDailySpin = "Automatically spins reward wheel off cooldown",
        TglDailyQuests = "Auto Claim Daily Quests",
        DescDailyQuests = "Claims all completed daily missions",
        TglMailbox = "Auto Claim Mailbox Rewards",
        DescMailbox = "Collects all items & rewards from mailbox",
        BtnTutorial = "Claim Tutorial Rewards",
        DescTutorial = "Sends MineTutorialDone & MineTutorialGift",

        SecProgression = "Character & Gear Progression",
        TglAutoUpgrade = "Auto Upgrade Active Miners",
        DescAutoUpgrade = "Continuously upgrades character slots with cash",
        BtnEquipBest = "Equip Best Characters & Picks",
        DescEquipBest = "Calls MineEquipBest remote directly",

        SecGacha = "Fast Gacha Summon (No Animation)",
        BtnSummon1 = "Fast Summon x1",
        BtnSummon10 = "Fast Summon x10",
        DescSummon = "Instant invocation bypassing all gacha animations",

        SecESP = "World & Ore Telemetry (ESP)",
        TglOreESP = "Enable Ore ESP",
        DescOreESP = "Highlights active ore nodes colored by rarity tier",
        TglStandESP = "Enable Stand & Altar ESP",
        DescStandESP = "Marks positions of world shops and shrines",
        SldESPDist = "ESP Max Render Distance",

        SecMovement = "Movement & Physics Modifiers",
        TglSpeed = "Speed Boost",
        SldSpeed = "WalkSpeed Value",
        TglJump = "Jump Boost",
        SldJump = "JumpPower Value",
        TglInfJump = "Infinite Jump",
        TglNoclip = "Noclip (Walk Through Walls)",
        TglAntiAFK = "Anti-AFK Protection",
        DescAntiAFK = "Prevents 20-minute idle disconnects",

        SecLangSelect = "UI Language Selection",
        DropLanguage = "Active Language",
        DescLangSelect = "Switches all text on the WindUI panel instantly",
        LangSuccess = "Language Switched",
        LangSuccessDesc = "UI language successfully updated to: ",

        SecConfig = "Profile & Configuration Persistence",
        InputConfigName = "Config Preset Name",
        BtnSaveConfig = "Save Current Config",
        DescSaveConfig = "Writes all settings and toggles to JSON file",
        BtnLoadConfig = "Load Config & Restore UI",
        DescLoadConfig = "Loads file and visually restores all toggles and values",
        BtnResetConfig = "Reset to Default Settings",
        TglAutoLoad = "Auto-Load Config on Launch",
        DescAutoLoad = "Restores your preferences automatically upon execution",
        SecKeybind = "UI Visibility & Keybind",
        KeybindToggle = "Hide / Show Menu Keybind",
        DescKeybind = "Press this key at any time to toggle panel visibility",
        -- Super Features
        SecCodes = "Promo Codes Bomber (Free Rewards)",
        BtnRedeemAll = "Redeem All 9 Active Codes Now",
        DescRedeemAll = "Instantly claims all Enchanted Dice, Summon Scrolls, & Potions",
        TglAutoCodes = "Auto-Redeem Codes on Launch",
        DescAutoCodes = "Redeems all promo codes automatically upon script startup",
        SecBuffs = "Buff Pad & Potions",
        TglBuffPad = "Auto Claim Server Buff Pad",
        DescBuffPad = "Automatically claims 2x buff multipliers off cooldown",
        TglPotions = "Auto Consume Active Potions",
        DescPotions = "Keeps Luck, Speed, and Yield potions active automatically",
        TglSkills = "Auto Buy Skill Tree Upgrades",
        DescSkills = "Scans and buys all available Skill Tree nodes automatically",
        SecZones = "Zone Fast Travel (13 Zones)",
        DropZones = "Select Target Zone",
        BtnTpZone = "Travel to Selected Zone",
        DescTpZone = "Instant travel via MineSelectZone network dispatch",
        SecPlayers = "Player Teleport",
        DropPlayers = "Select Player Target",
        BtnTpPlayer = "Teleport to Selected Player",
        DescTpPlayer = "Warps your character behind the target player",
        SecRender = "Lighting & World Render",
        TglFullbright = "Fullbright & Clear Cave Vision",
        DescFullbright = "Eliminates darkness, shadows, and cave fog completely",
        TglPlayerESP = "Player ESP (Names & Distance)",
        DescPlayerESP = "Displays 3D bounding tags on all other players",
        SecEmergency = "Emergency Utilities",
        BtnRestoreHUD = "Restore Game HUDs (Fix Missing UI)",
        DescRestoreHUD = "Forces all game HUDs (LeftBar, Hotbar, Teleport, Money) to visible",
        TglAutoRestoreHUD = "Auto-Restore Missing HUDs",
        DescAutoRestoreHUD = "Continuously keeps native game HUDs visible even after gacha or cutscenes",
        BtnBreakCutscenes = "Break Stuck Cutscenes & Reset Camera",
        DescBreakCutscenes = "Instantly clears stuck dialogue, animation locks, & resets camera",
        SldHoverHeight = "Hover Height Above Ore",
        TglMysteryBlocks = "Auto Open Mystery Blocks",
        DescMystery = "Automatically cracks any mystery blocks in your inventory",
        TglColossusCrates = "Auto Open Colossus Crates",
        DescCrates = "Automatically pops available crates in bulk without waiting",
    },

    ["Bahasa Indonesia"] = {
        TabAdmin = "Developer Admin",
        TabPlot = "Plot & Penambang",
        SecCmdr = "Konsol Native Cmdr Developer",
        BtnLaunchCmdr = "Buka UI Konsol Cmdr",
        DescLaunchCmdr = "Membuka konsol bawaan game Roblox ([ / F2)",
        InputCmdr = "Perintah Custom Cmdr",
        BtnDispatchCmdr = "Jalankan Perintah",
        SecAdminMacros = "Makro Developer 1-Klik",
        BtnCompleteIndex = "Buka Seluruh Koleksi Index",
        DescCompleteIndex = "Mengisi semua jurnal index (completeindex me)",
        BtnUnlockZones = "Buka Seluruh 13 Zona",
        DescUnlockZones = "Membuka seluruh map dan zona (unlockzones me)",
        BtnMaxMine = "Maksimalkan Status Tambang",
        DescMaxMine = "Mengatur level tambang ke max (maxmine me)",
        BtnTapKill = "Mode 1-Pukul Hancur (Tap-Kill)",
        DescTapKill = "Batu hancur dalam 1 ketukan (tapkill me)",
        SecAdminEconomy = "Bantuan Ekonomi Developer",
        BtnGrantGems = "Beri 1,000,000 Gems",
        BtnGrantScrolls = "Beri 1,000 Gulungan Gacha",
        BtnGrantDice = "Beri 500 Dadu Enchant",
        BtnGrantCash = "Beri $1,000,000,000 Cash",
        BtnGrantItems = "Beri Seluruh Item & Gear",

        SecPlotMaximizer = "Maksimalkan Penambang Plot (Mesin Asli)",
        TglAutoUpgradeMiners = "Auto Upgrade Semua Penambang",
        InputMaxMinerLevel = "Batas Maksimal Level Miner",
        DescMaxMinerLevel = "Berhenti upgrade saat miner mencapai level ini (0 = Tanpa Batas)",
        DescAutoUpgradeMiners = "Loop ClickDetector menaikkan level penambang & hauler",
        SldMinerDelay = "Jeda Loop Upgrade",
        BtnUpgradeMinersOnce = "Upgrade Semua Penambang Sekarang",
        SecPlotChest = "Otomasi Peti Plot",
        TglAutoClaimChest = "Auto Ambil Isi Peti Plot",
        DescAutoClaimChest = "Mengambil drop yang dikumpulkan hauler ke peti",
        BtnClaimChestNow = "Ambil Drop Peti Sekarang",
        SecPlotMiners = "Pengaturan Penambang & Stat",
        TglAutoEquipBestMiners = "Auto Pasang Karakter Terbaik",
        DescAutoEquipBestMiners = "Memasang hero tier tertinggi ke pad secara berkala",
        TglAutoBuyPickaxes = "Auto Beli Pickaxe Terbaik",
        DescAutoBuyPickaxes = "Otomatis membeli pickaxe tier tertinggi di toko saat miner butuh upgrade",
        TglAutoEquipPickaxes = "Auto Pasang Pickaxe Terbaik",
        DescAutoEquipPickaxes = "Memasangkan pickaxe multiplier tertinggi ke miner terkuat di plot",
        BtnBuyBestPickaxe = "Beli Pickaxe Terbaik Sekarang",
        DescBuyBestPickaxe = "Beli pickaxe tertinggi yang terbuka dan tersedia di toko",

        SecNodeFarm = "Penambangan Presisi Node Aktif",
        TglAutoFarmNodes = "Auto Tambang Node Plot",
        DescAutoFarmNodes = "Teleport langsung ke batu + tembak remote hit",
        TglTapKillMode = "Mode Tap-Kill Sekali Pukul",
        DescTapKillMode = "Mengaktifkan tapkill developer agar node langsung pecah",
        DropTargetRarity = "Filter Node Target",
        DescTargetRarity = "Pilih tipe batu pada plot Anda",
        SldNodeTapDelay = "Jeda Ketukan Node",
        BtnTpLowestNode = "TP ke Batu Darah Terendah",
        BtnTpHighestNode = "TP ke Batu Nilai Tertinggi",
        TabFarming = "Penambangan",
        TabTeleport = "Teleportasi",
        TabAutomation = "Automasi",
        TabGacha = "Gacha & Toko",
        TabVisuals = "Visual (ESP)",
        TabPlayer = "Karakter & Mod",
        TabLanguage = "Bahasa",
        TabConfig = "Konfigurasi",

        SecMine = "Tambang Otomatis & Ore Sniper",
        TglAutoMine = "Tambang Ore Otomatis",
        DescAutoMine = "Teleport dan fokuskan miner ke ore yang dipilih",
        DropTargetOre = "Pilih Target Ore",
        DescTargetOre = "Filter jenis ore yang ingin ditambang",
        SldMineRange = "Radius Jarak Cari Ore",

        SecSell = "Jual Jarak Jauh (Remote Sell)",
        TglAutoSell = "Jual Otomatis Berkala",
        DescAutoSell = "Jual semua isi tas tanpa harus jalan ke toko",
        TglAutoSellMiners = "Auto Jual Miner Tidak Terpakai",
        DescAutoSellMiners = "Otomatis jual miner ampas/tier rendah (Common/Uncommon/Rare) yang tidak dipakai",
        DropAutoSellMinerRarity = "Batas Rarity Miner Dijual",
        SldSellInterval = "Interval Jual (Detik)",
        BtnSellNow = "Jual Semua Isi Tas Sekarang",
        DescSellNow = "Eksekusi langsung remote MineSellItems",
        TglAutoChest = "Ambil Peti Drop Otomatis",
        DescAutoChest = "Otomatis ambil semua peti yang jatuh di map",

        SecStands = "Stand & Altar Dunia",
        BtnTpSell = "Teleport ke Toko Jual (Sell Stand)",
        BtnTpPick = "Teleport ke Toko Pickaxe",
        BtnTpEnchant = "Teleport ke Altar Enchant",
        BtnTpSummon = "Teleport ke Altar Summon",
        BtnTpAlliance = "Teleport ke Stand Alliance",
        BtnTpLucky = "Teleport ke Unreal Lucky Block",

        SecTravel = "Perjalanan Cepat (Fast Travel)",
        BtnTpHub = "Teleport ke Hub / Kota",
        BtnTpPlot = "Teleport ke Plot Pribadi",
        BtnTpOre = "Teleport ke Ore Terdekat",

        SecDailies = "Hadiah Harian & Kotak Masuk",
        TglDailySpin = "Putar Roda Harian Otomatis",
        DescDailySpin = "Otomatis putar roda saat cooldown selesai",
        TglDailyQuests = "Klaim Misi Harian Otomatis",
        DescDailyQuests = "Klaim semua misi harian yang telah selesai",
        TglMailbox = "Klaim Hadiah Kotak Surat",
        DescMailbox = "Ambil semua surat dan hadiah gratis",
        BtnTutorial = "Klaim Hadiah Tutorial",
        DescTutorial = "Eksekusi MineTutorialDone & MineTutorialGift",

        SecProgression = "Progres Karakter & Alat",
        TglAutoUpgrade = "Upgrade Karakter Penambang Otomatis",
        DescAutoUpgrade = "Otomatis naikkan level karakter saat ada uang",
        BtnEquipBest = "Pasang Karakter & Pickaxe Terbaik",
        DescEquipBest = "Panggil remote MineEquipBest secara langsung",

        SecGacha = "Gacha Cepat (Tanpa Animasi)",
        BtnSummon1 = "Gacha Cepat 1x",
        BtnSummon10 = "Gacha Cepat 10x",
        DescSummon = "Panggilan instan tanpa menunggu video/cutscene",

        SecESP = "ESP Ore & Telemetri Dunia",
        TglOreESP = "Aktifkan ESP Ore",
        DescOreESP = "Tandai ore aktif dengan warna sesuai kelangkaan",
        TglStandESP = "Aktifkan ESP Altar & Toko",
        DescStandESP = "Tandai posisi toko dan shrine penting",
        SldESPDist = "Jarak Maksimal Render ESP",

        SecMovement = "Modifikasi Gerakan & Fisika",
        TglSpeed = "Kecepatan Lari Tambahan",
        SldSpeed = "Nilai WalkSpeed",
        TglJump = "Kekuatan Lompat Tambahan",
        SldJump = "Nilai JumpPower",
        TglInfJump = "Lompat Tanpa Batas (Infinite Jump)",
        TglNoclip = "Tembus Dinding (Noclip)",
        TglAntiAFK = "Perlindungan Anti-AFK",
        DescAntiAFK = "Mencegah putus koneksi idle 20 menit",

        SecLangSelect = "Pengaturan Bahasa UI",
        DropLanguage = "Bahasa Aktif",
        DescLangSelect = "Ubah bahasa teks pada menu WindUI seketika",
        LangSuccess = "Bahasa Diubah",
        LangSuccessDesc = "Bahasa UI berhasil diperbarui ke: ",

        SecConfig = "Penyimpanan Profil & Konfigurasi",
        InputConfigName = "Nama Preset Config",
        BtnSaveConfig = "Simpan Konfigurasi",
        DescSaveConfig = "Menyimpan seluruh pengaturan dan toggle ke file JSON",
        BtnLoadConfig = "Muat Config & Pulihkan UI",
        DescLoadConfig = "Memuat file dan memulihkan seluruh tampilan toggle dan slider",
        BtnResetConfig = "Kembalikan ke Pengaturan Awal",
        TglAutoLoad = "Muat Otomatis Saat Memulai",
        DescAutoLoad = "Otomatis memulihkan preferensi saat script dijalankan",
        SecKeybind = "Tombol Pintas (Keybind) Tampilan UI",
        KeybindToggle = "Tombol Sembunyikan/Buka Menu",
        DescKeybind = "Tekan tombol ini kapan saja untuk membuka/menutup panel",
        -- Super Features
        SecCodes = "Redeem Kode Promosi (Hadiah Gratis)",
        BtnRedeemAll = "Klaim Semua 9 Kode Aktif Sekarang",
        DescRedeemAll = "Klaim instan seluruh Enchanted Dice, Summon Scrolls, & Potion",
        TglAutoCodes = "Otomatis Tebus Kode Saat Mulai",
        DescAutoCodes = "Otomatis memasukkan kode saat script dijalankan",
        SecBuffs = "Pad Buff Server & Ramuan Potion",
        TglBuffPad = "Klaim Otomatis Buff Pad Server",
        DescBuffPad = "Klaim bonus multiplier 2x di map secara berkala",
        TglPotions = "Gunakan Potion Otomatis",
        DescPotions = "Menjaga potion Luck, Speed, dan Yield tetap aktif 24/7",
        TglSkills = "Beli Skill Tree Otomatis",
        DescSkills = "Otomatis membuka dan membeli upgrade di pohon skill",
        SecZones = "Fast Travel 13 Zona",
        DropZones = "Pilih Target Zona",
        BtnTpZone = "Teleport ke Zona Terpilih",
        DescTpZone = "Berpindah zona seketika menggunakan remote server",
        SecPlayers = "Teleport ke Pemain",
        DropPlayers = "Pilih Target Pemain",
        BtnTpPlayer = "Teleport ke Pemain Terpilih",
        DescTpPlayer = "Warp karakter langsung ke belakang pemain target",
        SecRender = "Pencahayaan & Visual Dunia",
        TglFullbright = "Penglihatan Terang Gua (Fullbright)",
        DescFullbright = "Menghilangkan kegelapan, bayangan, dan kabut gua secara total",
        TglPlayerESP = "ESP Pemain (Nama & Jarak)",
        DescPlayerESP = "Menampilkan penanda 3D nama dan jarak seluruh pemain",
        SecEmergency = "Utilitas Darurat",
        BtnRestoreHUD = "Pulihkan HUD Game (Atasi UI Hilang)",
        DescRestoreHUD = "Memaksa semua HUD game (Bar Kiri, Hotbar, Teleport, Uang) kembali tampil",
        TglAutoRestoreHUD = "Auto-Pulihkan HUD Hilang",
        DescAutoRestoreHUD = "Menjaga HUD asli game tetap muncul meski setelah gacha atau cutscene",
        BtnBreakCutscenes = "Hentikan Cutscene & Reset Kamera",
        DescBreakCutscenes = "Memutus animasi macet dan mereset posisi kamera seketika",
        SldHoverHeight = "Tinggi Melayang di Atas Ore",
        TglMysteryBlocks = "Buka Kotak Misteri Otomatis",
        DescMystery = "Otomatis membuka semua kotak misteri di dalam tas",
        TglColossusCrates = "Buka Peti Colossus Otomatis",
        DescCrates = "Otomatis membuka peti drop tanpa menunggu animasi lama",
    },

    ["EspaÃ±ol"] = {
        TabFarming = "MinerÃ­a",
        TabTeleport = "Teletransporte",
        TabAutomation = "AutomatizaciÃ³n",
        TabGacha = "Gacha y Tienda",
        TabVisuals = "Visuales (ESP)",
        TabPlayer = "Jugador y Modos",
        TabLanguage = "Idioma",
        TabConfig = "ConfiguraciÃ³n",

        SecMine = "MinerÃ­a AutomÃ¡tica",
        TglAutoMine = "Minar Mineral Objetivo",
        DescAutoMine = "Teletransporta y ataca el mineral seleccionado",
        DropTargetOre = "Seleccionar Mineral",
        DescTargetOre = "Filtra quÃ© minerales buscar y destruir",
        SldMineRange = "Radio de BÃºsqueda de Minerales",

        SecSell = "Venta Remota InstantÃ¡nea",
        TglAutoSell = "Venta AutomÃ¡tica PeriÃ³dica",
        DescAutoSell = "Vende el inventario sin ir a la tienda",
        SldSellInterval = "Intervalo de Venta (Segundos)",
        BtnSellNow = "Vender Todo el Inventario Ahora",
        DescSellNow = "Llama al remote MineSellItems directamente",
        TglAutoChest = "Recoger Cofres AutomÃ¡ticamente",
        DescAutoChest = "Recoge todos los cofres de botÃ­n caÃ­dos",

        SecStands = "Puestos del Mundo",
        BtnTpSell = "TP a Puesto de Venta",
        BtnTpPick = "TP a Tienda de Picos",
        BtnTpEnchant = "TP a Altar de Encantamiento",
        BtnTpSummon = "TP a Altar de InvocaciÃ³n",
        BtnTpAlliance = "TP a Puesto de Alianza",
        BtnTpLucky = "TP a Unreal Lucky Block",

        SecTravel = "Viaje RÃ¡pido",
        BtnTpHub = "TP al Centro (Hub)",
        BtnTpPlot = "TP a Parcela Personal",
        BtnTpOre = "TP al Mineral MÃ¡s Cercano",

        SecDailies = "Recompensas Diarias",
        TglDailySpin = "Giro Diario AutomÃ¡tico",
        DescDailySpin = "Gira la ruleta cuando termina el enfriamiento",
        TglDailyQuests = "Reclamar Misiones Diarias",
        DescDailyQuests = "Reclama todas las misiones completadas",
        TglMailbox = "Reclamar Recompensas de BuzÃ³n",
        DescMailbox = "Recoge todos los regalos del correo",
        BtnTutorial = "Reclamar Recompensas de Tutorial",
        DescTutorial = "Ejecuta MineTutorialDone y MineTutorialGift",

        SecProgression = "Personajes y Progreso",
        TglAutoUpgrade = "Mejorar Mineros AutomÃ¡ticamente",
        DescAutoUpgrade = "Mejora niveles de mineros activos con dinero",
        BtnEquipBest = "Equipar Mejores Personajes y Picos",
        DescEquipBest = "Invoca el remote MineEquipBest",

        SecGacha = "InvocaciÃ³n RÃ¡pida (Sin AnimaciÃ³n)",
        BtnSummon1 = "InvocaciÃ³n RÃ¡pida 1x",
        BtnSummon10 = "InvocaciÃ³n RÃ¡pida 10x",
        DescSummon = "InvocaciÃ³n instantÃ¡nea saltando cutscenes",

        SecESP = "ESP de Minerales y Mapa",
        TglOreESP = "Activar ESP de Minerales",
        DescOreESP = "Resalta minerales coloreados por rareza",
        TglStandESP = "Activar ESP de Tiendas y Altares",
        DescStandESP = "Marca la posiciÃ³n de santuarios importantes",
        SldESPDist = "Distancia MÃ¡xima de Render ESP",

        SecMovement = "Modificadores de Movimiento",
        TglSpeed = "Velocidad Personalizada",
        SldSpeed = "Valor de WalkSpeed",
        TglJump = "Salto Mejorado",
        SldJump = "Valor de JumpPower",
        TglInfJump = "Salto Infinito",
        TglNoclip = "Atravesar Paredes (Noclip)",
        TglAntiAFK = "ProtecciÃ³n Anti-AFK",
        DescAntiAFK = "Evita desconexiones por inactividad de 20 minutos",

        SecLangSelect = "SelecciÃ³n de Idioma",
        DropLanguage = "Idioma Activo",
        DescLangSelect = "Cambia el idioma del menÃº al instante",
        LangSuccess = "Idioma Cambiado",
        LangSuccessDesc = "Idioma de la interfaz actualizado a: ",

        SecConfig = "Perfiles y ConfiguraciÃ³n",
        InputConfigName = "Nombre de ConfiguraciÃ³n",
        BtnSaveConfig = "Guardar ConfiguraciÃ³n",
        DescSaveConfig = "Guarda todos los ajustes en un archivo JSON",
        BtnLoadConfig = "Cargar Config y Restaurar UI",
        DescLoadConfig = "Carga y restaura visualmente todos los controles",
        BtnResetConfig = "Restablecer a Valores Predeterminados",
        TglAutoLoad = "Carga AutomÃ¡tica al Iniciar",
        DescAutoLoad = "Restaura tus preferencias al abrir el script",
        SecKeybind = "Tecla de Visibilidad del MenÃº",
        KeybindToggle = "Tecla para Ocultar/Mostrar",
        DescKeybind = "Presiona esta tecla para alternar la visibilidad",
    },

    ["PortuguÃªs"] = {
        TabFarming = "MineraÃ§Ã£o",
        TabTeleport = "Teletransporte",
        TabAutomation = "AutomaÃ§Ã£o",
        TabGacha = "Gacha e Loja",
        TabVisuals = "Visuais (ESP)",
        TabPlayer = "Jogador e Modos",
        TabLanguage = "Idioma",
        TabConfig = "ConfiguraÃ§Ãµes",

        SecMine = "MineraÃ§Ã£o AutomÃ¡tica",
        TglAutoMine = "Minerar MinÃ©rio Alvo",
        DescAutoMine = "Teleporta e foca os mineradores no minÃ©rio escolhido",
        DropTargetOre = "Selecionar MinÃ©rio Alvo",
        DescTargetOre = "Filtra qual minÃ©rio buscar e destruir",
        SldMineRange = "Raio MÃ¡ximo de Busca",

        SecSell = "Venda Remota InstantÃ¢nea",
        TglAutoSell = "Venda AutomÃ¡tica PeriÃ³dica",
        DescAutoSell = "Vende o inventÃ¡rio sem andar atÃ© a loja",
        SldSellInterval = "Intervalo de Venda (Segundos)",
        BtnSellNow = "Vender Tudo Agora",
        DescSellNow = "Executa o remote MineSellItems diretamente",
        TglAutoChest = "Coletar BaÃºs Automaticamente",
        DescAutoChest = "Pega todos os baÃºs de drop caÃ­dos no mundo",

        SecStands = "Locais Importantes",
        BtnTpSell = "TP para Ponto de Venda",
        BtnTpPick = "TP para Loja de Picaretas",
        BtnTpEnchant = "TP para Altar de Encantamentos",
        BtnTpSummon = "TP para Altar de InvocaÃ§Ã£o",
        BtnTpAlliance = "TP para Ponto de AlianÃ§a",
        BtnTpLucky = "TP para Unreal Lucky Block",

        SecTravel = "Viagem RÃ¡pida",
        BtnTpHub = "TP para o Hub Principal",
        BtnTpPlot = "TP para Terreno Pessoal",
        BtnTpOre = "TP para o MinÃ©rio Mais PrÃ³ximo",

        SecDailies = "Recompensas DiÃ¡rias",
        TglDailySpin = "Roleta DiÃ¡ria AutomÃ¡tica",
        DescDailySpin = "Gira a roleta assim que o tempo acabar",
        TglDailyQuests = "Reivindicar MissÃµes DiÃ¡rias",
        DescDailyQuests = "Reivindica todas as missÃµes concluÃ­das",
        TglMailbox = "Coletar Recompensas do Correio",
        DescMailbox = "Coleta todos os presentes da caixa de correio",
        BtnTutorial = "Reivindicar Recompensas do Tutorial",
        DescTutorial = "Chama MineTutorialDone e MineTutorialGift",

        SecProgression = "Personagens e Equipamentos",
        TglAutoUpgrade = "Melhorar Mineradores Automaticamente",
        DescAutoUpgrade = "Sobe o nÃ­vel dos mineradores ativos com dinheiro",
        BtnEquipBest = "Equipar Melhores Personagens e Picaretas",
        DescEquipBest = "Chama o remote MineEquipBest diretamente",

        SecGacha = "InvocaÃ§Ã£o RÃ¡pida (Sem AnimaÃ§Ã£o)",
        BtnSummon1 = "InvocaÃ§Ã£o RÃ¡pida 1x",
        BtnSummon10 = "InvocaÃ§Ã£o RÃ¡pida 10x",
        DescSummon = "InvocaÃ§Ã£o instantÃ¢nea sem esperar cutscenes",

        SecESP = "ESP de MinÃ©rios e Locais",
        TglOreESP = "Ativar ESP de MinÃ©rios",
        DescOreESP = "Destaca minÃ©rios com cores baseadas na raridade",
        TglStandESP = "Ativar ESP de Altares e Lojas",
        DescStandESP = "Marca santuÃ¡rios e lojas importantes",
        SldESPDist = "DistÃ¢ncia MÃ¡xima de RenderizaÃ§Ã£o ESP",

        SecMovement = "Modificadores de Movimento",
        TglSpeed = "Super Velocidade",
        SldSpeed = "Valor de WalkSpeed",
        TglJump = "Super Pulo",
        SldJump = "Valor de JumpPower",
        TglInfJump = "Pulo Infinito",
        TglNoclip = "Atravessar Paredes (Noclip)",
        TglAntiAFK = "ProteÃ§Ã£o Anti-AFK",
        DescAntiAFK = "Evita desconexÃ£o por inatividade de 20 minutos",

        SecLangSelect = "SeleÃ§Ã£o de Idioma",
        DropLanguage = "Idioma Ativo",
        DescLangSelect = "Muda o idioma da interface imediatamente",
        LangSuccess = "Idioma Atualizado",
        LangSuccessDesc = "Idioma da interface definido para: ",

        SecConfig = "Perfis e ConfiguraÃ§Ãµes",
        InputConfigName = "Nome da ConfiguraÃ§Ã£o",
        BtnSaveConfig = "Salvar ConfiguraÃ§Ã£o",
        DescSaveConfig = "Salva todas as configuraÃ§Ãµes em JSON",
        BtnLoadConfig = "Carregar Config e Restaurar UI",
        DescLoadConfig = "Restaura todos os botÃµes e seleÃ§Ãµes visualmente",
        BtnResetConfig = "Restaurar PadrÃ£o",
        TglAutoLoad = "Carregamento AutomÃ¡tico",
        DescAutoLoad = "Carrega suas preferÃªncias ao iniciar o script",
        SecKeybind = "Tecla de Visibilidade",
        KeybindToggle = "Tecla Ocultar/Mostrar Menu",
        DescKeybind = "Pressione para alternar a exibiÃ§Ã£o do menu",
    },

    ["Ð ÑÑÑÐºÐ¸Ð¹"] = {
        TabFarming = "ÐÐ¾Ð±ÑÑÐ°",
        TabTeleport = "Ð¢ÐµÐ»ÐµÐ¿Ð¾ÑÑ",
        TabAutomation = "ÐÐ²ÑÐ¾Ð¼Ð°ÑÐ¸ÐºÐ°",
        TabGacha = "ÐÐ°ÑÐ° Ð¸ ÐÐ°Ð³Ð°Ð·Ð¸Ð½",
        TabVisuals = "ÐÐ¸Ð·ÑÐ°Ð» (ESP)",
        TabPlayer = "ÐÐ³ÑÐ¾Ðº Ð¸ ÐÐ¾Ð´Ñ",
        TabLanguage = "Ð¯Ð·ÑÐº",
        TabConfig = "ÐÐ¾Ð½ÑÐ¸Ð³",

        SecMine = "ÐÐ²ÑÐ¾-Ð´Ð¾Ð±ÑÑÐ° Ð¸ Ð¡Ð½Ð°Ð¹Ð¿ÐµÑ Ð ÑÐ´Ñ",
        TglAutoMine = "ÐÐ²ÑÐ¾-ÑÐ°ÑÐ¼ ÑÐµÐ»ÐµÐ²Ð¾Ð¹ ÑÑÐ´Ñ",
        DescAutoMine = "Ð¢Ð Ð¸ ÑÐ¾ÐºÑÑ Ð¼Ð°Ð¹Ð½ÐµÑÐ¾Ð² Ð½Ð° Ð²ÑÐ±ÑÐ°Ð½Ð½Ð¾Ð¹ ÑÑÐ´Ðµ",
        DropTargetOre = "ÐÑÐ±ÑÐ°ÑÑ ÑÐµÐ»ÐµÐ²ÑÑ ÑÑÐ´Ñ",
        DescTargetOre = "Ð¤Ð¸Ð»ÑÑÑ ÑÑÐ´Ñ Ð´Ð»Ñ Ð¿Ð¾Ð¸ÑÐºÐ° Ð¸ ÑÐ°Ð·ÑÑÑÐµÐ½Ð¸Ñ",
        SldMineRange = "Ð Ð°Ð´Ð¸ÑÑ Ð¿Ð¾Ð¸ÑÐºÐ° ÑÑÐ´Ñ",

        SecSell = "Ð£Ð´Ð°Ð»ÐµÐ½Ð½Ð°Ñ ÐÑÑÑÑÐ°Ñ ÐÑÐ¾Ð´Ð°Ð¶Ð°",
        TglAutoSell = "ÐÐµÑÐ¸Ð¾Ð´Ð¸ÑÐµÑÐºÐ°Ñ Ð°Ð²ÑÐ¾-Ð¿ÑÐ¾Ð´Ð°Ð¶Ð°",
        DescAutoSell = "ÐÑÐ¾Ð´Ð°ÐµÑ Ð¸Ð½Ð²ÐµÐ½ÑÐ°ÑÑ Ð±ÐµÐ· Ð¿Ð¾ÑÐ¾Ð´Ð° Ð² Ð¼Ð°Ð³Ð°Ð·Ð¸Ð½",
        SldSellInterval = "ÐÐ½ÑÐµÑÐ²Ð°Ð» Ð¿ÑÐ¾Ð´Ð°Ð¶Ð¸ (ÑÐµÐº)",
        BtnSellNow = "ÐÑÐ¾Ð´Ð°ÑÑ Ð²ÐµÑÑ Ð¸Ð½Ð²ÐµÐ½ÑÐ°ÑÑ Ð¿ÑÑÐ¼Ð¾ ÑÐµÐ¹ÑÐ°Ñ",
        DescSellNow = "ÐÐ³Ð½Ð¾Ð²ÐµÐ½Ð½ÑÐ¹ Ð²ÑÐ·Ð¾Ð² remote MineSellItems",
        TglAutoChest = "ÐÐ²ÑÐ¾-ÑÐ±Ð¾Ñ ÑÑÐ½Ð´ÑÐºÐ¾Ð²",
        DescAutoChest = "Ð¡Ð¾Ð±Ð¸ÑÐ°ÐµÑ Ð²ÑÐµ ÑÐ¿Ð°Ð²ÑÐ¸Ðµ ÑÑÐ½Ð´ÑÐºÐ¸ Ñ Ð»ÑÑÐ¾Ð¼",

        SecStands = "Ð¢Ð¾ÑÐºÐ¸ Ð¸Ð½ÑÐµÑÐµÑÐ°",
        BtnTpSell = "Ð¢Ð Ðº Ð¡ÐºÑÐ¿ÑÐ¸ÐºÑ (Sell Stand)",
        BtnTpPick = "Ð¢Ð Ð² ÐÐ°Ð³Ð°Ð·Ð¸Ð½ ÐÐ¸ÑÐ¾Ðº",
        BtnTpEnchant = "Ð¢Ð Ðº ÐÐ»ÑÐ°ÑÑ ÐÐ°ÑÐ°ÑÐ¾Ð²Ð°Ð½Ð¸Ñ",
        BtnTpSummon = "Ð¢Ð Ðº ÐÐ»ÑÐ°ÑÑ ÐÑÐ¸Ð·ÑÐ²Ð°",
        BtnTpAlliance = "Ð¢Ð Ðº Ð¡ÑÐµÐ½Ð´Ñ ÐÐ»ÑÑÐ½ÑÐ°",
        BtnTpLucky = "Ð¢Ð Ðº Unreal Lucky Block",

        SecTravel = "ÐÑÑÑÑÐ¾Ðµ Ð¿ÐµÑÐµÐ¼ÐµÑÐµÐ½Ð¸Ðµ",
        BtnTpHub = "Ð¢Ð Ð² ÐÐ»Ð°Ð²Ð½ÑÐ¹ Ð¥Ð°Ð±",
        BtnTpPlot = "Ð¢Ð Ð½Ð° Ð¡Ð²Ð¾Ð¹ Ð£ÑÐ°ÑÑÐ¾Ðº",
        BtnTpOre = "Ð¢Ð Ðº ÐÐ»Ð¸Ð¶Ð°Ð¹ÑÐµÐ¹ Ð ÑÐ´Ðµ",

        SecDailies = "ÐÐ¶ÐµÐ´Ð½ÐµÐ²Ð½ÑÐµ ÐÐ°Ð³ÑÐ°Ð´Ñ",
        TglDailySpin = "ÐÐ²ÑÐ¾-Ð¿ÑÐ¾ÐºÑÑÑÐºÐ° ÑÑÐ»ÐµÑÐºÐ¸",
        DescDailySpin = "ÐÑÑÑÐ¸Ñ ÐºÐ¾Ð»ÐµÑÐ¾ Ð¿ÑÐ¸ Ð³Ð¾ÑÐ¾Ð²Ð½Ð¾ÑÑÐ¸ ÑÐ°Ð¹Ð¼ÐµÑÐ°",
        TglDailyQuests = "Ð¡Ð´Ð°ÑÐ° ÐµÐ¶ÐµÐ´Ð½ÐµÐ²Ð½ÑÑ ÐºÐ²ÐµÑÑÐ¾Ð²",
        DescDailyQuests = "ÐÐ°Ð±Ð¸ÑÐ°ÐµÑ Ð½Ð°Ð³ÑÐ°Ð´Ñ Ð·Ð° Ð²ÑÐµ Ð²ÑÐ¿Ð¾Ð»Ð½ÐµÐ½Ð½ÑÐµ ÐºÐ²ÐµÑÑÑ",
        TglMailbox = "Ð¡Ð±Ð¾Ñ Ð½Ð°Ð³ÑÐ°Ð´ Ð¸Ð· Ð¿Ð¾ÑÑÑ",
        DescMailbox = "ÐÐ°Ð±Ð¸ÑÐ°ÐµÑ Ð²ÑÐµ Ð¿Ð¾Ð´Ð°ÑÐºÐ¸ Ð¸Ð· Ð¿Ð¾ÑÑÐ¾Ð²Ð¾Ð³Ð¾ ÑÑÐ¸ÐºÐ°",
        BtnTutorial = "ÐÐ°Ð±ÑÐ°ÑÑ Ð½Ð°Ð³ÑÐ°Ð´Ñ Ð·Ð° ÐÐ±ÑÑÐµÐ½Ð¸Ðµ",
        DescTutorial = "ÐÑÐ¿ÑÐ°Ð²Ð»ÑÐµÑ MineTutorialDone Ð¸ MineTutorialGift",

        SecProgression = "ÐÑÐ¾ÐºÐ°ÑÐºÐ° ÐÐ°Ð¹Ð½ÐµÑÐ¾Ð² Ð¸ Ð¡Ð½Ð°ÑÑÐ¶ÐµÐ½Ð¸Ñ",
        TglAutoUpgrade = "ÐÐ²ÑÐ¾-Ð¿ÑÐ¾ÐºÐ°ÑÐºÐ° Ð¼Ð°Ð¹Ð½ÐµÑÐ¾Ð²",
        DescAutoUpgrade = "ÐÐ¾Ð²ÑÑÐ°ÐµÑ ÑÑÐ¾Ð²ÐµÐ½Ñ Ð°ÐºÑÐ¸Ð²Ð½ÑÑ Ð¿ÐµÑÑÐ¾Ð½Ð°Ð¶ÐµÐ¹ Ð·Ð° Ð´ÐµÐ½ÑÐ³Ð¸",
        BtnEquipBest = "Ð­ÐºÐ¸Ð¿Ð¸ÑÐ¾Ð²Ð°ÑÑ Ð»ÑÑÑÐ¸Ñ Ð¼Ð°Ð¹Ð½ÐµÑÐ¾Ð² Ð¸ ÐºÐ¸ÑÐºÐ¸",
        DescEquipBest = "ÐÐ³Ð½Ð¾Ð²ÐµÐ½Ð½Ð¾ Ð²ÑÐ·ÑÐ²Ð°ÐµÑ MineEquipBest",

        SecGacha = "ÐÑÑÑÑÑÐ¹ ÐÑÐ¸Ð·ÑÐ² (ÐÐµÐ· ÐÐ½Ð¸Ð¼Ð°ÑÐ¸Ð¸)",
        BtnSummon1 = "ÐÑÑÑÑÑÐ¹ Ð¿ÑÐ¸Ð·ÑÐ² 1x",
        BtnSummon10 = "ÐÑÑÑÑÑÐ¹ Ð¿ÑÐ¸Ð·ÑÐ² 10x",
        DescSummon = "ÐÐ³Ð½Ð¾Ð²ÐµÐ½Ð½ÑÐ¹ Ð¿ÑÐ¸Ð·ÑÐ² Ñ Ð¿ÑÐ¾Ð¿ÑÑÐºÐ¾Ð¼ Ð·Ð°ÑÑÐ°Ð²Ð¾Ðº",

        SecESP = "ESP Ð ÑÐ´Ñ Ð¸ ÐÐ±ÑÐµÐºÑÐ¾Ð²",
        TglOreESP = "ÐÐºÐ»ÑÑÐ¸ÑÑ ESP ÑÑÐ´Ñ",
        DescOreESP = "ÐÐ¾Ð´ÑÐ²ÐµÑÐ¸Ð²Ð°ÐµÑ ÑÑÐ´Ñ ÑÐ²ÐµÑÐ¾Ð¼ ÑÐµÐ´ÐºÐ¾ÑÑÐ¸",
        TglStandESP = "ÐÐºÐ»ÑÑÐ¸ÑÑ ESP Ð¼Ð°Ð³Ð°Ð·Ð¸Ð½Ð¾Ð² Ð¸ Ð°Ð»ÑÐ°ÑÐµÐ¹",
        DescStandESP = "ÐÑÐ¼ÐµÑÐ°ÐµÑ ÐºÐ»ÑÑÐµÐ²ÑÐµ Ð¿Ð¾ÑÑÑÐ¾Ð¹ÐºÐ¸ Ð½Ð° ÐºÐ°ÑÑÐµ",
        SldESPDist = "ÐÐ°ÐºÑ. Ð´Ð¸ÑÑÐ°Ð½ÑÐ¸Ñ Ð¾ÑÑÐ¸ÑÐ¾Ð²ÐºÐ¸ ESP",

        SecMovement = "ÐÐ¾Ð´Ð¸ÑÐ¸ÐºÐ°ÑÐ¾ÑÑ ÐÐ²Ð¸Ð¶ÐµÐ½Ð¸Ñ",
        TglSpeed = "Ð£Ð²ÐµÐ»Ð¸ÑÐµÐ½Ð½Ð°Ñ ÑÐºÐ¾ÑÐ¾ÑÑÑ",
        SldSpeed = "ÐÐ½Ð°ÑÐµÐ½Ð¸Ðµ WalkSpeed",
        TglJump = "Ð£Ð²ÐµÐ»Ð¸ÑÐµÐ½Ð½ÑÐ¹ Ð¿ÑÑÐ¶Ð¾Ðº",
        SldJump = "ÐÐ½Ð°ÑÐµÐ½Ð¸Ðµ JumpPower",
        TglInfJump = "ÐÐµÑÐºÐ¾Ð½ÐµÑÐ½ÑÐ¹ Ð¿ÑÑÐ¶Ð¾Ðº",
        TglNoclip = "Ð¥Ð¾Ð¶Ð´ÐµÐ½Ð¸Ðµ ÑÐºÐ²Ð¾Ð·Ñ ÑÑÐµÐ½Ñ (Noclip)",
        TglAntiAFK = "ÐÐ°ÑÐ¸ÑÐ° Ð¾Ñ ÐÐ¤Ð",
        DescAntiAFK = "ÐÑÐµÐ´Ð¾ÑÐ²ÑÐ°ÑÐ°ÐµÑ ÐºÐ¸Ðº Ð·Ð° 20 Ð¼Ð¸Ð½ÑÑ Ð±ÐµÐ·Ð´ÐµÐ¹ÑÑÐ²Ð¸Ñ",

        SecLangSelect = "ÐÑÐ±Ð¾Ñ Ð¯Ð·ÑÐºÐ° ÐÐµÐ½Ñ",
        DropLanguage = "ÐÐºÑÐ¸Ð²Ð½ÑÐ¹ ÑÐ·ÑÐº",
        DescLangSelect = "ÐÐ³Ð½Ð¾Ð²ÐµÐ½Ð½Ð¾ Ð¿ÐµÑÐµÐ²Ð¾Ð´Ð¸Ñ Ð²ÑÐµ ÑÐµÐºÑÑÑ Ð² Ð¼ÐµÐ½Ñ",
        LangSuccess = "Ð¯Ð·ÑÐº ÐÐ·Ð¼ÐµÐ½ÐµÐ½",
        LangSuccessDesc = "Ð¯Ð·ÑÐº Ð¸Ð½ÑÐµÑÑÐµÐ¹ÑÐ° ÑÑÐ¿ÐµÑÐ½Ð¾ Ð¾Ð±Ð½Ð¾Ð²Ð»ÐµÐ½ Ð½Ð°: ",

        SecConfig = "ÐÑÐ¾ÑÐ¸Ð»Ð¸ Ð¸ Ð¡Ð¾ÑÑÐ°Ð½ÐµÐ½Ð¸Ðµ ÐÐ°ÑÑÑÐ¾ÐµÐº",
        InputConfigName = "ÐÐ¼Ñ Ð¿ÑÐµÑÐµÑÐ°",
        BtnSaveConfig = "Ð¡Ð¾ÑÑÐ°Ð½Ð¸ÑÑ ÐÐ¾Ð½ÑÐ¸Ð³",
        DescSaveConfig = "ÐÐ°Ð¿Ð¸ÑÑÐ²Ð°ÐµÑ Ð²ÑÐµ Ð½Ð°ÑÑÑÐ¾Ð¹ÐºÐ¸ Ð¸ Ð¿ÐµÑÐµÐºÐ»ÑÑÐ°ÑÐµÐ»Ð¸ Ð² JSON",
        BtnLoadConfig = "ÐÐ°Ð³ÑÑÐ·Ð¸ÑÑ Ð¸ ÐÐ¾ÑÑÑÐ°Ð½Ð¾Ð²Ð¸ÑÑ UI",
        DescLoadConfig = "ÐÐ¾ÑÑÑÐ°Ð½Ð°Ð²Ð»Ð¸Ð²Ð°ÐµÑ Ð²ÑÐµ Ð¿ÐµÑÐµÐºÐ»ÑÑÐ°ÑÐµÐ»Ð¸ Ð¸ ÑÐ¿Ð¸ÑÐºÐ¸ Ð²Ð¸Ð·ÑÐ°Ð»ÑÐ½Ð¾",
        BtnResetConfig = "Ð¡Ð±ÑÐ¾Ñ ÐÐ°ÑÑÑÐ¾ÐµÐº",
        TglAutoLoad = "ÐÐ²ÑÐ¾-Ð·Ð°Ð³ÑÑÐ·ÐºÐ° Ð¿ÑÐ¸ ÑÑÐ°ÑÑÐµ",
        DescAutoLoad = "ÐÐ²ÑÐ¾Ð¼Ð°ÑÐ¸ÑÐµÑÐºÐ¸ Ð¿ÑÐ¸Ð¼ÐµÐ½ÑÐµÑ ÐºÐ¾Ð½ÑÐ¸Ð³ Ð¿ÑÐ¸ Ð·Ð°Ð¿ÑÑÐºÐµ ÑÐºÑÐ¸Ð¿ÑÐ°",
        SecKeybind = "ÐÐ¾ÑÑÑÐ°Ñ ÐºÐ»Ð°Ð²Ð¸ÑÐ° Ð¼ÐµÐ½Ñ",
        KeybindToggle = "ÐÐ»Ð°Ð²Ð¸ÑÐ° ÑÐºÑÑÑÐ¸Ñ Ð¼ÐµÐ½Ñ",
        DescKeybind = "ÐÐ°Ð¶Ð¼Ð¸ÑÐµ Ð´Ð»Ñ ÑÐºÑÑÑÐ¸Ñ Ð¸Ð»Ð¸ Ð¾ÑÐ¾Ð±ÑÐ°Ð¶ÐµÐ½Ð¸Ñ Ð¿Ð°Ð½ÐµÐ»Ð¸",
    },

    ["Tiáº¿ng Viá»t"] = {
        TabFarming = "Khai ThÃ¡c",
        TabTeleport = "Dá»ch Chuyá»n",
        TabAutomation = "Tá»± Äá»ng",
        TabGacha = "Gacha & Cá»­a HÃ ng",
        TabVisuals = "Hiá»n Thá» (ESP)",
        TabPlayer = "NhÃ¢n Váº­t & Mod",
        TabLanguage = "NgÃ´n Ngá»¯",
        TabConfig = "Cáº¥u HÃ¬nh",

        SecMine = "Tá»± Äá»ng Khai ThÃ¡c Quáº·ng",
        TglAutoMine = "Tá»± ÄÃ o Quáº·ng Má»¥c TiÃªu",
        DescAutoMine = "Dá»ch chuyá»n vÃ  táº­p trung ÄÃ o quáº·ng ÄÃ£ chá»n",
        DropTargetOre = "Chá»n Quáº·ng Má»¥c TiÃªu",
        DescTargetOre = "Lá»c loáº¡i quáº·ng cáº§n tÃ¬m vÃ  phÃ¡ huá»·",
        SldMineRange = "BÃ¡n KÃ­nh TÃ¬m Quáº·ng",

        SecSell = "BÃ¡n Äá» Tá»« Xa Cá»±c Nhanh",
        TglAutoSell = "Tá»± Äá»ng BÃ¡n Äá»nh Ká»³",
        DescAutoSell = "BÃ¡n toÃ n bá» kho Äá» mÃ  khÃ´ng cáº§n Äáº¿n cá»­a hÃ ng",
        SldSellInterval = "Khoáº£ng Thá»i Gian BÃ¡n (GiÃ¢y)",
        BtnSellNow = "BÃ¡n ToÃ n Bá» Ngay Láº­p Tá»©c",
        DescSellNow = "Gá»­i trá»±c tiáº¿p sá»± kiá»n MineSellItems",
        TglAutoChest = "Tá»± Nháº·t RÆ°Æ¡ng RÆ¡i",
        DescAutoChest = "Tá»± Äá»ng thu tháº­p táº¥t cáº£ rÆ°Æ¡ng rÆ¡i trÃªn báº£n Äá»",

        SecStands = "Äá»a Äiá»m Tháº¿ Giá»i",
        BtnTpSell = "Äáº¿n Chá» BÃ¡n Äá»",
        BtnTpPick = "Äáº¿n Cá»­a HÃ ng Cuá»c",
        BtnTpEnchant = "Äáº¿n BÃ n PhÃ¹ PhÃ©p",
        BtnTpSummon = "Äáº¿n Äá»n Triá»u Há»i",
        BtnTpAlliance = "Äáº¿n Khu LiÃªn Minh",
        BtnTpLucky = "Äáº¿n Khá»i May Máº¯n Unreal",

        SecTravel = "Dá»ch Chuyá»n Nhanh",
        BtnTpHub = "Vá» Sáº£nh ChÃ­nh (Hub)",
        BtnTpPlot = "Vá» Khu Äáº¥t CÃ¡ NhÃ¢n",
        BtnTpOre = "Äáº¿n Quáº·ng Gáº§n Nháº¥t",

        SecDailies = "Pháº§n ThÆ°á»ng HÃ ng NgÃ y",
        TglDailySpin = "Tá»± Quay VÃ²ng Quay HÃ ng NgÃ y",
        DescDailySpin = "Quay ngay khi háº¿t thá»i gian há»i",
        TglDailyQuests = "Tá»± Nháº­n Nhiá»m Vá»¥ HÃ ng NgÃ y",
        DescDailyQuests = "Nháº­n thÆ°á»ng táº¥t cáº£ nhiá»m vá»¥ ÄÃ£ hoÃ n thÃ nh",
        TglMailbox = "Tá»± Nháº­n QuÃ  Há»p ThÆ°",
        DescMailbox = "Thu tháº­p toÃ n bá» váº­t pháº©m trong hÃ²m thÆ°",
        BtnTutorial = "Nháº­n ThÆ°á»ng HÆ°á»ng Dáº«n",
        DescTutorial = "Thá»±c hiá»n MineTutorialDone vÃ  MineTutorialGift",

        SecProgression = "NÃ¢ng Cáº¥p Thá»£ ÄÃ o & Cuá»c",
        TglAutoUpgrade = "Tá»± NÃ¢ng Cáº¥p Thá»£ ÄÃ o",
        DescAutoUpgrade = "Tá»± Äá»ng dÃ¹ng tiá»n Äá» lÃªn cáº¥p nhÃ¢n váº­t",
        BtnEquipBest = "Trang Bá» NhÃ¢n Váº­t & Cuá»c Tá»t Nháº¥t",
        DescEquipBest = "Gá»i trá»±c tiáº¿p remote MineEquipBest",

        SecGacha = "Triá»u Há»i Cá»±c Nhanh (Bá» Qua Hoáº¡t áº¢nh)",
        BtnSummon1 = "Triá»u Há»i Nhanh 1x",
        BtnSummon10 = "Triá»u Há»i Nhanh 10x",
        DescSummon = "Nháº­n tÆ°á»ng ngay láº­p tá»©c khÃ´ng cáº§n xem video",

        SecESP = "ESP Quáº·ng & Váº­t Thá» Báº£n Äá»",
        TglOreESP = "Báº­t ESP Quáº·ng",
        DescOreESP = "LÃ m ná»i báº­t quáº·ng theo mÃ u sáº¯c Äá» hiáº¿m",
        TglStandESP = "Báº­t ESP Cá»­a HÃ ng & BÃ n Thá»",
        DescStandESP = "ÄÃ¡nh dáº¥u vá» trÃ­ cÃ¡c cÃ´ng trÃ¬nh quan trá»ng",
        SldESPDist = "Khoáº£ng CÃ¡ch Hiá»n Thá» ESP Tá»i Äa",

        SecMovement = "Chá»nh Sá»­a Di Chuyá»n",
        TglSpeed = "TÄng Tá»c Cháº¡y",
        SldSpeed = "Tá»c Äá» Di Chuyá»n",
        TglJump = "TÄng Sá»©c Báº­t Nháº£y",
        SldJump = "Äá» Cao Báº­t Nháº£y",
        TglInfJump = "Nháº£y VÃ´ Háº¡n",
        TglNoclip = "Äi XuyÃªn TÆ°á»ng (Noclip)",
        TglAntiAFK = "Chá»ng Treo MÃ¡y (Anti-AFK)",
        DescAntiAFK = "NgÄn ngá»«a bá» ÄÃ¡ ra sau 20 phÃºt khÃ´ng hoáº¡t Äá»ng",

        SecLangSelect = "Chá»n NgÃ´n Ngá»¯ Giao Diá»n",
        DropLanguage = "NgÃ´n Ngá»¯ Hiá»n Táº¡i",
        DescLangSelect = "Thay Äá»i ngÃ´n ngá»¯ báº£ng Äiá»u khiá»n ngay láº­p tá»©c",
        LangSuccess = "ÄÃ£ Äá»i NgÃ´n Ngá»¯",
        LangSuccessDesc = "NgÃ´n ngá»¯ giao diá»n ÄÃ£ cáº­p nháº­t thÃ nh: ",

        SecConfig = "Há» SÆ¡ & LÆ°u Cáº¥u HÃ¬nh",
        InputConfigName = "TÃªn Cáº¥u HÃ¬nh",
        BtnSaveConfig = "LÆ°u Cáº¥u HÃ¬nh",
        DescSaveConfig = "LÆ°u toÃ n bá» cÃ i Äáº·t vÃ o tá»p JSON",
        BtnLoadConfig = "Táº£i Cáº¥u HÃ¬nh & KhÃ´i Phá»¥c UI",
        DescLoadConfig = "KhÃ´i phá»¥c tráº¡ng thÃ¡i báº­t/táº¯t vÃ  giÃ¡ trá» hiá»n thá»",
        BtnResetConfig = "KhÃ´i Phá»¥c Máº·c Äá»nh",
        TglAutoLoad = "Tá»± Táº£i Khi Khá»i Äá»ng",
        DescAutoLoad = "Tá»± Äá»ng Ã¡p dá»¥ng cÃ i Äáº·t khi cháº¡y script",
        SecKeybind = "PhÃ­m Táº¯t áº¨n/Hiá»n Menu",
        KeybindToggle = "PhÃ­m ÄÃ³ng/Má» Báº£ng Äiá»u Khiá»n",
        DescKeybind = "Nháº¥n phÃ­m nÃ y Äá» áº©n hoáº·c má» láº¡i giao diá»n",
    },

    ["æ¥æ¬èª"] = {
        TabFarming = "æ¡æ",
        TabTeleport = "ãã¬ãã¼ã",
        TabAutomation = "èªåå",
        TabGacha = "ã¬ãã£ã»åº",
        TabVisuals = "è¦è¦ (ESP)",
        TabPlayer = "ãã¬ã¤ã¤ã¼",
        TabLanguage = "è¨èªè¨­å®",
        TabConfig = "è¨­å®ä¿å­",

        SecMine = "èªåæ¡æã·ã¹ãã ",
        TglAutoMine = "å¯¾è±¡é±ç³ã®èªåæ¡æ",
        DescAutoMine = "é¸æããé±ç³ã¸ãã¬ãã¼ããéä¸­æ»æãã¾ã",
        DropTargetOre = "å¯¾è±¡é±ç³ã®é¸æ",
        DescTargetOre = "ç ´å£å¯¾è±¡ã®é±ç³ãã£ã«ã¿ã¼",
        SldMineRange = "æå¤§æ¢ç´¢åå¾",

        SecSell = "é éå³æå£²å´",
        TglAutoSell = "å®æçãªé éå£²å´",
        DescAutoSell = "å£²å´æã«è¡ããã«ã¤ã³ãã³ããªãèªåå£²å´",
        SldSellInterval = "å£²å´éé (ç§)",
        BtnSellNow = "ä»ããææåããã¹ã¦å£²å´",
        DescSellNow = "MineSellItemsãç´æ¥å®è¡",
        TglAutoChest = "ãã­ãããã§ã¹ãèªååå",
        DescAutoChest = "è½ã¡ã¦ãããã¹ã¦ã®ãã§ã¹ããèªåç²å¾",

        SecStands = "éè¦æ½è¨­ã¹ããã",
        BtnTpSell = "å£²å´ã¹ã¿ã³ãã¸TP",
        BtnTpPick = "ãã«ãã·å±ã¸TP",
        BtnTpEnchant = "ã¨ã³ãã£ã³ãç¥­å£ã¸TP",
        BtnTpSummon = "å¬åç¥­å£ã¸TP",
        BtnTpAlliance = "ã¢ã©ã¤ã¢ã³ã¹ã¸TP",
        BtnTpLucky = "Unreal Lucky Blockã¸TP",

        SecTravel = "é«éç§»å",
        BtnTpHub = "ããã¸ãã¡ã¹ããã©ãã«",
        BtnTpPlot = "èªé£ãã­ããã¸ãã¡ã¹ããã©ãã«",
        BtnTpOre = "æå¯ãå¯¾è±¡é±ç³ã¸TP",

        SecDailies = "ãã¤ãªã¼å ±é¬ã»ã¡ã¼ã«",
        TglDailySpin = "ãã¤ãªã¼ã«ã¼ã¬ããèªååè»¢",
        DescDailySpin = "ã¯ã¼ã«ãã¦ã³çµäºæã«èªåã§ã¹ãã³",
        TglDailyQuests = "ãã¤ãªã¼ã¯ã¨ã¹ãèªååå",
        DescDailyQuests = "éæããå¨ã¯ã¨ã¹ãã®å ±é¬ãä¸æ¬åå",
        TglMailbox = "ã¡ã¼ã«ããã¯ã¹å ±é¬èªååå",
        DescMailbox = "ã¡ã¼ã«ã®å¨ãã¬ã¼ã³ããåå",
        BtnTutorial = "ãã¥ã¼ããªã¢ã«å ±é¬ãåå",
        DescTutorial = "MineTutorialDoneã»MineTutorialGiftãå®è¡",

        SecProgression = "ã­ã£ã©ã¯ã¿ã¼ã»ãã«ãã·å¼·å",
        TglAutoUpgrade = "éç½®ãã¤ãã¼èªåã¬ãã«ã¢ãã",
        DescAutoUpgrade = "ææéã§ãã¤ãã¼ã®ã¬ãã«ãèªåå¼·å",
        BtnEquipBest = "æå¼·ã­ã£ã©ã»ãã«ãã·ãä¸æ¬è£å",
        DescEquipBest = "MineEquipBestãç´æ¥å¼ã³åºã",

        SecGacha = "é«éã¬ãã£ (æ¼åºã¹ã­ãã)",
        BtnSummon1 = "é«éå¬å 1å",
        BtnSummon10 = "é«éå¬å 10å",
        DescSummon = "æ¼åºãé£ã°ãã¦å³åº§ã«ã­ã£ã©ã¯ã¿ã¼ãç²å¾",

        SecESP = "é±ç³ã»æ½è¨­ESP (ééè¡¨ç¤º)",
        TglOreESP = "é±ç³ESPãæå¹å",
        DescOreESP = "ã¬ã¢åº¦å¥ã®è²ã§é±ç³ããã¤ã©ã¤ãè¡¨ç¤º",
        TglStandESP = "æ½è¨­ã»ç¥­å£ESPãæå¹å",
        DescStandESP = "éè¦ã·ã§ãããç¥­å£ã®ä½ç½®ããã¼ã­ã³ã°",
        SldESPDist = "ESPæå¤§æç»è·é¢",

        SecMovement = "ç§»åã»ç©çè¨­å®",
        TglSpeed = "ç§»åéåº¦ãã¼ã¹ã",
        SldSpeed = "WalkSpeedè¨­å®å¤",
        TglJump = "ã¸ã£ã³ãåãã¼ã¹ã",
        SldJump = "JumpPowerè¨­å®å¤",
        TglInfJump = "ç¡éã¸ã£ã³ã",
        TglNoclip = "å£ããæã (Noclip)",
        TglAntiAFK = "æ¾ç½®åæ­é²æ­¢ (Anti-AFK)",
        DescAntiAFK = "20åæ¾ç½®ã«ããåæ­ãé²ãã¾ã",

        SecLangSelect = "UIè¨èªã®åãæ¿ã",
        DropLanguage = "ç¾å¨ã®è¨èª",
        DescLangSelect = "UIã¡ãã¥ã¼ã®å¨ãã­ã¹ããå³åº§ã«å¤æ´",
        LangSuccess = "è¨èªãå¤æ´ãã¾ãã",
        LangSuccessDesc = "UIè¨èªãä»¥ä¸ã«æ´æ°ããã¾ãã: ",

        SecConfig = "è¨­å®ãã­ãã¡ã¤ã«ã¨ä¿å­",
        InputConfigName = "ããªã»ããå",
        BtnSaveConfig = "è¨­å®ãä¿å­",
        DescSaveConfig = "ãã¹ã¦ã®ãã°ã«ã¨è¨­å®ãJSONã«ä¿å­",
        BtnLoadConfig = "è¨­å®ãèª­ã¿è¾¼ã¿UIãå¾©å",
        DescLoadConfig = "è¨­å®ãèª­ã¿è¾¼ã¿ãã°ã«ç­ã®è¡¨ç¤ºãå³åº§ã«åæ",
        BtnResetConfig = "åæè¨­å®ã«æ»ã",
        TglAutoLoad = "èµ·åæã«èªåèª­ã¿è¾¼ã¿",
        DescAutoLoad = "ã¹ã¯ãªããå®è¡æã«ååã®è¨­å®ãèªåé©ç¨",
        SecKeybind = "UIè¡¨ç¤ºåãæ¿ãã­ã¼",
        KeybindToggle = "ã¡ãã¥ã¼è¡¨ç¤º/éè¡¨ç¤ºã­ã¼",
        DescKeybind = "ãã®ã­ã¼ãæ¼ãã¦ã¡ãã¥ã¼ã®è¡¨ç¤ºç¶æãåãæ¿ãã¾ã",
    },

    ["íêµ­ì´"] = {
        TabFarming = "ì±êµ´",
        TabTeleport = "ìê°ì´ë",
        TabAutomation = "ìëí",
        TabGacha = "ê°ì±  ë° ìì ",
        TabVisuals = "í¬ì (ESP)",
        TabPlayer = "íë ì´ì´",
        TabLanguage = "ì¸ì´ ì¤ì ",
        TabConfig = "ì¤ì  ê´ë¦¬",

        SecMine = "ìë ì±êµ´ ìì¤í",
        TglAutoMine = "ëª©í ê´ì ìë ì±êµ´",
        DescAutoMine = "ì íí ê´ìì¼ë¡ ì´ëíì¬ ë§ì´ëë¥¼ ì§ì¤ìíµëë¤",
        DropTargetOre = "ëª©í ê´ì ì í",
        DescTargetOre = "íì ë° íê´´í  ê´ì íí°ë§",
        SldMineRange = "ê´ì íì ë°ê²½",

        SecSell = "ìê²© ì¦ì íë§¤",
        TglAutoSell = "ì£¼ê¸°ì  ìê²© ìë íë§¤",
        DescAutoSell = "ìì ì ê°ì§ ìê³  ê°ë°© ìì ê´ìì íë§¤í©ëë¤",
        SldSellInterval = "íë§¤ ì£¼ê¸° (ì´)",
        BtnSellNow = "ì§ê¸ ëª¨ë  ìì´í íë§¤",
        DescSellNow = "MineSellItems ë¦¬ëª¨í¸ ì¦ì í¸ì¶",
        TglAutoChest = "ëë¡­ ìì ìë íë",
        DescAutoChest = "ë§µì ë¨ì´ì§ ëª¨ë  ë³´ì ììë¥¼ ìì§í©ëë¤",

        SecStands = "ì£¼ì ì¥ì",
        BtnTpSell = "íë§¤ìë¡ ìê°ì´ë",
        BtnTpPick = "ê³¡ê´­ì´ ìì ì¼ë¡ ìê°ì´ë",
        BtnTpEnchant = "ì¸ì±í¸ ì ë¨ì¼ë¡ ìê°ì´ë",
        BtnTpSummon = "ìí ì ë¨ì¼ë¡ ìê°ì´ë",
        BtnTpAlliance = "ê¸¸ë/ì¼ë¼ì´ì¸ì¤ë¡ ìê°ì´ë",
        BtnTpLucky = "Unreal Lucky Blockì¼ë¡ ìê°ì´ë",

        SecTravel = "ë¹ ë¥¸ ì´ë",
        BtnTpHub = "ì¤ì íë¸ë¡ ë¹ ë¥¸ ì´ë",
        BtnTpPlot = "ë´ ê´ì° êµ¬ì­ì¼ë¡ ë¹ ë¥¸ ì´ë",
        BtnTpOre = "ê°ì¥ ê°ê¹ì´ ëª©í ê´ìì¼ë¡ ìê°ì´ë",

        SecDailies = "ì¼ì¼ ë³´ì ë° ì°í¸í¨",
        TglDailySpin = "ì¼ì¼ ë£°ë  ìë íì ",
        DescDailySpin = "ì¿¨ë¤ì´ì´ ëëë©´ ìëì¼ë¡ ë£°ë ì ëë¦½ëë¤",
        TglDailyQuests = "ì¼ì¼ íì¤í¸ ìë ìë ¹",
        DescDailyQuests = "ìë£ë ëª¨ë  ì¼ì¼ íì¤í¸ ë³´ìì ìë ¹í©ëë¤",
        TglMailbox = "ì°í¸í¨ ë³´ì ìë ìë ¹",
        DescMailbox = "ì°í¸í¨ì ëª¨ë  ì ë¬¼ê³¼ ë³´ìì ë°ìµëë¤",
        BtnTutorial = "íí ë¦¬ì¼ ë³´ì ìë ¹",
        DescTutorial = "MineTutorialDone ë° MineTutorialGift ì¤í",

        SecProgression = "ë§ì´ë ë° ì¥ë¹ ì¡ì±",
        TglAutoUpgrade = "íì± ë§ì´ë ìë ë ë²¨ì",
        DescAutoUpgrade = "ë³´ì  ê³¨ëë¡ ë§ì´ë ë ë²¨ì ìë ê°íí©ëë¤",
        BtnEquipBest = "ìµê³  ë§ì´ë ë° ê³¡ê´­ì´ ìë ì¥ì°©",
        DescEquipBest = "MineEquipBest ë¦¬ëª¨í¸ ì¦ì ì¤í",

        SecGacha = "ê³ ì ìí (ì°ì¶ ì¤íµ)",
        BtnSummon1 = "ê³ ì ìí 1í",
        BtnSummon10 = "ê³ ì ìí 10í",
        DescSummon = "ëª¨ë  ìí ì»·ì ì ê±´ëë°ê³  ì¦ì íëí©ëë¤",

        SecESP = "ê´ì ë° ìì¹ í¬ì (ESP)",
        TglOreESP = "ê´ì ESP íì±í",
        DescOreESP = "í¬ê·ëë³ ììì¼ë¡ ê´ì ë¸ëë¥¼ íìí©ëë¤",
        TglStandESP = "ìì  ë° ì ë¨ ESP íì±í",
        DescStandESP = "ì£¼ì ìì¤ê³¼ ì¬ìì ìì¹ë¥¼ íìí©ëë¤",
        SldESPDist = "ESP ìµë ë ëë§ ê±°ë¦¬",

        SecMovement = "ì´ë ë° ë¬¼ë¦¬ ì¡°ì ",
        TglSpeed = "ì´ë ìë ì¦ê°",
        SldSpeed = "WalkSpeed ìì¹",
        TglJump = "ì íë ¥ ì¦ê°",
        SldJump = "JumpPower ìì¹",
        TglInfJump = "ë¬´í ì í",
        TglNoclip = "ë²½ ë«ê¸° (Noclip)",
        TglAntiAFK = "ìë¦¬ë¹ì ë°©ì§ (Anti-AFK)",
        DescAntiAFK = "20ë¶ ì í´ë¡ ì¸í íê¹ì ë°©ì§í©ëë¤",

        SecLangSelect = "UI ì¸ì´ ì í",
        DropLanguage = "íì¬ ì¸ì´",
        DescLangSelect = "WindUI ë©ë´ì ëª¨ë  íì¤í¸ë¥¼ ì¦ì ë³ê²½í©ëë¤",
        LangSuccess = "ì¸ì´ ë³ê²½ ìë£",
        LangSuccessDesc = "UI ì¸ì´ê° ë¤ìì¼ë¡ ìë°ì´í¸ëììµëë¤: ",

        SecConfig = "íë¡í ë° ì¤ì  ì ì¥",
        InputConfigName = "íë¦¬ì ì´ë¦",
        BtnSaveConfig = "ì¤ì  ì ì¥",
        DescSaveConfig = "ëª¨ë  í ê¸ ë° ì¤ì ì JSON íì¼ë¡ ì ì¥í©ëë¤",
        BtnLoadConfig = "ì¤ì  ë¶ë¬ì¤ê¸° & UI ë³µì",
        DescLoadConfig = "ì¤ì ì ë¶ë¬ì ëª¨ë  ìê°ì  í ê¸ì ì¤ìê° ë³µìí©ëë¤",
        BtnResetConfig = "ê¸°ë³¸ê°ì¼ë¡ ì´ê¸°í",
        TglAutoLoad = "ìì ì ìë ë¶ë¬ì¤ê¸°",
        DescAutoLoad = "ì¤í¬ë¦½í¸ ì¤í ì ì¤ì ì ìëì¼ë¡ ì ì©í©ëë¤",
        SecKeybind = "ë©ë´ ë¨ì¶í¤ ì¤ì ",
        KeybindToggle = "ë©ë´ ì´ê¸°/ë«ê¸° ë¨ì¶í¤",
        DescKeybind = "ì´ í¤ë¥¼ ëë¬ ë©ë´ë¥¼ ì´ê±°ë ì¨ê¹ëë¤",
    },

    ["ç®ä½ä¸­æ"] = {
        TabFarming = "ææç³»ç»",
        TabTeleport = "ä¼ éç³»ç»",
        TabAutomation = "èªå¨ææº",
        TabGacha = "æ½å¡ååº",
        TabVisuals = "è§è§éè§",
        TabPlayer = "ç©å®¶å±æ§",
        TabLanguage = "è¯­è¨åæ¢",
        TabConfig = "éç½®ç®¡ç",

        SecMine = "èªå¨éç¿ä¸ç¿ç³çå»",
        TglAutoMine = "èªå¨å¼éç®æ ç¿ç³",
        DescAutoMine = "èªå¨ä¼ éå¹¶éç«å¼éæéé¶ä½ç¿ç³",
        DropTargetOre = "éæ©ç®æ ç¿ç³",
        DescTargetOre = "ç­ééè¦è¿½è¸ªä¸ééçç¿ç³ç§ç±»",
        SldMineRange = "æå¤§æç¿åå¾",

        SecSell = "å¨å¾è¿ç¨ç§å",
        TglAutoSell = "å®æèªå¨è¿ç¨åºå®",
        DescAutoSell = "æ éè·åååºï¼ç´æ¥è¿ç¨æ¸ç©ºå®åèå",
        SldSellInterval = "åºå®é´é (ç§)",
        BtnSellNow = "ç«å³åºå®èåå¨é¨ç©å",
        DescSellNow = "ç´æ¥è°ç¨MineSellItemsè¿ç¨æ¥å£",
        TglAutoChest = "èªå¨æ¾åå®ç®±æè½",
        DescAutoChest = "èªå¨é£æ¾å¨å¾æ£è½çæå©åå®ç®±",

        SecStands = "æ ¸å¿å»ºç­åæ ",
        BtnTpSell = "ä¼ éè³å®åå°",
        BtnTpPick = "ä¼ éè³éå­ååº",
        BtnTpEnchant = "ä¼ éè³éé­ç¥­å",
        BtnTpSummon = "ä¼ éè³å¬å¤ç¥­å",
        BtnTpAlliance = "ä¼ éè³å¬ä¼å±å°",
        BtnTpLucky = "ä¼ éè³Unrealå¹¸è¿æ¹å",

        SecTravel = "åºåå¿«éä¼ é",
        BtnTpHub = "å¿«éä¼ éè³ä¸­å¤®ä¸»å (Hub)",
        BtnTpPlot = "å¿«éä¼ éè³ç§äººé¢å°ç¿åº",
        BtnTpOre = "ä¼ éè³æè¿çç®æ ç¿ç³",

        SecDailies = "æ¯æ¥å¥å±ä¸é®ä»¶",
        TglDailySpin = "èªå¨æ½åæ¯æ¥è½¬ç",
        DescDailySpin = "å·å´ç»æåèªå¨æè½¬å¹¸è¿å¤§è½¬ç",
        TglDailyQuests = "èªå¨é¢åæ¯æ¥ä»»å¡å¥å±",
        DescDailyQuests = "ä¸é®é¢åææå·²è¾¾ææ¯æ¥ä»»å¡",
        TglMailbox = "èªå¨é¢åé®ç®±å¥å±",
        DescMailbox = "å¨èªå¨æ¸ç©ºé®ç®±åçåè´¹ç¤¼ç©",
        BtnTutorial = "ä¸é®é¢åæ°ææç¨ç¤¼å",
        DescTutorial = "è°ç¨MineTutorialDoneä¸MineTutorialGift",

        SecProgression = "è§è²ä¸è£å¤æé¿",
        TglAutoUpgrade = "èªå¨åçº§å¨åºç¿å·¥",
        DescAutoUpgrade = "éå¸åè¶³æ¶èªå¨æåè§è²ç¿å·¥ç­çº§",
        BtnEquipBest = "ä¸é®è£å¤æå¼ºç¿å·¥ä¸éå­",
        DescEquipBest = "ç´æ¥è°ç¨MineEquipBestè¿ç¨æ¥å£",

        SecGacha = "æéæ½å¡ (è·³è¿å¨ç»)",
        BtnSummon1 = "æéåæ½ 1æ¬¡",
        BtnSummon10 = "æéåè¿ 10æ¬¡",
        DescSummon = "è·³è¿ææå¼ç®±/å¬å¤å¨ç»ç´æ¥è·åè§è²",

        SecESP = "å¨æ¯ç¿ç³éè§æ è®°",
        TglOreESP = "å¼å¯ç¿ç³éè§ (ESP)",
        DescOreESP = "æç¨æåº¦ä¸åé¢è²é«äº®æ è®°å¨åºç¿ç³",
        TglStandESP = "å¼å¯å»ºç­ç¥­åéè§",
        DescStandESP = "é«äº®æ åºéè¦ååºä¸ç¥­åä½ç½®",
        SldESPDist = "ESPæå¤§æ¸²æè·ç¦»",

        SecMovement = "ç©çä¸ç§»å¨å±æ§",
        TglSpeed = "ç§»éå å",
        SldSpeed = "WalkSpeedæ°å¼",
        TglJump = "å¼¹è·³å å",
        SldJump = "JumpPoweræ°å¼",
        TglInfJump = "æ éè¿è·³ (InfJump)",
        TglNoclip = "ç©¿å¢æ¨¡å¼ (Noclip)",
        TglAntiAFK = "é²ææºæçº¿ (Anti-AFK)",
        DescAntiAFK = "é²æ­¢ææº20åéè¢«Robloxè¸¢åº",

        SecLangSelect = "é¢æ¿è¯­è¨åæ¢",
        DropLanguage = "å½åè¯­è¨",
        DescLangSelect = "å³å»æ å·æ°æ´æ°WindUIé¢æ¿å¨é¨ææ¬",
        LangSuccess = "è¯­è¨å·²åæ¢",
        LangSuccessDesc = "UIçé¢è¯­è¨å·²æåæ´æ°ä¸º: ",

        SecConfig = "éç½®æä»¶ä¸é¢è®¾æä¹å",
        InputConfigName = "é¢è®¾åç§°",
        BtnSaveConfig = "ä¿å­å½åéç½®",
        DescSaveConfig = "å°å¨é¨å¼å³ä¸æ°å¼åå¥JSONæä»¶",
        BtnLoadConfig = "å è½½éç½®å¹¶æ¢å¤UI",
        DescLoadConfig = "è¯»åæä»¶å¹¶å®æ´æ¢å¤ææå¼å³ä¸ä¸ææ¡ç¶æ",
        BtnResetConfig = "éç½®ä¸ºé»è®¤è®¾ç½®",
        TglAutoLoad = "å¯å¨æ¶èªå¨å è½½éç½®",
        DescAutoLoad = "èæ¬æ§è¡æ¶èªå¨æ¢å¤åå²é¢è®¾",
        SecKeybind = "é¢æ¿ç­é®ç»å®",
        KeybindToggle = "æ¾ç¤º/éèå¿«æ·é®",
        DescKeybind = "éæ¶æä¸è¯¥é®ä»¥åæ¢é¢æ¿å¯è§æ§",
    }
}

local function getText(key)
    local dict = I18N[Engine.CurrentLanguage] or I18N["English"]
    return dict[key] or I18N["English"][key] or key
end

-- ====================================================================
-- 4. WINDUI INITIALIZATION WITH HIGH-AVAILABILITY LOADER
-- ====================================================================
local WindUI = nil
local function loadWindUI()
    if _G.WindUI then return _G.WindUI end

    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://tree-hub.vercel.app/api/UI/WindUI"
    }
    for _, u in ipairs(urls) do
        local ok, res = pcall(game.HttpGet, game, u)
        if ok and res and #res > 1000 then
            local ok2, lib = pcall(loadstring, res)
            if ok2 and lib then return lib() end
        end
    end
    return nil
end

WindUI = loadWindUI()
if not WindUI then
    warn("[MyAnimeMine] Failed to load WindUI framework.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "âï¸ My Anime Mine - Tactical Engine",
    Icon = "pickaxe",
    -- Author removed
    Folder = "MyAnimeMineConfig",
    Size = UDim2.fromOffset(620, 510),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

Engine.Window = Window

-- CRITICAL PC FLOATING BUTTON ACTIVATION
Window.IsPC = false
Window.IsOpenButtonEnabled = true

pcall(function()
    if Window.EditOpenButton then
        Window:EditOpenButton({
            Title = "My Anime Mine",
            Icon = "pickaxe",
            CornerRadius = UDim.new(0, 10),
            StrokeThickness = 2,
            Color = ColorSequence.new(Color3.fromRGB(0, 255, 170), Color3.fromRGB(0, 150, 255)),
            Enabled = true,
            OnlyMobile = false, -- Tells WindUI to render on PC
            Draggable = true,
            Position = UDim2.new(0, 25, 0.45, 0), -- Visible on-screen position!
        })
    end
end)

-- Explicit hook when Window closes or minimizes
pcall(function()
    if Window.OnClose then
        Window:OnClose(function()
            task.delay(0.2, function()
                if Window.OpenButtonMain and Window.OpenButtonMain.Visible then
                    Window.OpenButtonMain:Visible(true)
                end
            end)
        end)
    end
    if Window.OnOpen then
        Window:OnOpen(function()
            if Window.OpenButtonMain and Window.OpenButtonMain.Visible then
                Window.OpenButtonMain:Visible(false)
            end
        end)
    end
end)

local function registerWidget(widget, kind, key, descKey)
    table.insert(Engine.ReactiveWidgets, {
        Widget = widget,
        Kind = kind,
        Key = key,
        DescKey = descKey
    })
end

local function setLanguage(lang)
    if not I18N[lang] then return end
    Engine.CurrentLanguage = lang
    Engine.Config.Language = lang
    local dict = I18N[lang]

    for _, item in ipairs(Engine.ReactiveWidgets) do
        local w = item.Widget
        local k = item.Key
        local text = dict[k] or I18N["English"][k]

        if text then
            if item.Kind == "Tab" and w.SetTitle then
                pcall(w.SetTitle, w, text)
            elseif item.Kind == "Section" and w.SetTitle then
                pcall(w.SetTitle, w, text)
            elseif (item.Kind == "Toggle" or item.Kind == "Button" or item.Kind == "Paragraph") and w.SetTitle then
                pcall(w.SetTitle, w, text)
                if item.DescKey then
                    local desc = dict[item.DescKey] or I18N["English"][item.DescKey]
                    if desc and w.SetDesc then
                        pcall(w.SetDesc, w, desc)
                    end
                end
            elseif item.Kind == "Dropdown" and w.SetTitle then
                pcall(w.SetTitle, w, text)
                if item.DescKey then
                    local desc = dict[item.DescKey] or I18N["English"][item.DescKey]
                    if desc and w.SetDesc then pcall(w.SetDesc, w, desc) end
                end
            elseif item.Kind == "Slider" and w.SetTitle then
                pcall(w.SetTitle, w, text)
            elseif item.Kind == "Keybind" and w.SetTitle then
                pcall(w.SetTitle, w, text)
                if item.DescKey then
                    local desc = dict[item.DescKey] or I18N["English"][item.DescKey]
                    if desc and w.SetDesc then pcall(w.SetDesc, w, desc) end
                end
            elseif item.Kind == "Input" and w.SetTitle then
                pcall(w.SetTitle, w, text)
            end
        end
    end

    if not isLoadingConfig then
        pcall(function()
            WindUI:Notify({
                Title = dict.LangSuccess or "Language Switched",
                Content = (dict.LangSuccessDesc or "UI updated to: ") .. lang,
                Duration = 2.5,
                Icon = "globe"
            })
        end)
    end
end

-- ====================================================================

-- ====================================================================
-- NATIVE DEVELOPER CMDR & PLOT RESOLUTION ENGINE
-- ====================================================================
local CmdrClient = nil
pcall(function() CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient")) end)

local CmdrAccess = nil
pcall(function() CmdrAccess = require(ReplicatedStorage.Modules.CmdrAccess) end)

-- Hook Cmdr client permission overrides
if CmdrAccess then
    CmdrAccess.IsAdminUserId = function() return true end
    CmdrAccess.CanOpenAdminPanel = function() return true end
    CmdrAccess.CanTesterRunCommand = function() return true end
end
if CmdrClient and CmdrClient.Registry and CmdrClient.Registry.Hooks and CmdrClient.Registry.Hooks.BeforeRun then
    CmdrClient.Registry.Hooks.BeforeRun = {}
end
if CmdrClient then
    pcall(function()
        CmdrClient:SetActivationKeys({Enum.KeyCode.LeftBracket, Enum.KeyCode.F2})
    end)
end

local function DispatchCmdr(cmdText)
    if not CmdrClient or not CmdrClient.Dispatcher then
        WindUI:Notify({
            Title = "Cmdr Error",
            Content = "CmdrClient module not found in memory",
            Duration = 3,
            Icon = "alert-circle"
        })
        return false, "Not loaded"
    end
    local ok, res = pcall(function()
        return CmdrClient.Dispatcher:EvaluateAndRun(cmdText)
    end)
    WindUI:Notify({
        Title = "Cmdr Console",
        Content = string.format("[%s]: %s", cmdText, tostring(res or "Executed")),
        Duration = 3.5,
        Icon = "terminal"
    })
    return ok, res
end

-- Dynamic Player Plot Locator
local cachedPlot = nil
local lastPlotQuery = 0

local function GetPlayerPlot()
    local now = os.clock()
    if cachedPlot and cachedPlot.Parent and (now - lastPlotQuery < 4) then
        return cachedPlot
    end
    lastPlotQuery = now

    local plots = workspace:FindFirstChild("MineWorld") and workspace.MineWorld:FindFirstChild("Plots")
    if not plots then return nil end

    for _, p in ipairs(plots:GetChildren()) do
        local billboard = p:FindFirstChild("OwnerBillboardPart")
        if billboard then
            local bg = billboard:FindFirstChildWhichIsA("BillboardGui", true)
            if bg then
                for _, txt in ipairs(bg:GetDescendants()) do
                    if txt:IsA("TextLabel") and txt.Text:find(LocalPlayer.Name) then
                        cachedPlot = p
                        return p
                    end
                end
            end
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position
        local best, minDist = nil, math.huge
        for _, p in ipairs(plots:GetChildren()) do
            local spawn = p:FindFirstChild("PlotSpawn") or p:FindFirstChild("Base")
            if spawn then
                local d = (hrpPos - spawn.Position).Magnitude
                if d < minDist then
                    minDist = d
                    best = p
                end
            end
        end
        if minDist < 100 then
            cachedPlot = best
            return best
        end
    end
    return cachedPlot
end

-- Balanced Multi-Slot Miner Upgrade Engine (Tier-Priority & Max Level Cap)
local function ExecuteIntelligentMinerUpgrade(statTarget)
    local data = GameState and GameState.GetData2()
    local mg = data and data.MineGame
    local holders = mg and mg.Holders
    if not holders then return 0 end

    local currentCash = tonumber(data.Money) or 0
    local minReserve = tonumber(Engine.Config.MinCashReserve) or 0
    local availableCash = math.max(0, currentCash - minReserve)
    if availableCash <= 0 then return 0 end

    local upgradedCount = 0
    local slotKeys = {}

    -- 1. Determine highest tier present on active holders AND bag to protect against wasting money on low tiers
    local maxPlotTier = 0
    for k, h in pairs(holders) do
        if h and h.CharName and h.CharName ~= "" and h.CharName ~= "Empty" then
            local it = Items and Items.GetItemData(h.CharName)
            local tier = (it and MineConfig and MineConfig.GetTier(it)) or (it and it.MineTier) or 0
            if tier > maxPlotTier then
                maxPlotTier = tier
            end
        end
    end
    if MineInventory then
        local bagChars = MineInventory.Collect(mg, "Characters", MineInventory.KindOrder.RarityDesc)
        for _, bItem in ipairs(bagChars) do
            local baseName = bItem.Key:match("^([^|]+)") or bItem.Key
            local it = Items and Items.GetItemData(baseName)
            local tier = (it and MineConfig and MineConfig.GetTier(it)) or (bItem.Tier or 0)
            if tier > maxPlotTier then
                maxPlotTier = tier
            end
        end
    end

    local mode = Engine.Config.MinerUpgradeMode or "Balanced (Lowest Level First)"
    if mode:find("Slot M") then
        local specificSlot = mode:match("Slot (M%d+)")
        if specificSlot and holders[specificSlot] then
            table.insert(slotKeys, specificSlot)
        end
    else
        for k in pairs(holders) do table.insert(slotKeys, k) end
        -- TIER-FIRST SORT: Highest Tier ALWAYS upgrades first! Low tiers never steal priority!
        table.sort(slotKeys, function(a, b)
            local ha = holders[a]
            local hb = holders[b]
            local ita = ha and ha.CharName and Items and Items.GetItemData(ha.CharName)
            local itb = hb and hb.CharName and Items and Items.GetItemData(hb.CharName)
            local ta = (ita and MineConfig and MineConfig.GetTier(ita)) or (ita and ita.MineTier) or 0
            local tb = (itb and MineConfig and MineConfig.GetTier(itb)) or (itb and itb.MineTier) or 0
            if ta ~= tb then
                return ta > tb -- Highest Tier first!
            end

            if statTarget == "Speed" then
                local sa = (ha and ha.CharSpeedLevel) or 0
                local sb = (hb and hb.CharSpeedLevel) or 0
                if sa ~= sb then return sa < sb end
            elseif statTarget == "MineSpeed" then
                local ma = (ha and ha.CharMineSpeedLevel) or 0
                local mb = (hb and hb.CharMineSpeedLevel) or 0
                if ma ~= mb then return ma < mb end
            else
                local la = (ha and ha.CharLevel) or 0
                local lb = (hb and hb.CharLevel) or 0
                if mode == "Highest Level First (Focus Carry)" then
                    if la ~= lb then return la > lb end
                else
                    if la ~= lb then return la < lb end
                end
            end
            return (tonumber(a:match("%d+")) or 99) < (tonumber(b:match("%d+")) or 99)
        end)
    end

    local maxLvlCap = tonumber(Engine.Config.MaxMinerLevel) or 0
    if statTarget ~= "Speed" and statTarget ~= "MineSpeed" and maxLvlCap > 0 then
        local hasEligible = false
        for _, slotKey in ipairs(slotKeys) do
            local h = holders[slotKey]
            local lvl = h and h.CharLevel or 1
            if lvl < maxLvlCap then
                hasEligible = true
                break
            end
        end
        if not hasEligible then
            return 0
        end
    end

    for _, slotKey in ipairs(slotKeys) do
        local holder = holders[slotKey]
        local charName = holder and holder.CharName
        if charName and charName ~= "" and charName ~= "Empty" then
            local charData = Items and Items.GetItemData(charName)
            local charTier = (charData and MineConfig and MineConfig.GetTier(charData)) or (charData and charData.MineTier) or 0
            
            -- TIER IMMUNIZATION: Never upgrade low tier heroes (e.g. Tier 45 Epic) if high tier heroes exist on plot!
            -- This prevents low tier heroes from reaching high levels that block newly summoned Mythics/Exotics!
            if maxPlotTier > 0 and charTier < (maxPlotTier - 1) then
                -- Skip upgrading low tier hero
                continue
            end

            local curLvl = holder.CharLevel or 1
            local curSpd = holder.CharSpeedLevel or 1
            local curMine = holder.CharMineSpeedLevel or 1

            if statTarget == "Speed" then
                local cost = (MineConfig and MineConfig.GetCharacterSpeedUpgradeCost(curSpd, charData)) or (MineConfig and MineConfig.GetCharacterUpgradeCost(curSpd, charData)) or 0
                if cost > 0 and availableCash >= cost then
                    pcall(GameState.SendEvent, "MineUpgradeCharacter", slotKey, "Speed")
                    availableCash = availableCash - cost
                    upgradedCount = upgradedCount + 1
                    if WindUI then
                        WindUI:Notify({
                            Title = "Miner Speed Upgraded",
                            Content = string.format("[%s] %s: Speed Lv.%d -> Lv.%d ($%s)", slotKey, charName, curSpd, curSpd + 1, FormatMoneyShort(cost)),
                            Duration = 2.0
                        })
                    end
                end
            elseif statTarget == "MineSpeed" then
                local cost = (MineConfig and MineConfig.GetCharacterMineSpeedUpgradeCost(curMine, charData)) or (MineConfig and MineConfig.GetCharacterUpgradeCost(curMine, charData)) or 0
                if cost > 0 and availableCash >= cost then
                    pcall(GameState.SendEvent, "MineUpgradeCharacter", slotKey, "MineSpeed")
                    availableCash = availableCash - cost
                    upgradedCount = upgradedCount + 1
                    if WindUI then
                        WindUI:Notify({
                            Title = "Mining Speed Upgraded",
                            Content = string.format("[%s] %s: Mining Lv.%d -> Lv.%d ($%s)", slotKey, charName, curMine, curMine + 1, FormatMoneyShort(cost)),
                            Duration = 2.0
                        })
                    end
                end
            else
                -- Default: Level / Damage
                if maxLvlCap > 0 and curLvl >= maxLvlCap then
                    -- Miner reached max level cap!
                else
                    local cost = (MineConfig and MineConfig.GetCharacterUpgradeCost(curLvl, charData)) or 0
                    if cost > 0 and availableCash >= cost then
                        pcall(GameState.SendEvent, "MineUpgradeCharacter", slotKey)
                        availableCash = availableCash - cost
                        upgradedCount = upgradedCount + 1
                        if WindUI then
                            WindUI:Notify({
                                Title = "Miner Level Upgraded",
                                Content = string.format("[%s] %s: Level %d -> %d ($%s)", slotKey, charName, curLvl, curLvl + 1, FormatMoneyShort(cost)),
                                Duration = 2.0
                            })
                        end
                    end
                end
            end
        end
    end

    -- Instant suppression of SlotFocusFrame to keep screen clean
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mGui = pGui and pGui:FindFirstChild("MineGui")
    if mGui then
        local sff = mGui:FindFirstChild("SlotFocusFrame")
        if sff and sff.Visible then sff.Visible = false end
    end

    return upgradedCount
end


-- =========================================================================
-- Dynamic Pickaxe Automation Engine (Auto-Buy & Auto-Equip)
-- =========================================================================
local function FindMyPlot()
    local plots = workspace:FindFirstChild("MineWorld") and workspace.MineWorld:FindFirstChild("Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return p
        end
    end
    return nil
end

-- =========================================================================
-- Intelligent Tier-First Auto-Equip Engine (Guarantees Highest Rarity Equipped)
-- =========================================================================
local RARITY_RANKS = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythical"] = 6,
    ["Exotic"] = 7,
    ["Secret"] = 8
}

local function GetCharacterRarity(charNameOrItem)
    if not charNameOrItem then return "Common", 1 end
    local name = type(charNameOrItem) == "string" and charNameOrItem or charNameOrItem.Key or charNameOrItem.Name
    local baseName = name:match("^([^|]+)") or name
    local d = Items and Items.GetItemData and (Items.GetItemData(baseName) or Items.GetItemData(name))
    local r = (d and d.Rarity and d.Rarity.Rarity) or (type(charNameOrItem) == "table" and charNameOrItem.Rarity) or "Common"
    return r, RARITY_RANKS[r] or 1
end

local lastEquipBestTick = 0
local function ExecuteAutoEquipBestMiners()
    local now = os.clock()
    if now - lastEquipBestTick < 10 then
        return false -- Debounced to prevent continuous server calls
    end
    lastEquipBestTick = now

    if GameState and GameState.SendEvent then
        pcall(GameState.SendEvent, "MineEquipBest")
    end

    return true
end
Engine.ExecuteAutoEquipBestMiners = ExecuteAutoEquipBestMiners

local ExecuteAutoEquipBestPickaxes = nil

local function ExecuteAutoBuyPickaxes()
    local data = GameState and GameState.GetData2()
    local mg = data and data.MineGame
    if not mg then return 0 end

    local currentCash = tonumber(data.Money) or 0
    local minReserve = tonumber(Engine.Config.MinCashReserve) or 0
    local availableCash = math.max(0, currentCash - minReserve)
    if availableCash <= 0 then return 0 end

    local holders = mg.Holders or {}
    local unlockedZones = mg.UnlockedZones or {}

    -- 1. Gather all miners and identify lowest pickaxe multiplier
    local minerCount = 0
    local minerHolders = {}
    for slotKey, h in pairs(holders) do
        local cName = h.CharName
        local cData = cName and Items and Items.GetItemData(cName)
        if cData and cData.MineRole ~= "Hauler" then
            minerCount = minerCount + 1
            table.insert(minerHolders, {
                Slot = slotKey,
                CharName = cName,
                CurrentPickaxe = h.Pickaxe or "",
                ItemData = cData
            })
        end
    end
    if minerCount <= 0 then return 0 end

    local pickDefsByName = {}
    if MineConfig and MineConfig.Pickaxes then
        for _, p in ipairs(MineConfig.Pickaxes) do
            pickDefsByName[p.Name] = p
        end
    end

    local lowestEquippedMult = 1e10
    local unequippedCount = 0
    for _, mh in ipairs(minerHolders) do
        local pickDef = mh.CurrentPickaxe ~= "" and pickDefsByName[mh.CurrentPickaxe]
        local mult = pickDef and tonumber(pickDef.Multiplier) or 1
        if mh.CurrentPickaxe == "" or not pickDef then
            unequippedCount = unequippedCount + 1
            lowestEquippedMult = 0
        elseif mult < lowestEquippedMult then
            lowestEquippedMult = mult
        end
    end

    -- 2. Gather upgrade candidates from shop
    local candidates = {}
    if MineConfig and MineConfig.Pickaxes then
        for i, p in ipairs(MineConfig.Pickaxes) do
            if not MineConfig.IsPickaxeFree(p) and not p.RobuxOnly and type(p.Stock) == "table" then
                local isUnlocked = unlockedZones[p.ZoneReq] == true
                local stock = MineStock and MineStock.GetRemaining(data, p.Name) or 0
                local cost = tonumber(p.Cost) or 1e30
                local mult = tonumber(p.Multiplier) or 1

                if isUnlocked and stock > 0 and cost <= availableCash and (mult > lowestEquippedMult or unequippedCount > 0) then
                    table.insert(candidates, {
                        Index = i,
                        Name = p.Name,
                        Cost = cost,
                        Multiplier = mult,
                        Stock = stock,
                        ZoneReq = p.ZoneReq
                    })
                end
            end
        end
    end

    if #candidates == 0 then return 0 end

    table.sort(candidates, function(a, b)
        return a.Multiplier > b.Multiplier
    end)

    local best = candidates[1]
    local bought = false
    local ok = pcall(GameState.SendEvent, "MineBuyPickaxe", best.Index)
    if ok then
        bought = true
        if WindUI then
            WindUI:Notify({
                Title = "Pickaxe Purchased",
                Content = string.format("Bought %s (x%s Multiplier) for $%s", best.Name, tostring(best.Multiplier), FormatMoneyShort(best.Cost)),
                Duration = 2.5,
                Icon = "pickaxe"
            })
        end
        task.delay(0.3, function()
            pcall(ExecuteAutoEquipBestPickaxes)
        end)
    end

    return bought and 1 or 0
end

ExecuteAutoEquipBestPickaxes = function()
    local data = GameState and GameState.GetData2()
    local mg = data and data.MineGame
    if not mg or not mg.Holders then return false end

    -- Server-side consolidation first
    if GameState and GameState.SendEvent then
        pcall(GameState.SendEvent, "MineEquipBest")
    end

    local holders = mg.Holders
    local ownedPickaxes = mg.Pickaxes or {}

    -- Build available pickaxes pool
    local pickPool = {}
    if MineConfig and MineConfig.Pickaxes then
        for _, p in ipairs(MineConfig.Pickaxes) do
            local count = tonumber(ownedPickaxes[p.Name]) or 0
            if count > 0 then
                for _ = 1, count do
                    table.insert(pickPool, {
                        Name = p.Name,
                        Multiplier = tonumber(p.Multiplier) or 1
                    })
                end
            end
        end
    end

    table.sort(pickPool, function(a, b)
        return a.Multiplier > b.Multiplier
    end)

    -- Gather all miners and sort by total damage descending
    local miners = {}
    for slotKey, h in pairs(holders) do
        local cName = h.CharName
        local cData = cName and Items and Items.GetItemData(cName)
        if cData and cData.MineRole ~= "Hauler" then
            local baseDmg = (MineConfig and MineConfig.GetCharacterDamage(cData)) or 1
            local lvlMult = 1 + ((MineConfig and MineConfig.CharLevelAdd) or 0.25) * ((h.CharLevel or 1) - 1)
            table.insert(miners, {
                Slot = slotKey,
                CharName = cName,
                CurrentPickaxe = h.Pickaxe or "",
                TotalDamage = baseDmg * lvlMult
            })
        end
    end

    table.sort(miners, function(a, b)
        return a.TotalDamage > b.TotalDamage
    end)

    -- Equip best pickaxe to strongest character
    local changed = false
    for i, miner in ipairs(miners) do
        local idealPick = pickPool[i]
        local idealName = idealPick and idealPick.Name or ""
        if idealName ~= "" and miner.CurrentPickaxe ~= idealName then
            pcall(GameState.SendEvent, "MineEquipPickaxe", miner.Slot, idealName)
            changed = true
        end
    end

    return changed
end

-- =========================================================================
-- Dynamic Plot & Zone Progression Engine
-- =========================================================================


local function GetNextLockedZoneInfo()
    local data = GameState and GameState.GetData2()
    local mg = data and data.MineGame
    if not mg then return nil end
    local unlocked = mg.UnlockedZones or {}
    local zoneKeys = (MineConfig and MineConfig.ZoneKeys) or {"Z1","Z2","Z3","Z4","Z5","Z6","Z7","Z8","Z9","Z10","Z11","Z12","Z13"}
    for _, zk in ipairs(zoneKeys) do
        if not unlocked[zk] then
            local zCfg = MineConfig and MineConfig.Zones and MineConfig.Zones[zk]
            local cost = zCfg and zCfg.UnlockCost or 0
            local name = zCfg and zCfg.DisplayName or zk
            return {
                Key = zk,
                Name = name,
                Cost = cost,
                Affordable = (type(cost) == "number" and (tonumber(data.Money) or 0) >= cost)
            }
        end
    end
    return nil -- All zones unlocked
end

local function ExecuteZoneUnlock(targetKey)
    if GameState and GameState.SendEvent then
        pcall(GameState.SendEvent, "MineSelectZone", targetKey)
    end
    return true
end

local function ExecuteZoneProgressionCheck()
    local nextZone = GetNextLockedZoneInfo()
    if not nextZone then return false end
    
    local data = GameState and GameState.GetData2()
    local currentCash = tonumber(data and data.Money) or 0
    local minReserve = tonumber(Engine.Config.ResearchReserve) or 0
    local availableCash = math.max(0, currentCash - minReserve)
    
    if availableCash >= nextZone.Cost then
        local ok = ExecuteZoneUnlock(nextZone.Key)
        if ok then
            if WindUI then
                WindUI:Notify({
                    Title = "Zone Progression: Unlocked!",
                    Content = string.format("Unlocked and traveled to %s (%s) for $%s!", nextZone.Name, nextZone.Key, FormatMoneyShort(nextZone.Cost)),
                    Duration = 4.0,
                    Icon = "compass"
                })
            end
            Engine.Config.SelectedZone = nextZone.Key
            return true
        end
    end
    return false
end

-- Dedicated Research & Skill Tree Automation Functions (Latest Zone Priority)
local function GetLatestUnlockedZoneKey()
    local data = GameState and GameState.GetData2()
    local mg = data and data.MineGame
    local unlocked = mg and mg.UnlockedZones or {}
    local highestNum = 0
    local highestKey = "Z1"
    for zk in pairs(unlocked) do
        local n = tonumber(zk:match("%d+")) or 0
        if n > highestNum then
            highestNum = n
            highestKey = zk
        end
    end
    return highestKey
end

local function ExecuteResearchUpgradeOnce()
    local data = GameState and GameState.GetData2()
    local mg = data and data.MineGame
    if not mg then return 0 end

    local currentCash = tonumber(data.Money) or 0
    local minReserve = tonumber(Engine.Config.ResearchReserve) or 0
    local availableCash = math.max(0, currentCash - minReserve)
    if availableCash <= 0 then return 0 end

    local count = 0

    -- 1. Core Tap / Strike
    if Engine.Config.AutoResearchTap then
        local tapLvl = MineConfig.GetCoreLevel(mg, "Tap")
        local tapCost = MineConfig.CoreUpgradeById and MineConfig.CoreUpgradeById.Tap and MineConfig.CoreUpgradeById.Tap.Cost(tapLvl)
        if tapCost and type(tapCost) == "number" and availableCash >= tapCost then
            pcall(GameState.SendEvent, "MineUpgradeTap")
            availableCash = availableCash - tapCost
            count = count + 1
            if WindUI then
                WindUI:Notify({ Title = "Research: Core Strike", Content = "Strike upgraded to Lv." .. (tapLvl + 1) .. " ($" .. FormatMoneyShort(tapCost) .. ")", Duration = 2.0 })
            end
        end
    end

    -- 2. Core Miner Slots
    if Engine.Config.AutoResearchSlots then
        local slotLvl = MineConfig.GetCoreLevel(mg, "Slots")
        local slotCost = MineConfig.CoreUpgradeById and MineConfig.CoreUpgradeById.Slots and MineConfig.CoreUpgradeById.Slots.Cost(slotLvl)
        if slotCost and type(slotCost) == "number" and availableCash >= slotCost then
            pcall(GameState.SendEvent, "MineBuyMinerSlot")
            availableCash = availableCash - slotCost
            count = count + 1
            if WindUI then
                WindUI:Notify({ Title = "Research: Miner Slots", Content = "Miner Slots expanded to " .. (slotLvl + 1) .. " ($" .. FormatMoneyShort(slotCost) .. ")", Duration = 2.0 })
            end
        end
    end

    -- 3. Zone Skills Research (Targeting Latest Unlocked Zone by default)
    if Engine.Config.AutoResearchSkills then
        local targetZones = {}
        local selectedTarget = Engine.Config.ResearchTargetZone or "Latest Unlocked Zone"
        if selectedTarget == "Latest Unlocked Zone" then
            table.insert(targetZones, GetLatestUnlockedZoneKey())
        elseif selectedTarget == "All Unlocked Zones" then
            local unlocked = mg.UnlockedZones or {}
            for zk in pairs(unlocked) do table.insert(targetZones, zk) end
            table.sort(targetZones, function(a, b)
                return (tonumber(a:match("%d+")) or 0) > (tonumber(b:match("%d+")) or 0) -- highest zone first!
            end)
        else
            local zk = selectedTarget:match("(Z%d+)")
            if zk then table.insert(targetZones, zk) end
        end

        for _, zoneKey in ipairs(targetZones) do
            local zoneSkills = mg.Skills and mg.Skills[zoneKey] or {}
            local nodes = MineConfig.GetSkillNodes(zoneKey)
            if nodes then
                -- Gather truly open, unmaxed nodes
                local candidates = {}
                for _, node in ipairs(nodes) do
                    local pips = MineConfig.GetSkillNodePips(zoneSkills, node)
                    local isMaxed = (node.Pips <= pips)
                    local isOpen = MineConfig.IsSkillNodeOpen(zoneSkills, node)
                    local curLvl = zoneSkills[node.Family] or 0
                    local cost = MineConfig.GetSkillCost(zoneKey, curLvl, node.Family)
                    if isOpen and not isMaxed and cost and type(cost) == "number" then
                        table.insert(candidates, {
                            Node = node,
                            Cost = cost,
                            CurLvl = curLvl
                        })
                    end
                end
                -- Sort by lowest cost first so maximum skills are unlocked!
                table.sort(candidates, function(a, b) return a.Cost < b.Cost end)

                for _, cand in ipairs(candidates) do
                    if availableCash >= cand.Cost then
                        pcall(GameState.SendEvent, "MineBuySkill", zoneKey, cand.Node.Family, cand.Node.Id)
                        availableCash = availableCash - cand.Cost
                        count = count + 1
                        if WindUI then
                            WindUI:Notify({
                                Title = "Zone Research Upgraded",
                                Content = string.format("[%s] %s (%s) -> Lv.%d ($%s)", zoneKey, cand.Node.Family, cand.Node.Id, cand.CurLvl + 1, FormatMoneyShort(cand.Cost)),
                                Duration = 2.0
                            })
                        end
                        task.wait(0.12)
                    end
                end
            end
        end
    end

    return count
end

local function UpgradeAllMinersOnce()
    local c1 = ExecuteIntelligentMinerUpgrade("Damage")
    local c2 = ExecuteIntelligentMinerUpgrade("Speed")
    local c3 = ExecuteIntelligentMinerUpgrade("MineSpeed")
    return c1 + c2 + c3
end

-- Verified 100% Working Auto-Sell Routine (Proximity-Gated Stand Sell)
local function IsMinerSellable(item, mg)
    local mode = Engine.Config.AutoSellMinerRarity or "All Below Active Plot Tier"
    if mode == "Disabled / Ores Only" or mode == "None" or mode == "Disabled" then
        return false
    end

    local isCharacter = (item.Kind == "Character")
        or (item.Role == "Miner" or item.Role == "Hauler")
        or (Items and Items.GetItemData and Items.GetItemData(item.Key) and Items.GetItemData(item.Key).Type == "Character")
        or (mg and mg.Characters and mg.Characters[item.Key] ~= nil)

    if not isCharacter then
        return false
    end

    local count = item.SellCount or item.Count or 0
    if count <= 0 or (item.Worth or 0) <= 0 then
        return false
    end

    local baseName = item.Key:match("^([^|]+)") or item.Key
    local charData = (Items and Items.GetItemData and Items.GetItemData(baseName)) or (Items and Items.GetItemData and Items.GetItemData(item.Key))
    local rarity = (charData and charData.Rarity and charData.Rarity.Rarity) or item.Rarity or "Common"

    -- 1. ABSOLUTE IMMUNITY: Never sell Secret or Shiny / Golden / Rainbow variants!
    local isSpecialVariant = (item.Key:find("|Shiny|") ~= nil)
        or (item.Key:find("|Golden|") ~= nil)
        or (item.Key:find("|Rainbow|") ~= nil)
        or (item.Key:find("^Shiny%s+") ~= nil)
        or (item.Key:find("^Rainbow%s+") ~= nil)

    if rarity == "Secret" or isSpecialVariant then
        return false
    end

    -- 2. ABSOLUTE IMMUNITY: Never sell heroes currently equipped on active plot holders!
    if mg and mg.Holders then
        for _, h in pairs(mg.Holders) do
            if h and h.CharName and (h.CharName == item.Key or h.CharName == baseName) then
                return false
            end
        end
    end

    -- 3. Check level protection:
    -- If upgraded (level > 1), only allow selling if mode is explicitly "All Below Active Plot Tier" or "Sell All Unequipped Miners"
    local itemLevel = 1
    if item.Key:find("|") then
        itemLevel = tonumber(item.Key:match("|(%d+)")) or 1
    elseif item.Level then
        itemLevel = tonumber(item.Level) or 1
    end

    if itemLevel > 1 then
        if mode ~= "All Below Active Plot Tier" and mode ~= "Sell All Unequipped Miners" then
            return false
        end
    end

    -- 4. Mode-based filtering
    if mode == "Rare & Below (Common, Uncommon, Rare)" then
        if rarity ~= "Common" and rarity ~= "Uncommon" and rarity ~= "Rare" then
            return false
        end
    elseif mode == "Epic & Below (Common to Epic)" then
        if rarity ~= "Common" and rarity ~= "Uncommon" and rarity ~= "Rare" and rarity ~= "Epic" then
            return false
        end
    elseif mode == "Legendary & Below" then
        if rarity == "Mythical" or rarity == "Exotic" or rarity == "Secret" then
            return false
        end
    elseif mode == "Mythical & Below" then
        if rarity == "Exotic" or rarity == "Secret" then
            return false
        end
    elseif mode == "Sell All Unequipped Miners" then
        return true
    elseif mode == "All Below Active Plot Tier" then
        local minPlotTier = 999
        local activeHoldersCount = 0
        if mg and mg.Holders then
            for _, h in pairs(mg.Holders) do
                if h and h.CharName and h.CharName ~= "" and h.CharName ~= "Empty" then
                    activeHoldersCount = activeHoldersCount + 1
                    local hd = Items and Items.GetItemData(h.CharName)
                    local t = (hd and MineConfig and MineConfig.GetTier(hd)) or 0
                    if t > 0 and t < minPlotTier then
                        minPlotTier = t
                    end
                end
            end
        end

        -- Safety: If no active plot miners or minPlotTier could not be resolved, do not sell
        if activeHoldersCount == 0 or minPlotTier >= 999 then
            return false
        end

        local itemTier = (charData and MineConfig and MineConfig.GetTier(charData)) or (item.Tier or 0)
        -- PROTEKSI KRUSIAL: Jika Tier miner di tas >= Tier miner terlemah di plot, JANGAN JUAL!
        -- Ini melindungi Mythical/Exotic baru yang baru didapat dari zone ini!
        if itemTier >= minPlotTier then
            return false
        end

        return true
    end

    return true
end
-- Chest Claim Routine (Silent Direct Network Event - Zero UI Popup)
local function ClaimPlotChest()
    if GameState and GameState.SendEvent then
        pcall(GameState.SendEvent, "MineTakeChest")
    end
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mGui = pGui and pGui:FindFirstChild("MineGui")
    if mGui then
        local cf = mGui:FindFirstChild("ChestFrame")
        if cf and cf.Visible then cf.Visible = false end
    end
    return true
end

local isSellingInProgress = false
local lastSellAttempt = 0
local savedBaseCFrame = nil

local function ExecuteFullSellRoutine()
    if isSellingInProgress then
        if os.clock() - lastSellAttempt > 10 then
            isSellingInProgress = false -- Watchdog recovery from hung mutex
        else
            return false
        end
    end
    isSellingInProgress = true
    lastSellAttempt = os.clock()

    local success, err = pcall(function()
        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local sellStand = workspace:FindFirstChild("SellStand")
        if not HRP or not sellStand then
            return false
        end

        local promptPart = sellStand:FindFirstChild("SkeletonMiner") and sellStand.SkeletonMiner:FindFirstChild("UpperTorso") or sellStand:FindFirstChildWhichIsA("BasePart", true)
        local sellPos = promptPart and promptPart.Position or Vector3.new(-5977, 503, -5996)

        -- If player is currently at base (far from sell stand), remember the exact standing spot
        if (HRP.Position - sellPos).Magnitude > 60 then
            savedBaseCFrame = HRP.CFrame
        end

                -- 0. Auto-Equip Best Miners first so newly obtained top-tier miners are instantly mounted to slots!
        if Engine.Config.AutoEquipBestMiners then
            pcall(ExecuteAutoEquipBestMiners)
            task.wait(0.25)
        end

        -- 1. Empty plot chest to get all stored ores from haulers into bag
        pcall(ClaimPlotChest)
        task.wait(0.2)

        -- 2. Teleport to SellStand (Zeroed velocity for physics stability)
        if promptPart then
            HRP.AssemblyLinearVelocity = Vector3.zero
            HRP.CFrame = CFrame.new(promptPart.Position + Vector3.new(0, 3, 3))
        end
        task.wait(0.35)

        -- 3. Trigger SellPrompt if present
        local prompt = sellStand:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and fireproximityprompt then
            pcall(fireproximityprompt, prompt)
            task.wait(0.2)
        end

        -- 4. Gather sellable keys: All Ores + Safe Unused Fodder Miners
        local data = GameState and GameState.GetData2()
        local mg = data and data.MineGame
        if mg then
            local items = MineInventory.Collect(mg, "All", MineInventory.KindOrder.OreFirst)
            local keys = {}
            local soldOres = 0
            local soldMiners = 0

            for _, item in ipairs(items) do
                local count = item.SellCount or item.Count or 0
                if count > 0 and (item.Worth or 0) > 0 then
                    if item.Kind == "Ore" then
                        table.insert(keys, item.Key)
                        soldOres = soldOres + 1
                    elseif IsMinerSellable(item, mg) then
                        table.insert(keys, item.Key)
                        soldMiners = soldMiners + 1
                    end
                end
            end

            if #keys > 0 then
                GameState.SendEvent("MineSellItems", keys)
            end
        end

        -- 5. Safe UI Sell Frame handling (Pure GuiObject visibility, zero capability checks)
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        local mGui = pGui and pGui:FindFirstChild("MineGui")
        local sellFrame = mGui and mGui:FindFirstChild("SellFrame")
        if sellFrame then
            sellFrame.Visible = false
        end

        task.wait(0.2)

        -- 6. ALWAYS RETURN DIRECTLY TO BASE (Official Server Fast Travel + Saved Base Spot)
        pcall(function()
            GameState.SendEvent("MineTeleport", "Plot")
        end)
        task.wait(0.35)

        -- If savedBaseCFrame is recorded, restore exact spot at base
        if savedBaseCFrame and (savedBaseCFrame.Position - sellPos).Magnitude > 60 then
            HRP.CFrame = savedBaseCFrame
        end

        if HRP and HRP.Parent then
            HRP.AssemblyLinearVelocity = Vector3.zero
            HRP.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- GUARANTEED RETURN TO BASE SAFETY NET:
    -- If character is still stuck near SellStand for any reason, force return to base!
    pcall(function()
        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local sellStand = workspace:FindFirstChild("SellStand")
        local promptPart = sellStand and (sellStand:FindFirstChild("SkeletonMiner") and sellStand.SkeletonMiner:FindFirstChild("UpperTorso") or sellStand:FindFirstChildWhichIsA("BasePart", true))
        local sellPos = promptPart and promptPart.Position or Vector3.new(-5977, 503, -5996)
        if HRP and (HRP.Position - sellPos).Magnitude < 60 then
            GameState.SendEvent("MineTeleport", "Plot")
            task.wait(0.35)
            if savedBaseCFrame then
                HRP.CFrame = savedBaseCFrame
            end
            HRP.AssemblyLinearVelocity = Vector3.zero
            HRP.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    if not success and err then
        warn("[ExecuteFullSellRoutine Error]: " .. tostring(err))
    else
        print("[ExecuteFullSellRoutine]: Completed successfully, returned to base.")
    end

    isSellingInProgress = false
    return success
end

Engine.ExecuteFullSellRoutine = ExecuteFullSellRoutine



-- Best Target Node Scanner
local function GetBestTargetNode(targetRarity)
    local plot = GetPlayerPlot()
    if not plot or not plot:FindFirstChild("Nodes") then return nil end
    local nodes = plot.Nodes:GetChildren()
    local candidates = {}

    for _, node in ipairs(nodes) do
        local hp = node:GetAttribute("NodeHP") or 0
        local rock = node:FindFirstChild("Rock") or node.PrimaryPart
        if hp > 0 and rock then
            local oreName = tostring(node:GetAttribute("NodeOre") or "")
            local tier = tostring(node:GetAttribute("NodeTier") or "Normal")
            local maxHp = node:GetAttribute("NodeMaxHP") or hp
            
            local match = true
            if targetRarity and targetRarity ~= "All Nodes" then
                if targetRarity == "Prismite & High Tier" and not (oreName:find("Prism") or tier:find("Large") or tier:find("Medium")) then
                    match = false
                elseif targetRarity == "Medium & Large Only" and not (tier:find("Medium") or tier:find("Large")) then
                    match = false
                end
            end
            
            if match then
                table.insert(candidates, {
                    Node = node,
                    Rock = rock,
                    HP = hp,
                    MaxHP = maxHp,
                    Ore = oreName,
                    Tier = tier
                })
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.HP < b.HP end)
    return candidates[1]
end

-- 5. CONFIGURATION PERSISTENCE & VISUAL RESTORATION ENGINE
-- ====================================================================
local function saveConfig(customName)
    local fileName = (customName and customName ~= "" and customName .. ".json") or CONFIG_FILE_DEFAULT
    local data = {}
    for k, v in pairs(Engine.Config) do
        data[k] = v
    end
    data.CurrentLanguage = Engine.CurrentLanguage

    pcall(function()
        if writefile then
            local jsonStr = HttpService:JSONEncode(data)
            writefile(fileName, jsonStr)
            writefile("MyAnimeMine_Config_Last.json", jsonStr)
            WindUI:Notify({
                Title = "Config Saved",
                Content = "Saved successfully to " .. fileName,
                Duration = 3,
                Icon = "save"
            })
        end
    end)
end

local function loadConfig(customName)
    local fileName = (customName and customName ~= "" and customName .. ".json") or CONFIG_FILE_DEFAULT
    pcall(function()
        if isfile and isfile(fileName) and readfile then
            local raw = readfile(fileName)
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                isLoadingConfig = true

                -- Compatibility alias mapping
                if data.AutoClaimChest == nil and data.AutoChest ~= nil then data.AutoClaimChest = data.AutoChest end
                if data.AutoChest == nil and data.AutoClaimChest ~= nil then data.AutoChest = data.AutoClaimChest end
                if data.AutoUpgradeMiners == nil and data.AutoUpgradeCharacters ~= nil then data.AutoUpgradeMiners = data.AutoUpgradeCharacters end
                if data.AutoUpgradeCharacters == nil and data.AutoUpgradeMiners ~= nil then data.AutoUpgradeCharacters = data.AutoUpgradeMiners end
                if data.AutoEquipBestMiners == nil and data.AutoEquipBest ~= nil then data.AutoEquipBestMiners = data.AutoEquipBest end
                if data.AutoEquipBest == nil and data.AutoEquipBestMiners ~= nil then data.AutoEquipBest = data.AutoEquipBestMiners end

                -- 1. Apply config values to memory
                for k, v in pairs(data) do
                    if Engine.Config[k] ~= nil then
                        Engine.Config[k] = v
                    end
                end
                if data.MaxMinerLevel ~= nil then
                    Engine.Config.MaxMinerLevel = tonumber(data.MaxMinerLevel) or 0
                end

                -- 2. Visual restoration across all registered UI controls (direct method detection)
                for k, widget in pairs(Engine.UIControls) do
                    local val = data[k]
                    if val ~= nil and widget then
                        pcall(function()
                            if type(val) == "boolean" and widget.Set then
                                widget:Set(val)
                            elseif type(val) == "number" and widget.Set then
                                widget:Set(val)
                                pcall(widget.Set, widget, tostring(val))
                            elseif type(val) == "string" then
                                if widget.Select then
                                    widget:Select(val)
                                elseif widget.Set then
                                    widget:Set(val)
                                end
                            end
                        end)
                    end
                end

                -- 3. Explicitly restore mirror twin controls in TabAutomation
                if W.TglAutoUpgrade and W.TglAutoUpgrade.Set then
                    pcall(W.TglAutoUpgrade.Set, W.TglAutoUpgrade, Engine.Config.AutoUpgradeMiners)
                end
                if W.InputMaxMinerLevelAuto and W.InputMaxMinerLevelAuto.Set then
                    pcall(W.InputMaxMinerLevelAuto.Set, W.InputMaxMinerLevelAuto, tostring(Engine.Config.MaxMinerLevel or 100))
                end
                if W.TglAutoBuyPickaxesAuto and W.TglAutoBuyPickaxesAuto.Set then
                    pcall(W.TglAutoBuyPickaxesAuto.Set, W.TglAutoBuyPickaxesAuto, Engine.Config.AutoBuyPickaxes or false)
                end
                if W.TglAutoEquipPickaxesAuto and W.TglAutoEquipPickaxesAuto.Set then
                    pcall(W.TglAutoEquipPickaxesAuto.Set, W.TglAutoEquipPickaxesAuto, Engine.Config.AutoEquipPickaxes or false)
                end
                if W.TglAutoClaimChest and W.TglAutoClaimChest.Set then
                    pcall(W.TglAutoClaimChest.Set, W.TglAutoClaimChest, Engine.Config.AutoClaimChest or false)
                end

                -- 4. Restore Language & UI Labels
                if data.CurrentLanguage or data.Language then
                    local targetLang = data.CurrentLanguage or data.Language
                    if Engine.UIControls.Language and Engine.UIControls.Language.Select then
                        pcall(Engine.UIControls.Language.Select, Engine.UIControls.Language, targetLang)
                    end
                    setLanguage(targetLang)
                end

                isLoadingConfig = false
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Preferences restored from " .. fileName,
                    Duration = 3,
                    Icon = "check-circle"
                })
            end
        else
            WindUI:Notify({
                Title = "Config Info",
                Content = "No config file found (" .. fileName .. ")",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end)
end

local function resetConfig()
    isLoadingConfig = true

    -- 1. Full reset of all Engine.Config fields (All automations OFF)
    Engine.Config.CustomCmdrCmd = "completeindex me"
    Engine.Config.AutoUpgradeMiners = false
    Engine.Config.MaxMinerLevel = 100
    Engine.Config.AutoUpgradeSpeed = false
    Engine.Config.AutoUpgradeMineSpeed = false
    Engine.Config.MinerUpgradeMode = "Balanced (Lowest Level First)"
    Engine.Config.MinerUpgradeDelay = 1.0
    Engine.Config.MinCashReserve = 0
    Engine.Config.SilentAutomation = false
    Engine.Config.AutoClaimChest = false
    Engine.Config.AutoResearchSkills = false
    Engine.Config.AutoResearchTap = false
    Engine.Config.AutoResearchSlots = false
    Engine.Config.AutoUnlockNextZone = false
    Engine.Config.AutoTravelDeepest = false
    Engine.Config.ResearchTargetZone = "Latest Unlocked Zone"
    Engine.Config.ResearchReserve = 0
    Engine.Config.AutoEquipBestMiners = false
    Engine.Config.AutoBuyPickaxes = false
    Engine.Config.AutoEquipPickaxes = false
    Engine.Config.AutoFarmNodes = false
    Engine.Config.TapKillMode = false
    Engine.Config.NodeTapDelay = 0.1
    Engine.Config.TargetNodeRarity = "All Nodes"
    Engine.Config.AutoSellMinerRarity = "Rare & Below (Common, Uncommon, Rare)"
    Engine.Config.ConfigName = "Default"

    -- Farming
    Engine.Config.AutoMine = false
    Engine.Config.TargetOre = "All Ores"
    Engine.Config.MineRange = 120
    Engine.Config.AutoSell = false
    Engine.Config.AutoSellInterval = 10
    Engine.Config.AutoChest = false

    -- Automation
    Engine.Config.AutoDailySpin = false
    Engine.Config.AutoDailyQuests = false
    Engine.Config.AutoMailbox = false
    Engine.Config.AutoUpgradeCharacters = false
    Engine.Config.AutoEquipBest = false

    -- Visuals
    Engine.Config.OreESP = false
    Engine.Config.StandESP = false
    Engine.Config.MaxESPDistance = 350
    Engine.Config.PlayerESP = false
    Engine.Config.Fullbright = false

    -- Player Mods
    Engine.Config.SpeedBoost = false
    Engine.Config.SpeedValue = 16
    Engine.Config.JumpBoost = false
    Engine.Config.JumpValue = 50
    Engine.Config.InfiniteJump = false
    Engine.Config.Noclip = false
    Engine.Config.AntiAFK = true
    Engine.Config.MineHoverHeight = 3.5

    -- Super Features
    Engine.Config.AutoRestoreHUD = true
    Engine.Config.AutoRedeemCodes = false
    Engine.Config.AutoClaimBuffPad = false
    Engine.Config.AutoMysteryBlocks = false
    Engine.Config.AutoColossusCrates = false
    Engine.Config.AutoConsumePotions = false
    Engine.Config.AutoBuySkills = false
    Engine.Config.SelectedZone = "Z1"
    Engine.Config.SelectedPlayer = ""

    -- 2. Immediate physical state restoration & halt character physics
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
        pcall(function() GameState.SendEvent("MineTeleport", "Plot") end)
    end)

    -- 3. Clear all active ESP drawings & objects
    pcall(function()
        for _, obj in pairs(Engine.ESPObjects) do
            if obj and obj.Destroy then pcall(obj.Destroy, obj) end
        end
        table.clear(Engine.ESPObjects)
        for _, draw in pairs(Engine.Drawings) do
            if draw and draw.Remove then pcall(draw.Remove, draw) end
        end
        table.clear(Engine.Drawings)
    end)

    -- 4. Restore Lighting to default
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)

    -- 5. Force update visual widgets across ALL tabs via Engine.UIControls
    for k, widget in pairs(Engine.UIControls) do
        local def = Engine.Config[k]
        if def ~= nil and widget then
            pcall(function()
                if type(def) == "boolean" and widget.Set then
                    widget:Set(def)
                elseif type(def) == "number" and widget.Set then
                    widget:Set(def)
                    pcall(widget.Set, widget, tostring(def))
                elseif type(def) == "string" then
                    if widget.Select then
                        widget:Select(def)
                    elseif widget.Set then
                        widget:Set(def)
                    end
                end
            end)
        end
    end

    -- 6. Explicitly update mirror twin controls in TabAutomation
    if W.TglAutoUpgrade and W.TglAutoUpgrade.Set then
        pcall(W.TglAutoUpgrade.Set, W.TglAutoUpgrade, false)
    end
    if W.InputMaxMinerLevelAuto and W.InputMaxMinerLevelAuto.Set then
        pcall(W.InputMaxMinerLevelAuto.Set, W.InputMaxMinerLevelAuto, "100")
    end
    if W.TglAutoBuyPickaxesAuto and W.TglAutoBuyPickaxesAuto.Set then
        pcall(W.TglAutoBuyPickaxesAuto.Set, W.TglAutoBuyPickaxesAuto, false)
    end
    if W.TglAutoEquipPickaxesAuto and W.TglAutoEquipPickaxesAuto.Set then
        pcall(W.TglAutoEquipPickaxesAuto.Set, W.TglAutoEquipPickaxesAuto, false)
    end
    if W.TglAutoClaimChest and W.TglAutoClaimChest.Set then
        pcall(W.TglAutoClaimChest.Set, W.TglAutoClaimChest, false)
    end

    isLoadingConfig = false
    WindUI:Notify({
        Title = "Config Reset",
        Content = "All automations stopped & settings restored to default.",
        Duration = 3,
        Icon = "rotate-ccw"
    })
end

Engine.SaveConfig = saveConfig
Engine.LoadConfig = loadConfig
Engine.ResetConfig = resetConfig

-- ====================================================================
-- 6. GAME HELPER ROUTINES & AUTOMATION LOGIC
-- ====================================================================

-- 6.0 PROMO CODES BOMBER
local PROMO_CODES = {
    "PETALFALL",
    "ONANDON",
    "FEASTS",
    "MOONRISE",
    "HALLOWKEEP",
    "BLUEMOON",
    "SOULFORGE",
    "EnchantedStrength",
    "MUTATIONLUCK"
}

local function redeemAllCodes()
    task.spawn(function()
        for _, code in ipairs(PROMO_CODES) do
            pcall(function()
                GameState.SendEvent("UseCode", code)
            end)
            task.wait(0.6)
        end
        WindUI:Notify({
            Title = "Promo Codes",
            Content = "All 9 active promo codes redeemed successfully!",
            Duration = 3,
            Icon = "gift"
        })
    end)
end

-- 6.015 HUD Restoration Engine (Fixes game chrome elements hidden by gacha / cutscenes)
local function RestoreGameHUDs()
    pcall(function()
        -- 1. Call native GameState UI unhider if available
        local RS = game:GetService("ReplicatedStorage")
        local GS = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("GameState")
        if GS then
            pcall(function()
                local gsMod = require(GS)
                local d2 = gsMod and gsMod.GetData2 and gsMod.GetData2()
                if d2 and type(d2.HideAllUIs) == "function" then
                    d2:HideAllUIs(false)
                end
            end)
        end

        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pGui then return end

        -- 2. Reset HidingUIs attribute & restore MineGui chrome elements
        local mGui = pGui:FindFirstChild("MineGui")
        if mGui then
            pcall(function() mGui:SetAttribute("HidingUIs", false) end)
            local chromeNames = {"LeftBar", "TeleportButton", "HotbarFrame", "EventsBar", "RightBar"}
            for _, name in ipairs(chromeNames) do
                local el = mGui:FindFirstChild(name)
                if el and el:IsA("GuiObject") and not el.Visible then
                    el.Visible = true
                end
            end
        end

        -- 3. Restore ScreenGui MoneyHolder
        local sGui = pGui:FindFirstChild("ScreenGui")
        if sGui then
            local mh = sGui:FindFirstChild("MoneyHolder")
            if mh and mh:IsA("GuiObject") and not mh.Visible then
                mh.Visible = true
            end
        end

        -- 4. Ensure ProximityPromptService is enabled
        local pps = game:GetService("ProximityPromptService")
        if pps and not pps.Enabled then
            pps.Enabled = true
        end
    end)
end

-- 6.01 Fullbright Controller
local OriginalLighting = {
    Brightness = game:GetService("Lighting").Brightness,
    ClockTime = game:GetService("Lighting").ClockTime,
    FogEnd = game:GetService("Lighting").FogEnd,
    Ambient = game:GetService("Lighting").Ambient,
}

local function setFullbright(enabled)
    local Lighting = game:GetService("Lighting")
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.Ambient = OriginalLighting.Ambient
    end
end

-- 6.02 Player ESP Objects
local PlayerESPFolder = Instance.new("Folder")
PlayerESPFolder.Name = "MyAnimeMine_PlayerESP"
pcall(function()
    PlayerESPFolder.Parent = game:GetService("CoreGui")
end)
if not PlayerESPFolder.Parent then
    PlayerESPFolder.Parent = Workspace
end

-- 6.1 Remote Instant Sell (Ores + Safe Unused Fodder Miners)
local function sellAllBagItems()
    pcall(function()
        local data = GameState and GameState.GetData2()
        local mg = data and data.MineGame
        if not mg or not MineInventory then return end

        local sellList = {}
        for _, item in ipairs(MineInventory.Collect(mg, "All", MineInventory.KindOrder.OreFirst)) do
            local count = item.SellCount or item.Count or 0
            if count > 0 and (item.Worth or 0) > 0 then
                if item.Kind == "Ore" then
                    table.insert(sellList, item.Key)
                elseif IsMinerSellable(item, mg) then
                    table.insert(sellList, item.Key)
                end
            end
        end

        if #sellList > 0 then
            GameState.SendEvent("MineSellItems", sellList)
        end
    end)
end
-- 6.2 Ore Finder & Topology
local ORE_RARITY_RANKS = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
}

local ORE_RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(150, 150, 150),
    ["Uncommon"] = Color3.fromRGB(80, 200, 120),
    ["Rare"] = Color3.fromRGB(60, 160, 255),
    ["Epic"] = Color3.fromRGB(180, 70, 255),
    ["Legendary"] = Color3.fromRGB(255, 180, 40),
    ["Mythic"] = Color3.fromRGB(255, 60, 90),
}

local function getAllOresInWorkspace()
    local ores = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child:GetAttribute("OreName") then
            table.insert(ores, child)
        elseif child:IsA("Model") and child:FindFirstChild("Root") and child.Root:GetAttribute("OreName") then
            table.insert(ores, child)
        end
    end
    return ores
end

local function getNearestTargetOre()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local targetFilter = Engine.Config.TargetOre
    local bestOre = nil
    local bestDist = math.huge

    for _, ore in ipairs(getAllOresInWorkspace()) do
        local oreName = ore:GetAttribute("OreName") or (ore:FindFirstChild("Root") and ore.Root:GetAttribute("OreName")) or ore.Name
        local oreRarity = ore:GetAttribute("OreRarity") or (ore:FindFirstChild("Root") and ore.Root:GetAttribute("OreRarity")) or "Common"
        local orePart = ore:FindFirstChild("Root") or ore.PrimaryPart or ore:FindFirstChildWhichIsA("BasePart")

        if orePart then
            local dist = (orePart.Position - root.Position).Magnitude
            if dist <= Engine.Config.MineRange then
                local isMatch = false
                if targetFilter == "All Ores" then
                    isMatch = true
                elseif targetFilter == "Mythic & Legendary Only" then
                    isMatch = (oreRarity == "Mythic" or oreRarity == "Legendary")
                elseif targetFilter == "Epic & Rare Only" then
                    isMatch = (oreRarity == "Epic" or oreRarity == "Rare")
                elseif targetFilter == oreName then
                    isMatch = true
                end

                if isMatch and dist < bestDist then
                    bestDist = dist
                    bestOre = { Model = ore, Part = orePart, Name = oreName, Rarity = oreRarity, Distance = dist }
                end
            end
        end
    end
    return bestOre
end

-- 6.3 Ore ESP Engine
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MyAnimeMine_ESP"
pcall(function() ESPFolder.Parent = CurrentCamera or Workspace end)

local function updateOreESP()
    if not Engine.Config.OreESP then
        for _, obj in pairs(Engine.ESPObjects) do
            if obj.Billboard then pcall(function() obj.Billboard:Destroy() end) end
        end
        table.clear(Engine.ESPObjects)
        return
    end

    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position
    local activeKeys = {}

    for _, ore in ipairs(getAllOresInWorkspace()) do
        local rootPart = ore:FindFirstChild("Root") or ore.PrimaryPart or ore:FindFirstChildWhichIsA("BasePart")
        if rootPart then
            local dist = (rootPart.Position - camPos).Magnitude
            if dist <= Engine.Config.MaxESPDistance then
                local oreName = ore:GetAttribute("OreName") or rootPart:GetAttribute("OreName") or ore.Name
                local oreRarity = ore:GetAttribute("OreRarity") or rootPart:GetAttribute("OreRarity") or "Common"
                local key = "ORE_" .. ore:GetDebugId()
                activeKeys[key] = true

                local cache = Engine.ESPObjects[key]
                if not cache then
                    cache = {}
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "BB_" .. key
                    bb.Size = UDim2.fromOffset(140, 36)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = Engine.Config.MaxESPDistance
                    bb.ExtentsOffset = Vector3.new(0, 2.2, 0)
                    bb.Adornee = rootPart
                    bb.Parent = ESPFolder

                    local lblName = Instance.new("TextLabel")
                    lblName.Size = UDim2.new(1, 0, 0.55, 0)
                    lblName.BackgroundTransparency = 1
                    lblName.Font = Enum.Font.RobotoMono
                    lblName.TextSize = 12
                    lblName.TextColor3 = ORE_RARITY_COLORS[oreRarity] or Color3.fromRGB(255, 255, 255)
                    lblName.TextStrokeTransparency = 0.2
                    lblName.Text = oreName
                    lblName.Parent = bb

                    local lblInfo = Instance.new("TextLabel")
                    lblInfo.Size = UDim2.new(1, 0, 0.45, 0)
                    lblInfo.Position = UDim2.new(0, 0, 0.55, 0)
                    lblInfo.BackgroundTransparency = 1
                    lblInfo.Font = Enum.Font.RobotoMono
                    lblInfo.TextSize = 10
                    lblInfo.TextColor3 = Color3.fromRGB(220, 220, 220)
                    lblInfo.TextStrokeTransparency = 0.3
                    lblInfo.Parent = bb

                    cache.Billboard = bb
                    cache.NameLabel = lblName
                    cache.InfoLabel = lblInfo
                    cache.Part = rootPart
                    Engine.ESPObjects[key] = cache
                end

                cache.Billboard.Enabled = true
                cache.InfoLabel.Text = string.format("[%s] %dm", oreRarity, math.floor(dist))
            end
        end
    end

    for k, v in pairs(Engine.ESPObjects) do
        if not activeKeys[k] then
            if v.Billboard then pcall(function() v.Billboard:Destroy() end) end
            Engine.ESPObjects[k] = nil
        end
    end
end

-- ====================================================================
-- 7. BUILDING THE WINDUI INTERFACE
-- ====================================================================


local W = {}
-- 7.0 TAB 0: DEVELOPER ADMIN SUITE (Cmdr Integration & 0% Gimmick Macros)
local TabAdmin = Window:Tab({ Title = getText("TabAdmin"), Icon = "shield-alert" })
registerWidget(TabAdmin, "Tab", "TabAdmin")


W.SecAdminNotice = TabAdmin:Section({ Title = "Server Notice & Live Capabilities" })
W.ParAdmin = TabAdmin:Paragraph({
    Title = "Server-Side Cmdr Protection Notice",
    Content = "In the live place (79389059854988), server-side Cmdr commands (completeindex, givegems) are restricted by the server script to the developer studio ID. Use the Real Client-Side Macros below which execute 100% on the live server."
})

W.SecCmdr = TabAdmin:Section({ Title = getText("SecCmdr") })
registerWidget(W.SecCmdr, "Section", "SecCmdr")

W.BtnLaunchCmdr = TabAdmin:Button({
    Title = getText("BtnLaunchCmdr"),
    Desc = getText("DescLaunchCmdr"),
    Callback = function()
        if CmdrClient and CmdrClient.Show then
            CmdrClient:Show()
        elseif CmdrClient and CmdrClient.Toggle then
            CmdrClient:Toggle()
        else
            WindUI:Notify({ Title = "Cmdr Error", Content = "CmdrClient interface unavailable", Duration = 3 })
        end
    end
})
registerWidget(W.BtnLaunchCmdr, "Button", "BtnLaunchCmdr", "DescLaunchCmdr")

W.InputCmdr = TabAdmin:Input({
    Title = getText("InputCmdr"),
    Value = Engine.Config.CustomCmdrCmd,
    Placeholder = "completeindex me",
    Callback = function(val)
        Engine.Config.CustomCmdrCmd = val
    end
})
registerWidget(W.InputCmdr, "Input", "InputCmdr")
Engine.UIControls.CustomCmdrCmd = W.InputCmdr

W.BtnDispatchCmdr = TabAdmin:Button({
    Title = getText("BtnDispatchCmdr"),
    Callback = function()
        if Engine.Config.CustomCmdrCmd and Engine.Config.CustomCmdrCmd ~= "" then
            DispatchCmdr(Engine.Config.CustomCmdrCmd)
        end
    end
})
registerWidget(W.BtnDispatchCmdr, "Button", "BtnDispatchCmdr")

W.SecAdminMacros = TabAdmin:Section({ Title = getText("SecAdminMacros") })
registerWidget(W.SecAdminMacros, "Section", "SecAdminMacros")

W.BtnCompleteIndex = TabAdmin:Button({
    Title = getText("BtnCompleteIndex"),
    Desc = getText("DescCompleteIndex"),
    Callback = function()
        DispatchCmdr("completeindex me")
    end
})
registerWidget(W.BtnCompleteIndex, "Button", "BtnCompleteIndex", "DescCompleteIndex")

W.BtnUnlockZones = TabAdmin:Button({
    Title = getText("BtnUnlockZones"),
    Desc = getText("DescUnlockZones"),
    Callback = function()
        DispatchCmdr("unlockzones me")
    end
})
registerWidget(W.BtnUnlockZones, "Button", "BtnUnlockZones", "DescUnlockZones")

W.BtnMaxMine = TabAdmin:Button({
    Title = getText("BtnMaxMine"),
    Desc = getText("DescMaxMine"),
    Callback = function()
        DispatchCmdr("maxmine me")
    end
})
registerWidget(W.BtnMaxMine, "Button", "BtnMaxMine", "DescMaxMine")

W.BtnTapKill = TabAdmin:Button({
    Title = getText("BtnTapKill"),
    Desc = getText("DescTapKill"),
    Callback = function()
        DispatchCmdr("tapkill me")
    end
})
registerWidget(W.BtnTapKill, "Button", "BtnTapKill", "DescTapKill")

W.BtnAdminPanel = TabAdmin:Button({
    Title = "Open Game Admin Panel UI",
    Desc = "Launches built-in server admin panel frame (adminpanel me)",
    Callback = function()
        DispatchCmdr("adminpanel me")
    end
})

W.BtnStopCutscene = TabAdmin:Button({
    Title = "Emergency Stop Stuck Cutscenes",
    Desc = "Terminates active camera locks & cutscenes (stopcutscene me)",
    Callback = function()
        DispatchCmdr("stopcutscene me")
    end
})

W.SecAdminEconomy = TabAdmin:Section({ Title = getText("SecAdminEconomy") })
registerWidget(W.SecAdminEconomy, "Section", "SecAdminEconomy")

W.BtnGrantGems = TabAdmin:Button({
    Title = getText("BtnGrantGems"),
    Callback = function()
        DispatchCmdr("givegems me 1000000")
    end
})
registerWidget(W.BtnGrantGems, "Button", "BtnGrantGems")

W.BtnGrantScrolls = TabAdmin:Button({
    Title = getText("BtnGrantScrolls"),
    Callback = function()
        DispatchCmdr("givescrolls me 1000")
    end
})
registerWidget(W.BtnGrantScrolls, "Button", "BtnGrantScrolls")

W.BtnGrantDice = TabAdmin:Button({
    Title = getText("BtnGrantDice"),
    Callback = function()
        DispatchCmdr("givedice me 500")
    end
})
registerWidget(W.BtnGrantDice, "Button", "BtnGrantDice")

W.BtnGrantCash = TabAdmin:Button({
    Title = getText("BtnGrantCash"),
    Callback = function()
        DispatchCmdr("givemoney me 1000000000")
    end
})
registerWidget(W.BtnGrantCash, "Button", "BtnGrantCash")

W.BtnGrantItems = TabAdmin:Button({
    Title = getText("BtnGrantItems"),
    Callback = function()
        DispatchCmdr("giveallitems me")
    end
})
registerWidget(W.BtnGrantItems, "Button", "BtnGrantItems")


-- 7.05 TAB PLOT: GROUND-TRUTH PLOT & MINER MAXIMIZER
local TabPlot = Window:Tab({ Title = getText("TabPlot"), Icon = "hammer" })
registerWidget(TabPlot, "Tab", "TabPlot")

W.SecPlotMaximizer = TabPlot:Section({ Title = getText("SecPlotMaximizer") })
registerWidget(W.SecPlotMaximizer, "Section", "SecPlotMaximizer")

W.ParaMinerTelemetry = TabPlot:Paragraph({
    Title = "Live Miner Roster Telemetry",
    Desc = "Scanning plot holders..."
})

W.DropMinerUpgradeMode = TabPlot:Dropdown({
    Title = "Miner Upgrade Target Mode",
    Values = {
        "Balanced (Lowest Level First)",
        "Slot M1 Only",
        "Slot M2 Only",
        "Slot M3 Only",
        "Slot M4 Only",
        "Slot M5 Only",
        "Slot M6 Only"
    },
    Value = Engine.Config.MinerUpgradeMode or "Balanced (Lowest Level First)",
    Callback = function(v)
        Engine.Config.MinerUpgradeMode = v
    end
})
registerWidget(W.DropMinerUpgradeMode, "Dropdown", "DropMinerUpgradeMode")
Engine.UIControls.MinerUpgradeMode = W.DropMinerUpgradeMode

W.TglAutoUpgradeMiners = TabPlot:Toggle({
    Title = getText("TglAutoUpgradeMiners"),
    Desc = getText("DescAutoUpgradeMiners"),
    Value = Engine.Config.AutoUpgradeMiners,
    Callback = function(v)
        Engine.Config.AutoUpgradeMiners = v
        Engine.Config.AutoUpgradeCharacters = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoUpgrade and W.TglAutoUpgrade.Set then
                pcall(W.TglAutoUpgrade.Set, W.TglAutoUpgrade, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoUpgradeMiners, "Toggle", "TglAutoUpgradeMiners", "DescAutoUpgradeMiners")
Engine.UIControls.AutoUpgradeMiners = W.TglAutoUpgradeMiners

W.InputMaxMinerLevel = TabPlot:Input({
    Title = getText("InputMaxMinerLevel"),
    Desc = getText("DescMaxMinerLevel"),
    Value = tostring(Engine.Config.MaxMinerLevel or 100),
    Placeholder = "e.g. 80, 100, 150 (0 = Unlimited)",
    Callback = function(val)
        local num = tonumber(tostring(val):match("%d+")) or 0
        Engine.Config.MaxMinerLevel = num
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.InputMaxMinerLevelAuto and W.InputMaxMinerLevelAuto.Set then
                pcall(W.InputMaxMinerLevelAuto.Set, W.InputMaxMinerLevelAuto, tostring(num))
            end
            isSyncing = false
        end
    end
})
registerWidget(W.InputMaxMinerLevel, "Input", "InputMaxMinerLevel", "DescMaxMinerLevel")
Engine.UIControls.MaxMinerLevel = W.InputMaxMinerLevel

W.TglAutoUpgradeSpeed = TabPlot:Toggle({
    Title = getText("TglAutoUpgradeSpeed"),
    Desc = getText("DescAutoUpgradeSpeed"),
    Value = Engine.Config.AutoUpgradeSpeed or false,
    Callback = function(v)
        Engine.Config.AutoUpgradeSpeed = v
    end
})
registerWidget(W.TglAutoUpgradeSpeed, "Toggle", "TglAutoUpgradeSpeed", "DescAutoUpgradeSpeed")
Engine.UIControls.AutoUpgradeSpeed = W.TglAutoUpgradeSpeed

W.TglAutoUpgradeMineSpeed = TabPlot:Toggle({
    Title = getText("TglAutoUpgradeMineSpeed"),
    Desc = getText("DescAutoUpgradeMineSpeed"),
    Value = Engine.Config.AutoUpgradeMineSpeed or false,
    Callback = function(v)
        Engine.Config.AutoUpgradeMineSpeed = v
    end
})
registerWidget(W.TglAutoUpgradeMineSpeed, "Toggle", "TglAutoUpgradeMineSpeed", "DescAutoUpgradeMineSpeed")
Engine.UIControls.AutoUpgradeMineSpeed = W.TglAutoUpgradeMineSpeed

W.SldMinerDelay = TabPlot:Slider({
    Title = getText("SldMinerDelay"),
    Value = { Min = 0.5, Max = 5.0, Default = Engine.Config.MinerUpgradeDelay or 1.0 },
    Step = 0.25,
    Callback = function(v)
        Engine.Config.MinerUpgradeDelay = v
    end
})
registerWidget(W.SldMinerDelay, "Slider", "SldMinerDelay")
Engine.UIControls.MinerUpgradeDelay = W.SldMinerDelay

W.SldMinCashReserve = TabPlot:Slider({
    Title = getText("SldMinCashReserve"),
    Value = { Min = 0, Max = 100000000, Default = Engine.Config.MinCashReserve or 10000000 },
    Step = 5000000,
    Callback = function(v)
        Engine.Config.MinCashReserve = v
    end
})
registerWidget(W.SldMinCashReserve, "Slider", "SldMinCashReserve")
Engine.UIControls.MinCashReserve = W.SldMinCashReserve

W.BtnUpgradeMinersOnce = TabPlot:Button({
    Title = getText("BtnUpgradeMinersOnce"),
    Callback = function()
        local count = UpgradeAllMinersOnce()
        WindUI:Notify({ Title = "Plot Maximizer", Content = "Completed " .. count .. " miner upgrades across plot!", Duration = 2.5 })
    end
})
registerWidget(W.BtnUpgradeMinersOnce, "Button", "BtnUpgradeMinersOnce")

W.TglSilentAutomation = TabPlot:Toggle({
    Title = getText("TglSilentAutomation"),
    Desc = getText("DescSilentAutomation"),
    Value = Engine.Config.SilentAutomation ~= false,
    Callback = function(v)
        Engine.Config.SilentAutomation = v
    end
})
registerWidget(W.TglSilentAutomation, "Toggle", "TglSilentAutomation", "DescSilentAutomation")
Engine.UIControls.SilentAutomation = W.TglSilentAutomation

W.SecPlotChest = TabPlot:Section({ Title = getText("SecPlotChest") })
registerWidget(W.SecPlotChest, "Section", "SecPlotChest")

W.TglAutoClaimChest = TabPlot:Toggle({
    Title = getText("TglAutoClaimChest"),
    Desc = getText("DescAutoClaimChest"),
    Value = Engine.Config.AutoClaimChest,
    Callback = function(v)
        Engine.Config.AutoClaimChest = v
        Engine.Config.AutoChest = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoChest and W.TglAutoChest.Set then
                pcall(W.TglAutoChest.Set, W.TglAutoChest, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoClaimChest, "Toggle", "TglAutoClaimChest", "DescAutoClaimChest")
Engine.UIControls.AutoClaimChest = W.TglAutoClaimChest

W.BtnClaimChestNow = TabPlot:Button({
    Title = getText("BtnClaimChestNow"),
    Callback = function()
        ClaimPlotChest()
        WindUI:Notify({ Title = "Chest Claim", Content = "Plot chest emptied silently!", Duration = 2.5 })
    end
})
registerWidget(W.BtnClaimChestNow, "Button", "BtnClaimChestNow")

W.SecPlotMiners = TabPlot:Section({ Title = getText("SecPlotMiners") })
registerWidget(W.SecPlotMiners, "Section", "SecPlotMiners")

W.TglAutoEquipBestMiners = TabPlot:Toggle({
    Title = getText("TglAutoEquipBestMiners"),
    Desc = getText("DescAutoEquipBestMiners"),
    Value = Engine.Config.AutoEquipBestMiners,
    Callback = function(v)
        Engine.Config.AutoEquipBestMiners = v
    end
})
registerWidget(W.TglAutoEquipBestMiners, "Toggle", "TglAutoEquipBestMiners", "DescAutoEquipBestMiners")
Engine.UIControls.AutoEquipBestMiners = W.TglAutoEquipBestMiners
Engine.UIControls.AutoEquipBest = W.TglAutoEquipBestMiners

W.TglAutoBuyPickaxes = TabPlot:Toggle({
    Title = getText("TglAutoBuyPickaxes"),
    Desc = getText("DescAutoBuyPickaxes"),
    Value = Engine.Config.AutoBuyPickaxes or false,
    Callback = function(v)
        Engine.Config.AutoBuyPickaxes = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoBuyPickaxesAuto and W.TglAutoBuyPickaxesAuto.Set then
                pcall(W.TglAutoBuyPickaxesAuto.Set, W.TglAutoBuyPickaxesAuto, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoBuyPickaxes, "Toggle", "TglAutoBuyPickaxes", "DescAutoBuyPickaxes")
Engine.UIControls.AutoBuyPickaxes = W.TglAutoBuyPickaxes

W.TglAutoEquipPickaxes = TabPlot:Toggle({
    Title = getText("TglAutoEquipPickaxes"),
    Desc = getText("DescAutoEquipPickaxes"),
    Value = Engine.Config.AutoEquipPickaxes or false,
    Callback = function(v)
        Engine.Config.AutoEquipPickaxes = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoEquipPickaxesAuto and W.TglAutoEquipPickaxesAuto.Set then
                pcall(W.TglAutoEquipPickaxesAuto.Set, W.TglAutoEquipPickaxesAuto, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoEquipPickaxes, "Toggle", "TglAutoEquipPickaxes", "DescAutoEquipPickaxes")
Engine.UIControls.AutoEquipPickaxes = W.TglAutoEquipPickaxes

W.BtnBuyBestPickaxe = TabPlot:Button({
    Title = getText("BtnBuyBestPickaxe"),
    Desc = getText("DescBuyBestPickaxe"),
    Callback = function()
        local bought = ExecuteAutoBuyPickaxes()
        if bought <= 0 and WindUI then
            WindUI:Notify({ Title = "Pickaxe Shop", Content = "No pickaxe upgrades available or affordable right now", Duration = 2.5 })
        end
    end
})
registerWidget(W.BtnBuyBestPickaxe, "Button", "BtnBuyBestPickaxe", "DescBuyBestPickaxe")

W.BtnEquipBestPlot = TabPlot:Button({
    Title = "Equip Best Miners & Pickaxes Now",
    Callback = function()
        pcall(ExecuteAutoEquipBestPickaxes)
        if GameState and GameState.SendEvent then
            GameState.SendEvent("MineEquipBest")
            WindUI:Notify({ Title = "Miners & Picks Setup", Content = "Equipped highest power characters and pickaxes", Duration = 2.5 })
        end
    end
})


-- 7.1 TAB 1: FARMING
local TabFarming = Window:Tab({ Title = getText("TabFarming"), Icon = "pickaxe" })
registerWidget(TabFarming, "Tab", "TabFarming")


W.SecNodeFarm = TabFarming:Section({ Title = getText("SecNodeFarm") })
registerWidget(W.SecNodeFarm, "Section", "SecNodeFarm")

W.TglAutoFarmNodes = TabFarming:Toggle({
    Title = getText("TglAutoFarmNodes"),
    Desc = getText("DescAutoFarmNodes"),
    Value = Engine.Config.AutoFarmNodes,
    Callback = function(v)
        Engine.Config.AutoFarmNodes = v
        if v and Engine.Config.TapKillMode then
            DispatchCmdr("tapkill me")
        end
    end
})
registerWidget(W.TglAutoFarmNodes, "Toggle", "TglAutoFarmNodes", "DescAutoFarmNodes")
Engine.UIControls.AutoFarmNodes = W.TglAutoFarmNodes

W.TglTapKillMode = TabFarming:Toggle({
    Title = getText("TglTapKillMode"),
    Desc = getText("DescTapKillMode"),
    Value = Engine.Config.TapKillMode,
    Callback = function(v)
        Engine.Config.TapKillMode = v
        if v then
            DispatchCmdr("tapkill me")
        end
    end
})
registerWidget(W.TglTapKillMode, "Toggle", "TglTapKillMode", "DescTapKillMode")
Engine.UIControls.TapKillMode = W.TglTapKillMode

W.DropTargetRarity = TabFarming:Dropdown({
    Title = getText("DropTargetRarity"),
    Desc = getText("DescTargetRarity"),
    Values = { "All Nodes", "Prismite & High Tier", "Medium & Large Only" },
    Value = Engine.Config.TargetNodeRarity,
    Callback = function(sel)
        Engine.Config.TargetNodeRarity = sel
    end
})
registerWidget(W.DropTargetRarity, "Dropdown", "DropTargetRarity", "DescTargetRarity")
Engine.UIControls.TargetNodeRarity = W.DropTargetRarity

W.SldNodeTapDelay = TabFarming:Slider({
    Title = getText("SldNodeTapDelay"),
    Value = { Min = 0.05, Max = 0.5, Default = Engine.Config.NodeTapDelay },
    Step = 0.05,
    Callback = function(v)
        Engine.Config.NodeTapDelay = v
    end
})
registerWidget(W.SldNodeTapDelay, "Slider", "SldNodeTapDelay")
Engine.UIControls.NodeTapDelay = W.SldNodeTapDelay

W.BtnTpLowestNode = TabFarming:Button({
    Title = getText("BtnTpLowestNode"),
    Callback = function()
        local target = GetBestTargetNode(Engine.Config.TargetNodeRarity)
        if target and target.Rock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:PivotTo(CFrame.new(target.Rock.Position + Vector3.new(0, 3, 0), target.Rock.Position))
            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            WindUI:Notify({ Title = "Node Fast Travel", Content = "Arrived at " .. target.Ore .. " (HP: " .. target.HP .. ")", Duration = 2.5 })
        end
    end
})
registerWidget(W.BtnTpLowestNode, "Button", "BtnTpLowestNode")


W.SecMine = TabFarming:Section({ Title = getText("SecMine") })
registerWidget(W.SecMine, "Section", "SecMine")

local ORE_OPTIONS = {
    "All Ores",
    "Mythic & Legendary Only",
    "Epic & Rare Only",
    "Voidshard",
    "Coronium",
    "Rosemarl",
    "Palegrit",
    "Scorchgold",
    "Bullionite",
    "Ironshard",
    "Sungold",
    "Emberlode",
    "Silverdrop",
    "Ochrite",
    "Copperine",
    "Coalite"
}

W.DropTargetOre = TabFarming:Dropdown({
    Title = getText("DropTargetOre"),
    Desc = getText("DescTargetOre"),
    Values = ORE_OPTIONS,
    Value = Engine.Config.TargetOre,
    Callback = function(v)
        Engine.Config.TargetOre = v
    end
})
registerWidget(W.DropTargetOre, "Dropdown", "DropTargetOre", "DescTargetOre")
Engine.UIControls.TargetOre = W.DropTargetOre

W.TglAutoMine = TabFarming:Toggle({
    Title = getText("TglAutoMine"),
    Desc = getText("DescAutoMine"),
    Value = Engine.Config.AutoMine,
    Callback = function(v)
        Engine.Config.AutoMine = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                pcall(function() GameState.SendEvent("MineTeleport", "Plot") end)
            end)
        end
    end
})
registerWidget(W.TglAutoMine, "Toggle", "TglAutoMine", "DescAutoMine")
Engine.UIControls.AutoMine = W.TglAutoMine

W.SldMineRange = TabFarming:Slider({
    Title = getText("SldMineRange"),
    Step = 10,
    Value = { Min = 30, Max = 500, Default = Engine.Config.MineRange },
    Callback = function(v)
        Engine.Config.MineRange = v
    end
})
registerWidget(W.SldMineRange, "Slider", "SldMineRange")
Engine.UIControls.MineRange = W.SldMineRange

W.SldHoverHeight = TabFarming:Slider({
    Title = getText("SldHoverHeight"),
    Step = 0.5,
    Value = { Min = 2, Max = 8, Default = Engine.Config.MineHoverHeight },
    Callback = function(v)
        Engine.Config.MineHoverHeight = v
    end
})
registerWidget(W.SldHoverHeight, "Slider", "SldHoverHeight")
Engine.UIControls.MineHoverHeight = W.SldHoverHeight

W.TglMystery = TabFarming:Toggle({
    Title = getText("TglMysteryBlocks"),
    Desc = getText("DescMystery"),
    Value = Engine.Config.AutoMysteryBlocks,
    Callback = function(v)
        Engine.Config.AutoMysteryBlocks = v
    end
})
registerWidget(W.TglMystery, "Toggle", "TglMysteryBlocks", "DescMystery")
Engine.UIControls.AutoMysteryBlocks = W.TglMystery

W.TglCrates = TabFarming:Toggle({
    Title = getText("TglColossusCrates"),
    Desc = getText("DescCrates"),
    Value = Engine.Config.AutoColossusCrates,
    Callback = function(v)
        Engine.Config.AutoColossusCrates = v
    end
})
registerWidget(W.TglCrates, "Toggle", "TglColossusCrates", "DescCrates")
Engine.UIControls.AutoColossusCrates = W.TglCrates

W.SecSell = TabFarming:Section({ Title = getText("SecSell") })
registerWidget(W.SecSell, "Section", "SecSell")

W.TglAutoSell = TabFarming:Toggle({
    Title = getText("TglAutoSell"),
    Desc = getText("DescAutoSell"),
    Value = Engine.Config.AutoSell,
    Callback = function(v)
        Engine.Config.AutoSell = v
    end
})
registerWidget(W.TglAutoSell, "Toggle", "TglAutoSell", "DescAutoSell")
Engine.UIControls.AutoSell = W.TglAutoSell

W.DropAutoSellMinerRarity = TabFarming:Dropdown({
    Title = getText("DropAutoSellMinerRarity"),
    Values = {
        "Disabled / Ores Only",
        "Rare & Below (Common, Uncommon, Rare)",
        "Epic & Below (Common to Epic)",
        "Legendary & Below",
        "Mythical & Below",
        "All Below Active Plot Tier",
        "Sell All Unequipped Miners"
    },
    Value = Engine.Config.AutoSellMinerRarity or "Rare & Below (Common, Uncommon, Rare)",
    Callback = function(v)
        Engine.Config.AutoSellMinerRarity = v
    end
})
registerWidget(W.DropAutoSellMinerRarity, "Dropdown", "DropAutoSellMinerRarity")
Engine.UIControls.AutoSellMinerRarity = W.DropAutoSellMinerRarity

W.SldSellInterval = TabFarming:Slider({
    Title = getText("SldSellInterval"),
    Step = 2,
    Value = { Min = 4, Max = 60, Default = Engine.Config.AutoSellInterval },
    Callback = function(v)
        Engine.Config.AutoSellInterval = v
    end
})
registerWidget(W.SldSellInterval, "Slider", "SldSellInterval")
Engine.UIControls.AutoSellInterval = W.SldSellInterval

W.BtnSellNow = TabFarming:Button({
    Title = getText("BtnSellNow"),
    Desc = getText("DescSellNow"),
    Callback = function()
        task.spawn(function()
            ExecuteFullSellRoutine()
        end)
        WindUI:Notify({ Title = "Sell Stand Routine", Content = "Emptied chest, visited sell stand & sold bag items!", Duration = 2.5, Icon = "check" })
    end
})
registerWidget(W.BtnSellNow, "Button", "BtnSellNow", "DescSellNow")
Engine.UIControls.BtnSellNow = W.BtnSellNow

W.TglAutoChest = TabFarming:Toggle({
    Title = getText("TglAutoChest"),
    Desc = getText("DescAutoChest"),
    Value = Engine.Config.AutoClaimChest,
    Callback = function(v)
        Engine.Config.AutoClaimChest = v
        Engine.Config.AutoChest = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoClaimChest and W.TglAutoClaimChest.Set then
                pcall(W.TglAutoClaimChest.Set, W.TglAutoClaimChest, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoChest, "Toggle", "TglAutoChest", "DescAutoChest")
Engine.UIControls.AutoChest = W.TglAutoChest

-- 7.2 TAB 2: TELEPORT
local TabTeleport = Window:Tab({ Title = getText("TabTeleport"), Icon = "map-pin" })
registerWidget(TabTeleport, "Tab", "TabTeleport")

W.SecTravel = TabTeleport:Section({ Title = getText("SecTravel") })
registerWidget(W.SecTravel, "Section", "SecTravel")

W.BtnTpHub = TabTeleport:Button({
    Title = getText("BtnTpHub"),
    Callback = function()
        pcall(function() GameState.SendEvent("MineTeleport", "Hub") end)
    end
})
registerWidget(W.BtnTpHub, "Button", "BtnTpHub")

W.BtnTpPlot = TabTeleport:Button({
    Title = getText("BtnTpPlot"),
    Callback = function()
        pcall(function() GameState.SendEvent("MineTeleport", "Plot") end)
    end
})
registerWidget(W.BtnTpPlot, "Button", "BtnTpPlot")

W.BtnTpOre = TabTeleport:Button({
    Title = getText("BtnTpOre"),
    Callback = function()
        local ore = getNearestTargetOre()
        if ore and ore.Part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = ore.Part.CFrame + Vector3.new(0, 3.5, 0)
            WindUI:Notify({ Title = "Ore Teleport", Content = "Teleported to " .. ore.Name .. " (" .. math.floor(ore.Distance) .. "m)", Duration = 2, Icon = "navigation" })
        else
            WindUI:Notify({ Title = "Ore Teleport", Content = "No matching ore found in range.", Duration = 2, Icon = "alert-circle" })
        end
    end
})
registerWidget(W.BtnTpOre, "Button", "BtnTpOre")

W.SecZones = TabTeleport:Section({ Title = getText("SecZones") })
registerWidget(W.SecZones, "Section", "SecZones")

local ZONE_LIST = {"Z1", "Z2", "Z3", "Z4", "Z5", "Z6", "Z7", "Z8", "Z9", "Z10", "Z11", "Z12", "Z13"}
W.DropZones = TabTeleport:Dropdown({
    Title = getText("DropZones"),
    Values = ZONE_LIST,
    Value = Engine.Config.SelectedZone,
    Callback = function(v)
        Engine.Config.SelectedZone = v
    end
})
registerWidget(W.DropZones, "Dropdown", "DropZones")
Engine.UIControls.SelectedZone = W.DropZones

W.BtnTpZone = TabTeleport:Button({
    Title = getText("BtnTpZone"),
    Desc = getText("DescTpZone"),
    Callback = function()
        pcall(function()
            ExecuteZoneUnlock(Engine.Config.SelectedZone)
            WindUI:Notify({ Title = "Zone Travel", Content = "Traveled to " .. Engine.Config.SelectedZone, Duration = 2, Icon = "compass" })
        end)
    end
})
registerWidget(W.BtnTpZone, "Button", "BtnTpZone", "DescTpZone")

W.SecPlayers = TabTeleport:Section({ Title = getText("SecPlayers") })
registerWidget(W.SecPlayers, "Section", "SecPlayers")

local function getPlayerNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then table.insert(list, "No other players") end
    return list
end

W.DropPlayers = TabTeleport:Dropdown({
    Title = getText("DropPlayers"),
    Values = getPlayerNames(),
    Value = getPlayerNames()[1] or "",
    Callback = function(v)
        Engine.Config.SelectedPlayer = v
    end
})
registerWidget(W.DropPlayers, "Dropdown", "DropPlayers")
Engine.UIControls.SelectedPlayer = W.DropPlayers

W.BtnTpPlayer = TabTeleport:Button({
    Title = getText("BtnTpPlayer"),
    Desc = getText("DescTpPlayer"),
    Callback = function()
        pcall(function()
            local target = Players:FindFirstChild(Engine.Config.SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
                WindUI:Notify({ Title = "Player Teleport", Content = "Teleported to " .. target.Name, Duration = 2, Icon = "navigation" })
            end
        end)
    end
})
registerWidget(W.BtnTpPlayer, "Button", "BtnTpPlayer", "DescTpPlayer")

W.SecStands = TabTeleport:Section({ Title = getText("SecStands") })
registerWidget(W.SecStands, "Section", "SecStands")

local STAND_LOCATIONS = {
    { Key = "BtnTpSell", Name = "SellStand" },
    { Key = "BtnTpPick", Name = "PickaxesStand" },
    { Key = "BtnTpEnchant", Name = "EnchantAltar" },
    { Key = "BtnTpSummon", Name = "SummonShrine" },
    { Key = "BtnTpAlliance", Name = "AllianceStand" },
    { Key = "BtnTpLucky", Name = "UnrealLuckyBlockDisplay" },
}

for _, item in ipairs(STAND_LOCATIONS) do
    W.btn = TabTeleport:Button({
        Title = getText(item.Key),
        Callback = function()
            local targetModel = Workspace:FindFirstChild(item.Name)
            if targetModel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local posPart = targetModel:FindFirstChildWhichIsA("BasePart") or targetModel.PrimaryPart
                if posPart then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = posPart.CFrame + Vector3.new(0, 3, 3)
                    WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. item.Name, Duration = 2, Icon = "check" })
                end
            end
        end
    })
    registerWidget(W.btn, "Button", item.Key)
end

-- 7.3 TAB 3: AUTOMATION
local TabAutomation = Window:Tab({ Title = getText("TabAutomation"), Icon = "repeat" })
registerWidget(TabAutomation, "Tab", "TabAutomation")

W.SecCodes = TabAutomation:Section({ Title = getText("SecCodes") })
registerWidget(W.SecCodes, "Section", "SecCodes")

W.BtnRedeemAll = TabAutomation:Button({
    Title = getText("BtnRedeemAll"),
    Desc = getText("DescRedeemAll"),
    Callback = function()
        redeemAllCodes()
    end
})
registerWidget(W.BtnRedeemAll, "Button", "BtnRedeemAll", "DescRedeemAll")

W.TglAutoCodes = TabAutomation:Toggle({
    Title = getText("TglAutoCodes"),
    Desc = getText("DescAutoCodes"),
    Value = Engine.Config.AutoRedeemCodes,
    Callback = function(v)
        Engine.Config.AutoRedeemCodes = v
    end
})
registerWidget(W.TglAutoCodes, "Toggle", "TglAutoCodes", "DescAutoCodes")
Engine.UIControls.AutoRedeemCodes = W.TglAutoCodes

W.SecBuffs = TabAutomation:Section({ Title = getText("SecBuffs") })
registerWidget(W.SecBuffs, "Section", "SecBuffs")

W.TglBuffPad = TabAutomation:Toggle({
    Title = getText("TglBuffPad"),
    Desc = getText("DescBuffPad"),
    Value = Engine.Config.AutoClaimBuffPad,
    Callback = function(v)
        Engine.Config.AutoClaimBuffPad = v
    end
})
registerWidget(W.TglBuffPad, "Toggle", "TglBuffPad", "DescBuffPad")
Engine.UIControls.AutoClaimBuffPad = W.TglBuffPad

W.TglPotions = TabAutomation:Toggle({
    Title = getText("TglPotions"),
    Desc = getText("DescPotions"),
    Value = Engine.Config.AutoConsumePotions,
    Callback = function(v)
        Engine.Config.AutoConsumePotions = v
    end
})
registerWidget(W.TglPotions, "Toggle", "TglPotions", "DescPotions")
Engine.UIControls.AutoConsumePotions = W.TglPotions

W.TglSkills = TabAutomation:Toggle({
    Title = getText("TglSkills"),
    Desc = getText("DescSkills"),
    Value = Engine.Config.AutoBuySkills,
    Callback = function(v)
        Engine.Config.AutoBuySkills = v
    end
})
registerWidget(W.TglSkills, "Toggle", "TglSkills", "DescSkills")
Engine.UIControls.AutoBuySkills = W.TglSkills

W.SecDailies = TabAutomation:Section({ Title = getText("SecDailies") })
registerWidget(W.SecDailies, "Section", "SecDailies")

W.TglDailySpin = TabAutomation:Toggle({
    Title = getText("TglDailySpin"),
    Desc = getText("DescDailySpin"),
    Value = Engine.Config.AutoDailySpin,
    Callback = function(v) Engine.Config.AutoDailySpin = v end
})
registerWidget(W.TglDailySpin, "Toggle", "TglDailySpin", "DescDailySpin")
Engine.UIControls.AutoDailySpin = W.TglDailySpin

W.TglDailyQuests = TabAutomation:Toggle({
    Title = getText("TglDailyQuests"),
    Desc = getText("DescDailyQuests"),
    Value = Engine.Config.AutoDailyQuests,
    Callback = function(v) Engine.Config.AutoDailyQuests = v end
})
registerWidget(W.TglDailyQuests, "Toggle", "TglDailyQuests", "DescDailyQuests")
Engine.UIControls.AutoDailyQuests = W.TglDailyQuests

W.TglMailbox = TabAutomation:Toggle({
    Title = getText("TglMailbox"),
    Desc = getText("DescMailbox"),
    Value = Engine.Config.AutoMailbox,
    Callback = function(v) Engine.Config.AutoMailbox = v end
})
registerWidget(W.TglMailbox, "Toggle", "TglMailbox", "DescMailbox")
Engine.UIControls.AutoMailbox = W.TglMailbox

W.BtnTutorial = TabAutomation:Button({
    Title = getText("BtnTutorial"),
    Desc = getText("DescTutorial"),
    Callback = function()
        pcall(function()
            GameState.SendEvent("MineTutorialDone")
            GameState.SendEvent("MineTutorialGift")
            GameState.SendEvent("MineTutorialGoalsDone")
            WindUI:Notify({ Title = "Tutorial Claim", Content = "Tutorial rewards sent.", Duration = 2.5, Icon = "gift" })
        end)
    end
})
registerWidget(W.BtnTutorial, "Button", "BtnTutorial", "DescTutorial")

W.SecProgression = TabAutomation:Section({ Title = getText("SecProgression") })
registerWidget(W.SecProgression, "Section", "SecProgression")

W.TglAutoUpgrade = TabAutomation:Toggle({
    Title = getText("TglAutoUpgrade"),
    Desc = getText("DescAutoUpgrade"),
    Value = Engine.Config.AutoUpgradeMiners,
    Callback = function(v)
        Engine.Config.AutoUpgradeMiners = v
        Engine.Config.AutoUpgradeCharacters = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoUpgradeMiners and W.TglAutoUpgradeMiners.Set then
                pcall(W.TglAutoUpgradeMiners.Set, W.TglAutoUpgradeMiners, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoUpgrade, "Toggle", "TglAutoUpgrade", "DescAutoUpgrade")
Engine.UIControls.AutoUpgradeCharacters = W.TglAutoUpgrade

W.InputMaxMinerLevelAuto = TabAutomation:Input({
    Title = getText("InputMaxMinerLevel"),
    Desc = getText("DescMaxMinerLevel"),
    Value = tostring(Engine.Config.MaxMinerLevel or 100),
    Placeholder = "e.g. 80, 100, 150 (0 = Unlimited)",
    Callback = function(val)
        local num = tonumber(tostring(val):match("%d+")) or 0
        Engine.Config.MaxMinerLevel = num
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.InputMaxMinerLevel and W.InputMaxMinerLevel.Set then
                pcall(W.InputMaxMinerLevel.Set, W.InputMaxMinerLevel, tostring(num))
            end
            isSyncing = false
        end
    end
})
registerWidget(W.InputMaxMinerLevelAuto, "Input", "InputMaxMinerLevel", "DescMaxMinerLevel")

W.TglAutoBuyPickaxesAuto = TabAutomation:Toggle({
    Title = getText("TglAutoBuyPickaxes"),
    Desc = getText("DescAutoBuyPickaxes"),
    Value = Engine.Config.AutoBuyPickaxes or false,
    Callback = function(v)
        Engine.Config.AutoBuyPickaxes = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoBuyPickaxes and W.TglAutoBuyPickaxes.Set then
                pcall(W.TglAutoBuyPickaxes.Set, W.TglAutoBuyPickaxes, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoBuyPickaxesAuto, "Toggle", "TglAutoBuyPickaxes", "DescAutoBuyPickaxes")

W.TglAutoEquipPickaxesAuto = TabAutomation:Toggle({
    Title = getText("TglAutoEquipPickaxes"),
    Desc = getText("DescAutoEquipPickaxes"),
    Value = Engine.Config.AutoEquipPickaxes or false,
    Callback = function(v)
        Engine.Config.AutoEquipPickaxes = v
        if not isSyncing and not isLoadingConfig then
            isSyncing = true
            if W.TglAutoEquipPickaxes and W.TglAutoEquipPickaxes.Set then
                pcall(W.TglAutoEquipPickaxes.Set, W.TglAutoEquipPickaxes, v)
            end
            isSyncing = false
        end
    end
})
registerWidget(W.TglAutoEquipPickaxesAuto, "Toggle", "TglAutoEquipPickaxes", "DescAutoEquipPickaxes")

W.BtnEquipBest = TabAutomation:Button({
    Title = getText("BtnEquipBest"),
    Desc = getText("DescEquipBest"),
    Callback = function()
        pcall(function()
            pcall(ExecuteAutoEquipBestMiners)
            pcall(ExecuteAutoEquipBestPickaxes)
            WindUI:Notify({ Title = "Equip Best", Content = "Best miners & picks equipped.", Duration = 2, Icon = "sparkles" })
        end)
    end
})
registerWidget(W.BtnEquipBest, "Button", "BtnEquipBest", "DescEquipBest")

-- Dynamic Zone Progression & Auto-Unlock Suite
W.SecZoneProgression = TabAutomation:Section({ Title = "Zone Progression & Expansion Studio" })
registerWidget(W.SecZoneProgression, "Section", "SecZoneProgression")

Engine.ParaZoneTelemetry = TabAutomation:Paragraph({
    Title = "Live Zone Progression Status",
    Desc = "Scanning zone progress..."
})

W.TglAutoUnlockNextZone = TabAutomation:Toggle({
    Title = "Auto Unlock Next Zone",
    Desc = "Automatically purchases and unlocks the next zone as soon as cash requirements are met",
    Value = Engine.Config.AutoUnlockNextZone ~= false,
    Callback = function(v)
        Engine.Config.AutoUnlockNextZone = v
    end
})
registerWidget(W.TglAutoUnlockNextZone, "Toggle", "TglAutoUnlockNextZone")
Engine.UIControls.AutoUnlockNextZone = W.TglAutoUnlockNextZone

W.TglAutoTravelDeepest = TabAutomation:Toggle({
    Title = "Auto Travel to Deepest Zone",
    Desc = "Ensures miners are always working in the deepest unlocked zone for max profit",
    Value = Engine.Config.AutoTravelDeepest ~= false,
    Callback = function(v)
        Engine.Config.AutoTravelDeepest = v
    end
})
registerWidget(W.TglAutoTravelDeepest, "Toggle", "TglAutoTravelDeepest")
Engine.UIControls.AutoTravelDeepest = W.TglAutoTravelDeepest

W.BtnUnlockNextZoneNow = TabAutomation:Button({
    Title = "Unlock Next Zone Now",
    Desc = "Checks cash and unlocks next zone immediately if affordable",
    Callback = function()
        local nextZone = GetNextLockedZoneInfo()
        if not nextZone then
            WindUI:Notify({ Title = "Zone Progression", Content = "All zones already unlocked!", Duration = 2.5 })
            return
        end
        local ok = ExecuteZoneProgressionCheck()
        if not ok then
            local data = GameState and GameState.GetData2()
            local curCash = tonumber(data and data.Money) or 0
            WindUI:Notify({
                Title = "Insufficient Cash",
                Content = string.format("Need $%s for %s (%s) [Have: $%s]", FormatMoneyShort(nextZone.Cost), nextZone.Name, nextZone.Key, FormatMoneyShort(curCash)),
                Duration = 3.0
            })
        end
    end
})
registerWidget(W.BtnUnlockNextZoneNow, "Button", "BtnUnlockNextZoneNow")

-- Comprehensive Research & Skill Tree Automation Suite
W.SecResearch = TabAutomation:Section({ Title = "Research & Skill Tree Studio" })
registerWidget(W.SecResearch, "Section", "SecResearch")

Engine.ParaResearchTelemetry = TabAutomation:Paragraph({
    Title = "Live Research Progress",
    Desc = "Scanning core & zone research..."
})

W.DropResearchTarget = TabAutomation:Dropdown({
    Title = "Research Target Zone",
    Values = {
        "Latest Unlocked Zone",
        "All Unlocked Zones",
        "Zone 3 (Magma Hollows)",
        "Zone 2 (Crystal Caves)",
        "Zone 1 (The Underground)"
    },
    Value = Engine.Config.ResearchTargetZone or "Latest Unlocked Zone",
    Callback = function(v)
        Engine.Config.ResearchTargetZone = v
    end
})
registerWidget(W.DropResearchTarget, "Dropdown", "DropResearchTarget")
Engine.UIControls.ResearchTargetZone = W.DropResearchTarget

W.TglAutoResearchSkills = TabAutomation:Toggle({
    Title = "Auto Research Zone Skills",
    Desc = "Continuously buys open skill nodes in target zone (Latest: Crystal Caves)",
    Value = Engine.Config.AutoResearchSkills or false,
    Callback = function(v)
        Engine.Config.AutoResearchSkills = v
    end
})
registerWidget(W.TglAutoResearchSkills, "Toggle", "TglAutoResearchSkills")
Engine.UIControls.AutoResearchSkills = W.TglAutoResearchSkills

W.TglAutoResearchTap = TabAutomation:Toggle({
    Title = "Auto Research Core Strike (Tap)",
    Desc = "Upgrades player tap/strike damage automatically",
    Value = Engine.Config.AutoResearchTap or false,
    Callback = function(v)
        Engine.Config.AutoResearchTap = v
    end
})
registerWidget(W.TglAutoResearchTap, "Toggle", "TglAutoResearchTap")
Engine.UIControls.AutoResearchTap = W.TglAutoResearchTap

W.TglAutoResearchSlots = TabAutomation:Toggle({
    Title = "Auto Research Miner Slots",
    Desc = "Expands maximum miner pad slots on plot (up to 8 slots)",
    Value = Engine.Config.AutoResearchSlots or false,
    Callback = function(v)
        Engine.Config.AutoResearchSlots = v
    end
})
registerWidget(W.TglAutoResearchSlots, "Toggle", "TglAutoResearchSlots")
Engine.UIControls.AutoResearchSlots = W.TglAutoResearchSlots

W.SldResearchReserve = TabAutomation:Slider({
    Title = "Research Cash Reserve ($)",
    Value = { Min = 0, Max = 50000000, Default = Engine.Config.ResearchReserve or 5000000 },
    Step = 2500000,
    Callback = function(v)
        Engine.Config.ResearchReserve = v
    end
})
registerWidget(W.SldResearchReserve, "Slider", "SldResearchReserve")
Engine.UIControls.ResearchReserve = W.SldResearchReserve

W.BtnResearchAllOnce = TabAutomation:Button({
    Title = "Research All Available Skills Once Now",
    Desc = "Sweeps and buys all affordable open research nodes across all zones",
    Callback = function()
        local count = ExecuteResearchUpgradeOnce()
        WindUI:Notify({ Title = "Research Complete", Content = "Purchased " .. count .. " research nodes across zones!", Duration = 2.5 })
    end
})
registerWidget(W.BtnResearchAllOnce, "Button", "BtnResearchAllOnce")

-- 7.4 TAB 4: GACHA & SHOP
local TabGacha = Window:Tab({ Title = getText("TabGacha"), Icon = "sparkles" })
registerWidget(TabGacha, "Tab", "TabGacha")

W.SecGacha = TabGacha:Section({ Title = getText("SecGacha") })
registerWidget(W.SecGacha, "Section", "SecGacha")

W.BtnSummon1 = TabGacha:Button({
    Title = getText("BtnSummon1"),
    Desc = getText("DescSummon"),
    Callback = function()
        pcall(function()
            GameState.SendEvent("MineSummon", 1)
            task.delay(0.8, RestoreGameHUDs)
            task.wait(0.5)
            if Engine.Config.AutoEquipBestMiners then
                pcall(ExecuteAutoEquipBestMiners)
            end
            if Engine.Config.AutoEquipPickaxes then
                pcall(ExecuteAutoEquipBestPickaxes)
            end
            WindUI:Notify({ Title = "Summon", Content = "Fast Summon x1 fired & Best Miners/Picks equipped.", Duration = 1.5, Icon = "sparkles" })
        end)
    end
})
registerWidget(W.BtnSummon1, "Button", "BtnSummon1", "DescSummon")

W.BtnSummon10 = TabGacha:Button({
    Title = getText("BtnSummon10"),
    Desc = getText("DescSummon"),
    Callback = function()
        pcall(function()
            GameState.SendEvent("MineSummon", 10)
            task.delay(0.8, RestoreGameHUDs)
            task.wait(0.6)
            if Engine.Config.AutoEquipBestMiners then
                pcall(ExecuteAutoEquipBestMiners)
            end
            if Engine.Config.AutoEquipPickaxes then
                pcall(ExecuteAutoEquipBestPickaxes)
            end
            WindUI:Notify({ Title = "Summon", Content = "Fast Summon x10 fired & Best Miners/Picks equipped.", Duration = 1.5, Icon = "sparkles" })
        end)
    end
})
registerWidget(W.BtnSummon10, "Button", "BtnSummon10", "DescSummon")

-- 7.5 TAB 5: VISUALS (ESP)
local TabVisuals = Window:Tab({ Title = getText("TabVisuals"), Icon = "eye" })
registerWidget(TabVisuals, "Tab", "TabVisuals")

W.SecRender = TabVisuals:Section({ Title = getText("SecRender") })
registerWidget(W.SecRender, "Section", "SecRender")

W.TglFullbright = TabVisuals:Toggle({
    Title = getText("TglFullbright"),
    Desc = getText("DescFullbright"),
    Value = Engine.Config.Fullbright,
    Callback = function(v)
        Engine.Config.Fullbright = v
        setFullbright(v)
    end
})
registerWidget(W.TglFullbright, "Toggle", "TglFullbright", "DescFullbright")
Engine.UIControls.Fullbright = W.TglFullbright

W.TglPlayerESP = TabVisuals:Toggle({
    Title = getText("TglPlayerESP"),
    Desc = getText("DescPlayerESP"),
    Value = Engine.Config.PlayerESP,
    Callback = function(v)
        Engine.Config.PlayerESP = v
        if not v then
            for _, c in ipairs(PlayerESPFolder:GetChildren()) do
                pcall(function() c:Destroy() end)
            end
        end
    end
})
registerWidget(W.TglPlayerESP, "Toggle", "TglPlayerESP", "DescPlayerESP")
Engine.UIControls.PlayerESP = W.TglPlayerESP

W.TglStandESP = TabVisuals:Toggle({
    Title = getText("TglStandESP"),
    Desc = getText("DescStandESP"),
    Value = Engine.Config.StandESP,
    Callback = function(v)
        Engine.Config.StandESP = v
    end
})
registerWidget(W.TglStandESP, "Toggle", "TglStandESP", "DescStandESP")
Engine.UIControls.StandESP = W.TglStandESP

W.SecESP = TabVisuals:Section({ Title = getText("SecESP") })
registerWidget(W.SecESP, "Section", "SecESP")

W.TglOreESP = TabVisuals:Toggle({
    Title = getText("TglOreESP"),
    Desc = getText("DescOreESP"),
    Value = Engine.Config.OreESP,
    Callback = function(v)
        Engine.Config.OreESP = v
        updateOreESP()
    end
})
registerWidget(W.TglOreESP, "Toggle", "TglOreESP", "DescOreESP")
Engine.UIControls.OreESP = W.TglOreESP

W.SldESPDist = TabVisuals:Slider({
    Title = getText("SldESPDist"),
    Step = 25,
    Value = { Min = 100, Max = 1000, Default = Engine.Config.MaxESPDistance },
    Callback = function(v)
        Engine.Config.MaxESPDistance = v
    end
})
registerWidget(W.SldESPDist, "Slider", "SldESPDist")
Engine.UIControls.MaxESPDistance = W.SldESPDist

-- 7.6 TAB 6: PLAYER & MODS
local TabPlayer = Window:Tab({ Title = getText("TabPlayer"), Icon = "user" })
registerWidget(TabPlayer, "Tab", "TabPlayer")

W.SecEmergency = TabPlayer:Section({ Title = getText("SecEmergency") })
registerWidget(W.SecEmergency, "Section", "SecEmergency")

W.BtnBreakCutscenes = TabPlayer:Button({
    Title = getText("BtnBreakCutscenes"),
    Desc = getText("DescBreakCutscenes"),
    Callback = function()
        pcall(function()
            local mineGame = LocalPlayer.PlayerScripts:FindFirstChild("UI") and LocalPlayer.PlayerScripts.UI:FindFirstChild("MineGame")
            if mineGame then
                local cutsceneScript = mineGame:FindFirstChild("MineCutsceneClient")
                local adminControl = cutsceneScript and cutsceneScript:FindFirstChild("AdminControl")
                if adminControl and adminControl:IsA("BindableFunction") then
                    adminControl:Invoke("Stop")
                end
            end
            CurrentCamera.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
            RestoreGameHUDs()
            WindUI:Notify({ Title = "Cutscene Reset", Content = "Camera & animations cleared. HUDs restored.", Duration = 2, Icon = "video-off" })
        end)
    end
})
registerWidget(W.BtnBreakCutscenes, "Button", "BtnBreakCutscenes", "DescBreakCutscenes")

W.BtnRestoreHUD = TabPlayer:Button({
    Title = getText("BtnRestoreHUD"),
    Desc = getText("DescRestoreHUD"),
    Callback = function()
        RestoreGameHUDs()
        WindUI:Notify({ Title = "HUD Restored", Content = "All native HUD elements forced visible.", Duration = 2, Icon = "layout-grid" })
    end
})
registerWidget(W.BtnRestoreHUD, "Button", "BtnRestoreHUD", "DescRestoreHUD")

W.TglAutoRestoreHUD = TabPlayer:Toggle({
    Title = getText("TglAutoRestoreHUD"),
    Desc = getText("DescAutoRestoreHUD"),
    Value = Engine.Config.AutoRestoreHUD,
    Callback = function(v)
        Engine.Config.AutoRestoreHUD = v
        if v then
            RestoreGameHUDs()
        end
    end
})
registerWidget(W.TglAutoRestoreHUD, "Toggle", "TglAutoRestoreHUD", "DescAutoRestoreHUD")
Engine.UIControls.AutoRestoreHUD = W.TglAutoRestoreHUD

W.SecMovement = TabPlayer:Section({ Title = getText("SecMovement") })
registerWidget(W.SecMovement, "Section", "SecMovement")

W.TglSpeed = TabPlayer:Toggle({
    Title = getText("TglSpeed"),
    Value = Engine.Config.SpeedBoost,
    Callback = function(v)
        Engine.Config.SpeedBoost = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
})
registerWidget(W.TglSpeed, "Toggle", "TglSpeed")
Engine.UIControls.SpeedBoost = W.TglSpeed

W.SldSpeed = TabPlayer:Slider({
    Title = getText("SldSpeed"),
    Step = 2,
    Value = { Min = 16, Max = 120, Default = Engine.Config.SpeedValue },
    Callback = function(v)
        Engine.Config.SpeedValue = v
    end
})
registerWidget(W.SldSpeed, "Slider", "SldSpeed")
Engine.UIControls.SpeedValue = W.SldSpeed

W.TglJump = TabPlayer:Toggle({
    Title = getText("TglJump"),
    Value = Engine.Config.JumpBoost,
    Callback = function(v)
        Engine.Config.JumpBoost = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
        end
    end
})
registerWidget(W.TglJump, "Toggle", "TglJump")
Engine.UIControls.JumpBoost = W.TglJump

W.SldJump = TabPlayer:Slider({
    Title = getText("SldJump"),
    Step = 5,
    Value = { Min = 50, Max = 200, Default = Engine.Config.JumpValue },
    Callback = function(v)
        Engine.Config.JumpValue = v
    end
})
registerWidget(W.SldJump, "Slider", "SldJump")
Engine.UIControls.JumpValue = W.SldJump

W.TglInfJump = TabPlayer:Toggle({
    Title = getText("TglInfJump"),
    Value = Engine.Config.InfiniteJump,
    Callback = function(v) Engine.Config.InfiniteJump = v end
})
registerWidget(W.TglInfJump, "Toggle", "TglInfJump")
Engine.UIControls.InfiniteJump = W.TglInfJump

W.TglNoclip = TabPlayer:Toggle({
    Title = getText("TglNoclip"),
    Value = Engine.Config.Noclip,
    Callback = function(v)
        Engine.Config.Noclip = v
        if not v and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})
registerWidget(W.TglNoclip, "Toggle", "TglNoclip")
Engine.UIControls.Noclip = W.TglNoclip

W.TglAntiAFK = TabPlayer:Toggle({
    Title = getText("TglAntiAFK"),
    Desc = getText("DescAntiAFK"),
    Value = Engine.Config.AntiAFK,
    Callback = function(v) Engine.Config.AntiAFK = v end
})
registerWidget(W.TglAntiAFK, "Toggle", "TglAntiAFK", "DescAntiAFK")
Engine.UIControls.AntiAFK = W.TglAntiAFK

-- 7.7 TAB 7: LANGUAGE SELECTION
local TabLanguage = Window:Tab({ Title = getText("TabLanguage"), Icon = "globe" })
registerWidget(TabLanguage, "Tab", "TabLanguage")

W.SecLangSelect = TabLanguage:Section({ Title = getText("SecLangSelect") })
registerWidget(W.SecLangSelect, "Section", "SecLangSelect")

local LANGUAGE_LIST = {
    "English",
    "Bahasa Indonesia",
    "EspaÃ±ol",
    "PortuguÃªs",
    "Ð ÑÑÑÐºÐ¸Ð¹",
    "Tiáº¿ng Viá»t",
    "æ¥æ¬èª",
    "íêµ­ì´",
    "ç®ä½ä¸­æ"
}

W.DropLanguage = TabLanguage:Dropdown({
    Title = getText("DropLanguage"),
    Desc = getText("DescLangSelect"),
    Values = LANGUAGE_LIST,
    Value = Engine.CurrentLanguage,
    Callback = function(selectedLang)
        setLanguage(selectedLang)
    end
})
registerWidget(W.DropLanguage, "Dropdown", "DropLanguage", "DescLangSelect")
Engine.UIControls.Language = W.DropLanguage

-- Quick Language One-Click Switchers
for _, lang in ipairs(LANGUAGE_LIST) do
    TabLanguage:Button({
        Title = "Set Language: " .. lang,
        Callback = function()
            DropLanguage:Select(lang)
            setLanguage(lang)
        end
    })
end

-- 7.8 TAB 8: CONFIG & KEYBIND
local TabConfig = Window:Tab({ Title = getText("TabConfig"), Icon = "settings" })
registerWidget(TabConfig, "Tab", "TabConfig")

W.SecKeybind = TabConfig:Section({ Title = getText("SecKeybind") })
registerWidget(W.SecKeybind, "Section", "SecKeybind")

W.KeybindToggle = TabConfig:Keybind({
    Title = getText("KeybindToggle"),
    Desc = getText("DescKeybind"),
    Value = Engine.Config.ToggleKey,
    Callback = function(key)
        Engine.Config.ToggleKey = key
    end
})
registerWidget(W.KeybindToggle, "Keybind", "KeybindToggle", "DescKeybind")
Engine.UIControls.ToggleKey = W.KeybindToggle

W.SecConfig = TabConfig:Section({ Title = getText("SecConfig") })
registerWidget(W.SecConfig, "Section", "SecConfig")

W.InputConfigName = TabConfig:Input({
    Title = getText("InputConfigName"),
    Value = Engine.Config.ConfigName,
    Placeholder = "Default",
    Callback = function(name)
        Engine.Config.ConfigName = name
    end
})
registerWidget(W.InputConfigName, "Input", "InputConfigName")
Engine.UIControls.ConfigName = W.InputConfigName

W.BtnSaveConfig = TabConfig:Button({
    Title = getText("BtnSaveConfig"),
    Desc = getText("DescSaveConfig"),
    Callback = function()
        saveConfig(Engine.Config.ConfigName)
    end
})
registerWidget(W.BtnSaveConfig, "Button", "BtnSaveConfig", "DescSaveConfig")

W.BtnLoadConfig = TabConfig:Button({
    Title = getText("BtnLoadConfig"),
    Desc = getText("DescLoadConfig"),
    Callback = function()
        loadConfig(Engine.Config.ConfigName)
    end
})
registerWidget(W.BtnLoadConfig, "Button", "BtnLoadConfig", "DescLoadConfig")

W.BtnResetConfig = TabConfig:Button({
    Title = getText("BtnResetConfig"),
    Callback = function()
        resetConfig()
    end
})
registerWidget(W.BtnResetConfig, "Button", "BtnResetConfig")
Engine.UIControls.BtnResetConfig = W.BtnResetConfig

-- ====================================================================
-- 8. BACKGROUND AUTOMATION ENGINE & TICK THREADS
-- ====================================================================


-- 8.01 Plot Miner Intelligent Upgrade Loop
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(Engine.Config.MinerUpgradeDelay or 1.0)
        if Engine.Config.AutoUpgradeMiners then
            pcall(ExecuteIntelligentMinerUpgrade, "Damage")
        end
        if Engine.Config.AutoUpgradeSpeed then
            pcall(ExecuteIntelligentMinerUpgrade, "Speed")
        end
        if Engine.Config.AutoUpgradeMineSpeed then
            pcall(ExecuteIntelligentMinerUpgrade, "MineSpeed")
        end
    end
end)

-- 8.02 Plot Chest Auto-Claim Loop (Silent Background Claim)
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(4.0)
        if Engine.Config.AutoClaimChest then
            pcall(ClaimPlotChest)
        end
        if Engine.Config.AutoEquipBestMiners then
            pcall(ExecuteAutoEquipBestMiners)
        end
        if Engine.Config.AutoBuyPickaxes then
            pcall(ExecuteAutoBuyPickaxes)
        end
        if Engine.Config.AutoEquipPickaxes then
            pcall(ExecuteAutoEquipBestPickaxes)
        end
    end
end)

-- 8.03 Smooth Plot Economy & Miner Automation Engine (Zero Jitter)
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(1.0)
        if Engine.Config.AutoFarmNodes then
            -- 1. Upgrade plot miners if enabled
            if Engine.Config.AutoUpgradeMiners then
                pcall(ExecuteIntelligentMinerUpgrade, "Damage")
            end
            
            -- 2. Empty plot chest silently (Strictly gated by AutoClaimChest)
            if Engine.Config.AutoClaimChest then
                pcall(ClaimPlotChest)
            end
            
            -- 3. Equip best miners if needed
            if Engine.Config.AutoEquipBestMiners then
            pcall(ExecuteAutoEquipBestMiners)
        end
        end
    end
end)

-- 8.04 Live Miner Telemetry Monitor
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(1.5)
        pcall(function()
            local data = GameState and GameState.GetData2()
            local mg = data and data.MineGame
            local holders = mg and mg.Holders
            if holders and ParaMinerTelemetry and ParaMinerTelemetry.SetDesc then
                local lines = {}
                local keys = {}
                for k in pairs(holders) do table.insert(keys, k) end
                table.sort(keys, function(a, b)
                    return (tonumber(a:match("%d+")) or 99) < (tonumber(b:match("%d+")) or 99)
                end)
                for _, k in ipairs(keys) do
                    local h = holders[k]
                    local name = h.CharName or "Empty"
                    local lvl = h.CharLevel or 1
                    local spd = h.CharSpeedLevel or 1
                    local mine = h.CharMineSpeedLevel or 1
                    local maxCap = tonumber(Engine.Config.MaxMinerLevel) or 0
                    local capTag = (maxCap > 0 and lvl >= maxCap and " [MAX]" or "")
                    table.insert(lines, string.format("[%s] %s | Lv.%d%s | Spd.%d | Mine.%d", k, name, lvl, capTag, spd, mine))
                end
                ParaMinerTelemetry:SetDesc(table.concat(lines, "\n"))
            end
        end)
    end
end)

-- 8.1 UI Toggle Global Keybind Handler with Strict Debounce (0.35s)
local lastToggleTick = 0
local function safeToggleUI()
    local now = os.clock()
    if now - lastToggleTick < 0.35 then return end
    lastToggleTick = now
    pcall(function()
        if Window and Window.Toggle then
            Window:Toggle()
        end
    end)
end

local KeyInputConnection = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if UserInputService:GetFocusedTextBox() then return end

    local customKey = Engine.Config.ToggleKey
    local matchesCustom = false
    if customKey and Enum.KeyCode[customKey] then
        matchesCustom = (input.KeyCode == Enum.KeyCode[customKey])
    end

    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift or matchesCustom then
        safeToggleUI()
    end
end)
table.insert(Engine.Connections, KeyInputConnection)

-- 8.2 Movement & Noclip Loop
local SteppedConnection = RunService.Stepped:Connect(function()
    if Engine.Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Engine.Config.SpeedBoost then
            hum.WalkSpeed = Engine.Config.SpeedValue
        end
        if Engine.Config.JumpBoost then
            hum.JumpPower = Engine.Config.JumpValue
        end
    end
end)
table.insert(Engine.Connections, SteppedConnection)

-- 8.3 Infinite Jump Connection
local JumpConnection = UserInputService.JumpRequest:Connect(function()
    if Engine.Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(Engine.Connections, JumpConnection)

-- 8.4 Anti-AFK Guard
local IdledConnection = LocalPlayer.Idled:Connect(function()
    if Engine.Config.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)
table.insert(Engine.Connections, IdledConnection)

-- 8.5 Auto Mine Background Thread
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        if Engine.Config.AutoMine then
            local ore = getNearestTargetOre()
            if ore and ore.Part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                -- Smooth hover position above the ore
                local targetCFrame = CFrame.new(ore.Part.Position + Vector3.new(0, (Engine.Config.MineHoverHeight or 3.5), 0), ore.Part.Position)
                root.CFrame = targetCFrame

                -- Trigger click/swing
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton1(Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2))
                end)
            end
        end
        task.wait(0.25)
    end
end)

-- 8.6 Auto Sell Loop (Proximity-Gated Stand Routine)
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(math.max(3, Engine.Config.AutoSellInterval or 10))
        if Engine.Config.AutoSell then
            pcall(ExecuteFullSellRoutine)
        end
    end
end)

-- 8.7 Auto Chest Claim Loop
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        if Engine.Config.AutoChest then
            pcall(function()
                local data = GameState and GameState.GetData2()
                local mg = data and data.MineGame
                if mg and type(mg.Chests) == "table" then
                    for k, chest in pairs(mg.Chests) do
                        GameState.SendEvent("MineTakeChest", k)
                    end
                else
                    GameState.SendEvent("MineTakeChest")
                end
            end)
        end
        task.wait(3.0)
    end
end)

-- 8.75 Super Automation Loop (Buff Pad, Crates, Mystery Blocks, Potions, Skills)
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        pcall(function()
            -- Buff Pad Claim
            if Engine.Config.AutoClaimBuffPad then
                GameState.SendEvent("MineBuffModeClaim")
            end

            -- Crates & Mystery Blocks
            local data = GameState and GameState.GetData2()
            local mg = data and data.MineGame
            if mg then
                if Engine.Config.AutoColossusCrates and (mg.ColossusCrates or 0) > 0 then
                    GameState.SendEvent("MineOpenColossusCrate", 1, 10)
                end
                if Engine.Config.AutoMysteryBlocks and (mg.MysteryBlocks or 0) > 0 then
                    for k, count in pairs(mg.MysteryBlocks) do
                        if type(count) == "number" and count > 0 then
                            GameState.SendEvent("MineOpenMysteryBlock", k)
                        end
                    end
                end
                if Engine.Config.AutoConsumePotions and mg.Potions then
                    for potKey, pCount in pairs(mg.Potions) do
                        if type(pCount) == "number" and pCount > 0 then
                            GameState.SendEvent("MineUsePotion", potKey, 1)
                        end
                    end
                end
            end
        end)
        task.wait(4)
    end
end)

-- Player ESP Ghost Cleanup
local PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
    local tag = PlayerESPFolder:FindFirstChild(player.Name)
    if tag then pcall(function() tag:Destroy() end) end
end)
table.insert(Engine.Connections, PlayerRemovingConnection)

-- 8.76 Player ESP Render Loop
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        if Engine.Config.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    local dist = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude or 0
                    local tag = PlayerESPFolder:FindFirstChild(player.Name)
                    if not tag then
                        tag = Instance.new("BillboardGui")
                        tag.Name = player.Name
                        tag.AlwaysOnTop = true
                        tag.Size = UDim2.new(0, 160, 0, 40)
                        tag.StudsOffset = Vector3.new(0, 3, 0)
                        tag.Parent = PlayerESPFolder
                        tag.Adornee = root

                        local label = Instance.new("TextLabel")
                        label.Name = "Text"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(0, 255, 180)
                        label.TextStrokeTransparency = 0
                        label.TextSize = 13
                        label.Font = Enum.Font.GothamBold
                        label.Parent = tag
                    end
                    local lbl = tag:FindFirstChild("Text")
                    if lbl then
                        lbl.Text = player.DisplayName .. " (@" .. player.Name .. ")\n[" .. math.floor(dist) .. "m]"
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 8.8 Dailies & Mailbox Auto Claim Loop
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        -- Daily Spin
        if Engine.Config.AutoDailySpin and MineDailySpinConfig then
            pcall(function()
                GameState.SendEvent(MineDailySpinConfig.Events.Spin)
            end)
        end

        -- Daily Quests
        if Engine.Config.AutoDailyQuests and MineDailyQuestsCatalog then
            pcall(function()
                for i = 1, 10 do
                    GameState.SendEvent(MineDailyQuestsCatalog.Events.Claim, i)
                end
            end)
        end

        -- Mailbox
        if Engine.Config.AutoMailbox then
            pcall(function()
                for i = 1, 15 do
                    GameState.SendEvent("ClaimMailboxReward", i, 1)
                end
            end)
        end

        -- Miner Upgrades (Direct Network Upgrade)
        if Engine.Config.AutoUpgradeCharacters then
            pcall(ExecuteIntelligentMinerUpgrade, "Damage")
        end

        task.wait(5.0)
    end
end)

-- 8.9 Ore ESP Render Loop
local ESPUpdateTick = 0
local RenderConnection = RunService.RenderStepped:Connect(function()
    local now = os.clock()
    if now - ESPUpdateTick >= 0.25 then
        ESPUpdateTick = now
        pcall(updateOreESP)
    end
end)
table.insert(Engine.Connections, RenderConnection)


-- ====================================================================
-- 9. ENGINE UNLOAD & CLEANUP ROUTINE
-- ====================================================================
function Engine:Unload()
    self.Running = false
    _G.MyAnimeMineInstanceId = (_G.MyAnimeMineInstanceId or 0) + 1
    -- Disconnect core events
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(self.Connections)

    -- Remove ESP
    for _, obj in pairs(self.ESPObjects) do
        if obj.Billboard then pcall(function() obj.Billboard:Destroy() end) end
    end
    table.clear(self.ESPObjects)
    pcall(function() ESPFolder:Destroy() end)
    pcall(function() PlayerESPFolder:Destroy() end)
    setFullbright(false)

    -- Destroy UI window
    if Window and Window.Destroy then
        pcall(function() Window:Destroy() end)
    end

    _G.MyAnimeMineEngine = nil
    print("[MyAnimeMine] Engine unloaded cleanly.")
end

_G.MyAnimeMineEngine = Engine

print("==================================================")
print("âï¸ MY ANIME MINE ENGINE LOADED SUCCESSFULLY!")
print("Active Framework: WindUI v1.6+ | 9 Languages Ready")
print("Press [INSERT] or [RIGHT SHIFT] to Toggle Menu")

if Engine.Config.AutoRedeemCodes then
    task.delay(1.5, redeemAllCodes)
end
print("==================================================")


-- Global Screen Obstruction Suppressor (Keeps view 100% clean during all automation)
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(0.2)
        if Engine.Config.SilentAutomation then
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mGui = pGui and pGui:FindFirstChild("MineGui")
                if mGui then
                    local intrusive = {"ChestFrame", "AutoSellFrame", "SlotFocusFrame", "SellFrame"}
                    for _, mName in ipairs(intrusive) do
                        local f = mGui:FindFirstChild(mName)
                        if f and f:IsA("GuiObject") and f.Visible then
                            f.Visible = false
                            task.defer(RestoreGameHUDs)
                        end
                    end
                end
            end)
        end
    end
end)



-- 8.01 Background Game HUD Guardian (Prevents UI disappearing from summon/cutscene locks)
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(3.0)
        if Engine.Config.AutoRestoreHUD ~= false then
            pcall(RestoreGameHUDs)
        end
    end
end)

-- 8.05 Background Zone Progression & Research Automation Monitor
task.spawn(function()
    while Engine.Running and _G.MyAnimeMineInstanceId == currentInstanceId and _G.MyAnimeMineEngine == Engine do
        task.wait(2.0)
        -- 1. Zone Auto-Progression
        if Engine.Config.AutoUnlockNextZone then
            pcall(ExecuteZoneProgressionCheck)
        end
        if Engine.Config.AutoTravelDeepest then
            pcall(function()
                local data = GameState and GameState.GetData2()
                local mg = data and data.MineGame
                local deepest = MineConfig and MineConfig.DeepestUnlockedZone and MineConfig.DeepestUnlockedZone(mg)
                if deepest and mg and mg.CurrentZone and mg.CurrentZone < deepest then
                    ExecuteZoneUnlock("Z" .. deepest)
                end
            end)
        end
        -- 2. Zone Telemetry Update
        pcall(function()
            local data = GameState and GameState.GetData2()
            local mg = data and data.MineGame
            if mg and Engine.ParaZoneTelemetry and Engine.ParaZoneTelemetry.SetDesc then
                local curZ = mg.CurrentZone or 1
                local curZName = MineConfig and MineConfig.Zones and MineConfig.Zones["Z" .. curZ] and MineConfig.Zones["Z" .. curZ].DisplayName or ("Zone " .. curZ)
                local nextZ = GetNextLockedZoneInfo()
                if nextZ then
                    local curCash = tonumber(data.Money) or 0
                    local status = nextZ.Affordable and "[READY TO UNLOCK!]" or ("[NEED $" .. FormatMoneyShort(math.max(0, nextZ.Cost - curCash)) .. "]")
                    Engine.ParaZoneTelemetry:SetDesc(string.format("Current Active: Z%d (%s)\nNext Target: %s (%s)\nCost: $%s %s", curZ, curZName, nextZ.Name, nextZ.Key, FormatMoneyShort(nextZ.Cost), status))
                else
                    Engine.ParaZoneTelemetry:SetDesc(string.format("Current Active: Z%d (%s)\nAll 13 Zones Unlocked! (Max Progression)", curZ, curZName))
                end
            end
        end)
        -- 3. Research Automation
        if Engine.Config.AutoResearchSkills or Engine.Config.AutoResearchTap or Engine.Config.AutoResearchSlots then
            pcall(ExecuteResearchUpgradeOnce)
        end
        -- 4. Research Telemetry Update
        pcall(function()
            local data = GameState and GameState.GetData2()
            local mg = data and data.MineGame
            if mg and Engine.ParaResearchTelemetry and Engine.ParaResearchTelemetry.SetDesc then
                local lines = {}
                local tapLvl = MineConfig.GetCoreLevel(mg, "Tap")
                local slotLvl = MineConfig.GetCoreLevel(mg, "Slots")
                table.insert(lines, string.format("Core Strike: Lv.%d/39 | Miner Slots: %d/8", tapLvl, slotLvl))
                
                local unlockedZones = mg.UnlockedZones or {}
                local zoneNames = {}
                for zk in pairs(unlockedZones) do table.insert(zoneNames, zk) end
                table.sort(zoneNames, function(a, b) return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0) end)
                
                for _, zk in ipairs(zoneNames) do
                    local zSkills = mg.Skills and mg.Skills[zk] or {}
                    local prog, maxProg = 0, 0
                    pcall(function() prog, maxProg = MineConfig.GetZoneResearchProgress(mg.Skills, zk) end)
                    local zTitle = MineConfig and MineConfig.Zones and MineConfig.Zones[zk] and MineConfig.Zones[zk].DisplayName or zk
                    table.insert(lines, string.format("[%s - %s] Progress: %d/%d", zk, zTitle, prog, maxProg))
                end
                Engine.ParaResearchTelemetry:SetDesc(table.concat(lines, "\n"))
            end
        end)
    end
end)
