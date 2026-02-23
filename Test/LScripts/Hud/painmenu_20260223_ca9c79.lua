--============================================================================
-- Profile Management Functions
--============================================================================

function PainMenu:ConfirmProfileSelection(profileName)
    if not profileName then return end
    
    local question = string.format("%s: %s", TXT.Menu.SelectProfile, profileName)
    local yesAction = string.format([[
        Cfg.CurrentProfile = '%s';
        Game:SetProfile(Cfg.CurrentProfile);
        Cfg:Save();
        PainMenu:ActivateScreen(ProfileMenu)
    ]], profileName)
    
    PainMenu:AskYesNo(question, yesAction, 'PainMenu:ActivateScreen(SelectProfileMenu)')
end

--============================================================================

function PainMenu:ConfirmProfileDeletion()
    local currentProfile = Cfg.CurrentProfile
    
    -- Safety checks
    if not currentProfile or currentProfile == "" or currentProfile == "Default" then
        return
    end
    
    local question = string.format("%s: %s. %s", 
        TXT.Menu.DeleteProfile, 
        currentProfile, 
        TXT.Menu.DeleteProfileConfirm
    )
    
    local yesAction = string.format([[
        PlayerProfile:Delete('%s');
        PainMenu:ActivateScreen(ProfileMenu)
    ]], currentProfile)
    
    PainMenu:AskYesNo(question, yesAction, 'PainMenu:ActivateScreen(ProfileMenu)')
end

--============================================================================

function PainMenu:HandleProfileListSelection()
    local selectedProfile = GetSelectedItemFromList("ProfileList")
    
    if not selectedProfile or selectedProfile == "Profiles" then
        return
    end
    
    -- Update stats display for selected profile
    self:UpdateStatsList()
    
    -- Enable/disable delete button based on selection
    if selectedProfile == "Default" then
        PMENU.DisableItem("DeleteProfile")
    else
        PMENU.EnableItem("DeleteProfile")
    end
    
    PMENU.PlaySound("menu/menu/back-light-on")
end

--============================================================================

function PainMenu:HandleProfileDoubleClick()
    local clickIndex = PMENU.GetDoubleClickedIndex("ProfileList")
    local selectedProfile = GetSelectedItemFromList("ProfileList")
    
    if clickIndex > 0 and selectedProfile and selectedProfile ~= Cfg.CurrentProfile then
        self:ConfirmProfileSelection(selectedProfile)
    end
end

--============================================================================

function PainMenu:CreateNewProfile(profileName)
    if not profileName or profileName == "" then
        PainMenu:ShowInfo(
            Languages.Texts[1329], 
            "PainMenu:ActivateScreen(CreateNewProfile)"
        )
        return
    end
    
    -- Sanitize profile name
    local cleanName = string.gsub(profileName, "[/\\.]", "")
    
    if cleanName == "" or cleanName == "Profiles" then
        PainMenu:ShowInfo(
            Languages.Texts[1329], 
            "PainMenu:ActivateScreen(CreateNewProfile)"
        )
        return
    end
    
    if not PlayerProfile:Create(cleanName) then
        PainMenu:ShowInfo(
            Languages.Texts[1329], 
            "PainMenu:ActivateScreen(CreateNewProfile)"
        )
        return
    end
    
    -- Set as current profile
    Cfg.CurrentProfile = cleanName
    Game:SetProfile(Cfg.CurrentProfile)
    Cfg:Save()
    
    -- Load RPG data for new profile
    if RPGSystem then
        self:ReloadRPGData()
    end
    
    PainMenu:ActivateScreen(ProfileMenu)
end

--============================================================================

function PainMenu:GetProfileDisplayText()
    return string.format("%s: %s", TXT.Menu.PlayerCurrentProfile, Cfg.CurrentProfile or "Default")
end

--============================================================================

function PainMenu:RefreshProfileList()
    if self.currScreen ~= SelectProfileMenu then
        return
    end
    
    PMENU.ClearList("ProfileList")
    PMENU.AddItemToList("ProfileList", TXT.Menu.Profiles)
    
    local profiles = PlayerProfile:GetProfiles()
    for i, profileName in ipairs(profiles) do
        PMENU.AddItemToList("ProfileList", profileName)
    end
end

--============================================================================

function PainMenu:OnProfileCreated()
    self:RefreshProfileList()
    PainMenu:ActivateScreen(SelectProfileMenu)
end