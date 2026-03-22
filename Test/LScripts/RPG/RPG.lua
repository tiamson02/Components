RPGSystem = {
    Enabled = true,
}

-- Дерево навыков по умолчанию
local DefaultSkillTree = {
    nodes = {
        -- ========== ARMOR BRANCH (Intelligence) ==========
        [1] = { 
            id = 1, 
            name = "Reinforced Armor", 
            desc = "+10% armor effectiveness", 
            cost = 1, 
            parents = {}, 
            unlocked = false, 
            stat = "Intelligence", 
            effect = "ArmorRescueFactor",
            value = 0.1,
            reqAttr = { Intelligence = 2 }
        },
        [2] = { 
            id = 2, 
            name = "Ceramic Plating", 
            desc = "+15% armor effectiveness", 
            cost = 2, 
            parents = {1}, 
            unlocked = false, 
            stat = "Intelligence", 
            effect = "ArmorRescueFactor",
            value = 0.15,
            reqAttr = { Intelligence = 3 }
        },
        [3] = { 
            id = 3, 
            name = "Energy Shield", 
            desc = "+25% armor effectiveness", 
            cost = 3, 
            parents = {2}, 
            unlocked = false, 
            stat = "Intelligence", 
            effect = "ArmorRescueFactor",
            value = 0.25,
            reqAttr = { Intelligence = 4 }
        },
        
        -- ========== AMMO BRANCH (Intelligence) ==========
        [4] = { 
            id = 4, 
            name = "Ammo Conservation", 
            desc = "+15% ammo found", 
            cost = 1, 
            parents = {}, 
            unlocked = false, 
            stat = "Intelligence", 
            effect = "AmmoFoundFactor",
            value = 0.15,
            reqAttr = { Intelligence = 2 }
        },
        [5] = { 
            id = 5, 
            name = "Scavenger", 
            desc = "+25% ammo found", 
            cost = 2, 
            parents = {4}, 
            unlocked = false, 
            stat = "Intelligence", 
            effect = "AmmoFoundFactor",
            value = 0.25,
            reqAttr = { Intelligence = 3 }
        },
        [6] = { 
            id = 6, 
            name = "Military Stockpile", 
            desc = "+40% ammo found", 
            cost = 3, 
            parents = {5}, 
            unlocked = false, 
            stat = "Intelligence", 
            effect = "AmmoFoundFactor",
            value = 0.4,
            reqAttr = { Intelligence = 4 }
        },
        
        -- ========== HEALTH BRANCH (Strength) ==========
        [7] = { 
            id = 7, 
            name = "Combat Experience", 
            desc = "+5% damage", 
            cost = 1, 
            parents = {}, 
            unlocked = false, 
            stat = "Strength", 
            effect = "DamageFactor",
            value = 0.05,
            reqAttr = { Strength = 2 }
        },
        [8] = { 
            id = 8, 
            name = "Vitality", 
            desc = "+20 HP", 
            cost = 1, 
            parents = {7}, 
            unlocked = false, 
            stat = "Strength", 
            effect = "MaxHealth",
            value = 20,
            reqAttr = { Strength = 3 }
        },
        [9] = { 
            id = 9, 
            name = "Colossus", 
            desc = "+10% HP", 
            cost = 2, 
            parents = {8}, 
            unlocked = false, 
            stat = "Strength", 
            effect = "MaxHealth",
            value = 0.1,
            reqAttr = { Strength = 4 }
        },
        [10] = { 
            id = 10, 
            name = "Regeneration", 
            desc = "Slowly regenerates health", 
            cost = 2, 
            parents = {8}, 
            unlocked = false, 
            stat = "Strength", 
            effect = "HealthRegen",
            value = true,
            reqAttr = { Strength = 5 }
        },
        [11] = { 
            id = 11, 
            name = "Iron Body", 
            desc = "+50 HP", 
            cost = 3, 
            parents = {9, 10}, 
            unlocked = false, 
            stat = "Strength", 
            effect = "MaxHealth",
            value = 50,
            reqAttr = { Strength = 5 }
        },
        
        -- ========== SOUL BRANCH (Agility) ==========
        [12] = { 
            id = 12, 
            name = "Soul Catcher", 
            desc = "+3m soul collection range", 
            cost = 1, 
            parents = {}, 
            unlocked = false, 
            stat = "Agility", 
            effect = "SoulCatchDistance",
            value = 3,
            reqAttr = { Agility = 2 }
        },
        [13] = { 
            id = 13, 
            name = "Soul Keeper", 
            desc = "Souls stay +50% longer", 
            cost = 2, 
            parents = {12}, 
            unlocked = false, 
            stat = "Agility", 
            effect = "SoulStayFactor",
            value = 0.5,
            reqAttr = { Agility = 3 }
        },
        [14] = { 
            id = 14, 
            name = "Soul Power", 
            desc = "Souls give +50% more health", 
            cost = 2, 
            parents = {13}, 
            unlocked = false, 
            stat = "Agility", 
            effect = "SoulHealthFactor",
            value = 0.5,
            reqAttr = { Agility = 4 }
        },
        [15] = { 
            id = 15, 
            name = "Quick Hands", 
            desc = "-10% reload time", 
            cost = 1, 
            parents = {}, 
            unlocked = false, 
            stat = "Agility", 
            effect = "ReloadSpeedFactor",
            value = 0.1,
            reqAttr = { Agility = 2 }
        },
        [16] = { 
            id = 16, 
            name = "Sprinter", 
            desc = "+15% movement speed", 
            cost = 1, 
            parents = {15}, 
            unlocked = false, 
            stat = "Agility", 
            effect = "SpeedFactor",
            value = 0.15,
            reqAttr = { Agility = 3 }
        },
    }
}

-- Инициализация RPG-системы
function RPGSystem:Init()
    --CONSOLE.AddMessage("RPG-system is active!")

    -- Установим значения по умолчанию
    self.PlayerLevel = 1
    self.PlayerXP = 0
    self.XPToNextLevel = 100
    self.SkillPoints = 0
    self.Stats = { Strength = 1, Agility = 1, Intelligence = 1 }
    self.ActiveSkills = {}
    self.SkillTree = Clone(DefaultSkillTree)

    -- Загружаем данные из профиля
    self:LoadFromProfile()

    -- Применяем статы если игрок уже существует
    if Player then
        self:ApplyStats()
    end
    
    --CONSOLE.AddMessage("RPG: Level " .. self.PlayerLevel .. ", XP: " .. self.PlayerXP .. "/" .. self.XPToNextLevel)
end

-- Загрузка из профиля
function RPGSystem:LoadFromProfile()
    local profile = Game:GetProfile()
    if profile then
        -- Инициализируем секцию RPG в профиле если её нет
        if not profile.RPG then
            profile.RPG = {}
        end
        
        -- Загружаем данные или используем значения по умолчанию
        self.PlayerLevel = profile.RPG.PlayerLevel or 1
        self.PlayerXP = profile.RPG.PlayerXP or 0
        self.XPToNextLevel = profile.RPG.XPToNextLevel or 100
        self.SkillPoints = profile.RPG.SkillPoints or 0
        self.Stats = profile.RPG.Stats or { Strength = 1, Agility = 1, Intelligence = 1 }
        self.ActiveSkills = profile.RPG.ActiveSkills or {}
        
        -- Загружаем дерево навыков
        if profile.RPG.SkillTree then
            self.SkillTree = profile.RPG.SkillTree
        else
            self.SkillTree = Clone(DefaultSkillTree)
        end
        
        --CONSOLE.AddMessage("RPG: The data was uploaded from the profile")
    else
        CONSOLE.AddMessage("RPG: No profile found, using default values")
    end
end

-- Сохранение в профиль
function RPGSystem:SaveToProfile()
    local profile = Game:GetProfile()
    if profile then
        -- Создаем или обновляем секцию RPG
        profile.RPG = {
            PlayerLevel = self.PlayerLevel,
            PlayerXP = self.PlayerXP,
            XPToNextLevel = self.XPToNextLevel,
            SkillPoints = self.SkillPoints,
            Stats = Clone(self.Stats),
            ActiveSkills = Clone(self.ActiveSkills or {}),
            SkillTree = Clone(self.SkillTree)
        }
        
        -- Сохраняем профиль
        if PlayerProfile and Cfg.CurrentProfile then
            PlayerProfile:Save(Cfg.CurrentProfile, profile)
            CONSOLE.AddMessage("RPG: The progress is saved in the profile")
        else
            CONSOLE.AddMessage("RPG: Save error - PlayerProfile or Cfg.CurrentProfile not found")
        end
    else
        CONSOLE.AddMessage("RPG: Saving error - profile not found")
    end
end

-- Добавление XP
function RPGSystem:AddXP(amount)
    if not self.Enabled then 
        return 
    end
    
    if not Player or Player._died then
        return 
    end

    self.PlayerXP = (self.PlayerXP or 0) + amount

    -- Проверка на повышение уровня
    local levelUps = 0
    while self.PlayerXP >= (self.XPToNextLevel or 100) do
        self:LevelUp()
        levelUps = levelUps + 1
        if levelUps > 10 then
            --CONSOLE.AddMessage("RPG: Too many levels at a time, stop")
            break
        end
    end

    -- Сохраняем после каждого добавления XP
    self:SaveToProfile()
end

-- Повышение уровня
function RPGSystem:LevelUp()
    self.PlayerXP = self.PlayerXP - self.XPToNextLevel
    self.PlayerLevel = (self.PlayerLevel or 1) + 1
    self.SkillPoints = (self.SkillPoints or 0) + 3
    self.XPToNextLevel = math.floor((self.XPToNextLevel or 100) * 1.5)
    
    self:ApplyStats()
    -- Сохраняем после повышения уровня
    self:SaveToProfile()
end

-- Применение статов к игроку
function RPGSystem:ApplyStats()
    if not Player then 
        return 
    end

    -- Сбрасываем факторы перед применением
    Player.DamageFactor = 1.0
    Player.ReloadSpeedFactor = 1.0
    Player.SpeedFactor = 1.0
    Player.ArmorRescueFactor = 0.5
    
    -- Сбрасываем фактор поднимаемых патронов (будет изменен Интеллектом)
    Game.AmmoFoundFactor = 0.6  -- базовое значение из Game:ResetSilverCardsVars()

    -- Применяем базовые статы    
    -- Увеличиваем максимальное количество патронов в зависимости от Силы
    if Player.Ammo then
        -- Сохраняем текущее количество патронов в процентах
        local ammoPercent = {}
        for ammoType, count in pairs(Player.Ammo) do
            local maxAmmo = CPlayer.s_SubClass.MaxAmmo[ammoType] or 0
            if maxAmmo > 0 then
                ammoPercent[ammoType] = count / maxAmmo
            end
        end
        
        -- Увеличиваем максимальный лимит патронов: +10% за каждый уровень Силы сверх 1
        local ammoBonus = 1.0 + (self.Stats.Strength - 1) * 0.1
        
        for ammoType, maxAmount in pairs(CPlayer.s_SubClass.MaxAmmo) do
            local newMax = math.floor(maxAmount * ammoBonus)
            CPlayer.s_SubClass.MaxAmmo[ammoType] = newMax
            
            -- Восстанавливаем процентное соотношение патронов
            if Player.Ammo[ammoType] and ammoPercent[ammoType] then
                Player.Ammo[ammoType] = math.floor(newMax * ammoPercent[ammoType])
            end
        end
        
        -- Для 666 патронов (карта) тоже применяем бонус
        if CPlayer.s_SubClass._666Ammo then
            for ammoType, amount in pairs(CPlayer.s_SubClass._666Ammo) do
                CPlayer.s_SubClass._666Ammo[ammoType] = math.floor(666 * ammoBonus)
            end
        end
        
        --CONSOLE.AddMessage("RPG: Max ammo increased by " .. string.format("%d%%", (ammoBonus - 1) * 100))
    end

    -- Интеллект: +20% к эффективности брони за уровень, +15% к фактору патронов за уровень
    Player.ArmorRescueFactor = 0.5 * (1 + (self.Stats.Intelligence - 1) * 0.2)
    
    -- Увеличиваем количество поднимаемых патронов
    Game.AmmoFoundFactor = 0.6 * (1 + (self.Stats.Intelligence - 1) * 0.15)
    if Game.AmmoFoundFactor > 2.0 then Game.AmmoFoundFactor = 2.0 end -- кап

    -- Ловкость: пока ничего не делает, резервируем
    -- Player.ReloadSpeedFactor = math.max(0.3, 1.0 - (self.Stats.Agility - 1) * 0.05)
    -- Player.SpeedFactor = 1.0 + (self.Stats.Agility - 1) * 0.05

    -- Применяем навыки из дерева навыков
    if self.SkillTree and self.SkillTree.nodes then
        for _, node in pairs(self.SkillTree.nodes) do
            if node.unlocked then
                local skill = SkillTreeData[node.id]
                if skill then
                    if skill.effect == "ArmorRescueFactor" then
                        Player.ArmorRescueFactor = Player.ArmorRescueFactor * (1 + skill.value)
                    elseif skill.effect == "AmmoFoundFactor" then
                        Game.AmmoFoundFactor = Game.AmmoFoundFactor * (1 + skill.value)
                    elseif skill.effect == "MaxHealth" then
                        Player.MaxHealth = Player.MaxHealth + skill.value
                        if Player.Health > Player.MaxHealth then
                            Player.Health = Player.MaxHealth
                        end
                    elseif skill.effect == "HealthRegen" and skill.value then
                        Game.HealthRegen = true
                    elseif skill.effect == "SoulCatchDistance" then
                        Game.SoulCatchDistance = (Game.SoulCatchDistance or 0) + skill.value
                    elseif skill.effect == "SoulStayFactor" then
                        Game.SoulStayFactor = Game.SoulStayFactor * (1 + skill.value)
                    elseif skill.effect == "SoulHealthFactor" then
                        Game.SoulHealthFactor = Game.SoulHealthFactor * (1 + skill.value)
                    end
                end
            end
        end
    end

    -- Клиппинг значений
    Player.ReloadSpeedFactor = math.max(0.3, math.min(2.0, Player.ReloadSpeedFactor))
    Player.SpeedFactor = math.max(0.5, math.min(2.0, Player.SpeedFactor))
    Player.ArmorRescueFactor = math.max(0.1, math.min(1.0, Player.ArmorRescueFactor))
    Player.DamageFactor = math.max(0.5, math.min(3.0, Player.DamageFactor))
    Game.AmmoFoundFactor = math.max(0.3, math.min(1.0, Game.AmmoFoundFactor))
    
    -- Применяем скорость
    if Player.PlayerSpeed then
        local baseSpeed, baseJump = GetPlayerSpeed()
        SetPlayerSpeed(Player.PlayerSpeed * Player.SpeedFactor, baseJump / Player.SpeedFactor)
    end
    
    -- Обновляем максимальные значения патронов в инвентаре игрока
    if Player.CheckMaxAmmo then
        Player:CheckMaxAmmo()
    end
    
    CONSOLE.AddMessage("RPG: Stats applied - Level " .. (self.PlayerLevel or 1))
    CONSOLE.AddMessage(string.format("RPG: Strength=%d (+%d%% max ammo), Int=%d (+%d%% armor, +%d%% ammo found)", 
        self.Stats.Strength or 1,
        ((self.Stats.Strength or 1) - 1) * 10,
        self.Stats.Intelligence or 1,
        ((self.Stats.Intelligence or 1) - 1) * 20,
        ((self.Stats.Intelligence or 1) - 1) * 15))
end

-- Увеличение стата
function RPGSystem:IncreaseStat(statName)
    if not self.Enabled then 
        return false 
    end
    
    if not self.SkillPoints or self.SkillPoints <= 0 then
        return false
    end
    
    if not self.Stats then
        self.Stats = { Strength = 1, Agility = 1, Intelligence = 1 }
    end
    
    local currentValue = self.Stats[statName] or 1
    local maxStat = 10 -- максимальный уровень (как в твоем примере)
    
    if currentValue >= maxStat then
        --CONSOLE.AddMessage("RPG: " .. statName .. " already at maximum level (" .. maxStat .. ")")
        return false
    end
    
    -- Увеличиваем стат
    self.Stats[statName] = currentValue + 1
    self.SkillPoints = self.SkillPoints - 1
    
    -- Применяем изменения
    self:ApplyStats()
    self:SaveToProfile()
    
    --CONSOLE.AddMessage("=== RPG STAT INCREASED ===")
    --CONSOLE.AddMessage(statName .. ": " .. currentValue .. " → " .. self.Stats[statName])
    --CONSOLE.AddMessage("Skill points left: " .. self.SkillPoints)
    
    -- Обновляем меню если оно открыто
    if PainMenu and PainMenu.currScreen == ProfileMenu1 then
        if __UpdateStatButtons then
            __UpdateStatButtons()
        end
        -- Обновляем значения статов
        PMENU.SetItemText("StatsStrengthValue", tostring(self.Stats.Strength or 1))
        PMENU.SetItemText("StatsAgilityValue", tostring(self.Stats.Agility or 1))
        PMENU.SetItemText("StatsIntelligenceValue", tostring(self.Stats.Intelligence or 1))
        PMENU.SetItemText("StatsSkillPointsValue", tostring(self.SkillPoints or 0))
    end
    
    return true
end

-- Применение статов к игроку
function RPGSystem:ApplyStats()
    if not Player then 
        return 
    end

    -- Сбрасываем факторы перед применением
    Player.DamageFactor = 1.0
    Player.ReloadSpeedFactor = 1.0
    Player.SpeedFactor = 1.0
    Player.ArmorRescueFactor = 0.5
    
    -- Сбрасываем фактор поднимаемых патронов
    Game.AmmoFoundFactor = 0.6

    -- СИЛА: увеличиваем максимальное количество патронов
    local strengthLevel = math.min(self.Stats.Strength or 1, 10)
    local t = (strengthLevel - 1) / 9

    if Player then
        -- Инициализируем таблицу если нужно
        if not Player.MaxAmmoTable then
            Player.MaxAmmoTable = {}
            for k, v in pairs(CPlayer.s_SubClass.MaxAmmo) do
                Player.MaxAmmoTable[k] = v
            end
        end
        
        -- Базовые значения (Strength = 1)
        local baseMaxAmmo = {
            Shotgun = 45, 
            IceBullets = 25, 
            Stakes = 45, 
            Grenades = 25,
            MiniGun = 150, 
            Shurikens = 80, 
            Electro = 150, 
            Rifle = 75,
            FlameThrower = 80, 
            Bolt = 100, 
            HeaterBomb = 60
        }
        
        local maxAmmoAt5 = {
            Shotgun = 75, 
            IceBullets = 50, 
            Stakes = 75, 
            Grenades = 50,
            MiniGun = 350, 
            Shurikens = 200, 
            Electro = 250, 
            Rifle = 175,
            FlameThrower = 200, 
            Bolt = 300, 
            HeaterBomb = 120
        }

        local maxAmmoAt10 = {
            Shotgun = 250, 
            IceBullets = 150, 
            Stakes = 250, 
            Grenades = 250,
            MiniGun = 850, 
            Shurikens = 725, 
            Electro = 950, 
            Rifle = 805,
            FlameThrower = 700, 
            Bolt =800, 
            HeaterBomb = 600
        }
        
        local strengthLevel = math.min(self.Stats.Strength or 1, 10)
        local t = (strengthLevel - 1) / 9
        
        for ammoType, baseValue in pairs(baseMaxAmmo) do
            local targetValue = maxAmmoAt5[ammoType] or baseValue
            local targetValue1 = maxAmmoAt10[ammoType] or baseValue
            Player.MaxAmmoTable[ammoType] = math.floor(baseValue + (targetValue - baseValue) * t)
            Player.MaxAmmoTable[ammoType] = math.floor(baseValue + (targetValue1 - baseValue) * t)
        end
        
    end

    -- Интеллект: +20% к эффективности брони за уровень
    Player.ArmorRescueFactor = 0.5 * (1 + (self.Stats.Intelligence - 1) * 0.2)
    
    -- Интеллект: +15% к фактору поднимаемых патронов за уровень
    Game.AmmoFoundFactor = 0.6 * (1 + (self.Stats.Intelligence - 1) * 0.15)
    if Game.AmmoFoundFactor > 2.0 then Game.AmmoFoundFactor = 2.0 end

    -- Применяем навыки из дерева навыков
    if self.SkillTree and self.SkillTree.nodes then
        for _, node in pairs(self.SkillTree.nodes) do
            if node.unlocked then
                if node.stat == "Strength" then
                    if node.id == 1 then -- Боевой опыт
                        Player.DamageFactor = Player.DamageFactor * (1.0 + (node.value or 0.05))
                    elseif node.id == 2 then -- Живучесть
                        Player.InitialHealth = Player.InitialHealth + (node.value or 20)
                    elseif node.id == 3 then -- Колосс
                        Player.InitialHealth = Player.InitialHealth * (1.0 + (node.value or 0.1))
                    end
                elseif node.stat == "Agility" then
                    if node.id == 4 then -- Ловкие руки
                        Player.ReloadSpeedFactor = Player.ReloadSpeedFactor * (1.0 - (node.value or 0.1))
                    elseif node.id == 5 then -- Спринтер
                        Player.SpeedFactor = Player.SpeedFactor * (1.0 + (node.value or 0.15))
                    end
                elseif node.stat == "Intelligence" then
                    if node.id == 7 then -- Броня
                        Player.ArmorRescueFactor = Player.ArmorRescueFactor * (1.0 + (node.value or 0.15))
                    elseif node.id == 9 then -- Инженер
                        Player.ArmorRescueFactor = Player.ArmorRescueFactor * (1.0 + (node.value or 0.25))
                    end
                end
            end
        end
    end

    -- Клиппинг значений
    Player.ReloadSpeedFactor = math.max(0.3, math.min(2.0, Player.ReloadSpeedFactor))
    Player.SpeedFactor = math.max(0.5, math.min(2.0, Player.SpeedFactor))
    Player.ArmorRescueFactor = math.max(0.1, math.min(1.0, Player.ArmorRescueFactor))
    Player.DamageFactor = math.max(0.5, math.min(3.0, Player.DamageFactor))
    Game.AmmoFoundFactor = math.max(0.3, math.min(2.0, Game.AmmoFoundFactor))
    
    -- Применяем скорость
    if Player.PlayerSpeed then
        local baseSpeed, baseJump = GetPlayerSpeed()
        SetPlayerSpeed(Player.PlayerSpeed * Player.SpeedFactor, baseJump / Player.SpeedFactor)
    end
    
    CONSOLE.AddMessage("RPG: Stats applied - Level " .. (self.PlayerLevel or 1))
    CONSOLE.AddMessage(string.format("RPG: Strength=%d (Max Ammo: +%d%%), Int=%d (Armor: +%d%%, Ammo Found: +%d%%)", 
        self.Stats.Strength or 1,
        ((self.Stats.Strength or 1) - 1) * 10,
        self.Stats.Intelligence or 1,
        ((self.Stats.Intelligence or 1) - 1) * 20,
        ((self.Stats.Intelligence or 1) - 1) * 15))
end

-- Проверка возможности разблокировки навыка
function RPGSystem:CanUnlockSkill(nodeID)
    local node = self.SkillTree.nodes[nodeID]
    if not node then return false end
    if node.unlocked then return false end
    if self.SkillPoints < node.cost then return false end
    
    for _, parentID in ipairs(node.parents or {}) do
        local parent = self.SkillTree.nodes[parentID]
        if not parent or not parent.unlocked then
            return false
        end
    end
    return true
end

-- Разблокировка навыка
function RPGSystem:UnlockSkill(nodeID)
    if not self:CanUnlockSkill(nodeID) then
        CONSOLE.AddMessage("RPG: The skill cannot be unlocked!")
        return false
    end

    local node = self.SkillTree.nodes[nodeID]
    self.SkillPoints = self.SkillPoints - node.cost
    node.unlocked = true
    table.insert(self.ActiveSkills, nodeID)
    
    self:ApplyStats()
    self:SaveToProfile()
    
    --CONSOLE.AddMessage("RPG: Навык '" .. node.name .. "' разблокирован!")
    return true
end

-- Получение XP за убийство моба
function RPGSystem:OnMobKilled(actor)
    if not self.Enabled or not actor then return end
    if not Player or Player._died then return end
    
    -- Базовая XP за убийство
    local xpGain = 10
    
    -- Бонус за сложность
    if Game.Difficulty then
        xpGain = xpGain * (1 + Game.Difficulty * 0.5)
    end
    
    self:AddXP(math.floor(xpGain))
end

-- Вызывается при старте игры
function RPGSystem:OnGameStart()
    self:Init()
end

-- Сброс RPG системы (для консольной команды)
function RPGSystem:Reset()
    self.PlayerLevel = 1
    self.PlayerXP = 0
    self.XPToNextLevel = 100
    self.SkillPoints = 0
    self.Stats = { Strength = 1, Agility = 1, Intelligence = 1 }
    self.ActiveSkills = {}
    self.SkillTree = Clone(DefaultSkillTree)
    
    self:ApplyStats()
    self:SaveToProfile()
    CONSOLE.AddMessage("RPG: Система сброшена!")
end