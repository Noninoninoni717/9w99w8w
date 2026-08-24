

local _buterFont = nil
pcall(function()
    _buterFont = Font.fromEnum(Enum.Font.GothamSemibold)
end)
if not _buterFont then
    _buterFont = Font.new("rbxasset://fonts/families/GothamSSm.json")
end

local _TRIDENT_URL = "https://github.com/sametexe001/luas/raw/refs/heads/main/imgs/trident.jpg"

local function _loadURLImage(imgLabel, url, fallbackColor)
    task.spawn(function()
        local ok = pcall(function()
            local data = game:HttpGet(url)
            local fname = "buter_img_trident.jpg"
            writefile(fname, data)
            local asset = getcustomasset(fname)
            imgLabel.Image = asset
            imgLabel.BackgroundTransparency = 0
            imgLabel.ImageTransparency = 0
        end)
        if not ok or imgLabel.Image == "" then
            pcall(function()
                if imgLabel and imgLabel.Parent then
                    imgLabel.Parent.BackgroundColor3 = fallbackColor or Color3.fromRGB(40, 20, 28)
                    imgLabel.BackgroundColor3 = fallbackColor or Color3.fromRGB(40, 20, 28)
                    imgLabel.BackgroundTransparency = 0
                end
            end)
        end
    end)
end

-- Key system removed (not needed for personal use)
local _ksPassed   = true
local _verifiedKey = ""
local _selectedScript = nil

local _hxSetEnabled = nil

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService= game:GetService("CollectionService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local GuiInset         = game:GetService("GuiService"):GetGuiInset()
local Mouse            = LocalPlayer:GetMouse()

local function GetCamera()
    local cam = workspace.CurrentCamera
    if cam and cam:IsA("Camera") then return cam end
    return nil
end

local function SafeWorldToViewport(cam, pos)
    if not cam or not pcall(function() return cam:IsA("Camera") end) or not cam:IsA("Camera") then
        cam = workspace.CurrentCamera
    end
    if not cam then return nil, false end
    local ok, sp = pcall(function() return cam:WorldToViewportPoint(pos) end)
    if not ok then return nil, false end
    return sp, sp.Z > 0
end

local function GetMyPos()
    local ok,pos = pcall(function()
        local ignoreFolder = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
        local localChar = ignoreFolder and ignoreFolder:FindFirstChild("LocalCharacter")
        if localChar then
            local ref = localChar:FindFirstChild("Middle") or localChar:FindFirstChild("Top")
            if ref then return ref.Position end
        end
        return nil
    end)
    return (ok and pos) or nil
end

local S = {

    BigHeadsEnabled=false, HeadSize=3, HeadTransparency=0, TeamCheck=false,
    ExpandPart="Head", BlinkEnabled=false, _blinkState=0, _blinkTimer=0, BlinkSpeed=0.5,

    FovCircleVisible=false, FovCircleRadius=150, FovCircleFilled=false, FovShape="Circle",

    ArmChamsHL=false, ArmChamsColor=Color3.fromRGB(255, 182, 210), ArmChamsTransparency=0,
    FovCircleColor=Color3.fromRGB(255,255,255),
    FovCircleOutline=false,
    FovCircleOutlineColor=Color3.new(1,1,1),
    FovCircleThickness=2,

    ObjEspEnabled=false,
    ObjEspAllowed={},
    ObjEspFontSize=15,
    ObjEspFont=Drawing.Fonts.Monospace,
    ObjEspNameColor={Color3.new(1,1,1),1},
    ObjEspNameOutline=false,
    ObjEspNameOutlineColor=Color3.new(0,0,0),
    OreDistEnabled=false,
    OreCounterEnabled=false,

    EspEnabled=false,
    EspBox=false,
    EspDist=false, EspItem=false,
    VisCheckEnabled=false,
    EspMaxDist=5000,
    EspBoxColor=Color3.fromRGB(255,255,255),
    EspNameColor=Color3.fromRGB(255,255,255),
    EspDistColor=Color3.fromRGB(255,255,255),
    EspItemColor=Color3.fromRGB(255,255,255),

    OreEspEnabled=false, OreOpacity=0.5,
    CrateEspEnabled=false, BagEspEnabled=false,

    NitrateEspEnabled=false, NitrateEspColor=Color3.fromRGB(255,255,255),
    IronEspEnabled=false,    IronEspColor=Color3.fromRGB(255,215,0),
    StoneEspEnabled=false,   StoneEspColor=Color3.fromRGB(100,180,255),

    CrosshairEnabled=false, CrosshairRainbow=false,
    CrosshairColor=Color3.fromRGB(255,255,255), CrosshairThickness=1, CrosshairLength=8,
    CrosshairOpacity=1, CrosshairXOffset=0, CrosshairYOffset=0,
    CrosshairSpin=false, CrosshairSpinSpeed=2,

    HandEnabled=false, HandRainbow=false, HandColor=Color3.fromRGB(0,59,143),
    HandMaterial=Enum.Material.SmoothPlastic, HandOpacity=0,
    SleeveEnabled=false, SleeveRainbow=false, SleeveColor=Color3.fromRGB(163,162,165),
    SleeveMaterial=Enum.Material.Fabric, SleeveOpacity=0,

    FovEnabled=false, FovValue=80,
    RemoveClouds=false, RemoveLeaves=false, RemoveGrass=false, WaterOpt=false,
    FlatTextures=false,

    SkyboxEnabled=false, SkyboxChoice="SpongeBob Sky",

    ColorsEnabled=false, ColorBrightness=0, ColorContrast=0, ColorSaturation=0,
    ThemeColor=Color3.fromRGB(255, 182, 210),

    WatermarkEnabled=false,

    HeadSoundEnabled=false, BodySoundEnabled=false, WoodSoundEnabled=false,

    XrayEnabled=false,

    GrassColorEnabled=false, GrassColor=Color3.fromRGB(93,111,55),
    CloudColorEnabled=false, CloudColor=Color3.fromRGB(255,255,255),

    TracersEnabled=false, TracerColor=Color3.fromRGB(255,255,255), TracerOrigin="Bottom",
    TracerThickness=1, TracerTransparency=0.3,

    CompassEnabled=false,

    SessionTimerEnabled=false,

    AntiAfkEnabled=false,

    PlayerNotifEnabled=false,

    NightModeEnabled=false,

    CrosshairRainbowSpeed=1,
}

local _SoundService = game:GetService("SoundService")

local _tridentSounds = {
    ["Default Headshot Hit"]="rbxassetid://9119561046", ["Default Body Hit"]="rbxassetid://9114487369",
    ["Default Wood Hit"]="rbxassetid://9125573608",     ["Default Rock Hit"]="rbxassetid://9118630389",
    Neverlose="rbxassetid://8726881116",   Gamesense="rbxassetid://4817809188",
    One="rbxassetid://7380502345",         Bell="rbxassetid://6534947240",
    Rust="rbxassetid://1255040462",        TF2="rbxassetid://2868331684",
    Slime="rbxassetid://6916371803",       ["Among Us"]="rbxassetid://5700183626",
    Minecraft="rbxassetid://4018616850",   ["CS:GO"]="rbxassetid://6937353691",
    Saber="rbxassetid://8415678813",       Baimware="rbxassetid://3124331820",
    Osu="rbxassetid://7149255551",         ["TF2 Critical"]="rbxassetid://296102734",
    Bat="rbxassetid://3333907347",         ["Call of Duty"]="rbxassetid://5952120301",
    Bubble="rbxassetid://6534947588",      Pick="rbxassetid://1347140027",
    Pop="rbxassetid://198598793",          Bruh="rbxassetid://4275842574",
    Bamboo="rbxassetid://3769434519",      Crowbar="rbxassetid://546410481",
    Weeb="rbxassetid://6442965016",        Beep="rbxassetid://8177256015",
    Bambi="rbxassetid://8437203821",       Stone="rbxassetid://3581383408",
    ["Old Fatality"]="rbxassetid://6607142036", Click="rbxassetid://8053704437",
    Ding="rbxassetid://7149516994",        Snow="rbxassetid://6455527632",
    Laser="rbxassetid://7837461331",       Mario="rbxassetid://2815207981",
    Steve="rbxassetid://4965083997",       Snowdrake="rbxassetid://7834724809",
}
local _tridentSoundList = {
    "Default Headshot Hit","Default Body Hit","Default Wood Hit","Default Rock Hit",
    "Neverlose","Gamesense","One","Bell","Rust","TF2","Slime","Among Us","Minecraft",
    "CS:GO","Saber","Baimware","Osu","TF2 Critical","Bat","Call of Duty","Bubble",
    "Pick","Pop","Bruh","Bamboo","Crowbar","Weeb","Beep","Bambi","Stone",
    "Old Fatality","Click","Ding","Snow","Laser","Mario","Steve","Snowdrake",
}

local ChamStorage = CoreGui:FindFirstChild("TridentVisuals") or Instance.new("Folder")
ChamStorage.Name = "TridentVisuals"; ChamStorage.Parent = CoreGui

local OreConfigs = {
    ["Nitrate Ore"] = {FillColor=Color3.fromRGB(255,255,255), Part1Color=Color3.fromRGB(248,248,248), Part2Color=Color3.fromRGB(72,72,72)},
    ["Iron Ore"]    = {FillColor=Color3.fromRGB(255,215,0),   Part1Color=Color3.fromRGB(199,172,120), Part2Color=Color3.fromRGB(72,72,72)},
    Cobblestone     = {FillColor=Color3.fromRGB(100,100,100), Part1Color=Color3.fromRGB(72,72,72),    Part2Color=nil},
}

local activeOres={};local activeCrates={};local activeBags={}

local function IdentifyOre(model)
    if model.Name ~= "Model" then return nil end
    local children = model:GetChildren()
    for _, configName in pairs({"Nitrate Ore","Iron Ore","Cobblestone"}) do
        local config = OreConfigs[configName]
        local p1Match, p2Match = false, (configName == "Cobblestone")
        for _, child in pairs(children) do
            if child:IsA("MeshPart") or child:IsA("Part") then
                if child.Color == config.Part1Color then p1Match = true
                elseif config.Part2Color and child.Color == config.Part2Color then p2Match = true end
            end
        end
        if p1Match and p2Match then return config end
    end
    return nil
end

local function ApplyOreCham(model, config)
    local hl = model:FindFirstChild("OreHL")
    if not hl then
        hl = Instance.new("Highlight"); hl.Name = "OreHL"; hl.Adornee = model
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = model
    end
    hl.Enabled = S.OreEspEnabled
    hl.FillColor = config.FillColor; hl.FillTransparency = 1 - S.OreOpacity
    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.OutlineTransparency = 0
    activeOres[model] = hl
end

local function IsTargetCrate(model)
    if not model:IsA("Model") then return false end
    if model.Name == "InteriorContainer" then return false end
    if model:FindFirstChild("Container-WithDoor") then return false end
    if model:FindFirstChild("State") then return false end
    if model.Name:find("MO-fence") then return false end
    if LocalPlayer.Character and model:IsDescendantOf(LocalPlayer.Character) then return false end
    local ch = {}
    for _,c in pairs(model:GetChildren()) do ch[c.Name] = true end
    return (ch['Bottom'] and ch['Top']) or (ch['Body'] and ch['Wheel'])
        or (ch['box'] and ch['trash']) or (ch['Dispenser'] and ch['Machine'])
end

local function ApplyCrateCham(model)
    if not IsTargetCrate(model) then return end
    local id = model:GetDebugId()
    local hl = ChamStorage:FindFirstChild(id)
    if not hl then
        hl = Instance.new("Highlight"); hl.Name = id; hl.Adornee = model
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = ChamStorage
    end
    hl.Enabled = S.CrateEspEnabled
    hl.FillColor = Color3.fromRGB(0,255,127); hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.OutlineTransparency = 0
    activeCrates[model] = hl
end

local function IsTargetBag(model)
    if not model:IsA("Model") then return false end
    if #model:GetChildren() ~= 2 then return false end
    local p1 = model:FindFirstChild("Part")
    if p1 and p1:IsA("BasePart") then
        local s = p1.Size
        if s.Y < 3 and s.X < 3 and s.Z < 3 then return true end
    end
    return false
end
-- duplicate IsTargetBag removed

local bagEspDrawings = {}

local function ApplyBagCham(model)
    if not IsTargetBag(model) then return end
    task.defer(function()
        if not model:IsDescendantOf(workspace) then return end
        if bagEspDrawings[model] then return end
        local part = model:FindFirstChild("Part")
        if not part then return end
        local nameD = Drawing.new("Text")
        nameD.Center       = true
        nameD.Visible      = false
        nameD.Font         = Drawing.Fonts.Monospace
        nameD.Size         = 15
        nameD.Color        = Color3.fromRGB(0, 200, 80)
        nameD.Outline      = true
        nameD.OutlineColor = Color3.new(0, 0, 0)
        nameD.Transparency = 1
        bagEspDrawings[model] = { name=nameD, part=part }
        model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                pcall(function() nameD:Remove() end)
                bagEspDrawings[model] = nil
                activeBags[model] = nil
            end
        end)

        activeBags[model] = true
    end)
end

local entityFingerprints = {}
pcall(function()
    local shared = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
    local entities = shared and shared:FindFirstChild("entities")
    if entities then
        for _, v in ipairs(entities:GetChildren()) do
            local model = v:FindFirstChild("Model")
            if model and model.PrimaryPart then
                entityFingerprints[v.Name] = {
                    CollisionGroup = model.PrimaryPart.CollisionGroup,
                    Material = model.PrimaryPart.Material,
                    Color = model.PrimaryPart.Color
                }
            end
        end
    end
end)

local function identify_world_object(model)
    if model.ClassName ~= "Model" then return false, false end

    local meshpart = model:FindFirstChildOfClass("MeshPart")
    if meshpart and meshpart.MeshId == "rbxassetid://12939036056" then
        if #model:GetChildren() == 1 then
            return "Stone", model:GetChildren()[1]
        else
            for _, part in ipairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    if part.Color == Color3.fromRGB(248,248,248) then return "Nitrate", part
                    elseif part.Color == Color3.fromRGB(199,172,120) then return "Iron", part end
                end
            end
        end
    end
    if not model.PrimaryPart then return false, false end
    local primpart = model.PrimaryPart
    for name, entity in pairs(entityFingerprints) do
        if entity.Color == primpart.Color and entity.Material == primpart.Material
            and entity.CollisionGroup == primpart.CollisionGroup then
            return name, primpart
        end
    end
    return false, false
end

local objEspDrawings = {}

local oreCounterDrawings = {
    bg       = Drawing.new("Square"),
    nitrate  = Drawing.new("Text"),
    iron     = Drawing.new("Text"),
    stone    = Drawing.new("Text"),
    total    = Drawing.new("Text"),
}
do
    local bg = oreCounterDrawings.bg
    bg.Filled = true; bg.Color = Color3.new(0,0,0)
    bg.Transparency = 0.5; bg.Visible = false; bg.ZIndex = 1

    local function initCounterText(d, col)
        d.Font = Drawing.Fonts.Monospace
        d.Size = 10; d.Color = col
        d.Outline = true; d.OutlineColor = Color3.new(0,0,0)
        d.Transparency = 1; d.Visible = false; d.ZIndex = 2
    end
    initCounterText(oreCounterDrawings.nitrate, Color3.fromRGB(255,255,255))
    initCounterText(oreCounterDrawings.iron,    Color3.fromRGB(255,215,0))
    initCounterText(oreCounterDrawings.stone,   Color3.fromRGB(100,180,255))
    initCounterText(oreCounterDrawings.total,   Color3.fromRGB(200,200,200))
end

local function obj_esp_create(model)
    local espname, mainpart = identify_world_object(model)
    if not (espname and mainpart) then return end

    local nameD  = Drawing.new("Text")
    local distD  = Drawing.new("Text")

    nameD.Center = true; nameD.Visible = false; nameD.Text = espname
    distD.Center = true; distD.Visible = false

    objEspDrawings[model] = {
        name     = nameD,
        dist     = distD,
        mainpart = mainpart,
        espname  = espname,
    }
end

local function obj_esp_destroy(model)
    local obj = objEspDrawings[model]
    if not obj then return end
    obj.name:Remove()
    obj.dist:Remove()
    objEspDrawings[model] = nil
end

task.spawn(function()
  while true do
    task.wait(0.1)
    if not S.OreCounterEnabled then
        oreCounterDrawings.bg.Visible      = false
        oreCounterDrawings.nitrate.Visible = false
        oreCounterDrawings.iron.Visible    = false
        oreCounterDrawings.stone.Visible   = false
        oreCounterDrawings.total.Visible   = false
        return
    end

    local counts = {["Nitrate Ore"]=0, ["Iron Ore"]=0, Cobblestone=0}
    for model, hl in pairs(activeOres) do
        if model and model.Parent and hl and hl.Enabled then

            local fc = hl.FillColor
            if fc == Color3.fromRGB(255,255,255) then counts["Nitrate Ore"] = counts["Nitrate Ore"]+1
            elseif fc == Color3.fromRGB(255,215,0) then counts["Iron Ore"] = counts["Iron Ore"]+1
            elseif fc == Color3.fromRGB(100,100,100) then counts.Cobblestone = counts.Cobblestone+1
            end
        end
    end

    local cam = GetCamera()
    local vsize = cam and cam.ViewportSize or Vector2.new(1920,1080)
    local x = vsize.X - 160
    local y = 10
    local lineH = 18

    oreCounterDrawings.nitrate.Text = ("Nitrate:  %d"):format(counts["Nitrate Ore"])
    oreCounterDrawings.iron.Text    = ("Iron:     %d"):format(counts["Iron Ore"])
    oreCounterDrawings.stone.Text   = ("Stone:    %d"):format(counts.Cobblestone)
    oreCounterDrawings.total.Text   = ("Total:    %d"):format(counts["Nitrate Ore"]+counts["Iron Ore"]+counts.Cobblestone)

    oreCounterDrawings.nitrate.Position = Vector2.new(x, y)
    oreCounterDrawings.iron.Position    = Vector2.new(x, y + lineH)
    oreCounterDrawings.stone.Position   = Vector2.new(x, y + lineH*2)
    oreCounterDrawings.total.Position   = Vector2.new(x, y + lineH*3 + 4)

    oreCounterDrawings.bg.Position = Vector2.new(x - 8, y - 4)
    oreCounterDrawings.bg.Size     = Vector2.new(150, lineH*4 + 14)

    oreCounterDrawings.bg.Visible      = true
    oreCounterDrawings.nitrate.Visible = true
    oreCounterDrawings.iron.Visible    = true
    oreCounterDrawings.stone.Visible   = true
    oreCounterDrawings.total.Visible   = true
  end
end)

local function CheckAndTagModel(model)
    if not model:IsA("Model") then return end
    ApplyCrateCham(model)
    ApplyBagCham(model)
    task.delay(0.5, function()
        if not model or not model.Parent then return end
        local ore = IdentifyOre(model)
        if ore then ApplyOreCham(model, ore) end
    end)
    obj_esp_create(model)
end

local _charCache = {}; local _charCacheTime = {}

local function GetIgnoreFolder()
    local c = workspace:FindFirstChild("Const")
    return c and c:FindFirstChild("Ignore")
end

local function GetTridentChar(plr)
    local now = tick()
    if _charCache[plr] and _charCacheTime[plr] and (now-_charCacheTime[plr])<0.5 then
        local cached = _charCache[plr]
        if cached and cached.Parent then return cached end
    end
    local found = nil
    local ignoreFolder = GetIgnoreFolder()
    if ignoreFolder then
        local uid=tostring(plr.UserId); local dname=plr.DisplayName; local uname=plr.Name
        for _, child in ipairs(ignoreFolder:GetChildren()) do
            if child:IsA("Model") and child ~= ignoreFolder:FindFirstChild("LocalCharacter") then
                if child.Name==dname or child.Name==uname or child.Name==uid then
                    if child:FindFirstChildOfClass("Humanoid") or child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Middle") then
                        found=child; break
                    end
                end
            end
        end
        if not found then
            for _, child in ipairs(ignoreFolder:GetChildren()) do
                if child:IsA("Model") then
                    local uidVal=child:FindFirstChild("UserId") or child:FindFirstChild("PlayerID") or child:FindFirstChild("ID")
                    if uidVal and tostring(uidVal.Value)==uid then found=child; break end
                end
            end
        end
    end
    if not found then local c=plr.Character; if c and c.Parent then found=c end end
    if not found then
        local c=workspace:FindFirstChild(plr.Name) or workspace:FindFirstChild(plr.DisplayName)
        if c and c:IsA("Model") then found=c end
    end
    _charCache[plr]=found; _charCacheTime[plr]=now
    return found
end

local _tridentItems = {

    "Blunderbuss","Bow","Crossbow","Pipe Pistol","C9","Gauss Rifle",
    "Handmade Assault Rifle","Pipe SMG","Pump Shotgun","RPG-22","SCAR",
    "UZI SMG","M4A1","Energy Rifle","Flintlock","Musket","Revolver",

    "Hammer","Pickaxe","Axe","Hatchet","Machete","Knife","Bat","Crowbar",
    "Wrench","Spear","Sword","Club","Bone Club","Stone Axe","Metal Pipe",

    "Fishing Rod","Flashlight","Torch","Lantern","Rope","Bandage",
    "Med Kit","Food","Water","Can","Bottle","Lighter","Matches",
    "Light Stick","Flare","Smoke Grenade","Grenade","Molotov",
    "Building Hammer","Repair Hammer","Upgrade Hammer",

    "Stone","Rock","Stick","Branch","Plank","Metal","Scrap",
}
local _itemLookup = {}
for _, v in ipairs(_tridentItems) do _itemLookup[v:lower()] = v end

local function _getWeapon(model)
    if not model then return "None" end

    local ok1, res1 = pcall(function()
        local entry = _getEntry(model)
        if not entry then return nil end
        if entry.equippedItem and entry.equippedItem.id then
            local id = tostring(entry.equippedItem.id)
            if id ~= "" and id ~= "nil" then return id end
        end
        if entry.handModel and entry.handModel.Name then
            local n = entry.handModel.Name
            if n ~= "" and n ~= "Handle" and n ~= "HandModel" then return n end
        end
        return nil
    end)
    if ok1 and res1 then return res1 end

    local tool = model:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end

    return "None"
end

local function IsVisible(part)
    local cam=GetCamera(); if not cam or not part then return false end
    local origin=cam.CFrame.Position; local dir=part.Position-origin
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
    local myChar=LocalPlayer.Character
    local ignoreFolder=GetIgnoreFolder()
    local myTridentChar=ignoreFolder and ignoreFolder:FindFirstChild("LocalCharacter")
    local excludes={}
    if myChar then excludes[#excludes+1]=myChar end
    if myTridentChar then excludes[#excludes+1]=myTridentChar end
    rp.FilterDescendantsInstances=excludes
    local result=workspace:Raycast(origin,dir,rp)
    if not result then return true end
    return result.Instance and (result.Instance:IsDescendantOf(part.Parent) or result.Instance==part)
end

local function IsOnTeam(plr)
    if not S.TeamCheck then return false end
    return plr.Team and plr.Team==LocalPlayer.Team
end

local _Skyboxes = {
    ["Purple Nebula"] = {Bk="rbxassetid://159454299",Dn="rbxassetid://159454296",Ft="rbxassetid://159454293",Lf="rbxassetid://159454286",Rt="rbxassetid://159454300",Up="rbxassetid://159454288"},
    ["Minecraft"]     = {Bk="rbxassetid://1876545003",Dn="rbxassetid://1876544331",Ft="rbxassetid://1876542941",Lf="rbxassetid://1876543392",Rt="rbxassetid://1876543764",Up="rbxassetid://1876544642"},
    ["Night Sky"]     = {Bk="rbxassetid://12064107",Dn="rbxassetid://12064152",Ft="rbxassetid://12064121",Lf="rbxassetid://12063984",Rt="rbxassetid://12064115",Up="rbxassetid://12064131"},
    ["SpongeBob Sky"] = {Bk="rbxassetid://10287764626",Dn="rbxassetid://10287766382",Ft="rbxassetid://10287764626",Lf="rbxassetid://10287763421",Rt="rbxassetid://10287764626",Up="rbxassetid://10287767597"},
    ["Purple Sky"]    = {Bk="rbxassetid://17103618635",Dn="rbxassetid://17103622190",Ft="rbxassetid://17103624898",Lf="rbxassetid://17103628153",Rt="rbxassetid://17103636666",Up="rbxassetid://17103639457"},
    ["Pink Sky"]      = {Bk="rbxassetid://271042516",Dn="rbxassetid://271077243",Ft="rbxassetid://271042556",Lf="rbxassetid://271042310",Rt="rbxassetid://271042467",Up="rbxassetid://271077958"},
}
local _origSkyData = {}
local function _updateSkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then sky = Instance.new("Sky"); sky.Parent = Lighting end
    if S.SkyboxEnabled then
        if not _origSkyData.Bk then
            _origSkyData = {Bk=sky.SkyboxBk,Dn=sky.SkyboxDn,Ft=sky.SkyboxFt,Lf=sky.SkyboxLf,Rt=sky.SkyboxRt,Up=sky.SkyboxUp}
        end
        local sel = _Skyboxes[S.SkyboxChoice]
        if sel then
            sky.SkyboxBk=sel.Bk; sky.SkyboxDn=sel.Dn; sky.SkyboxFt=sel.Ft
            sky.SkyboxLf=sel.Lf; sky.SkyboxRt=sel.Rt; sky.SkyboxUp=sel.Up
        end
    elseif _origSkyData.Bk then
        sky.SkyboxBk=_origSkyData.Bk; sky.SkyboxDn=_origSkyData.Dn; sky.SkyboxFt=_origSkyData.Ft
        sky.SkyboxLf=_origSkyData.Lf; sky.SkyboxRt=_origSkyData.Rt; sky.SkyboxUp=_origSkyData.Up
    end
end

local function _updateColors()
    local cc = Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
    if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name="TH_Colors"; cc.Parent=Lighting end
    cc.Enabled    = S.ColorsEnabled
    cc.Brightness = S.ColorBrightness
    cc.Contrast   = S.ColorContrast
    cc.Saturation = S.ColorSaturation
end

local CH = { Gui=nil, Bars={}, Angle=0, Conn=nil }

local function SetCrosshair(enabled)
    if CH.Conn then CH.Conn:Disconnect(); CH.Conn = nil end
    if CH.Gui then CH.Gui:Destroy(); CH.Gui = nil end
    CH.Bars = {}; CH.Angle = 0
    if not enabled then return end

    CH.Gui = Instance.new("ScreenGui")
    CH.Gui.Name = "TH_Crosshair"
    CH.Gui.ResetOnSpawn = false
    CH.Gui.IgnoreGuiInset = true
    CH.Gui.DisplayOrder = 999
    pcall(function() CH.Gui.Parent = CoreGui end)
    if not CH.Gui.Parent then CH.Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local container = Instance.new("Frame", CH.Gui)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0

    local arms = {
        {w=false, sign=-1},
        {w=false, sign=1},
        {w=true,  sign=-1},
        {w=true,  sign=1},
    }
    for _, arm in ipairs(arms) do
        local f = Instance.new("Frame", container)
        f.BackgroundColor3 = S.CrosshairColor or Color3.new(1,1,1)
        f.BorderSizePixel = 0
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        table.insert(CH.Bars, {frame=f, wide=arm.w, sign=arm.sign})
    end

    local function updateBars()
        local col = S.CrosshairColor or Color3.new(1,1,1)
        local thick = S.CrosshairThickness or 2
        local len   = S.CrosshairLength or 8
        local gap   = (S.CrosshairXOffset or 0) + 4
        for _, bar in ipairs(CH.Bars) do
            local f = bar.frame
            f.BackgroundColor3 = col
            if bar.wide then
                f.Size = UDim2.new(0, len, 0, thick)
                f.Position = UDim2.new(0.5, bar.sign * (gap + len/2), 0.5, 0)
            else
                f.Size = UDim2.new(0, thick, 0, len)
                f.Position = UDim2.new(0.5, 0, 0.5, bar.sign * (gap + len/2))
            end
        end
    end

    updateBars()

    CH.Conn = RunService.RenderStepped:Connect(function(dt)
        if not S.CrosshairEnabled then return end
        updateBars()
        if S.CrosshairSpin then
            CH.Angle = (CH.Angle + (S.CrosshairSpinSpeed or 2) * dt * 60) % 360
        else
            CH.Angle = 0
        end
        container.Rotation = CH.Angle
    end)
end

do local old=CoreGui:FindFirstChild("TH_WM"); if old then old:Destroy() end end
local WMGui=Instance.new("ScreenGui"); WMGui.Name="TH_WM"; WMGui.Parent=CoreGui
WMGui.IgnoreGuiInset=true; WMGui.ResetOnSpawn=false; WMGui.DisplayOrder=24

local WMLbl=Instance.new("TextLabel",WMGui)
WMLbl.Size=UDim2.new(1,0,0,18); WMLbl.Position=UDim2.new(0,0,0,4)
WMLbl.BackgroundTransparency=1; WMLbl.BorderSizePixel=0
WMLbl.Text="buter.cel  •  discord.gg/3ncdFSH39"
WMLbl.TextColor3=Color3.fromRGB(210,180,255)
WMLbl.TextStrokeColor3=Color3.new(0,0,0); WMLbl.TextStrokeTransparency=0.4
WMLbl.FontFace=_buterFont; WMLbl.TextSize=8
WMLbl.TextXAlignment=Enum.TextXAlignment.Center
WMLbl.Visible=true
local WMFrame=WMLbl

local _handHue=0; local _sleeveHue=0
local _wmFps,_wmFpsTimer,_wmFpsCount=60,tick(),0

-- Forward declarations for variables used across closures
local Flags = { jsEnabled=false, saSnapTarget=nil, bigSquareEnabled=false }
local _applyBigSquare = function() end
local _removePlate    = function() end

-- ── Hitmarker: module-level so all hooks can fire it immediately ──────────
-- ========== HITMARKER (точечный) ==========
local HM = {
    Enabled   = false,
    Color     = Color3.fromRGB(255, 255, 255),
    HeadColor = Color3.fromRGB(255,  60,  60),
    Size      = 12,
    Thick     = 3,
    Duration  = 0.35,
    Gap       = 3,
    Pool      = {},
}

local function _spawnHitmarker(isHead, screenPos)
    if not HM.Enabled then return end
    if #HM.Pool >= 12 then table.remove(HM.Pool, 1) end
    table.insert(HM.Pool, { timer = 0, isHead = isHead, pos = screenPos })
end

-- 👇 ДОБАВЬ ЭТО
local function _getScreenPos(worldPos)
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local vp, onScreen = cam:WorldToViewportPoint(worldPos)
    if not onScreen then return nil end
    return Vector2.new(vp.X, vp.Y)
end

-- legacy alias (если где-то используется)
local _spawnWorldHitmarker_ref = _spawnHitmarker

local HB = {
    validCharacters      = {},
    originalHeadSizes    = {},
    originalTorsoSizes   = {},
    Enabled              = false,
    Conn                 = nil,
    HeadSizeX            = 3,
    HeadSizeY            = 3,
    HeadShapeBlocky      = false,
    HeadTransparency     = 0,
    blockyOverlays       = {},
}

--[[
local GH = {
    Hitboxes = {},
    Enabled  = false,
    Size     = 13,
    Transp   = 1,
}
--]]

local function isCharacterModel(m)
    if not (typeof(m) == "Instance" and m:IsA("Model")) then return false end

    if not m:FindFirstChild("Head") then return false end
    return m:FindFirstChild("Middle") ~= nil
        or m:FindFirstChild("LowerTorso") ~= nil
        or m:FindFirstChild("UpperTorso") ~= nil
end

local function addToVC(obj)
    if isCharacterModel(obj) then

        local ign = GetIgnoreFolder()
        local myChar = ign and ign:FindFirstChild("LocalCharacter")
        if obj == myChar or obj == LocalPlayer.Character then return end
        HB.validCharacters[obj] = true
        local head = obj:FindFirstChild("Head")
        if head and head:IsA("BasePart") and not HB.originalHeadSizes[head] then
            HB.originalHeadSizes[head] = head.Size
        end
        obj.ChildAdded:Connect(function(c)
            if c.Name == "Head" and c:IsA("BasePart") then
                if not HB.originalHeadSizes[c] then
                    HB.originalHeadSizes[c] = c.Size
                end
            end
        end)

        --[[
        if GH.Enabled then
            task.defer(function() _applyGhost(obj) end)
        end
        --]]
        if Flags.bigSquareEnabled then
            task.defer(function() _applyBigSquare(obj) end)
        end
    end
end

local _removeGhost

local function removeFromVC(obj)
    if HB.validCharacters[obj] then
        HB.validCharacters[obj] = nil
        -- if _removeGhost then pcall(_removeGhost, obj) end
        pcall(_removePlate, obj)
    end
end

for _, v in ipairs(workspace:GetChildren()) do addToVC(v) end
workspace.ChildAdded:Connect(addToVC)
workspace.ChildRemoved:Connect(removeFromVC)

task.spawn(function()
    task.wait(1)
    local ign = GetIgnoreFolder()
    if ign then
        for _, v in ipairs(ign:GetChildren()) do addToVC(v) end
        ign.ChildAdded:Connect(addToVC)
        ign.ChildRemoved:Connect(removeFromVC)
    end
end)

local function removeBlockyOverlay(head)
    if HB.blockyOverlays[head] then
        pcall(function() HB.blockyOverlays[head]:Destroy() end)
        HB.blockyOverlays[head] = nil
        pcall(function() head.LocalTransparencyModifier = 0 end)
    end
end

local _blockyApplied = {}

local function applyBlockyToHead(head, size)
    if _blockyApplied[head] then return end
    _blockyApplied[head] = true
    pcall(function()

        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            mesh.MeshType = Enum.MeshType.Brick
            mesh.MeshId   = ""
            mesh.Scale    = Vector3.new(1, 1, 1)
            return
        end

        local sm = Instance.new("SpecialMesh")
        sm.MeshType = Enum.MeshType.Brick
        sm.MeshId   = ""
        sm.Scale    = Vector3.new(1, 1, 1)
        sm.Parent   = head
        HB.blockyOverlays[head] = sm
    end)
end

local function removeBlockyFromHead(head)
    _blockyApplied[head] = nil
    pcall(function()

        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            if HB.blockyOverlays[head] == mesh then

                mesh:Destroy()
                HB.blockyOverlays[head] = nil
            else
                mesh.MeshType = Enum.MeshType.Sphere
                mesh.MeshId   = ""
                mesh.Scale    = Vector3.new(1, 1, 1)
            end
        end
    end)
end

local function _setHeadSize(head, size)

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(head, "Size", size)
        end
    end)
end

local _headConns   = {}

local _modelProxies = {}

local function applyHitboxOnce()
    local newSize
    if HB.HeadShapeBlocky then
        local s = HB.HeadSizeX
        newSize = Vector3.new(s, s, s)
    else
        newSize = Vector3.new(HB.HeadSizeX, HB.HeadSizeY, HB.HeadSizeX)
    end
    for model, _ in pairs(HB.validCharacters) do
        local head = model and model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            if not HB.originalHeadSizes[head] then
                HB.originalHeadSizes[head] = head.Size
            end

            _setHeadSize(head, newSize)

            if HB.HeadShapeBlocky then
                applyBlockyToHead(head, newSize)
            else
                removeBlockyFromHead(head)
            end
        end
    end
end

local function restoreHitbox()
    for head, orig in pairs(HB.originalHeadSizes) do
        if head and head.Parent then
            if _headConns[head] then
                pcall(function() _headConns[head]:Disconnect() end)
                _headConns[head] = nil
            end
            pcall(function()
                if sethiddenproperty then
                    sethiddenproperty(head, "Size", orig)
                end
            end)
            removeBlockyFromHead(head)
        end
    end
    _modelProxies = {}
    _headConns    = {}
end

local function applyTorsoOnce()
    for model, _ in pairs(HB.validCharacters) do

        local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
        if torso and torso:IsA("BasePart") then
            if not HB.originalTorsoSizes[torso] then
                HB.originalTorsoSizes[torso] = torso.Size
            end
            local orig = HB.originalTorsoSizes[torso]

            torso.Size = Vector3.new(orig.X * HB.HeadSizeX * 0.7, orig.Y * HB.HeadSizeX * 0.5, orig.Z * HB.HeadSizeX * 0.7)
            torso.Transparency = HB.HeadTransparency
            torso.CanCollide = false
        end
    end
end

local function restoreTorso()
    for torso, orig in pairs(HB.originalTorsoSizes) do
        if torso and torso.Parent then
            torso.Size = orig
            torso.Transparency = 0
        end
    end
end

local function setHitboxEnabled(value)
    HB.Enabled = value
    if HB.Conn then HB.Conn:Disconnect(); HB.Conn = nil end
    if value then
        applyHitboxOnce()
        local _hitboxThrottle = 0
        HB.Conn = RunService.Heartbeat:Connect(function(dt)
            _hitboxThrottle = _hitboxThrottle + dt
            if _hitboxThrottle < 0.05 then return end
            _hitboxThrottle = 0
            applyHitboxOnce()
        end)
    else
        restoreHitbox()
    end
end


_removeGhost = function(model)
    local g = GH.Hitboxes[model]
    if not g then return end
    pcall(function() g.weld:Destroy() end)
    pcall(function() g.part:Destroy() end)
    GH.Hitboxes[model] = nil
end

--[[local function _applyGhost(model)
    if not GH.Enabled then return end
    local head = model and model:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return end
    local existing = GH.Hitboxes[model]
    if existing and existing.part and existing.part.Parent then
        existing.part.Size        = Vector3.new(GH.Size, GH.Size, GH.Size)
        existing.part.Transparency = GH.Transp
        return
    end
    local ghost = Instance.new("Part")
    ghost.Name         = "GhostHB"
    ghost.Size         = Vector3.new(GH.Size, GH.Size, GH.Size)
    ghost.Transparency = GH.Transp
    ghost.CanCollide   = false
    ghost.CanQuery     = false
    ghost.CastShadow   = false
    ghost.Anchored     = false
    ghost.Massless     = true
    ghost.Material     = Enum.Material.ForceField
    ghost.Color        = Color3.fromRGB(255, 0, 0)
    ghost.CFrame       = head.CFrame
    ghost.Parent       = workspace
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ghost; weld.Part1 = head; weld.Parent = ghost
    GH.Hitboxes[model] = {part = ghost, weld = weld}
    model.AncestryChanged:Connect(function(_, parent)
        if not parent then _removeGhost(model) end
    end)
end
--]]

local function _applyAllGhosts()
    for model in pairs(HB.validCharacters) do _applyGhost(model) end
end

local function _removeAllGhosts()
    for model in pairs(GH.Hitboxes) do _removeGhost(model) end
end

local _mainHBThrottle = 0
RunService.Heartbeat:Connect(function(dt)

    _wmFpsCount=_wmFpsCount+1
    if _wmFpsTimer+1<=tick() then _wmFpsTimer=tick(); _wmFps=_wmFpsCount; _wmFpsCount=0 end

    _mainHBThrottle = _mainHBThrottle + dt
    if _mainHBThrottle >= 0.05 then
        _mainHBThrottle = 0
        for model,hl in pairs(activeOres) do if hl and model.Parent then hl.Enabled=S.OreEspEnabled end end
        for _,hl in pairs(activeCrates) do if hl then hl.Enabled=S.CrateEspEnabled end end
    end

    if S.BigHeadsEnabled then
        if S.BlinkEnabled then
            local _now = tick()
            if _now - S._blinkTimer >= S.BlinkSpeed then
                S._blinkState = (S._blinkState + 1) % 2
                S._blinkTimer = _now
                if S._blinkState == 1 then
                        restoreHitbox()
                    else
                        applyHitboxOnce()
                    end
            end
        end
    end
end)

local _playerRegistry = nil

local function _isValidRegistry(t)
    if type(t) ~= "table" then return false end
    local count = 0
    for _, entry in pairs(t) do
        if type(entry) ~= "table" then return false end
        local ok, valid = pcall(function()
            if not entry.model then return false end
            if typeof(entry.model) ~= "Instance" then return false end
            return entry.model:IsA("Model")
        end)
        if not ok or not valid then return false end
        count = count + 1
        if count >= 2 then return true end
    end
    return false
end

local function _findRegistry()
    local gcList = {}
    pcall(function()
        for _, fn in pairs(getgc(true)) do
            if typeof(fn) == "function" then
                gcList[#gcList + 1] = fn
            end
        end
    end)
    local count = 0
    for _, fn in ipairs(gcList) do
        count = count + 1

        if count % 100 == 0 then task.wait() end

        local nups = 0
        pcall(function()
            local ok1, n = pcall(debug.info, fn, "u")
            if ok1 and type(n) == "number" then
                nups = n
            else
                local info = debug.getinfo and debug.getinfo(fn)
                if info and info.nups then nups = info.nups end
            end
        end)

        local limit = (nups > 0) and nups or 20
        for i = 1, limit do
            local ok, val = pcall(debug.getupvalue, fn, i)
            if not ok then break end
            if _isValidRegistry(val) then
                for _, entry in pairs(val) do
                    if entry.equippedItem ~= nil or entry.handModel ~= nil then
                        return val
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    task.wait(8)
    while not _playerRegistry do
        _playerRegistry = _findRegistry()
        if not _playerRegistry then task.wait(30) end
    end
    warn("[TridentHub] Player registry found via structure fingerprint")
end)

local function _getEntry(model)
    if not _playerRegistry or not model then return nil end
    for _, entry in pairs(_playerRegistry) do
        if entry and entry.model == model then return entry end

        if entry and entry.model and entry.model.Name == model.Name then
            return entry
        end
    end
    return nil
end

local function _getChar(plr)
    return (plr.Character and plr.Character.Parent and plr.Character)
        or GetTridentChar(plr)
end

local function _getHead(char)
    return char:FindFirstChild("Head") or char:FindFirstChild("Top")
end

local function _getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Middle")
        or (char.PrimaryPart)
        or char:FindFirstChildOfClass("BasePart")
end

local _sleeperCache = setmetatable({}, {__mode = "k"})

local function _isSleeper(char)
    if not char then return false end

    local cached = _sleeperCache[char]
    if cached and tick() - cached.time < 1 then return cached.value end

    local value = false
    local lt = char:FindFirstChild("LowerTorso")
    if lt then
        local rr = lt:FindFirstChild("RootRig")
        if rr then
            local ok, angle = pcall(function() return rr.CurrentAngle end)
            value = ok and type(angle) == "number" and angle ~= 0 or false
        end
    end
    _sleeperCache[char] = {value = value, time = tick()}
    return value
end

local function _isDead(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health <= 0
end

local function _isRagdoll(char)
    local ac = char:FindFirstChild("AnimationController")
    if not ac then return false end
    local anim = ac:FindFirstChild("Animator")
    if not anim then return false end
    for _, track in pairs(anim:GetPlayingAnimationTracks()) do
        if track.Animation and track.Animation.AnimationId == "rbxassetid://13280887764" then
            return true
        end
    end
    return false
end

local _SYC = { Modules = { Fonts = {} } }
local _fontOk = pcall(function()
    local function _regFont(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then writefile(Asset.Id, Asset.Font) end
        if isfile(Name .. ".font") then delfile(Name .. ".font") end
        local Data = {
            name = Name,
            faces = {{
                name    = "Regular",
                weight  = Weight,
                style   = Style,
                assetId = getcustomasset(Asset.Id),
            }},
        }
        writefile(Name .. ".font", game:GetService("HttpService"):JSONEncode(Data))
        return getcustomasset(Name .. ".font")
    end
    _SYC.Modules.Fonts.Minecraftia = Font.new(_regFont("Minecraftia", 200, "normal", {
        Id   = "Minecraftia.ttf",
        Font = crypt.base64.decode("AAEAAAANAIAAAwBQRFNJRwAAAAEAAQX0AAAACEdERUYDBAAkAAEF/AAAAChPUy8y1NZFSAAAANwAAABgY21hcNZo3swAAQp8AAAIOGdhc3AAAAADAAEF7AAAAAhnbHlmEGqBuwAAGjgAANTQaGVhZAZHGCYAAPpgAAAANmhoZWERQQ7WAAAZ9AAAACRobXR4Ywj7gAAA+pgAAAtUbG9jYQEl1TwAAO8IAAALWG1heHAC4wA8AAAaGAAAACBuYW1lomnC7QABBiQAAARWcG9zdN5ON9IAAAE8AAAYuAADBGEB"),
    }))
end)
if not _fontOk then

    _SYC.Modules.Fonts.Minecraftia = Font.new("rbxasset://fonts/families/SourceSansPro.json")
end


-- ========================================================
--  PLAYER ESP  (Goose engine, VisCheck kept from paid)
-- ========================================================

local gui = Instance.new("ScreenGui")
gui.Name           = "ESPHolder"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if not gui or not gui.Parent then
        gui = Instance.new("ScreenGui")
        gui.Name           = "ESPHolder"
        gui.ResetOnSpawn   = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end
end)

local Esp = {
    settings = {
        enabled = false, boxEnabled = false, nameEnabled = false,
        distanceEnabled = false, weaponEnabled = false, chamsEnabled = false,
        boxType = "Corner", boxOutline = true, boxFill = false,
        fillTransparency = 0.75, renderDistance = 500,
        boxColor         = Color3.fromRGB(255, 255, 255),
        outlineColor     = Color3.fromRGB(20, 20, 20),
        fillColor        = Color3.fromRGB(255, 255, 255),
        fillColor2       = Color3.fromRGB(20, 20, 20),
        nameColor        = Color3.fromRGB(255, 255, 255),
        nameOutline      = true,
        nameOutlineColor = Color3.fromRGB(20, 20, 20),
        distColor        = Color3.fromRGB(255, 255, 255),
        distOutline      = true,
        distOutlineColor = Color3.fromRGB(20, 20, 20),
        weapColor        = Color3.fromRGB(255, 255, 255),
        weapOutline      = true,
        weapOutlineColor = Color3.fromRGB(20, 20, 20),
        sleepCheck = false, teamCheck = false, aiCheck = false,
    },
    cache = {
        boxes      = setmetatable({}, {__mode = "k"}),
        sleep      = setmetatable({}, {__mode = "k"}),
        player     = setmetatable({}, {__mode = "k"}),
        weapon     = setmetatable({}, {__mode = "k"}),
        weaponTime = setmetatable({}, {__mode = "k"}),
    },
    const = {
        V3_UP = Vector3.new(0, 2.8, 0),
        V3_DN = Vector3.new(0, 3.0, 0),
        ANCHORS = {
            LeftTop         = Vector2.new(0, 0),
            LeftSide        = Vector2.new(0, 0),
            RightTop        = Vector2.new(1, 0),
            RightSide       = Vector2.new(0, 0),
            BottomSide      = Vector2.new(0, 1),
            BottomDown      = Vector2.new(0, 1),
            BottomRightSide = Vector2.new(1, 1),
            BottomRightDown = Vector2.new(1, 1),
        },
    },
}

local function ESP_IsTeam(m)
    if not m then return false end
    local h = m:FindFirstChild("Head")
    return h and h:FindFirstChild("Dot") and h.Dot.Enabled == true or false
end
local function ESP_IsSleeper(m)
    if not m then return false end
    local c = Esp.cache.sleep[m]
    if c and tick() - c.time < 1 then return c.value end
    local lt = m:FindFirstChild("LowerTorso"); local v = false
    if lt then
        local rr = lt:FindFirstChild("RootRig")
        if rr then
            local ok, a = pcall(function() return rr.CurrentAngle end)
            v = ok and type(a) == "number" and a ~= 0 or false
        end
    end
    Esp.cache.sleep[m] = {value = v, time = tick()}; return v
end
local function ESP_IsPlayer(m)
    local c = Esp.cache.player[m]
    if c and tick() - c.time < 2 then return c.value end
    local t = m:FindFirstChild("Torso")
    local v = t and t:FindFirstChild("LeftBooster") and true or false
    Esp.cache.player[m] = {value = v, time = tick()}; return v
end
local function espShouldSkip(m)
    if not m or not m.Parent then return true end
    local s = Esp.settings
    if ESP_IsSleeper(m) then return true end  -- always skip sleepers
    if s.teamCheck and ESP_IsTeam(m) then return true end
    if s.aiCheck   and ESP_IsAI(m)   then return true end
    return false
end

local _espWeaponData = {
    Bow={{"Arrow","Fabric","Handle","Meshes/Bow","ADS","Mover"}},
    Ar15={{"AnimSaves","Barrel","Body","Bolt","ChargingHandle","Decor","Grip","Handle","Mag","Rails","Stock","Muzzle"}},
    Blunderbuss={{"Body","Handle","Tube","thing","ADS","Muzzle"}},
    C9={{"Barrel","Body","Bolt","Decor","Grip","Handle","LowerSlide","Mag","Sight1","Sight2","UpperSlide","ADS","Muzzle"}},
    CrossBow={{"Arrow","BackMetal","Body","FrontNails","Handle","Release","SpringSteel","String","Wheel","Slide"}},
    EnergyRifle={{"DefaultSight","FrontCover","Glowing","Grip","Handle","Mag","Metal","Metal2","RearCover","RearDecor","Screws","Tubes"}},
    GaussRifle={{"DefaultSight","Barrel","Body","CoilHolders","Coils","Decals1","Decals2","Grip","Handle","Housing","Mag","StockBack"}},
    Hmar={{"DefaultSight","Body","Bolt","Bolts","Cover","Handle","Mag","Rails","Spring","Stock","Wood","Muzzle"}},
    LeverActionRifle={{"9mm","DefaultSight","Body","Brass","Hammer","Handle","Lever","Metal","Thing","Wood","Muzzle"}},
    M4a1={{"DefaultSight","Body","Bolt","ChargeHandle","Grip","Handle","Mag","Metal","mbrk","Muzzle"}},
    PipePistol={{"DefaultSight","Body","Bolt","Handle","Mag","Muzzle"}},
    PipeSmg={{"DefaultSight","Barrel","Body","Bolt","Flap","Grip","Handle","Mag","Stock","Muzzle"}},
    PumpShotgun={{"Barrel","Body","Handle","MainMetal","RearSight","Shell","Slider","ADS","Muzzle"}},
    Scar={{"DefaultSight","Barrel","Body","ChargingHandle","Decals","Handle","Mag","Rails","ShoulderPad","Stock","Muzzle"}},
    Svd={{"DefaultSight","Body","Bolt","Handle","Magazine","Magazine2","Metal2","Wood"}},
    Usp9={{"Body","Handle","Mag","Slide","ADS","Muzzle"}},
    Uzi={{"DefaultSight","Body","Body2","Bolt","ChargingHandle","Decor","Grip","Handle","Mag","Stock","Muzzle"}},
    Magnum={{"Cylinder","Decor","EjectRod","EjectRodDecal","Frame","Grip"}},
}

local function espDetectWeapon(m)
    local t  = tick()
    local lu = Esp.cache.weaponTime[m]
    if lu and t - lu < 2 then return Esp.cache.weapon[m] or "None" end
    local hand = m:FindFirstChild("HandModel")
    if not hand then
        Esp.cache.weapon[m] = "None"; Esp.cache.weaponTime[m] = t; return "None"
    end
    local best, bestN = "None", 0
    for wn, parts in next, _espWeaponData do
        local cnt = 0
        for _, p in ipairs(parts[1]) do if hand:FindFirstChild(p, true) then cnt = cnt + 1 end end
        if cnt > bestN then best = wn; bestN = cnt end
    end
    Esp.cache.weapon[m] = best; Esp.cache.weaponTime[m] = t
    return best
end



local function espNewText()
    local t = Drawing.new("Text")
    t.Visible = false; t.Size = 10; t.Center = true
    t.Font = 2; t.Outline = true; t.OutlineColor = Color3.fromRGB(0,0,0)
    return t
end

local function espNewCornerFrame(anchor)
    local f = Instance.new("Frame")
    f.BackgroundColor3       = Esp.settings.boxColor
    f.BorderSizePixel        = 0
    f.BackgroundTransparency = 0
    f.Visible                = false
    f.AnchorPoint            = anchor
    f.ZIndex                 = 2
    f.Parent                 = gui
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0,0,0); s.Thickness = 1; s.Transparency = 0
    s.LineJoinMode = Enum.LineJoinMode.Miter
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = f
    return f, s
end

local function espMakeCorners()
    local cf = {}
    for name, anchor in next, Esp.const.ANCHORS do
        local f, s = espNewCornerFrame(anchor)
        cf[name] = {f = f, s = s}
    end
    return cf
end

local function espMakeFillFrame()
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0; f.BackgroundColor3 = Color3.fromRGB(255,255,255)
    f.BackgroundTransparency = 1; f.Visible = false; f.ZIndex = 0; f.Parent = gui
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Esp.settings.fillColor),
        ColorSequenceKeypoint.new(1, Esp.settings.fillColor2),
    }
    g.Parent = f
    return f, g
end

local function espMakeDefaultBox()
    local fill, fillGrad = espMakeFillFrame()
    fill.ZIndex = 0
    local strokeOutline = Instance.new("UIStroke")
    strokeOutline.Color = Esp.settings.outlineColor; strokeOutline.Thickness = 3
    strokeOutline.Transparency = 0; strokeOutline.LineJoinMode = Enum.LineJoinMode.Miter
    strokeOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; strokeOutline.Parent = fill
    local main = Instance.new("Frame")
    main.BorderSizePixel = 0; main.BackgroundColor3 = Color3.fromRGB(0,0,0)
    main.BackgroundTransparency = 1; main.Visible = false; main.ZIndex = 2; main.Parent = gui
    local stroke = Instance.new("UIStroke")
    stroke.Color = Esp.settings.boxColor; stroke.Thickness = 1; stroke.Transparency = 0
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Parent = main
    return {fill=fill, fillGrad=fillGrad, main=main, stroke=stroke, strokeOutline=strokeOutline}
end

local function espApplyFill(fill, grad, l, t, w, h)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Esp.settings.fillColor),
        ColorSequenceKeypoint.new(1, Esp.settings.fillColor2),
    }
    fill.BackgroundTransparency = Esp.settings.boxFill and Esp.settings.fillTransparency or 1
    fill.Position = UDim2.new(0, l, 0, t); fill.Size = UDim2.new(0, w, 0, h)
    fill.Visible = true
end

local ESP_CORNER_POS = {}
local function espBuildCornerPos(l, r, t, b, cx, cy)
    ESP_CORNER_POS.LeftTop         = {l,   t,  cx,  1.5}
    ESP_CORNER_POS.LeftSide        = {l,   t,  1.5, cy}
    ESP_CORNER_POS.RightTop        = {r,   t,  cx,  1.5}
    ESP_CORNER_POS.RightSide       = {r-1, t,  1.5, cy}
    ESP_CORNER_POS.BottomSide      = {l,   b,  1.5, cy}
    ESP_CORNER_POS.BottomDown      = {l,   b,  cx,  1.5}
    ESP_CORNER_POS.BottomRightSide = {r,   b,  1.5, cy}
    ESP_CORNER_POS.BottomRightDown = {r,   b,  cx,  1.5}
end

local function espUpdateCorners(cf, fill, grad, px, py, w, h)
    local cx, cy = w*0.22, h*0.22
    local l, r   = px - w*0.5, px + w*0.5
    local t, b   = py - h*0.5, py + h*0.5
    espBuildCornerPos(l, r, t, b, cx, cy)
    local bc  = Esp.settings.boxColor
    local oc  = Esp.settings.outlineColor
    local otr = Esp.settings.boxOutline and 0 or 1
    for name, seg in next, cf do
        local d = ESP_CORNER_POS[name]
        seg.f.Position = UDim2.new(0, d[1], 0, d[2]); seg.f.Size = UDim2.new(0, d[3], 0, d[4])
        seg.f.BackgroundColor3 = bc; seg.f.Visible = true
        seg.s.Color = oc; seg.s.Transparency = otr
    end
    espApplyFill(fill, grad, l, t, w, h)
end

local function espUpdateDefaultBox(db, px, py, w, h)
    local l, t = px - w*0.5, py - h*0.5
    espApplyFill(db.fill, db.fillGrad, l, t, w, h)
    db.strokeOutline.Color = Esp.settings.outlineColor
    db.strokeOutline.Transparency = Esp.settings.boxOutline and 0 or 1
    db.main.Position = UDim2.new(0, l, 0, t); db.main.Size = UDim2.new(0, w, 0, h)
    db.main.Visible = true; db.stroke.Color = Esp.settings.boxColor; db.stroke.Transparency = 0
end

local function espHideCorners(cf, fill)
    for _, seg in next, cf do if seg.f.Visible then seg.f.Visible = false end end
    if fill.Visible then fill.Visible = false end
end
local function espHideDefault(db)
    if db.fill.Visible then db.fill.Visible = false end
    if db.main.Visible then db.main.Visible = false end
end

local function espDestroyEntry(m, d)
    pcall(function() d.cacheConn:Disconnect() end)
    for _, seg in next, d.corners do pcall(function() seg.f:Destroy() end) end
    pcall(function() d.cFill:Destroy() end)
    pcall(function() d.default.fill:Destroy() end)
    pcall(function() d.default.main:Destroy() end)
    pcall(function() d.nameText:Remove() end)
    pcall(function() d.distText:Remove() end)
    pcall(function() d.weapText:Remove() end)
    if d.visBar then pcall(function() d.visBar:Destroy() end) end
    Esp.cache.boxes[m] = nil
end

-- VisBar drawing for VisCheck (kept from paid script)
local function espMakeVisBar()
    local f = Instance.new("Frame")
    f.Name = "VisBar"; f.ZIndex = 3; f.Parent = gui
    f.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    f.BorderSizePixel = 0; f.Visible = false
    return f
end

local function espCreateEntry(m)
    if Esp.cache.boxes[m] then return end
    local cFill, cGrad = espMakeFillFrame()
    local entry = {
        corners   = espMakeCorners(),
        cFill     = cFill,
        cGrad     = cGrad,
        default   = espMakeDefaultBox(),
        nameText  = espNewText(),
        distText  = espNewText(),
        weapText  = espNewText(),
        visBar    = espMakeVisBar(),
        hrp       = m:FindFirstChild("HumanoidRootPart"),
        lastCache = 0,
        isPlayer  = false,
        isSleeper = false,
        _visBlinkTimer = 0,
        _visBlinkState = true,
    }
    entry.cacheConn = m.ChildAdded:Connect(function()
        entry.hrp = m:FindFirstChild("HumanoidRootPart")
    end)
    Esp.cache.boxes[m] = entry
end

-- ========== ОПТИМИЗИРОВАННЫЙ ESP ДЛЯ БОТОВ ==========
local ESP_INTERVAL   = 1 / 30
local espLastTick    = 0
local ESP_MAX_RENDER = 3400  -- максимум стадов (хардкап)

-- Кешированные цвета для VisCheck
local VIS = {
    COLOR_VISIBLE = Color3.fromRGB(0, 255, 80),
    COLOR_NEAR    = Color3.fromRGB(255, 200, 0),
    COLOR_MID     = Color3.fromRGB(255, 120, 0),
    COLOR_FAR     = Color3.fromRGB(220, 0, 0),
}

-- Throttle raycast VisCheck
local _visCheckCache    = {}
local _visCheckInterval = 0.15

-- Авто-очистка мёртвых записей из visCheck кеша
task.spawn(function()
    while true do
        task.wait(10)
        for m in next, _visCheckCache do
            if not m or not m.Parent then
                _visCheckCache[m] = nil
            end
        end
    end
end)

local function _espHideEntry(d)
    espHideCorners(d.corners, d.cFill)
    espHideDefault(d.default)
    if d.nameText.Visible then d.nameText.Visible = false end
    if d.distText.Visible then d.distText.Visible = false end
    if d.weapText.Visible then d.weapText.Visible = false end
    if d.visBar.Visible   then d.visBar.Visible   = false end
end

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - espLastTick < ESP_INTERVAL then return end
    espLastTick = now

    local cam = workspace.CurrentCamera
    if not cam or not cam:IsA("Camera") then return end
    local camPos = cam.CFrame.Position
    local s      = Esp.settings

    -- рендер дистанция: берём настройку, но не больше хардкапа
    local rd = math.min(s.renderDistance, ESP_MAX_RENDER)

    for m, d in next, Esp.cache.boxes do
        -- авто-очистка мёртвых объектов
        if not m or not m.Parent then
            _espHideEntry(d)
            espDestroyEntry(m, d)
            _visCheckCache[m] = nil
            continue
        end
        if not s.enabled then _espHideEntry(d); continue end

        local hrp = d.hrp
        if not hrp or not hrp.Parent then
            d.hrp = m:FindFirstChild("HumanoidRootPart")
            _espHideEntry(d); continue
        end

        -- дистанция без sqrt (быстро)
        local hrpPos = hrp.Position
        local dx = hrpPos.X - camPos.X
        local dy = hrpPos.Y - camPos.Y
        local dz = hrpPos.Z - camPos.Z
        local distSq = dx*dx + dy*dy + dz*dz

        -- чек дистанции (настраиваемая, хардкап 3400)
        if distSq > rd*rd then
            _espHideEntry(d); continue
        end

        if espShouldSkip(m) then _espHideEntry(d); continue end

        -- кеш player/sleeper раз в 5 сек
        if now - d.lastCache > 5 then
            d.isPlayer  = ESP_IsPlayer(m)
            d.isSleeper = ESP_IsSleeper(m)
            d.lastCache = now
        end

        local topPos = cam:WorldToViewportPoint(hrpPos + Esp.const.V3_UP)
        local botPos = cam:WorldToViewportPoint(hrpPos - Esp.const.V3_DN)

        if topPos.Z <= 0 then _espHideEntry(d); continue end

        local h = botPos.Y - topPos.Y
        if h < 1 then _espHideEntry(d); continue end

        local w    = h * 0.65
        local px   = topPos.X
        local py   = topPos.Y + h * 0.5
        local dist = math.floor(math.sqrt(distSq))

        -- BOX
        if s.boxEnabled then
            if s.boxType == "Corner" then
                espHideDefault(d.default)
                espUpdateCorners(d.corners, d.cFill, d.cGrad, px, py, w, h)
            else
                espHideCorners(d.corners, d.cFill)
                espUpdateDefaultBox(d.default, px, py, w, h)
            end
        else
            espHideCorners(d.corners, d.cFill)
            espHideDefault(d.default)
        end

        local dtype = d.isPlayer and "player" or "bot"

        -- NAME
        if s.nameEnabled then
            d.nameText.Text         = dtype
            d.nameText.Position     = Vector2.new(px, py - h*0.5 - 16)
            d.nameText.Color        = s.nameColor
            d.nameText.Outline      = s.nameOutline
            d.nameText.OutlineColor = s.nameOutlineColor
            d.nameText.Visible      = true
        else
            if d.nameText.Visible then d.nameText.Visible = false end
        end

        -- DISTANCE
        if s.distanceEnabled then
            d.distText.Text         = "[" .. dist .. "m]"
            d.distText.Position     = Vector2.new(px, py + h*0.5 + 4)
            d.distText.Color        = s.distColor
            d.distText.Outline      = s.distOutline
            d.distText.OutlineColor = s.distOutlineColor
            d.distText.Visible      = true
        else
            if d.distText.Visible then d.distText.Visible = false end
        end

        -- WEAPON
        if s.weaponEnabled then
            d.weapText.Text         = espDetectWeapon(m)
            d.weapText.Position     = Vector2.new(px, py + h*0.5 + (s.distanceEnabled and 18 or 4))
            d.weapText.Color        = s.weapColor
            d.weapText.Outline      = s.weapOutline
            d.weapText.OutlineColor = s.weapOutlineColor
            d.weapText.Visible      = true
        else
            if d.weapText.Visible then d.weapText.Visible = false end
        end

        -- VISCHECK (raycast throttled)
        if S.VisCheckEnabled then
            local vc = _visCheckCache[m]
            if not vc or (now - vc.time) >= _visCheckInterval then
                local visNow = IsVisible(hrp)
                _visCheckCache[m] = {time = now, visible = visNow}
                vc = _visCheckCache[m]
            end
            local visNow  = vc.visible
            local visColor
            if visNow then
                visColor = VIS.COLOR_VISIBLE
            elseif dist < 100 then
                visColor = VIS.COLOR_NEAR
            elseif dist < 300 then
                visColor = VIS.COLOR_MID
            else
                visColor = VIS.COLOR_FAR
            end
            local blinkRate = visNow and 0.15 or 0.5
            if now - d._visBlinkTimer >= blinkRate then
                d._visBlinkTimer = now
                d._visBlinkState = not d._visBlinkState
            end
            d.visBar.BackgroundColor3 = visColor
            d.visBar.Position = UDim2.new(0, px - w*0.5, 0, py + h*0.5 + 2)
            d.visBar.Size     = UDim2.new(0, w, 0, 3)
            d.visBar.Visible  = d._visBlinkState
        else
            if d.visBar.Visible then d.visBar.Visible = false end
        end
    end
end)

-- Авто-регистрация новых моделей
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.defer(function()
            if obj.Parent and obj:FindFirstChild("HumanoidRootPart") and not Esp.cache.boxes[obj] then
                espCreateEntry(obj)
            end
        end)
    end
end)

-- Авто-очистка при удалении
workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") then
        local d = Esp.cache.boxes[obj]
        if d then espDestroyEntry(obj, d) end
        Esp.cache.weapon[obj]     = nil
        Esp.cache.weaponTime[obj] = nil
        Esp.cache.player[obj]     = nil
        Esp.cache.sleep[obj]      = nil
        _visCheckCache[obj]       = nil
    end
end)

-- Периодическая авто-очистка всех кешей каждые 10 сек
task.spawn(function()
    while true do
        task.wait(10)
        for m in next, Esp.cache.weapon do
            if not m or not m.Parent then
                Esp.cache.weapon[m]     = nil
                Esp.cache.weaponTime[m] = nil
            end
        end
        for m in next, Esp.cache.sleep do
            if not m or not m.Parent then Esp.cache.sleep[m] = nil end
        end
        for m in next, Esp.cache.player do
            if not m or not m.Parent then Esp.cache.player[m] = nil end
        end
        for m, d in next, Esp.cache.boxes do
            if not m or not m.Parent then
                espDestroyEntry(m, d)
                _visCheckCache[m] = nil
            end
        end
    end
end)

-- Первичное сканирование workspace
for _, m in next, workspace:GetChildren() do
    if m:IsA("Model") then
        task.defer(function()
            if m.Parent and m:FindFirstChild("HumanoidRootPart") then
                espCreateEntry(m)
            end
        end)
    end
end
-- ========== КОНЕЦ ОПТИМИЗИРОВАННОГО ESP ДЛЯ БОТОВ ==========


local function worldToScreen(world)
    local cam = GetCamera()
    local s, inB = cam:WorldToViewportPoint(world)
    return Vector2.new(s.X, s.Y), inB, s.Z
end

local FovInlineDrawing = Drawing.new("Circle")
FovInlineDrawing.Thickness  = 1
FovInlineDrawing.Color      = Color3.fromRGB(255, 182, 210)
FovInlineDrawing.Filled     = false
FovInlineDrawing.Radius     = 150
FovInlineDrawing.Visible    = false
FovInlineDrawing.Position   = Vector2.new(0, 0)

local FovFillDrawing = Drawing.new("Circle")
FovFillDrawing.Thickness     = 1
FovFillDrawing.Color         = Color3.fromRGB(255, 182, 210)
FovFillDrawing.Filled        = true
FovFillDrawing.Radius        = 150
FovFillDrawing.Visible       = false
FovFillDrawing.Position      = Vector2.new(0, 0)
FovFillDrawing.Transparency  = 0.9

local FovOutlineDrawing = Drawing.new("Circle")
FovOutlineDrawing.Thickness = 3
FovOutlineDrawing.Color     = Color3.new(0, 0, 0)
FovOutlineDrawing.Filled    = false
FovOutlineDrawing.Radius    = 150
FovOutlineDrawing.Visible   = false
FovOutlineDrawing.Position  = Vector2.new(0, 0)

-- FOV Polygon drawings (12 sides)
local FovPolyLines = {}
for i = 1, 12 do
    local line = Drawing.new("Line")
    line.Visible   = false
    line.Color     = Color3.fromRGB(255, 255, 255)
    line.Thickness = 2
    FovPolyLines[i] = line
end

local _lastBagUpdate = 0
local BAG_INTERVAL = 1 / 20   -- 20 раз в секунду

local _renderThrottle = 0
local _BLACK = Color3.new(0,0,0)
local _BAG_ESP_COLOR = Color3.fromRGB(0,200,80)
-- Hoisted above RenderStepped to avoid allocating new locals every frame
local _rs_cam, _rs_s, _rs_inB
local function _rs_snap(worldPos)
    _rs_s = _rs_cam:WorldToViewportPoint(worldPos)
    return Vector2.new(_rs_s.X, _rs_s.Y), _rs_s.Z > 0
end
RunService.RenderStepped:Connect(function(dt)
    _rs_cam = GetCamera(); if not _rs_cam or not _rs_cam:IsA("Camera") then return end
    local cam    = _rs_cam
    local camCF  = cam.CFrame
    local camPos = camCF.Position
    local vp     = cam.ViewportSize

    local function snapToScreen(worldPos)
        return _rs_snap(worldPos)
    end

    local cx = vp.X/2
    local cy = vp.Y/2
    local pos = Vector2.new(cx, cy)

    local fovVisible  = S.FovCircleVisible
    local fovRadius   = S.FovCircleRadius or 150
    local fovColor    = S.FovCircleColor
    local fovThick    = math.max(S.FovCircleThickness, 1)
    local fovShape    = S.FovShape or "Circle"

    if fovShape == "Circle" then
        -- Circle mode: single drawing handles both outline and fill
        local isFilled = S.FovCircleFilled == true
        FovInlineDrawing.Position     = pos
        FovInlineDrawing.Radius       = fovRadius
        FovInlineDrawing.Color        = fovColor
        FovInlineDrawing.Thickness    = isFilled and 0 or fovThick
        FovInlineDrawing.Filled       = isFilled
        FovInlineDrawing.Transparency = isFilled and 0.9 or 0
        FovInlineDrawing.Visible      = fovVisible

        -- When filled, also draw the outline ring on top so the border is still visible
        FovOutlineDrawing.Position    = pos
        FovOutlineDrawing.Radius      = fovRadius
        FovOutlineDrawing.Color       = fovColor
        FovOutlineDrawing.Thickness   = fovThick
        FovOutlineDrawing.Filled      = false
        FovOutlineDrawing.Visible     = fovVisible and isFilled

        FovFillDrawing.Visible = false
        for _, pl in ipairs(FovPolyLines) do pl.Visible = false end
    else
        -- Polygon mode (12 sides)
        FovInlineDrawing.Visible  = false
        FovFillDrawing.Visible    = false
        FovOutlineDrawing.Visible = false

        local sides = 12
        local r = fovRadius
        for i = 1, sides do
            local a1 = (math.pi * 2 / sides) * (i - 1) - math.pi / 2
            local a2 = (math.pi * 2 / sides) * i - math.pi / 2
            local p1 = Vector2.new(cx + math.cos(a1) * r, cy + math.sin(a1) * r)
            local p2 = Vector2.new(cx + math.cos(a2) * r, cy + math.sin(a2) * r)
            FovPolyLines[i].From      = p1
            FovPolyLines[i].To        = p2
            FovPolyLines[i].Color     = fovColor
            FovPolyLines[i].Thickness = fovThick
            FovPolyLines[i].Visible   = fovVisible
        end
    end

end) -- конец RenderStepped

-- ========== ОПТИМИЗИРОВАННЫЙ OBJ ESP (руда, объекты) ==========
-- Рендер дистанция: 1000 стадов, авто-очистка, отдельный Heartbeat
do
    local _objInterval = 1/20
    local _objLast     = 0
    local OBJ_MAX_DIST = 1000
    local OBJ_MAX_DISTSQ = OBJ_MAX_DIST * OBJ_MAX_DIST

    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - _objLast < _objInterval then return end
        _objLast = now
        local cam = workspace.CurrentCamera
        if not cam or not cam:IsA("Camera") then return end
        local camPos = cam.CFrame.Position

        local myPos2 = GetMyPos()

        for model, obj in pairs(objEspDrawings) do
            -- авто-очистка мёртвых
            if not model or not model.Parent then
                pcall(function() obj.name:Remove() end)
                pcall(function() obj.dist:Remove() end)
                objEspDrawings[model] = nil
            elseif not S.ObjEspEnabled or not S.ObjEspAllowed[obj.espname] then
                obj.name.Visible = false
                obj.dist.Visible = false
            elseif obj.mainpart and obj.mainpart.Parent then
                local mpos = obj.mainpart.Position
                -- дистанция без sqrt
                local dx = mpos.X - camPos.X
                local dy = mpos.Y - camPos.Y
                local dz = mpos.Z - camPos.Z
                local dsq = dx*dx + dy*dy + dz*dz
                if dsq > OBJ_MAX_DISTSQ then
                    obj.name.Visible = false
                    obj.dist.Visible = false
                else
                    local ok, sp = pcall(function() return cam:WorldToViewportPoint(mpos) end)
                    if ok and sp and sp.Z > 0 then
                        local dist2 = myPos2 and math.round(math.sqrt(dsq)) or 0
                        local oreCol = (obj.espname=="Nitrate" and S.NitrateEspColor)
                            or (obj.espname=="Iron"    and S.IronEspColor)
                            or (obj.espname=="Stone"   and S.StoneEspColor)
                            or Color3.new(1,1,1)
                        obj.name.Visible      = true
                        obj.name.Position     = Vector2.new(sp.X, sp.Y)
                        obj.name.Text         = obj.espname:lower() .. " (" .. dist2 .. ")"
                        obj.name.Color        = oreCol
                        obj.name.Transparency = 1
                        obj.name.Outline      = true
                        obj.name.OutlineColor = Color3.new(0,0,0)
                        obj.name.Size         = 10
                        obj.name.Font         = Drawing.Fonts.Monospace
                        obj.dist.Visible      = false
                    else
                        obj.name.Visible = false
                        obj.dist.Visible = false
                    end
                end
            else
                obj.name.Visible = false
                obj.dist.Visible = false
            end
        end
    end)
end
-- ========== КОНЕЦ OBJ ESP ==========

-- ========== ОПТИМИЗИРОВАННЫЙ BAG ESP (рюкзаки) ==========
-- Рендер дистанция: 1000 стадов, авто-очистка, отдельный Heartbeat
do
    local _bagInterval = 1/20
    local _bagLast     = 0
    local BAG_MAX_DIST = 1000
    local BAG_MAX_DISTSQ = BAG_MAX_DIST * BAG_MAX_DIST

    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - _bagLast < _bagInterval then return end
        _bagLast = now
        local cam = workspace.CurrentCamera
        if not cam or not cam:IsA("Camera") then return end
        local camPos = cam.CFrame.Position

        for model, obj in pairs(bagEspDrawings) do
            -- авто-очистка мёртвых
            if not model or not model.Parent then
                pcall(function() obj.name:Remove() end)
                bagEspDrawings[model] = nil
            elseif not S.BagEspEnabled then
                obj.name.Visible = false
            elseif obj.part and obj.part.Parent then
                local ppos = obj.part.Position
                local dx = ppos.X - camPos.X
                local dy = ppos.Y - camPos.Y
                local dz = ppos.Z - camPos.Z
                local dsq = dx*dx + dy*dy + dz*dz
                if dsq > BAG_MAX_DISTSQ then
                    obj.name.Visible = false
                else
                    local ok, sp = pcall(function() return cam:WorldToViewportPoint(ppos) end)
                    if ok and sp and sp.Z > 0 then
                        local dist2 = math.round(math.sqrt(dsq))
                        obj.name.Visible      = true
                        obj.name.Position     = Vector2.new(sp.X, sp.Y)
                        obj.name.Text         = "ʙᴀᴄᴋᴘᴀᴄᴋ (" .. dist2 .. ")"
                        obj.name.Color        = Color3.fromRGB(0,200,80)
                        obj.name.Transparency = 1
                        obj.name.Outline      = true
                        obj.name.OutlineColor = Color3.new(0,0,0)
                        obj.name.Size         = 10
                        obj.name.Font         = Drawing.Fonts.Monospace
                    else
                        obj.name.Visible = false
                    end
                end
            else
                obj.name.Visible = false
            end
        end
    end)
end
-- ========== КОНЕЦ BAG ESP ==========

workspace.ChildAdded:Connect(CheckAndTagModel)
workspace.DescendantAdded:Connect(function(d) if d:IsA("Model") then CheckAndTagModel(d) end end)
task.delay(10, function()
    for _,obj in ipairs(workspace:GetChildren()) do CheckAndTagModel(obj) end
    end)
workspace.DescendantRemoving:Connect(function(obj)
    local _debugId=""; pcall(function() _debugId=obj:GetDebugId() end)
    local found=ChamStorage:FindFirstChild(_debugId); if found then found:Destroy() end
    activeCrates[obj]=nil; activeBags[obj]=nil; activeOres[obj]=nil
end)

Players.PlayerAdded:Connect(function(plr) end)
Players.PlayerRemoving:Connect(function(plr)
    _charCache[plr]=nil; _charCacheTime[plr]=nil
end)


-- ============================================================
-- BUTER UI LIBRARY (ported from Buter_rost_fixed)
-- ============================================================

-- Font already loaded at top of file as _buterFont (GothamSemibold)

local mainColor  = Color3.fromRGB(255, 182, 210)
local font       = _buterFont

local Library = { IsVisible = true }

local function tw(obj, props, dur)
    dur = dur or 0.2
    TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ── Toggle widget ─────────────────────────────────────────────────────────
local function _mkToggle(parent, name, default, callback)
    local toggle = {value = default or false}
    local frame  = Instance.new("Frame", parent)
    frame.BorderSizePixel = 0; frame.BackgroundTransparency = 1
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.Size = UDim2.new(1,0,0,16)
    local lbl = Instance.new("TextLabel", frame)
    lbl.TextStrokeTransparency=1; lbl.BorderSizePixel=0; lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(200,200,200); lbl.Size=UDim2.new(1,-26,1,0)
    lbl.Position=UDim2.new(0,2,0,0); lbl.Text=name
    do if font then lbl.FontFace=font else lbl.Font=Enum.Font.GothamSemibold end end
    local checkbox = Instance.new("Frame", frame)
    checkbox.Size=UDim2.new(0,12,0,12); checkbox.Position=UDim2.new(1,-18,0.5,-6)
    checkbox.BorderSizePixel=0; checkbox.BackgroundColor3=Color3.fromRGB(18,18,18)
    local chkStroke = Instance.new("UIStroke",checkbox); chkStroke.Color=Color3.fromRGB(50,50,50); chkStroke.Thickness=1
    local fill = Instance.new("Frame",checkbox); fill.Size=UDim2.new(1,0,1,0)
    fill.BackgroundColor3=mainColor; fill.BorderSizePixel=0; fill.Visible=toggle.value
    local btn = Instance.new("TextButton",frame); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.BorderSizePixel=0
    btn.Activated:Connect(function()
        toggle.value = not toggle.value
        fill.Visible = toggle.value
        if callback then pcall(callback, toggle.value) end
    end)
    function toggle:Set(v) toggle.value=v; fill.Visible=v; if callback then pcall(callback,v) end end
    function toggle:Get() return toggle.value end
    return toggle
end

-- ── Slider widget ─────────────────────────────────────────────────────────
local function _mkSlider(parent, name, minV, maxV, default, callback, step)
    step = step or 1
    local isFloat = (step < 1)
    local function snapVal(v)
        if step <= 0 then return math.clamp(v,minV,maxV) end
        return math.clamp(math.floor((v-minV)/step+0.5)*step+minV, minV, maxV)
    end
    local slider = {value = snapVal(default or minV)}
    local frame  = Instance.new("Frame", parent)
    frame.BorderSizePixel=0; frame.BackgroundTransparency=1; frame.Size=UDim2.new(1,0,0,32)
    local lbl = Instance.new("TextLabel", frame)
    lbl.TextStrokeTransparency=1; lbl.BorderSizePixel=0; lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(180,180,180); lbl.Size=UDim2.new(1,0,0,13); lbl.Position=UDim2.new(0,0,0,1)
    do if font then lbl.FontFace=font else lbl.Font=Enum.Font.GothamSemibold end end
    local touchArea = Instance.new("TextButton", frame)
    touchArea.Size=UDim2.new(1,0,0,18); touchArea.Position=UDim2.new(0,0,0,14)
    touchArea.BackgroundTransparency=1; touchArea.BorderSizePixel=0; touchArea.Text=""
    local track = Instance.new("Frame", touchArea)
    track.Size=UDim2.new(1,0,0,8); track.Position=UDim2.new(0,0,0.5,-4)
    track.BackgroundColor3=Color3.fromRGB(28,28,28); track.BorderSizePixel=0
    local fill = Instance.new("Frame", track)
    fill.Size=UDim2.new(0,0,1,0); fill.Position=UDim2.new(0,0,0,0)
    fill.BackgroundColor3=mainColor; fill.BorderSizePixel=0
    local function fmtVal(v)
        if isFloat then return string.format("%.2f", v) else return tostring(v) end
    end
    local tweenInfo = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function refreshBar(val)
        local pos = math.clamp((val-minV)/math.max(maxV-minV,0.0001), 0, 1)
        TweenService:Create(fill, tweenInfo, {Size=UDim2.new(pos,0,1,0)}):Play()
        lbl.Text = name..": "..fmtVal(val)
    end
    local draggingSl = false
    local function updateSl(inputPos)
        local relX = inputPos.X - track.AbsolutePosition.X
        local pos  = math.clamp(relX/math.max(track.AbsoluteSize.X,1), 0, 1)
        slider.value = snapVal(minV + (maxV-minV)*pos)
        refreshBar(slider.value)
        if callback then pcall(callback, slider.value) end
    end
    touchArea.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            draggingSl=true; updateSl(i.Position)
        end
    end)
    touchArea.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingSl=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not draggingSl then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then updateSl(i.Position) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingSl=false end
    end)
    refreshBar(slider.value)
    function slider:Set(v) slider.value=snapVal(v); refreshBar(slider.value); if callback then pcall(callback,slider.value) end end
    function slider:Get() return slider.value end
    return slider
end

-- ── Dropdown widget ───────────────────────────────────────────────────────
local function _mkDropdown(parent, name, options, default, callback)
    local dropdown={value=default or options[1]}
    local frame=Instance.new("Frame",parent)
    frame.BorderSizePixel=0; frame.BackgroundColor3=Color3.fromRGB(0,0,0)
    frame.Size=UDim2.new(1,0,0,18); frame.BackgroundTransparency=1
    local lbl=Instance.new("TextLabel",frame); lbl.TextStrokeTransparency=1; lbl.BorderSizePixel=0
    lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(200,200,200); lbl.Size=UDim2.new(0.5,-5,1,0); lbl.Position=UDim2.new(0,5,0,0)
    lbl.Text=name; do if font then lbl.FontFace=font else lbl.Font=Enum.Font.GothamSemibold end end
    local selLbl=Instance.new("TextLabel",frame); selLbl.TextStrokeTransparency=1; selLbl.BorderSizePixel=0
    selLbl.TextSize=9; selLbl.TextXAlignment=Enum.TextXAlignment.Right; selLbl.BackgroundTransparency=1
    selLbl.TextColor3=mainColor; selLbl.Size=UDim2.new(0.5,-10,1,0); selLbl.Position=UDim2.new(0.5,0,0,0)
    selLbl.Text=dropdown.value
    do if font then selLbl.FontFace=font else selLbl.Font=Enum.Font.GothamSemibold end end
    selLbl.TextTruncate=Enum.TextTruncate.AtEnd
    local ddGui=Instance.new("ScreenGui"); ddGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ddGui.DisplayOrder=999
    pcall(function() ddGui.Parent=game:GetService("CoreGui") end)
    if not ddGui.Parent then ddGui.Parent=LocalPlayer:WaitForChild("PlayerGui") end
    local optOuter=Instance.new("Frame",ddGui); optOuter.BorderSizePixel=0
    optOuter.BackgroundColor3=Color3.fromRGB(8,8,8); optOuter.Size=UDim2.new(0,0,0,0); optOuter.Visible=false
    optOuter.ClipsDescendants=true
    Instance.new("UIStroke",optOuter).Color=Color3.fromRGB(40,40,40)
    local optFrame=Instance.new("ScrollingFrame",optOuter)
    optFrame.Size=UDim2.new(1,0,1,0); optFrame.Position=UDim2.new(0,0,0,0)
    optFrame.BackgroundTransparency=1; optFrame.BorderSizePixel=0
    optFrame.ScrollBarThickness=4; optFrame.ScrollBarImageColor3=mainColor
    optFrame.ScrollingDirection=Enum.ScrollingDirection.Y
    optFrame.CanvasSize=UDim2.new(0,0,0,0); optFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
    optFrame.ElasticBehavior=Enum.ElasticBehavior.Never
    Instance.new("UIListLayout",optFrame).SortOrder=Enum.SortOrder.LayoutOrder
    local expanded=false
    local MAX_DD_H=200
    for _,opt in ipairs(options) do
        local btn=Instance.new("TextButton",optFrame); btn.Size=UDim2.new(1,0,0,22); btn.BackgroundColor3=Color3.fromRGB(12,12,12)
        btn.BorderSizePixel=0; btn.Text=opt
        do if font then btn.FontFace=font else btn.Font=Enum.Font.GothamSemibold end end
        btn.TextSize=9; btn.TextColor3=Color3.fromRGB(200,200,200)
        btn.Activated:Connect(function()
            dropdown.value=opt; selLbl.Text=opt
            TweenService:Create(optOuter,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,frame.AbsoluteSize.X,0,0)}):Play()
            task.delay(0.15,function() optOuter.Visible=false end); expanded=false
            if callback then pcall(callback,opt) end
        end)
    end
    local clickBtn=Instance.new("TextButton",frame); clickBtn.Size=UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency=1; clickBtn.Text=""
    local function toggleDD()
        expanded=not expanded
        if expanded then
            local ap=frame.AbsolutePosition; local as=frame.AbsoluteSize
            optOuter.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y); optOuter.Size=UDim2.new(0,as.X,0,0); optOuter.Visible=true
            local targetH=math.min(#options*22,MAX_DD_H)
            TweenService:Create(optOuter,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,as.X,0,targetH)}):Play()
        else
            TweenService:Create(optOuter,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,frame.AbsoluteSize.X,0,0)}):Play()
            task.delay(0.15,function() optOuter.Visible=false end)
        end
    end
    clickBtn.Activated:Connect(toggleDD)
    -- FIX: закрывать dropdown при клике вне его
    UserInputService.InputBegan:Connect(function(inp)
        if not expanded then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
            and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local mp = inp.Position
        local op = optOuter.AbsolutePosition; local os2 = optOuter.AbsoluteSize
        local fp = frame.AbsolutePosition;   local fs2 = frame.AbsoluteSize
        local inOpt = (mp.X>=op.X and mp.X<=op.X+os2.X and mp.Y>=op.Y and mp.Y<=op.Y+os2.Y)
        local inFrm = (mp.X>=fp.X and mp.X<=fp.X+fs2.X and mp.Y>=fp.Y and mp.Y<=fp.Y+fs2.Y)
        if not inOpt and not inFrm then
            expanded = false
            TweenService:Create(optOuter,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,frame.AbsoluteSize.X,0,0)}):Play()
            task.delay(0.15, function() optOuter.Visible = false end)
        end
    end)
    function dropdown:Set(v) dropdown.value=v; selLbl.Text=v; if callback then pcall(callback,v) end end
    function dropdown:Get() return dropdown.value end
    return dropdown
end

-- ── Color Picker (preset swatch) ──────────────────────────────────────────
local function _mkColorPicker(parent, name, default, callback)
    local picker = {color = default or Color3.fromRGB(255,255,255)}
    local _h, _s, _v = Color3.toHSV(picker.color)

    -- Row: label + swatch
    local frame = Instance.new("Frame", parent)
    frame.BorderSizePixel=0; frame.BackgroundTransparency=1
    frame.Size=UDim2.new(1,0,0,18)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Text=name; lbl.TextSize=9
    do if font then lbl.FontFace=font else lbl.Font=Enum.Font.GothamSemibold end end
    lbl.TextColor3=Color3.fromRGB(200,200,200); lbl.BackgroundTransparency=1
    lbl.Size=UDim2.new(1,-30,1,0); lbl.Position=UDim2.new(0,2,0,0)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency=1; lbl.BorderSizePixel=0

    local swatch = Instance.new("TextButton", frame)
    swatch.Size=UDim2.new(0,18,0,18)
    swatch.Position=UDim2.new(1,-22,0.5,-9)
    swatch.BackgroundColor3=picker.color
    swatch.BorderSizePixel=1; swatch.Text=""
    swatch.BorderColor3=Color3.fromRGB(80,80,80)

    -- HSV Popup GUI
    local popupGui=Instance.new("ScreenGui")
    popupGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    popupGui.DisplayOrder=1001
    pcall(function() popupGui.Parent=game:GetService("CoreGui") end)
    if not popupGui.Parent then popupGui.Parent=LocalPlayer:WaitForChild("PlayerGui") end

    local popup=Instance.new("Frame",popupGui)
    popup.Visible=false
    popup.Size=UDim2.new(0,162,0,152)
    popup.BackgroundColor3=Color3.fromRGB(12,12,12)
    popup.BorderSizePixel=1
    popup.BorderColor3=Color3.fromRGB(55,55,55)
    popup.ZIndex=2

    -- SV square (Saturation=X, Value=Y)
    local svOuter=Instance.new("Frame",popup)
    svOuter.Size=UDim2.new(0,142,0,100)
    svOuter.Position=UDim2.new(0,10,0,6)
    svOuter.BackgroundColor3=Color3.fromHSV(_h,1,1)
    svOuter.BorderSizePixel=0
    svOuter.ClipsDescendants=true
    svOuter.ZIndex=3

    -- white→transparent left→right (saturation overlay)
    local satLayer=Instance.new("Frame",svOuter)
    satLayer.Size=UDim2.new(1,0,1,0)
    satLayer.BackgroundColor3=Color3.new(1,1,1)
    satLayer.BorderSizePixel=0; satLayer.ZIndex=4
    local satGrad=Instance.new("UIGradient",satLayer)
    satGrad.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
    satGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(1,1),
    })

    -- transparent→black top→bottom (value overlay)
    local valLayer=Instance.new("Frame",svOuter)
    valLayer.Size=UDim2.new(1,0,1,0)
    valLayer.BackgroundColor3=Color3.new(0,0,0)
    valLayer.BorderSizePixel=0; valLayer.ZIndex=5
    local valGrad=Instance.new("UIGradient",valLayer)
    valGrad.Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0))
    valGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(1,0),
    })
    valGrad.Rotation=90

    -- SV cursor (white ring)
    local svCursor=Instance.new("Frame",svOuter)
    svCursor.Size=UDim2.new(0,8,0,8)
    svCursor.AnchorPoint=Vector2.new(0.5,0.5)
    svCursor.BackgroundTransparency=1; svCursor.BorderSizePixel=0
    svCursor.ZIndex=10
    Instance.new("UICorner",svCursor).CornerRadius=UDim.new(1,0)
    local svStroke=Instance.new("UIStroke",svCursor)
    svStroke.Color=Color3.new(1,1,1); svStroke.Thickness=2

    -- invisible drag surface over SV square
    local svBtn=Instance.new("TextButton",svOuter)
    svBtn.Size=UDim2.new(1,0,1,0)
    svBtn.BackgroundTransparency=1; svBtn.Text=""; svBtn.ZIndex=11

    -- Hue rainbow bar
    local hueBar=Instance.new("Frame",popup)
    hueBar.Size=UDim2.new(0,142,0,13)
    hueBar.Position=UDim2.new(0,10,0,111)
    hueBar.BackgroundColor3=Color3.new(1,1,1)
    hueBar.BorderSizePixel=0; hueBar.ZIndex=3
    local hueGrad=Instance.new("UIGradient",hueBar)
    hueGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,      Color3.fromHSV(0/6,   1,1)),
        ColorSequenceKeypoint.new(0.0833, Color3.fromHSV(0.5/6, 1,1)),
        ColorSequenceKeypoint.new(0.1667, Color3.fromHSV(1/6,   1,1)),
        ColorSequenceKeypoint.new(0.25,   Color3.fromHSV(1.5/6, 1,1)),
        ColorSequenceKeypoint.new(0.3333, Color3.fromHSV(2/6,   1,1)),
        ColorSequenceKeypoint.new(0.4167, Color3.fromHSV(2.5/6, 1,1)),
        ColorSequenceKeypoint.new(0.5,    Color3.fromHSV(3/6,   1,1)),
        ColorSequenceKeypoint.new(0.5833, Color3.fromHSV(3.5/6, 1,1)),
        ColorSequenceKeypoint.new(0.6667, Color3.fromHSV(4/6,   1,1)),
        ColorSequenceKeypoint.new(0.75,   Color3.fromHSV(4.5/6, 1,1)),
        ColorSequenceKeypoint.new(0.8333, Color3.fromHSV(5/6,   1,1)),
        ColorSequenceKeypoint.new(0.9167, Color3.fromHSV(5.5/6, 1,1)),
        ColorSequenceKeypoint.new(1,      Color3.fromHSV(5.9999/6, 1,1)),
    })

    -- hue cursor (thin white bar)
    local hueCursor=Instance.new("Frame",hueBar)
    hueCursor.Size=UDim2.new(0,3,1,4)
    hueCursor.AnchorPoint=Vector2.new(0.5,0.5)
    hueCursor.Position=UDim2.new(_h,0,0.5,0)
    hueCursor.BackgroundColor3=Color3.new(1,1,1)
    hueCursor.BorderSizePixel=0; hueCursor.ZIndex=6

    local hueBtn=Instance.new("TextButton",hueBar)
    hueBtn.Size=UDim2.new(1,0,1,0)
    hueBtn.BackgroundTransparency=1; hueBtn.Text=""; hueBtn.ZIndex=7

    -- Hex input row
    local hexFrame=Instance.new("Frame",popup)
    hexFrame.Size=UDim2.new(0,142,0,20)
    hexFrame.Position=UDim2.new(0,10,0,128)
    hexFrame.BackgroundColor3=Color3.fromRGB(20,20,20)
    hexFrame.BorderSizePixel=1; hexFrame.BorderColor3=Color3.fromRGB(50,50,50)
    hexFrame.ZIndex=3

    local hashLbl=Instance.new("TextLabel",hexFrame)
    hashLbl.Size=UDim2.new(0,14,1,0); hashLbl.Position=UDim2.new(0,3,0,0)
    hashLbl.BackgroundTransparency=1; hashLbl.BorderSizePixel=0
    hashLbl.Text="#"; hashLbl.TextSize=9
    hashLbl.TextColor3=Color3.fromRGB(90,90,90); hashLbl.ZIndex=4
    do if font then hashLbl.FontFace=font else hashLbl.Font=Enum.Font.GothamSemibold end end

    local hexBox=Instance.new("TextBox",hexFrame)
    hexBox.Size=UDim2.new(1,-18,1,0); hexBox.Position=UDim2.new(0,16,0,0)
    hexBox.BackgroundTransparency=1; hexBox.BorderSizePixel=0
    hexBox.PlaceholderText="ꜰꜰꜰꜰꜰꜰ"
    hexBox.PlaceholderColor3=Color3.fromRGB(60,60,60)
    hexBox.TextColor3=Color3.fromRGB(200,200,200)
    hexBox.TextSize=9; hexBox.ClearTextOnFocus=false
    hexBox.TextXAlignment=Enum.TextXAlignment.Left; hexBox.ZIndex=4
    do if font then hexBox.FontFace=font else hexBox.Font=Enum.Font.GothamSemibold end end

    -- Helpers
    local function colorToHex(c)
        return string.format("%02X%02X%02X",
            math.clamp(math.floor(c.R*255+0.5),0,255),
            math.clamp(math.floor(c.G*255+0.5),0,255),
            math.clamp(math.floor(c.B*255+0.5),0,255))
    end
    local function hexToColor(hex)
        hex=hex:gsub("[^%x]","")
        if #hex~=6 then return nil end
        local r=tonumber(hex:sub(1,2),16)
        local g=tonumber(hex:sub(3,4),16)
        local b=tonumber(hex:sub(5,6),16)
        if not(r and g and b) then return nil end
        return Color3.fromRGB(r,g,b)
    end

    local function refreshUI(fire)
        local col=Color3.fromHSV(_h,_s,_v)
        picker.color=col
        swatch.BackgroundColor3=col
        svOuter.BackgroundColor3=Color3.fromHSV(_h,1,1)
        svCursor.Position=UDim2.new(_s,0,1-_v,0)
        hueCursor.Position=UDim2.new(_h,0,0.5,0)
        hexBox.Text=colorToHex(col)
        if fire and callback then pcall(callback,col) end
    end

    -- SV drag
    local svDrag=false
    local function onSV(inp)
        local sz=svOuter.AbsoluteSize; local op=svOuter.AbsolutePosition
        _s=math.clamp((inp.Position.X-op.X)/sz.X,0,1)
        _v=math.clamp(1-(inp.Position.Y-op.Y)/sz.Y,0,1)
        refreshUI(true)
    end
    svBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
            svDrag=true; onSV(i) end
    end)
    svBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then svDrag=false end
    end)

    -- Hue drag
    local hueDrag=false
    local function onHue(inp)
        local ox=hueBar.AbsolutePosition.X; local ow=hueBar.AbsoluteSize.X
        _h=math.clamp((inp.Position.X-ox)/ow,0,0.9999)
        refreshUI(true)
    end
    hueBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
            hueDrag=true; onHue(i) end
    end)
    hueBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then hueDrag=false end
    end)

    -- FIX: сохраняем соединения чтобы отключить при уничтожении picker'а
    local _pickerConns = {}
    _pickerConns[1] = UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch then
            if svDrag  then onSV(i)  end
            if hueDrag then onHue(i) end
        end
    end)
    _pickerConns[2] = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
            svDrag=false; hueDrag=false end
    end)
    frame.Destroying:Connect(function()
        for _, c in ipairs(_pickerConns) do pcall(function() c:Disconnect() end) end
        pcall(function() popupGui:Destroy() end)
    end)

    -- Hex input confirm
    hexBox.FocusLost:Connect(function()
        local c=hexToColor(hexBox.Text)
        if c then _h,_s,_v=Color3.toHSV(c); refreshUI(true) end
    end)

    -- Open / close popup
    local open=false
    swatch.MouseButton1Click:Connect(function()
        open=not open
        if open then
            local ap=swatch.AbsolutePosition; local as2=swatch.AbsoluteSize
            local px=ap.X-72; local py=ap.Y+as2.Y+4
            local vp=workspace.CurrentCamera.ViewportSize
            if px+162>vp.X then px=vp.X-166 end
            if px<4 then px=4 end
            if py+152>vp.Y then py=ap.Y-156 end
            popup.Position=UDim2.new(0,px,0,py)
            hexBox.Text=colorToHex(picker.color)
        end
        popup.Visible=open
    end)

    UserInputService.InputBegan:Connect(function(inp)
        if not open then return end
        if inp.UserInputType~=Enum.UserInputType.MouseButton1
            and inp.UserInputType~=Enum.UserInputType.Touch then return end
        if svDrag or hueDrag then return end
        local mp=inp.Position
        local pp=popup.AbsolutePosition; local ps=popup.AbsoluteSize
        local sp=swatch.AbsolutePosition; local ss=swatch.AbsoluteSize
        local inP=(mp.X>=pp.X and mp.X<=pp.X+ps.X and mp.Y>=pp.Y and mp.Y<=pp.Y+ps.Y)
        local inS=(mp.X>=sp.X and mp.X<=sp.X+ss.X and mp.Y>=sp.Y and mp.Y<=sp.Y+ss.Y)
        if not inP and not inS then open=false; popup.Visible=false end
    end)

    refreshUI(false)

    function picker:Set(c)
        picker.color=c; swatch.BackgroundColor3=c
        _h,_s,_v=Color3.toHSV(c); refreshUI(false)
        if callback then pcall(callback,c) end
    end
    function picker:Get() return picker.color end
    return picker
end

-- ── Label widget ──────────────────────────────────────────────────────────
local function _mkLabel(parent, text)
    local lf = Instance.new("TextLabel", parent)
    lf.Text=text; lf.TextSize=9
    do if font then lf.FontFace=font else lf.Font=Enum.Font.GothamSemibold end end
    lf.TextColor3=Color3.fromRGB(160,160,160); lf.BackgroundTransparency=1
    lf.Size=UDim2.new(1,0,0,16); lf.TextXAlignment=Enum.TextXAlignment.Left
    lf.TextStrokeTransparency=1; lf.BorderSizePixel=0
    local stub = { label = lf } -- FIX: expose real label
    function stub:Set(t) lf.Text = t end -- FIX: allow updating text
    function stub:AddColorPicker() return stub end
    return stub
end

-- ── Notification ──────────────────────────────────────────────────────────
local _notifGui = nil
local function _notify(title, desc, t)
    t = t or 3
    if not _notifGui then
        _notifGui = Instance.new("ScreenGui")
        _notifGui.Name = "BH_Notifs"
        _notifGui.ResetOnSpawn = false
        _notifGui.IgnoreGuiInset = true
        pcall(function() _notifGui.Parent = game:GetService("CoreGui") end)
        if not _notifGui.Parent then _notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end
    local f = Instance.new("Frame", _notifGui)
    local _isWelcome = (title == "Welcome | Buter.cel")
    f.Size = UDim2.fromOffset(220, _isWelcome and 32 or 44)
    if _isWelcome then
        f.AnchorPoint = Vector2.new(0.5, 0); f.Position = UDim2.new(0.5, 0, 1, -60)
    else
        f.Position = UDim2.new(1, -230, 1, -60)
    end
    f.BackgroundColor3 = Color3.fromRGB(10, 10, 10); f.BorderSizePixel = 0
    local st = Instance.new("UIStroke", f); st.Color = Color3.fromRGB(45,45,45); st.Thickness = 1
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local tl = Instance.new("TextLabel", f)
    if _isWelcome then
        tl.Size=UDim2.new(1,0,1,0); tl.Position=UDim2.fromOffset(0,0)
        tl.TextXAlignment=Enum.TextXAlignment.Center
    else
        tl.Size=UDim2.new(1,-8,0,18); tl.Position=UDim2.fromOffset(6,4)
        tl.TextXAlignment=Enum.TextXAlignment.Left
    end
    tl.BackgroundTransparency=1; tl.Text=title
    tl.TextColor3=mainColor; tl.FontFace=_buterFont; tl.TextSize=9
    local dl = Instance.new("TextLabel", f)
    dl.Size=UDim2.new(1,-8,0,16); dl.Position=UDim2.fromOffset(6,22)
    dl.BackgroundTransparency=1; dl.Text=desc
    dl.TextColor3=Color3.fromRGB(200,200,210); dl.FontFace=_buterFont; dl.TextSize=9
    dl.TextXAlignment=Enum.TextXAlignment.Left
    task.delay(t, function() pcall(function() f:Destroy() end) end)
end

local _uiReg = {}
local function _regUI(key, obj) if key and key ~= "" then _uiReg[key] = obj end end
local _LibAddGroupbox = nil

local function _buildMainUI()

-- ── Screen GUI ────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "VomaglaUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
pcall(function() gui.IgnoreGuiInset = true end)
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Drop-shadow wrapper
local mainOuter = Instance.new("Frame")
mainOuter.BackgroundTransparency = 1; mainOuter.BorderSizePixel = 0
mainOuter.Size = UDim2.new(0, 510, 0, 390)
mainOuter.Position = UDim2.new(0, 425, 0, 55)
mainOuter.Parent = gui; mainOuter.ZIndex = 0

-- Main window
local main = Instance.new("Frame")
main.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
main.Size = UDim2.new(0, 500, 0, 380)
main.Position = UDim2.new(0, 430, 0, 60)
main.BorderSizePixel = 0
main.Parent = gui
main.ClipsDescendants = true
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(45,45,45); mainStroke.Thickness = 1
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 4)

local isLocked = false

-- Toggle button (top-left, always visible)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 24, 0, 24)
toggleButton.Position = UDim2.new(0, 6, 0, 6)
toggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "ᴜɪ"; toggleButton.TextSize = 8
do if font then toggleButton.FontFace=font else toggleButton.Font=Enum.Font.GothamSemibold end end
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Parent = gui; toggleButton.ZIndex = 1000
local tglStroke = Instance.new("UIStroke", toggleButton)
tglStroke.Color = Color3.fromRGB(60,60,60); tglStroke.Thickness = 1
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,3)

local function toggleUIVisible()
    Library.IsVisible = not Library.IsVisible
    main.Visible = Library.IsVisible
    mainOuter.Visible = Library.IsVisible
    toggleButton.TextColor3 = Library.IsVisible and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
end
toggleButton.Activated:Connect(toggleUIVisible)

-- Dragging
local dragging, dragInput, dragStart, startPos, outerStartPos = false,nil,nil,nil,nil
local function beginDrag(input)
    if isLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position; outerStartPos=mainOuter.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging=false end
        end)
    end
end
local function onDragMove(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and not isLocked then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        mainOuter.Position = UDim2.new(outerStartPos.X.Scale, outerStartPos.X.Offset+delta.X, outerStartPos.Y.Scale, outerStartPos.Y.Offset+delta.Y)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- LEFT SIDEBAR
-- ════════════════════════════════════════════════════════════════
local SIDEBAR_W = 110

local sidebar = Instance.new("Frame", main)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.Position = UDim2.new(0,0,0,0)
sidebar.BackgroundColor3 = Color3.fromRGB(10,10,10)
sidebar.BorderSizePixel = 0; sidebar.ZIndex = 2

local sideRule = Instance.new("Frame", sidebar)
sideRule.Size = UDim2.new(0,1,1,0); sideRule.Position = UDim2.new(1,-1,0,0)
sideRule.BackgroundColor3 = Color3.fromRGB(40,40,40); sideRule.BorderSizePixel = 0

-- Logo area
local logoArea = Instance.new("Frame", sidebar)
logoArea.Size = UDim2.new(1,0,0,62); logoArea.Position = UDim2.new(0,0,0,0)
logoArea.BackgroundTransparency = 1; logoArea.BorderSizePixel = 0
logoArea.InputBegan:Connect(beginDrag); logoArea.InputChanged:Connect(onDragMove)

local logoImg = Instance.new("ImageLabel", logoArea)
logoImg.Size = UDim2.new(0,18,0,18); logoImg.Position = UDim2.new(0.5,-9,0,5)
logoImg.BackgroundTransparency=1; logoImg.BorderSizePixel=0
logoImg.Image = "rbxassetid://121755309866936"
logoImg.ImageColor3 = mainColor; logoImg.ScaleType = Enum.ScaleType.Fit

local logoTxt = Instance.new("TextLabel", logoArea)
logoTxt.Size = UDim2.new(1,0,0,14); logoTxt.Position = UDim2.new(0,0,0,25)
logoTxt.BackgroundTransparency=1; logoTxt.BorderSizePixel=0
logoTxt.Text = "ʙᴜᴛᴇʀ.ᴄᴇʟ"; logoTxt.TextSize=9
do if font then logoTxt.FontFace=font else logoTxt.Font=Enum.Font.GothamSemibold end end
logoTxt.TextColor3=Color3.fromRGB(220,220,220)
logoTxt.TextXAlignment=Enum.TextXAlignment.Center

local logoDsc = Instance.new("TextLabel", logoArea)
logoDsc.Size = UDim2.new(1,0,0,11); logoDsc.Position = UDim2.new(0,0,0,40)
logoDsc.BackgroundTransparency=1; logoDsc.BorderSizePixel=0
logoDsc.Text = "discord.gg/MvDnxsRFb"; logoDsc.TextSize=8
do if font then logoDsc.FontFace=font else logoDsc.Font=Enum.Font.GothamSemibold end end
logoDsc.TextColor3=mainColor
logoDsc.TextXAlignment=Enum.TextXAlignment.Center
logoDsc.TextTruncate=Enum.TextTruncate.AtEnd

-- Category list
local catList = Instance.new("Frame", sidebar)
catList.Size = UDim2.new(1,0,1,-62); catList.Position = UDim2.new(0,0,0,62)
catList.BackgroundTransparency=1; catList.BorderSizePixel=0
local catLayout = Instance.new("UIListLayout", catList)
catLayout.SortOrder=Enum.SortOrder.LayoutOrder; catLayout.Padding=UDim.new(0,1)

-- ════════════════════════════════════════════════════════════════
-- RIGHT CONTENT AREA
-- ════════════════════════════════════════════════════════════════
local contentArea = Instance.new("Frame", main)
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1,-SIDEBAR_W,1,0)
contentArea.Position = UDim2.new(0,SIDEBAR_W,0,0)
contentArea.BackgroundColor3 = Color3.fromRGB(15,15,15)
contentArea.BorderSizePixel=0; contentArea.ClipsDescendants=true

local subTabBarBg = Instance.new("Frame", contentArea)
subTabBarBg.Size=UDim2.new(1,0,0,26); subTabBarBg.Position=UDim2.new(0,0,0,0)
subTabBarBg.BackgroundColor3=Color3.fromRGB(15,15,15); subTabBarBg.BorderSizePixel=0
subTabBarBg.Visible=true -- FIX: was false, subtabs never showed
subTabBarBg.InputBegan:Connect(beginDrag); subTabBarBg.InputChanged:Connect(onDragMove)

local subTabBar=Instance.new("Frame",subTabBarBg)
subTabBar.BackgroundTransparency=1; subTabBar.Size=UDim2.new(1,0,1,0)
subTabBar.BorderSizePixel=0

local pageHolder = Instance.new("Frame", contentArea)
pageHolder.Size=UDim2.new(1,0,1,-26); pageHolder.Position=UDim2.new(0,0,0,26) -- FIX: offset below subtabbar
pageHolder.BackgroundTransparency=1; pageHolder.BorderSizePixel=0; pageHolder.ClipsDescendants=true

-- ════════════════════════════════════════════════════════════════
-- CATEGORY + PAGE SYSTEM
-- ════════════════════════════════════════════════════════════════
local categories = {}
local _activeCat = nil

local function _setActiveCat(cat)
    if _activeCat == cat then return end
    _activeCat = cat
    for _, c in ipairs(categories) do
        tw(c.button, {BackgroundColor3=Color3.fromRGB(10,10,10), TextColor3=Color3.fromRGB(110,110,110)})
        local _acc = c.button:FindFirstChild("Accent"); if _acc then _acc.Visible = false end
        for _, p in ipairs(c.pages) do
            p.tabBtn.Parent = nil
            p.content.Visible = false
        end
    end
    tw(cat.button, {BackgroundColor3=Color3.fromRGB(35,14,22), TextColor3=Color3.fromRGB(255, 200, 220)})
    local acc = cat.button:FindFirstChild("Accent")
    if acc then acc.Visible = true end
    for i, p in ipairs(cat.pages) do
        p.tabBtn.Parent = subTabBar
        p.tabBtn.Position = UDim2.new(0,(i-1)*62,0,0)
    end
    if cat.pages[1] and not cat._activePage then cat._activePage = cat.pages[1] end
    if cat._activePage then
        for _, p in ipairs(cat.pages) do
            p.content.Visible = (p == cat._activePage)
            local ul = p.tabBtn:FindFirstChild("UL")
            if ul then ul.Visible = (p == cat._activePage) end
            tw(p.tabBtn, {TextColor3 = (p == cat._activePage) and Color3.fromRGB(255, 200, 220) or Color3.fromRGB(110,110,110)})
        end
    end
end

local function _ensureCategory(catName)
    for _, c in ipairs(categories) do
        if c.name == catName then return c end
    end
    local idx = #categories + 1
    local c = {name=catName, pages={}, _activePage=nil}
    local btn = Instance.new("TextButton", catList)
    btn.Size=UDim2.new(1,0,0,30); btn.BackgroundColor3=Color3.fromRGB(10,10,10)
    btn.BorderSizePixel=0; btn.Text=catName; btn.TextSize=9
    do if font then btn.FontFace=font else btn.Font=Enum.Font.GothamSemibold end end
    btn.TextColor3=Color3.fromRGB(110,110,110); btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.LayoutOrder=idx
    local bpad = Instance.new("UIPadding", btn); bpad.PaddingLeft=UDim.new(0,10)
    btn.Activated:Connect(function() _setActiveCat(c) end)
    c.button = btn
    table.insert(categories, c)
    return c
end

local pages = {}
local _tabBtnIndex = 0

local function AddPage(catName, tabName)
    -- Single-arg call: AddPage("ᴛᴀʙɴᴀᴍᴇ") -> each tab is its own sidebar category
    if tabName == nil then tabName = catName end
    local cat = _ensureCategory(catName)
    local page = {name=tabName, columns={}, groupboxes={}, _cat=cat}
    local tabBtn = Instance.new("TextButton")
    tabBtn.TextStrokeTransparency=1; tabBtn.TextSize=9
    do if font then tabBtn.FontFace=font else tabBtn.Font=Enum.Font.GothamSemibold end end
    tabBtn.TextColor3=Color3.fromRGB(110,110,110)
    tabBtn.BackgroundColor3=Color3.fromRGB(15,15,15); tabBtn.BackgroundTransparency=0
    tabBtn.Size=UDim2.new(0,62,1,0); tabBtn.BorderSizePixel=0; tabBtn.Text=tabName

    local contentHolder = Instance.new("Frame", pageHolder)
    contentHolder.BorderSizePixel=0; contentHolder.BackgroundTransparency=1
    contentHolder.Size=UDim2.new(1,0,1,0); contentHolder.Position=UDim2.new(0,0,0,0)
    contentHolder.ClipsDescendants=false; contentHolder.Visible=false

    local colW = 170
    for i=1,2 do
        local col = Instance.new("ScrollingFrame", contentHolder)
        col.BorderSizePixel=0; col.BackgroundTransparency=1
        if i==1 then
            col.Size=UDim2.new(0,colW,1,0); col.Position=UDim2.new(0,4,0,0)
        else
            col.Size=UDim2.new(0,colW,1,0); col.Position=UDim2.new(0,colW+12,0,0)
        end
        col.ScrollBarThickness=2; col.ScrollBarImageColor3=mainColor
        col.ScrollingDirection=Enum.ScrollingDirection.Y
        col.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
        col.CanvasSize=UDim2.new(0,0,0,0); col.AutomaticCanvasSize=Enum.AutomaticSize.Y
        col.ScrollingEnabled=true
        local layout=Instance.new("UIListLayout",col)
        layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,2)
        local pad=Instance.new("UIPadding",col)
        pad.PaddingLeft=UDim.new(0,3); pad.PaddingRight=UDim.new(0,3); pad.PaddingTop=UDim.new(0,3)
        page.columns[i]=col
    end

    page.content=contentHolder; page.tabBtn=tabBtn; page.currentColumn=1

    local function switchToThisPage()
        if _activeCat ~= cat then _setActiveCat(cat) end
        cat._activePage = page
        for _, p in ipairs(cat.pages) do
            p.content.Visible = (p == page)
            local ul = p.tabBtn:FindFirstChild("UL"); if ul then ul.Visible = (p == page) end
            tw(p.tabBtn, {TextColor3 = (p == page) and Color3.fromRGB(255, 200, 220) or Color3.fromRGB(110,110,110)})
        end
    end
    tabBtn.Activated:Connect(switchToThisPage)

    table.insert(cat.pages, page)
    table.insert(pages, page)

    if #categories == 1 and #cat.pages == 1 then
        _setActiveCat(cat)
        switchToThisPage()
    end

    -- expose groupbox helpers directly on page for Paid.txt API compatibility
    function page:AddLeftGroupbox(name)  return makeGB(self, name, 1) end
    function page:AddRightGroupbox(name) return makeGB(self, name, 2) end

    return page
end

local function AddGroupbox(page, name, colIdx)
    colIdx = colIdx or 1
    local targetCol = page.columns[colIdx]
    local gb = {name=name, content=nil}
    local frame = Instance.new("Frame", targetCol)
    frame.BorderSizePixel=0; frame.BackgroundTransparency=1
    frame.Size=UDim2.new(1,0,0,0); frame.AutomaticSize=Enum.AutomaticSize.Y
    local header=Instance.new("Frame",frame); header.Size=UDim2.new(1,0,0,18)
    header.BackgroundTransparency=1; header.BorderSizePixel=0
    local hdrBox=Instance.new("Frame",header)
    hdrBox.Size=UDim2.new(1,-8,0,14); hdrBox.Position=UDim2.new(0,4,0,2)
    hdrBox.BackgroundTransparency=1; hdrBox.BorderSizePixel=0
    local hdrStroke=Instance.new("UIStroke",hdrBox)
    hdrStroke.Color=mainColor; hdrStroke.Thickness=1; hdrStroke.Transparency=0.4
    Instance.new("UICorner",hdrBox).CornerRadius=UDim.new(0,0)
    local lbl=Instance.new("TextLabel",hdrBox)
    lbl.TextStrokeTransparency=1; lbl.BorderSizePixel=0; lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.BackgroundTransparency=1
    lbl.TextColor3=mainColor; lbl.Size=UDim2.new(1,-6,1,0); lbl.Position=UDim2.new(0,5,0,0)
    lbl.Text=name
    do if font then lbl.FontFace=font else lbl.Font=Enum.Font.GothamSemibold end end
    local content=Instance.new("Frame",frame)
    content.Size=UDim2.new(1,0,0,0); content.Position=UDim2.new(0,0,0,19)
    content.BackgroundTransparency=1; content.BorderSizePixel=0; content.AutomaticSize=Enum.AutomaticSize.Y
    local layout=Instance.new("UIListLayout",content); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,1)
    local pad=Instance.new("UIPadding",content); pad.PaddingBottom=UDim.new(0,3)
    gb.frame=frame; gb.content=content
    return gb
end
_LibAddGroupbox = AddGroupbox

-- makeGB wraps AddGroupbox and exposes the widget methods
function makeGB(page, name, col)
    local gb = AddGroupbox(page, name, col)
    local c = gb.content
    local o = {}
    o.content = c
    function o:AddToggle(key, data)
        local t = _mkToggle(c, data.Text or key, data.Default, data.Callback)
        _regUI(key, t); return t
    end
    function o:AddSlider(key, data)
        local step = data.Rounding ~= nil and (data.Rounding == 0 and 1 or data.Rounding) or (data.Step or 1)
        local s = _mkSlider(c, data.Text or key, data.Min or 0, data.Max or 100, data.Default, data.Callback, step)
        _regUI(key, s); return s
    end
    function o:AddDropdown(key, data)
        local vals = data.Values or {}
        -- FIX: data.Default может быть числом (индекс) или строкой (значение)
        local def
        if type(data.Default) == "number" then
            def = vals[data.Default] or vals[1]
        else
            def = data.Default or vals[1]
        end
        local d = _mkDropdown(c, data.Text or key, vals, def, data.Callback)
        _regUI(key, d); return d
    end
    function o:AddLabel(text)
        return _mkLabel(c, text)
    end
    function o:AddDivider()
        local div = Instance.new("Frame", c)
        div.Size = UDim2.new(1, 0, 0, 1)
        div.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        div.BorderSizePixel = 0
        return div
    end
    function o:AddColorPicker(key, data)
        local p = _mkColorPicker(c, data.Title or key, data.Default, data.Callback)
        _regUI(key, p); return p
    end
    function o:AddTextbox(key, data)
        local frame = Instance.new("Frame", c)
        frame.Size=UDim2.new(1,0,0,38); frame.BackgroundTransparency=1; frame.BorderSizePixel=0
        local lbl2 = Instance.new("TextLabel", frame)
        lbl2.Size=UDim2.new(1,-10,0,14); lbl2.Position=UDim2.new(0,5,0,0)
        lbl2.BackgroundTransparency=1; lbl2.Text=data.Text or key
        lbl2.TextColor3=Color3.fromRGB(180,180,180); lbl2.TextSize=9
        do if font then lbl2.FontFace=font else lbl2.Font=Enum.Font.GothamSemibold end end
        lbl2.TextXAlignment=Enum.TextXAlignment.Left; lbl2.BorderSizePixel=0; lbl2.TextStrokeTransparency=1
        local box = Instance.new("TextBox", frame)
        box.Size=UDim2.new(1,-10,0,20); box.Position=UDim2.new(0,5,0,16)
        box.BackgroundColor3=Color3.fromRGB(18,18,18); box.BorderSizePixel=0
        box.Text=data.Default or ""; box.PlaceholderText=data.Text or key
        box.TextColor3=Color3.fromRGB(200,200,200); box.PlaceholderColor3=Color3.fromRGB(70,70,70)
        box.TextSize=9; do if font then box.FontFace=font else box.Font=Enum.Font.GothamSemibold end end
        box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=false
        local bs=Instance.new("UIStroke",box); bs.Color=Color3.fromRGB(50,50,50); bs.Thickness=1
        box:GetPropertyChangedSignal("Text"):Connect(function() if data.Callback then pcall(data.Callback, box.Text) end end)
        box.FocusLost:Connect(function() if data.Callback then pcall(data.Callback, box.Text) end end)
        return box
    end
    function o:AddButton(data)
        local btn = Instance.new("TextButton", c)
        btn.Size=UDim2.new(1,0,0,22); btn.BackgroundColor3=Color3.fromRGB(18,18,18)
        btn.BorderSizePixel=0; btn.Text=data.Text or "Button"
        btn.TextColor3=mainColor; btn.TextSize=9
        do if font then btn.FontFace=font else btn.Font=Enum.Font.GothamSemibold end end
        local bs=Instance.new("UIStroke",btn); bs.Color=Color3.fromRGB(50,50,50); bs.Thickness=1
        btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(28,28,28)},0.1) end)
        btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(18,18,18)},0.1) end)
        btn.MouseButton1Click:Connect(function() if data.Func then pcall(data.Func) end end)
        return btn
    end
    function o:AddKeybind() return o end
    return o
end

    local Tabs = {
        Combat    = AddPage("ᴄᴏᴍʙᴀᴛ"),
        Visuals   = AddPage("ᴠɪꜱᴜᴀʟꜱ"),
        ESP       = AddPage("ᴇꜱᴘ"),
        World     = AddPage("ᴡᴏʀʟᴅ"),
        Arms      = AddPage("ᴀʀᴍꜱ"),
        Resources = AddPage("ᴇꜱᴘ ᴇxᴛʀᴀ"),
        Sounds    = AddPage("ꜱᴏᴜɴᴅꜱ"),
        Misc      = AddPage("ᴍɪꜱᴄ"),
        Vehicles  = AddPage("ᴠᴇʜɪᴄʟᴇꜱ"),
        Skins     = AddPage("ꜱᴋɪɴꜱ"),
    }


    local _hxOrigSizes  = {}
    local _hxOrigTransp = {}
    local _hxConn       = nil

    local function _hxSetHead(head, enable)
        if not head or not head:IsA("BasePart") then return end
        if enable then
            if not _hxOrigSizes[head] then
                _hxOrigSizes[head]  = head.Size
                _hxOrigTransp[head] = head.Transparency
            end
            pcall(sethiddenproperty, head, "Size", Vector3.new(9, 9, 9))
            pcall(function() head.LocalTransparencyModifier = 1 end)
            pcall(function() head.Transparency = 1 end)
        else
            if _hxOrigSizes[head] then
                pcall(sethiddenproperty, head, "Size", _hxOrigSizes[head])
                pcall(function()
                    head.LocalTransparencyModifier = 0
                end)
                pcall(function() head.Transparency = _hxOrigTransp[head] or 0 end)
                _hxOrigSizes[head]  = nil
                _hxOrigTransp[head] = nil
            end
        end
    end

    local function _hxApplyAll()
        for model in pairs(HB.validCharacters) do
            local head = model:FindFirstChild("Head")
            if head then _hxSetHead(head, true) end
        end
    end

    local function _hxRestoreAll()
        for head in pairs(_hxOrigSizes) do _hxSetHead(head, false) end
    end

    _hxSetEnabled = function(v)
        if _hxConn then _hxConn:Disconnect(); _hxConn = nil end
        if v then
            _hxApplyAll()
            local _t = 0
            _hxConn = RunService.Heartbeat:Connect(function(dt)
                _t = _t + dt; if _t < 1.0 then return end; _t = 0
                _hxApplyAll()
            end)
        else
            _hxRestoreAll()
        end
    end

local _pmEnabled = false

-- ===== PM (dedsamodell) — глобальные переменные состояния =====
local SilentAim = {
    Enabled = false,
    SnaplineVisible = false,
    Rainbow = false,
    Thickness = 1.5,
    Color = Color3.fromRGB(255, 0, 0),
    Target = nil,
    HeadAvoid = 10,
    KillIndicatorEnabled = false
}

local _pmDefaultMaxDist = 60
local _pmWeaponMaxDist = {
    Bow              = 20,
    CrossBow         = 28,
    AR15             = 59,
    M4A1             = 62,
    SCAR             = 62,
    SVD              = 75,
    C9               = 20,
    UZI              = 40,
    USP9             = 30,
    Blunderbuss      = 20,
    PumpShotgun      = 63,
    EnergyRifle      = 83,
    GaussRifle       = 79,
    HMAR             = 50,
    LeverActionRifle = 77,
    PipePistol       = 30,
    PipeSMG          = 49,
    Magnum           = 30,
}

local PM = {
    Mode          = "Pro",
    AiCheck       = false,
    TeamCheck     = false,
    SleepCheck    = false,
    IndoorCheck   = false,
}

-- Drawing objects для dedsamodell PM
local saLine = Drawing.new("Line")
local saIndicator = Drawing.new("Text")
saIndicator.Visible = false
saIndicator.Text = "💀"
saIndicator.Size = 30
saIndicator.Center = true
saIndicator.Font = 3
saIndicator.Outline = true
saIndicator.OutlineColor = Color3.fromRGB(0,0,0)
saIndicator.Color = Color3.fromRGB(255, 50, 50)
saLine.Visible = false
saLine.Thickness = SilentAim.Thickness
saLine.Color = SilentAim.Color

local PMFov = {
    Enabled = false,
    Size    = 150,
    Color   = Color3.fromRGB(255,255,255),
    Circle  = Drawing.new("Circle"),
}
PMFov.Circle.Thickness    = 1
PMFov.Circle.Radius       = PMFov.Size
PMFov.Circle.Color        = PMFov.Color
PMFov.Circle.Transparency = 0.5
PMFov.Circle.Filled       = false
PMFov.Circle.Visible      = false

local PM_BODY_PARTS = {"Head","UpperTorso","LowerTorso","HumanoidRootPart","Middle","LeftArm","RightArm","LeftUpperLeg","RightUpperLeg","LeftLowerArm","RightLowerArm"}

local PMState = {
    NoVisHitChance = 50,
    Target         = nil,
    TargetPos      = nil,
    Cached         = nil,
}

-- ============ CUSTOM EQUIPPED ITEM TRACKER ============
-- Hooks __namecall to detect weapon equip events (event 9, args[4] = weapon name).
-- More reliable than FPS.GetEquippedItem() which breaks on game updates.
local _equippedItem = { name = nil, speed = 0, drop = 0 }

local _projectileInfo = {
    AR15             = { Speed = 1300, Drop = 3   },
    Blunderbuss      = { Speed = 600,  Drop = 3.5 },
    Bow              = { Speed = 300,  Drop = 3   },
    BowClient        = { Speed = 300,  Drop = 3   },
    C9               = { Speed = 600,  Drop = 3   },
    Conv556          = { Speed = 1300, Drop = 3   },
    Crossbow         = { Speed = 450,  Drop = 3   },
    EnergyRifle      = { Speed = 2000, Drop = 1.1 },
    Flintlock        = { Speed = 500,  Drop = 3.5 },
    GaussRifle       = { Speed = 3000, Drop = 2   },
    HMAR             = { Speed = 1000, Drop = 3.5 },
    LeverActionRifle = { Speed = 1200, Drop = 1.5 },
    M4A1             = { Speed = 1300, Drop = 4   },
    Magnum           = { Speed = 700,  Drop = 3   },
    Minigun          = { Speed = 1300, Drop = 3   },
    Musket           = { Speed = 500,  Drop = 3.5 },
    PipePistol       = { Speed = 500,  Drop = 3   },
    PipeSMG          = { Speed = 600,  Drop = 3   },
    PumpShotgun      = { Speed = 600,  Drop = 2   },
    Revolver         = { Speed = 700,  Drop = 3   },
    RPG              = { Speed = 300,  Drop = 0   },
    ["RPG-22"]       = { Speed = 300,  Drop = 0   },
    RPG22            = { Speed = 300,  Drop = 0   },
    SCAR             = { Speed = 1300, Drop = 4   },
    Sling            = { Speed = 400,  Drop = 3   },
    SVD              = { Speed = 1400, Drop = 2   },
    USP9             = { Speed = 600,  Drop = 3   },
    UZI              = { Speed = 600,  Drop = 3   },
}

local function _updateEquipped(itemName)
    local info = _projectileInfo[tostring(itemName)]
    if info then
        _equippedItem.name  = itemName
        _equippedItem.speed = info.Speed
        _equippedItem.drop  = info.Drop
    else
        _equippedItem.name  = nil
        _equippedItem.speed = 0
        _equippedItem.drop  = 0
    end
end

do
    local _oldNc = getrawmetatable(game).__namecall
    pcall(setreadonly, getrawmetatable(game), false)
    getrawmetatable(game).__namecall = newcclosure(function(self, ...)
        local args = {...}
        -- equip tracker: event code 9
        if args[1] == 9 and args[4] then
            pcall(_updateEquipped, args[4])
        end
        -- hitmarker: catch SendTCP "Hit" calls (event code 10, second arg == "Hit")
        -- Работает на мобайл; на ПК может идти через FireServer напрямую
        if args[1] == 10 and args[2] == "Hit" then
            local partName = tostring(args[6] or "")
            local isHead   = (partName == "Head" or partName == "Top")
            _spawnHitmarker(isHead)
        end
        -- ПК-фолбэк: некоторые эксплойты посылают FireServer с кодом события вторым аргументом
        local methodName = tostring(self) -- имя метода при :method() вызове
        if methodName and (methodName:lower():find("tcp") or (type(args[1]) == "number" and args[2] == "Hit")) then
            local partName = tostring(args[6] or "")
            local isHead   = (partName == "Head" or partName == "Top")
            _spawnHitmarker(isHead)
        end
        return _oldNc(self, ...)
    end)
    pcall(setreadonly, getrawmetatable(game), true)
end

-- Дополнительный ПК-фолбэк: слушаем TCP RemoteEvent напрямую
task.spawn(function()
    local tcp = Players.LocalPlayer:WaitForChild("TCP", 30)
    if not tcp then return end
    -- На ПК хит-пакеты могут приходить обратно через OnClientEvent
    tcp.OnClientEvent:Connect(function(eventCode, hitPart, ...)
        -- ловим подтверждение попадания от сервера (коды варьируются по билду)
        if eventCode == "Hit" or eventCode == "Damage" or eventCode == 10 then
            local partName = tostring(hitPart or "")
            local isHead   = (partName == "Head" or partName == "Top")
            _spawnHitmarker(isHead)
        end
    end)
    -- Также перехватываем исходящие FireServer вызовы через __index если доступно
    pcall(function()
        local origFire = tcp.FireServer
        if not origFire then return end
        local mt = getrawmetatable and getrawmetatable(tcp)
        if not mt then return end
        pcall(setreadonly, mt, false)
        local origIdx = rawget(mt, "__index") or mt.__index
        mt.__newindex = mt.__newindex -- preserve
        -- Слушаем через hookfunction если доступен
        if hookfunction then
            hookfunction(origFire, newcclosure(function(self2, ...)
                local a = {...}
                if a[1] == 10 and a[2] == "Hit" then
                    local partName = tostring(a[6] or "")
                    _spawnHitmarker(partName == "Head" or partName == "Top")
                end
                return origFire(self2, ...)
            end))
        end
        pcall(setreadonly, mt, true)
    end)
end)
-- ============ END CUSTOM EQUIPPED ITEM TRACKER ============

do
local SAFlags = { Enabled=false, SnapEnabled=false }

local _saSnapLine = Drawing.new("Line")
_saSnapLine.Visible   = false
_saSnapLine.Color     = Color3.fromRGB(255, 255, 255)
_saSnapLine.Thickness = 1

local _saTargetCircle = Drawing.new("Circle")
_saTargetCircle.Visible   = false
_saTargetCircle.Thickness = 1
_saTargetCircle.Color     = Color3.fromRGB(255, 255, 255)
_saTargetCircle.Radius    = 2
_saTargetCircle.Filled    = false

local _hookMagicBullet  -- forward declaration; defined further below

local _saHL = Instance.new("Highlight")
_saHL.Name             = "SA_Highlight"
_saHL.FillTransparency = 1
_saHL.OutlineColor     = Color3.fromRGB(255, 255, 255)
pcall(function() _saHL.Parent = game:GetService("CoreGui") end)

local SAV = {
    Classes      = nil,
    CameraClient = nil,
    FPSClient    = nil,
    PlayerReg    = nil,
    OldGetCFrame = nil,
    Hooked       = false,
    Camera       = nil,
}

local _validGuns = {
    "AR15", "Blunderbuss", "Bow", "BowClient", "C9", "Conv556",
    "Crossbow", "EnergyRifle", "Flintlock", "GaussRifle", "HMAR",
    "LeverActionRifle", "M4A1", "Magnum", "Minigun", "Musket",
    "PipePistol", "PipeSMG", "PumpShotgun", "Revolver",
    "RPG", "RPG-22", "RPG22", "SCAR", "Sling", "SVD", "USP9", "UZI",
}

local function _isValidGun(gun)
    return table.find(_validGuns, tostring(gun)) ~= nil
end

local function _saGetClosest()
    if not SAV.PlayerReg then return nil, nil end
    local cam = SAV.Camera or GetCamera()
    if not cam then return nil, nil end
    local baseR   = S.FovCircleRadius or 150
    local scaledR = baseR
    local center  = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closestTarget, targetVelocity, closestDistance = nil, nil, math.huge
    for _, v in next, SAV.PlayerReg do
        if v.type == "Player" and not v.sleeping and v.model and v.model:FindFirstChild("HumanoidRootPart") then
            local distanceToPlayer = (v.model.HumanoidRootPart.Position - cam.CFrame.Position).Magnitude
            local screenPoint = cam:WorldToViewportPoint(v.model.Head.Position)
            local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
            if distanceToPlayer <= 1000 and distanceFromCenter <= scaledR and distanceToPlayer < closestDistance then
                closestTarget = v.model
                targetVelocity = v.velocityVector
                closestDistance = distanceToPlayer
            end
        end
    end
    return closestTarget, targetVelocity
end

local function _calcBulletDrop(tPos, tVel, cPos, pSpeed, pDrop)
    if not tPos or not cPos then return tPos end
    pSpeed = (type(pSpeed) == "number" and pSpeed > 0) and pSpeed or 200
    pDrop  = (type(pDrop)  == "number") and pDrop or 0
    local dTT = (tPos - cPos).Magnitude
    local tTT = dTT / math.max(pSpeed, 1)
    local hVel = tVel and Vector3.new(tVel.X, 0, tVel.Z) * 7 or Vector3.zero
    local vVel = tVel and Vector3.new(0, tVel.Y, 0) * 2 or Vector3.zero
    local pTP  = tPos + ((hVel + vVel) * tTT)
    local dP   = pDrop ~= 0 and (-pDrop ^ (tTT * pDrop) + 1) or 0
    return pTP - Vector3.new(0, dP, 0)
end

local function _hookSA()
    if SAV.Hooked then return end

    -- Setup camera ref
    local rawCam = game:GetService("Workspace").CurrentCamera
    SAV.Camera = rawCam and pcall(cloneref, rawCam) and cloneref(rawCam) or rawCam

    -- Try to find CameraClient via getrenv()._G.classes (old method)
    local foundViaClasses = false
    pcall(function()
        local g = getrenv()._G
        if g and g.classes and g.classes.Camera then
            SAV.CameraClient = g.classes.Camera
            foundViaClasses = true
        end
    end)

    -- Fallback: search getgc() for a table with GetCFrame method (CameraClient)
    if not foundViaClasses then
        pcall(function()
            for _, v in pairs(getgc()) do
                if type(v) == "table" and type(v.GetCFrame) == "function"
                    and type(v.SetCFrame) == "function" then
                    SAV.CameraClient = v
                    break
                end
            end
        end)
    end

    -- Search for PlayerReg via PlayerClient script
    pcall(function()
        local function GetFunction(Script, Line)
            for _, v in pairs(getgc()) do
                if typeof(v) == "function" then
                    local ok2, src = pcall(debug.info, v, "s")
                    local ok3, ln  = pcall(debug.info, v, "l")
                    if ok2 and ok3 and type(src)=="string" and src:find(Script) and ln == Line then
                        return v
                    end
                end
            end
        end
        for _, ln in ipairs({588, 585, 590, 580, 595, 575, 600, 605, 610, 560, 550}) do
            local fn = GetFunction("PlayerClient", ln)
            if fn then
                for i = 1, 10 do
                    local ok2, reg = pcall(debug.getupvalue, fn, i)
                    if ok2 and type(reg) == "table" then
                        local hasModel = false
                        for _, entry in pairs(reg) do
                            if type(entry) == "table" and typeof(entry.model) == "Instance" then
                                hasModel = true; break
                            end
                        end
                        if hasModel then SAV.PlayerReg = reg; break end
                    end
                end
                if SAV.PlayerReg then break end
            end
        end
    end)

    -- Hook GetCFrame if we found CameraClient
    if SAV.CameraClient and type(SAV.CameraClient.GetCFrame) == "function" then
        SAV.OldGetCFrame = SAV.CameraClient.GetCFrame
        SAV.CameraClient.GetCFrame = function()
            if not SAFlags.Enabled then return SAV.OldGetCFrame() end
            local closest, velocityVector = _saGetClosest()
            if _equippedItem.name and closest and closest:FindFirstChild("HumanoidRootPart") and _isValidGun(_equippedItem.name) then
                local cam = SAV.Camera or GetCamera()
                local predictedPosition = _calcBulletDrop(
                    closest.Head.Position,
                    velocityVector,
                    cam.CFrame.Position,
                    _equippedItem.speed,
                    _equippedItem.drop)
                return CFrame.new(cam.CFrame.Position, predictedPosition)
            end
            return SAV.OldGetCFrame()
        end
        SAV.Hooked = true
    end
end

local _saLastTarget = nil

-- Unified snap line + SA highlight render (PM target takes priority when PM is on)
RunService.RenderStepped:Connect(function()
    local cam = SAV.Camera or GetCamera()
    if not cam then return end

    -- SA highlight cleanup when SA is off
    if not SAFlags.Enabled then
        if _saHL.Adornee then _saHL.Adornee = nil end
        _saLastTarget = nil
    end

    -- Snap line: purely driven by SAFlags.SnapEnabled toggle, no other requirement
    if SAFlags.SnapEnabled then
        local lineTarget = nil
        local linePos    = nil

        -- PM is on and has a target? PMState.Target IS the closest body part, reproject live every frame
        if _pmEnabled and PMState.Target and PMState.Target.Parent and PMState.Target:IsA("BasePart") then
            local ok, hp = pcall(function() return cam:WorldToViewportPoint(PMState.Target.Position) end)
            if ok and hp.Z > 0 then
                lineTarget = PMState.Target
                linePos    = Vector2.new(hp.X, hp.Y)
            end
        else
            -- fall back to SA closest target - lock strictly to Head
            local closest, _ = _saGetClosest()
            if closest then
                local head = closest:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local ok, hp = pcall(function() return cam:WorldToViewportPoint(head.Position) end)
                    if ok and hp.Z > 0 then
                        local sx, sy = hp.X, hp.Y
                        local vp2 = cam.ViewportSize
                        if sx >= 0 and sx <= vp2.X and sy >= 0 and sy <= vp2.Y then
                            lineTarget = head
                            linePos    = Vector2.new(sx, sy)
                            if SAFlags.Enabled and _saLastTarget ~= closest then
                                _saHL.Adornee = closest
                                _saLastTarget = closest
                            end
                        end
                    end
                end
            end
        end

        if lineTarget and linePos then
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local fovR = S.FovCircleRadius or 150

            -- Only show line + dot if target is inside the FOV circle
            -- If outside, hide everything
            local dir  = linePos - center
            local dist = dir.Magnitude
            if dist > fovR then
                _saSnapLine.Visible     = false
                _saTargetCircle.Visible = false
            else
                _saSnapLine.From    = center
                _saSnapLine.To      = linePos
                _saSnapLine.Visible = true
                _saTargetCircle.Position = linePos
                _saTargetCircle.Visible  = true
            end
        else
            _saSnapLine.Visible     = false
            _saTargetCircle.Visible = false
            if _saLastTarget then _saHL.Adornee = nil; _saLastTarget = nil end
        end
    else
        _saSnapLine.Visible     = false
        _saTargetCircle.Visible = false
    end
end)

local NCV = {
    Hooked       = false,
    OldNamecall  = nil,
    Enabled      = false,
    CachedHeadPos= nil,
    Throttle     = 0,
}
RunService.Heartbeat:Connect(function(dt)
    NCV.Throttle = NCV.Throttle + dt
    if NCV.Throttle < 0.05 then return end
    NCV.Throttle = 0
    if not NCV.Enabled then NCV.CachedHeadPos = nil; return end
    local closest, _ = _saGetClosest()
    if not closest then NCV.CachedHeadPos = nil; return end
    local head = closest:FindFirstChild("Head")
    NCV.CachedHeadPos = head and head.Position or nil
end)

local function _hookNamecall()
    if NCV.Hooked then return end
    local ok = pcall(function()
        local gmt = getrawmetatable(game)
        NCV.OldNamecall = clonefunction(gmt.__namecall)
        setreadonly(gmt, false)
        gmt.__namecall = newcclosure(function(self, ...)
            if checkcaller() then return NCV.OldNamecall(self, ...) end
            if not NCV.Enabled or not NCV.CachedHeadPos then return NCV.OldNamecall(self, ...) end
            local args = {...}
            if args[1] == 10 then
                local cam = workspace.CurrentCamera
                if cam and cam:IsA("Camera") then
                    if args[2] == "Hit" then
                        args[6] = "Head"; args[7] = Vector3.zero; args[8] = NCV.CachedHeadPos
                    elseif args[2] == "Fire" then
                        args[4] = CFrame.new(cam.CFrame.Position, NCV.CachedHeadPos)
                    end
                end
            end
            return NCV.OldNamecall(self, table.unpack(args))
        end)
        setreadonly(gmt, true)
    end)
    if ok then NCV.Hooked = true end
end

local SABox = Tabs.Combat:AddRightGroupbox('ꜱɪʟᴇɴᴛ ᴀɪᴍ')
SABox:AddToggle('SilentAimEnabled', {Text='ᴇɴᴀʙʟᴇ ꜱɪʟᴇɴᴛ ᴀɪᴍ', Default=false,
    Callback=function(v)
        SAFlags.Enabled = v
        if v then
            _hookSA()
            _hookNamecall()
            _hookMagicBullet()
            NCV.Enabled = true
        else
            _saHL.Adornee = nil
            NCV.Enabled    = false
        end
    end})
SABox:AddToggle('SilentAimSnapline', {Text='ꜱɴᴀᴘʟɪɴᴇ ᴛᴏ ʜᴇᴀᴅ', Default=false,
    Callback=function(v)
        SAFlags.SnapEnabled = v
        if not v then
            _saSnapLine.Visible     = false
            _saTargetCircle.Visible = false
        end
    end})
-- ── FOV Circle (настройка FOV для Silent Aim) ──────────────────────────────
SABox:AddToggle('FovCircleVisible',{Text='ꜰᴏᴠ ᴠɪꜱɪʙʟᴇ',Default=false,
    Callback=function(v) S.FovCircleVisible=v end})
SABox:AddDropdown('FovShape',{Text='ꜱʜᴀᴘᴇ',Values={"ᴄɪʀᴄʟᴇ","ᴘᴏʟʏɢᴏɴ"},Default=1,
    Callback=function(v) S.FovShape=v end})
SABox:AddToggle('FovCircleFilled',{Text='ꜰɪʟʟ ꜰᴏᴠ',Default=false,
    Callback=function(v) S.FovCircleFilled=v end})
SABox:AddSlider('FovCircleRadius',{Text='ꜰᴏᴠ ꜱɪᴢᴇ',Default=150,Min=30,Max=400,
    Callback=function(v) S.FovCircleRadius=v end})
SABox:AddColorPicker('FovCircleColor',{Title='FOV Color',Default=Color3.fromRGB(255,255,255),
    Callback=function(v) S.FovCircleColor=v end})
SABox:AddSlider('FovCircleThickness',{Text='ᴛʜɪᴄᴋɴᴇꜱꜱ',Default=2,Min=1,Max=8,
    Callback=function(v) S.FovCircleThickness=v end})
-- (PM toggle moved to Player Manipulation groupbox below)
end


local MB = {
    Enabled        = false,
    AlwaysHit      = false,
    ForceHead      = false,
    HitboxBypass   = false,
    ProjectileCount= 0,
    Target         = nil,
}

RunService.Heartbeat:Connect(function()
    if not MB.Enabled and not MB.AlwaysHit then MB.Target = nil; return end
    local cam = GetCamera(); if not cam or not cam:IsA("Camera") then return end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local best, bestDist = nil, math.huge
    local ign = GetIgnoreFolder()
    local myChar = ign and ign:FindFirstChild("LocalCharacter")
    if SAV.PlayerReg then
        for _, v in next, SAV.PlayerReg do
            if v.type == "Player" and not v.sleeping and v.model then
                if v.model == myChar or v.model == LocalPlayer.Character then continue end
                local head = v.model:FindFirstChild("Head"); if not head then continue end
                local dist = (cam.CFrame.Position - head.Position).Magnitude
                if dist > 1200 then continue end
                local sp, on = SafeWorldToViewport(cam, head.Position)
                local sd = sp and on and (Vector2.new(sp.X,sp.Y)-center).Magnitude or dist*0.5
                if sd < S.FovCircleRadius and dist < bestDist then
                    best = v; bestDist = dist
                end
            end
        end
    else
        for model in pairs(HB.validCharacters) do
            if model == myChar or model == LocalPlayer.Character then continue end
            if _isSleeper(model) then continue end
            local head = model:FindFirstChild("Head"); if not head then continue end
            local dist = (cam.CFrame.Position - head.Position).Magnitude
            if dist > 1200 then continue end
            local sp, on = SafeWorldToViewport(cam, head.Position)
            local sd = sp and on and (Vector2.new(sp.X,sp.Y)-center).Magnitude or dist*0.5
            if sd < S.FovCircleRadius and dist < bestDist then
                best = {model=model, id=nil, velocityVector=nil}; bestDist = dist
            end
        end
    end
    MB.Target = best
end)

local function _mbPrediction(camPos, targetPos, targetData, weaponData)
    if not weaponData then return targetPos end
    local speed = weaponData.ProjectileSpeed or 100
    local drop  = weaponData.ProjectileDrop  or 0
    local vel   = (targetData and typeof(targetData.velocityVector) == "Vector3") and targetData.velocityVector or Vector3.zero
    local dist  = (targetPos - camPos).Magnitude
    local t     = dist / speed
    local arc   = CFrame.new(camPos, targetPos).UpVector * (drop^(t*drop) - 1)
    return targetPos + vel*(t*7.4) + arc, t
end

local _hookMagicBullet = function()
    local ok = pcall(function()
        local classes       = getrenv()._G.classes
        local netClient     = classes.NetClient
        local sendCodes     = classes.SendCodes
        local entityClient  = classes.EntityClient
        local repStorage    = game:GetService("ReplicatedStorage")
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {workspace.Const and workspace.Const.Ignore or workspace}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.CollisionGroup = "WeaponRaycast"
        raycastParams.IgnoreWater = true

        local function doRayCast(cameraCFrame, weaponData, isServer, ignoreInstance, overrideProjectileDrop)
            if not isServer then return end
            if not weaponData or not weaponData.ProjectileSpeed then return end

            local fireCFrame = cameraCFrame
            local saTarget   = nil

            if SAFlags.Enabled then
                local saClosest, saVel = _saGetClosest()
                if saClosest and saClosest:FindFirstChild("Head") then
                    if SAV.PlayerReg then
                        for _, v in next, SAV.PlayerReg do
                            if v.model == saClosest then saTarget = v; break end
                        end
                    end
                    local saVelSafe = (saVel and typeof(saVel) == "Vector3") and saVel or Vector3.new(0,0,0)
                    local saPred = _calcBulletDrop(
                        saClosest.Head.Position, saVelSafe,
                        cameraCFrame.Position,
                        weaponData.ProjectileSpeed,
                        weaponData.ProjectileDrop or 0)
                    if saPred then
                        fireCFrame = CFrame.new(cameraCFrame.Position, saPred)
                    end
                end
            end

            local projectileSpeed = weaponData.ProjectileSpeed
            local projectileDrop  = overrideProjectileDrop or weaponData.ProjectileDrop or 0
            MB.ProjectileCount = MB.ProjectileCount + 1
            local inventoryItem = MB.ProjectileCount

            local tracerPartClone = nil
            pcall(function()
                tracerPartClone = repStorage[weaponData.TracerPart]:Clone()
                tracerPartClone.CFrame = fireCFrame
                tracerPartClone.Parent = workspace.Const.Ignore
                if tracerPartClone:FindFirstChild("whiz") then tracerPartClone.whiz:Play() end
            end)

            local timeElapsed = 0
            local currentPosition = fireCFrame.Position
            local hasHit = false
            local fireSent = false
            local conn
            conn = RunService.RenderStepped:Connect(function(dt)
                if hasHit then
                    conn:Disconnect()
                    pcall(function() tracerPartClone:Destroy() end)
                    return
                end
                timeElapsed = timeElapsed + dt
                local arcTime = timeElapsed + 0.025
                local previousPosition = currentPosition
                currentPosition = (fireCFrame * CFrame.new(0, -projectileDrop^(timeElapsed*projectileDrop)+1, -timeElapsed*projectileSpeed)).Position
                local lookAtPos   = (fireCFrame * CFrame.new(0, -projectileDrop^(arcTime*projectileDrop)+1,   -arcTime*projectileSpeed)).Position
                pcall(function()
                    if tracerPartClone and tracerPartClone.Parent then
                        tracerPartClone.CFrame = CFrame.new(currentPosition, lookAtPos)
                    end
                end)
                if not (SAFlags.Enabled and saTarget) then
                    local result = workspace:Raycast(previousPosition, currentPosition - previousPosition, raycastParams)
                    if result then
                        local dist2 = (currentPosition - previousPosition).Magnitude
                        timeElapsed = timeElapsed - (dist2 - result.Distance) / projectileSpeed
                        pcall(function()
                            local hitEntity = entityClient.GetEntityFromPart(result.Instance)
                            if hitEntity then
                                netClient.SendTCP(sendCodes.INV_USE_ITEM, "Hit", inventoryItem, timeElapsed, hitEntity.id, result.Instance.Name, Vector3.zero, result.Position)
                               local isHead = (result.Instance.Name == "Head" or result.Instance.Name == "Top")
                               local screenPos = _getScreenPos(result.Position)
                                _spawnHitmarker(isHead, screenPos)                        
                            end
                        end)
                        pcall(function()
                            if tracerPartClone then
                                tracerPartClone.CFrame = CFrame.new(result.Position, lookAtPos) * CFrame.new(0,0,tracerPartClone.Size.Z/2)
                            end
                        end)
                        hasHit = true
                    end
                end
                if timeElapsed >= 3 then
                    conn:Disconnect()
                    pcall(function() tracerPartClone:Destroy() end)
                end
if result then
    local dist2 = (currentPosition - previousPosition).Magnitude
    timeElapsed = timeElapsed - (dist2 - result.Distance) / projectileSpeed
    pcall(function()
        local hitEntity = entityClient.GetEntityFromPart(result.Instance)
        if hitEntity then
            netClient.SendTCP(sendCodes.INV_USE_ITEM, "Hit", inventoryItem, timeElapsed, hitEntity.id, result.Instance.Name, Vector3.zero, result.Position)
            local isHead = (result.Instance.Name == "Head" or result.Instance.Name == "Top")
            local screenPos = _getScreenPos(result.Position)
            _spawnHitmarker(isHead, screenPos)
                 end
            end)
                end
            end)
        end

        classes.RangedWeaponClient.RayCastFunction = newcclosure(doRayCast)
        classes.BowClient.RayCastFunction = newcclosure(doRayCast)

        for _, v in pairs(getgc(true)) do
            if typeof(v) == "function" and islclosure and islclosure(v) then
                pcall(function()
                    local src = debug.info(v, "s")
                    local consts = debug.getconstants(v)
                    for i = 1, #consts do
                        local c = debug.getconstant(v, i)
                        if c == "CreateProjectile" and src and (src:find("RangedWeaponClient") or src:find("BowClient")) then
                            debug.setconstant(v, i, "RayCastFunction")
                        end
                    end
                end)
            end
        end
        warn("[TridentHub] Magic Bullet (RayCastFunction) hooked")
    end)
    if not ok then warn("[TridentHub] Magic Bullet hook failed") end
end

-- Jump Shoot (from dedsamodell — uses a floor Part to fake grounded state)
local CharacterJS = { Jumpshoot = false, JsPart = nil }
CharacterJS.Js = function()
    local p = Instance.new("Part", workspace)
    p.Name = "!.!"; p.Size = Vector3.new(4,0.2,4); p.Anchored = true
    p.Color = Color3.fromRGB(255,255,255); p.Transparency = 0.3; p.Material = Enum.Material.Neon
    local mesh = Instance.new("SpecialMesh"); mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://20329976"; mesh.Parent = p
    return p
end
CharacterJS.Update = function()
    while CharacterJS.Jumpshoot do
        local ok, mid = pcall(function()
            if workspace.Const and workspace.Const.Ignore and workspace.Const.Ignore.LocalCharacter then
                return workspace.Const.Ignore.LocalCharacter.Middle.Position
            end
            return nil
        end)
        if ok and mid and CharacterJS.JsPart and CharacterJS.JsPart.Parent then
            CharacterJS.JsPart.Position = mid - Vector3.new(0, 3.5, 0)
        end
        RunService.Heartbeat:Wait()
    end
end

local JumpShootBox = Tabs.Combat:AddLeftGroupbox('ᴊᴜᴍᴘ ꜱʜᴏᴏᴛ')
JumpShootBox:AddToggle('JumpShootEnabled', {Text='ᴊᴜᴍᴘ ꜱʜᴏᴏᴛ(⬆️🔫)', Default=false,
    Callback=function(v)
        Flags.jsEnabled = v
        CharacterJS.Jumpshoot = v
        if v then
            if not CharacterJS.JsPart or not CharacterJS.JsPart.Parent then
                CharacterJS.JsPart = CharacterJS.Js()
            end
            task.spawn(function() CharacterJS.Update() end)
        else
            if CharacterJS.JsPart then
                CharacterJS.JsPart:Destroy()
                CharacterJS.JsPart = nil
            end
        end
    end})

do
local HE = { Enabled=false, Size=9, OrigSizes={}, OrigTransp={}, Conn=nil }

local function _hePlateSize(s)
    return Vector3.new(s, s, s)
end

local function _heSetHead(head, enable)
    if not head or not head:IsA("BasePart") then return end
    if head.Name ~= "Head" then return end
    if enable then
        if not HE.OrigSizes[head] then
            HE.OrigSizes[head]  = head.Size
            HE.OrigTransp[head] = head.Transparency
        end
        pcall(sethiddenproperty, head, "Size", _hePlateSize(HE.Size))
        pcall(function() head.Transparency = 0.85 end)
        pcall(function() head.LocalTransparencyModifier = 0.85 end)
    else
        if HE.OrigSizes[head] then
            pcall(sethiddenproperty, head, "Size", HE.OrigSizes[head])
            pcall(function() head.Transparency = HE.OrigTransp[head] or 0 end)
            pcall(function() head.LocalTransparencyModifier = 0 end)
            HE.OrigSizes[head]  = nil
            HE.OrigTransp[head] = nil
        end
    end
end

local function _heApplyAll()
    local ign = GetIgnoreFolder()
    local myChar = ign and ign:FindFirstChild("LocalCharacter")
    for model in pairs(HB.validCharacters) do
        if model == myChar or model == LocalPlayer.Character then continue end
        local head = model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            _heSetHead(head, true)
        end
    end
end

local function _heRestoreAll()
    for head in pairs(HE.OrigSizes) do _heSetHead(head, false) end
end

local function _heSetEnabled(v)
    HE.Enabled = v
    if HE.Conn then HE.Conn:Disconnect(); HE.Conn = nil end
    if v then
        _heApplyAll()
        local _t = 0
        HE.Conn = RunService.Heartbeat:Connect(function(dt)
            _t = _t + dt; if _t < 0.08 then return end; _t = 0
            _heApplyAll()
        end)
    else
        _heRestoreAll()
    end
end

local HEBox = Tabs.Combat:AddLeftGroupbox('ʜᴇᴀᴅ ᴇxᴘᴀɴᴅᴇʀ')
HEBox:AddToggle('HeadExpanderEnabled', {Text='ᴇɴᴀʙʟᴇ ʜᴇᴀᴅ ᴇxᴘᴀɴᴅᴇʀ', Default=false,
    Callback=function(v)
        _heSetEnabled(v)
        if v then
            _hookNamecall()
            NCV.Enabled = true
        else
            if not SAFlags.Enabled then NCV.Enabled = false end
        end
    end})
HEBox:AddSlider('HeadExpanderSize', {
    Text    = 'ᴘʟᴀᴛᴇ ꜱɪᴢᴇ',
    Default = 5,
    Min     = 1,
    Max     = 6,
    Rounding= 0,
    Callback= function(v)
        HE.Size = v
        if HE.Enabled then
            _heRestoreAll()
            _heApplyAll()
        end
    end
})
end

-- (JumpShoot toggle moved above with CharacterJS engine)

do
local SJ = { Running=false, Stop=false, Gui=nil }

local function _doSlideJump()
    while SJ.Running do
        if SJ.Stop then break end
        keypress(0x57)
        keypress(0x10)
        task.wait(0.05)
        keypress(0x43)
        keypress(0x20)
        keyrelease(0x20)
        task.wait(0.5)
        keyrelease(0x43)
        keyrelease(0x10)
        task.wait(1.2)
    end
    keyrelease(0x57)
    keyrelease(0x10)
    keyrelease(0x43)
end

local function _createSJButton()
    if SJ.Gui then SJ.Gui:Destroy(); SJ.Gui = nil end
    SJ.Gui = Instance.new("ScreenGui")
    SJ.Gui.Name = "TH_SlideJump"
    SJ.Gui.ResetOnSpawn = false
    SJ.Gui.IgnoreGuiInset = true
    SJ.Gui.DisplayOrder = 999
    pcall(function() SJ.Gui.Parent = game:GetService("CoreGui") end)
    if not SJ.Gui.Parent then SJ.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local frame = Instance.new("Frame", SJ.Gui)
    frame.Size = UDim2.new(0, 100, 0, 80)
    frame.Position = UDim2.new(0, 10, 1, -150)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local fst = Instance.new("UIStroke", frame)
    fst.Color = Color3.fromRGB(40, 40, 40)
    fst.Thickness = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    btn.FontFace = _buterFont
    btn.TextSize = 10
    btn.TextColor3 = mainColor
    btn.Text = "ꜱʟɪᴅᴇ ᴊᴜᴍᴘ: ᴏꜰꜰ"
    btn.TextWrapped = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bst = Instance.new("UIStroke", btn)
    bst.Color = Color3.fromRGB(40, 40, 40)
    bst.Thickness = 1

    local function toggle()
        SJ.Running = not SJ.Running
        SJ.Stop = not SJ.Running
        if SJ.Running then
            btn.Text = "ꜱʟɪᴅᴇ ᴊᴜᴍᴘ: ᴏɴ"
            btn.TextColor3 = Color3.fromRGB(130, 255, 130)
            bst.Color = mainColor
            task.spawn(_doSlideJump)
        else
            btn.Text = "ꜱʟɪᴅᴇ ᴊᴜᴍᴘ: ᴏꜰꜰ"
            btn.TextColor3 = mainColor
            bst.Color = Color3.fromRGB(40, 40, 40)
        end
    end
    btn.MouseButton1Click:Connect(toggle)
    btn.TouchTap:Connect(toggle)
end

local SlideBox = Tabs.Combat:AddRightGroupbox('ꜱʟɪᴅᴇ ᴊᴜᴍᴘ')
SlideBox:AddToggle('SlideJumpEnabled', {Text='ᴇɴᴀʙʟᴇ ꜱʟɪᴅᴇ ᴊᴜᴍᴘ', Default=false,
    Callback=function(v)
        if v then
            _createSJButton()
        else
            SJ.Running = false; SJ.Stop = true
            if SJ.Gui then SJ.Gui:Destroy(); SJ.Gui = nil end
        end
    end})
end

    do
        local LootBox = Tabs.Combat:AddRightGroupbox('ɪɴꜱᴛᴀ ʟᴏᴏᴛ')
        local _lootGui=nil; local _lootEnabled=false
        local function CreateLootButton()
            if _lootGui then _lootGui:Destroy(); _lootGui=nil end
            _lootGui = Instance.new("ScreenGui")
            _lootGui.Name = "TH_FastLoot"; _lootGui.ResetOnSpawn = false
            _lootGui.IgnoreGuiInset = true; _lootGui.DisplayOrder = 999
            pcall(function() _lootGui.Parent = game:GetService("CoreGui") end)
            if not _lootGui.Parent then _lootGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

            -- outer pill container
            local btn = Instance.new("TextButton", _lootGui)
            btn.Size = UDim2.fromOffset(54, 26)
            btn.Position = UDim2.new(0.5, -27, 0.5, -13)
            btn.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 10
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", btn)
            st.Color = Color3.fromRGB(200, 120, 160); st.Thickness = 1

            -- top accent line
            local accent = Instance.new("Frame", btn)
            accent.Size = UDim2.new(0.6, 0, 0, 1)
            accent.Position = UDim2.new(0.2, 0, 0, 0)
            accent.BackgroundColor3 = Color3.fromRGB(255, 182, 210)
            accent.BorderSizePixel = 0
            Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

            -- icon label (left side)
            local icon = Instance.new("TextLabel", btn)
            icon.Size = UDim2.fromOffset(16, 26)
            icon.Position = UDim2.fromOffset(5, 0)
            icon.BackgroundTransparency = 1
            icon.Text = "+"
            icon.TextColor3 = Color3.fromRGB(255, 182, 210)
            icon.FontFace = _buterFont; icon.TextSize = 13
            icon.ZIndex = 11

            -- text label (right side)
            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, -22, 1, 0)
            lbl.Position = UDim2.fromOffset(20, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "ʟᴏᴏᴛ"
            lbl.TextColor3 = Color3.fromRGB(255, 220, 235)
            lbl.FontFace = _buterFont; lbl.TextSize = 9
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 11

            -- drag (Touch + Mouse для ПК)
            local drg, ds, sp2 = false, nil, nil
            btn.InputBegan:Connect(function(inp)
                local isTouch = inp.UserInputType == Enum.UserInputType.Touch
                local isMouse = inp.UserInputType == Enum.UserInputType.MouseButton1
                if isTouch or isMouse then
                    drg = true; ds = inp.Position; sp2 = btn.Position
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then drg = false end
                    end)
                end
            end)
            btn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then drg = false end
            end)
            local di
            btn.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch or
                   inp.UserInputType == Enum.UserInputType.MouseMovement then di = inp end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if inp == di and drg and sp2 then
                    local d = inp.Position - ds
                    btn.Position = UDim2.new(sp2.X.Scale, sp2.X.Offset + d.X, sp2.Y.Scale, sp2.Y.Offset + d.Y)
                end
            end)

            -- Функция лута (общая для Touch и Mouse/ПК)
            local function _doLoot()
                local tcp = Players.LocalPlayer:FindFirstChild("TCP"); if not tcp then return end
                st.Color = Color3.fromRGB(0, 200, 80)
                icon.TextColor3 = Color3.fromRGB(0, 230, 100)
                lbl.TextColor3 = Color3.fromRGB(180, 255, 200)
                task.spawn(function()
                    for i = 1, 25 do pcall(function() tcp:FireServer(12, i, true) end) end
                    task.wait(0.3)
                    st.Color = Color3.fromRGB(200, 120, 160)
                    icon.TextColor3 = Color3.fromRGB(255, 182, 210)
                    lbl.TextColor3 = Color3.fromRGB(255, 220, 235)
                end)
            end

            -- Touch (мобайл)
            btn.TouchTap:Connect(_doLoot)
            -- Mouse click (ПК)
            btn.MouseButton1Click:Connect(_doLoot)
        end
        LootBox:AddToggle('FastLootEnabled',{Text='ɪɴꜱᴛᴀ ʟᴏᴏᴛ(📦)',Default=false,
            Callback=function(v) _lootEnabled=v; if v then CreateLootButton() else if _lootGui then _lootGui:Destroy(); _lootGui=nil end end end})
    end

do
    local FastBox = Tabs.Combat:AddLeftGroupbox('ꜰᴀꜱᴛ ᴀᴛᴛᴀᴄᴋ')
    local _fastDrillEnabled=false; local _fastShootEnabled=false
    -- x150 скорость: оригинальный кулдаун 0.7 для дрели, делим на 150
    local _drillSpoofed = 0.1 / 900   -- ≈ 0.0046667
    local _shootSpoofed = 0.4 / 5   -- ≈ 0.0006667
    local _patchedDrill={}; local _patchedShoot={}
    local function _applyFastDrill()
        _patchedDrill={}
        task.defer(function()
            for _,v in pairs(getgc(true)) do
                if type(v)=="table" and not getmetatable(v) then
                    if rawget(v,"AttackCooldown") then
                        local realACD=v.AttackCooldown; local spoofed=_drillSpoofed
                        rawset(v,"AttackCooldown",spoofed)
                        setmetatable(v,{__index=function(_,k) if k=="AttackCooldown" then return realACD end end,__newindex=function(_,k,val) if k=="AttackCooldown" then realACD=val; rawset(v,k,spoofed) else rawset(v,k,val) end end})
                        table.insert(_patchedDrill,{tbl=v,key="AttackCooldown",real=realACD})
                    end
                end
            end
        end)
    end
    local function _restoreFastDrill() for _,e in ipairs(_patchedDrill) do pcall(function() setmetatable(e.tbl,nil); rawset(e.tbl,e.key,e.real) end) end; _patchedDrill={} end
    local function _applyFastShoot()
        _patchedShoot={}
        task.defer(function()
            for _,v in pairs(getgc(true)) do
                if type(v)=="table" and not getmetatable(v) then
                    if rawget(v,"UseRate") then
                        local realUR=v.UseRate; local spoofed=_shootSpoofed
                        rawset(v,"UseRate",spoofed)
                        setmetatable(v,{__index=function(_,k) if k=="UseRate" then return realUR end end,__newindex=function(_,k,val) if k=="UseRate" then realUR=val; rawset(v,k,spoofed) else rawset(v,k,val) end end})
                        table.insert(_patchedShoot,{tbl=v,key="UseRate",real=realUR})
                    end
                end
            end
        end)
    end
    local function _restoreFastShoot() for _,e in ipairs(_patchedShoot) do pcall(function() setmetatable(e.tbl,nil); rawset(e.tbl,e.key,e.real) end) end; _patchedShoot={} end

    -- Метод 2: getrenv-фолбэк для ПК (прямой патч через classes)
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local g = getrenv and getrenv()._G
            if not (g and g.classes) then return end
            if _fastDrillEnabled then
                for _, cls in ipairs({"MeleeWeaponClient","DrillClient","PickaxeClient","ToolClient"}) do
                    if g.classes[cls] and g.classes[cls].AttackCooldown ~= nil then
                        g.classes[cls].AttackCooldown = _drillSpoofed
                    end
                end
            end
            if _fastShootEnabled then
                for _, cls in ipairs({"RangedWeaponClient","BowClient","CrossBowClient","WeaponClient"}) do
                    if g.classes[cls] and g.classes[cls].UseRate ~= nil then
                        g.classes[cls].UseRate = _shootSpoofed
                    end
                end
            end
        end)
    end)

    FastBox:AddToggle('FastDrillEnabled',{Text='ꜰᴀꜱᴛ ᴅʀɪʟʟ (ᴀᴛᴛᴀᴄᴋᴄᴏᴏʟᴅᴏᴡɴ)',Default=false,
        Callback=function(v) _fastDrillEnabled=v; if v then _applyFastDrill() else _restoreFastDrill() end end})
    FastBox:AddToggle('FastShootEnabled',{Text='ꜰᴀꜱᴛ ꜱʜᴏᴏᴛ (ᴜꜱᴇʀᴀᴛᴇ)',Default=false,
        Callback=function(v) _fastShootEnabled=v; if v then _applyFastShoot() else _restoreFastShoot() end end})
end
-- ============ SPEEDHACK (без кубика, чистое управление скоростью) ============
do
    local speedhack = {
        enabled = false,
        silent = false,
        silentActive = false,
        speed = 60,
        downcliff = false,
        downcliffAccel = 50,
        downcliffFall = 10,
        forcesprint = false,
    }

    -- НАСТРОЙКИ (меняй смело)
    local FLIGHT_TIME = 0.83      -- время полёта на максимальной скорости
    local BRAKE1_SPEED = 43       -- первое торможение (сразу после полёта)
    local BRAKE1_DURATION = 0.39  -- сколько секунд держится 43
    local BRAKE2_SPEED = 17       -- вторая скорость (скольжение)
    local GLIDE_VERTICAL = -15    -- вертикальная скорость при скольжении
    local GLIDE_HORIZONTAL = 17   -- горизонтальная скорость при скольжении

    local function getCharParts()
        local constFolder = workspace:FindFirstChild("Const")
        if not constFolder then return nil, nil, nil end
        local ignFolder = constFolder:FindFirstChild("Ignore")
        if not ignFolder then return nil, nil, nil end
        local char = ignFolder:FindFirstChild("LocalCharacter")
        if not char then return nil, nil, nil end
        return char:FindFirstChild("Middle"), char:FindFirstChild("Bottom"), char:FindFirstChild("Top")
    end

    local speedState = {
        active = false,
        phase = 0,          -- 0 = полёт, 1 = торможение1, 2 = торможение2, 3 = скольжение
        phaseTimer = 0,
        flightTimer = 0,
        jumpDone = false,
    }

    RunService.Heartbeat:Connect(function(delta)
        local middle, bottom, top = getCharParts()
        if not middle then return end

        local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.C)
        local space = UserInputService:IsKeyDown(Enum.KeyCode.Space)

        -- Направление движения (WASD + камера)
        local direction = Vector3.zero
        local camLook = workspace.CurrentCamera.CFrame.LookVector
        camLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Vector3.new(-camLook.Z, 0, camLook.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction + Vector3.new(camLook.Z, 0, -camLook.X) end
        if direction ~= Vector3.zero then direction = direction.Unit end

        -- SILENT (если не используется, ничего не делаем)
        if speedhack.silent and speedhack.silentActive then
            return
        end

        local isActiveNow = speedhack.enabled and not speedhack.silent and shift and ctrl

        if isActiveNow then
            if not speedState.active then
                speedState.active = true
                speedState.phase = 0
                speedState.phaseTimer = 0
                speedState.flightTimer = 0
                speedState.jumpDone = false
            end

            -- Подброс (один раз)
            if not speedState.jumpDone then
                local tp, md, bt = top and top.CFrame, middle.CFrame, bottom and bottom.CFrame
                middle.CFrame = md + Vector3.new(0, 2, 0)
                if bottom then bottom.CFrame = bt + Vector3.new(0, 2, 0) end
                if top then top.CFrame = tp + Vector3.new(0, 2, 0) end
                speedState.jumpDone = true
            end

            -- Логика фаз
            if speedState.phase == 0 then
                speedState.flightTimer = speedState.flightTimer + delta
                if speedState.flightTimer >= FLIGHT_TIME then
                    speedState.phase = 1
                    speedState.phaseTimer = 0
                end
            elseif speedState.phase == 1 then
                speedState.phaseTimer = speedState.phaseTimer + delta
                if speedState.phaseTimer >= BRAKE1_DURATION then
                    speedState.phase = 2
                end
            elseif speedState.phase == 2 then
                speedState.phase = 3
            end
        else
            if speedState.active then
                speedState.active = false
                speedState.phase = 0
                speedState.phaseTimer = 0
                speedState.flightTimer = 0
                speedState.jumpDone = false
            end
        end

        -- Принудительная установка скорости (каждый кадр, работает даже в воде)
        if speedState.active then
            local horizSpeed = 0
            local yVel = 0
            if speedState.phase == 0 then
                horizSpeed = speedhack.speed   -- 60
                yVel = 0
            elseif speedState.phase == 1 then
                horizSpeed = BRAKE1_SPEED      -- 43
                yVel = -7
            elseif speedState.phase == 2 then
                horizSpeed = BRAKE2_SPEED      -- 17
                yVel = -15
            elseif speedState.phase == 3 then
                horizSpeed = GLIDE_HORIZONTAL  -- 17
                yVel = GLIDE_VERTICAL          -- -15
            end
            local vel = Vector3.new(direction.X * horizSpeed, yVel, direction.Z * horizSpeed)
            middle.AssemblyLinearVelocity = vel
            if bottom then bottom.AssemblyLinearVelocity = vel end
            if top then top.AssemblyLinearVelocity = vel end
        end

        -- DOWNCLIFF и FORCE SPRINT (заглушки)
        if speedhack.downcliff and not isActiveNow and shift and ctrl then
            if direction ~= Vector3.zero then direction = direction.Unit end
            if space and speedState.phaseTimer == 0 then
                local tp, md, bt = top and top.CFrame, middle.CFrame, bottom and bottom.CFrame
                middle.CFrame = md + Vector3.new(0, 2, 0)
                if bottom then bottom.CFrame = bt + Vector3.new(0, 2, 0) end
                if top then top.CFrame = tp + Vector3.new(0, 2, 0) end
            end
            speedState.phaseTimer = (speedState.phaseTimer or 0) + delta
            local dcBuildup = 17 + (speedState.phaseTimer % 8)
            local yVel = space and -7 or -10
            middle.AssemblyLinearVelocity = Vector3.new(direction.X * dcBuildup, yVel, direction.Z * dcBuildup)
        end

        if speedhack.forcesprint and not isActiveNow then
            if direction ~= Vector3.zero then direction = direction.Unit end
            middle.AssemblyLinearVelocity = Vector3.new(direction.X * 18, middle.AssemblyLinearVelocity.Y, direction.Z * 18)
        end
    end)

    -- GUI
    local SpeedBox = Tabs.Combat:AddLeftGroupbox('ꜱᴘᴇᴇᴅʜᴀᴄᴋ')
    SpeedBox:AddToggle('SpeedhackEnable', {Text='ꜱᴘᴇᴇᴅʜᴀᴄᴋ (ꜱʜɪꜰᴛ+ᴄ)', Default=false,
        Callback=function(v) speedhack.enabled = v end})
    SpeedBox:AddSlider('SpeedValue', {Text='ꜱᴘᴇᴇᴅ', Min=40, Max=60, Default=55, Rounding=0,
        Callback=function(v) speedhack.speed = v end})

    local _forceSprint = false
    RunService.Heartbeat:Connect(function()
        if not _forceSprint then return end
        local constFolder = workspace:FindFirstChild("Const")
        if not constFolder then return end
        local ignFolder = constFolder:FindFirstChild("Ignore")
        if not ignFolder then return end
        local char = ignFolder:FindFirstChild("LocalCharacter")
        if not char then return end
        local middle = char:FindFirstChild("Middle")
        if not middle then return end
        local camLook = workspace.CurrentCamera.CFrame.LookVector
        local flat = Vector3.new(camLook.X, 0, camLook.Z)
        if flat.Magnitude < 0.01 then return end
        flat = flat.Unit
        local right = Vector3.new(-flat.Z, 0, flat.X)
        local dir = Vector3.zero
        local UIS = UserInputService
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + flat end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - flat end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
        if dir.Magnitude > 0.01 then
            dir = dir.Unit
            middle.AssemblyLinearVelocity = Vector3.new(dir.X * 18, middle.AssemblyLinearVelocity.Y, dir.Z * 18)
        end
    end)
    SpeedBox:AddToggle('SpeedForceSprint', {Text='ꜰᴏʀᴄᴇ ꜱᴘʀɪɴᴛ', Default=false,
        Callback=function(v) _forceSprint = v end})
end
    -- ============ PLAYER MANIPULATION (dedsamodell) ============
    do
        local function getCurrentWeaponName()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                return tool and tool.Name
            end
            return nil
        end

        local function PM_IsTeam(m)
            if not m then return false end
            local h = m:FindFirstChild("Head")
            return h and h:FindFirstChild("Dot") and h.Dot.Enabled == true or false
        end

        local function PM_IsSleeper(m)
            if not m then return false end
            local lt = m:FindFirstChild("LowerTorso")
            if lt then
                local rr = lt:FindFirstChild("RootRig")
                if rr then
                    local ok, a = pcall(function() return rr.CurrentAngle end)
                    if ok and type(a) == "number" and a ~= 0 then return true end
                end
            end
            return false
        end

        local function PM_IsAI(m)
            local torso = m:FindFirstChild("Torso") or m:FindFirstChild("HumanoidRootPart")
            return torso and torso.CollisionGroup == "NPC" or false
        end

        local INDOOR_RAY_DISTANCE = 35
        local function PM_IsIndoors(model)
            local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
            if not head then return false end
            local pos   = head.Position
            local cf    = head.CFrame
            local look  = cf.LookVector
            local right = look:Cross(Vector3.new(0,1,0))
            local directions = {
                Vector3.new(0,1,0), Vector3.new(0,-1,0),
                look, -look, right, -right,
                (look+right).Unit, (look-right).Unit,
                (-look+right).Unit, (-look-right).Unit,
            }
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local localChar = workspace.Const and workspace.Const.Ignore and workspace.Const.Ignore:FindFirstChild("LocalCharacter")
            rayParams.FilterDescendantsInstances = {model, localChar or LocalPlayer.Character}
            for _, dir in ipairs(directions) do
                local result = workspace:Raycast(pos, dir * INDOOR_RAY_DISTANCE, rayParams)
                if not result then return false end
            end
            return true
        end

        -- Player tracking (глобальный pmPlayers уже объявлен выше)
        local pmPlayers = {}
        local function addPmPlayer(obj)
            if not obj then return end
            if obj:FindFirstChild("Head") and (obj:FindFirstChild("Middle") or obj:FindFirstChild("LowerTorso") or obj:FindFirstChild("HumanoidRootPart")) then
                local ign    = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
                local myChar = ign and ign:FindFirstChild("LocalCharacter")
                if obj ~= myChar and obj ~= LocalPlayer.Character then
                    pmPlayers[obj] = obj
                end
            end
        end
        for _, v in next, workspace:GetChildren() do addPmPlayer(v) end
        workspace.ChildAdded:Connect(addPmPlayer)
        workspace.ChildRemoved:Connect(function(obj) pmPlayers[obj] = nil end)
        task.spawn(function()
            local const = workspace:WaitForChild("Const", 15)
            local ign   = const and const:FindFirstChild("Ignore")
            if ign then
                for _, v in ipairs(ign:GetChildren()) do addPmPlayer(v) end
                ign.ChildAdded:Connect(addPmPlayer)
                ign.ChildRemoved:Connect(function(obj) pmPlayers[obj] = nil end)
            end
        end)

        local function getHP(model)
            local hum = model and model:FindFirstChild("Humanoid")
            return hum and hum.Health or 100
        end

        -- Приоритет: наименьший HP, затем ближе к центру
        local function getClosestPm()
            local cam = workspace.CurrentCamera
            if not cam then return nil, nil end
            local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local bestPart, bestPos, bestScore = nil, nil, math.huge
            for _, char in pairs(pmPlayers) do
                if PM.AiCheck      and PM_IsAI(char)      then continue end
                if PM.TeamCheck    and PM_IsTeam(char)    then continue end
                if (PM.Mode == "Pro" or PM.SleepCheck) and PM_IsSleeper(char) then continue end
                if PM.IndoorCheck  and PM_IsIndoors(char) then continue end
                local hp = getHP(char)
                for _, partName in ipairs(PM_BODY_PARTS) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        local ok, pos = pcall(function() return cam:WorldToViewportPoint(part.Position) end)
                        if ok and pos.Z > 0 then
                            local dist  = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            local score = hp + dist * 0.0001
                            if score < bestScore then
                                bestPart  = part
                                bestPos   = Vector2.new(pos.X, pos.Y)
                                bestScore = score
                            end
                        end
                    end
                end
            end
            return bestPart, bestPos
        end

        local function getSilentTarget()
            local cam = workspace.CurrentCamera
            if not cam then return nil end
            local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local modelBest = {}
            for _, char in pairs(pmPlayers) do
                if PM.AiCheck      and PM_IsAI(char)      then continue end
                if PM.TeamCheck    and PM_IsTeam(char)    then continue end
                if (PM.Mode == "Pro" or PM.SleepCheck) and PM_IsSleeper(char) then continue end
                if PM.IndoorCheck  and PM_IsIndoors(char) then continue end
                local hp = getHP(char)
                local candidates = {}
                for _, partName in ipairs(PM_BODY_PARTS) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist <= PMFov.Size then
                                table.insert(candidates, {part=part, dist=dist, isHead=(partName=="Head")})
                            end
                        end
                    end
                end
                if #candidates == 0 then continue end
                table.sort(candidates, function(a,b) return a.dist < b.dist end)
                local chosen = nil
                for _, entry in ipairs(candidates) do
                    if entry.isHead then
                        if math.random(1,100) > SilentAim.HeadAvoid then chosen = entry; break end
                    else
                        chosen = entry; break
                    end
                end
                if not chosen then chosen = candidates[1] end
                if chosen then
                    local score = hp + chosen.dist * 0.0001
                    modelBest[char] = {part=chosen.part, score=score}
                end
            end
            local bestModel, bestScore2 = nil, math.huge
            for model, data in pairs(modelBest) do
                if data.score < bestScore2 then bestModel=model; bestScore2=data.score end
            end
            return bestModel and modelBest[bestModel].part
        end

        -- Основной цикл обновления таргета
        local pmFrozenData = {}
        PMState.Target, PMState.TargetPos, PMState.Cached = nil, nil, nil

        RunService.RenderStepped:Connect(function()
            if not PMState.Cached then PMState.Target, PMState.TargetPos = getClosestPm() end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

            if SilentAim.Enabled then
                SilentAim.Target = getSilentTarget()
            else
                SilentAim.Target = nil
            end

            if SilentAim.Rainbow and SilentAim.SnaplineVisible then
                saLine.Color = Color3.fromHSV(tick()%5/5, 1, 1)
            end
            if SilentAim.SnaplineVisible and SilentAim.Target and SilentAim.Enabled then
                local pos, onScreen = cam:WorldToViewportPoint(SilentAim.Target.Position)
                if onScreen then
                    saLine.From = center; saLine.To = Vector2.new(pos.X,pos.Y); saLine.Visible = true
                else
                    saLine.Visible = false
                end
            else
                saLine.Visible = false
            end

            if SilentAim.Enabled and SilentAim.KillIndicatorEnabled and SilentAim.Target then
                local targetPart = SilentAim.Target
                local model = targetPart and targetPart.Parent
                if model and model:IsA("Model") then
                    local head   = model:FindFirstChild("Head")
                    local anchor = head or targetPart
                    local worldPos = anchor.Position + Vector3.new(0,15,0)
                    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
                    if onScreen then
                        local camPos = cam.CFrame.Position
                        local dist   = (anchor.Position - camPos).Magnitude
                        local distanceScale = math.clamp(2.5-(dist/80), 0.6, 2.2)
                        local t = tick()
                        saIndicator.Position    = Vector2.new(screenPos.X, screenPos.Y)
                        saIndicator.Visible     = true
                        local pulse = math.sin(t*4)*0.08+1
                        saIndicator.Size        = math.floor(24*distanceScale*pulse+0.5)
                        saIndicator.Color       = Color3.fromRGB(255, 40+math.abs(math.sin(t*3))*80, 40)
                        saIndicator.Transparency = 0.15+math.abs(math.sin(t*5))*0.2
                    else
                        saIndicator.Visible = false
                    end
                else
                    saIndicator.Visible = false
                end
            else
                saIndicator.Visible = false
            end

            if PMFov.Enabled and (_pmEnabled or SilentAim.Enabled) then
                PMFov.Circle.Position = center
                PMFov.Circle.Radius   = PMFov.Size
                PMFov.Circle.Visible  = true
            else
                PMFov.Circle.Visible = false
            end
        end)

        -- ===== ОБРАБОТЧИКИ ПУЛЬ =====

        local function proBulletHandler(obj)
            task.defer(function()
                if not obj or not obj.Parent then return end
                local distToCamera = (obj.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                local weaponName   = getCurrentWeaponName()
                local maxDist      = _pmWeaponMaxDist[weaponName] or _pmDefaultMaxDist
                if distToCamera > maxDist then return end

                local locked = PMState.Target
                if not locked then return end
                local model  = locked:IsA("Model") and locked or locked.Parent
                if not model then return end
                if PMState.Cached and PMState.Cached == model then return end

                local root = model:FindFirstChild("Middle") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if not root then return end

                local originalRootCFrame = root.CFrame
                local initialTargetPos   = (locked:FindFirstChild("Head") and locked.Head.Position)
                    or (locked:FindFirstChild("HumanoidRootPart") and locked.HumanoidRootPart.Position)

                local partsData = {}
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(partsData, {part=part, position=part.Position})
                    end
                end
                pmFrozenData[model] = {parts=partsData, originalCFrame=originalRootCFrame}

                local connHit, connClean
                local hasDirectVision = false

                local function cleanup(returnToOriginal)
                    if connHit   then connHit:Disconnect()   end
                    if connClean then connClean:Disconnect() end
                    PMState.Cached = nil
                    if model and pmFrozenData[model] then pmFrozenData[model] = nil end
                    if root and root.Parent and returnToOriginal and originalRootCFrame then
                        pcall(function() root.CFrame = originalRootCFrame end)
                    end
                end

                PMState.Cached = model

                connHit = obj:GetPropertyChangedSignal("CFrame"):Connect(function()
                    if not locked or not locked.Parent or hasDirectVision then return end
                    if not locked.Parent then cleanup(true); return end
                    local bulletPos = obj.CFrame.Position

                    if initialTargetPos then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = {obj, locked}
                        local direction  = initialTargetPos - bulletPos
                        local rayResult  = workspace:Raycast(bulletPos, direction, rayParams)
                        if not rayResult then
                            hasDirectVision = true
                            pcall(function() root.CFrame = CFrame.new(bulletPos) end)
                            task.wait()
                            cleanup(true)
                            return
                        end
                    end
                    pcall(function() root.CFrame = CFrame.new(bulletPos.X, root.Position.Y, bulletPos.Z) end)
                end)

                connClean = RunService.Heartbeat:Connect(function()
                    if not obj or not obj.Parent then
                        if not hasDirectVision then
                            if math.random(1,100) <= PMState.NoVisHitChance then cleanup(false)
                            else cleanup(true) end
                        else
                            if connHit   then connHit:Disconnect()   end
                            if connClean then connClean:Disconnect() end
                        end
                    end
                end)
            end)
        end

        local function oldBulletHandler(obj)
            task.defer(function()
                if not obj or not obj.Parent then return end
                local distToCamera = (obj.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                local weaponName   = getCurrentWeaponName()
                local maxDist      = _pmWeaponMaxDist[weaponName] or _pmDefaultMaxDist
                if distToCamera > maxDist then return end

                local locked = PMState.Target
                if not locked then return end
                local model  = locked:IsA("Model") and locked or locked.Parent
                local originalCFrame  = locked.CFrame
                local targetPart      = locked:FindFirstChild("Head") or locked:FindFirstChild("HumanoidRootPart")
                local initialTargetPos = targetPart and targetPart.Position

                local partsData = {}
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(partsData, {part=part, position=part.Position})
                    end
                end
                pmFrozenData[model] = {parts=partsData, originalCFrame=originalCFrame}

                local connHit, connClean
                local function cleanup()
                    if connHit   then connHit:Disconnect()   end
                    if connClean then connClean:Disconnect() end
                    PMState.Cached = nil
                    if model and pmFrozenData[model] then pmFrozenData[model] = nil end
                    if locked and locked.Parent then
                        pcall(function() locked.CFrame = originalCFrame end)
                    end
                end
                PMState.Cached = locked

                connHit = obj:GetPropertyChangedSignal("CFrame"):Connect(function()
                    if not locked or not locked.Parent then cleanup(); return end
                    local parent = locked.Parent
                    if not parent then cleanup(); return end
                    local root = parent.PrimaryPart or parent:FindFirstChild("Middle") or parent:FindFirstChild("HumanoidRootPart")
                    if not root then cleanup(); return end
                    local bulletPos = obj.CFrame.Position
                    pcall(function() root.CFrame = CFrame.new(bulletPos.X, root.Position.Y, bulletPos.Z) end)
                    if initialTargetPos then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = {obj, locked}
                        local rayResult = workspace:Raycast(obj.CFrame.Position, initialTargetPos - obj.CFrame.Position, rayParams)
                        if not rayResult then
                            local r2 = parent.PrimaryPart or parent:FindFirstChild("Middle") or parent:FindFirstChild("HumanoidRootPart")
                            if r2 then pcall(function() r2.CFrame = CFrame.new(obj.CFrame.Position) end); task.wait() end
                            cleanup()
                        end
                    end
                end)
                connClean = RunService.Heartbeat:Connect(function()
                    if not obj or not obj.Parent then cleanup() end
                end)
            end)
        end

        -- Запуск слушателя пуль
        task.spawn(function()
            local const = workspace:WaitForChild("Const", 60)
            local ign   = const and const:FindFirstChild("Ignore")
            if not ign then return end
            ign.ChildAdded:Connect(function(obj)
                if not obj or not obj:FindFirstChild("whiz") or not _pmEnabled or not PMState.Target then return end
                if PM.Mode == "Pro" then proBulletHandler(obj) else oldBulletHandler(obj) end
            end)
        end)

        -- ===== PM GUI =====
        local CombatPMBox = Tabs.Combat:AddLeftGroupbox("ᴘʟᴀʏᴇʀ ᴍᴀɴɪᴘᴜʟᴀᴛɪᴏɴ")

        CombatPMBox:AddToggle("PMEnable_dm", {
            Text = "ᴘᴍ ᴇɴᴀʙʟᴇᴅ", Default = false,
            Callback = function(v) _pmEnabled = v end
        })

        local pmSleepCheckToggle
        CombatPMBox:AddDropdown("PMMode_dm", {
            Text = "ᴘᴍ ᴍᴏᴅᴇ", Default = "Pro (Sleep Check)",
            Values = {"Pro (Sleep Check)", "Old (No Sleep Check)"},
            Callback = function(v)
                if v == "Pro (Sleep Check)" then
                    PM.Mode = "Pro"
                    if pmSleepCheckToggle then
                        PM.SleepCheck = true
                        pmSleepCheckToggle:SetValue(true)
                        pmSleepCheckToggle:SetDisabled(true)
                    end
                else
                    PM.Mode = "Old"
                    if pmSleepCheckToggle then
                        PM.SleepCheck = false
                        pmSleepCheckToggle:SetValue(false)
                        pmSleepCheckToggle:SetDisabled(false)
                    end
                end
            end
        })

        CombatPMBox:AddToggle("SilentAimEnable_dm", {
            Text = "ꜱɪʟᴇɴᴛ ᴀɪᴍ (ᴅᴇᴅꜱᴀᴍᴏᴅᴇʟʟ)", Default = false,
            Callback = function(v) SilentAim.Enabled = v end
        })
        CombatPMBox:AddToggle("SASnapline_dm", {
            Text = "ꜱɴᴀᴘʟɪɴᴇ", Default = false,
            Callback = function(v) SilentAim.SnaplineVisible = v end
        })
        CombatPMBox:AddToggle("SAKillIndicator_dm", {
            Text = "ᴋɪʟʟ ɪɴᴅɪᴄᴀᴛᴏʀ (💀)", Default = false,
            Callback = function(v) SilentAim.KillIndicatorEnabled = v end
        })
        CombatPMBox:AddToggle("SARainbow_dm", {
            Text = "ʀᴀɪɴʙᴏᴡ ꜱɴᴀᴘʟɪɴᴇ", Default = false,
            Callback = function(v) SilentAim.Rainbow = v end
        })
        CombatPMBox:AddSlider("SAHeadAvoid_dm", {
            Text = "ᴛᴏʀꜱᴏ %", Min = 0, Max = 100, Default = 10, Rounding = 0,
            Callback = function(v) SilentAim.HeadAvoid = v end
        })

        pmSleepCheckToggle = CombatPMBox:AddToggle("PMSleepCheck_dm", {
            Text = "ꜱʟᴇᴇᴘ ᴄʜᴇᴄᴋ (💤)", Default = false,
            Callback = function(v) PM.SleepCheck = v end
        })
        CombatPMBox:AddToggle("PMAICheck_dm", {
            Text = "ᴀɪ ᴄʜᴇᴄᴋ (🤖)", Default = false,
            Callback = function(v) PM.AiCheck = v end
        })
        CombatPMBox:AddToggle("PMTeamCheck_dm", {
            Text = "ᴛᴇᴀᴍ ᴄʜᴇᴄᴋ (👥)", Default = false,
            Callback = function(v) PM.TeamCheck = v end
        })
        CombatPMBox:AddToggle("PMIndoorCheck_dm", {
            Text = "ᴄʜᴇᴄᴋ ʜᴏᴍᴇ(🏠︎)", Default = false,
            Callback = function(v) PM.IndoorCheck = v end
        })

        CombatPMBox:AddToggle("PMFovEnabled_dm", {
            Text = "ꜱʜᴏᴡ ꜰᴏᴠ ᴄɪʀᴄʟᴇ", Default = false,
            Callback = function(v) PMFov.Enabled = v end
        })
        CombatPMBox:AddSlider("PMFovSize_dm", {
            Text = "ꜰᴏᴠ ꜱɪᴢᴇ", Min = 30, Max = 500, Default = 150, Rounding = 0,
            Callback = function(v) PMFov.Size = v end
        })
        CombatPMBox:AddSlider("PMNoVisChance_dm", {
            Text = "ʜɪᴛ ᴄʜᴀɴᴄᴇ %", Min = 0, Max = 95, Default = 50, Rounding = 0,
            Callback = function(v) PMState.NoVisHitChance = v end
        })
    end
    -- ============ END PLAYER MANIPULATION (dedsamodell) ============

    do
        local _acEnabled  = false
        local _acFov      = 100
        local _acRadius   = 1000
        local _acLabels   = {}
        local _acBg       = {}
        local _acOutline  = {}
        local _acModel    = nil
        local _acDrawn    = nil
        local _acScan     = 0
        local _acPadX     = 14
        local _acPadY     = 10
        local _acLineH    = 26
        local _acFSize    = 18
        local _acRad      = 8
local cam = GetCamera()
local y = cam and cam.ViewportSize.Y / 2 - 60 or 100
local _acPos = Vector2.new(20, y)
        local _acDragging = false
        local _acDragOff  = Vector2.new(0,0)
        local _acTotalW   = 0
        local _acTotalH   = 0
        local _acPlayers  = {}

        local function _acClearShapes(t)
            if not t then return end
            for _,s in ipairs(t) do pcall(function() s.Visible=false; s:Remove() end) end
        end
        local function _acClear()
            for _,l in ipairs(_acLabels) do pcall(function() l.Visible=false; l:Remove() end) end
            _acLabels={}; _acClearShapes(_acBg); _acBg={}; _acClearShapes(_acOutline); _acOutline={}
        end
        local function _acRounded(x,y,w,h,r,color,zi)
            -- Sharp corners: just draw a single rectangle
            local shapes={}
            local function sq(px,py,pw,ph)
                local s=Drawing.new("Square"); s.Position=Vector2.new(px,py); s.Size=Vector2.new(pw,ph)
                s.Color=color; s.Filled=true; s.Thickness=1; s.Visible=true; s.ZIndex=zi
                table.insert(shapes,s)
            end
            sq(x,y,w,h)
            return shapes
        end
        local function _acGetPart(m)
            return m and (m:FindFirstChild("Head") or m:FindFirstChild("UpperTorso") or m:FindFirstChild("LowerTorso") or m:FindFirstChild("HumanoidRootPart"))
        end
        local function _acAddModel(o)
            if o:IsA("Model") and o ~= LocalPlayer.Character then
                if o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("LowerTorso") or o:FindFirstChild("Head") then
                    table.insert(_acPlayers,o)
                end
            end
        end
        for _,v in ipairs(workspace:GetChildren()) do _acAddModel(v) end
        workspace.ChildAdded:Connect(function(o) task.wait(0.1); _acAddModel(o) end)
        workspace.ChildRemoved:Connect(function(o)
            for i=#_acPlayers,1,-1 do if _acPlayers[i]==o then table.remove(_acPlayers,i); break end end
        end)

        local function _acDraw(model)
            _acClear(); if not model then return end
            local folder=model:FindFirstChild("Armor")
            local items=folder and folder:GetChildren() or {}
            if #items==0 then return end
            local x,y=_acPos.X,_acPos.Y; local maxW=0
            for _,item in ipairs(items) do
                local w=#item.Name*(_acFSize*0.58)+_acPadX*2
                if w>maxW then maxW=w end
            end
            local totalH=#items*_acLineH+_acPadY*2
            _acTotalW=maxW; _acTotalH=totalH
            _acOutline=_acRounded(x-2,y-2,maxW+4,totalH+4,_acRad+1,Color3.fromRGB(35, 18, 60),8)
            _acBg=_acRounded(x,y,maxW,totalH,_acRad,Color3.fromRGB(10,10,10),9)
            local yOff=y+_acPadY
            for _,item in ipairs(items) do
                local l=Drawing.new("Text"); l.Text=item.Name; l.Size=_acFSize
                l.Color=Color3.fromRGB(255,255,255); l.Outline=true; l.OutlineColor=Color3.fromRGB(0,0,0)
                l.Font=Drawing.Fonts.Monospace
                l.Position=Vector2.new(x+_acPadX,yOff); l.Visible=true; l.ZIndex=10
                table.insert(_acLabels,l); yOff=yOff+_acLineH
            end
        end

        UserInputService.InputBegan:Connect(function(input)
            if not _acEnabled then return end
            if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local mp=Vector2.new(input.Position.X,input.Position.Y)
            if mp.X>=_acPos.X-2 and mp.X<=_acPos.X+_acTotalW+2 and mp.Y>=_acPos.Y-2 and mp.Y<=_acPos.Y+_acTotalH+2 then
                _acDragging=true; _acDragOff=mp-_acPos
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then _acDragging=false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not _acDragging or input.UserInputType~=Enum.UserInputType.MouseMovement then return end
            _acPos=Vector2.new(input.Position.X,input.Position.Y)-_acDragOff
            if _acModel then _acDraw(_acModel) end
        end)

        local _acThrottle = 0
        RunService.Heartbeat:Connect(function(dt)
            _acThrottle = _acThrottle + dt
            if _acThrottle < 0.05 then return end
            _acThrottle = 0
            if not _acEnabled then return end
            local snapChar = Flags.saSnapTarget and Flags.saSnapTarget.Parent
            if not snapChar then
                local cam = GetCamera()
                local bestDist = math.huge
                for _, model in ipairs(_acPlayers) do
                    if model and model.Parent and model ~= LocalPlayer.Character then
                        local part = _acGetPart(model)
                        if part and cam then
                            local _, onScreen = cam:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (cam.CFrame.Position - part.Position).Magnitude
                                if dist < bestDist then
                                    bestDist = dist
                                    snapChar = model
                                end
                            end
                        end
                    end
                end
            end

            if snapChar ~= _acModel then
                _acModel = snapChar
                _acDrawn = nil
                if not snapChar then _acClear() end
            end
            if _acModel and _acModel.Parent then
                local p = _acGetPart(_acModel)
                if p then
                    if _acDrawn ~= _acModel then _acDraw(_acModel); _acDrawn = _acModel end
                else
                    _acModel = nil; _acDrawn = nil; _acClear()
                end
            end
        end)

        local AcBox = Tabs.Visuals:AddRightGroupbox('ᴀʀᴍᴏʀ ᴄʜᴇᴄᴋ')
        AcBox:AddToggle('ArmorCheckEnabled',{Text='ᴀʀᴍᴏʀ ᴄʜᴇᴄᴋ',Default=false,Callback=function(v)
            _acEnabled=v; if not v then _acModel=nil; _acDrawn=nil; _acClear() end
        end})
    end

    do
        local _btEnabled   = false
        local _btColor     = Color3.fromRGB(255, 182, 210)
        local _btThickness = 0.1
        local _btLifetime  = 1.5
        local _btNames     = {"Bullet","BlueBullet","Projectile","Rocket","Missile","Grenade"}
        local Debris        = game:GetService("Debris")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local function _btIsLocalArrow(obj)
            local fps = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore") and workspace.Const.Ignore:FindFirstChild("FPSArms")
            if not fps then return false end
            local hm = fps:FindFirstChild("HandModel")
            return hm and hm:FindFirstChild("Arrow") == obj
        end

        local function _btMakeTracer(proj)
            if proj.Name=="Arrow" and _btIsLocalArrow(proj) then return end
            local lastPos=proj.Position or proj.CFrame.Position
            local conn
            local _btdt=0
            conn=RunService.Heartbeat:Connect(function(bdt)
                _btdt=_btdt+bdt; if _btdt<0.016 then return end; _btdt=0
                if not _btEnabled or not proj or not proj.Parent then conn:Disconnect(); return end
                if proj.Name=="Arrow" and _btIsLocalArrow(proj) then conn:Disconnect(); return end
                local cur=proj.Position or proj.CFrame.Position
                local d=(cur-lastPos).Magnitude
                if d>0.5 and d<500 then
                    local t=Instance.new("Part")
                    t.Anchored=true; t.CanCollide=false; t.CanQuery=false; t.CanTouch=false
                    t.Size=Vector3.new(_btThickness,_btThickness,d)
                    t.CFrame=CFrame.new(lastPos,cur)*CFrame.new(0,0,-d/2)
                    t.Color=_btColor; t.Material=Enum.Material.Neon; t.Transparency=0; t.Parent=workspace
                    Debris:AddItem(t,_btLifetime)
                end
                lastPos=cur
            end)
        end

        workspace.DescendantAdded:Connect(function(obj)
            if obj:IsDescendantOf(ReplicatedStorage) then return end
            task.wait()
            if not _btEnabled then return end
            for _,name in ipairs(_btNames) do if obj.Name==name then _btMakeTracer(obj); return end end
            if obj.Name=="Arrow" and not _btIsLocalArrow(obj) then _btMakeTracer(obj) end
        end)

        local BtBox = Tabs.Visuals:AddRightGroupbox('ʙᴜʟʟᴇᴛ ᴛʀᴀᴄᴇʀꜱ')
        BtBox:AddToggle('BulletTracersEnabled',{Text='ᴇɴᴀʙʟᴇ ʙᴜʟʟᴇᴛ ᴛʀᴀᴄᴇʀꜱ',Default=false,Callback=function(v) _btEnabled=v end})
        BtBox:AddColorPicker('BulletTracerColor',{Title='Tracer Color',Default=Color3.fromRGB(255, 182, 210),Callback=function(v) _btColor=v end})
        BtBox:AddSlider('BulletTracerThick',{Text='ᴛʜɪᴄᴋɴᴇꜱꜱ',Default=1,Min=1,Max=10,Callback=function(v) _btThickness=v/10 end})
        BtBox:AddSlider('BulletTracerLife',{Text='ʟɪꜰᴇᴛɪᴍᴇ (ꜱ)',Default=15,Min=5,Max=50,Callback=function(v) _btLifetime=v/10 end})
    end

    do
        local HudBox  = Tabs.Visuals:AddRightGroupbox('ᴄʀᴏꜱꜱʜᴀɪʀ')
        HudBox:AddToggle('CrosshairEnabled',{Text='ᴄʀᴏꜱꜱʜᴀɪʀ',Default=false,Callback=function(v) S.CrosshairEnabled=v; SetCrosshair(v) end})
        HudBox:AddColorPicker('CrosshairColor',{Title='Crosshair Color',Default=Color3.fromRGB(255,255,255),Callback=function(v) S.CrosshairColor=v end})
        HudBox:AddSlider('CrosshairThickness',{Text='ᴛʜɪᴄᴋɴᴇꜱꜱ',Default=1,Min=1,Max=8,Callback=function(v) S.CrosshairThickness=v end})
        HudBox:AddSlider('CrosshairLength',{Text='ʟᴇɴɢᴛʜ',Default=8,Min=2,Max=40,Callback=function(v) S.CrosshairLength=v end})
        HudBox:AddToggle('CrosshairSpin',{Text='ꜱᴘɪɴ',Default=false,Callback=function(v) S.CrosshairSpin=v end})
        HudBox:AddSlider('CrosshairSpinSpeed',{Text='ꜱᴘɪɴ ꜱᴘᴇᴇᴅ',Default=2,Min=1,Max=20,Callback=function(v) S.CrosshairSpinSpeed=v end})
    end

    do
        local ResBox = Tabs.Visuals:AddLeftGroupbox('ʀᴇꜱᴏʟᴜᴛɪᴏɴ')

        local _resEnabled = false
        local _resValue   = 0.65
        local _resConn    = nil
        local _resCamera  = workspace.CurrentCamera

        local function _startRes()
            if _resConn then _resConn:Disconnect(); _resConn = nil end
            if getgenv then
                getgenv().Resolution = { [".gg/scripters"] = _resValue }
                _resConn = game:GetService("RunService").RenderStepped:Connect(function()
                    if not _resEnabled then return end
                    _resCamera = workspace.CurrentCamera
                    if _resCamera then
                        _resCamera.CFrame = _resCamera.CFrame * CFrame.new(0,0,0, 1,0,0, 0,getgenv().Resolution[".gg/scripters"],0, 0,0,1)
                    end
                end)
            end
        end

        local function _stopRes()
            if _resConn then _resConn:Disconnect(); _resConn = nil end
            if getgenv then
                getgenv().Resolution = { [".gg/scripters"] = 1 }
                getgenv().gg_scripters = nil
            end
        end

        ResBox:AddToggle('ResolutionEnabled', {Text='ʀᴇꜱᴏʟᴜᴛɪᴏɴ ᴄʜᴀɴɢᴇʀ', Default=false,
            Callback=function(v)
                _resEnabled = v
                if v then _startRes() else _stopRes() end
            end})
        ResBox:AddSlider('ResolutionValue', {Text='ʀᴇꜱᴏʟᴜᴛɪᴏɴ', Default=65, Min=10, Max=100,
            Callback=function(v)
                _resValue = v / 100
                if getgenv and getgenv().Resolution then
                    getgenv().Resolution[".gg/scripters"] = _resValue
                end
                if _resEnabled and not _resConn then _startRes() end
            end})
    end

    do
        -- HM.Enabled / HM.Pool / HM.Color etc. are all module-level now.
        -- This block only owns the line-pool renderer and the UI controls.

local _hmLinePool = {}
for i = 1, 48 do
    local l = Drawing.new("Line")
    l.Visible = false; l.Thickness = 2
    l.Color = Color3.fromRGB(255,255,255); l.ZIndex = 10
    _hmLinePool[i] = l
end

RunService.RenderStepped:Connect(function(dt)
    if not HM.Enabled then
        for _, l in ipairs(_hmLinePool) do l.Visible = false end
        for i = #HM.Pool, 1, -1 do table.remove(HM.Pool, i) end
        return
    end

    local cam = workspace.CurrentCamera
    local vp  = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local lineIdx = 0

    for i = #HM.Pool, 1, -1 do
        local hm = HM.Pool[i]
        hm.timer = hm.timer + dt
        if hm.timer >= HM.Duration then
            table.remove(HM.Pool, i); continue
        end

        if not hm.pos then
            -- если позиция неизвестна, пропускаем (не рисуем в центре)
            continue
        end

        local fade = 1 - (hm.timer / HM.Duration)
        local g  = HM.Gap
        local sz = HM.Size
        local col = hm.isHead and HM.HeadColor or HM.Color

        local px = hm.pos.X
        local py = hm.pos.Y

        local d0 = g  * 0.7071
        local d1 = (g + sz) * 0.7071
        local arms = {
            { px - d0, py - d0, px - d1, py - d1 },
            { px + d0, py - d0, px + d1, py - d1 },
            { px - d0, py + d0, px - d1, py + d1 },
            { px + d0, py + d0, px + d1, py + d1 },
        }
        for _, c in ipairs(arms) do
            lineIdx = lineIdx + 1
            if lineIdx > #_hmLinePool then break end
            local l = _hmLinePool[lineIdx]
            l.From         = Vector2.new(c[1], c[2])
            l.To           = Vector2.new(c[3], c[4])
            l.Color        = col
            l.Thickness    = HM.Thick
            l.Transparency = 1 - fade
            l.Visible      = true
        end
    end

    for i = lineIdx + 1, #_hmLinePool do
        _hmLinePool[i].Visible = false
    end
end)

        local HmBox = Tabs.Visuals:AddLeftGroupbox('ʜɪᴛᴍᴀʀᴋᴇʀ')
        HmBox:AddToggle('HitmarkerEnabled', {Text='ᴇɴᴀʙʟᴇ ʜɪᴛᴍᴀʀᴋᴇʀ', Default=false,
            Callback=function(v)
                HM.Enabled = v
                if not v then
                    for _, l in ipairs(_hmLinePool) do l.Visible = false end
                    for i = #HM.Pool, 1, -1 do table.remove(HM.Pool, i) end
                end
            end})
        HmBox:AddColorPicker('HitmarkerColor', {Title='Color',
            Default=Color3.fromRGB(255,255,255),
            Callback=function(v) HM.Color = v end})
        HmBox:AddColorPicker('HitmarkerHeadColor', {Title='Headshot Color',
            Default=Color3.fromRGB(255,60,60),
            Callback=function(v) HM.HeadColor = v end})
        HmBox:AddSlider('HitmarkerSize', {Text='ꜱɪᴢᴇ', Default=12, Min=4, Max=30,
            Callback=function(v) HM.Size = v end})
        HmBox:AddSlider('HitmarkerThickness', {Text='ᴛʜɪᴄᴋɴᴇꜱꜱ', Default=3, Min=1, Max=6,
            Callback=function(v) HM.Thick = v end})
        HmBox:AddSlider('HitmarkerGap', {Text='ɢᴀᴘ', Default=3, Min=0, Max=15,
            Callback=function(v) HM.Gap = v end})
    end


    do
        local EspBox    = Tabs.ESP:AddLeftGroupbox('ᴘʟᴀʏᴇʀ ᴇꜱᴘ')

        EspBox:AddToggle('EspEnabled',{Text='ᴇɴᴀʙʟᴇ ᴇꜱᴘ',Default=false,Callback=function(v)
            Esp.settings.enabled = v
        end})
        EspBox:AddToggle('EspBox',{Text='ᴇɴᴀʙʟᴇ ʙᴏx',Default=false,Callback=function(v)
            Esp.settings.boxEnabled = v
        end})
        EspBox:AddDropdown('BoxType',{Values={"ᴄᴏʀɴᴇʀ","ᴅᴇꜰᴀᴜʟᴛ"},Default=1,Text='ʙᴏx ᴛʏᴘᴇ',Callback=function(v)
            Esp.settings.boxType = v
        end})
        EspBox:AddToggle('EspName',{Text='ɴᴀᴍᴇ',Default=false,Callback=function(v)
            Esp.settings.nameEnabled = v
        end})
        EspBox:AddToggle('EspDist',{Text='ᴅɪꜱᴛᴀɴᴄᴇ',Default=false,Callback=function(v)
            Esp.settings.distanceEnabled = v
        end})
        EspBox:AddToggle('EspWeapon',{Text='ᴡᴇᴀᴘᴏɴ',Default=false,Callback=function(v)
            Esp.settings.weaponEnabled = v
        end})
        EspBox:AddToggle('VisCheckEnabled',{Text='ᴠɪꜱɪʙʟᴇ ᴄʜᴇᴄᴋ ʙᴀʀ',Default=false,Callback=function(v)
            S.VisCheckEnabled = v
        end})
        EspBox:AddSlider('RenderDistance',{Text='ʀᴇɴᴅᴇʀ ᴅɪꜱᴛᴀɴᴄᴇ (ꜱᴛᴜᴅꜱ)',Default=500,Min=50,Max=3400,Rounding=0,Callback=function(v)
            Esp.settings.renderDistance = math.min(v, ESP_MAX_RENDER)
        end})


    -- =========================================================
    --  PLAYER CHAMS  (per-part Highlight boxes like the image)
    -- =========================================================
    do
        local _pcEnabled      = false
        local _pcOutlineColor = Color3.fromRGB(255, 255, 255)
        local _pcFillColor    = Color3.fromRGB(255, 255, 255)
        local _pcFillTrans    = 0.5   -- 0=solid fill, 1=outline only
        local _pcOutlineTrans = 0
        local _pcRainbow      = false
        local _pcRainbowHue   = 0
        local _pcDepth        = Enum.HighlightDepthMode.AlwaysOnTop -- hardcoded

        local _CORE_PARTS = {
            "Head",
            "UpperTorso","LowerTorso","Torso","Middle",
            "LeftUpperArm","LeftLowerArm","LeftHand",
            "RightUpperArm","RightLowerArm","RightHand",
            "LeftUpperLeg","LeftLowerLeg","LeftFoot",
            "RightUpperLeg","RightLowerLeg","RightFoot",
        }

        local _pcFolder = Instance.new("Folder")
        _pcFolder.Name = "TH_PartChams"
        pcall(function() _pcFolder.Parent = CoreGui end)
        if not _pcFolder.Parent then
            _pcFolder.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        end

        -- _pcData[plr] = { partName = Highlight }
        local _pcData = {}

        local function _removePlayer(model)
            local d = _pcData[model]
            if not d then return end
            for _, hl in pairs(d) do pcall(function() hl:Destroy() end) end
            _pcData[model] = nil
        end

        local function _hidePlayer(model)
            local d = _pcData[model]
            if not d then return end
            for _, hl in pairs(d) do hl.Enabled = false end
        end

        local function _makeHL(part)
            local hl = Instance.new("Highlight")
            hl.Adornee             = part
            hl.FillColor           = _pcFillColor
            hl.FillTransparency    = _pcFillTrans
            hl.OutlineColor        = _pcOutlineColor
            hl.OutlineTransparency = _pcOutlineTrans
            hl.DepthMode           = _pcDepth
            hl.Enabled             = false
            hl.Parent              = _pcFolder
            return hl
        end

        -- cleanup when a character model leaves workspace
        workspace.ChildRemoved:Connect(function(obj)
            if _pcData[obj] then _removePlayer(obj) end
        end)

        RunService.Heartbeat:Connect(function(dt)
            if _pcRainbow then
                _pcRainbowHue = (_pcRainbowHue + dt * 0.4) % 1
                local col = Color3.fromHSV(_pcRainbowHue, 1, 1)
                _pcFillColor    = col
                _pcOutlineColor = col
            end

            if not _pcEnabled then
                for model, d in pairs(_pcData) do
                    for _, hl in pairs(d) do hl.Enabled = false end
                end
                return
            end

            local myIgn = GetIgnoreFolder()
            local myChar = myIgn and myIgn:FindFirstChild("LocalCharacter")

            for model in pairs(HB.validCharacters) do
                if not model or not model.Parent then continue end
                if model == myChar or model == LocalPlayer.Character then continue end
                if _isSleeper(model) or _isDead(model) then
                    -- hide using model as key
                    local d = _pcData[model]
                    if d then for _, hl in pairs(d) do hl.Enabled = false end end
                    continue
                end
                -- use model directly as key
                if not _pcData[model] then _pcData[model] = {} end
                local d = _pcData[model]
                for _, name in ipairs(_CORE_PARTS) do
                    local part = model:FindFirstChild(name)
                    if part and part:IsA("BasePart") then
                        if not d[name] then
                            d[name] = _makeHL(part)
                        elseif d[name].Adornee ~= part then
                            d[name].Adornee = part
                        end
                        local hl = d[name]
                        hl.Enabled             = true
                        hl.FillColor           = _pcFillColor
                        hl.FillTransparency    = _pcFillTrans
                        hl.OutlineColor        = _pcOutlineColor
                        hl.OutlineTransparency = _pcOutlineTrans
                        hl.DepthMode           = _pcDepth
                    elseif d[name] then
                        d[name].Enabled = false
                    end
                end
            end

            -- purge stale
            for model, d in pairs(_pcData) do
                if not HB.validCharacters[model] then
                    for _, hl in pairs(d) do pcall(function() hl:Destroy() end) end
                    _pcData[model] = nil
                end
            end
        end)


        local PlayerChamsBox = Tabs.ESP:AddLeftGroupbox('ᴘʟᴀʏᴇʀ ᴄʜᴀᴍꜱ')

        PlayerChamsBox:AddToggle('PlayerChamsEnabled', {
            Text = 'ᴇɴᴀʙʟᴇ ᴘʟᴀʏᴇʀ ᴄʜᴀᴍꜱ', Default = false,
            Callback = function(v)
                _pcEnabled = v
                if not v then
                    for model, d in pairs(_pcData) do
                        for _, hl in pairs(d) do hl.Enabled = false end
                    end
                end
            end
        })
        PlayerChamsBox:AddToggle('PlayerChamsRainbow', {
            Text = 'ʀᴀɪɴʙᴏᴡ', Default = false,
            Callback = function(v)
                _pcRainbow = v
                if not v then
                    _pcFillColor    = Color3.fromRGB(255, 255, 255)
                    _pcOutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        })
        PlayerChamsBox:AddColorPicker('PlayerChamsOutlineCol', {
            Title = 'Outline Color', Default = Color3.fromRGB(255, 255, 255),
            Callback = function(v)
                _pcOutlineColor = v
            end
        })
        PlayerChamsBox:AddColorPicker('PlayerChamsFillCol', {
            Title = 'Fill Color', Default = Color3.fromRGB(255, 255, 255),
            Callback = function(v)
                _pcFillColor = v
            end
        })
        PlayerChamsBox:AddSlider('PlayerChamsFillTrans', {
            Text = 'ꜰɪʟʟ ᴛʀᴀɴꜱᴘᴀʀᴇɴᴄʏ', Default = 5, Min = 0, Max = 10, Rounding = 0,
            Callback = function(v)
                _pcFillTrans = v / 10
            end
        })
        PlayerChamsBox:AddSlider('PlayerChamsOutlineTrans', {
            Text = 'ᴏᴜᴛʟɪɴᴇ ᴛʀᴀɴꜱᴘᴀʀᴇɴᴄʏ', Default = 0, Min = 0, Max = 10, Rounding = 0,
            Callback = function(v)
                _pcOutlineTrans = v / 10
            end
        })

    end
    -- =========================================================

        local VehicleEspBox = Tabs.ESP:AddRightGroupbox('ᴡᴏʀʟᴅ ᴇꜱᴘ')
        local _boatEspEnabled=false; local _boatEspObjs={}
        local _heliEspEnabled=false; local _heliEspConns={}
        local function _getCam()
            local c = workspace.CurrentCamera
            return (c and c:IsA("Camera")) and c or nil
        end

        local function _makeHL(model,color)
            if not model or not model:IsA("Model") then return nil end
            local hl=Instance.new("Highlight"); hl.FillColor=color; hl.OutlineColor=color
            hl.FillTransparency=0.4; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=model
            pcall(function() hl.Parent=game:GetService("CoreGui") end)
            if not hl.Parent then hl.Parent=LocalPlayer:FindFirstChildOfClass("PlayerGui") end
            return hl
        end
        local function _makeLbl(color)
            local lbl=Drawing.new("Text"); lbl.Size=10; lbl.Center=true; lbl.Outline=true; lbl.Color=color; lbl.Visible=false; lbl.Transparency=1; return lbl
        end

        local function _addBoatEsp(model)
            if not model:IsA("Model") or not model:FindFirstChild("Hull") then return end
            local hl=_makeHL(model,Color3.fromRGB(0,150,255)); local lbl=_makeLbl(Color3.fromRGB(80,180,255))
            local hull=model:FindFirstChild("Hull")
            -- no per-object connection; rendered in shared loop below
            table.insert(_boatEspObjs,{hl=hl,lbl=lbl,model=model,hull=hull})
        end

        VehicleEspBox:AddToggle('BoatEspEnabled',{Text='ʙᴏᴀᴛ ᴇꜱᴘ',Default=false,Callback=function(v)
            _boatEspEnabled=v
            for _,e in ipairs(_boatEspObjs) do e.lbl:Remove(); if e.hl then pcall(function() e.hl:Destroy() end) end end
            _boatEspObjs={}
            if not v then return end
            for _,obj in ipairs(workspace:GetChildren()) do _addBoatEsp(obj) end
            workspace.ChildAdded:Connect(function(obj) if _boatEspEnabled then task.wait(0.3); _addBoatEsp(obj) end end)
        end})

        -- Car ESP
        local _carEspEnabled = false
        local _carEspObjs = {}
        local _carEspCadrs = 0
        local function _clearCarEsp()
            for _, text in pairs(_carEspObjs) do
                if text then text.Visible = false end
            end
        end
        VehicleEspBox:AddToggle('CarEspEnabled',{Text='ᴄᴀʀ ᴇꜱᴘ',Default=false,Callback=function(v)
            _carEspEnabled = v
            if not v then
                for _, e in pairs(_carEspObjs) do
                    if e.lbl then pcall(function() e.lbl:Remove() end) end
                end
                _carEspObjs = {}
            end
        end})

        -- ATV ESP
        local _atvEspEnabled = false
        local _atvEspObjs = {}
        local _atvEspCadrs = 0
        VehicleEspBox:AddToggle('AtvEspEnabled', {Text='ᴀᴛᴠ ᴇꜱᴘ', Default=false, Callback=function(v)
            _atvEspEnabled = v
            if not v then
                for _, e in pairs(_atvEspObjs) do
                    if e.lbl then pcall(function() e.lbl:Remove() end) end
                end
                _atvEspObjs = {}
            end
        end})

        VehicleEspBox:AddToggle('HeliEspEnabled',{Text='ʜᴇʟɪᴄᴏᴘᴛᴇʀ ᴇꜱᴘ',Default=false,Callback=function(v)
            _heliEspEnabled=v
            if v then
                local function makeHeliLbl(model)
                    local part=model:FindFirstChild("HeadLockPart"); if not part then return end
                    local lbl=_makeLbl(Color3.fromRGB(0,255,150))
                    table.insert(_heliEspConns,{lbl=lbl,part=part})
                end
                for _,obj in ipairs(workspace:GetChildren()) do if obj:IsA("Model") and obj:FindFirstChild("HeadLockPart") then makeHeliLbl(obj) end end
                workspace.ChildAdded:Connect(function(obj) if _heliEspEnabled and obj:IsA("Model") then task.wait(0.5); if obj:FindFirstChild("HeadLockPart") then makeHeliLbl(obj) end end end)
            else
                for _,e in ipairs(_heliEspConns) do e.lbl:Remove() end; _heliEspConns={}
            end
        end})

        local _totemEspEnabled = false
        local _totemEspObjs = {}

        local _totemPartName = nil
        pcall(function()
            local prefab = game:GetService("ReplicatedStorage").Shared.items["place downs"].ClaimTotemItem.Image.ClaimTotem
            local state = prefab:FindFirstChild("State")
            if state and state:IsA("BasePart") then
                _totemPartName = state.Name
            end
        end)

        local function _addTotemEsp(obj)
            if not obj:IsA("BasePart") then return end
            local n = obj.Name:lower()
            if not (n:find("totem") or n:find("claim") or (_totemPartName and obj.Name == _totemPartName)) then return end
            for _, e in ipairs(_totemEspObjs) do
                if e.part == obj then return end
            end
            local lbl = Drawing.new("Text")
            lbl.Size = 10; lbl.Center = true; lbl.Font = Drawing.Fonts.Monospace
            lbl.Outline = true; lbl.OutlineColor = Color3.new(0,0,0)
            lbl.Color = Color3.fromRGB(255,200,0); lbl.Visible = false; lbl.Transparency = 1
            table.insert(_totemEspObjs, {part=obj, lbl=lbl})
        end

        VehicleEspBox:AddToggle('TotemEspEnabled',{Text='ᴄʟᴀɪᴍ ᴛᴏᴛᴇᴍ ᴇꜱᴘ',Default=false,Callback=function(v)
            _totemEspEnabled = v
            for _,e in ipairs(_totemEspObjs) do e.lbl:Remove() end
            _totemEspObjs = {}
            if not v then return end
            for _,obj in ipairs(workspace:GetDescendants()) do
                _addTotemEsp(obj)
            end
            workspace.DescendantAdded:Connect(function(obj)
                if _totemEspEnabled then
                    task.wait(0.3)
                    _addTotemEsp(obj)
                end
            end)
        end})


        -- Shared RenderStepped loop for boat/heli — one camera snapshot, zero per-object jitter
        RunService.RenderStepped:Connect(function()
            local cam = _getCam(); if not cam then return end
            local camPos = cam.CFrame.Position

            if _boatEspEnabled then
                for i = #_boatEspObjs, 1, -1 do
                    local e = _boatEspObjs[i]
                    if not e.model or not e.model.Parent then
                        e.lbl:Remove(); if e.hl then pcall(function() e.hl:Destroy() end) end
                        table.remove(_boatEspObjs, i); continue
                    end
                    local hull = e.model:FindFirstChild("Hull") or e.model:FindFirstChildOfClass("BasePart")
                    if hull then
                        local ok,vp = pcall(function() return cam:WorldToViewportPoint(hull.Position+Vector3.new(0,3,0)) end)
                        if ok and vp and vp.Z > 0 then
                            e.lbl.Position = Vector2.new(vp.X, vp.Y)
                            e.lbl.Text = string.format("boat [%.0f]", (camPos-hull.Position).Magnitude)
                            e.lbl.Size = 10; e.lbl.Visible = true
                        else e.lbl.Visible = false end
                    else e.lbl.Visible = false end
                end
            else
                for _,e in ipairs(_boatEspObjs) do e.lbl.Visible = false end
            end

            if _carEspEnabled then
                -- Rescan workspace every 3 frames to pick up new/removed cars
                _carEspCadrs = _carEspCadrs + 1
                if _carEspCadrs >= 3 then
                    _carEspCadrs = 0
                    local seen = {}
                    for _, obj in ipairs(workspace:GetChildren()) do
                        local _carBody = obj:FindFirstChild("Body")
                        local _carBodySize = _carBody and _carBody:IsA("BasePart") and math.abs(_carBody.Size.X - 7.76) < 0.1
                        if obj:IsA("Model") and not _carBodySize and (obj:FindFirstChild("FRWheel") or obj:FindFirstChild("FLWheel")) and (obj:FindFirstChild("Frame") or _carBody) then
                            seen[obj] = true
                            if not _carEspObjs[obj] then
                                local lbl = Drawing.new("Text")
                                lbl.Size = 10
                                lbl.Center = true
                                lbl.Font = Drawing.Fonts.Monospace
                                lbl.Outline = true
                                lbl.OutlineColor = Color3.new(0, 0, 0)
                                lbl.Color = Color3.fromRGB(255, 0, 0)
                                lbl.Visible = false
                                _carEspObjs[obj] = { lbl = lbl, part = obj:FindFirstChild("Frame") or obj:FindFirstChild("Body") }
                            end
                        end
                    end
                    -- Remove labels for cars that are gone
                    for obj, e in pairs(_carEspObjs) do
                        if not seen[obj] then
                            pcall(function() e.lbl:Remove() end)
                            _carEspObjs[obj] = nil
                        end
                    end
                end
                -- Update label positions every frame so they don't shake
                for obj, e in pairs(_carEspObjs) do
                    local part = e.part
                    if part and part.Parent then
                        local ok, vp = pcall(function() return cam:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0)) end)
                        if ok and vp and vp.Z > 0 then
                            e.lbl.Position = Vector2.new(vp.X, vp.Y)
                            e.lbl.Text = string.format("car [%.0f]", (camPos - part.Position).Magnitude)
                            e.lbl.Visible = true
                        else
                            e.lbl.Visible = false
                        end
                    else
                        e.lbl.Visible = false
                    end
                end
            else
                for _, e in pairs(_carEspObjs) do
                    if e.lbl then e.lbl.Visible = false end
                end
            end

            if _atvEspEnabled then
                _atvEspCadrs = _atvEspCadrs + 1
                if _atvEspCadrs >= 3 then
                    _atvEspCadrs = 0
                    local seen = {}
                    for _, obj in ipairs(workspace:GetChildren()) do
                        local _atvBody = obj:FindFirstChild("Body")
                        local _atvBodySize = _atvBody and _atvBody:IsA("BasePart") and math.abs(_atvBody.Size.X - 7.76) < 0.1
                        if obj:IsA("Model") and _atvBodySize
                            and (obj:FindFirstChild("FRWheel") or obj:FindFirstChild("FLWheel"))
                            and _atvBody then
                            seen[obj] = true
                            if not _atvEspObjs[obj] then
                                local lbl = Drawing.new("Text")
                                lbl.Size = 10
                                lbl.Center = true
                                lbl.Font = Drawing.Fonts.Monospace
                                lbl.Outline = true
                                lbl.OutlineColor = Color3.new(0, 0, 0)
                                lbl.Color = Color3.fromRGB(255, 182, 210)
                                lbl.Visible = false
                                _atvEspObjs[obj] = {
                                    lbl  = lbl,
                                    part = _atvBody
                                }
                            end
                        end
                    end
                    for obj, e in pairs(_atvEspObjs) do
                        if not seen[obj] then
                            pcall(function() e.lbl:Remove() end)
                            _atvEspObjs[obj] = nil
                        end
                    end
                end
                for obj, e in pairs(_atvEspObjs) do
                    local part = e.part
                    if part and part.Parent then
                        local ok, vp = pcall(function()
                            return cam:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0))
                        end)
                        if ok and vp and vp.Z > 0 then
                            e.lbl.Position = Vector2.new(vp.X, vp.Y)
                            e.lbl.Text = string.format("atv [%.0f]", (camPos - part.Position).Magnitude)
                            e.lbl.Visible = true
                        else
                            e.lbl.Visible = false
                        end
                    else
                        e.lbl.Visible = false
                    end
                end
            else
                for _, e in pairs(_atvEspObjs) do
                    if e.lbl then e.lbl.Visible = false end
                end
            end

            if _heliEspEnabled then
                for i = #_heliEspConns, 1, -1 do
                    local e = _heliEspConns[i]
                    if not e.part or not e.part.Parent then
                        e.lbl:Remove(); table.remove(_heliEspConns, i); continue
                    end
                    local ok,vp = pcall(function() return cam:WorldToViewportPoint(e.part.Position+Vector3.new(0,3,0)) end)
                    if ok and vp and vp.Z > 0 then
                        e.lbl.Position = Vector2.new(vp.X, vp.Y)
                        e.lbl.Text = string.format("heli [%.0f]", (camPos-e.part.Position).Magnitude)
                        e.lbl.Size = 10; e.lbl.Visible = true
                    else e.lbl.Visible = false end
                end
            else
                for _,e in ipairs(_heliEspConns) do e.lbl.Visible = false end
            end

            if _totemEspEnabled then
                for i = #_totemEspObjs, 1, -1 do
                    local e = _totemEspObjs[i]
                    if not e.part or not e.part.Parent then
                        e.lbl:Remove(); table.remove(_totemEspObjs, i); continue
                    end
                    local dist = (camPos - e.part.Position).Magnitude
                    if dist > 1000 then e.lbl.Visible = false; continue end
                    local ok,vp = pcall(function() return cam:WorldToViewportPoint(e.part.Position) end)
                    if ok and vp and vp.Z > 0 then
                        e.lbl.Position = Vector2.new(vp.X, vp.Y)
                        e.lbl.Text = string.format("claim totem [%.0f]", dist)
                        e.lbl.Size = 10; e.lbl.Visible = true
                    else e.lbl.Visible = false end
                end
            else
                for _,e in ipairs(_totemEspObjs) do e.lbl.Visible = false end
            end


        end)

    end

    do
        local LightBox = Tabs.World:AddLeftGroupbox('ʟɪɢʜᴛɪɴɢ')
        local SkyBox   = Tabs.World:AddRightGroupbox('ꜱᴋʏʙᴏx')
        local PerfBox  = Tabs.World:AddRightGroupbox('ᴘᴇʀꜰᴏʀᴍᴀɴᴄᴇ')

        -- Equip/shoot in water fix: hook IsSwimming to always return false
        local _isSwimHooked = false
        local MiscBox = Tabs.Combat:AddRightGroupbox('ShootInWater  ')
        MiscBox:AddToggle('ShootInWater', {Text='ᴇQᴜɪᴘ ɢᴜɴ ɪɴ ᴡᴀᴛᴇʀ', Default=false,
            Callback=function(v)
                if v and not _isSwimHooked then
                    pcall(function()
                        local classes = getrenv()._G.classes
                        local char = classes.Character
                        hookfunction(char.IsSwimming, newcclosure(function(...) return false end))
                        _isSwimHooked = true
                    end)
                end
            end})

        local _timeChangerEnabled = false
        local _timeChangerValue   = math.round(Lighting.ClockTime)
        RunService.Heartbeat:Connect(function()
            if _timeChangerEnabled then
                Lighting.ClockTime = _timeChangerValue
            end
        end)
        LightBox:AddToggle('TimeChangerEnabled',{Text='ᴛɪᴍᴇ ᴄʜᴀɴɢᴇʀ',Default=false,Callback=function(v)
            _timeChangerEnabled = v
        end})
        LightBox:AddSlider('TimeChangerValue',{Text='ᴛɪᴍᴇ',Default=math.round(Lighting.ClockTime),Min=0,Max=24,Callback=function(v)
            _timeChangerValue = v
        end})

        -- FOV Changer (from dedsamodell — instant RenderStepped apply)
        local _fovSettings = { fovEnabled = false, fovValue = 70 }

        LightBox:AddToggle('FovEnabled',{Text='ꜰᴏᴠ ᴄʜᴀɴɢᴇʀ',Default=false,Callback=function(v)
            _fovSettings.fovEnabled = v
            S.FovEnabled = v
            if not v then workspace.CurrentCamera.FieldOfView = 70 end
        end})
        LightBox:AddSlider('FovValue',{Text='ꜰᴏᴠ',Default=70,Min=30,Max=120,Callback=function(v)
            _fovSettings.fovValue = v
            S.FovValue = v
        end})

        RunService.RenderStepped:Connect(function()
            if _fovSettings.fovEnabled then
                workspace.CurrentCamera.FieldOfView = _fovSettings.fovValue
            end
        end)

        -- ── Ambient Color Picker (Heartbeat-enforced, no flicker) ────────────
        local _ambEnabled   = false
        local _ambColor     = Color3.fromRGB(70, 70, 70)
        local _ambOrigColor = Lighting.Ambient

        -- Enforce every single Heartbeat (no throttle) so game scripts
        -- cannot overwrite our value between frames → no flicker.
        RunService.Heartbeat:Connect(function()
            if not _ambEnabled then return end
            if Lighting.Ambient ~= _ambColor then
                Lighting.Ambient = _ambColor
            end
        end)

        local AmbBox = Tabs.World:AddLeftGroupbox('ᴀᴍʙɪᴇɴᴛ ᴄᴏʟᴏʀ')
        AmbBox:AddToggle('AmbientColorEnabled', {Text='ᴇɴᴀʙʟᴇ ᴀᴍʙɪᴇɴᴛ ᴄᴏʟᴏʀ', Default=false,
            Callback=function(v)
                _ambEnabled = v
                if not v then
                    Lighting.Ambient = _ambOrigColor
                end
            end})
        AmbBox:AddColorPicker('AmbientColor', {Title='Ambient (тень)', Default=Color3.fromRGB(70,70,70),
            Callback=function(v)
                _ambColor = v
                if _ambEnabled then Lighting.Ambient = v end
            end})
        -- ─────────────────────────────────────────────────────────────────────

        -- ── Cloud Color Picker (Heartbeat-enforced, no flicker) ──────────────
        local _cloudEnabled   = false
        local _cloudColor     = Color3.fromRGB(255, 255, 255)
        local _cloudOrigColor = nil
        pcall(function()
            local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
            if clouds then _cloudOrigColor = clouds.Color end
        end)

        RunService.Heartbeat:Connect(function()
            if not _cloudEnabled then return end
            local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
            if not clouds then return end
            if clouds.Color ~= _cloudColor then
                clouds.Color = _cloudColor
            end
        end)

        local CloudBox = Tabs.World:AddLeftGroupbox('ᴄʟᴏᴜᴅ ᴄᴏʟᴏʀ')
        CloudBox:AddToggle('CloudColorEnabled', {Text='ᴇɴᴀʙʟᴇ ᴄʟᴏᴜᴅ ᴄᴏʟᴏʀ', Default=false,
            Callback=function(v)
                _cloudEnabled = v
                if not v then
                    pcall(function()
                        local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
                        if clouds and _cloudOrigColor then
                            clouds.Color = _cloudOrigColor
                        end
                    end)
                end
            end})
        CloudBox:AddColorPicker('CloudColor', {Title='Cloud Color', Default=Color3.fromRGB(255,255,255),
            Callback=function(v)
                _cloudColor = v
                if _cloudEnabled then
                    pcall(function()
                        local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
                        if clouds then clouds.Color = v end
                    end)
                end
            end})
        -- ─────────────────────────────────────────────────────────────────────
        SkyBox:AddToggle('SkyboxEnabled',{Text='ᴇɴᴀʙʟᴇ ꜱᴋʏʙᴏx',Default=false,Callback=function(v) S.SkyboxEnabled=v; _updateSkybox() end})
        SkyBox:AddDropdown('SkyboxChoice',{Values={'Purple Nebula','Minecraft','Night Sky','SpongeBob Sky','Purple Sky','Pink Sky'},Default=4,Text='ꜱᴇʟᴇᴄᴛ ꜱᴋʏʙᴏx',
            Callback=function(v) S.SkyboxChoice=v; if S.SkyboxEnabled then _updateSkybox() end end})

        PerfBox:AddToggle('RemoveClouds',{Text='ʀᴇᴍᴏᴠᴇ ᴄʟᴏᴜᴅꜱ',Default=false,Callback=function(v) if v then local c=workspace.Terrain:FindFirstChildOfClass("Clouds"); if c then c:Destroy() end end end})
        PerfBox:AddToggle('RemoveLeaves',{Text='ʀᴇᴍᴏᴠᴇ ʟᴇᴀᴠᴇꜱ',Default=false,Callback=function(v)
            if v then
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name=="Elm1_Leaves" or obj.Name=="Fir3_Leaves" or obj.Name=="Birch1_Leaves" or obj.Name=="Palm1_Leaves" then pcall(function() obj:Destroy() end) end
                end
            end
        end})
        PerfBox:AddToggle('RemoveGrass',{Text='ʀᴇᴍᴏᴠᴇ ɢʀᴀꜱꜱ',Default=false,Callback=function(v)
            if v then pcall(function() local t=workspace:FindFirstChildOfClass("Terrain"); if t and sethiddenproperty then sethiddenproperty(t,"Decoration",false) end end) end
        end})
        PerfBox:AddToggle('WaterOpt',{Text='ᴡᴀᴛᴇʀ ᴏᴘᴛɪᴍɪᴢᴀᴛɪᴏɴ',Default=false,Callback=function(v)
            if v then local t=workspace.Terrain; t.WaterColor=Color3.fromRGB(33,233,255); t.WaterTransparency=0.25; t.WaterReflectance=0; t.WaterWaveSize=0; t.WaterWaveSpeed=0 end
        end})
        PerfBox:AddToggle('FlatTextures',{Text='ꜰʟᴀᴛ ᴛᴇxᴛᴜʀᴇꜱ',Default=false,Callback=function(v)
            if v then
                for _,obj in ipairs(game:GetDescendants()) do
                    pcall(function()
                        if obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("BasePart") then obj.Material=Enum.Material.SmoothPlastic
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then obj.Enabled=false
                        elseif obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") then obj.Enabled=false
                        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Texture="" end
                    end)
                end
            end
        end})

        local XrayBox = Tabs.World:AddLeftGroupbox('x-ʀᴀʏ')
        local _xrayTransparency = 0.6
        XrayBox:AddToggle('XrayEnabled',{Text='x-ʀᴀʏ',Default=false,Callback=function(v)
            S.XrayEnabled=v
            for _,obj in pairs(game:GetDescendants()) do
                if obj:FindFirstChild('Hitbox') then pcall(function() obj.Hitbox.Transparency=v and _xrayTransparency or 0 end) end
            end
        end})
        XrayBox:AddSlider('XrayTransparency',{Text='ᴛʀᴀɴꜱᴘᴀʀᴇɴᴄʏ',Default=60,Min=0,Max=100,
            Callback=function(v)
                _xrayTransparency = v / 100
                if S.XrayEnabled then
                    for _,obj in pairs(game:GetDescendants()) do
                        if obj:FindFirstChild('Hitbox') then pcall(function() obj.Hitbox.Transparency=_xrayTransparency end) end
                    end
                end
            end})

        local EnvBox = Tabs.World:AddRightGroupbox('ᴇɴᴠɪʀᴏɴᴍᴇɴᴛ ᴄᴏʟᴏʀꜱ')
        EnvBox:AddToggle('GrassColorEnabled',{Text='ɢʀᴀꜱꜱ ᴄᴏʟᴏʀ',Default=false,Callback=function(v)
            S.GrassColorEnabled=v; pcall(function() workspace.Terrain:SetMaterialColor(Enum.Material.Grass,v and S.GrassColor or Color3.fromRGB(93,111,55)) end)
        end})
        EnvBox:AddColorPicker('GrassColor',{Title='Grass Color',Default=Color3.fromRGB(93,111,55),Callback=function(v)
            S.GrassColor=v; if S.GrassColorEnabled then pcall(function() workspace.Terrain:SetMaterialColor(Enum.Material.Grass,v) end) end
        end})

        local ZoneBox = Tabs.World:AddLeftGroupbox('ᴢᴏɴᴇ ᴄʜᴀʀᴍꜱ')

        local _szEnabled = false
        local _szColor   = Color3.fromRGB(0,255,0)
        local _szPart    = workspace:FindFirstChild("World") and
                           workspace.World:FindFirstChild("Zones") and
                           workspace.World.Zones:FindFirstChild("SafeZones") and
                           workspace.World.Zones.SafeZones:FindFirstChild("SAFEZONE_Town")

        local _nbEnabled = false
        local _nbColor   = Color3.fromRGB(255,0,0)
        local _nbParts   = workspace:FindFirstChild("World") and
                           workspace.World:FindFirstChild("Zones") and
                           workspace.World.Zones:FindFirstChild("NoBuildZones")

        ZoneBox:AddToggle('SafeZoneCharm',{Text='ꜱᴀꜰᴇ ᴢᴏɴᴇ',Default=false,Callback=function(v)
            _szEnabled=v
            if not _szPart then return end
            if v then _szPart.Transparency=0.75; _szPart.Material=Enum.Material.ForceField; _szPart.Color=_szColor
            else  _szPart.Transparency=1; _szPart.Material=Enum.Material.Neon end
        end})
        ZoneBox:AddColorPicker('SafeZoneColor',{Title='Safe Zone Color',Default=Color3.fromRGB(0,255,0),Callback=function(v)
            _szColor=v; if _szEnabled and _szPart then _szPart.Color=v end
        end})
        ZoneBox:AddToggle('NoBuildZoneCharm',{Text='ɴᴏ ʙᴜɪʟᴅ ᴢᴏɴᴇ',Default=false,Callback=function(v)
            _nbEnabled=v
            if not _nbParts then return end
            for _,p in ipairs(_nbParts:GetDescendants()) do
                if p:IsA("BasePart") then
                    if v then p.Transparency=0.75; p.Material=Enum.Material.ForceField; p.Color=_nbColor
                    else  p.Transparency=1; p.Material=Enum.Material.Neon end
                end
            end
        end})
        ZoneBox:AddColorPicker('NoBuildZoneColor',{Title='No Build Zone Color',Default=Color3.fromRGB(255,0,0),Callback=function(v)
            _nbColor=v
            if _nbEnabled and _nbParts then
                for _,p in ipairs(_nbParts:GetDescendants()) do if p:IsA("BasePart") then p.Color=v end end
            end
        end})

    end


    do
        -- ── Gun & Arm Chams (from dedsamodell — Visuals.Chams system) ──────────
        local Viewmodel = game:GetService("ReplicatedStorage"):FindFirstChild("HandModels")
        local Visuals = {
            Chams = {
                WeaponChams = false, WeaponChams_Color = Color3.fromRGB(255, 182, 210), WeaponChams_Material = "ForceField",
                ArmChams    = false, ArmChams_Color    = Color3.fromRGB(255, 182, 210), ArmChams_Material    = "ForceField",
                Section     = Tabs.Arms,
            },
            Cache = { WeaponMaterial = {}, WeaponColor = {}, ArmMaterial = {}, ArmColor = {} },
        }

        if Viewmodel then
            for _, Child in pairs(Viewmodel:GetChildren()) do
                if Child:IsA("Model") then
                    for _, Part in pairs(Child:GetDescendants()) do
                        if Part:IsA("BasePart") then
                            Visuals.Cache.WeaponMaterial[Part] = Part.Material
                            Visuals.Cache.WeaponColor[Part]    = Part.Color
                        end
                    end
                end
            end
        end

        local _vcArmPartNames = {
            {"Const","Ignore","FPSArms","RightHand"},
            {"Const","Ignore","FPSArms","RightLowerArm"},
            {"Const","Ignore","FPSArms","LeftLowerArm"},
            {"Const","Ignore","FPSArms","LeftHand"},
            {"Const","Ignore","FPSArms","Fake","c_RightLowerArm"},
            {"Const","Ignore","FPSArms","Fake","c_LeftLowerArm"},
        }
        local function _vcFindPath(root, paths)
            local cur = root
            for _, p in ipairs(paths) do cur = cur:FindFirstChild(p); if not cur then return nil end end
            return cur
        end
        local function _vcRecacheArms()
            Visuals.Cache.ArmMaterial = {}; Visuals.Cache.ArmColor = {}
            for _, paths in ipairs(_vcArmPartNames) do
                local p = _vcFindPath(workspace, paths)
                if p and p:IsA("BasePart") then
                    Visuals.Cache.ArmMaterial[p] = p.Material
                    Visuals.Cache.ArmColor[p]    = p.Color
                end
            end
        end
        local function _vcGetArmParts()
            local parts = {}
            for _, paths in ipairs(_vcArmPartNames) do
                local p = _vcFindPath(workspace, paths)
                if p and p:IsA("BasePart") then table.insert(parts, p) end
            end
            return parts
        end
        _vcRecacheArms()

        local _vcFpsArms = _vcFindPath(workspace, {"Const","Ignore","FPSArms"})
        if _vcFpsArms then
            _vcFpsArms.ChildAdded:Connect(function()
                task.wait(0.2); _vcRecacheArms()
                if Visuals.Chams.ArmChams then Visuals.Chams.Update() end
            end)
        end

        Visuals.Chams.Update = function()
            if Viewmodel then
                for _, Child in pairs(Viewmodel:GetChildren()) do
                    if Child:IsA("Model") then
                        for _, Part in pairs(Child:GetDescendants()) do
                            if Part:IsA("BasePart") then
                                if Visuals.Chams.WeaponChams then
                                    Part.Material = Enum.Material[Visuals.Chams.WeaponChams_Material]
                                    Part.Color    = Visuals.Chams.WeaponChams_Color
                                else
                                    local origMat = Visuals.Cache.WeaponMaterial[Part]
                                    local origCol = Visuals.Cache.WeaponColor[Part]
                                    if origMat then Part.Material = origMat end
                                    if origCol then Part.Color    = origCol end
                                end
                            end
                        end
                    end
                end
            end
            local armParts = _vcGetArmParts()
            for _, part in ipairs(armParts) do
                if part and part.Parent then
                    if Visuals.Chams.ArmChams then
                        part.Material = Enum.Material[Visuals.Chams.ArmChams_Material]
                        part.Color    = Visuals.Chams.ArmChams_Color
                    else
                        local origMat = Visuals.Cache.ArmMaterial[part]
                        local origCol = Visuals.Cache.ArmColor[part]
                        if origMat then part.Material = origMat end
                        if origCol then part.Color    = origCol end
                    end
                end
            end
        end

        RunService.Heartbeat:Connect(function()
            if not Visuals.Chams.ArmChams then return end
            local armParts = _vcGetArmParts()
            for _, part in ipairs(armParts) do
                if part and part.Parent then
                    part.Material = Enum.Material[Visuals.Chams.ArmChams_Material]
                    part.Color    = Visuals.Chams.ArmChams_Color
                end
            end
        end)

        local ArmBox = Tabs.Arms:AddLeftGroupbox('ᴀʀᴍ ᴄʜᴀᴍꜱ')
        local WeaponBox = Tabs.Arms:AddRightGroupbox('ɢᴜɴ ᴄʜᴀᴍꜱ')
        local _vcMaterials = {"ForceField","Neon","CrackedLava","Glass","SmoothPlastic","Metal","DiamondPlate","Plastic"}

        local WeaponChamsTog = WeaponBox:AddToggle('WeaponChams', {
            Text = 'ᴡᴇᴀᴘᴏɴ ᴄʜᴀᴍꜱ', Default = false,
            Callback = function(v) Visuals.Chams.WeaponChams = v; Visuals.Chams.Update() end
        })
        WeaponBox:AddColorPicker('WeaponChamsColor', {
            Title = 'Weapon Color', Default = Color3.fromRGB(255, 182, 210),
            Callback = function(v) Visuals.Chams.WeaponChams_Color = v; if Visuals.Chams.WeaponChams then Visuals.Chams.Update() end end
        })
        WeaponBox:AddDropdown('WeaponMaterial', {
            Text = 'ᴡᴇᴀᴘᴏɴ ᴍᴀᴛᴇʀɪᴀʟ', Default = 1, Values = _vcMaterials,
            Callback = function(v) Visuals.Chams.WeaponChams_Material = v; if Visuals.Chams.WeaponChams then Visuals.Chams.Update() end end
        })

        local ArmChamsTog = ArmBox:AddToggle('ArmChamsHL', {
            Text = 'ᴇɴᴀʙʟᴇ ᴀʀᴍ ᴄʜᴀᴍꜱ', Default = false,
            Callback = function(v) Visuals.Chams.ArmChams = v; Visuals.Chams.Update() end
        })
        ArmBox:AddColorPicker('ArmChamsColor', {
            Title = 'Arm Color', Default = Color3.fromRGB(255, 182, 210),
            Callback = function(v) Visuals.Chams.ArmChams_Color = v; if Visuals.Chams.ArmChams then Visuals.Chams.Update() end end
        })
        ArmBox:AddDropdown('ArmMaterial', {
            Text = 'ᴀʀᴍ ᴍᴀᴛᴇʀɪᴀʟ', Default = 1, Values = _vcMaterials,
            Callback = function(v) Visuals.Chams.ArmChams_Material = v; if Visuals.Chams.ArmChams then Visuals.Chams.Update() end end
        })
    end

    do
        local BagBox = Tabs.Resources:AddLeftGroupbox('ʙᴀᴄᴋᴘᴀᴄᴋ (ᴅɪꜱᴛᴀɴᴄᴇ)')

        BagBox:AddToggle('BagEspEnabled',{Text='ʙᴀᴄᴋᴘᴀᴄᴋ ᴇꜱᴘ',Default=false,Callback=function(v) S.BagEspEnabled=v end})

        local LootESP2 = {
            enabled     = false,
            maxDistance = 2000,
            cache       = setmetatable({}, {__mode="k"}),
            data        = setmetatable({}, {__mode="k"}),
            Bucket   = { textColor=Color3.fromRGB(255,165,0),   textSize=10, label="bucket",        textEnabled=false },
            Box      = { textColor=Color3.fromRGB(230,182,0),   textSize=10, label="defaultbox",    textEnabled=false },
            Chest    = { textColor=Color3.fromRGB(150,150,150), textSize=10, label="metalbox",      textEnabled=false },
            Crafting = { textColor=Color3.fromRGB(255,0,207),   textSize=10, label="healthmachine", textEnabled=false },
            Crate    = { textColor=Color3.fromRGB(44,97,0),     textSize=10, label="greencrate",    textEnabled=false },
            Vault    = { textColor=Color3.fromRGB(100,100,100), textSize=10, label="safe",          textEnabled=false },
            Gas      = { textColor=Color3.fromRGB(200,0,0),     textSize=10, label="gasoline",      textEnabled=false },
        }
        local lootTypes2 = {"Bucket","Box","Chest","Crafting","Crate","Vault","Gas"}

        local function _isSalvage2(model)
            local cached = LootESP2.cache[model]
            if cached ~= nil then return cached end
            if not model:IsA("Model") then LootESP2.cache[model]=false; return false end
            if model:FindFirstChild("default") then
                local n=0
                for _,c in ipairs(model:GetChildren()) do if c:IsA("BasePart") and c.Name=="Part" then n=n+1 end end
                if n>=10 then LootESP2.cache[model]="Bucket"; return "Bucket" end
            end
            local boxM=model:FindFirstChild("box"); local trash=model:FindFirstChild("trash")
            if boxM and boxM:IsA("MeshPart") and trash and trash:IsA("MeshPart") then LootESP2.cache[model]="Box"; return "Box" end
            local bodyM=model:FindFirstChild("Body"); local defP=model:FindFirstChild("default")
            if bodyM and bodyM:IsA("MeshPart") and defP and defP:IsA("BasePart") then LootESP2.cache[model]="Chest"; return "Chest" end
            if model:FindFirstChild("Dispenser") and model:FindFirstChild("Machine") and model:FindFirstChild("Sign") then LootESP2.cache[model]="Crafting"; return "Crafting" end
            if model:FindFirstChild("Bottom") and model:FindFirstChild("Handles") and model:FindFirstChild("Top") then LootESP2.cache[model]="Crate"; return "Crate" end
            if model:FindFirstChild("Body") and model:FindFirstChild("Bolts") and model:FindFirstChild("Dials") and model:FindFirstChild("Hinge") and model:FindFirstChild("Pins") and model:FindFirstChild("Wheel") then LootESP2.cache[model]="Vault"; return "Vault" end
            local prim=model:FindFirstChild("Prim")
            if prim and prim:FindFirstChildWhichIsA("SpecialMesh") then LootESP2.cache[model]="Gas"; return "Gas" end
            LootESP2.cache[model]=false; return false
        end

        local function _newLootText2(s)
            local t=Drawing.new("Text")
            t.Text=s.label; t.Size=s.textSize; t.Center=true; t.Font=2
            t.Outline=true; t.OutlineColor=Color3.new(0,0,0); t.Color=s.textColor; t.Visible=false
            return t
        end

        local function _createLootESP2(model)
            if LootESP2.data[model] then return end
            local kind=_isSalvage2(model)
            if not kind then return end
            local s=LootESP2[kind]; if not s then return end
            local anchor=model:FindFirstChildWhichIsA("BasePart"); if not anchor then return end
            local t=_newLootText2(s)
            local conn=model.AncestryChanged:Connect(function()
                if not model.Parent then t:Remove(); LootESP2.data[model]=nil; LootESP2.cache[model]=nil end
            end)
            LootESP2.data[model]={t=t,anchor=anchor,conn=conn,kind=kind}
        end

        local function _removeLootESP2(model)
            local d=LootESP2.data[model]; if not d then return end
            d.conn:Disconnect(); if d.t then d.t:Remove() end
            LootESP2.data[model]=nil; LootESP2.cache[model]=nil
        end

        for _,m in ipairs(workspace:GetChildren()) do task.spawn(_createLootESP2, m) end
        workspace.ChildAdded:Connect(function(m) task.spawn(_createLootESP2, m) end)
        workspace.ChildRemoved:Connect(_removeLootESP2)

local _lastLootUpdate = 0
local LOOT_INTERVAL = 1 / 20

RunService.Heartbeat:Connect(function()
    if tick() - _lastLootUpdate < LOOT_INTERVAL then return end
    _lastLootUpdate = tick()
    local cam2 = workspace.CurrentCamera
    if not cam2 or not cam2:IsA("Camera") then return end
    local camPos2 = cam2.CFrame.Position
    local vp2 = cam2.ViewportSize
    for model, d in pairs(LootESP2.data) do
        if not model or not model.Parent or not d.anchor or not d.anchor.Parent then
            _removeLootESP2(model)
        else
            local s = LootESP2[d.kind]
            if not s then _removeLootESP2(model) else
                local aPos = d.anchor.Position
                local diff = aPos - camPos2
                if d.t then
                    if s.textEnabled and (diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z) <= (LootESP2.maxDistance * LootESP2.maxDistance) then
                        local ok, sp = pcall(function() return cam2:WorldToViewportPoint(aPos) end)
                        if ok and sp and sp.Z > 0 then
                            d.t.Position = Vector2.new(
                                math.clamp(sp.X, 20, vp2.X - 20),
                                math.clamp(sp.Y - 20, 20, vp2.Y - 20))
                            d.t.Color   = s.textColor
                            d.t.Visible = true
                        else d.t.Visible = false end
                    else d.t.Visible = false end
                end
            end
        end
    end
end)

        local BoxEspBox2 = Tabs.Resources:AddLeftGroupbox('ʙᴏx ᴇꜱᴘ')

        BoxEspBox2:AddToggle('LootEsp2Master',{Text='ᴇɴᴀʙʟᴇ ʙᴏx ᴇꜱᴘ',Default=false,Callback=function(v)
            LootESP2.enabled=v
            for _,d in pairs(LootESP2.data) do if d and d.t then d.t.Visible=LootESP2[d.kind].textEnabled and v end end
        end})
        BoxEspBox2:AddSlider('LootEsp2MaxDist',{Text='ᴍᴀx ᴅɪꜱᴛᴀɴᴄᴇ',Default=2000,Min=250,Max=2000,Rounding=0,Callback=function(v) LootESP2.maxDistance=v end})
        BoxEspBox2:AddDivider()
        for _,key in ipairs(lootTypes2) do
            BoxEspBox2:AddToggle('LootEsp2_'..key,{Text=LootESP2[key].label,Default=false,Callback=function(v)
                LootESP2[key].textEnabled=v
                for _,d in pairs(LootESP2.data) do
                    if d and d.kind==key and d.t then d.t.Visible=v and LootESP2.enabled end
                end
            end})
            BoxEspBox2:AddColorPicker('LootEsp2_'..key..'Color',{Title=LootESP2[key].label,Default=LootESP2[key].textColor,Callback=function(v)
                LootESP2[key].textColor=v
                for _,d in pairs(LootESP2.data) do if d and d.kind==key and d.t then d.t.Color=v end end
            end})
        end

        local OreBox = Tabs.Resources:AddRightGroupbox('ᴏʀᴇ ᴇꜱᴘ')

        local function _rebuildOreAllowed()
            S.ObjEspAllowed={}
            if S.NitrateEspEnabled then S.ObjEspAllowed["Nitrate"]=true end
            if S.IronEspEnabled    then S.ObjEspAllowed["Iron"]=true end
            if S.StoneEspEnabled   then S.ObjEspAllowed["Stone"]=true end
            S.ObjEspEnabled=S.NitrateEspEnabled or S.IronEspEnabled or S.StoneEspEnabled
        end

        OreBox:AddToggle('NitrateEspEnabled',{Text='ɴɪᴛʀᴀᴛᴇ ᴏʀᴇ',Default=false,Callback=function(v) S.NitrateEspEnabled=v; _rebuildOreAllowed(); if not v then for _,o in pairs(objEspDrawings) do if o.espname=="Nitrate" then o.name.Visible=false; o.dist.Visible=false end end end end})
        OreBox:AddColorPicker('NitrateEspColor',{Title='Nitrate Color',Default=Color3.fromRGB(255,255,255),Callback=function(v) S.NitrateEspColor=v; for _,o in pairs(objEspDrawings) do if o.espname=="Nitrate" then o.name.Color=v end end end})
        OreBox:AddToggle('IronEspEnabled',{Text='ɪʀᴏɴ ᴏʀᴇ',Default=false,Callback=function(v) S.IronEspEnabled=v; _rebuildOreAllowed(); if not v then for _,o in pairs(objEspDrawings) do if o.espname=="Iron" then o.name.Visible=false; o.dist.Visible=false end end end end})
        OreBox:AddColorPicker('IronEspColor',{Title='Iron Color',Default=Color3.fromRGB(255,215,0),Callback=function(v) S.IronEspColor=v; for _,o in pairs(objEspDrawings) do if o.espname=="Iron" then o.name.Color=v end end end})
        OreBox:AddToggle('StoneEspEnabled',{Text='ꜱᴛᴏɴᴇ ᴏʀᴇ',Default=false,Callback=function(v) S.StoneEspEnabled=v; _rebuildOreAllowed(); if not v then for _,o in pairs(objEspDrawings) do if o.espname=="Stone" then o.name.Visible=false; o.dist.Visible=false end end end end})
        OreBox:AddColorPicker('StoneEspColor',{Title='Stone Color',Default=Color3.fromRGB(100,180,255),Callback=function(v) S.StoneEspColor=v; for _,o in pairs(objEspDrawings) do if o.espname=="Stone" then o.name.Color=v end end end})
    end

    do
        local HsBox = Tabs.Sounds:AddLeftGroupbox('ʜᴇᴀᴅ ʜɪᴛꜱᴏᴜɴᴅ')
        local BsBox = Tabs.Sounds:AddRightGroupbox('ʙᴏᴅʏ ʜɪᴛꜱᴏᴜɴᴅ')

        HsBox:AddToggle('HeadSoundEnabled',{Text='ᴇɴᴀʙʟᴇᴅ',Default=false,Callback=function(v) S.HeadSoundEnabled=v end})
        HsBox:AddDropdown('HeadSoundChoice',{Values=_tridentSoundList,Default=1,Text='ꜱᴏᴜɴᴅ',
            Callback=function(v) local id=_tridentSounds[v]; if id then pcall(function() _SoundService.PlayerHitHeadshot.SoundId=id end) end end})
        HsBox:AddSlider('HeadSoundVolume',{Text='ᴠᴏʟᴜᴍᴇ',Default=5,Min=0,Max=10,Callback=function(v) pcall(function() _SoundService.PlayerHitHeadshot.Volume=v end) end})

        BsBox:AddToggle('BodySoundEnabled',{Text='ᴇɴᴀʙʟᴇᴅ',Default=false,Callback=function(v) S.BodySoundEnabled=v end})
        BsBox:AddDropdown('BodySoundChoice',{Values=_tridentSoundList,Default=2,Text='ꜱᴏᴜɴᴅ',
            Callback=function(v) local id=_tridentSounds[v]; if id then pcall(function() _SoundService.PlayerHit2.SoundId=id end) end end})
        BsBox:AddSlider('BodySoundVolume',{Text='ᴠᴏʟᴜᴍᴇ',Default=5,Min=0,Max=10,Callback=function(v) pcall(function() _SoundService.PlayerHit2.Volume=v end) end})
    end

    local function _buildVehicles()

    -- ══════════════════════════════════════════════
    -- SECTION 1: CAR FLY
    -- ══════════════════════════════════════════════
    do
        local CFBox   = Tabs.Vehicles:AddLeftGroupbox('ᴄᴀʀ ꜰʟʏ')
        local InfoBox = Tabs.Vehicles:AddRightGroupbox('ᴄᴀʀ ꜰʟʏ ᴄᴏɴᴛʀᴏʟꜱ')

        local _cf = {
            enabled      = false,
            flightActive = false,
            noClip       = false,
            stabilize    = true,
            speed        = 10,
            vertSpeed    = 10,
            rotSpeed     = 3,
            activeVehicles = {},
            lastScan     = 0,
        }
        local _cfRotYaw  = 0
        local _cfHoldUp  = false
        local _cfHoldDn  = false
        local _cfHoldRotL = false
        local _cfHoldRotR = false

        -- Anchor tracking so we can restore original anchor state on unanchor
        local _cfAnchorCache = {}

        local function _anchorVehicle(v, state)
            if not v or not v.model then return end
            for _, p in pairs(v.model:GetDescendants()) do
                if p:IsA("BasePart") then
                    if state then
                        _cfAnchorCache[p] = p.Anchored
                        p.Anchored = true
                    else
                        p.Anchored = (_cfAnchorCache[p] ~= nil) and _cfAnchorCache[p] or false
                        _cfAnchorCache[p] = nil
                    end
                end
            end
        end

        local function _anchorAllVehicles(state)
            for _, v in pairs(_cf.activeVehicles) do
                _anchorVehicle(v, state)
            end
        end

        -- ── Seat Anchor (character pin) ──
        -- Creates a transparent part welded to the car, then welds the player's
        -- HumanoidRootPart to it. Keeps the character locked in place so bumps
        -- and server collisions can't eject the player from the seat.
        local _cfSeatPart  = nil
        local _cfSeatWeldA = nil   -- car mainPart  → seat part
        local _cfSeatWeldB = nil   -- HRP           → seat part

        local function _cfAttachSeat()
            -- Force a fresh scan so activeVehicles is populated even on first press
            _cf.lastScan = 0
            _cfScan()
            task.wait(0.05)  -- tiny yield so scan finishes before we read activeVehicles
            pcall(function()
                -- Clean up any old anchor first
                if _cfSeatPart and _cfSeatPart.Parent then _cfSeatPart:Destroy() end
                _cfSeatPart = nil; _cfSeatWeldA = nil; _cfSeatWeldB = nil

                -- Find the first active vehicle's mainPart
                local mp = nil
                for _, v in pairs(_cf.activeVehicles) do
                    if v.mainPart and v.mainPart.Parent then mp = v.mainPart; break end
                end
                if not mp then return end

                -- Get player HRP (Trident custom char or normal char)
                local hrp = nil
                local ign = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
                local tc  = ign and ign:FindFirstChild("LocalCharacter")
                if tc then
                    hrp = tc:FindFirstChild("Middle") or tc:FindFirstChild("HumanoidRootPart")
                end
                if not hrp and _lp.Character then
                    hrp = _lp.Character:FindFirstChild("HumanoidRootPart")
                end
                if not hrp then return end

                -- Create the anchor part (fully transparent, no collision)
                local anchor = Instance.new("Part")
                anchor.Name             = "CFSeatAnchor"
                anchor.Size             = Vector3.new(0.1, 0.1, 0.1)
                anchor.Transparency     = 1
                anchor.CanCollide       = false
                anchor.Anchored         = false
                anchor.CFrame           = mp.CFrame
                anchor.Parent           = mp.Parent  -- parent to vehicle model

                -- Weld anchor to car mainPart
                local wA = Instance.new("WeldConstraint")
                wA.Part0 = mp; wA.Part1 = anchor; wA.Parent = anchor

                -- Weld HRP to anchor
                local wB = Instance.new("WeldConstraint")
                wB.Part0 = anchor; wB.Part1 = hrp; wB.Parent = anchor

                _cfSeatPart  = anchor
                _cfSeatWeldA = wA
                _cfSeatWeldB = wB
            end)
        end

        local function _cfDetachSeat()
            pcall(function()
                if _cfSeatPart and _cfSeatPart.Parent then
                    _cfSeatPart:Destroy()
                end
            end)
            _cfSeatPart = nil; _cfSeatWeldA = nil; _cfSeatWeldB = nil
        end

        local function _cfScan()
            if tick() - _cf.lastScan < 2 then return end
            _cf.lastScan = tick()
            _cf.activeVehicles = {}

            local bestModel, bestDist, bestMp = nil, 50, nil

            local myPos = nil
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("BasePart")
                    if root then myPos = root.Position end
                end
            end)
            if not myPos then myPos = Camera.CFrame.Position end

            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name ~= "ATV" and (obj:FindFirstChild("FRWheel") or obj:FindFirstChild("FLWheel")) and (obj:FindFirstChild("Frame") or obj:FindFirstChild("Body")) then
                    local mp = obj:FindFirstChild("Frame") or obj:FindFirstChild("Body")
                    local dist = (mp.Position - myPos).Magnitude
                    if dist < bestDist then
                        bestDist  = dist
                        bestModel = obj
                        bestMp    = mp
                    end
                end
            end

            if bestModel then
                table.insert(_cf.activeVehicles, {
                    model    = bestModel,
                    mainPart = bestMp,
                })
            end
        end

        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if not _cf.enabled then return end
            if inp.KeyCode == Enum.KeyCode.B  then
                _cf.flightActive = not _cf.flightActive
                _anchorAllVehicles(_cf.flightActive)
                if _cf.flightActive then _cfAttachSeat() else _cfDetachSeat() end
            end
            if inp.KeyCode == Enum.KeyCode.Q  then _cfHoldRotL = true end
            if inp.KeyCode == Enum.KeyCode.E  then _cfHoldRotR = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.Q then _cfHoldRotL = false end
            if inp.KeyCode == Enum.KeyCode.E then _cfHoldRotR = false end
        end)

        -- Smooth velocity per vehicle (anti-rubber-band, zero alloc per frame)
        local _cfVel          = Vector3.zero
        local _cfVelMap       = {}
        local _cfNCFrame      = 0
        local _cfWasActive    = false  -- tracks previous frame flightActive to detect transitions



        -- Block all damage while flying
        -- Trident uses TCP RemoteEvent for server->client damage packets.
        -- We hook the TCP OnClientEvent to silently drop damage calls while flightActive.
        local _lp = game:GetService("Players").LocalPlayer

        local function _hookTCP()
            pcall(function()
                local tcp = _lp:WaitForChild("TCP", 10)
                if not tcp then return end
                local origFire = tcp.OnClientEvent
                -- hookfunction the internal fire so damage packets are swallowed mid-flight
                local conn = tcp.OnClientEvent:Connect(function(...)
                    -- packet type 1 = damage in most Trident builds; drop all while flying
                    if _cf.flightActive then return end
                end)
                -- Also hook via hookfunction if executor supports it
                pcall(function()
                    local meta = getrawmetatable(tcp)
                    local oldIndex = meta.__index
                    setreadonly(meta, false)
                    meta.__index = newcclosure(function(self, key)
                        if key == "OnClientEvent" and _cf.flightActive then
                            -- return a dummy signal that does nothing
                            return {Connect = function() return {Disconnect=function()end} end}
                        end
                        return oldIndex(self, key)
                    end)
                    setreadonly(meta, true)
                end)
            end)
        end
        task.spawn(_hookTCP)

        -- Fallback: also keep Humanoid guard + zero character velocity every frame
        local _cfHealthLoop = nil
        local function _startHealthGuard(hum)
            if _cfHealthLoop then _cfHealthLoop:Disconnect() end
            _cfHealthLoop = RunService.Heartbeat:Connect(function()
                if not _cf.flightActive then return end
                pcall(function()
                    if hum and hum.Parent then
                        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
                        local root = hum.Parent:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.AssemblyLinearVelocity  = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                    -- Zero Trident custom character part velocities
                    local ign = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
                    local tc  = ign and ign:FindFirstChild("LocalCharacter")
                    if tc then
                        for _, p in ipairs(tc:GetChildren()) do
                            if p:IsA("BasePart") then
                                p.AssemblyLinearVelocity  = Vector3.zero
                                p.AssemblyAngularVelocity = Vector3.zero
                            end
                        end
                    end
                end)
            end)
        end

        local _cfDmgConns = {}
        local function _hookDamage(char)
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if not hum then return end
            pcall(function()
                local orig = hum.TakeDamage
                hookfunction(orig, newcclosure(function(self, amount)
                    if _cf.flightActive then return end
                    return orig(self, amount)
                end))
            end)
            local conn = hum:GetPropertyChangedSignal("Health"):Connect(function()
                if _cf.flightActive and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
            table.insert(_cfDmgConns, conn)
            _startHealthGuard(hum)
        end
        if _lp.Character then _hookDamage(_lp.Character) end
        _lp.CharacterAdded:Connect(function(char)
            for _, c in ipairs(_cfDmgConns) do c:Disconnect() end
            _cfDmgConns = {}
            if _cfHealthLoop then _cfHealthLoop:Disconnect(); _cfHealthLoop = nil end
            _hookDamage(char)
        end)

        local CF_ACCEL = 8
        local CF_DECEL = 12
        local V3_ZERO  = Vector3.zero

        -- Drag Fly AI
        local _dfAI = {
            enabled     = false,
            spdOverride = nil,
        }
        local _dfSpdMulSmoothed  = 1.0  -- horizontal speed multiplier
        local _dfVSpdMulSmoothed = 1.0  -- vertical speed multiplier (up ray)
        -- Materials considered solid obstacles (walls, doors, metal, wood structures)
        local _dfSolidMats = {
            [Enum.Material.Metal]        = true,
            [Enum.Material.Wood]         = true,
            [Enum.Material.WoodPlanks]   = true,
            [Enum.Material.Brick]        = true,
            [Enum.Material.Concrete]     = true,
            [Enum.Material.SmoothPlastic]= true,
            [Enum.Material.Plastic]      = true,
            [Enum.Material.DiamondPlate] = true,
            [Enum.Material.CorrodedMetal]= true,
        }
        -- Raycast params: ignore the car model itself, ignore trees (Enum.Material.Grass/LeafyGrass)
        local _dfRayParams = RaycastParams.new()
        _dfRayParams.FilterType = Enum.RaycastFilterType.Exclude
        local function _dfUpdateRayParams(model)
            local ignore = {model}
            _dfRayParams.FilterDescendantsInstances = ignore
        end

        -- Drawing lines for ray visualisation (6 rays: 5 side + 1 ground)
        local _dfLines = {}
        for i = 1, 6 do
            local ln = Drawing.new("Line")
            ln.Thickness = 1
            ln.Visible   = false
            ln.Color     = Color3.fromRGB(0, 255, 0)
            _dfLines[i]  = ln
        end
        local _dfLineGround = _dfLines[6]  -- alias for clarity

        -- ── Proximity & Altitude Safety System ──
        -- Horizontal: cast 8 studs, INSTANTLY clamp to 10 when anything within 6 studs (trees, cacti, walls, all).
        -- Vertical up: slow to 20 when anything within 12 studs above.
        -- Vertical down: slow to 10 when within 5 studs of ground.
        local CF_SAFE_HSPD       = 10   -- max horizontal speed when near obstacle
        local CF_SAFE_HSPD_UP    = 20   -- max upward speed when ceiling within 12 studs
        local CF_SAFE_VSPD_DN    = 10   -- max downward speed when near ground
        local CF_SAFE_ALT_MAX    = 800  -- above this Y, upward speed is clamped
        local CF_SAFE_UP_DIST    = 12   -- studs above to trigger upward slow
        local CF_SAFE_DN_DIST    = 5    -- studs below to trigger downward slow
        local CF_SAFE_HORIZ_RAY  = 8    -- raycast length horizontally
        local CF_SAFE_HORIZ_TRIG = 6    -- distance at which horizontal clamp activates
        local CF_SAFE_LERP_VERT  = 5    -- lerp rate for vertical (smooth)
        local CF_SAFE_LERP_OUT   = 2    -- lerp rate leaving safe mode

        local _cfSafeUpMul    = 1.0
        local _cfSafeDnMul    = 1.0
        local _cfSafeHorizMul = 1.0

        local _cfSafeRayParams = RaycastParams.new()
        _cfSafeRayParams.FilterType = Enum.RaycastFilterType.Exclude

        local _cfHorizDirs = {
            Vector3.new( 1, 0, 0), Vector3.new(-1, 0, 0),
            Vector3.new( 0, 0, 1), Vector3.new( 0, 0,-1),
        }

        local function _cfUpdateSafety(mp, model, dt)
            _cfSafeRayParams.FilterDescendantsInstances = {model}
            local origin = mp.CFrame.Position

            -- ── Upward safety (smooth, 12 studs, clamp to 20) ──
            local dangerUp = (origin.Y > CF_SAFE_ALT_MAX)
            if not dangerUp then
                local upHit = workspace:Raycast(origin, Vector3.new(0, CF_SAFE_UP_DIST, 0), _cfSafeRayParams)
                if upHit then
                    dangerUp = (upHit.Position - origin).Magnitude < CF_SAFE_UP_DIST
                end
            end
            local targetUpMul = dangerUp and (CF_SAFE_HSPD_UP / math.max(_cf.vertSpeed, CF_SAFE_HSPD_UP)) or 1.0
            _cfSafeUpMul = _cfSafeUpMul + (targetUpMul - _cfSafeUpMul) * math.min(1, (dangerUp and CF_SAFE_LERP_VERT or CF_SAFE_LERP_OUT) * dt)

            -- ── Downward safety (smooth, 5 studs, clamp to 10) ──
            local dangerDn = false
            local downHit = workspace:Raycast(origin, Vector3.new(0, -CF_SAFE_DN_DIST, 0), _cfSafeRayParams)
            if downHit then
                dangerDn = (origin.Y - downHit.Position.Y) < CF_SAFE_DN_DIST
            end
            local targetDnMul = dangerDn and (CF_SAFE_VSPD_DN / math.max(_cf.vertSpeed, CF_SAFE_VSPD_DN)) or 1.0
            _cfSafeDnMul = _cfSafeDnMul + (targetDnMul - _cfSafeDnMul) * math.min(1, (dangerDn and CF_SAFE_LERP_VERT or CF_SAFE_LERP_OUT) * dt)

            -- ── Horizontal obstacle safety (INSTANT: any hit within 6 studs → speed 10) ──
            local dangerH = false
            for _, dir in ipairs(_cfHorizDirs) do
                local hit = workspace:Raycast(origin, dir * CF_SAFE_HORIZ_RAY, _cfSafeRayParams)
                if hit and (hit.Position - origin).Magnitude <= CF_SAFE_HORIZ_TRIG then
                    dangerH = true
                    break
                end
            end
            -- Instant snap: no lerp, set directly
            if dangerH then
                _cfSafeHorizMul = CF_SAFE_HSPD / math.max(_cf.speed, CF_SAFE_HSPD)
            else
                -- Smooth restore only
                _cfSafeHorizMul = _cfSafeHorizMul + (1.0 - _cfSafeHorizMul) * math.min(1, CF_SAFE_LERP_OUT * dt)
            end
        end

        -- Pre-cache keycodes to avoid Enum lookup overhead in hot loop
        local KC_W    = Enum.KeyCode.W
        local KC_S    = Enum.KeyCode.S
        local KC_A    = Enum.KeyCode.A
        local KC_D    = Enum.KeyCode.D
        local KC_N    = Enum.KeyCode.N
        local KC_LCTL = Enum.KeyCode.V
        local KC_RCTL = Enum.KeyCode.V

        RunService.Heartbeat:Connect(function(dt)
            if not _cf.enabled then return end
            if tick() - _cf.lastScan > 5 then _cfScan() end

            if _cfHoldRotL then _cfRotYaw = (_cfRotYaw - _cf.rotSpeed) % 360 end
            if _cfHoldRotR then _cfRotYaw = (_cfRotYaw + _cf.rotSpeed) % 360 end

            -- Read input once per frame, not per vehicle
            local UIS = UserInputService
            local kW = UIS:IsKeyDown(KC_W)
            local kS = UIS:IsKeyDown(KC_S)
            local kA = UIS:IsKeyDown(KC_A)
            local kD = UIS:IsKeyDown(KC_D)
            local kU = UIS:IsKeyDown(KC_N)    or _cfHoldUp
            local kDn= UIS:IsKeyDown(KC_LCTL) or _cfHoldDn

            -- Build horizontal direction once per frame
            local camLook = workspace.CurrentCamera.CFrame.LookVector
            local mx, mz  = camLook.X, camLook.Z
            local mlen    = math.sqrt(mx*mx + mz*mz)
            if mlen > 0 then mx = mx/mlen; mz = mz/mlen end
            local sx, sz  = -mz, mx   -- strafe = perpendicular

            -- Noclip throttled to every 30 frames
            _cfNCFrame = _cfNCFrame + 1
            local doNC = _cf.noClip and (_cfNCFrame % 30 == 0)

            -- ── Drag Fly AI raycast ──
            local _dfSpdMul = 1.0
            local _dfWallHit = false
            if _dfAI.enabled and _cf.flightActive then
                for _, v in pairs(_cf.activeVehicles) do
                    local mp = v.mainPart
                    if not mp or not mp.Parent then continue end
                    _dfUpdateRayParams(v.model)

                    local origin = mp.CFrame.Position

                    local camLookH = Vector3.new(mx, 0, mz).Unit
                    local rightH   = Vector3.new(mz, 0, -mx).Unit
                    local RAY_LEN  = 5

                    -- Rays: forward, forward-right 30°, forward-left 30°, right, left, UP
                    -- Each ray only slows the axis it corresponds to
                    local rayDirs = {
                        camLookH,
                        (camLookH + rightH * 0.577).Unit,
                        (camLookH - rightH * 0.577).Unit,
                        rightH,
                        -rightH,
                        Vector3.new(0, 1, 0),  -- straight up
                    }

                    local closestHoriz = RAY_LEN + 1  -- forward rays only
                    local closestUp    = RAY_LEN + 1  -- upward ray only
                    local cam          = workspace.CurrentCamera

                    for i, dir in ipairs(rayDirs) do
                        local hit    = workspace:Raycast(origin, dir * RAY_LEN, _dfRayParams)
                        local endPos = hit and hit.Position or (origin + dir * RAY_LEN)
                        local isHit  = hit ~= nil

                        if isHit then
                            local dist     = (hit.Position - origin).Magnitude
                            local mat      = hit.Material
                            local isTerrain = hit.Instance and hit.Instance:IsA("Terrain")
                            local isTree   = isTerrain and (
                                mat == Enum.Material.Grass or mat == Enum.Material.LeafyGrass
                                or mat == Enum.Material.Ground or mat == Enum.Material.Mud)

                            if not isTree then
                                if i <= 3 and dist < closestHoriz then
                                    -- forward rays affect horizontal speed
                                    closestHoriz = dist
                                elseif i == 6 and dist < closestUp then
                                    -- upward ray affects vertical speed only
                                    closestUp = dist
                                end
                            end
                        end

                        -- Draw ray lines
                        local ln = _dfLines[math.min(i, #_dfLines)]
                        if ln then
                            local vpA, visA = cam:WorldToViewportPoint(origin)
                            local vpB, visB = cam:WorldToViewportPoint(endPos)
                            if visA and visB then
                                ln.From  = Vector2.new(vpA.X, vpA.Y)
                                ln.To    = Vector2.new(vpB.X, vpB.Y)
                                ln.Color = isHit and Color3.fromRGB(255,80,80) or Color3.fromRGB(0,255,80)
                                ln.Visible = true
                            else
                                ln.Visible = false
                            end
                        end
                    end

                    -- Horizontal speed multiplier (forward only)
                    local SLOW_ZONE = RAY_LEN * 0.5
                    local targetHorizMul = 1.0
                    if closestHoriz <= SLOW_ZONE then
                        local factor = closestHoriz / SLOW_ZONE
                        targetHorizMul = math.max(0.5, factor)
                    end
                    local horizRate = targetHorizMul < _dfSpdMulSmoothed and 3 or 6
                    _dfSpdMulSmoothed = _dfSpdMulSmoothed + (targetHorizMul - _dfSpdMulSmoothed) * math.min(1, horizRate * dt)
                    _dfSpdMul = _dfSpdMulSmoothed

                    -- Vertical speed multiplier (up only, separate — doesn't touch horizontal)
                    local targetVertMul = 1.0
                    if closestUp <= SLOW_ZONE then
                        local factor = closestUp / SLOW_ZONE
                        targetVertMul = math.max(0.5, factor)
                    end
                    local vertRate = targetVertMul < _dfVSpdMulSmoothed and 3 or 6
                    _dfVSpdMulSmoothed = _dfVSpdMulSmoothed + (targetVertMul - _dfVSpdMulSmoothed) * math.min(1, vertRate * dt)
                end
            end
            -- Hide all lines when AI is disabled or flight off
            if not (_dfAI.enabled and _cf.flightActive) then
                for _, ln in ipairs(_dfLines) do ln.Visible = false end
                _dfSpdMulSmoothed  = 1.0
                _dfVSpdMulSmoothed = 1.0  -- reset both on disable
            end

            -- Run proximity+altitude safety on all active vehicles
            if _cf.flightActive then
                for _, v in pairs(_cf.activeVehicles) do
                    if v.mainPart and v.mainPart.Parent then
                        _cfUpdateSafety(v.mainPart, v.model, dt)
                    end
                end
            else
                _cfSafeUpMul = 1.0
                _cfSafeDnMul = 1.0
                _cfSafeHorizMul = 1.0
            end

            -- Horizontal speed: clamped near obstacles
            local spd  = _cf.speed * _dfSpdMul * _cfSafeHorizMul
            -- Vertical speed: split into up/down multipliers
            local vspdUp = _cf.vertSpeed * _dfVSpdMulSmoothed * _cfSafeUpMul
            local vspdDn = _cf.vertSpeed * _dfVSpdMulSmoothed * _cfSafeDnMul
            local yr   = math.rad(_cfRotYaw)
            local faceX, faceZ = math.sin(yr), -math.cos(yr)

            for _, v in pairs(_cf.activeVehicles) do
                local mp = v.mainPart
                if not mp or not mp.Parent then continue end

                local curVel = _cfVelMap[mp] or V3_ZERO

                if _cf.flightActive then
                    local tx, ty, tz = 0, 0, 0
                    if kW  then tx = tx + mx*spd;        tz = tz + mz*spd  end
                    if kS  then tx = tx - mx*spd;        tz = tz - mz*spd  end
                    if kA  then tx = tx - sx*spd*0.7;    tz = tz - sz*spd*0.7 end
                    if kD  then tx = tx + sx*spd*0.7;    tz = tz + sz*spd*0.7 end
                    if kU  then ty =  vspdUp end
                    if kDn then ty = -vspdDn end

                    local alpha = math.min(1, CF_ACCEL * dt)
                    local nx = curVel.X + (tx - curVel.X) * alpha
                    local ny = curVel.Y + (ty - curVel.Y) * alpha
                    local nz = curVel.Z + (tz - curVel.Z) * alpha
                    local newVel = Vector3.new(nx, ny, nz)
                    _cfVelMap[mp] = newVel

                    local pos = mp.CFrame.Position

                    local newPos = Vector3.new(pos.X + nx*dt, pos.Y + ny*dt, pos.Z + nz*dt)


                    -- PivotTo with full rotation CFrame so wheels/lights rotate with the model
                    local targetCF = CFrame.new(newPos) * CFrame.Angles(0, yr, 0)
                    v.model:PivotTo(targetCF)

                    mp.AssemblyLinearVelocity  = V3_ZERO
                    mp.AssemblyAngularVelocity = V3_ZERO
                else
                    -- Only unanchor once on the frame flight turns off, not every frame
                    if _cfWasActive then
                        _anchorVehicle(v, false)
                    end
                    if curVel ~= V3_ZERO then
                        local alpha = math.min(1, CF_DECEL * dt)
                        local nx = curVel.X * (1 - alpha)
                        local ny = curVel.Y * (1 - alpha)
                        local nz = curVel.Z * (1 - alpha)
                        local mag = nx*nx + ny*ny + nz*nz
                        _cfVelMap[mp] = mag > 0.01 and Vector3.new(nx, ny, nz) or nil
                    end
                    mp.AssemblyLinearVelocity  = V3_ZERO
                    mp.AssemblyAngularVelocity = V3_ZERO
                end

                -- Noclip: only runs every 30 frames, only iterates GetChildren not GetDescendants
                if doNC then
                    for _, p in pairs(v.model:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end
            end
            -- Track transition for next frame
            _cfWasActive = _cf.flightActive
        end)

        -- ── 360 Free Camera Rotation ──
        -- Mobile: uses Touch delta. PC: uses MouseMovement delta.
        -- BindToRenderStep at Camera priority+1 guarantees we run AFTER Trident's camera script.
        local _freeRot = {
            enabled = false,
            yaw     = 0,
            pitch   = 0,
            dist    = 8,
        }
        local _freeRotOrigType = nil
        local _freeRotStepName = "ButerFreeRot360"

        local function _freeRotGetSubjectPos()
            -- When flying, lock the camera subject to the car so it properly orbits the vehicle
            if _cf.flightActive then
                for _, v in pairs(_cf.activeVehicles) do
                    if v.mainPart and v.mainPart.Parent then
                        return v.mainPart.CFrame.Position + Vector3.new(0, 2, 0)
                    end
                end
            end
            -- Fallback: Trident custom character, then normal character
            local ign = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
            local tc  = ign and ign:FindFirstChild("LocalCharacter")
            if tc then
                local mid = tc:FindFirstChild("Middle") or tc:FindFirstChild("Top") or tc.PrimaryPart
                if mid then return mid.Position + Vector3.new(0, 1.5, 0) end
            end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then return hrp.Position + Vector3.new(0, 1.5, 0) end
            end
            return Camera.CFrame.Position
        end

        local function _freeRotEnable(state)
            _freeRot.enabled = state
            if state then
                local look = Camera.CFrame.LookVector
                _freeRot.yaw   = math.atan2(-look.X, -look.Z)
                _freeRot.pitch = math.asin(math.clamp(look.Y, -1, 1))
                _freeRotOrigType  = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable
                -- Bind AFTER camera priority so we always overwrite Trident's camera last
                RunService:BindToRenderStep(_freeRotStepName, Enum.RenderPriority.Camera.Value + 1, function()
                    if not _freeRot.enabled then return end
                    pcall(function()
                        Camera.CameraType = Enum.CameraType.Scriptable
                        local subjectPos = _freeRotGetSubjectPos()
                        local rotCF  = CFrame.Angles(0, _freeRot.yaw, 0) * CFrame.Angles(_freeRot.pitch, 0, 0)
                        local offset = rotCF * Vector3.new(0, 0, _freeRot.dist)
                        Camera.CFrame = CFrame.new(subjectPos + offset, subjectPos)
                        -- Sync car/body rotation to camera yaw so arms+body face where camera looks
                        _cfRotYaw = (-math.deg(_freeRot.yaw)) % 360
                    end)
                end)
            else
                pcall(function() RunService:UnbindFromRenderStep(_freeRotStepName) end)
                Camera.CameraType = _freeRotOrigType or Enum.CameraType.Custom
                _freeRotOrigType  = nil
            end
        end

        -- Z key toggles (PC)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.Z then
                _freeRotEnable(not _freeRot.enabled)
            end
        end)

        -- Input delta handler — works for BOTH mouse (MouseMovement) and mobile (Touch)
        local _frTouchId = nil  -- track which touch finger is rotating
        UserInputService.InputChanged:Connect(function(inp)
            if not _freeRot.enabled then return end
            local sens = 0.004
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                _freeRot.yaw   = _freeRot.yaw   - inp.Delta.X * sens
                _freeRot.pitch = math.clamp(_freeRot.pitch - inp.Delta.Y * sens, math.rad(-89), math.rad(89))
            elseif inp.UserInputType == Enum.UserInputType.Touch then
                -- On mobile, only track a single finger (avoid conflict with joystick finger)
                if _frTouchId == nil or _frTouchId == inp then
                    _frTouchId = inp
                    _freeRot.yaw   = _freeRot.yaw   - inp.Delta.X * sens
                    _freeRot.pitch = math.clamp(_freeRot.pitch - inp.Delta.Y * sens, math.rad(-89), math.rad(89))
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp == _frTouchId then _frTouchId = nil end
        end)


        CFBox:AddToggle('CarFlyEnabled', {Text='ᴇɴᴀʙʟᴇ ꜰʟɪɢʜᴛ ꜱʏꜱᴛᴇᴍ', Default=false, Callback=function(v)
            _cf.enabled = v
            if not v then
                _cf.flightActive = false; _cfRotYaw = 0
                _anchorAllVehicles(false)
                _cfDetachSeat()
                for _, veh in pairs(_cf.activeVehicles) do
                    if veh.mainPart then
                        veh.mainPart.AssemblyLinearVelocity  = Vector3.zero
                        veh.mainPart.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            else
                _cf.lastScan = 0
            end
        end})
        CFBox:AddToggle('CarFreeRot', {Text='360 ʙᴏᴅʏ ʀᴏᴛᴀᴛɪᴏɴ  (ᴢ ᴋᴇʏ)', Default=false, Callback=function(v)
            _freeRotEnable(v)
        end})

        CFBox:AddToggle('CarFlyActive', {Text='ᴀᴄᴛɪᴠᴀᴛᴇ ꜰʟɪɢʜᴛ  (ʙ ᴋᴇʏ)', Default=false, Callback=function(v)
            _cf.flightActive = v
            _anchorAllVehicles(v)
            if v then _cfAttachSeat() else _cfDetachSeat() end
        end})
        CFBox:AddToggle('CarFlyNoClip', {Text='ɴᴏᴄʟɪᴘ', Default=false, Callback=function(v)
            _cf.noClip = v
        end})
        CFBox:AddToggle('CarFlyStabilize', {Text='ᴀᴜᴛᴏ-ꜱᴛᴀʙɪʟɪᴢᴇ', Default=true, Callback=function(v)
            _cf.stabilize = v
        end})

        CFBox:AddToggle('CarFlyDragAI', {Text='ᴅʀᴀɢ ꜰʟʏ ᴀɪ', Default=false, Callback=function(v)
            _dfAI.enabled = v
            if not v then
                _dfAI.spdOverride = nil
                for _, ln in ipairs(_dfLines) do ln.Visible = false end
            end
        end})

        CFBox:AddSlider('CarFlySpeed',    {Text='ꜰʟɪɢʜᴛ ꜱᴘᴇᴇᴅ',    Default=10, Min=1, Max=200, Callback=function(v) _cf.speed     = v end})
        CFBox:AddSlider('CarFlyVertSpeed',{Text='ᴠᴇʀᴛɪᴄᴀʟ ꜱᴘᴇᴇᴅ',  Default=10, Min=1, Max=200, Callback=function(v) _cf.vertSpeed = v end})
        CFBox:AddSlider('CarFlyRotSpeed', {Text='ʀᴏᴛᴀᴛɪᴏɴ ꜱᴘᴇᴇᴅ',  Default=3,  Min=1, Max=10,  Callback=function(v) _cf.rotSpeed  = v end})

        InfoBox:AddLabel('── ᴋᴇʏʙᴏᴀʀᴅ ──')
        InfoBox:AddLabel('ʙ  =  ᴛᴏɢɢʟᴇ ꜰʟɪɢʜᴛ ᴏɴ/ᴏꜰꜰ')
        InfoBox:AddLabel('ᴢ  =  360 ʙᴏᴅʏ ʀᴏᴛᴀᴛɪᴏɴ')
        InfoBox:AddLabel('ᴡ ᴀ ꜱ ᴅ  =  ᴍᴏᴠᴇ')
        InfoBox:AddLabel('ɴ  =  ɢᴏ ᴜᴘ')
        InfoBox:AddLabel('ᴠ  =  ɢᴏ ᴅᴏᴡɴ')
        InfoBox:AddLabel('Q  =  ʀᴏᴛᴀᴛᴇ ʟᴇꜰᴛ')
        InfoBox:AddLabel('ᴇ  =  ʀᴏᴛᴀᴛᴇ ʀɪɢʜᴛ')
    end -- end CarFly section

    -- ══════════════════════════════════════════════
    -- SECTION 2: BOAT FLY
    -- ══════════════════════════════════════════════
    do
        local BFBox   = Tabs.Vehicles:AddLeftGroupbox('ʙᴏᴀᴛ ꜰʟʏ')
        local BFInfo  = Tabs.Vehicles:AddRightGroupbox('ʙᴏᴀᴛ ꜰʟʏ ᴄᴏɴᴛʀᴏʟꜱ')

        local _bf = {
            enabled      = false,
            flightActive = false,
            noClip       = false,
            stabilize    = true,
            speed        = 10,
            vertSpeed    = 10,
            rotSpeed     = 3,
            activeBoats  = {},
            lastScan     = 0,
        }
        local _bfRotYaw   = 0
        local _bfHoldRotL = false
        local _bfHoldRotR = false

        local _bfAnchorCache = {}

        local function _bfAnchorBoat(b, state)
            if not b or not b.model then return end
            for _, p in pairs(b.model:GetDescendants()) do
                if p:IsA("BasePart") then
                    if state then
                        _bfAnchorCache[p] = p.Anchored
                        p.Anchored = true
                    else
                        p.Anchored = (_bfAnchorCache[p] ~= nil) and _bfAnchorCache[p] or false
                        _bfAnchorCache[p] = nil
                    end
                end
            end
        end

        local function _bfAnchorAll(state)
            for _, b in pairs(_bf.activeBoats) do _bfAnchorBoat(b, state) end
        end

        -- Seat weld (same trick as CarFly — welds player to boat so they don't fall off)
        local _bfSeatPart  = nil
        local _bfSeatWeldA = nil
        local _bfSeatWeldB = nil

        local function _bfAttachSeat()
            pcall(function()
                if _bfSeatPart and _bfSeatPart.Parent then _bfSeatPart:Destroy() end
                _bfSeatPart = nil; _bfSeatWeldA = nil; _bfSeatWeldB = nil

                local mp = nil
                for _, b in pairs(_bf.activeBoats) do
                    if b.mainPart and b.mainPart.Parent then mp = b.mainPart; break end
                end
                if not mp then return end

                local hrp = nil
                local ign = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
                local tc  = ign and ign:FindFirstChild("LocalCharacter")
                if tc then hrp = tc:FindFirstChild("Middle") or tc:FindFirstChild("HumanoidRootPart") end
                if not hrp and LocalPlayer.Character then
                    hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                end
                if not hrp then return end

                local anchor = Instance.new("Part")
                anchor.Name = "BFSeatAnchor"; anchor.Size = Vector3.new(0.1,0.1,0.1)
                anchor.Transparency = 1; anchor.CanCollide = false; anchor.Anchored = false
                anchor.CFrame = mp.CFrame; anchor.Parent = mp.Parent

                local wA = Instance.new("WeldConstraint")
                wA.Part0 = mp; wA.Part1 = anchor; wA.Parent = anchor
                local wB = Instance.new("WeldConstraint")
                wB.Part0 = anchor; wB.Part1 = hrp; wB.Parent = anchor

                _bfSeatPart = anchor; _bfSeatWeldA = wA; _bfSeatWeldB = wB
            end)
        end

        local function _bfDetachSeat()
            pcall(function()
                if _bfSeatPart and _bfSeatPart.Parent then _bfSeatPart:Destroy() end
            end)
            _bfSeatPart = nil; _bfSeatWeldA = nil; _bfSeatWeldB = nil
        end

        -- Scan: finds nearest boat (model with Hull part)
        local function _bfScan()
            if tick() - _bf.lastScan < 2 then return end
            _bf.lastScan = tick()
            _bf.activeBoats = {}

            local myPos = Camera.CFrame.Position
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("BasePart")
                    if root then myPos = root.Position end
                end
            end)

            local bestModel, bestDist, bestMp = nil, 80, nil
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Hull") then
                    local hull = obj.Hull
                    local dist = (hull.Position - myPos).Magnitude
                    if dist < bestDist then
                        bestDist  = dist
                        bestModel = obj
                        bestMp    = hull
                    end
                end
            end

            if bestModel then
                table.insert(_bf.activeBoats, { model = bestModel, mainPart = bestMp })
            end
        end

        -- Toggle flight with H key (separate from car's B key)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if not _bf.enabled then return end
            if inp.KeyCode == Enum.KeyCode.H then
                _bf.flightActive = not _bf.flightActive
                _bfAnchorAll(_bf.flightActive)
                if _bf.flightActive then _bfAttachSeat() else _bfDetachSeat() end
            end
            if inp.KeyCode == Enum.KeyCode.Q then _bfHoldRotL = true end
            if inp.KeyCode == Enum.KeyCode.E then _bfHoldRotR = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.Q then _bfHoldRotL = false end
            if inp.KeyCode == Enum.KeyCode.E then _bfHoldRotR = false end
        end)

        -- Smooth velocity state
        local _bfVelMap   = {}
        local _bfWasActive = false
        local BF_ACCEL    = 8
        local BF_DECEL    = 12
        local V3Z         = Vector3.zero

        RunService.Heartbeat:Connect(function(dt)
            if not _bf.enabled then return end
            if tick() - _bf.lastScan > 5 then _bfScan() end

            if _bfHoldRotL then _bfRotYaw = (_bfRotYaw - _bf.rotSpeed) % 360 end
            if _bfHoldRotR then _bfRotYaw = (_bfRotYaw + _bf.rotSpeed) % 360 end

            local UIS = UserInputService
            local kW = UIS:IsKeyDown(Enum.KeyCode.W)
            local kS = UIS:IsKeyDown(Enum.KeyCode.S)
            local kA = UIS:IsKeyDown(Enum.KeyCode.A)
            local kD = UIS:IsKeyDown(Enum.KeyCode.D)
            local kUp = UIS:IsKeyDown(Enum.KeyCode.N)
            local kDn = UIS:IsKeyDown(Enum.KeyCode.V)

            local cam   = workspace.CurrentCamera
            local camCF = cam.CFrame
            local fwd   = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
            if fwd.Magnitude > 0.001 then fwd = fwd.Unit end
            local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
            if right.Magnitude > 0.001 then right = right.Unit end

            local wishDir = V3Z
            if kW then wishDir = wishDir + fwd  end
            if kS then wishDir = wishDir - fwd  end
            if kD then wishDir = wishDir + right end
            if kA then wishDir = wishDir - right end
            if wishDir.Magnitude > 0.001 then wishDir = wishDir.Unit end

            local wishVert = 0
            if kUp then wishVert =  _bf.vertSpeed end
            if kDn then wishVert = -_bf.vertSpeed end

            -- Transition: deactivated this frame → stop all boats
            if _bfWasActive and not _bf.flightActive then
                for _, b in pairs(_bf.activeBoats) do
                    local mp = b.mainPart
                    if mp and mp.Parent then
                        _bfVelMap[mp] = nil
                        mp.AssemblyLinearVelocity  = V3Z
                        mp.AssemblyAngularVelocity = V3Z
                    end
                end
            end
            _bfWasActive = _bf.flightActive
            if not _bf.flightActive then return end

            local frameNC = (_bf.noClip and math.random(1,30) == 1)

            for _, b in pairs(_bf.activeBoats) do
                local mp = b.mainPart
                if not mp or not mp.Parent then continue end

                -- Target world velocity
                local targetVel = wishDir * _bf.speed + Vector3.new(0, wishVert, 0)

                -- Smooth acceleration (same as CarFly)
                local curVel = _bfVelMap[mp] or V3Z
                local alpha  = math.min(1, (wishDir.Magnitude > 0.001 and BF_ACCEL or BF_DECEL) * dt)
                local newVel = Vector3.new(
                    curVel.X + (targetVel.X - curVel.X) * alpha,
                    curVel.Y + (targetVel.Y - curVel.Y) * alpha,
                    curVel.Z + (targetVel.Z - curVel.Z) * alpha
                )
                _bfVelMap[mp] = newVel.Magnitude > 0.01 and newVel or nil

                -- Move: PivotTo with yaw rotation applied
                local yawRad = math.rad(_bfRotYaw)
                local curCF  = b.model:GetPivot()
                local newPos = curCF.Position + newVel * dt
                -- Stabilize: keep boat level (zero pitch/roll)
                local newCF
                if _bf.stabilize then
                    newCF = CFrame.new(newPos) * CFrame.Angles(0, yawRad, 0)
                else
                    newCF = CFrame.new(newPos) * (curCF - curCF.Position) * CFrame.Angles(0, 0, 0)
                    newCF = CFrame.new(newPos) * CFrame.Angles(0, yawRad, 0)
                end
                b.model:PivotTo(newCF)

                mp.AssemblyLinearVelocity  = V3Z
                mp.AssemblyAngularVelocity = V3Z

                -- Noclip: run every 30 frames
                if frameNC then
                    for _, p in pairs(b.model:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                end
            end
        end)

        -- UI Controls
        BFBox:AddToggle('BoatFlyEnabled', {Text='ᴇɴᴀʙʟᴇ ꜰʟɪɢʜᴛ ꜱʏꜱᴛᴇᴍ', Default=false, Callback=function(v)
            _bf.enabled = v
            if not v then
                _bf.flightActive = false; _bfRotYaw = 0
                _bfAnchorAll(false)
                _bfDetachSeat()
                for _, b in pairs(_bf.activeBoats) do
                    if b.mainPart then
                        b.mainPart.AssemblyLinearVelocity  = V3Z
                        b.mainPart.AssemblyAngularVelocity = V3Z
                    end
                end
            else
                _bf.lastScan = 0
            end
        end})

        BFBox:AddToggle('BoatFlyActive', {Text='ᴀᴄᴛɪᴠᴀᴛᴇ ꜰʟɪɢʜᴛ  (ʜ ᴋᴇʏ)', Default=false, Callback=function(v)
            _bf.flightActive = v
            _bfAnchorAll(v)
            if v then _bfAttachSeat() else _bfDetachSeat() end
        end})

        BFBox:AddToggle('BoatFlyNoClip',    {Text='ɴᴏᴄʟɪᴘ',          Default=false, Callback=function(v) _bf.noClip    = v end})
        BFBox:AddToggle('BoatFlyStabilize', {Text='ᴀᴜᴛᴏ-ꜱᴛᴀʙɪʟɪᴢᴇ', Default=true,  Callback=function(v) _bf.stabilize = v end})

        BFBox:AddSlider('BoatFlySpeed',     {Text='ꜰʟɪɢʜᴛ ꜱᴘᴇᴇᴅ',   Default=10, Min=1, Max=500, Callback=function(v) _bf.speed     = v end})
        BFBox:AddSlider('BoatFlyVertSpeed', {Text='ᴠᴇʀᴛɪᴄᴀʟ ꜱᴘᴇᴇᴅ', Default=10, Min=1, Max=200, Callback=function(v) _bf.vertSpeed = v end})
        BFBox:AddSlider('BoatFlyRotSpeed',  {Text='ʀᴏᴛᴀᴛɪᴏɴ ꜱᴘᴇᴇᴅ', Default=3,  Min=1, Max=10,  Callback=function(v) _bf.rotSpeed  = v end})

        BFInfo:AddLabel('── ᴋᴇʏʙᴏᴀʀᴅ ──')
        BFInfo:AddLabel('ʜ  =  ᴛᴏɢɢʟᴇ ꜰʟɪɢʜᴛ ᴏɴ/ᴏꜰꜰ')
        BFInfo:AddLabel('ᴡ ᴀ ꜱ ᴅ  =  ᴍᴏᴠᴇ')
        BFInfo:AddLabel('ɴ  =  ɢᴏ ᴜᴘ')
        BFInfo:AddLabel('ᴠ  =  ɢᴏ ᴅᴏᴡɴ')
        BFInfo:AddLabel('Q  =  ʀᴏᴛᴀᴛᴇ ʟᴇꜰᴛ')
        BFInfo:AddLabel('ᴇ  =  ʀᴏᴛᴀᴛᴇ ʀɪɢʜᴛ')
    end -- end BoatFly section

    end -- end _buildVehicles
    _buildVehicles()

    -- ================================================================
    -- MISC TAB  –  Keybind list
    -- ================================================================
    do
        local MiscBox = Tabs.Misc:AddLeftGroupbox('ᴋᴇʏʙɪɴᴅꜱ')

        -- ── keybind data ──────────────────────────────────────────
        -- Each entry: { label, uiKey (string|nil), toggle (bool state), onActivate(state) }
        local _kbEntries = {}
        local _kbGui     = nil
        local _kbVisible = false
        local _kbPos     = UDim2.fromOffset(20, 120)  -- default position

        -- helper: fire a UI toggle by reg key
        local function _setReg(key, val)
            if _uiReg and _uiReg[key] then pcall(function() _uiReg[key]:Set(val) end) end
        end

        -- register one keybind entry
        local function _kbAdd(label, callback)
            local e = { label=label, key=nil, state=false, callback=callback }
            table.insert(_kbEntries, e)
            return e
        end

        -- ore esp all (nitrate+iron+stone)

        -- insta loot (keybind fires loot action while toggle in UI still controls the button)
        local _kbLootEntry = _kbAdd("Insta Loot", function(v)
            -- fire loot remotely regardless of UI button state
            if v then
                task.spawn(function()
                    local tcp = Players.LocalPlayer:FindFirstChild("TCP")
                    if not tcp then return end
                    for i = 1, 25 do pcall(function() tcp:FireServer(12, i, true) end) end
                end)
            end
        end)
        -- insta loot is instant-fire, not a toggle, so always reset state
        _kbLootEntry.momentary = true

        -- safe zone / no build zone
        -- safe zone + no build zone — один бинд на оба
        _kbAdd("Zone ESP (Safe+NoBuild)", function(v)
            _setReg("SafeZoneCharm", v)
            _setReg("NoBuildZoneCharm", v)
        end)

        -- items esp: toggle master + all sub-types
        _kbAdd("Silent Aim",     function(v) _setReg("SilentAimEnabled",   v) end)
        _kbAdd("Jump Shoot",     function(v) _setReg("JumpShootEnabled",   v) end)
        _kbAdd("Head Expander",  function(v) _setReg("HeadExpanderEnabled",v) end)
        _kbAdd("Speedhack",      function(v) _setReg("SpeedhackEnable",    v) end)
        _kbAdd("Force Sprint",   function(v) _setReg("SpeedForceSprint",   v) end)
        _kbAdd("Player Manip",   function(v) _setReg("PMEnable_dm",        v) end)

        -- VISUALS
        _kbAdd("FreeCam",        function(v) _setReg("FreeCamEnabled",     v) end)
        _kbAdd("X-Ray",          function(v) _setReg("XrayEnabled",        v) end)
        _kbAdd("Backpack ESP",   function(v) _setReg("BagEspEnabled",      v) end)
        _kbAdd("Activate Flight",function(v) _setReg("CarFlyEnabled",      v) end)

        -- ── build / rebuild the floating keybind panel ────────────
        local _panel = nil

        local function _buildPanel()
            if _kbGui then pcall(function() _kbGui:Destroy() end); _kbGui = nil; _panel = nil end
            if not _kbVisible then return end

            _kbGui = Instance.new("ScreenGui")
            _kbGui.Name = "TH_KbList"
            _kbGui.ResetOnSpawn = false
            _kbGui.IgnoreGuiInset = true
            _kbGui.DisplayOrder = 600
            pcall(function() _kbGui.Parent = CoreGui end)
            if not _kbGui.Parent then _kbGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

            local PANEL_W  = 162
            local ROW_H    = 16   -- row height
            local ROW_GAP  = 2    -- gap between rows
            local TITLE_H  = 18
            local SEP_H    = 2    -- purple separator
            local PAD_BOT  = 4
            local totalH   = TITLE_H + SEP_H + #_kbEntries * (ROW_H + ROW_GAP) - ROW_GAP + PAD_BOT

            local panel = Instance.new("Frame", _kbGui)
            panel.Size             = UDim2.fromOffset(PANEL_W, totalH)
            panel.Position         = _kbPos
            panel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
            panel.BorderSizePixel  = 0
            panel.ClipsDescendants = false
            _panel = panel

            -- thin outer border
            local pStroke = Instance.new("UIStroke", panel)
            pStroke.Color = Color3.fromRGB(60, 40, 50); pStroke.Thickness = 1

            -- title bar (drag handle)
            local titleBar = Instance.new("Frame", panel)
            titleBar.Size             = UDim2.new(1, 0, 0, TITLE_H)
            titleBar.BackgroundColor3 = Color3.fromRGB(14, 10, 12)
            titleBar.BorderSizePixel  = 0

            local titleLbl = Instance.new("TextLabel", titleBar)
            titleLbl.Size                   = UDim2.new(1, -8, 1, 0)
            titleLbl.Position               = UDim2.fromOffset(6, 0)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text                   = "ᴋᴇʏʙɪɴᴅꜱ:"
            titleLbl.TextColor3             = Color3.fromRGB(255, 200, 215)
            titleLbl.TextSize               = 9; titleLbl.FontFace = font
            titleLbl.TextXAlignment         = Enum.TextXAlignment.Left

            -- purple separator line under title
            local sep = Instance.new("Frame", panel)
            sep.Size             = UDim2.new(1, 0, 0, SEP_H)
            sep.Position         = UDim2.fromOffset(0, TITLE_H)
            sep.BackgroundColor3 = Color3.fromRGB(255, 182, 210)
            sep.BorderSizePixel  = 0

            -- drag (title bar)
            local _drag, _dragStart, _panStart = false, nil, nil
            titleBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    _drag = true; _dragStart = inp.Position; _panStart = panel.Position
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then _drag = false end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not _drag then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - _dragStart
                    local np = UDim2.fromOffset(_panStart.X.Offset + d.X, _panStart.Y.Offset + d.Y)
                    panel.Position = np; _kbPos = np
                end
            end)

            -- rows: label LEFT, badge RIGHT, with gap
            for i, entry in ipairs(_kbEntries) do
                local yOff = TITLE_H + SEP_H + (i-1) * (ROW_H + ROW_GAP)

                local row = Instance.new("Frame", panel)
                row.Size             = UDim2.new(1, 0, 0, ROW_H)
                row.Position         = UDim2.fromOffset(0, yOff)
                row.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(14, 12, 14) or Color3.fromRGB(10, 10, 12)
                row.BorderSizePixel  = 0

                -- label (left)
                local lbl = Instance.new("TextLabel", row)
                lbl.Size                   = UDim2.new(1, -46, 1, 0)
                lbl.Position               = UDim2.fromOffset(6, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text                   = entry.label
                lbl.TextColor3             = Color3.fromRGB(210, 200, 205)
                lbl.TextSize               = 8; lbl.FontFace = font
                lbl.TextXAlignment         = Enum.TextXAlignment.Left
                lbl.TextTruncate           = Enum.TextTruncate.AtEnd

                -- badge (right), no bg, no stroke
                local badge = Instance.new("TextButton", row)
                badge.Size                   = UDim2.fromOffset(44, ROW_H)
                badge.Position               = UDim2.new(1, -44, 0, 0)
                badge.BackgroundTransparency = 1
                badge.BorderSizePixel        = 0
                badge.Text                   = entry.key and ("["..entry.key.Name.."]") or "[ ]"
                badge.TextColor3             = entry.key and Color3.fromRGB(255, 182, 210) or Color3.fromRGB(90, 70, 75)
                badge.TextSize               = 8; badge.FontFace = font
                badge.AutoButtonColor        = false

                local _listening = false
                local _listenConn = nil

                local function _refreshBadge()
                    badge.Text       = entry.key and ("["..entry.key.Name.."]") or "[ ]"
                    badge.TextColor3 = entry.key and Color3.fromRGB(255,182,210) or Color3.fromRGB(90,70,75)
                end

                badge.MouseButton1Click:Connect(function()
                    if _listening then
                        entry.key = nil
                        if _listenConn then _listenConn:Disconnect(); _listenConn = nil end
                        _listening = false
                        _refreshBadge()
                        return
                    end
                    _listening = true
                    badge.Text       = "[...]"
                    badge.TextColor3 = Color3.fromRGB(215, 180, 55)

                    _listenConn = UserInputService.InputBegan:Connect(function(inp, gp)
                        if gp then return end
                        if inp.KeyCode == Enum.KeyCode.Unknown then return end
                        entry.key = inp.KeyCode
                        if _listenConn then _listenConn:Disconnect(); _listenConn = nil end
                        _listening = false
                        _refreshBadge()
                    end)
                end)
            end
        end

        -- ── global InputBegan handler for firing keybinds ─────────
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            for _, entry in ipairs(_kbEntries) do
                if entry.key and inp.KeyCode == entry.key then
                    if entry.momentary then
                        pcall(function() entry.callback(true) end)
                    else
                        entry.state = not entry.state
                        pcall(function() entry.callback(entry.state) end)
                        _notify("Keybind", entry.label..": "..(entry.state and "ON" or "OFF"), 1.5)
                    end
                end
            end
        end)

        -- ── toggle in UI ──────────────────────────────────────────
        MiscBox:AddToggle('KbListVisible', {Text='ꜱʜᴏᴡ ᴋᴇʏʙɪɴᴅ ʟɪꜱᴛ', Default=false,
            Callback=function(v)
                _kbVisible = v
                _buildPanel()
            end})
        -- Free Cam keybind (registered here so _kbAdd is in scope)
        _kbAdd("Free Cam", function(state)
            if _uiReg and _uiReg["FreeCamEnabled"] then
                pcall(function() _uiReg["FreeCamEnabled"]:Set(state) end)
            end
        end)
    end

        -- ── Free Cam ─────────────────────────────────────────────────────────
        do
            local FCBox = Tabs.Misc:AddRightGroupbox('ꜰʀᴇᴇ ᴄᴀᴍ')

            local _fc = {
                enabled = false,
                speed   = 10,
                part    = "middle",
            }
            local _fcOffset = Vector3.zero
            local _fcConn   = nil

            local function _fcGetParts()
                local ok, mid, bot, top = pcall(function()
                    local lc = workspace.Const.Ignore.LocalCharacter
                    return lc.Middle, lc.Bottom, lc.Top
                end)
                if ok and mid then return mid, bot, top end
                return nil, nil, nil
            end

            local function _fcStop()
                if _fcConn then _fcConn:Disconnect(); _fcConn = nil end
                _fcOffset = Vector3.zero
                pcall(function()
                    local m, b, t = _fcGetParts()
                    if m then m.CanCollide = true end
                    if b then b.CanCollide = true end
                    if t then t.CanCollide = true end
                end)
            end

            local function _fcStart()
                _fcStop()
                local middle, bottom, top = _fcGetParts()
                if not middle then return end

                middle.CanCollide = false
                bottom.CanCollide = false
                top.CanCollide    = false

                local mdpos = middle.CFrame
                local bmpos = bottom.CFrame
                local tppos = top.CFrame
                _fcOffset   = Vector3.zero

                _fcConn = RunService.Heartbeat:Connect(function(delta)
                    if not _fc.enabled then return end
                    local m = middle
                    if not m or not m.Parent then return end

                    if _fc.part == "middle" then m.CFrame      = mdpos end
                    if _fc.part == "bottom" then bottom.CFrame = bmpos end
                    if _fc.part == "top"    then top.CFrame    = tppos end

                    local camLook = workspace.CurrentCamera.CFrame.LookVector
                    local dir     = Vector3.zero
                    local UIS     = UserInputService
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camLook end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camLook end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(-camLook.Z, 0, camLook.X) end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(camLook.Z, 0, -camLook.X) end
                    if dir ~= Vector3.zero then dir = dir.Unit end

                    _fcOffset = _fcOffset + (dir * delta * _fc.speed)

                    if _fc.part == "middle" then m.CFrame      = mdpos + _fcOffset end
                    if _fc.part == "bottom" then bottom.CFrame = bmpos + _fcOffset end
                    if _fc.part == "top"    then top.CFrame    = tppos + _fcOffset end

                    m.AssemblyLinearVelocity      = Vector3.zero
                    bottom.AssemblyLinearVelocity = Vector3.zero
                    top.AssemblyLinearVelocity    = Vector3.zero
                end)
            end

            FCBox:AddToggle('FreeCamEnabled', {
                Text    = 'ꜰʀᴇᴇ ᴄᴀᴍ',
                Default = false,
                Callback = function(v)
                    _fc.enabled = v
                    if v then _fcStart() else _fcStop() end
                end,
            })
            FCBox:AddSlider('FreeCamSpeed', {
                Text     = 'ꜱᴘᴇᴇᴅ',
                Default  = 10,
                Min      = 1,
                Max      = 150,
                Rounding = 0,
                Suffix   = ' sps',
                Compact  = false,
                Callback = function(v) _fc.speed = v end,
            })
            FCBox:AddDropdown('FreeCamPart', {
                Text     = 'ᴘᴀʀᴛ',
                Default  = 'middle',
                Values   = { 'middle', 'bottom', 'top' },
                Callback = function(v) _fc.part = v end,
            })
            FCBox:AddLabel('ᴡ/ꜱ/ᴀ/ᴅ  =  ᴍᴏᴠᴇ')
            FCBox:AddLabel('ᴄᴀᴍᴇʀᴀ ᴄᴏɴᴛʀᴏʟꜱ ʟᴏᴏᴋ ᴅɪʀᴇᴄᴛɪᴏɴ')


        end
        -- ─────────────────────────────────────────────────────────────────────

    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.KeyCode==Enum.KeyCode.RightShift then Library.IsVisible=not Library.IsVisible; main.Visible=Library.IsVisible; mainOuter.Visible=Library.IsVisible end
        if inp.KeyCode==Enum.KeyCode.Delete  then pcall(function() gui:Destroy() end) end
    end)

    -- ══════════════════════════════════════════════════════════════════
    -- UI SETTINGS TAB  –  сохранение / загрузка конфигов
    -- ══════════════════════════════════════════════════════════════════
    do
        local _cfgTab   = AddPage("ᴜɪ ꜱᴇᴛᴛɪɴɢꜱ")
        local _cfgLeft  = _cfgTab:AddLeftGroupbox("ᴄᴏɴꜰɪɢꜱ")
        local _cfgRight = _cfgTab:AddRightGroupbox("ꜱᴛᴀᴛᴜꜱ")

        -- ── имя файла для авто-конфига ─────────────────────────────────
        local CONFIG_FOLDER    = "BuferConfigs"
        local AUTOLOAD_FILE    = CONFIG_FOLDER .. "/autoload.txt"   -- хранит имя последнего конфига
        local DEFAULT_CFG_NAME = "default"

        -- создать папку если нет
        pcall(function()
            if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        end)

        -- ── утилиты: Color3 ↔ строка ──────────────────────────────────
        local function colorToStr(c)
            return string.format("%d,%d,%d",
                math.floor(c.R*255+.5),
                math.floor(c.G*255+.5),
                math.floor(c.B*255+.5))
        end
        local function strToColor(s)
            local r,g,b = s:match("(%d+),(%d+),(%d+)")
            if r then return Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)) end
            return nil
        end

        -- ── сериализация текущего состояния всех виджетов ─────────────
        local function _serializeConfig()
            local t = {}
            for key, obj in pairs(_uiReg) do
                if obj and obj.Get then
                    local ok, val = pcall(function() return obj:Get() end)
                    if ok and val ~= nil then
                        local vtype = type(val)
                        if vtype == "boolean" then
                            t[key] = "bool:" .. tostring(val)
                        elseif vtype == "number" then
                            t[key] = "num:" .. tostring(val)
                        elseif vtype == "string" then
                            t[key] = "str:" .. val
                        elseif typeof(val) == "Color3" then
                            t[key] = "col:" .. colorToStr(val)
                        end
                    end
                end
            end
            -- сборка строки key=value\n
            local lines = {}
            for k, v in pairs(t) do
                table.insert(lines, k .. "=" .. v)
            end
            return table.concat(lines, "\n")
        end

        -- ── десериализация и применение ───────────────────────────────
        local function _applyConfig(data)
            for line in (data .. "\n"):gmatch("([^\n]+)\n") do
                local key, raw = line:match("^(.-)=(.+)$")
                if key and raw and _uiReg[key] then
                    local obj = _uiReg[key]
                    if obj and obj.Set then
                        pcall(function()
                            local prefix, val = raw:match("^(%a+):(.+)$")
                            if prefix == "bool" then
                                obj:Set(val == "true")
                            elseif prefix == "num" then
                                obj:Set(tonumber(val))
                            elseif prefix == "str" then
                                obj:Set(val)
                            elseif prefix == "col" then
                                local c = strToColor(val)
                                if c then obj:Set(c) end
                            end
                        end)
                    end
                end
            end
        end

        -- ── список файлов конфигов ─────────────────────────────────────
        local function _listConfigs()
            local list = {}
            pcall(function()
                for _, name in ipairs(listfiles(CONFIG_FOLDER)) do
                    -- listfiles возвращает полный путь, берём только имя файла без .cfg
                    local short = name:match("[/\\]?([^/\\]+)$") or name
                    if short:sub(-4) == ".cfg" then
                        table.insert(list, short:sub(1,-5))
                    end
                end
            end)
            if #list == 0 then table.insert(list, DEFAULT_CFG_NAME) end
            return list
        end

        -- ── статус-лейбл ──────────────────────────────────────────────
        local _statusLbl  = _cfgRight:AddLabel("ꜱᴛᴀᴛᴜꜱ: ɪᴅʟᴇ")
        local _autoLbl    = _cfgRight:AddLabel("ᴀᴜᴛᴏ: ɴᴏɴᴇ")

        local function _setStatus(msg, isOk)
            if _statusLbl and _statusLbl.label then
                _statusLbl.label.Text = "ꜱᴛᴀᴛᴜꜱ: " .. msg
                _statusLbl.label.TextColor3 = isOk
                    and Color3.fromRGB(80,220,120)
                    or  Color3.fromRGB(255,100,100)
            end
        end
        local function _setAutoLbl(name)
            if _autoLbl and _autoLbl.label then
                if name and name ~= "" then
                    _autoLbl.label.Text = "ᴀᴜᴛᴏ: " .. name
                    _autoLbl.label.TextColor3 = Color3.fromRGB(255,182,210)
                else
                    _autoLbl.label.Text = "ᴀᴜᴛᴏ: ᴏꜰꜰ"
                    _autoLbl.label.TextColor3 = Color3.fromRGB(130,130,130)
                end
            end
        end

        -- ── текущее выбранное имя конфига ─────────────────────────────
        local _cfgName = DEFAULT_CFG_NAME

        -- dropdown со списком конфигов
        local _cfgList   = _listConfigs()
        local _cfgDrop   = _cfgLeft:AddDropdown("ConfigSelect", {
            Text    = "ᴄᴏɴꜰɪɢ",
            Values  = _cfgList,
            Default = _cfgList[1],
            Callback = function(v) _cfgName = v end,
        })
        _cfgName = _cfgList[1]

        -- textbox для имени нового конфига
        local _cfgNewName = DEFAULT_CFG_NAME
        _cfgLeft:AddTextbox("ConfigNewName", {
            Text    = "ɴᴏᴡ ɴᴀᴍᴇ",
            Default = DEFAULT_CFG_NAME,
            Callback = function(v) _cfgNewName = (v ~= "") and v or DEFAULT_CFG_NAME end,
        })

        -- ── обновить dropdown ─────────────────────────────────────────
        local function _refreshDrop()
            local newList = _listConfigs()
            -- пересобрать dropdown: самый простой способ — Set на первый элемент
            -- (dropdown не поддерживает rebuild, но Set обновит отображение)
            if _cfgDrop and _cfgDrop.Set then
                pcall(function() _cfgDrop:Set(newList[1]) end)
                _cfgName = newList[1]
            end
        end

        -- ── СОХРАНИТЬ ─────────────────────────────────────────────────
        _cfgLeft:AddButton({
            Text = "💾  ꜱᴀᴠᴇ  ᴄᴏɴꜰɪɢ",
            Func = function()
                local name = (_cfgNewName ~= "") and _cfgNewName or _cfgName
                local path = CONFIG_FOLDER .. "/" .. name .. ".cfg"
                local ok, err = pcall(function()
                    writefile(path, _serializeConfig())
                end)
                if ok then
                    _setStatus("ꜱᴀᴠᴇᴅ: " .. name, true)
                    _refreshDrop()
                else
                    _setStatus("ꜱᴀᴠᴇ ꜰᴀɪʟᴇᴅ", false)
                end
            end,
        })

        -- ── ЗАГРУЗИТЬ ─────────────────────────────────────────────────
        _cfgLeft:AddButton({
            Text = "📂  ʟᴏᴀᴅ  ᴄᴏɴꜰɪɢ",
            Func = function()
                local path = CONFIG_FOLDER .. "/" .. _cfgName .. ".cfg"
                local ok, data = pcall(readfile, path)
                if ok and data then
                    _applyConfig(data)
                    _setStatus("ʟᴏᴀᴅᴇᴅ: " .. _cfgName, true)
                else
                    _setStatus("ꜰɪʟᴇ ɴᴏᴛ ꜰᴏᴜɴᴅ", false)
                end
            end,
        })

        -- ── УДАЛИТЬ ───────────────────────────────────────────────────
        _cfgLeft:AddButton({
            Text = "🗑  ᴅᴇʟᴇᴛᴇ  ᴄᴏɴꜰɪɢ",
            Func = function()
                local path = CONFIG_FOLDER .. "/" .. _cfgName .. ".cfg"
                local ok = pcall(delfile, path)
                if ok then
                    _setStatus("ᴅᴇʟᴇᴛᴇᴅ: " .. _cfgName, true)
                    _refreshDrop()
                else
                    _setStatus("ᴅᴇʟᴇᴛᴇ ꜰᴀɪʟᴇᴅ", false)
                end
            end,
        })

        _cfgLeft:AddDivider()

        -- ── УСТАНОВИТЬ КАК АВТО-ЗАГРУЗКУ ──────────────────────────────
        _cfgLeft:AddButton({
            Text = "⚡  ꜱᴇᴛ  ᴀᴜᴛᴏʟᴏᴀᴅ",
            Func = function()
                local ok = pcall(function()
                    writefile(AUTOLOAD_FILE, _cfgName)
                end)
                if ok then
                    _setAutoLbl(_cfgName)
                    _setStatus("ᴀᴜᴛᴏʟᴏᴀᴅ: " .. _cfgName, true)
                else
                    _setStatus("ᴄᴀɴɴᴏᴛ ꜱᴇᴛ ᴀᴜᴛᴏʟᴏᴀᴅ", false)
                end
            end,
        })

        -- ── СНЯТЬ АВТО-ЗАГРУЗКУ ────────────────────────────────────────
        _cfgLeft:AddButton({
            Text = "✖  ᴄʟᴇᴀʀ  ᴀᴜᴛᴏʟᴏᴀᴅ",
            Func = function()
                pcall(delfile, AUTOLOAD_FILE)
                _setAutoLbl(nil)
                _setStatus("ᴀᴜᴛᴏʟᴏᴀᴅ ᴄʟᴇᴀʀᴇᴅ", true)
            end,
        })

        -- ── АВТО-ПРИМЕНЕНИЕ ПРИ ЗАПУСКЕ ───────────────────────────────
        -- Читаем autoload.txt → загружаем конфиг через task.defer
        -- (task.defer даёт движку инициализировать все виджеты до apply)
        task.defer(function()
            local ok, autoName = pcall(readfile, AUTOLOAD_FILE)
            if ok and autoName and autoName:match("%S") then
                autoName = autoName:gsub("%s","") -- убрать пробелы/переносы
                local cfgPath = CONFIG_FOLDER .. "/" .. autoName .. ".cfg"
                local ok2, data = pcall(readfile, cfgPath)
                if ok2 and data then
                    -- небольшая задержка чтобы все callbacks успели зарегистрироваться
                    task.wait(0.5)
                    _applyConfig(data)
                    _setAutoLbl(autoName)
                    _setStatus("ᴀᴜᴛᴏ ʟᴏᴀᴅᴇᴅ: " .. autoName, true)
                    _notify("Buter.cel | Config", "ᴀᴜᴛᴏ-ʟᴏᴀᴅᴇᴅ: " .. autoName, 3)
                else
                    _setAutoLbl(autoName)
                    _setStatus("ᴀᴜᴛᴏ ꜰɪʟᴇ ᴍɪꜱꜱɪɴɢ", false)
                end
            else
                _setAutoLbl(nil)
                _setStatus("ɴᴏ ᴀᴜᴛᴏʟᴏᴀᴅ ꜱᴇᴛ", true)
            end
        end)
    end
    -- ══════════════════════════════════════════════════════════════════

    -- ================================================================
    --  SKIN CHANGER TAB
    -- ================================================================
    do
        local RS = game:GetService("ReplicatedStorage")

        -- All generic skins with rarity
        local SKIN_LIST = {
            -- Common
            {name="Woodland",   rarity="Common"},
            {name="Slate",      rarity="Common"},
            {name="Scale",      rarity="Common"},
            {name="Melon",      rarity="Common"},
            {name="GunCamo",    rarity="Common"},
            {name="Imperial",   rarity="Common"},
            {name="Floral",     rarity="Common"},
            {name="ForestCamo", rarity="Common"},
            -- Rare
            {name="Asylum",     rarity="Rare"},
            {name="Bones",      rarity="Rare"},
            {name="BlackAndWhite", rarity="Rare"},
            {name="Corruption", rarity="Rare"},
            {name="Danger",     rarity="Rare"},
            {name="Webbed",     rarity="Rare"},
            {name="GreenWebbed",rarity="Rare"},
            {name="Clipped",    rarity="Rare"},
            -- Exotic
            {name="Eyes",       rarity="Exotic"},
            {name="Frost",      rarity="Exotic"},
            {name="Frozen",     rarity="Exotic"},
            {name="Galaxy",     rarity="Exotic"},
            {name="Golden",     rarity="Exotic"},
            {name="Jack",       rarity="Exotic"},
            {name="Magma",      rarity="Exotic"},
            {name="Matrix",     rarity="Exotic"},
            {name="Obsidian",   rarity="Exotic"},
            {name="RadioActive",rarity="Exotic"},
            {name="Rainbow",    rarity="Exotic"},
            {name="Trippy",     rarity="Exotic"},
            {name="Universe",   rarity="Exotic"},
            {name="Void",       rarity="Exotic"},
            {name="Water",      rarity="Exotic"},
            {name="Groovy",     rarity="Exotic"},
            {name="FrostCamo",  rarity="Exotic"},
            {name="Studs",      rarity="Exotic"},
            {name="PinkCamo",   rarity="Exotic"},
            {name="Troll",      rarity="Exotic"},
            {name="CyberNet",   rarity="Exotic"},
            {name="Bree",       rarity="Exotic"},
            -- Limited
            {name="SpongeBob",    rarity="Limited"},
            {name="AmongUs",      rarity="Limited"},
            {name="Checkerboard", rarity="Limited"},
            {name="Banana",       rarity="Limited"},
            {name="Steff",        rarity="Limited"},
            {name="Grass",        rarity="Limited"},
        }

        local RARITY_COLORS = {
            Common  = Color3.fromRGB(180, 180, 180),
            Rare    = Color3.fromRGB(80,  140, 255),
            Exotic  = Color3.fromRGB(255, 160, 40),
            Limited = Color3.fromRGB(255, 80,  80),
        }

        -- Cache loaded skin modules
        local _skinCache = {}
        local function _getSkinModule(name)
            if _skinCache[name] then return _skinCache[name] end
            local ok, m = pcall(function()
                return RS.Shared.ItemSkins.GenericSkinInfo:FindFirstChild(name)
            end)
            if not ok or not m then return nil end
            local ok2, data = pcall(require, m)
            if ok2 and type(data) == "table" then
                _skinCache[name] = data
                return data
            end
            return nil
        end

        -- Find local player HandModel (FPSArms)
        local function _getLocalHandModel()
            local fps = workspace:FindFirstChild("Const")
                and workspace.Const:FindFirstChild("Ignore")
                and workspace.Const.Ignore:FindFirstChild("FPSArms")
            if fps then
                local hm = fps:FindFirstChild("HandModel")
                if hm then return hm end
                for _, v in ipairs(fps:GetChildren()) do
                    if v:IsA("Model") then return v end
                end
                for _, v in ipairs(fps:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChildWhichIsA("MeshPart") then
                        return v
                    end
                end
            end
            return nil
        end

        -- Apply skin to HandModel using GetApplyFunction
        local _currentSkin = "None"
        local _autoReapply = false
        local _autoConn = nil

        local function _applySkin(skinName)
            if skinName == "None" then
                _currentSkin = "None"
                return
            end
            local data = _getSkinModule(skinName)
            if not data then return end
            local fn = data.GetApplyFunction
            if type(fn) ~= "function" then return end
            local hm = _getLocalHandModel()
            if not hm then return end

            local weaponName = _equippedItem and _equippedItem.name
            local skinners = RS.Shared.ItemSkins.Skinners
            local applied = false

            local skinnerScript = weaponName and skinners:FindFirstChild(weaponName)
            if not skinnerScript then
                skinnerScript = skinners:GetChildren()[1]
            end

            if skinnerScript then
                local okS, skinnerData = pcall(require, skinnerScript)
                if okS and type(skinnerData) == "table" then
                    local _typeToClass = {
                        Color3    = "Color3Value",
                        number    = "NumberValue",
                        string    = "StringValue",
                        boolean   = "BoolValue",
                        BrickColor= "BrickColorValue",
                        Vector3   = "Vector3Value",
                    }
                    local function _seedValues(source)
                        for attrKey, attrVal in pairs(source) do
                            local cls = _typeToClass[typeof(attrVal)]
                            if cls then
                                local existing = hm:FindFirstChild(attrKey)
                                if existing then pcall(function() existing:Destroy() end) end
                                pcall(function()
                                    local inst = Instance.new(cls)
                                    inst.Name  = attrKey
                                    inst.Value = attrVal
                                    inst.Parent = hm
                                end)
                            end
                        end
                    end
                    _seedValues(skinnerData)
                    _seedValues(data)

                    if not applied then
                        local okC, applierC = pcall(fn, skinnerData)
                        if okC and type(applierC) == "function" then
                            local okC2 = pcall(applierC, hm)
                            if okC2 then applied = true end
                        end
                    end
                    if not applied then
                        local okD, errD = pcall(fn, hm, skinnerData)
                        if okD and type(errD) ~= "function" then
                            applied = true
                        elseif okD and type(errD) == "function" then
                            local okD2 = pcall(errD)
                            if okD2 then applied = true end
                        end
                    end
                    if not applied and type(data.SkinAll) == "function" then
                        local okE = pcall(data.SkinAll, data, hm, skinnerData)
                        if okE then applied = true
                        else
                            local okE2 = pcall(data.SkinAll, hm, skinnerData)
                            if okE2 then applied = true end
                        end
                    end
                    if not applied and type(data.ColorAll) == "function" then
                        local okF = pcall(data.ColorAll, data, hm, skinnerData)
                        if okF then applied = true
                        else
                            local okF2 = pcall(data.ColorAll, hm, skinnerData)
                            if okF2 then applied = true end
                        end
                    end
                    if not applied then
                        local okA, applier = pcall(fn, hm)
                        if okA and type(applier) == "function" then
                            local okA2 = pcall(applier, skinnerData)
                            if okA2 then applied = true end
                        end
                    end
                    if not applied then
                        local okB, errB = pcall(fn, skinnerData, hm)
                        if okB and type(errB) ~= "function" then applied = true end
                    end
                end
            end

            if applied then _currentSkin = skinName end
        end

        -- Auto-reapply on weapon switch
        local function _startAutoReapply()
            if _autoConn then _autoConn:Disconnect(); _autoConn = nil end
            task.spawn(function()
                local lastHM = nil
                local hmWasNil = false
                while _autoReapply do
                    task.wait(0.3)
                    if _currentSkin == "None" then continue end
                    local hm = _getLocalHandModel()
                    if not hm then
                        if lastHM ~= nil then hmWasNil = true end
                        lastHM = nil
                    elseif hm ~= lastHM or hmWasNil then
                        lastHM = hm
                        hmWasNil = false
                        task.wait(0.15)
                        _applySkin(_currentSkin)
                    end
                end
            end)
        end

        -- Build the UI
        local skLeft  = Tabs.Skins:AddLeftGroupbox("ꜱᴋɪɴ ᴄʜᴀɴɢᴇʀ")
        local skRight = Tabs.Skins:AddRightGroupbox("ꜱᴋɪɴ ʟɪꜱᴛ")

        skLeft:AddToggle("SkinEnabled", {
            Text    = "ᴇɴᴀʙʟᴇ ꜱᴋɪɴ ᴄʜᴀɴɢᴇʀ",
            Default = false,
            Callback = function(v)
                _autoReapply = v
                if v then
                    _startAutoReapply()
                    if _currentSkin ~= "None" then _applySkin(_currentSkin) end
                end
            end,
        })

        local skinDropValues = {"None"}
        for _, s in ipairs(SKIN_LIST) do
            table.insert(skinDropValues, s.name)
        end

        skLeft:AddDropdown("SkinSelect", {
            Text    = "ꜱᴇʟᴇᴄᴛ ꜱᴋɪɴ",
            Values  = skinDropValues,
            Default = "None",
            Callback = function(v)
                _currentSkin = v
                if Flags["SkinEnabled"] and v ~= "None" then
                    _applySkin(v)
                end
            end,
        })

        skLeft:AddButton({
            Text = "  ᴀᴘᴘʟʏ ɴᴏᴡ  ",
            Func = function()
                if _currentSkin ~= "None" then _applySkin(_currentSkin) end
            end,
        })

        skLeft:AddDivider()
        skLeft:AddLabel("ᴀʟʟ ꜱᴋɪɴꜱ ᴡᴏʀᴋ ᴏɴ ᴀʟʟ ᴡᴇᴀᴘᴏɴꜱ")

        -- Skin list by rarity on right column
        local rarityOrder = {"Common","Rare","Exotic","Limited"}
        for _, rarity in ipairs(rarityOrder) do
            local rarGroup = Tabs.Skins:AddRightGroupbox(rarity)
            for _, s in ipairs(SKIN_LIST) do
                if s.rarity == rarity then
                    rarGroup:AddButton({
                        Text = "  " .. s.name,
                        Func = function()
                            _currentSkin = s.name
                            if Flags["SkinEnabled"] then _applySkin(s.name) end
                        end,
                    })
                end
            end
        end
    end
    -- ================================================================

    _notify('Welcome | Buter.cel','',4)

end

_selectedScript = "trident"
_buildMainUI()

-- ── Player Count Box (top-right) ──────────────────────────────────────────
do
    local _pcPlayers = game:GetService("Players")
    local _pcGui = Instance.new("ScreenGui")
    _pcGui.Name = "BH_PlayerCount"
    _pcGui.ResetOnSpawn = false
    _pcGui.IgnoreGuiInset = true
    _pcGui.DisplayOrder = 9998
    pcall(function() _pcGui.Parent = game:GetService("CoreGui") end)
    if not _pcGui.Parent then _pcGui.Parent = _pcPlayers.LocalPlayer:WaitForChild("PlayerGui") end

    local box = Instance.new("Frame", _pcGui)
    box.Name = "PCBox"
    box.Size = UDim2.fromOffset(72, 44)
    box.Position = UDim2.new(1, -82, 0, 10)
    box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    box.BorderSizePixel = 0
    box.ZIndex = 2
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local _boxStroke = Instance.new("UIStroke", box)
    _boxStroke.Color = Color3.fromRGB(40, 40, 40)
    _boxStroke.Thickness = 1

    local labelTop = Instance.new("TextLabel", box)
    labelTop.Size = UDim2.new(1, 0, 0, 16)
    labelTop.Position = UDim2.fromOffset(0, 5)
    labelTop.BackgroundTransparency = 1
    labelTop.Text = "ᴘʟᴀʏᴇʀꜱ"
    labelTop.TextColor3 = Color3.fromRGB(120, 120, 120)
    labelTop.FontFace = _buterFont
    labelTop.TextSize = 8
    labelTop.ZIndex = 3

    local labelCount = Instance.new("TextLabel", box)
    labelCount.Size = UDim2.new(1, 0, 0, 22)
    labelCount.Position = UDim2.fromOffset(0, 19)
    labelCount.BackgroundTransparency = 1
    labelCount.Text = tostring(#_pcPlayers:GetPlayers())
    labelCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelCount.FontFace = _buterFont
    labelCount.TextSize = 18
    labelCount.ZIndex = 3

    local function _updateCount()
        labelCount.Text = tostring(#_pcPlayers:GetPlayers())
    end
    _pcPlayers.PlayerAdded:Connect(_updateCount)
    _pcPlayers.PlayerRemoving:Connect(function()
        task.wait()
        _updateCount()
    end)

    -- draggable
    local _pcDragging, _pcDragStart, _pcBoxStart = false, nil, nil
    box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            _pcDragging  = true
            _pcDragStart = input.Position
            _pcBoxStart  = box.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    _pcDragging = false
                end
            end)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if _pcDragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = input.Position - _pcDragStart
            box.Position = UDim2.new(
                _pcBoxStart.X.Scale, _pcBoxStart.X.Offset + d.X,
                _pcBoxStart.Y.Scale, _pcBoxStart.Y.Offset + d.Y
            )
        end
    end)
end
-- ─────────────────────────────────────────────────────────────────────────

--[[REMOVED_SELECTOR_START]]
--[[
do
    local CoreGui     = game:GetService("CoreGui")
    local TS          = game:GetService("TweenService")
    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local C = {
        bg      = Color3.fromRGB(13,  13,  13),
        bgCard  = Color3.fromRGB(10,  10,  10),
        bgRow   = Color3.fromRGB(15,  15,  15),
        border  = Color3.fromRGB(45,  45,  45),
        accent  = Color3.fromRGB(255, 182, 210),
        white   = Color3.fromRGB(230, 230, 230),
        grey    = Color3.fromRGB(120, 120, 120),
        dimgrey = Color3.fromRGB(30,  30,  30),
        green   = Color3.fromRGB(80,  220, 120),
        red     = Color3.fromRGB(220,  60,  60),
    }

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "ButerSelector"; GUI.DisplayOrder = 9990
    GUI.IgnoreGuiInset = true; GUI.ResetOnSpawn = false
    pcall(function() GUI.Parent = CoreGui end)
    if not GUI.Parent then GUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local Overlay = Instance.new("Frame", GUI)
    Overlay.Size = UDim2.new(1,0,1,0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0; Overlay.ZIndex = 1

    local CardOuter = Instance.new("Frame", GUI)
    CardOuter.Size = UDim2.fromOffset(488, 414)
    CardOuter.Position = UDim2.new(0.5,-244, 0.5,-207)
    CardOuter.BackgroundTransparency = 1; CardOuter.BorderSizePixel = 0; CardOuter.ZIndex = 8
    local CardOuterStroke = Instance.new("UIStroke", CardOuter)
    CardOuterStroke.Color = Color3.fromRGB(200, 120, 160); CardOuterStroke.Thickness = 0

    local Card = Instance.new("Frame", GUI)
    Card.Size = UDim2.fromOffset(480, 406)
    Card.Position = UDim2.new(0.5,-240, 0.5,-203)
    Card.BackgroundColor3 = C.bgCard
    Card.BackgroundTransparency = 1
    Card.BorderSizePixel = 0; Card.ZIndex = 10
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = C.accent; CardStroke.Thickness = 1

    local TopBar = Instance.new("Frame", Card)
    TopBar.Size = UDim2.new(1,0,0,28)
    TopBar.BackgroundColor3 = C.bg
    TopBar.BorderSizePixel = 0; TopBar.ZIndex = 11
    local TopLine = Instance.new("Frame", TopBar)
    TopLine.Size = UDim2.new(1,0,0,1); TopLine.Position = UDim2.new(0,0,1,-1)
    TopLine.BackgroundColor3 = C.border; TopLine.BorderSizePixel = 0; TopLine.ZIndex = 12

    local LogoIcon = Instance.new("Frame", TopBar)
    LogoIcon.Size = UDim2.fromOffset(16,16); LogoIcon.Position = UDim2.fromOffset(8,6)
    LogoIcon.BackgroundColor3 = C.accent; LogoIcon.BorderSizePixel = 0; LogoIcon.ZIndex = 12
    local LogoTxt = Instance.new("TextLabel", LogoIcon)
    LogoTxt.Size = UDim2.new(1,0,1,0); LogoTxt.BackgroundTransparency = 1
    LogoTxt.Text = "ʙ"; LogoTxt.TextColor3 = Color3.new(1,1,1)
    LogoTxt.FontFace = _buterFont; LogoTxt.TextSize = 9; LogoTxt.ZIndex = 13

    local BrandLbl = Instance.new("TextLabel", TopBar)
    BrandLbl.Size = UDim2.new(0,200,1,0); BrandLbl.Position = UDim2.fromOffset(30,0)
    BrandLbl.BackgroundTransparency = 1
    BrandLbl.Text = "ʙᴜᴛᴇʀ.ᴄᴇʟ"; BrandLbl.TextColor3 = C.white
    BrandLbl.FontFace = _buterFont; BrandLbl.TextSize = 10
    BrandLbl.TextXAlignment = Enum.TextXAlignment.Left; BrandLbl.ZIndex = 12

    local VerPill = Instance.new("TextLabel", TopBar)
    VerPill.Size = UDim2.fromOffset(58,16); VerPill.Position = UDim2.new(1,-65,0.5,-8)
    VerPill.BackgroundTransparency = 1; VerPill.BorderSizePixel = 0; VerPill.ZIndex = 12
    VerPill.Text = "ᴠ2.0 ᴘᴀɪᴅ"; VerPill.TextColor3 = C.grey
    VerPill.FontFace = _buterFont; VerPill.TextSize = 9

    local playerName = LocalPlayer and LocalPlayer.Name or "Player"
    local displayKey = _verifiedKey ~= "" and _verifiedKey or "Buter"
    local displayKeyShort = #displayKey > 40 and displayKey:sub(1,40).."..." or displayKey
    local _selExecutor = "Unknown"
    pcall(function()
        if identifyexecutor then _selExecutor = identifyexecutor()
        elseif syn then _selExecutor = "Synapse X"
        elseif KRNL_LOADED then _selExecutor = "Krnl"
        elseif isexecutorclosure then _selExecutor = "Delta"
        end
        _selExecutor = tostring(_selExecutor):match("^([^%s]+)") or _selExecutor
    end)

    local InfoBar = Instance.new("Frame", Card)
    InfoBar.Size = UDim2.new(1,-20,0,58); InfoBar.Position = UDim2.fromOffset(10,36)
    InfoBar.BackgroundColor3 = C.bg; InfoBar.BorderSizePixel = 0; InfoBar.ZIndex = 11
    local InfoStroke = Instance.new("UIStroke", InfoBar)
    InfoStroke.Color = C.border; InfoStroke.Thickness = 1

    local function _infoRow(parent, text, yOff)
        local lbl = Instance.new("TextLabel", parent)
        lbl.Size = UDim2.new(1,-16,0,16); lbl.Position = UDim2.fromOffset(10, yOff)
        lbl.BackgroundTransparency = 1; lbl.Text = text
        lbl.TextColor3 = C.white; lbl.FontFace = _buterFont
        lbl.TextSize = 8; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12
    end
    _infoRow(InfoBar, "name: " .. playerName, 6)
    _infoRow(InfoBar, "key: "  .. displayKeyShort, 24)
    _infoRow(InfoBar, "executor: " .. _selExecutor, 42)

    local ListPanel = Instance.new("ScrollingFrame", Card)
    ListPanel.Size = UDim2.fromOffset(268, 248); ListPanel.Position = UDim2.fromOffset(10,104)
    ListPanel.BackgroundColor3 = C.bg; ListPanel.BorderSizePixel = 0; ListPanel.ZIndex = 11
    ListPanel.CanvasSize = UDim2.fromOffset(0, 200)
    ListPanel.ScrollBarThickness = 2
    ListPanel.ScrollBarImageColor3 = C.accent
    ListPanel.ElasticBehavior = Enum.ElasticBehavior.Never
    ListPanel.ScrollingDirection = Enum.ScrollingDirection.Y
    local ListStroke = Instance.new("UIStroke", ListPanel)
    ListStroke.Color = C.border; ListStroke.Thickness = 1

    local RightPanel = Instance.new("Frame", Card)
    RightPanel.Size = UDim2.fromOffset(188,248); RightPanel.Position = UDim2.fromOffset(282,104)
    RightPanel.BackgroundColor3 = C.bg; RightPanel.BorderSizePixel = 0; RightPanel.ZIndex = 11
    local RightStroke = Instance.new("UIStroke", RightPanel)
    RightStroke.Color = C.border; RightStroke.Thickness = 1

    local function _rightLbl(parent, text, col, yOff, sz)
        local lbl = Instance.new("TextLabel", parent)
        lbl.Size = UDim2.new(1,-16,0,16); lbl.Position = UDim2.fromOffset(10, yOff)
        lbl.BackgroundTransparency = 1; lbl.Text = text
        lbl.TextColor3 = col; lbl.FontFace = _buterFont
        lbl.TextSize = sz or 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12
        return lbl
    end

    _rightLbl(RightPanel, "selected:", C.grey, 10)
    local SelName    = _rightLbl(RightPanel, "none",    C.white, 26, 13)
    _rightLbl(RightPanel, "",  C.grey, 46)
    local StatusHdr  = _rightLbl(RightPanel, "status: n/a",   C.grey, 52)
    local VersionHdr = _rightLbl(RightPanel, "version: n/a",  C.grey, 68)
    _rightLbl(RightPanel, "injection:", C.grey, 92)
    local InjStatus  = _rightLbl(RightPanel, "idle", C.grey, 108)

    local InjectBtn = Instance.new("TextButton", RightPanel)
    InjectBtn.Size = UDim2.new(1,-20,0,28); InjectBtn.Position = UDim2.fromOffset(10,206)
    InjectBtn.BackgroundColor3 = C.dimgrey; InjectBtn.BorderSizePixel = 0
    InjectBtn.Text = "ɪɴᴊᴇᴄᴛ"; InjectBtn.TextColor3 = C.grey
    InjectBtn.FontFace = _buterFont; InjectBtn.TextSize = 9
    InjectBtn.AutoButtonColor = false; InjectBtn.ZIndex = 12
    local InjStroke = Instance.new("UIStroke", InjectBtn)
    InjStroke.Color = C.border; InjStroke.Thickness = 1

    local games = {
        { id="trident", name="Trident Survival", status="Available", version="v1", color=Color3.fromRGB(60,160,255) },
    }

    local selectedRow = nil
    local rows = {}

    local function updateSelection(game)
        _selectedScript = game.id
        SelName.Text    = game.name
        StatusHdr.Text  = "ꜱᴛᴀᴛᴜꜱ: "  .. game.status
        VersionHdr.Text = "ᴠᴇʀꜱɪᴏɴ: " .. game.version
        local isClosed = game.status:find("Closed") or game.status:find("Repair") or game.status:find("Unavailable")
        if isClosed then
            _selectedScript = nil
            InjStatus.Text = "ᴜɴᴀᴠᴀɪʟᴀʙʟᴇ"; InjStatus.TextColor3 = C.grey
            TS:Create(InjectBtn, TweenInfo.new(0.15), {BackgroundColor3=C.dimgrey}):Play()
            InjectBtn.TextColor3 = C.grey; InjStroke.Color = C.border
        else
            InjStatus.Text = "ʀᴇᴀᴅʏ"; InjStatus.TextColor3 = C.green
            TS:Create(InjectBtn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(120, 50, 80)}):Play()
            InjectBtn.TextColor3 = C.white; InjStroke.Color = C.accent
        end
        for _, r in ipairs(rows) do
            TS:Create(r.frame, TweenInfo.new(0.12), {BackgroundColor3=C.bg}):Play()
            r.selBar.BackgroundTransparency = 1
        end
        if selectedRow then
            TS:Create(selectedRow.frame, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(32, 18, 24)}):Play()
            selectedRow.selBar.BackgroundTransparency = 0
        end
    end

    for i, g in ipairs(games) do
        local yPos = (i-1) * 88 + 8

        local row = Instance.new("Frame", ListPanel)
        row.Size = UDim2.new(1,-16,0,78); row.Position = UDim2.fromOffset(8, yPos)
        row.BackgroundColor3 = C.bg; row.BorderSizePixel = 0; row.ZIndex = 12
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = C.border; rowStroke.Thickness = 1

        local selBar = Instance.new("Frame", row)
        selBar.Size = UDim2.fromOffset(3,78); selBar.BackgroundColor3 = g.color
        selBar.BorderSizePixel = 0; selBar.BackgroundTransparency = 1; selBar.ZIndex = 14
        Instance.new("UICorner", selBar).CornerRadius = UDim.new(0,5)

        local thumb = Instance.new("Frame", row)
        thumb.Size = UDim2.fromOffset(54,54); thumb.Position = UDim2.fromOffset(10,12)
        thumb.BackgroundColor3 = Color3.fromRGB(14,14,14); thumb.BorderSizePixel = 0; thumb.ZIndex = 13
        local thumbImg = Instance.new("ImageLabel", thumb)
        thumbImg.Size = UDim2.new(1,0,1,0); thumbImg.BackgroundTransparency = 1
        thumbImg.Image = ""; thumbImg.ImageTransparency = 1
        thumbImg.ScaleType = Enum.ScaleType.Crop; thumbImg.BorderSizePixel = 0; thumbImg.ZIndex = 14
        _loadURLImage(thumbImg, _TRIDENT_URL, Color3.fromRGB(35, 18, 25))

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(1,-80,0,18); nameLbl.Position = UDim2.fromOffset(72,10)
        nameLbl.BackgroundTransparency = 1; nameLbl.Text = g.name
        nameLbl.TextColor3 = C.white; nameLbl.FontFace = _buterFont
        nameLbl.TextSize = 9; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 13

        local statusLbl = Instance.new("TextLabel", row)
        statusLbl.Size = UDim2.new(1,-80,0,14); statusLbl.Position = UDim2.fromOffset(72,30)
        statusLbl.BackgroundTransparency = 1; statusLbl.Text = g.status
        statusLbl.TextColor3 = g.color; statusLbl.FontFace = _buterFont
        statusLbl.TextSize = 9; statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.ZIndex = 13

        local verLbl = Instance.new("TextLabel", row)
        verLbl.Size = UDim2.new(1,-80,0,12); verLbl.Position = UDim2.fromOffset(72,46)
        verLbl.BackgroundTransparency = 1; verLbl.Text = g.version
        verLbl.TextColor3 = C.grey; verLbl.FontFace = _buterFont
        verLbl.TextSize = 8; verLbl.TextXAlignment = Enum.TextXAlignment.Left; verLbl.ZIndex = 13

        local selBtn = Instance.new("TextButton", row)
        selBtn.Size = UDim2.fromOffset(48,20); selBtn.Position = UDim2.new(1,-54,0.5,-10)
        selBtn.BackgroundColor3 = C.dimgrey; selBtn.BorderSizePixel = 0
        selBtn.Text = "ꜱᴇʟᴇᴄᴛ"; selBtn.TextColor3 = C.white
        selBtn.FontFace = _buterFont; selBtn.TextSize = 8
        selBtn.AutoButtonColor = false; selBtn.ZIndex = 14

        local rowEntry = {frame=row, selBar=selBar, game=g}
        table.insert(rows, rowEntry)

        selBtn.MouseButton1Click:Connect(function()
            selectedRow = rowEntry
            updateSelection(g)
        end)
        selBtn.MouseEnter:Connect(function()
            TS:Create(selBtn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(120, 50, 80)}):Play()
        end)
        selBtn.MouseLeave:Connect(function()
            TS:Create(selBtn, TweenInfo.new(0.1), {BackgroundColor3=C.dimgrey}):Play()
        end)
    end

    if #rows > 0 then
        selectedRow = rows[1]
        updateSelection(games[1])
    end

    local DiscordBtn = Instance.new("TextButton", Card)
    DiscordBtn.Size = UDim2.new(1,-20,0,22); DiscordBtn.Position = UDim2.fromOffset(10,376)
    DiscordBtn.BackgroundColor3 = C.bg; DiscordBtn.BorderSizePixel = 0
    DiscordBtn.Text = "discord.gg/MvDnxsRFb"; DiscordBtn.TextColor3 = C.grey
    DiscordBtn.FontFace = _buterFont; DiscordBtn.TextSize = 9
    DiscordBtn.AutoButtonColor = false; DiscordBtn.ZIndex = 11
    local DscStroke = Instance.new("UIStroke", DiscordBtn)
    DscStroke.Color = C.border; DscStroke.Thickness = 1

    DiscordBtn.MouseEnter:Connect(function()
        DiscordBtn.TextColor3 = Color3.fromRGB(114,137,218)
        DscStroke.Color = Color3.fromRGB(114,137,218)
    end)
    DiscordBtn.MouseLeave:Connect(function()
        DiscordBtn.TextColor3 = C.grey
        DscStroke.Color = C.border
    end)
    DiscordBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/MvDnxsRFb") end)
        local orig = DiscordBtn.Text
        DiscordBtn.Text = "✅  ʟɪɴᴋ ᴄᴏᴘɪᴇᴅ!"
        DiscordBtn.TextColor3 = C.green
        task.delay(2, function() DiscordBtn.Text = orig; DiscordBtn.TextColor3 = C.grey end)
    end)

    InjectBtn.MouseButton1Click:Connect(function()
        if not _selectedScript then return end
        InjStatus.Text = "ɪɴᴊᴇᴄᴛɪɴɢ..."; InjStatus.TextColor3 = C.accent
        InjectBtn.Text = "ɪɴᴊᴇᴄᴛɪɴɢ..."
        task.wait(0.2)
        TS:Create(Card, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
        TS:Create(Overlay, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
        task.wait(0.3)
        pcall(function() GUI:Destroy() end)
        task.spawn(_buildMainUI)
    end)

    InjectBtn.MouseEnter:Connect(function()
        if _selectedScript then
            TS:Create(InjectBtn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(180, 100, 140)}):Play()
        end
    end)
    InjectBtn.MouseLeave:Connect(function()
        if _selectedScript then
            TS:Create(InjectBtn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(120, 50, 80)}):Play()
        end
    end)

    TS:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency=0.45}):Play()
    task.wait(0.05)
    TS:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency=0}):Play()
end
]]--REMOVED_SELECTOR_END
