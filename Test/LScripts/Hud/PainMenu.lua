if itemName == "DeleteProfile" then
	o.disabled = not Cfg.CurrentProfile or Cfg.CurrentProfile == "" or Cfg.CurrentProfile == "Default"
end

if itemName == "SelectProfile" then
	o.disabled = not Cfg.CurrentProfile or Cfg.CurrentProfile == ""
end

function PainMenu:SelectProfile(profile)
    if profile then
        local yes_action = string.format( "Cfg.CurrentProfile = '%s' ; Game:SetProfile(Cfg.CurrentProfile); Cfg:Save(); PainMenu:ActivateScreen(ProfileMenu)", profile )
        PainMenu:AskYesNo( TXT.Menu.SelectProfile..": "..profile, yes_action, 'PainMenu:ActivateScreen(SelectProfile)' )
    end
end

function PainMenu:DeleteProfile()
    local profile = Cfg.CurrentProfile
    
    if not profile or profile == "" or profile == "Default" then
        return
    end
    
    local yes_action = string.format("PlayerProfile:Delete('%s'); PainMenu:ActivateScreen(ProfileMenu)", profile)
    PainMenu:AskYesNo(TXT.Menu.DeleteProfile..": "..profile..". "..TXT.Menu.DeleteProfileConfirm, yes_action, 'PainMenu:ActivateScreen(ProfileMenu)')
end

function PainMenu:SelectProfile(profile)
	SelectProfileMenu:RefreshProfiles()
    PainMenu:ActivateScreen(SelectProfileMenu)
end