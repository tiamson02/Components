--=======================================================================
--                   SelectProfileMenu.lua
--                    By CityZD Lead Team.
--        Lua файл находится под авторским правом от компании ООО "РХК".
--=======================================================================


SelectProfileMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBigSize = 30,
    
    backAction = "PainMenu:ActivateScreen(ProfileMenu)",

    items =
    {

		SelectProfileBorder = 
		{
			type = MenuItemTypes.Border,
			x = 150,
			y = 240,
			width = 730,
			height = 120,
		},

        ProfileList =
        {
            type = MenuItemTypes.TextButtonEx,
            text = "Select Profile",
            desc = "Choose profile to use",
            currValue = 1,
            values = {},
            visible = {},
            option = "SelectedProfile",
            x     = -1,
            y     = 285,
            action = "",
            maxLength = 16,
        },

        SelectButton =
        {
            text = "Select",
            desc = "Apply selected profile",
            x     = -1,
            y     = 380,
            action = "SelectProfileMenu:ConfirmSelection()",
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            descColor   = R3D.RGB( 255, 186, 122 ),
            sndAccept   = "menu/magicboard/card-take",
            maxLength = 16,
        },
    },
}

function SelectProfileMenu:RefreshProfiles()
    local path = "../Profiles/"
    local numprofiles = 0

    self.items.ProfileList.values = {}
    self.items.ProfileList.visible = {}

    local profileDirs = FS.FindFiles(path.."*", 0, 1)

    for k, v in pairs(profileDirs) do
        if v ~= "." and v ~= ".." then
            numprofiles = numprofiles + 1
            table.insert(self.items.ProfileList.values, numprofiles)
            table.insert(self.items.ProfileList.visible, v)
        end
    end

    for i, profile in ipairs(self.items.ProfileList.visible) do
        if profile == Cfg.CurrentProfile then
            self.items.ProfileList.currValue = i
            break
        end
    end

    if numprofiles == 0 then
        self.items.ProfileList.desc = "No profiles available"
        self.items.ProfileList.visible = {[1] = "None"}
        self.items.ProfileList.currValue = 1
        self.items.SelectButton.disabled = true
    else
        self.items.SelectButton.disabled = false
    end
end

function SelectProfileMenu:ConfirmSelection()
    local selectedProfile = self.items.ProfileList.visible[self.items.ProfileList.currValue]

    if selectedProfile and selectedProfile ~= "None" and selectedProfile ~= "Profiles" and selectedProfile ~= Cfg.CurrentProfile then
        Cfg.CurrentProfile = selectedProfile
        Game:SetProfile(Cfg.CurrentProfile)
        
        -- Загружаем RPG данные для нового профиля
        if RPGSystem then
            RPGSystem:LoadFromProfile()
        end
        
        PainMenu:ApplySettings()
        PainMenu:ActivateScreen(ProfileMenu)
    end
end
