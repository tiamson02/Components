--============================================================================
-- Custom Difficulty Menu
--============================================================================

CustomDifficultyMenu = {
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

    menuWidth   = 880,
	fontBigSize = 26,

    itemsDrawShadow = true,
    background = "HUD/Menu",
    bgType = MenuBackgroundTypes.Image,

    sndAccept = "menu/menu/option-accept",
    sndLightOn = "menu/menu/option-light-on",

    backAction = "PainMenu:ActivateScreen(NewGameMenu)",

    items = {
        GeneralTab = {
            type = MenuItemTypes.TabGroup,
            x = 50,
            y = 60,
            width = 924,
            height = 576,
            visible = true,
            align = MenuAlign.Left,
            items = {
                PlayerDamage = {
                    type = MenuItemTypes.Slider,
                    text = "Player Damage",
                    desc = "Adjust damage taken by player (1x–10x)",
                    option = "CustomPlayerDamage",
                    minValue = 0,
                    maxValue = 10,
                    currValue = 1,
                    x = 120,
                    y = 160,
                    sliderWidth = 300,
                    applyRequired = true,
                },
                AmmoMultiplier = {
                    type = MenuItemTypes.Slider,
                    text = "Ammo Multiplier",
                    desc = "Adjust ammo found in boxes (0.5x–5x)",
                    option = "CustomAmmoMultiplier",
                    minValue = 0,
                    maxValue = 5,
                    currValue = 1,
                    x = 120,
                    y = 210,
                    sliderWidth = 300,
                    applyRequired = true,
                },
                EnemyDamage = {
                    type = MenuItemTypes.Slider,
                    text = "Enemy Damage",
                    desc = "Adjust damage dealt by enemies (1x–10x)",
                    option = "CustomEnemyDamage",
                    minValue = 0,
                    maxValue = 10,
                    currValue = 2,
                    x = 120,
                    y = 260,
                    sliderWidth = 300,
                    applyRequired = true,
                },
                PlayerSpeed = {
                    type = MenuItemTypes.Slider,
                    text = "Player Speed",
                    desc = "Adjust player movement speed (1x–5x)",
                    option = "CustomPlayerSpeed",
                    minValue = 0,
                    maxValue = 5,
                    currValue = 1,
                    x = 120,
                    y = 310,
                    sliderWidth = 300,
                    applyRequired = true,
                },
            },
        },

        AdvancedTab = {
            type = MenuItemTypes.TabGroup,
            x = 50,
            y = 60,
            width = 924,
            height = 576,
            visible = false,
            align = MenuAlign.Right,
            items = {
                HealthRegen = {
                    type = MenuItemTypes.Checkbox,
                    text = "Health Regeneration",
                    desc = "Enable health regeneration",
                    option = "CustomHealthRegen",
                    valueOn = true,
                    valueOff = false,
                    x = 120,
                    y = 160,
                    applyRequired = true,
                },
                ArmorRegen = {
                    type = MenuItemTypes.Checkbox,
                    text = "Armor Regeneration",
                    desc = "Enable armor regeneration",
                    option = "CustomArmorRegen",
                    valueOn = true,
                    valueOff = false,
                    x = 120,
                    y = 210,
                    applyRequired = true,
                },
                CarryOver = {
                    type = MenuItemTypes.Checkbox,
                    text = "Carry Over Items",
                    desc = "Carry health, armor and ammo between levels",
                    option = "CustomCarryOver",
                    valueOn = true,
                    valueOff = false,
                    x = 120,
                    y = 260,
                    applyRequired = true,
                },
                InfiniteAmmo = {
                    type = MenuItemTypes.Checkbox,
                    text = "Infinite Ammo",
                    desc = "Enable infinite ammo",
                    option = "CustomInfiniteAmmo",
                    valueOn = true,
                    valueOff = false,
                    x = 120,
                    y = 310,
                    applyRequired = true,
                },
            },
        },

        GeneralSettings = {
            text = "General",
            desc = "Basic Difficulty Settings",
            x = 140,
            y = 86,
            align = MenuAlign.Center,
            action = [[
                PMENU.SetBorderSize('CustomDiffBorder', 924, 410);
                PMENU.SetScrollerHeight('CustomDiffScroller',440);
                local i, o = next(PainMenu.currScreen.items.AdvancedTab.items, nil)
                while i do
                    PMENU.SetItemVisibility(i, false)
                    i, o = next(PainMenu.currScreen.items.AdvancedTab.items, i)
                end
                PMENU.SetItemVisibility('AdvancedTab', false)
                i, o = next(PainMenu.currScreen.items.GeneralTab.items, nil)
                while i do
                    PMENU.SetItemVisibility(i, true)
                    i, o = next(PainMenu.currScreen.items.GeneralTab.items, i)
                end
                PMENU.SetItemVisibility('GeneralTab', true)
            ]],
            sndAccept = "menu/magicboard/card-take",
            fontBigSize = 26,
            useItemBG = false,
        },

        AdvancedSettings = {
            text = "Advanced",
            desc = "Advanced Settings",
            x = 320,
            y = 86,
            align = MenuAlign.Center,
            action = [[
                PMENU.SetBorderSize('CustomDiffBorder', 924, 524);
                PMENU.SetScrollerHeight('CustomDiffScroller',546);
                local i, o = next(PainMenu.currScreen.items.GeneralTab.items, nil)
                while i do
                    PMENU.SetItemVisibility(i, false)
                    i, o = next(PainMenu.currScreen.items.GeneralTab.items, i)
                end
                PMENU.SetItemVisibility('GeneralTab', false)
                i, o = next(PainMenu.currScreen.items.AdvancedTab.items, nil)
                while i do
                    PMENU.SetItemVisibility(i, true)
                    i, o = next(PainMenu.currScreen.items.AdvancedTab.items, i)
                end
                PMENU.SetItemVisibility('AdvancedTab', true)
            ]],
            sndAccept = "menu/magicboard/card-take",
            fontBigSize = 26,
            useItemBG = false,
        },

        ResetButton = {
            type = MenuItemTypes.TextButton,
            text = "Reset Settings",
            desc = "Reset all settings to default",
            x = -1,
            y = 660,
            action = "CustomDifficultyMenu:ResetSettings()",
        },

        ApplyButton = {
            type = MenuItemTypes.TextButton,
            text = "Apply Settings",
            desc = "Apply custom difficulty settings",
			x	 = 952,
			y	 = 660,
            align = MenuAlign.Right,
            action = "CustomDifficultyMenu:ApplySettings() RPGMenu:ActivateScreen()",
        },
    }
}

--============================================================================
-- Functions
--============================================================================

function CustomDifficultyMenu:Init()
    if not Cfg.CustomPlayerDamage then
        Cfg.CustomPlayerDamage = 1
        Cfg.CustomAmmoMultiplier = 1
        Cfg.CustomEnemyDamage = 1
        Cfg.CustomPlayerSpeed = 1
        Cfg.CustomHealthRegen = false
        Cfg.CustomArmorRegen = false
        Cfg.CustomCarryOver = false
        Cfg.CustomInfiniteAmmo = false
        Cfg:Save()
    end
end

function CustomDifficultyMenu:ResetSettings()
    Cfg.CustomPlayerDamage = 1
    Cfg.CustomAmmoMultiplier = 1
    Cfg.CustomEnemyDamage = 1
    Cfg.CustomPlayerSpeed = 1
    Cfg.CustomHealthRegen = false
    Cfg.CustomArmorRegen = false
    Cfg.CustomCarryOver = false
    Cfg.CustomInfiniteAmmo = false
    Cfg:Save()
    PainMenu:ApplySettings(true)
    PainMenu:ActivateScreen(CustomDifficultyMenu)
end

function CustomDifficultyMenu:ApplySettings()
    PainMenu:ApplySettings(true)
    Cfg:Save()
    PainMenu:ShowInfo("Custom difficulty settings applied successfully!", "PainMenu:ActivateScreen(NewGameMenu)")
end

function CustomDifficultyMenu:ApplyToGame()
    if Game.Difficulty == Difficulties.CustomDiff then
        Game.PlayerDamageFactor = Cfg.CustomPlayerDamage
        Game.AmmoFoundFactor = Cfg.CustomAmmoMultiplier
        Game.HealthRegen = Cfg.CustomHealthRegen
        Game.ArmorRegen = Cfg.CustomArmorRegen
        Game.InfiniteAmmo = Cfg.CustomInfiniteAmmo
        Game.CarryOverEnabled = Cfg.CustomCarryOver

        if Player then
            local speed, jump = GetPlayerSpeed()
            SetPlayerSpeed(speed * Cfg.CustomPlayerSpeed, jump)
        end
    end
end

function CustomDifficultyMenu:HandleCarryOver()
    if Game.Difficulty == Difficulties.CustomDiff and Game.CarryOverEnabled then
        Game.LastPlayerHP = Player.Health
        Game.LastPlayerArmor = Player.Armor
        Game.LastPlayerArmorType = Player.ArmorType
        Game.LastPlayerSouls = Player.SoulsCount
        Game._LastAmmo = Clone(Player.Ammo)
    else
        Game.LastPlayerHP = nil
        Game.LastPlayerArmor = nil
        Game.LastPlayerArmorType = nil
        Game.LastPlayerSouls = nil
        Game._LastAmmo = nil
    end
end

function CustomDifficultyMenu:OnLevelEnd()
    self:HandleCarryOver()
end

function CustomDifficultyMenu:OnLevelStart()
    if Game.Difficulty == Difficulties.CustomDiff then
        self:ApplyToGame()
        if Game.CarryOverEnabled and Game.LastPlayerHP and Player then
            Player.Health = Game.LastPlayerHP
            if Game.LastPlayerArmor then
                Player.Armor = Game.LastPlayerArmor
                Player.ArmorType = Game.LastPlayerArmorType or 0
                Player.ArmorRescueFactor = GetArmorRescueFactor(Player.ArmorType)
            end
            if Game.LastPlayerSouls then
                Player.SoulsCount = Game.LastPlayerSouls
            end
        end
    end
end