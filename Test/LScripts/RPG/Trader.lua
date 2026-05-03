--=======================================================================
--                        Trader.lua
--                         By 7ZOV.
--                  Точно не спизжено с релоада)
--               Используйте в своих модах на здоровье!
--             Мод находится под авторским правом от компании ООО "РХК".
--=======================================================================

Trader = {}
Trader.CurrMenu = {
  Name = "EMPTY",
  Sub = {}
}
Trader.ZeroMenu = {}
Trader.QMItemPosX = 0
Trader.QMItemPosY = 0
Trader.QMIndent = 15
Trader.QMenuSpanW = 0
Trader.QMenuSizeX = 0
Trader.QMenuSizeY = 0
Trader.QMenuRows = 0
Trader.QMenuIdx = {}
Trader.QMExtraRows = {}
Trader.QMenuRowHeight = 38
Trader.QMFontHeight = Trader.QMenuRowHeight - 18
Trader.QMFontType = "courbd"
Trader.GameStage = 1

Trader.Build = "3.5" --Ради выебонов, так то нахуй не нужно
Trader._DrawQuickOptions = false -- Флаг для магазина душ
Trader._CoinShopOpen = false -- Флаг для магазина монет
Trader._TarotShopOpen = false -- Флаг для обменника/таро

Trader.Colors = {
  Text        = {230, 161, 97},
  Highlight   = {214, 0, 23},
  Disabled    = {100, 100, 100},
  Background  = {0, 0, 0},
  Border      = {230, 161, 97}
}

Trader.NormalPrices = { -- Обычная цена без скидки от карты таро
  Shotgun = 4,
  Stakec  = 4,
  Grenate = 6,
  Frozen  = 6,
  Bullets = 4,
  Electro = 4,
  Sureken = 4,
  ArmorBr = 11, -- Осторожно, если число выше 10, то текст может поехать на сво (места мало)
  Heal    = 6,
}

Trader.DiscountPrices = {
  Shotgun = 3,
  Stakec  = 3,
  Grenate = 5,
  Frozen  = 4,
  Bullets = 3,
  Electro = 3,
  Sureken = 3,
  ArmorBr = 9,
  Heal    = 5,
}

Trader.CoinPrices = { -- Обычная цена без скидки от карты таро
  BoltGun     = 2000,
  Rifle       = 2000,
  AmmoBolt    = 8,
  AmmoRifle   = 8,
  Flame       = 9,
  Bomb        = 10,
  ArmorSr     = 750,
  MegaHealth  = 750,
  Quad        = 270,
  Devastator  = 2000,
  HellGun     = 2000,
  Quad1       = 270,
  MegaPack    = 100,
}

Trader.DiscountCoinPrices = {
  BoltGun     = 900,
  Rifle       = 900,
  AmmoBolt    = 5,
  AmmoRifle   = 5,
  Flame       = 6,
  Bomb        = 7,
  ArmorSr     = 550,
  MegaHealth  = 550,
  Quad        = 150,
  Devastator  = 900,
  HellGun     = 900,
  Quad1       = 150,
  MegaPack    = 70,
}

Trader.TarotShop = {
  SoulToCoin        = {souls = 1, coins = 0, getCoins = 15},
  CoinToSoul        = {souls = 0, coins = 25, getSouls = 1},
  VampirismCard     = {souls = 12, coins = 650},
  HealthRegenCard   = {souls = 32, coins = 900},
  ArmorRegenCard    = {souls = 32, coins = 900},
  AmmoBoostCard     = {souls = 30, coins = 650},
  SoulCatchDistance = {souls = 10, coins = 300},
  RepairArmor       = {souls = 12, coins = 170},
}

function Trader:ResetMenuPos()
  local Width, Height = R3D.ScreenSize()
  Trader.QMItemPosX = (Width - Trader.QMenuSizeX) / 2
  Trader.QMItemPosY = (Height - Trader.QMenuSizeY) / 2
  Trader.QMenuSpanW = 0
end

function Trader:CheckEnemiesAround()
    if not Player then return true end
    
    local playerX, playerY, playerZ = Player.Pos:Get()
    local enemies = 0
    
    for i, actor in Actors, nil do
        if actor and actor._Class == "CActor" and not actor._died and actor.Health > 0 and actor ~= Player then
            if not actor.NotCountable then
                local ax, ay, az = actor.Pos:Get()
                local dist = math.sqrt((ax - playerX)^2 + (ay - playerY)^2 + (az - playerZ)^2)
                if dist < 9999 then
                    enemies = enemies + 1
                    break
                end
            end
        end
    end
    
    return enemies > 0
end

function Trader:UpdateMenuSize(Menu, Expand)
  local RowWidth = 0
  local rows = 0
  HUD.SetFont(Trader.QMFontType, Trader.QMFontHeight)
  for i, v in Menu.Sub, nil do
    local CurrRowWidth = Trader:DrawIcon(v, 0, 0, true) + HUD.GetTextWidth(v.Name) + Trader.QMIndent
    if RowWidth < CurrRowWidth then
      RowWidth = CurrRowWidth
    end
    rows = i
  end
  if Expand then
    local LastMenuRows = Trader.QMenuRows
    local idx = 0
    for i, v in Trader.QMenuIdx, nil do
      idx = idx + v
    end
    if rows + idx > Trader.QMenuRows then
      Trader.QMenuRows = rows + idx
      table.insert(Trader.QMExtraRows, Trader.QMenuRows - LastMenuRows)
    else
      table.insert(Trader.QMExtraRows, 0)
    end
    Trader.QMenuSizeX = Trader.QMenuSizeX + RowWidth
    Trader.QMenuSizeY = Trader.QMenuRowHeight * Trader.QMenuRows
  else
    Trader.QMenuSizeX = Trader.QMenuSizeX - RowWidth
    local n = table.getn(Trader.QMExtraRows)
    Trader.QMenuSizeY = Trader.QMenuSizeY - Trader.QMenuRowHeight * Trader.QMExtraRows[n]
    Trader.QMenuRows = Trader.QMenuRows - Trader.QMExtraRows[n]
    table.remove(Trader.QMExtraRows, n)
  end
end

function Trader:CalculateMenuSize()
  local maxNameWidth = 0
  local maxPriceWidth = 0
  HUD.SetFont("courbd", 20)
  
  for i, v in Trader.CurrMenu.Sub, nil do
    local nameWidth = HUD.GetTextWidth(v.Name, "courbd", 20)
    if nameWidth > maxNameWidth then
      maxNameWidth = nameWidth
    end
    
    local priceText = ""
    if self._CoinShopOpen then
      priceText = TXT.PainShop.Coins .. ":" .. v.Price .. TXT.PainShop.MP
    elseif self._TarotShopOpen then
      local soulPrice = v.SoulPrice or 0
      local coinPrice = v.CoinPrice or 0
      priceText = TXT.PainShop.Souls .. ":" .. soulPrice .. TXT.PainShop.SP .. " + " .. TXT.PainShop.Coins .. ":" .. coinPrice .. TXT.PainShop.MP
    else
      priceText = TXT.PainShop.Souls .. ":" .. v.Price .. TXT.PainShop.SP
    end
    
    local priceWidth = HUD.GetTextWidth(priceText, "courbd", 20)
    if priceWidth > maxPriceWidth then
      maxPriceWidth = priceWidth
    end
  end
  
  local totalWidth = maxNameWidth + maxPriceWidth + 150 -- 100px для отступов и номеров
  local totalHeight = 550 -- базовая высота
  
  if totalWidth > 500 then
    return totalWidth, totalHeight
  else
    return 500, totalHeight
  end
end

function Trader:GetActualCoinShopItem(item)
    if item.Type == "weapon" and Player then
        local weaponSlot = nil
        
        if item.WeaponType == "IBoltGunHeater" then
            weaponSlot = 7
        elseif item.WeaponType == "IRifleFlameThrower" then
            weaponSlot = 6
        elseif item.WeaponType == "IHellGun" then
            weaponSlot = 8
        elseif item.WeaponType == "IDevastator" then
            weaponSlot = 9
        end
        
        if weaponSlot and Player.EnabledWeapons[weaponSlot] then
            local altItem = {}
            if item.WeaponType == "IBoltGunHeater" then
                altItem.Type = "armor"
                altItem.ArmorType = "ArmorMedium"
                altItem.Name = TXT.PainShop.ArmorSr or "Silver Armor"
            elseif item.WeaponType == "IRifleFlameThrower" then
                altItem.Type = "health"
                altItem.HealthType = "MegaHealth" 
                altItem.Name = TXT.PainShop.MegaHealth or "Mega Health"
            elseif item.WeaponType == "IHellGun" then
                altItem.Type = "ammo"
                altItem.AmmoType = "MegaPack"
                altItem.Name = TXT.PainShop.MegaPack or "MegaPack"
            elseif item.WeaponType == "IDevastator" then
                altItem.Type = "bonus"
                altItem.BonusType = "Quad"
                altItem.Name = TXT.PainShop.Quad1 or "Morph"
            end
            return altItem
        end
    end
    
    return item
end

function Trader:GetPriceText(item)
  if not self._TarotShopOpen then
    return "N/A"
  end
  
  local soulPrice = item.SoulPrice or 0
  local coinPrice = item.CoinPrice or 0
  return (TXT.PainShop.Souls or "Souls") .. ":" .. soulPrice .. (TXT.PainShop.SP or "/S") .. " + " .. (TXT.PainShop.Coins or "Coins") .. ":" .. coinPrice .. (TXT.PainShop.MP or "/M")
end

function Trader:LoadHUDData()
    self._matShotgunIcon = MATERIAL.Create("HUD/shell", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matStakeIcon = MATERIAL.Create("HUD/kolki", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matGrenadeIcon = MATERIAL.Create("HUD/rocket", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matMiniGunIcon = MATERIAL.Create("HUD/minigun", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matFreezerIcon = MATERIAL.Create("HUD/ikona_freezer", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matShurikenIcon = MATERIAL.Create("HUD/ikona_szuriken", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matElectroIcon = MATERIAL.Create("HUD/ikona_electro", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matRifleIcon = MATERIAL.Create("HUD/rifle", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matFlameIcon = MATERIAL.Create("HUD/ikona_flamer", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matBoltIcon = MATERIAL.Create("HUD/bolty", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matHeaterIcon = MATERIAL.Create("HUD/kulki", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matVampirismIcon = MATERIAL.Create("HUD/pentagram", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matSoulCatcherIcon = MATERIAL.Create("HUD/ikona_grabber", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matHealthRegenIcon = MATERIAL.Create("HUD/energia", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matArmorRegenIcon = MATERIAL.Create("HUD/gwiazdka", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    self._matAmmoBoostIcon = MATERIAL.Create("HUD/minigun", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
end

function Trader:DrawMenu(Menus)
  if not self._DrawQuickOptions then return end
  
  local w, h = R3D.ScreenSize()
  
  local menuWidth, menuHeight = self:CalculateMenuSize()
  local menuX, menuY = (w - menuWidth) / 2, (h - menuHeight) / 2
  
  HUD.DrawQuadRGBA(nil, menuX, menuY, menuWidth, menuHeight, 0, 0, 0, 200)

  self:DrawPlayerStatus(w, h, menuX, menuWidth)
  
  HUD.SetFont("timesbd", 28)
  
  local title = ""
  if self._CoinShopOpen then
    title = TXT.PainShop.CoinShop
  elseif self._TarotShopOpen then
    title = TXT.PainShop.TarotShop
  else
    title = TXT.PainShop.SoulsDec
  end
  
  local titleWidth = HUD.GetTextWidth(title, "timesbd", 28)
  HUD.PrintXY((w - titleWidth)/2, menuY + 10, title, "timesbd", self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 28)

  if self._CoinShopOpen then
    local coins = Game.PlayerMoney or 0
    local coinsText = TXT.PainShop.CoinsAmount .. ": " .. coins
    local coinsWidth = HUD.GetTextWidth(coinsText, "timesbd", 24)
    HUD.PrintXY(menuX + 20 + (menuWidth - coinsWidth)/2, menuY + 50, coinsText, "timesbd", self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 24)
  elseif self._TarotShopOpen then
    local souls = Player and (Player.SoulsCount or 0) or 0
    local coins = Game.PlayerMoney or 0
    local soulsText = TXT.PainShop.SoulsAmount .. ": " .. souls
    local coinsText = TXT.PainShop.CoinsAmount .. ": " .. coins
    local soulsWidth = HUD.GetTextWidth(soulsText, "timesbd", 20)
    local coinsWidth = HUD.GetTextWidth(coinsText, "timesbd", 20)
    HUD.PrintXY(menuX + 20, menuY + 50, soulsText, "timesbd", self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 20)
    HUD.PrintXY(menuX + menuWidth + 50 - coinsWidth, menuY + 50, coinsText, "timesbd", self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 20)
  else
    local souls = Player and (Player.SoulsCount or 0) or 0
    local soulsText = TXT.PainShop.SoulsAmount .. ": " .. souls
    local soulsWidth = HUD.GetTextWidth(soulsText, "timesbd", 24)
    HUD.PrintXY(menuX + 20 + (menuWidth - soulsWidth)/2, menuY + 50, soulsText, "timesbd", self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 24)
  end
  
  HUD.DrawQuadRGBA(nil, menuX + 20, menuY + 80, menuWidth - 40, 2, self.Colors.Border[1], self.Colors.Border[2], self.Colors.Border[3], 255)
  
  local itemStartY = menuY + 100
  local itemSpacing = 50

  local selectedItemDescription = ""

  for i, v in Trader.CurrMenu.Sub, nil do
    local color = self.Colors.Text

    local hasDarkSoulCard = Game.CardsSelected[16]
    local priceTable = hasDarkSoulCard and Trader.DiscountPrices or Trader.NormalPrices
    local double = Game.CardsSelected[20]
    local priceCoinTable = double and Trader.DiscountCoinPrices or Trader.CoinPrices
    
    local displayName = v.Name
    local displayPrice = v.Price
    local displayMP = TXT.PainShop.MP
    local displaySP = TXT.PainShop.SP

    local isPurchased = false
    if self._TarotShopOpen and v.Type == "tarotcard" then
      if v.CardType == "Vampirism" then
        isPurchased = Game.PurchasedBuffs.Vampirism
      elseif v.CardType == "HealthRegen" then
        isPurchased = Game.PurchasedBuffs.HealthRegen1
      elseif v.CardType == "ArmorRegen" then
        isPurchased = Game.PurchasedBuffs.ArmorRegen1
      elseif v.CardType == "AmmoBoost" then
        isPurchased = Game.PurchasedBuffs.AmmoBoost
      elseif v.CarType == "SoulCatchDistance1" then
        isPurchased = Game.PurchasedBuffs.SoulCatchDistance1
      end
    end

    local displayName = v.Name
    local displayPrice = v.Price
    
    if self._CoinShopOpen and v.Type == "weapon" and Player then
        local actualItem = self:GetActualCoinShopItem(v)
        displayName = actualItem.Name
        
        local double = Game.CardsSelected[20]
        local priceCoinTable = double and Trader.DiscountCoinPrices or Trader.CoinPrices
        
        if v.WeaponType == "IBoltGunHeater" and Player.EnabledWeapons[7] then
            displayPrice = priceCoinTable.ArmorSr
        elseif v.WeaponType == "IRifleFlameThrower" and Player.EnabledWeapons[6] then
            displayPrice = priceCoinTable.MegaHealth
        elseif v.WeaponType == "IHellGun" and Player.EnabledWeapons[8] then
            displayPrice = priceCoinTable.MegaPack
        elseif v.WeaponType == "IDevastator" and Player.EnabledWeapons[9] then
            displayPrice = priceCoinTable.Quad1
        end
    end
    
    local canAfford = false
    if self._CoinShopOpen then
      local coins = Game.PlayerMoney or 0
      canAfford = coins >= displayPrice
    elseif self._TarotShopOpen then
      local souls = Player and (Player.SoulsCount or 0) or 0
      local coins = Game.PlayerMoney or 0
      local soulPrice = v.SoulPrice or 0
      local coinPrice = v.CoinPrice or 0
      canAfford = (souls >= soulPrice) and (coins >= coinPrice)
    else
      local souls = Player and (Player.SoulsCount or 0) or 0
      canAfford = souls >= displayPrice
    end
    
    if i == Trader.CurrMenu.Idx then
      color = self.Colors.Highlight
      HUD.DrawQuadRGBA(nil, menuX + 10, itemStartY + (i-1)*itemSpacing - 5, menuWidth - 20, 30, 40, 30, 20, 100)
      if self._CoinShopOpen and v.Type == "weapon" and Player then
        local actualItem = self:GetActualCoinShopItem(v)
        selectedItemDescription = self:GetItemDescription(actualItem)
      else
        selectedItemDescription = self:GetItemDescription(v)
      end
    end
      
    if not canAfford then
      color = self.Colors.Disabled
      HUD.DrawQuadRGBA(nil, menuX + 10, itemStartY + (i-1)*itemSpacing - 5, menuWidth - 20, 30, 20, 20, 20, 100)
    end
    
    HUD.SetFont("courbd", 20)
    HUD.PrintXY(menuX + 30, itemStartY + (i-1)*itemSpacing, i .. ". " .. displayName, "courbd", color[1], color[2], color[3], 20)
    
    local priceText = ""
    local priceWidth = HUD.GetTextWidth(priceText, "courbd", 20)
    HUD.PrintXY(menuX + menuWidth - 30 - priceWidth, itemStartY + (i-1)*itemSpacing, priceText, "courbd", color[1], color[2], color[3], 20)
    
    local priceText = ""
    if self._TarotShopOpen then
      priceText = self:GetPriceText(v)
    else
      if self._CoinShopOpen then
        priceText = TXT.PainShop.Coins .. ":" .. displayPrice .. displayMP
      else
        priceText = TXT.PainShop.Souls .. ":" .. displayPrice .. displaySP
      end
    end
    
    local priceWidth = HUD.GetTextWidth(priceText, "courbd", 20)
    HUD.PrintXY(menuX + menuWidth - 30 - priceWidth, itemStartY + (i-1)*itemSpacing, priceText, "courbd", color[1], color[2], color[3], 20)
  end

  HUD.SetFont("courbd", 16)
  local controlText = TXT.PainShop.ControlsDesc
  local controlWidth = HUD.GetTextWidth(controlText, "courbd", 16)
  HUD.PrintXY((w - controlWidth)/2, menuY + menuHeight + 10, controlText, "courbd", self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 16)
  
  HUD.SetFont("courbd", 14)
  local switchText = TXT.PainShop.SwitchShop
  local switchWidth = HUD.GetTextWidth(switchText, "courbd", 14)
  HUD.PrintXY((w - switchWidth)/2, menuY + menuHeight + 40, switchText, "courbd", self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 16)

  if selectedItemDescription ~= "" then
    HUD.SetFont("courbd", 14)
    local descWidth = HUD.GetTextWidth(selectedItemDescription, "courbd", 14)
    HUD.PrintXY((w - descWidth)/2, menuY + menuHeight + 80, selectedItemDescription, "courbd", self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 16)
  end
end

function Trader:DrawPlayerStatus(screenWidth, screenHeight, menuX, menuWidth)
    if not Player then return end
    
    if not self._matShotgunIcon then
        self:LoadHUDData()
    end
    
    local statusX = menuX + menuWidth + 20
    local statusY = screenHeight / 2 - 150
    local iconSize = 24
    local textOffset = 30
    local rowHeight = 25
    
    HUD.DrawQuadRGBA(nil, statusX - 10, statusY - 70, 180, 460, 0, 0, 0, 180)

    -- Старый вариант
    --HUD.SetFont("timesbd", 18) 
    --HUD.PrintXY(statusX, statusY - 70 + 10, TXT.PainShop.Status, "timesbd", 230, 161, 97, 18)
    
    local statusTitle = TXT.PainShop.Status or "STATUS"
    HUD.SetFont("timesbd", 18)
    local titleWidth = HUD.GetTextWidth(statusTitle, "timesbd", 18)
    local titleX = statusX + (180 - titleWidth) / 2
    HUD.PrintXY(titleX, statusY - 70 + 10, statusTitle, "timesbd", 230, 161, 97, 18)
    
    local currentY = statusY - 70 + 30
    
    HUD.DrawQuad(Hud._matHealth, statusX, currentY - 3, iconSize, iconSize)
    HUD.PrintXY(statusX + textOffset, currentY, math.floor(Player.Health), "courbd", 230, 161, 97, 16)
    currentY = currentY + rowHeight
    
    local armorIcon = Hud._matArmorNormal
    
    if Player.ArmorType == ArmorTypes.Weak then
        armorIcon = Hud._matArmorGreen
    elseif Player.ArmorType == ArmorTypes.Medium then
        armorIcon = Hud._matArmorYellow  
    elseif Player.ArmorType == ArmorTypes.Strong then
        armorIcon = Hud._matArmorRed
    end
    
    HUD.DrawQuad(armorIcon, statusX, currentY - 3, iconSize, iconSize)
    HUD.PrintXY(statusX + textOffset, currentY, math.floor(Player.Armor or 0), "courbd", 230, 161, 97, 16)
    currentY = currentY + rowHeight
    
    currentY = currentY + 2
    HUD.DrawQuadRGBA(nil, statusX - 5, currentY, 170, 2, 100, 100, 100, 100)
    currentY = currentY + 10
    
    HUD.SetFont("courbd", 14)

    local ammoList = {
        {Player.Ammo.Shotgun, Player.MaxAmmoTable.Shotgun, self._matShotgunIcon},
        {Player.Ammo.Stakes, Player.MaxAmmoTable.Stakes, self._matStakeIcon},
        {Player.Ammo.Grenades, Player.MaxAmmoTable.Grenades, self._matGrenadeIcon},
        {Player.Ammo.MiniGun, Player.MaxAmmoTable.MiniGun, self._matMiniGunIcon},
        {Player.Ammo.IceBullets, Player.MaxAmmoTable.IceBullets, self._matFreezerIcon},
        {Player.Ammo.Shurikens, Player.MaxAmmoTable.Shurikens, self._matShurikenIcon},
        {Player.Ammo.Electro, Player.MaxAmmoTable.Electro, self._matElectroIcon},
        {Player.Ammo.Rifle, Player.MaxAmmoTable.Rifle, self._matRifleIcon},
        {Player.Ammo.FlameThrower, Player.MaxAmmoTable.FlameThrower, self._matFlameIcon},
        {Player.Ammo.Bolt, Player.MaxAmmoTable.Bolt, self._matBoltIcon},
        {Player.Ammo.HeaterBomb, Player.MaxAmmoTable.HeaterBomb, self._matHeaterIcon}
    }
    
    local hasAnyAmmo = false
    
    for i, ammo in ammoList do
        local currentAmmo = ammo[1] or 0
        local icon = ammo[3]
        
        if currentAmmo > 0 and icon then
            hasAnyAmmo = true
            HUD.DrawQuad(icon, statusX, currentY - 5, iconSize, iconSize)
            HUD.PrintXY(statusX + textOffset, currentY, currentAmmo .. "/" .. (ammo[2] or 999), "courbd", 230, 161, 97, 14)            currentY = currentY + 20
        end
    end
    
    currentY = currentY + 5
    HUD.DrawQuadRGBA(nil, statusX - 5, currentY, 170, 2, 100, 100, 100, 100)
    currentY = currentY + 10

    HUD.SetFont("timesbd", 16)
    HUD.PrintXY(statusX, currentY, TXT.PainShop.ActivBuf, "timesbd", 230, 161, 97, 16)
    currentY = currentY + 25

    HUD.SetFont("courbd", 14)

    local buffList = {
        {Game.PurchasedBuffs.Vampirism, TXT.PainShop.VampirismCard1, self._matVampirismIcon},
        {Game.PurchasedBuffs.HealthRegen1, TXT.PainShop.HealthRegenCard1, self._matHealthRegenIcon},
        {Game.PurchasedBuffs.ArmorRegen1, TXT.PainShop.ArmorRegenCard1, self._matArmorRegenIcon},
        {Game.PurchasedBuffs.AmmoBoost, TXT.PainShop.AmmoBoostCard1, self._matAmmoBoostIcon},
        {Game.PurchasedBuffs.SoulCatchDistance1, TXT.PainShop.SoulCatchDistance1, self._matSoulCatcherIcon},
    }

    local hasAnyBuff = false

    for i, buff in buffList do
        if buff[1] then
            hasAnyBuff = true
            if buff[3] then
                HUD.DrawQuad(buff[3], statusX, currentY, iconSize, iconSize)
            end
            HUD.PrintXY(statusX + textOffset, currentY + 5, buff[2], "courbd", 230, 161, 97, 14)
            currentY = currentY + 20
        end
    end

    if not hasAnyBuff then
        HUD.PrintXY(statusX, currentY, TXT.PainShop.ActivBufNo, "courbd", 100, 100, 100, 14)
    end
end

function Trader:HasWeaponForAmmo(ammoType)
    if not Player or not Player.EnabledWeapons then return false end
    
    local weaponAmmoMap = {
        SHOTGUN = {2, 9},      -- Shotgun, Devastator
        STAKES = {3},          -- StakeGun
        GRENADES = {4, 8, 9},  -- MiniGunRL, HellGun, Devastator  
        MINIGUN = {4},         -- MiniGunRL
        ["ICE BULLETS"] = {2}, -- Shotgun
        SHURIKENS = {5},       -- DriverElectro
        ELECTRO = {5},         -- DriverElectro
        RIFLE = {6, 8},        -- RifleFlameThrower, HellGun
        FLAMETHROWER = {6},    -- RifleFlameThrower
        BOLT = {7},            -- BoltGunHeater
        ["HEATER BOMB"] = {7}  -- BoltGunHeater
    }
    
    local weapons = weaponAmmoMap[ammoType]
    if weapons then
        for i, slot in weapons do
            if Player.EnabledWeapons[slot] then
                return true
            end
        end
    end
    
    return false
end

function Trader:DrawIcon(v, posx, posy, simulate)
  return 0
end

function Trader:InitMenu()

  if GetPainkillerVersionString() ~= "1.4" or GetEngineVersionString() ~= "1.4" then
    MsgBox( "Critical error: bad engine version or exe version; the game will not run" )
    return
  end
  
  if Game.Difficulty < 3 then
    CONSOLE.AddMessage(TXT.PainShop.CheckDf)
    PlaySound2D("misc/card-cannot_use")
    return
  end

  if self:CheckEnemiesAround() then
    CONSOLE.AddMessage(TXT.PainShop.Check)
    PlaySound2D("misc/card-cannot_use")
    return
  end

  if not self._matShotgunIcon then
    self:LoadHUDData()
  end
  
  Trader._DrawQuickOptions = true
  Trader._CoinShopOpen = false
  Trader._TarotShopOpen = false
  Trader.QMenuSizeX = 0
  Trader.QMenuSizeY = 0
  Trader.QMenuRows = 0
  Trader.QMenuIdx = {}
  Trader.QMExtraRows = {}
  Trader.ZeroMenu = {}
  Trader.CurrMenu = Trader:MakeMenu()
  Trader:Navigate(Trader._down)
  Trader.CurrMenu.Active = true
  Trader:UpdateMenuSize(Trader.CurrMenu, true)
  table.insert(Trader.ZeroMenu, Trader.CurrMenu)
  PlaySound2D("menu/mapselect/option-accept")
  AddAction({
    {"Wait:1.5"}
  })
end

function infix(f)
  local sm = setmetatable
  local mt = {
    __sub = function(self, b)
      return f(self[1], b)
    end
  }
  return sm({}, {
    __sub = function(a, _)
      return sm({a}, mt)
    end
  })
end

Trader._down = infix(function(a, b) -- Заготовка для последующих обнов
  return a + b
end)
Trader._up = infix(function(a, b) -- Заготовка для последующих обнов
  return a - b
end)

function Trader:Navigate(op)
  if not Trader.CurrMenu.Idx then
    Trader.CurrMenu.Idx = 0
  end
  local idx = 1
  local Item = Trader.CurrMenu.Sub[Trader.CurrMenu.Idx - op - idx]
  while Item and Item.Available and Item.Available > Trader.GameStage do
    idx = idx + 1
    Item = Trader.CurrMenu.Sub[Trader.CurrMenu.Idx - op - idx]
  end
  if Item then
    Trader.CurrMenu.Idx = Trader.CurrMenu.Idx - op - idx
  end
end

function Trader:DrawQuickMenu()
  if Game.IsDemon then
    self._DrawQuickOptions = false
    return
  end
  
  if Game.Difficulty < 3 then
    return
  end
  
  if self._DrawQuickOptions then

    self:DrawMenu(Trader.ZeroMenu)
    
    if INP.Key(Keys.Tab) == 1 then
      self:SwitchShop()
      return
    end
    
    if INP.Key(Keys.Num1) == 1 or INP.Key(Keys.D1) == 1 then
      if Trader.CurrMenu.Sub[1] then
        Trader.CurrMenu.Idx = 1
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num2) == 1 or INP.Key(Keys.D2) == 1 then
      if Trader.CurrMenu.Sub[2] then
        Trader.CurrMenu.Idx = 2
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num3) == 1 or INP.Key(Keys.D3) == 1 then
      if Trader.CurrMenu.Sub[3] then
        Trader.CurrMenu.Idx = 3
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num4) == 1 or INP.Key(Keys.D4) == 1 then
      if Trader.CurrMenu.Sub[4] then
        Trader.CurrMenu.Idx = 4
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num5) == 1 or INP.Key(Keys.D5) == 1 then
      if Trader.CurrMenu.Sub[5] then
        Trader.CurrMenu.Idx = 5
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num6) == 1 or INP.Key(Keys.D6) == 1 then
      if Trader.CurrMenu.Sub[6] then
        Trader.CurrMenu.Idx = 6
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num7) == 1 or INP.Key(Keys.D7) == 1 then
      if Trader.CurrMenu.Sub[7] then
        Trader.CurrMenu.Idx = 7
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Num8) == 1 or INP.Key(Keys.D8) == 1 then
      if Trader.CurrMenu.Sub[8] then
        Trader.CurrMenu.Idx = 8
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end

    if INP.Key(Keys.Num9) == 1 or INP.Key(Keys.D9) == 1 then
      if Trader.CurrMenu.Sub[9] then
        Trader.CurrMenu.Idx = 9
        PlaySound2D("menu/menu_necro/scroller-move")
      end
    end
    
    if INP.Key(Keys.Enter) == 1 or INP.Key(Keys.NumlockEnter) == 1 then
      if Trader.CurrMenu.Sub[Trader.CurrMenu.Idx] then
        self:BuySelectedItem(Trader.CurrMenu.Sub[Trader.CurrMenu.Idx])
      end
    end
    
    if INP.Key(Keys.End) == 1 then
      self:ToggleMenu()
      return
    end
    
    Trader:DrawMenu(Trader.ZeroMenu)
  end
end

function Trader:SwitchShop()
  if not self._CoinShopOpen and not self._TarotShopOpen then
    Trader._CoinShopOpen = true
    Trader._TarotShopOpen = false
    Trader.CurrMenu = Trader:MakeCoinMenu()
    --CONSOLE.AddMessage(TXT.PainShop.CoinShopOpened)
  elseif self._CoinShopOpen and not self._TarotShopOpen then
    Trader._CoinShopOpen = false
    Trader._TarotShopOpen = true
    Trader.CurrMenu = Trader:MakeTarotMenu()
    --CONSOLE.AddMessage(TXT.PainShop.TarotShopOpened)
  else
    Trader._CoinShopOpen = false
    Trader._TarotShopOpen = false
    Trader.CurrMenu = Trader:MakeMenu()
    --CONSOLE.AddMessage(TXT.PainShop.SoulShopOpened)
  end
  
  Trader.CurrMenu.Idx = 1
  Trader.CurrMenu.Active = true
  
  PlaySound2D("menu/menu_necro/scroller-move")
end

function Trader:ToggleMenu()
  if Game.Difficulty < 3 then
    CONSOLE.AddMessage("Trader available only on Trauma difficulty!")
    PlaySound2D("misc/card-cannot_use")
    return
  end

  if self._DrawQuickOptions then
    self._DrawQuickOptions = false
    self._CoinShopOpen = false
    self._TarotShopOpen = false
    if Player then Player.Frozen = false end
    PlaySound2D("menu/menu_necro/scroller-move")
    Hud.Enabled = true
    Game.CameraFromPlayer = true
    return
  end
  
  if self:CheckEnemiesAround() then
    CONSOLE.AddMessage(TXT.PainShop.Check)
    PlaySound2D("misc/card-cannot_use")
    return
  end
  
  self._DrawQuickOptions = true
  self._CoinShopOpen = false
  self._TarotShopOpen = false
  Trader.QMenuSizeX = 0
  Trader.QMenuSizeY = 0
  Trader.QMenuRows = 0
  Trader.QMenuIdx = {}
  Trader.QMExtraRows = {}
  Trader.ZeroMenu = {}
  Trader.CurrMenu = Trader:MakeMenu()
  Trader:Navigate(Trader._down)
  Trader.CurrMenu.Active = true
  Trader:UpdateMenuSize(Trader.CurrMenu, true)
  table.insert(Trader.ZeroMenu, Trader.CurrMenu)
  PlaySound2D("menu/mapselect/option-accept")
  AddAction({
    {"Wait:1.5"}
  })
  
  if Player then Player.Frozen = true end
  Hud.Enabled = false
  Game.CameraFromPlayer = false
end

function Trader:GetItemDescription(item)
  if self._CoinShopOpen then
    return self:GetCoinShopDescription(item)
  elseif self._TarotShopOpen then
    return self:GetTarotShopDescription(item)
  else
    return self:GetSoulShopDescription(item)
  end
end

function Trader:GetSoulShopDescription(item)
  local descriptions = {
    AmmoShotgun = TXT.PainShop.DescShotgun,
    AmmoStakes = TXT.PainShop.DescStakec,
    AmmoGrenadesBig = TXT.PainShop.DescGrenate,
    AmmoFreezer = TXT.PainShop.DescFrozen,
    AmmoMiniGun = TXT.PainShop.DescBullets,
    AmmoElectro = TXT.PainShop.DescElectro,
    AmmoShurikens = TXT.PainShop.DescSureken,
    ArmorWeak = TXT.PainShop.DescArmorBr,
    Health = TXT.PainShop.DescHeal
  }
  return descriptions[item.AmmoType or item.ArmorType or item.HealthType] or "N/A"
end

function Trader:GetCoinShopDescription(item)
  local descriptions = {
    IBoltGunHeater = TXT.PainShop.DescBoltGun,
    IRifleFlameThrower = TXT.PainShop.DescRifle,
    IHellGun = TXT.PainShop.DescHellGun,
    IDevastator = TXT.PainShop.DescDevastator,
    AmmoRifle = TXT.PainShop.DescAmmoRifle,
    AmmoFlameThrower = TXT.PainShop.DescFlame,
    AmmoBolt = TXT.PainShop.DescBolt,
    AmmoHeaterBomb = TXT.PainShop.DescBomb,
    WeaponModifier = TXT.PainShop.DescQuad,
    ArmorMedium = TXT.PainShop.DescArmorSr,
    MegaHealth = TXT.PainShop.DescMegaHealth,
    MegaPack = TXT.PainShop.DescMegaPack,
    Quad = TXT.PainShop.DescQuad1
  }
  local key = item.WeaponType or item.AmmoType or item.BonusType or item.ArmorType or item.HealthType
  return descriptions[key] or "N/A"
end

function Trader:GetTarotShopDescription(item)
  local descriptions = {
    SoulToCoin = TXT.PainShop.DescSoulToCoin,
    CoinToSoul = TXT.PainShop.DescCoinToSoul,
    Vampirism = TXT.PainShop.DescVampirismCard,
    HealthRegen = TXT.PainShop.DescHealthRegenCard,
    ArmorRegen = TXT.PainShop.DescArmorRegenCard,
    AmmoBoost = TXT.PainShop.DescAmmoBoostCard,
    SoulCatchDistance = TXT.PainShop.DescSoulCatchDistance,
    Auto = TXT.PainShop.DescRepairArmor,
  }
  local key = item.ExchangeType or item.CardType or item.RepairType or item.TarotType
  return descriptions[key] or "N/A"
end

function Trader:MakeMenu()
  local Top = {
    Name = TXT.PainShop.SoulsDec,
    Sub = {}
  }

  local hasDarkSoulCard = Game.CardsSelected[16] --Темная душа, скидка
  local priceTable = hasDarkSoulCard and Trader.DiscountPrices or Trader.NormalPrices

  local Items = {
    {
      Name = TXT.PainShop.Shotgun, -- Дробь
      Available = 1,
      Info = "",
      Price = priceTable.Shotgun,
      Type = "ammo",
      AmmoType = "AmmoShotgun",
      Amount = 1 -- Не работает, было выпелено из за багов
    },
    {
      Name = TXT.PainShop.Stakec, -- Колья
      Available = 1,
      Info = "",
      Price = priceTable.Stakec,
      Type = "ammo",
      AmmoType = "AmmoStakes",
      Amount = 1
    },
    {
      Name = TXT.PainShop.Grenate, -- Гранаты/Ракеты
      Available = 1,
      Info = "",
      Price = priceTable.Grenate,
      Type = "ammo",
      AmmoType = "AmmoGrenadesBig",
      Amount = 1
    },
    {
      Name = TXT.PainShop.Frozen, -- Мороз
      Available = 1,
      Info = "",
      Price = priceTable.Frozen,
      Type = "ammo",
      AmmoType = "AmmoFreezer",
      Amount = 1
    },
    {
      Name = TXT.PainShop.Bullets, -- Пули
      Available = 1,
      Info = "",
      Price = priceTable.Bullets,
      Type = "ammo",
      AmmoType = "AmmoMiniGun",
      Amount = 1
    },
    {
      Name = TXT.PainShop.Electro, -- Электричка
      Available = 1,
      Info = "",
      Price = priceTable.Electro,
      Type = "ammo",
      AmmoType = "AmmoElectro",
      Amount = 1
    },
    {
      Name = TXT.PainShop.Sureken, -- Сюрекены
      Available = 1,
      Info = "",
      Price = priceTable.Sureken,
      Type = "ammo",
      AmmoType = "AmmoShurikens",
      Amount = 1
    },
    {
      Name = TXT.PainShop.ArmorBr, -- Бронзовая броня 
      Available = 1,
      Info = "",
      Price = priceTable.ArmorBr,
      Type = "armor",
      ArmorType = "ArmorWeak",
      ArmorAmount = 1
    },
    {
      Name = TXT.PainShop.Heal, --Аптечка
      Available = 1,
      Info = "",
      Price = priceTable.Heal,
      Type = "health",
      HealthType = "Health",
      HealthAmount = 1
    },
  }

  Top.Sub = Items
  return Top
end

function Trader:MakeCoinMenu()
  local Top = {
    Name = TXT.PainShop.CoinShop,
    Sub = {}
  }

  local double = Game.CardsSelected[20] --Удвоенное золото, скидка
  local priceCoinTable = double and Trader.DiscountCoinPrices or Trader.CoinPrices

  local Items = {
    {
      Name = TXT.PainShop.BoltGun, -- BoltGun
      Available = 1,
      Info = "",
      Price = priceCoinTable.BoltGun,
      Type = "weapon",
      WeaponType = "IBoltGunHeater"
    },
    {
      Name = TXT.PainShop.Rifle, -- Rifle
      Available = 1,
      Info = "",
      Price = priceCoinTable.Rifle,
      Type = "weapon",
      WeaponType = "IRifleFlameThrower"
    },
    {
      Name = TXT.PainShop.HellGun, -- HellGun
      Available = 1,
      Info = "",
      Price = priceCoinTable.HellGun,
      Type = "weapon",
      WeaponType = "IHellGun"
    },
    {
      Name = TXT.PainShop.Devastator, -- Devastator
      Available = 1,
      Info = "",
      Price = priceCoinTable.Devastator,
      Type = "weapon",
      WeaponType = "IDevastator"
    },
    {
      Name = TXT.PainShop.AmmoRifle, -- Патроны к Rifle
      Available = 1,
      Info = "",
      Price = priceCoinTable.AmmoRifle,
      Type = "ammo",
      AmmoType = "AmmoRifle",
      Amount = 2
    },
    {
      Name = TXT.PainShop.Flame, -- Огонь
      Available = 1,
      Info = "",
      Price = priceCoinTable.Flame,
      Type = "ammo",
      AmmoType = "AmmoFlameThrower",
      Amount = 2
    },
    {
      Name = TXT.PainShop.Bolt, -- Патроны к BoltGun
      Available = 1,
      Info = "",
      Price = priceCoinTable.AmmoBolt,
      Type = "ammo",
      AmmoType = "AmmoBolt",
      Amount = 2
    },
    {
      Name = TXT.PainShop.Bomb, -- Шрапнель
      Available = 1,
      Info = "",
      Price = priceCoinTable.Bomb,
      Type = "ammo",
      AmmoType = "AmmoHeaterBomb",
      Amount = 2
    },
    {
      Name = TXT.PainShop.Quad, -- Маска на двойной урон
      Available = 1,
      Info = "",
      Price = priceCoinTable.Quad,
      Type = "bonus",
      BonusType = "WeaponModifier",
      Amount = 1
    },
  }

  Top.Sub = Items
  return Top
end

function Trader:MakeTarotMenu()
  local Top = {
    Name = TXT.PainShop.TarotShop,
    Sub = {}
  }

  local Items = {
    {
      Name = TXT.PainShop.SoulToCoin, -- Обмен душ в монеты
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.SoulToCoin.souls,
      CoinPrice = Trader.TarotShop.SoulToCoin.coins,
      Type = "exchange",
      ExchangeType = "SoulToCoin",
      GetCoins = Trader.TarotShop.SoulToCoin.getCoins
    },
    {
      Name = TXT.PainShop.CoinToSoul, -- Обмен монет в души
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.CoinToSoul.souls,
      CoinPrice = Trader.TarotShop.CoinToSoul.coins,
      Type = "exchange", 
      ExchangeType = "CoinToSoul",
      GetSouls = Trader.TarotShop.CoinToSoul.getSouls
    },
    {
      Name = TXT.PainShop.VampirismCard or "Vampirism",
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.VampirismCard.souls,
      CoinPrice = Trader.TarotShop.VampirismCard.coins,
      Type = "tarotcard",
      CardType = "Vampirism"
    },
    {
      Name = TXT.PainShop.HealthRegenCard or "Health Regen",
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.HealthRegenCard.souls,
      CoinPrice = Trader.TarotShop.HealthRegenCard.coins,
      Type = "tarotcard", 
      CardType = "HealthRegen"
    },
    {
      Name = TXT.PainShop.ArmorRegenCard or "Armor Regen",
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.ArmorRegenCard.souls,
      CoinPrice = Trader.TarotShop.ArmorRegenCard.coins,
      Type = "tarotcard",
      CardType = "ArmorRegen"
    },
    {
      Name = TXT.PainShop.AmmoBoostCard or "Ammo Boost",
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.AmmoBoostCard.souls,
      CoinPrice = Trader.TarotShop.AmmoBoostCard.coins,
      Type = "tarotcard",
      CardType = "AmmoBoost"
    },
    {
      Name = TXT.PainShop.SoulCatchDistance or "Soul Catch Distance",
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.SoulCatchDistance.souls,
      CoinPrice = Trader.TarotShop.SoulCatchDistance.coins,
      Type = "tarotcard",
      CardType = "SoulCatchDistance"
    },
    {
      Name = TXT.PainShop.RepairArmor or "Repair Armor", -- Ремонт брони (автоматически по типу)
      Available = 1,
      Info = "",
      SoulPrice = Trader.TarotShop.RepairArmor.souls,
      CoinPrice = Trader.TarotShop.RepairArmor.coins,
      Type = "repair",
      RepairType = "Auto"
    },
  }

  Top.Sub = Items
  return Top
end

function Trader:BuySelectedItem(item)
  if not Player then return end
  
    local useInventory = true -- Можно сделать настройкой или проверять по клавише-модификатору
    
    if useInventory and Inventory then
        -- Покупаем в инвентарь вместо прямого использования
        if Inventory:AddFromTrader(item) then
            -- Списание средств
            if self._CoinShopOpen then
                Game.PlayerMoney = (Game.PlayerMoney or 0) - item.Price
            elseif self._TarotShopOpen then
                if Player then Player.SoulsCount = (Player.SoulsCount or 0) - item.SoulPrice end
                Game.PlayerMoney = (Game.PlayerMoney or 0) - item.CoinPrice
            else
                if Player then Player.SoulsCount = (Player.SoulsCount or 0) - item.Price end
            end
            PlaySound2D("menu/magicboard/money-end_transaction")
            CONSOLE.AddMessage("Item added to inventory: " .. item.Name)
            return
        end
    end

  local tarotBuffs = {
    Vampirism = {key = "Vampirism", purchased = Game.PurchasedBuffs.Vampirism},
    HealthRegen = {key = "HealthRegen1", purchased = Game.PurchasedBuffs.HealthRegen1},
    ArmorRegen = {key = "ArmorRegen1", purchased = Game.PurchasedBuffs.ArmorRegen1},
    AmmoBoost = {key = "AmmoBoost", purchased = Game.PurchasedBuffs.AmmoBoost},
    SoulCatchDistance1 = {key = "SoulCatchDistance1", purchased = Game.PurchasedBuffs.SoulCatchDistance1},
  }
  
  local isTarotBuff = false
  local buffAlreadyPurchased = false
  
  for buffName, buffData in tarotBuffs do
    if item.CardType == buffName then
      isTarotBuff = true
      if buffData.purchased then
        buffAlreadyPurchased = true
      end
      break
    end
  end
  
  if isTarotBuff and buffAlreadyPurchased then
    CONSOLE.AddMessage(TXT.PainShop.AlreadyPurchased or "This buff is already purchased!")
    PlaySound2D("misc/card-cannot_use")
    return
  end
  
  if self._CoinShopOpen then
    local currencyAmount = coinsAmount
    local double = Game.CardsSelected[20]
    local priceCoinTable = double and Trader.DiscountCoinPrices or Trader.CoinPrices
    local hasDarkSoulCard = Game.CardsSelected[16]
    local priceTable = hasDarkSoulCard and Trader.DiscountPrices or Trader.NormalPrices
    
    local actualItem = item
    local actualPrice = item.Price
    local isAlternative = false
    
    if item.Type == "weapon" then
      local weaponSlot = nil
      
      if item.WeaponType == "IBoltGunHeater" then
        weaponSlot = 7
      elseif item.WeaponType == "IRifleFlameThrower" then
        weaponSlot = 6
      elseif item.WeaponType == "IHellGun" then
        weaponSlot = 8
      elseif item.WeaponType == "IDevastator" then
        weaponSlot = 9
      end
      
      if weaponSlot and Player.EnabledWeapons[weaponSlot] then
        isAlternative = true
        
        if item.WeaponType == "IBoltGunHeater" then
          actualItem = {
            Type = "armor",
            ArmorType = "ArmorMedium",
            Name = TXT.PainShop.ArmorSr or "Silver Armor",
            Price = priceCoinTable.ArmorSr,
          }
          actualPrice = priceCoinTable.ArmorSr
        elseif item.WeaponType == "IRifleFlameThrower" then
          actualItem = {
            Type = "health", 
            HealthType = "MegaHealth",
            Name = TXT.PainShop.MegaHealth or "Mega Health",
            Price = priceCoinTable.MegaHealth,
          }
          actualPrice = priceCoinTable.MegaHealth
        elseif item.WeaponType == "IHellGun" then
          actualItem = {
            Type = "ammo", 
            AmmoType = "MegaPack",
            Name = TXT.PainShop.MegaPack or "MegaPack",
            Price = priceCoinTable.MegaPack,
          }
          actualPrice = priceCoinTable.MegaPack
        elseif item.WeaponType == "IDevastator" then
          actualItem = {
            Type = "bonus", 
            BonusType = "Quad",
            Name = TXT.PainShop.Quad1 or "Morph",
            Price = priceCoinTable.Quad1,
          }
          actualPrice = priceCoinTable.Quad1
        end
        
        CONSOLE.AddMessage((TXT.PainShop.AlreadyHave or "Already have") .. ": " .. item.Name)
        CONSOLE.AddMessage((TXT.PainShop.ReplacedWith or "Replaced with") .. ": " .. actualItem.Name)
      end
    end
    
    if currencyAmount < actualPrice then
      CONSOLE.AddMessage(TXT.PainShop.Nedostack or "Not enough currency")
      PlaySound2D("misc/card-cannot_use")
      return
    end
    
    if actualItem.Type == "ammo" then
      Player.Ammo[actualItem.AmmoType] = (Player.Ammo[actualItem.AmmoType] or 0) + (actualItem.AmmoAdd or 1)
      Player:CheckMaxAmmo()
      PlaySound2D("weapons/Picks/pickup_ammo_generic")
      
      local ammoPickup = GObjects:Add(TempObjName(), CloneTemplate(actualItem.AmmoType..".CItem"))
      ammoPickup.Pos:Set(Player.Pos:Get())
      ammoPickup.NotCountable = true
      if ammoPickup.Apply then ammoPickup:Apply() end
      
    elseif actualItem.Type == "armor" then
      PlaySound2D("items/item-shield-medium")
      
      local armorPickup = GObjects:Add(TempObjName(), CloneTemplate(actualItem.ArmorType.. ".CItem"))
      armorPickup.Pos:Set(Player.Pos:Get())
      armorPickup.NotCountable = true
      if armorPickup.Apply then armorPickup:Apply() end
      
    elseif actualItem.Type == "health" then
      PlaySound2D("items/item-soul-gold")
      
      local healthPickup = GObjects:Add(TempObjName(), CloneTemplate(actualItem.HealthType.. ".CItem"))
      healthPickup.Pos:Set(Player.Pos:Get())
      healthPickup.NotCountable = true
      healthPickup:Apply()
      
    elseif actualItem.Type == "weapon" then
      PlaySound2D("weapons/Picks/pickup_weapon_generic")
      
      local weaponPickup = GObjects:Add(TempObjName(), CloneTemplate(actualItem.WeaponType.. ".CItem"))
      weaponPickup.Pos:Set(Player.Pos:Get())
      weaponPickup:Apply()
    elseif actualItem.Type == "bonus" then
      PlaySound2D("items/item-soul-gold")

      local bonusPickup = GObjects:Add(TempObjName(), CloneTemplate(actualItem.BonusType.. ".CItem"))
      bonusPickup.Pos:Set(Player.Pos:Get())
      bonusPickup:Apply()
    end
    
    Game.PlayerMoney = currencyAmount - actualPrice
    
    PlaySound2D("menu/magicboard/money-end_transaction")

    if isAlternative then
      CONSOLE.AddMessage((TXT.PainShop.Buy or "Buy") .. ": " .. actualItem.Name)
    else
      CONSOLE.AddMessage((TXT.PainShop.Buy or "Buy") .. ": " .. actualItem.Name)
    end

    Player:PickupFX()
    
  elseif self._TarotShopOpen then
    if soulsAmount < item.SoulPrice or coinsAmount < item.CoinPrice then
      CONSOLE.AddMessage(TXT.PainShop.Nedostack or "Not enough currency")
      PlaySound2D("misc/card-cannot_use")
      return
    end
    
    if isTarotBuff and buffAlreadyPurchased then
      CONSOLE.AddMessage(TXT.PainShop.AlreadyPurchased or "This buff is already purchased!")
      PlaySound2D("misc/card-cannot_use")
      return
    end
    
    Player.SoulsCount = soulsAmount - item.SoulPrice
    Game.PlayerMoney = coinsAmount - item.CoinPrice
    
    if item.Type == "exchange" then
      PlaySound2D("menu/magicboard/money-end_transaction")
      if item.ExchangeType == "SoulToCoin" then
        Game.PlayerMoney = coinsAmount - item.CoinPrice + item.GetCoins
        CONSOLE.AddMessage(string.format(TXT.PainShop.Exchanged or "Exchanged", item.SoulPrice, TXT.PainShop.Souls or "Souls", TXT.PainShop.Na or "", item.GetCoins, TXT.PainShop.Coins or "Coins"))
      elseif item.ExchangeType == "CoinToSoul" then
        Player.SoulsCount = soulsAmount - item.SoulPrice + item.GetSouls
        CONSOLE.AddMessage(string.format(TXT.PainShop.Exchanged or "Exchanged", item.CoinPrice, TXT.PainShop.Coins or "Coins", TXT.PainShop.Na or "", item.GetSouls, TXT.PainShop.Souls or "Souls"))
      end
      
    elseif item.Type == "tarotcard" then
      PlaySound2D("misc/card-pickup")
      if item.CardType == "Vampirism" and not Game.PurchasedBuffs.Vampirism then
        Game.PurchasedBuffs.Vampirism = true
        Game:ApplyPurchasedBuffs()
        CONSOLE.AddMessage(TXT.PainShop.VampirismCardAcquired or "Vampirism acquired!")
      elseif item.CardType == "HealthRegen" and not Game.PurchasedBuffs.HealthRegen1 then
        Game.PurchasedBuffs.HealthRegen1 = true
        Game:ApplyPurchasedBuffs()
        CONSOLE.AddMessage(TXT.PainShop.HealthRegenCardAcquired or "Health regen acquired!")
      elseif item.CardType == "ArmorRegen" and not Game.PurchasedBuffs.ArmorRegen1 then
        Game.PurchasedBuffs.ArmorRegen1 = true
        Game:ApplyPurchasedBuffs()
        CONSOLE.AddMessage(TXT.PainShop.ArmorRegenCardAcquired or "Armor regen acquired!")
      elseif item.CardType == "AmmoBoost" and not Game.PurchasedBuffs.AmmoBoost then
        Game.PurchasedBuffs.AmmoBoost = true
        Game:ApplyPurchasedBuffs()
        CONSOLE.AddMessage(TXT.PainShop.AmmoBoostCardAcquired or "Ammo boost acquired!")
      elseif item.CardType == "SoulCatchDistance" and not Game.PurchasedBuffs.SoulCatchDistance1 then
        Game.PurchasedBuffs.SoulCatchDistance1 = true
        Game:ApplyPurchasedBuffs()
        CONSOLE.AddMessage(TXT.PainShop.SoulCardAcquired or "Soul Catch Distance acquired!")
      else
        CONSOLE.AddMessage(TXT.PainShop.AlreadyPurchased or "This buff is already purchased!")
        Player.SoulsCount = soulsAmount
        Game.PlayerMoney = coinsAmount
        return
      end
    elseif item.Type == "repair" then
      PlaySound2D("items/item-shield-medium")
      if Player.ArmorType == 1 then
        Player.Armor = math.min(Player.Armor + 50, 50)
        CONSOLE.AddMessage(TXT.PainShop.BronzeArmorRepaired or "Bronze armor repaired!")
      elseif Player.ArmorType == 2 then
        Player.Armor = math.min(Player.Armor + 100, 100)
        CONSOLE.AddMessage(TXT.PainShop.SilverArmorRepaired or "Silver armor repaired!")
      elseif Player.ArmorType == 3 then
        Player.Armor = math.min(Player.Armor + 155, 155)
        CONSOLE.AddMessage(TXT.PainShop.GoldArmorRepaired or "Gold armor repaired!")
      else
        CONSOLE.AddMessage(TXT.PainShop.NoArmorToRepair or "No armor to repair!")
        Player.SoulsCount = soulsAmount
        Game.PlayerMoney = coinsAmount
        return
      end
      
    elseif item.Type == "combine" then --Возможно верну
      PlaySound2D("specials/bullet-time/bullet-time-start")
      local availableUpgrades = {}
      if Game.CardsSelected[16] then table.insert(availableUpgrades, "DarkSoul") end
      if Game.CardsSelected[20] then table.insert(availableUpgrades, "DoubleGold") end
      
      if table.getn(availableUpgrades) > 0 then
        local randomUpgrade = availableUpgrades[math.random(1, table.getn(availableUpgrades))]
        if randomUpgrade == "DarkSoul" then
          Game.Demon_HowManyCorpses = 35 
          Game.Demon_Counter = Game.Demon_HowManyCorpses
          CONSOLE.AddMessage(TXT.PainShop.DarkSoulCombined or "Dark Soul combined!")
        elseif randomUpgrade == "DoubleGold" then
          CONSOLE.AddMessage(TXT.PainShop.DoubleGoldCombined or "Double Gold combined!")
        end
      else
        CONSOLE.AddMessage(TXT.PainShop.NoCardsToCombine or "No cards to combine!")
        Player.SoulsCount = soulsAmount
        Game.PlayerMoney = coinsAmount
        return
      end
    end
    
    PlaySound2D("menu/magicboard/money-end_transaction")
    CONSOLE.AddMessage((TXT.PainShop.Buy or "Buy") .. ": " .. item.Name)
    Player:PickupFX()
    
  else
    local currencyAmount = soulsAmount
    local hasDarkSoulCard = Game.CardsSelected[16]
    local priceTable = hasDarkSoulCard and Trader.DiscountPrices or Trader.NormalPrices
    
    if currencyAmount < item.Price then
      CONSOLE.AddMessage(TXT.PainShop.Nedostack or "Not enough currency")
      PlaySound2D("misc/card-cannot_use")
      return
    end
    
    if item.Type == "ammo" then
      Player.Ammo[item.AmmoType] = (Player.Ammo[item.AmmoType] or 0) + (item.Amount or 1)
      Player:CheckMaxAmmo()
      PlaySound2D("weapons/Picks/pickup_ammo_generic")
      
      local ammoPickup = GObjects:Add(TempObjName(), CloneTemplate(item.AmmoType..".CItem"))
      ammoPickup.Pos:Set(Player.Pos:Get())
      ammoPickup.NotCountable = true
      if ammoPickup.Apply then ammoPickup:Apply() end
      
    elseif item.Type == "armor" then
      PlaySound2D("items/item-shield-medium")
      
      local armorPickup = GObjects:Add(TempObjName(), CloneTemplate(item.ArmorType.. ".CItem"))
      armorPickup.Pos:Set(Player.Pos:Get())
      armorPickup.NotCountable = true
      if armorPickup.Apply then armorPickup:Apply() end
      
    elseif item.Type == "health" then
      PlaySound2D("items/item-soul-gold")
      
      local healthPickup = GObjects:Add(TempObjName(), CloneTemplate(item.HealthType.. ".CItem"))
      healthPickup.Pos:Set(Player.Pos:Get())
      healthPickup.NotCountable = true
      healthPickup:Apply()
    end
    
    Player.SoulsCount = currencyAmount - item.Price
    PlaySound2D("menu/magicboard/money-end_transaction")
    CONSOLE.AddMessage((TXT.PainShop.Buy or "Buy") .. ": " .. item.Name)
    Player:PickupFX()
  end
end

