LastPlayerHP = nil,

    if self.Difficulty >= 3 and Game.LastPlayerHP then
        Player.Health = Game.LastPlayerHP
        Player.Armor = Game.LastPlayerArmor or 0
        Player.ArmorType = Game.LastPlayerArmorType or 0
        Player.SoulsCount = Game.LastPlayerSouls or 0
    else
        Player.Health = CPlayer.Health or 100
        Player.Armor = CPlayer.Armor or 0
        Player.ArmorType = CPlayer.ArmorType or 0
        Player.SoulsCount = 0
    end

    if Game.LastPlayerHP then
        Player.Health = Game.LastPlayerHP
        Player.Armor = Game.LastPlayerArmor or 0
        Player.ArmorType = Game.LastPlayerArmorType or 0
        Player.SoulsCount = Game.LastPlayerSouls or 0
        Player.ArmorRescueFactor = GetArmorRescueFactor(Player.ArmorType)
        
        --CONSOLE.AddMessage("Player.Armor after apply: "..tostring(Player.Armor))
        --CONSOLE.AddMessage("Player.ArmorType after apply: "..tostring(Player.ArmorType))
    else
        --CONSOLE.AddMessage("No saved armor found, using defaults")
    end

    if Player then
        if self.Difficulty == 3 and Game.LastPlayerHP then
            Player.Health = Game.LastPlayerHP
            if Game.LastPlayerArmor then
                Player.Armor = Game.LastPlayerArmor
                Player.ArmorType = Game.LastPlayerArmorType or 0
                Player.ArmorRescueFactor = GetArmorRescueFactor(Player.ArmorType)
            end
            if Game.LastPlayerSouls then
                Player.SoulsCount = Game.LastPlayerSouls
            end
        else
            if Game.LastPlayerHP then
                Player.Health = math.min(Game.LastPlayerHP, self.HealthCapacity)
            else
                Player.Health = self.InitialHealth or 100
            end
            
            if Game.LastPlayerArmor then
                Player.Armor = Game.LastPlayerArmor
                Player.ArmorType = Game.LastPlayerArmorType or 0
                Player.ArmorRescueFactor = GetArmorRescueFactor(Player.ArmorType)
            else
                Player.Armor = 0
                Player.ArmorType = 0
                Player.ArmorRescueFactor = 0
            end
            
            Player.SoulsCount = Game.LastPlayerSouls or 0
        end
    else
        if self.Difficulty == 3 and Game.LastPlayerHP then
            CPlayer.Health = Game.LastPlayerHP
            if Game.LastPlayerArmor then
                CPlayer.Armor = Game.LastPlayerArmor
                CPlayer.ArmorType = Game.LastPlayerArmorType or 0
            end
            if Game.LastPlayerSouls then
                CPlayer.SoulsCount = Game.LastPlayerSouls
            end
        else
            CPlayer.Health = self.InitialHealth or 100
            if Game.LastPlayerArmor then
                CPlayer.Armor = Game.LastPlayerArmor
                CPlayer.ArmorType = Game.LastPlayerArmorType or 0
            else
                CPlayer.Armor = 0
                CPlayer.ArmorType = 0
            end
            CPlayer.SoulsCount = Game.LastPlayerSouls or 0
        end
    end

    if self.Difficulty == 3 and Game.LastPlayerHP then
        if Player and Player.Health < 999 and Game.LastPlayerHP then
            Player.Health = Game.LastPlayerHP
        end
        if Player and Game.LastPlayerArmor then
            Player.Armor = Game.LastPlayerArmor
            Player.ArmorType = Game.LastPlayerArmorType
        end
        if Player and Game.LastPlayerSouls then
            Player.SoulsCount = Game.LastPlayerSouls
        end
    elseif Player and Player.Health < 999 and self.InitialHealth ~= 100 then
        Player.Health = self.InitialHealth
    end

    new.LastPlayerHP = Game.LastPlayerHP

    Game.LastPlayerHP = state.LastPlayerHP

    _LastAmmo = nil,

    if self.Difficulty == 3 then
        self:SetLastAmmo()
    else
        Game._LastAmmo = nil
    end

    function Game:SetLastAmmo()
        if Game._LastAmmo and Player then
            Player.Ammo = Clone(Game._LastAmmo)
        end
    end

    if self.Difficulty == 3 and Game._LastAmmo and firstTime then
        Player.Ammo = Clone(Game._LastAmmo)
    end

    if Lev.OnPlay then
        CLevel.OnPlay(Lev, firstTime)
        Lev:OnPlay(firstTime)
        CustomDifficultyMenu:OnLevelStart()
        if self.Difficulty < 3 then
            if Lev.ResetAmmoForThatLevel then
                Player.Ammo = Clone(CPlayer.s_SubClass.ClearAmmo)
            else
                Player.Ammo = Clone(CPlayer.s_SubClass.LevelAmmo.Simple)
            end
        end
        if self.Difficulty == 3 then
            Lev:SetLastAmmo()
        else
            Game._LastAmmo = nil
        end

    new._LastAmmo = Clone(Player.Ammo)

    Game._LastAmmo = {}
    Game._LastAmmo = Clone(state._LastAmmo)

    LastPlayerHealth = 0, -- легенда

    LastPlayerArmor = nil,

    new.LastPlayerArmor = Game.LastPlayerArmor
    new.LastPlayerArmorType = Game.LastPlayerArmorType

    Game.LastPlayerArmor = state.LastPlayerArmor
    Game.LastPlayerArmorType = state.LastPlayerArmorType