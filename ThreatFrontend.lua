ThreatIllustratorDB = ThreatIllustratorDB or {}
if type(ThreatIllustratorDB.Visible) ~= "boolean" then
    ThreatIllustratorDB.Visible = true
end

local ParentFrame = CreateFrame("Frame", "ThreatIllustratorFrame", UIParent, "BasicFrameTemplateWithInset")
ParentFrame:SetSize(190, 200)
ParentFrame:SetFrameStrata("DIALOG")
ParentFrame:SetClampedToScreen(true)
ParentFrame.TitleText:SetText("Threat Illustrator")
ParentFrame.CloseButton:Hide()

local savedPosition = ThreatIllustratorDB.Position
local uiWidth, uiHeight = UIParent:GetWidth(), UIParent:GetHeight()
if type(savedPosition) == "table"
    and type(savedPosition.X) == "number"
    and type(savedPosition.Y) == "number"
    and uiWidth > 0
    and uiHeight > 0 then
    ParentFrame:SetPoint(
        "CENTER",
        UIParent,
        "BOTTOMLEFT",
        savedPosition.X * uiWidth,
        savedPosition.Y * uiHeight
    )
else
    ParentFrame:SetPoint("CENTER")
end

local ScrollBox = CreateFrame("Frame", nil, ParentFrame, "WowScrollBoxList")

local AggroColorPerSituation = {
    [0] = {1, 0, 0}, -- Low Threat
    [1] = {1, 0.67, 0}, -- High Threat
    [2] = {1, 0.94, 0}, -- Primary Target but not High Threat
    [3] = {0, 1, 0}  -- Primary Target and High Threat
}
local StatusFrames = {}

-- Slash Commands
SLASH_TI1 = "/ti"
SLASH_TI2 = "/threatillustrator"
SlashCmdList["TI"] = function ()
    if ParentFrame:IsShown() then
        ParentFrame:Hide()
    else
        ParentFrame:Show()
    end
end

-- UIFrame Content Area
ScrollBox:SetPoint("TOPLEFT", ParentFrame, "TOPLEFT", 10, -32)
ScrollBox:SetPoint("BOTTOMRIGHT", ParentFrame, "BOTTOMRIGHT", -30, 10)
ScrollBox:EnableMouse(true)

-- UIFrame Movable Interactions
ParentFrame:EnableMouse(true)
ParentFrame:SetMovable(true)
ParentFrame:RegisterForDrag("LeftButton")
if not ThreatIllustratorDB.Visible then
    ParentFrame:Hide()
end

-- UIFrame Drag Events
ParentFrame:SetScript("OnDragStart", function (self)
    self:StartMoving()
end)

ParentFrame:SetScript("OnDragStop", function (self)
    self:StopMovingOrSizing()

    local centerX, centerY = self:GetCenter()
    local parentWidth, parentHeight = UIParent:GetWidth(), UIParent:GetHeight()
    if centerX and centerY and parentWidth > 0 and parentHeight > 0 then
        ThreatIllustratorDB.Position = {
            X = centerX / parentWidth,
            Y = centerY / parentHeight,
        }
    end
end)

-- UIFrame Show Events
ParentFrame:SetScript("OnShow", function (self)
    ThreatIllustratorDB.Visible = true
    PlaySound(800)
end)

ParentFrame:SetScript("OnHide", function (self)
    ThreatIllustratorDB.Visible = false
    PlaySound(800)
end)

local ScrollBar = CreateFrame("EventFrame", nil, ParentFrame, "MinimalScrollBar")
ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT")
ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT")

local ScrollView = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)

local function Initializer(bar, enemy)
    bar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")

    local unit = enemy.Unit
    if unit and UnitExists(unit) then
        -- The StatusBar displays current health as a fraction of maximum health.
        -- Pass both values directly so secret combat values are never used in Lua math.
        bar:SetMinMaxValues(0, UnitHealthMax(unit))
        bar:SetValue(UnitHealth(unit))
    else
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(0)
    end

    local threat = enemy.ThreatStatus or 0

    local color = AggroColorPerSituation[threat] or {0.5, 0.5, 0.5}
    bar:SetStatusBarColor(color[1], color[2], color[3])

    if not bar.NameText then
        bar.NameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bar.NameText:SetPoint("LEFT", bar, "LEFT", 4, 0)
    end
    bar.NameText:SetText(enemy.Name or enemy.Unit or "Unknown")
end

ScrollView:SetElementInitializer("StatusBar", Initializer)
ScrollView:SetElementExtent(20)

local DataProvider = CreateDataProvider()
ScrollView:SetDataProvider(DataProvider)

function UpdateScrollData(enemies)
    DataProvider:Flush()

    for _, enemy in pairs(enemies) do
        DataProvider:Insert(enemy)
    end

    ScrollBox:ScrollToBegin(true)
end
