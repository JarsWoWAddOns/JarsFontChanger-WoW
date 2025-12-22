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
    print("|cff00ff00Jar's Font Changer:|r Changed " .. changedCount .. " fonts. Type /reload to see all changes.")
end

-- Create configuration window
local function CreateConfigFrame()
    local frame = CreateFrame("Frame", "JFC_ConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(400, 250)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("Jar's Font Changer Configuration")
    
    -- Description
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOP", 0, -35)
    desc:SetText("Select a font to use as the global default:")
    
    -- Font selection dropdown
    local fontLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", 20, -70)
    fontLabel:SetText("Font:")
    
    local fontDropdown = CreateFrame("Frame", "JFC_FontDropdown", frame, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", 10, -85)
    
    -- Get current font name
    local function GetCurrentFontName()
        for name, path in pairs(FONTS) do
            if path == JarsFontChangerDB.font then
                return name
            end
        end
        return "Friz Quadrata (Default)"
    end
    
    -- Initialize dropdown
    UIDropDownMenu_SetWidth(fontDropdown, 300)
    UIDropDownMenu_SetText(fontDropdown, GetCurrentFontName())
    
    -- Dropdown menu function
    UIDropDownMenu_Initialize(fontDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for name, path in pairs(FONTS) do
            info.text = name
            info.func = function()
                JarsFontChangerDB.font = path
                UIDropDownMenu_SetText(fontDropdown, name)
                ApplyGlobalFont(path)
            end
            info.checked = (path == JarsFontChangerDB.font)
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Apply button
    local applyBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    applyBtn:SetSize(120, 25)
    applyBtn:SetPoint("BOTTOM", 0, 50)
    applyBtn:SetText("Apply Font")
    applyBtn:SetScript("OnClick", function()
        ApplyGlobalFont(JarsFontChangerDB.font)
    end)
    
    -- Reload UI button
    local reloadBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    reloadBtn:SetSize(120, 25)
    reloadBtn:SetPoint("BOTTOM", 0, 20)
    reloadBtn:SetText("Reload UI")
    reloadBtn:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Info text
    local info = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    info:SetPoint("BOTTOM", 0, 85)
    info:SetText("(Some UI elements may require a reload)")
    info:SetTextColor(0.7, 0.7, 0.7)
    
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
