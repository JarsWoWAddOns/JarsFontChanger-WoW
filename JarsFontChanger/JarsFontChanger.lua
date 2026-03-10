-- Jar's Font Changer for WoW 12.0.1
-- Change the global default font

-- Saved variables with defaults
JarsFontChangerDB = JarsFontChangerDB or {}

-- Initialize defaults
local defaults = {
    font = "Fonts\\FRIZQT__.TTF",
}

for key, value in pairs(defaults) do
    if JarsFontChangerDB[key] == nil then
        JarsFontChangerDB[key] = value
    end
end

-- Frame references
local configFrame

-- Available fonts (will be populated from LSM if available)
local FONTS = {
    ["Friz Quadrata (Default)"] = "Fonts\\FRIZQT__.TTF",
    ["Arial"] = "Fonts\\ARIALN.TTF",
    ["Skurri"] = "Fonts\\SKURRI.TTF",
    ["Morpheus"] = "Fonts\\MORPHEUS.TTF",
}

-- Function to load fonts from LibSharedMedia-3.0
local function LoadSharedMediaFonts()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local fontList = LSM:List("font")
        if fontList and #fontList > 0 then
            FONTS = {}
            for _, fontName in ipairs(fontList) do
                local fontPath = LSM:Fetch("font", fontName)
                if fontPath then
                    FONTS[fontName] = fontPath
                end
            end
            print("|cff00ff00Jar's Font Changer:|r Loaded " .. #fontList .. " fonts from LibSharedMedia-3.0")
            
            -- Ensure built-in fonts are always available
            if not FONTS["Friz Quadrata (Default)"] then
                FONTS["Friz Quadrata (Default)"] = "Fonts\\FRIZQT__.TTF"
            end
            if not FONTS["Arial"] then
                FONTS["Arial"] = "Fonts\\ARIALN.TTF"
            end
            if not FONTS["Skurri"] then
                FONTS["Skurri"] = "Fonts\\SKURRI.TTF"
            end
            if not FONTS["Morpheus"] then
                FONTS["Morpheus"] = "Fonts\\MORPHEUS.TTF"
            end
            return true
        end
    end
    return false
end

-- Table to store original font settings
local originalFonts = {}

-- Apply font to all default font objects
local function ApplyGlobalFont(fontPath)
    -- List of all font objects to override
    local fontObjects = {
        "GameFontNormal",
        "GameFontNormalSmall",
        "GameFontNormalLarge",
        "GameFontNormalHuge",
        "GameFontNormalMed1",
        "GameFontNormalMed2",
        "GameFontNormalMed3",
        "GameFontHighlight",
        "GameFontHighlightSmall",
        "GameFontHighlightSmallOutline",
        "GameFontHighlightLarge",
        "GameFontHighlightHuge",
        "GameFontDisable",
        "GameFontDisableSmall",
        "GameFontDisableLarge",
        "GameFontGreen",
        "GameFontGreenSmall",
        "GameFontGreenLarge",
        "GameFontRed",
        "GameFontRedSmall",
        "GameFontRedLarge",
        "GameFontWhite",
        "GameFontWhiteSmall",
        "GameFontDarkGraySmall",
        "GameFontBlack",
        "GameFontBlackSmall",
        "NumberFontNormal",
        "NumberFontNormalSmall",
        "NumberFontNormalLarge",
        "NumberFontNormalHuge",
        "QuestTitleFont",
        "QuestTitleFontBlackShadow",
        "QuestFont",
        "QuestFontNormalSmall",
        "ItemTextFontNormal",
        "MailTextFontNormal",
        "SubSpellFont",
        "DialogButtonNormalText",
        "DialogButtonHighlightText",
        "ErrorFont",
        "TextStatusBarText",
        "CombatTextFont",
        "GameTooltipText",
        "GameTooltipTextSmall",
        "GameTooltipHeaderText",
        "WorldMapTextFont",
        "InvoiceTextFontNormal",
        "InvoiceTextFontSmall",
        "CombatLogFont",
        "GameFontNormalOutline",
        "GameFontNormalSmallLeft",
        "SystemFont_Outline_Small",
        "SystemFont_Shadow_Med1",
        "SystemFont_Shadow_Med2",
        "SystemFont_Shadow_Med3",
        "SystemFont_Shadow_Large",
        "SystemFont_Shadow_Huge1",
        "SystemFont_OutlineThick_Huge2",
        "SystemFont_OutlineThick_Huge4",
        "SystemFont_OutlineThick_WTF",
        "Fancy12Font",
        "Fancy14Font",
        "Fancy16Font",
        "Fancy18Font",
        "Fancy20Font",
        "Fancy22Font",
        "Fancy24Font",
        "Fancy27Font",
        "Fancy30Font",
        "Fancy32Font",
        "Fancy48Font",
        -- Damage/Combat text fonts
        "DAMAGE_TEXT_FONT",
        "UNIT_NAME_FONT",
        "NAMEPLATE_FONT",
        "STANDARD_TEXT_FONT",
        -- Floating combat text
        "NumberFont_OutlineThick_Mono_Small",
        "NumberFont_Outline_Huge",
        "NumberFont_Outline_Large",
        "NumberFont_Outline_Med",
        "NumberFont_Shadow_Med",
        "NumberFont_Shadow_Small",
        -- Floating Combat Text (FCT) specific
        "CombatTextFontOutline",
        "CombatTextFontNormal",
        -- Nameplate fonts
        "SystemFont_NamePlate",
        "SystemFont_LargeNamePlate",
        "SystemFont_NamePlateFixed",
        "SystemFont_LargeNamePlateFixed",
        "SystemFont_NamePlateCastBar",
        -- Additional system fonts
        "SystemFont_Tiny",
        "SystemFont_Small",
        "SystemFont_Small2",
        "SystemFont_Shadow_Small",
        "SystemFont_Med1",
        "SystemFont_Med2",
        "SystemFont_Med3",
        "SystemFont_Large",
        "SystemFont_Huge1",
        "SystemFont_Huge2",
        "SystemFont_OutlineThick_Huge4",
        "SystemFont_Shadow_Outline_Huge2",
        "FriendsFont_Normal",
        "FriendsFont_Small",
        "FriendsFont_Large",
        "FriendsFont_UserText",
        "ChatFontNormal",
        "ChatFontSmall",
        "ChatBubbleFont",
        "Tooltip_Med",
        "Tooltip_Small",
        "AchievementFont_Small",
        "ReputationDetailFont",
        "GameFont_Gigantic",
        "SplashHeaderFont",
    }
    
    local changedCount = 0
    for _, fontName in ipairs(fontObjects) do
        local fontObject = _G[fontName]
        if fontObject and fontObject.GetFont then
            local currentFont, size, flags = fontObject:GetFont()
            if currentFont then
                -- Store original if not already stored
                if not originalFonts[fontName] then
                    originalFonts[fontName] = {currentFont, size, flags}
                end
                
                -- Apply new font
                local success = pcall(function()
                    fontObject:SetFont(fontPath, size, flags)
                end)
                
                if success then
                    changedCount = changedCount + 1
                end
            end
        end
    end
    
    JarsFontChangerDB.font = fontPath
    
    -- Hook into Blizzard's floating combat text
    if COMBAT_TEXT_TYPE_INFO then
        for textType, info in pairs(COMBAT_TEXT_TYPE_INFO) do
            if info.fontName then
                info.fontName = fontPath
            end
        end
    end
    
    -- Try to update CombatText frames directly
    if CombatText_UpdateDisplayedMessages then
        pcall(CombatText_UpdateDisplayedMessages)
    end
    
    -- Update any existing combat text font strings
    for i = 1, 50 do
        local frame = _G["CombatText" .. i]
        if frame and frame.SetFont then
            pcall(function()
                local _, size, flags = frame:GetFont()
                frame:SetFont(fontPath, size or 20, flags or "OUTLINE")
            end)
        end
    end
    
    -- Update Blizzard's damage font frames if they exist
    if DAMAGE_TEXT_FONT then
        pcall(function()
            local _, size, flags = DAMAGE_TEXT_FONT:GetFont()
            DAMAGE_TEXT_FONT:SetFont(fontPath, size, flags)
        end)
    end
    
    print("|cff00ff00Jar's Font Changer:|r Changed " .. changedCount .. " fonts. Type /reload to see all changes.")
end

-- Modern dark UI color palette
local UI = {
    bg        = { 0.10, 0.10, 0.12, 0.95 },
    header    = { 0.13, 0.13, 0.16, 1 },
    accent    = { 1.0,  0.55, 0.0,  1 },
    accentDim = { 0.70, 0.35, 0.0,  1 },
    text      = { 0.90, 0.90, 0.90, 1 },
    textDim   = { 0.55, 0.55, 0.58, 1 },
    border    = { 0.22, 0.22, 0.26, 1 },
    btnNormal = { 0.18, 0.18, 0.22, 1 },
    btnHover  = { 0.24, 0.24, 0.28, 1 },
    btnPress  = { 0.14, 0.14, 0.17, 1 },
}

local BACKDROP_INFO = {
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

-- Helper: create a flat modern button with hover / press states
local function CreateModernButton(parent, text, width, height, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop(BACKDROP_INFO)
    btn:SetBackdropColor(unpack(UI.btnNormal))
    btn:SetBackdropBorderColor(unpack(UI.border))

    btn.label = btn:CreateFontString(nil, "OVERLAY")
    btn.label:SetFont("Fonts\\FRIZQT__.TTF", 11)
    btn.label:SetPoint("CENTER")
    btn.label:SetTextColor(unpack(UI.accent))
    btn.label:SetText(text)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(UI.btnHover))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(UI.btnNormal))
    end)
    btn:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(unpack(UI.btnPress))
    end)
    btn:SetScript("OnMouseUp", function(self)
        self:SetBackdropColor(unpack(UI.btnHover))
    end)
    btn:SetScript("OnClick", onClick)

    return btn
end

-- Create configuration window
local function CreateConfigFrame()
    -- Main frame
    local frame = CreateFrame("Frame", "JFC_ConfigFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 280)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(BACKDROP_INFO)
    frame:SetBackdropColor(unpack(UI.bg))
    frame:SetBackdropBorderColor(unpack(UI.border))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    -- Escape-to-close
    table.insert(UISpecialFrames, "JFC_ConfigFrame")

    ----------------------------------------------------------------
    -- Title bar
    ----------------------------------------------------------------
    local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    titleBar:SetHeight(30)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetBackdrop(BACKDROP_INFO)
    titleBar:SetBackdropColor(unpack(UI.header))
    titleBar:SetBackdropBorderColor(unpack(UI.border))

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
    titleText:SetPoint("LEFT", 12, 0)
    titleText:SetTextColor(unpack(UI.accent))
    titleText:SetText("Jar's Font Changer")

    -- Close button (minimal "x", turns red on hover)
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPoint("RIGHT", -2, 0)
    closeBtn.label = closeBtn:CreateFontString(nil, "OVERLAY")
    closeBtn.label:SetFont("Fonts\\FRIZQT__.TTF", 13)
    closeBtn.label:SetPoint("CENTER")
    closeBtn.label:SetTextColor(unpack(UI.textDim))
    closeBtn.label:SetText("x")
    closeBtn:SetScript("OnEnter", function(self)
        self.label:SetTextColor(1, 0.30, 0.30, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self.label:SetTextColor(unpack(UI.textDim))
    end)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    ----------------------------------------------------------------
    -- Scroll frame for content
    ----------------------------------------------------------------
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 20, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 10)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(330, 220)
    scrollFrame:SetScrollChild(content)

    ----------------------------------------------------------------
    -- Description
    ----------------------------------------------------------------
    local desc = content:CreateFontString(nil, "OVERLAY")
    desc:SetFont("Fonts\\FRIZQT__.TTF", 11)
    desc:SetPoint("TOPLEFT", 0, 0)
    desc:SetTextColor(unpack(UI.textDim))
    desc:SetText("Select a font to use as the global default:")

    ----------------------------------------------------------------
    -- Font dropdown
    ----------------------------------------------------------------
    local fontLabel = content:CreateFontString(nil, "OVERLAY")
    fontLabel:SetFont("Fonts\\FRIZQT__.TTF", 11)
    fontLabel:SetPoint("TOPLEFT", 0, -26)
    fontLabel:SetTextColor(unpack(UI.text))
    fontLabel:SetText("Font:")

    local function GetCurrentFontName()
        for name, path in pairs(FONTS) do
            if path == JarsFontChangerDB.font then
                return name
            end
        end
        return "Friz Quadrata (Default)"
    end

    local fontDropdown = CreateFrame("DropdownButton", nil, content, "WowStyle1DropdownTemplate")
    fontDropdown:SetPoint("TOPLEFT", 0, -42)
    fontDropdown:SetWidth(330)
    fontDropdown:SetDefaultText(GetCurrentFontName())
    fontDropdown:SetupMenu(function(_, rootDescription)
        for name, path in pairs(FONTS) do
            rootDescription:CreateRadio(name,
                function() return JarsFontChangerDB.font == path end,
                function()
                    JarsFontChangerDB.font = path
                    ApplyGlobalFont(path)
                end)
        end
    end)

    ----------------------------------------------------------------
    -- Apply button
    ----------------------------------------------------------------
    local applyBtn = CreateModernButton(content, "Apply Font", 150, 28, function()
        ApplyGlobalFont(JarsFontChangerDB.font)
    end)
    applyBtn:SetPoint("TOPLEFT", 0, -86)

    ----------------------------------------------------------------
    -- Reload UI button
    ----------------------------------------------------------------
    local reloadBtn = CreateModernButton(content, "Reload UI", 150, 28, function()
        ReloadUI()
    end)
    reloadBtn:SetPoint("LEFT", applyBtn, "RIGHT", 10, 0)

    ----------------------------------------------------------------
    -- Info text
    ----------------------------------------------------------------
    local info = content:CreateFontString(nil, "OVERLAY")
    info:SetFont("Fonts\\FRIZQT__.TTF", 11)
    info:SetPoint("TOPLEFT", 0, -124)
    info:SetTextColor(unpack(UI.textDim))
    info:SetText("(Some UI elements may require a reload)")

    return frame
end

-- Event handler
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "JarsFontChanger" then
            -- Load fonts from SharedMedia if available
            LoadSharedMediaFonts()
        end
    elseif event == "PLAYER_LOGIN" then
        print("|cff00ff00Jar's Font Changer|r loaded. Type /jfc for options.")
        
        -- Create config window
        configFrame = CreateConfigFrame()
        
        -- Apply saved font after a short delay to ensure all UI elements are loaded
        C_Timer.After(0.5, function()
            if JarsFontChangerDB.font and JarsFontChangerDB.font ~= "Fonts\\FRIZQT__.TTF" then
                ApplyGlobalFont(JarsFontChangerDB.font)
            end
        end)
    end
end)

-- Slash commands
SLASH_JARSFONTCHANGER1 = "/jfc"
SLASH_JARSFONTCHANGER2 = "/jarsfontchanger"
SlashCmdList["JARSFONTCHANGER"] = function(msg)
    msg = msg:lower():trim()
    
    if msg == "config" or msg == "" then
        if configFrame then
            configFrame:SetShown(not configFrame:IsShown())
        end
        
    elseif msg == "reset" then
        JarsFontChangerDB.font = "Fonts\\FRIZQT__.TTF"
        ApplyGlobalFont(JarsFontChangerDB.font)
        print("|cff00ff00Jar's Font Changer|r Font reset to default")
        
    else
        print("|cff00ff00Jar's Font Changer|r Commands:")
        print("  /jfc - Open configuration window")
        print("  /jfc config - Open configuration window")
        print("  /jfc reset - Reset to default font")
    end
end
