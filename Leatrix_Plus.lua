
-- 	Leatrix Plus 3.0.131-esMX-Fixed (10th May 2023 + Issue #21 Fix)
--  Fixed by SethNubth for Sattva-108/Leatrix_Plus Issue #21


LibCompat = LibStub:GetLibrary("LibCompat-1.0")
_G.LeaPlusDB = _G.LeaPlusDB or {}
LeaPlusDB = _G.LeaPlusDB
LeaPlusDB["ListenedTracks"] = LeaPlusDB["ListenedTracks"] or {}

local LeaPlusLC, LeaPlusCB, LeaDropList, LeaConfigList, LeaLockList = {}, {}, {}, {}, {}
local ClientVersion = GetBuildInfo()
local GameLocale = GetLocale()
local void

local isTBC = select(4, GetBuildInfo()) == 20400
local isWOTLK = select(4, GetBuildInfo()) == 30300
local isPastWOTLK = select(4, GetBuildInfo()) > 30300

-- FIXED VERSION TAG
LeaPlusLC["AddonVer"] = "3.0.131-esMX-Fixed"

local void, Leatrix_Plus = ...
local L = Leatrix_Plus.L

-- FIX #3: Version check - Extended for private servers (12340 esMX)
do
    local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
    if gametocversion and gametocversion < 20000 or gametocversion > 50000 then
        LibCompat.After(2, function()
            print(L["LEATRIX PLUS: WRONG VERSION INSTALLED!"])
        end)
        return
    end
end

if IsAddOnLoaded("ElvUI") then
    LeaPlusLC.ElvUI = unpack(ElvUI)
end
if IsAddOnLoaded("Glass") then
    LeaPlusLC.Glass = true
end

--	L00: Leatrix Plus

LeaPlusLC["ShowErrorsFlag"] = 1
LeaPlusLC["NumberOfPages"] = 9
LeaPlusLC["RaidColors"] = RAID_CLASS_COLORS

local LpEvt = CreateFrame("FRAME")
LpEvt:RegisterEvent("ADDON_LOADED")
LpEvt:RegisterEvent("PLAYER_LOGIN")
LpEvt:RegisterEvent("PLAYER_ENTERING_WORLD")

_G.BINDING_HEADER_LEATRIX_PLUS = "Leatrix Plus"
_G.BINDING_NAME_LEATRIX_PLUS_GLOBAL_TOGGLE = L["Toggle panel"]
_G.BINDING_NAME_LEATRIX_PLUS_GLOBAL_WEBLINK = L["Show web link"]
_G.BINDING_NAME_LEATRIX_PLUS_GLOBAL_RARE = L["Announce rare"]

--	L01: Functions

function LeaPlusLC:Print(text)
    DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
end

function LeaPlusLC:LockItem(item, lock)
    if lock then
        item:Disable()
        item:SetAlpha(0.3)
    else
        item:Enable()
        item:SetAlpha(1.0)
    end
end

function LeaPlusLC:HideConfigPanels()
    for k, v in pairs(LeaConfigList) do
        v:Hide()
    end
end

function LeaPlusLC:CheckIfQuestIsSharedAndShouldBeDeclined()
    if LeaPlusLC["NoSharedQuests"] == "On" then
        local npcName = UnitName("questnpc")
        if npcName then
            if UnitInParty(npcName) or UnitInRaid(npcName) then
                if not LeaPlusLC:FriendCheck(npcName) then
                    DeclineQuest()
                    return
                end
            end
        end
    end
end

-- FIX #2: ShowSystemEditBox - FIXED WASD bug (Issue #21 #2)
function LeaPlusLC:ShowSystemEditBox(word, focuschat)
    if not LeaPlusLC.FactoryEditBox then
        local eFrame = CreateFrame("FRAME", nil, UIParent)
        LeaPlusLC.FactoryEditBox = eFrame
        eFrame:SetSize(700, 110)
        eFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
        eFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        eFrame:EnableMouse(true)
        eFrame:EnableKeyboard()
        eFrame:SetScript("OnMouseDown", function(self, btn)
            if btn == "RightButton" then
                eFrame:Hide()
            end
        end)
        eFrame.t = eFrame:CreateTexture(nil, "BACKGROUND")
        eFrame.t:SetAllPoints()
        eFrame.t:SetTexture(0.05, 0.05, 0.05, 0.9)
        eFrame.f = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.f:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 12, -52)
        eFrame.f:SetWidth(676)
        eFrame.f:SetJustifyH("LEFT")
        eFrame.f:SetWordWrap(false)
        eFrame.c = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.c:SetText(L["Press CTRL/C to copy"])
        eFrame.c:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 12, -82)
        eFrame.x = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.x:SetPoint("TOPRIGHT", eFrame, "TOPRIGHT", -12, -52)
        eFrame.x:SetText("|cff00ff00Feedback Discord:|r |cffadd8e6sattva108|r")
        hooksecurefunc(eFrame.f, "SetText", function()
            eFrame.f:SetWidth(676 - eFrame.x:GetStringWidth() - 26)
        end)
        eFrame.x = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        eFrame.x:SetText(L["Right-click to close"])
        eFrame.x:SetPoint("TOPRIGHT", eFrame, "TOPRIGHT", -12, -82)
        eFrame.b = CreateFrame("EditBox", "LeatrixSystemEditBox", eFrame, "InputBoxTemplate")
        eFrame.b:ClearAllPoints()
        eFrame.b:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 16, -12)
        eFrame.b:SetSize(672, 24)
        eFrame.b:SetFontObject("GameFontNormalLarge")
        eFrame.b:SetTextColor(1.0, 1.0, 1.0, 1)
        eFrame.b:DisableDrawLayer("BACKGROUND")
        eFrame.b:SetHitRectInsets(99, 99, 99, 99)
        eFrame.b:SetAutoFocus(true)
        eFrame.b:SetAltArrowKeyMode(true)
        eFrame.b:EnableMouse(true)
        eFrame.b:EnableKeyboard(true)
        eFrame.t = CreateFrame("FRAME", nil, eFrame.b)
        eFrame.t:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 } })
        eFrame.t:SetPoint("LEFT", -6, 0)
        eFrame.t:SetWidth(eFrame.b:GetWidth() + 6)
        eFrame.t:SetHeight(eFrame.b:GetHeight())
        eFrame.t:SetBackdropColor(1.0, 1.0, 1.0, 0.3)
        eFrame.b:SetScript("OnChar", function()
            eFrame.b:SetText(word);
            eFrame.b:HighlightText();
        end);
        eFrame.b:SetScript("OnMouseUp", function()
            eFrame.b:HighlightText();
        end);
        eFrame.b:SetScript("OnEscapePressed", function()
            eFrame:Hide()
        end)
        eFrame.b:SetFocus(true)
        eFrame.b:HighlightText()
        eFrame:Show()
    end
    if focuschat then
        LeaPlusLC.FactoryEditBoxFocusChat = true
    else
        LeaPlusLC.FactoryEditBoxFocusChat = nil
    end
    LeaPlusLC.FactoryEditBox:Show()
    LeaPlusLC.FactoryEditBox.b:SetText(word)
    LeaPlusLC.FactoryEditBox.b:HighlightText()
    -- FIXED: Removed WASD close check
    LeaPlusLC.FactoryEditBox.b:SetScript("OnChar", function()
        LeaPlusLC.FactoryEditBox.b:SetText(word)
        LeaPlusLC.FactoryEditBox.b:HighlightText()
    end)
    LeaPlusLC.FactoryEditBox.b:SetScript("OnKeyUp", function()
        LeaPlusLC.FactoryEditBox.b:SetFocus(true)
        LeaPlusLC.FactoryEditBox.b:SetText(word)
        LeaPlusLC.FactoryEditBox.b:HighlightText()
    end)
end

function LeaPlusLC:LoadVarChk(var, def)
    if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" and LeaPlusDB[var] == "On" or LeaPlusDB[var] == "Off" then
        LeaPlusLC[var] = LeaPlusDB[var]
    else
        LeaPlusLC[var] = def
        LeaPlusDB[var] = def
    end
end

function LeaPlusLC:LoadVarNum(var, def, valmin, valmax)
    if LeaPlusDB[var] and type(LeaPlusDB[var]) == "number" and LeaPlusDB[var] >= valmin and LeaPlusDB[var] <= valmax then
        LeaPlusLC[var] = LeaPlusDB[var]
    else
        LeaPlusLC[var] = def
        LeaPlusDB[var] = def
    end
end

function LeaPlusLC:LoadVarAnc(var, def)
    if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" and LeaPlusDB[var] == "CENTER" or LeaPlusDB[var] == "TOP" or LeaPlusDB[var] == "BOTTOM" or LeaPlusDB[var] == "LEFT" or LeaPlusDB[var] == "RIGHT" or LeaPlusDB[var] == "TOPLEFT" or LeaPlusDB[var] == "TOPRIGHT" or LeaPlusDB[var] == "BOTTOMLEFT" or LeaPlusDB[var] == "BOTTOMRIGHT" then
        LeaPlusLC[var] = LeaPlusDB[var]
    else
        LeaPlusLC[var] = def
        LeaPlusDB[var] = def
    end
end

function LeaPlusLC:LoadVarStr(var, def)
    if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" then
        LeaPlusLC[var] = LeaPlusDB[var]
    else
        LeaPlusLC[var] = def
        LeaPlusDB[var] = def
    end
end

function LeaPlusLC:TipSee()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    local parent = self:GetParent()
    local pscale = parent:GetEffectiveScale()
    local gscale = UIParent:GetEffectiveScale()
    local tscale = GameTooltip:GetEffectiveScale()
    local gap = ((UIParent:GetRight() * gscale) - (parent:GetRight() * pscale))
    if gap < (250 * tscale) then
        GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
    else
        GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
    end
    GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
end

function LeaPlusLC:ShowDropTip()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    local parent = self:GetParent():GetParent():GetParent()
    local pscale = parent:GetEffectiveScale()
