--============================================================================
-- RPG Menu
--============================================================================

RPGMenu = {
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
        -- ========== CHARACTER TAB ==========
        CharacterTab = {
            type = MenuItemTypes.TabGroup,
            x = 50,
            y = 60,
            width = 924,
            height = 576,
            visible = true,
            align = MenuAlign.Left,
            items = {
                LevelDisplay = {
                    type = MenuItemTypes.StaticText,
                    text = "Level: 0",
                    x = 120,
                    y = 160,
                },
                XPDisplay = {
                    type = MenuItemTypes.StaticText,
                    text = "XP: 0 / 0",
                    x = 120,
                    y = 210,
                },
                PointsDisplay = {
                    type = MenuItemTypes.StaticText,
                    text = "Skill Points: 0",
                    x = 120,
                    y = 260,
                },
            },
        },

        -- ========== STATS TAB ==========
        StatsTab = {
            type = MenuItemTypes.TabGroup,
            x = 50,
            y = 60,
            width = 924,
            height = 576,
            visible = false,
            align = MenuAlign.Right,
            items = {
                Strength = {
                    type = MenuItemTypes.TextButton,
                    text = "Strength +",
                    desc = "Increases base damage",
                    x = 120,
                    y = 160,
                    action = "RPGMenu:UpgradeStat('Strength')",
                },
                Agility = {
                    type = MenuItemTypes.TextButton,
                    text = "Agility +",
                    desc = "Improves weapon handling and reloads",
                    x = 120,
                    y = 210,
                    action = "RPGMenu:UpgradeStat('Agility')",
                },
                Vitality = {
                    type = MenuItemTypes.TextButton,
                    text = "Vitality +",
                    desc = "Increases max health",
                    x = 120,
                    y = 260,
                    action = "RPGMenu:UpgradeStat('Vitality')",
                },
                Luck = {
                    type = MenuItemTypes.TextButton,
                    text = "Luck +",
                    desc = "Improves loot quality and critical chance",
                    x = 120,
                    y = 310,
                    action = "RPGMenu:UpgradeStat('Luck')",
                },
            },
        },

        -- ========== TAB SWITCHERS ==========
        CharacterButton = {
            text = "Character",
            desc = "View character stats",
            x = 140,
            y = 86,
            align = MenuAlign.Center,
            action = "RPGMenu:SwitchToTab('CharacterTab')",
            sndAccept = "menu/magicboard/card-take",
            fontBigSize = 26,
            useItemBG = false,
        },

        StatsButton = {
            text = "Stats",
            desc = "Upgrade your stats",
            x = 320,
            y = 86,
            align = MenuAlign.Center,
            action = "RPGMenu:SwitchToTab('StatsTab')",
            sndAccept = "menu/magicboard/card-take",
            fontBigSize = 26,
            useItemBG = false,
        },

        -- ========== BUTTONS ==========
        StartGameButton = {
            type = MenuItemTypes.TextButton,
            text = "Start Game",
            desc = "Begin your journey",
			x = 952,
			y = 660,
            align = MenuAlign.Right,
            action = "RPGMenu:StartGame()",
        },

        BackButton = {
            text = TXT.Menu.Back,
            desc = TXT.MenuDesc.Back,
            x = 72,
            y = 660,
            fontBigSize = 36,
            align = MenuAlign.Left,
            useItemBG = false,
            textColor = R3D.RGBA(255, 255, 255, 255),
            descColor = R3D.RGB(255, 255, 255),
            sndAccept = "menu/menu/back-accept",
            sndLightOn = "menu/menu/back-light-on",
            action = "PainMenu:ActivateScreen(NewGameMenu)",
        },
    }
}

--============================================================================
-- Functions
--============================================================================

function RPGMenu:Init()
    if not Game.RPGSystem then
        Game.RPGSystem = {
            Enabled = true,
            PlayerLevel = 1, 
            PlayerXP = 0,
            XPToNextLevel = 300,      -- уровень 1 → 2 требует 300 XP
            SkillPoints = 5,
            Stats = {
                Strength = 1,
                Agility = 1,
                Vitality = 1,
                Luck = 1,
            },
            ActiveSkills = {},
        }
    end
end

function Game:ApplyRPGStats()
    if not self.RPGSystem or not self.RPGSystem.Enabled then return end
    local stats = self.RPGSystem.Stats

    -- Сила → урон
    self.DamageFactor = 1 + (stats.Strength - 1) * 0.2

    -- Ловкость → перезарядка и урон
    self.ReloadSpeedFactor = math.max(0.4, 1.0 - (stats.Agility - 1) * 0.1)

    -- Выносливость → здоровье
    self.HealthCapacity = 100 + (stats.Vitality - 1) * 25

    -- Удача → шанс дропа, крит
    -- (можно добавить позже)

    -- Применить текущее здоровье (если игрок существует)
    if Player then
        -- Не уменьшать здоровье, если уже больше
        if Player.Health <= self.HealthCapacity then
            Player.Health = math.min(Player.Health, self.HealthCapacity)
        end
    end

    -- Баффы из активных скиллов
    self.Vampirism = self.RPGSystem.ActiveSkills["Vampirism"] or false
    self.HealthRegen1 = self.RPGSystem.ActiveSkills["HealthRegen"] or false
    self.ArmorRegen1 = self.RPGSystem.ActiveSkills["ArmorRegen"] or false
    self.AmmoBoost = self.RPGSystem.ActiveSkills["AmmoBoost"] or false
    self.SoulCatchDistance1 = self.RPGSystem.ActiveSkills["SoulCatchDistance"] and 5 or 0

    -- Обновить AmmoFoundFactor в зависимости от AmmoBoost
    if self.AmmoBoost then
        self.AmmoFoundFactor = math.max(self.AmmoFoundFactor, 0.8)
    end
end

function RPGMenu:SwitchToTab(tabName)
    -- Скрыть CharacterTab
    PainMenu:HideTabGroup(self.items.CharacterTab, 'CharacterTab')
    -- Скрыть StatsTab
    PainMenu:HideTabGroup(self.items.StatsTab, 'StatsTab')

    -- Показать нужную вкладку
    if tabName == "CharacterTab" then
        PainMenu:ShowTabGroup(self.items.CharacterTab, 'CharacterTab')
    elseif tabName == "StatsTab" then
        PainMenu:ShowTabGroup(self.items.StatsTab, 'StatsTab')
    end
end

function RPGMenu:RefreshDisplays()
    if not Game.RPGSystem then
        self._levelText = "Level: 0"
        self._xpText = "XP: 0 / 0"
        self._pointsText = "Skill Points: 0"
    else
        local sys = Game.RPGSystem
        self._levelText = "Level: " .. sys.PlayerLevel
        self._xpText = "XP: " .. sys.PlayerXP .. " / " .. sys.XPToNextLevel
        self._pointsText = "Skill Points: " .. sys.SkillPoints
    end
end

function RPGMenu:Draw()
    if not Game.RPGSystem then return end
    local sys = Game.RPGSystem

    local levelText = "Level: " .. sys.PlayerLevel
    local xpText = "XP: " .. sys.PlayerXP .. " / " .. sys.XPToNextLevel
    local pointsText = "Skill Points: " .. sys.SkillPoints

    local screenW, screenH = R3D.ScreenSize()
    local baseX = 120
    local baseY = 100
    local lineHeight = 30

    -- Устанавливаем шрифт
    HUD.SetFont(self.fontBig, self.fontBigSize)

    -- Рисуем текст напрямую через HUD
    HUD.PrintXY(baseX, baseY, levelText, self.fontBig, self.textColor[1], self.textColor[2], self.textColor[3], self.fontBigSize)
    HUD.PrintXY(baseX, baseY + lineHeight, xpText, self.fontBig, self.textColor[1], self.textColor[2], self.textColor[3], self.fontBigSize)
    HUD.PrintXY(baseX, baseY + lineHeight * 2, pointsText, self.fontBig, self.textColor[1], self.textColor[2], self.textColor[3], self.fontBigSize)
end

function RPGMenu:ActivateScreen()
    self:Init()
    self:RefreshDisplays()
    PainMenu:ActivateScreen(RPGMenu)
end

function RPGMenu:UpgradeStat(statName)
    if not Game.RPGSystem then return end
    local sys = Game.RPGSystem
    if sys.SkillPoints < 1 then
        PainMenu:ShowInfo("Not enough skill points!", "PainMenu:ActivateScreen(RPGMenu); RPGMenu:SwitchToTab('CharacterTab')")
        return
    end
    local cost = sys.Stats[statName] * 2
    if sys.SkillPoints < cost then
        PainMenu:ShowInfo("Need " .. cost .. " points to upgrade " .. statName .. ".", "PainMenu:ActivateScreen(RPGMenu); RPGMenu:SwitchToTab('CharacterTab')")
        return
    end
    sys.Stats[statName] = sys.Stats[statName] + 1
    sys.SkillPoints = sys.SkillPoints - cost
    Game:ApplyRPGStats()
    PainMenu:ShowInfo(
        statName .. " upgraded!",
        "PainMenu:ActivateScreen(RPGMenu); RPGMenu:SwitchToTab('CharacterTab')"
    )
end

function RPGMenu:StartGame()
    if not Game.RPGSystem then return end
    Game:ApplyRPGStats()
    PainMenu:SelectDifficulty(Difficulties.CustomDiff)
end