local ADDON = ...

local UPDATE_INTERVAL = 0.5

local f = CreateFrame("Frame", "FpsPingFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
f:SetSize(70, 36)
f:SetFrameStrata("HIGH")
f:SetClampedToScreen(true)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
f:SetBackdropColor(0, 0, 0, 0.6)
f:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)

local fpsText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fpsText:SetPoint("TOP", 0, -5)

local msText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
msText:SetPoint("BOTTOM", 0, 5)

local function FpsColor(fps)
    if fps >= 60 then return "|cff00ff00" elseif fps >= 30 then return "|cffffff00" end
    return "|cffff0000"
end

local function MsColor(ms)
    if ms <= 100 then return "|cff00ff00" elseif ms <= 250 then return "|cffffff00" end
    return "|cffff0000"
end

local function Update()
    local fps = floor(GetFramerate() + 0.5)
    local _, _, home, world = GetNetStats()
    local ms = (world and world > 0) and world or home or 0
    fpsText:SetText(FpsColor(fps) .. fps .. "|r fps")
    msText:SetText(MsColor(ms) .. ms .. "|r ms")
end

local elapsed = 0
f:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed >= UPDATE_INTERVAL then
        elapsed = 0
        Update()
    end
end)

local function SavePosition()
    local point, _, relPoint, x, y = f:GetPoint()
    FpsPingDB.point, FpsPingDB.relPoint, FpsPingDB.x, FpsPingDB.y = point, relPoint, x, y
end

f:SetScript("OnDragStart", function(self)
    if not FpsPingDB.locked then self:StartMoving() end
end)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")
    FpsPingDB = FpsPingDB or {}
    self:ClearAllPoints()
    if FpsPingDB.point then
        self:SetPoint(FpsPingDB.point, UIParent, FpsPingDB.relPoint, FpsPingDB.x, FpsPingDB.y)
    else
        self:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    end
    Update()
end)

SLASH_FPSPING1 = "/fpsping"
SlashCmdList.FPSPING = function(msg)
    msg = strlower(strtrim(msg or ""))
    if msg == "lock" then
        FpsPingDB.locked = true
        print("FpsPing: locked")
    elseif msg == "unlock" then
        FpsPingDB.locked = false
        print("FpsPing: unlocked")
    elseif msg == "reset" then
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
        SavePosition()
        print("FpsPing: position reset")
    elseif msg == "hide" then
        f:Hide()
    elseif msg == "show" then
        f:Show()
    else
        print("FpsPing: /fpsping lock | unlock | reset | show | hide")
    end
end
