--=======================================================================
-- By 7ZOV
--=======================================================================

Inventory = {
    -- Flags
    IsOpen = false,
    
    -- Grid settings
    GridCols = 8,
    GridRows = 4,
    SlotSize = 64,
    SlotSpacing = 4,
    GridStartX = 0,
    GridStartY = 0,

    TestItemsAdded = false,
    
    -- Pages
    CurrentPage = 1,
    ItemsPerPage = 32, -- 8 cols x 4 rows
    
    -- Items
    Items = {},
    MaxSlots = 32,
    CurrentSelection = 1,
    
    -- Visual
    Colors = {
        Header        = {40, 60, 80},
        SlotEmpty     = {20, 20, 20},
        SlotBorder    = {60, 60, 60},
        SlotHighlight = {100, 150, 200},
        Text          = {230, 161, 97},
        Equipped      = {0, 255, 0},
        Quantity      = {200, 200, 200},
        Highlight     = {214, 0, 23},
        Border        = {230, 161, 97}
    },
    
    -- Equipped weapons tracking
    EquippedWeapons = {},
    
    -- Rounded corners
    CornerRadius = 10
}

-- Item types
Inventory.ItemTypes = {
    WEAPON = "weapon",
    AMMO = "ammo",
    ARMOR = "armor",
    HEALTH = "health",
    QUEST = "quest",
    KEY = "key"
}

-- Item template
Inventory.ItemTemplate = {
    id = "",
    name = "",
    type = "",
    model = nil,
    icon = nil,
    count = 1,
    maxCount = 999,
    description = "",
    usable = true,
    droppable = true,
    weaponSlot = nil,
    weaponType = nil,
    ammoType = nil,
    ammoAmount = 0,
    armorType = nil,
    armorAmount = 0,
    healthAmount = 0
}

--=======================================================================
-- Initialize
--=======================================================================
function Inventory:Init()
    self:LoadIcons()
    self:LoadFromProfile()
    self:UpdateEquippedWeapons()
    
    if not IsFinalBuild() and not self.TestItemsAdded then
        self:AddTestItems()
        self.TestItemsAdded = true
        CONSOLE.AddMessage("Test items added to inventory")
    end
    
    CONSOLE.AddMessage("Inventory System initialized")
end

--=======================================================================
-- Load icons
--=======================================================================
function Inventory:LoadIcons()
    local texFlags = TextureFlags.NoLOD + TextureFlags.NoMipMaps
    
    self.Icons = {}
    self.Icons.weapon = MATERIAL.Create("HUD/minigun", texFlags)
    self.Icons.ammo = MATERIAL.Create("HUD/shell", texFlags)
    self.Icons.armor = MATERIAL.Create("HUD/gwiazdka", texFlags)
    self.Icons.health = MATERIAL.Create("HUD/energia", texFlags)
    self.Icons.key = MATERIAL.Create("HUD/ikona_grabber", texFlags)
    self.Icons.default = MATERIAL.Create("HUD/ikona_electro", texFlags)
    
    -- Weapons
    self.Icons.shotgun = MATERIAL.Create("HUD/shell", texFlags)
    self.Icons.stakegun = MATERIAL.Create("HUD/kolki", texFlags)
    self.Icons.minigun = MATERIAL.Create("HUD/minigun", texFlags)
    self.Icons.driverelectro = MATERIAL.Create("HUD/ikona_electro", texFlags)
    self.Icons.rifle = MATERIAL.Create("HUD/rifle", texFlags)
    self.Icons.boltgun = MATERIAL.Create("HUD/bolty", texFlags)
    self.Icons.hellgun = MATERIAL.Create("HUD/ikona_flamer", texFlags)
    self.Icons.devastator = MATERIAL.Create("HUD/rocket", texFlags)
    
    -- Items
    self.Icons.shells = MATERIAL.Create("HUD/shell", texFlags)
    self.Icons.healthPotion = MATERIAL.Create("HUD/energia", texFlags)
    self.Icons.armorWeak = MATERIAL.Create("HUD/gwiazdka", texFlags)
    self.Icons.armorMedium = MATERIAL.Create("HUD/gwiazdka", texFlags)
    self.Icons.armorStrong = MATERIAL.Create("HUD/gwiazdka", texFlags)
end

--=======================================================================
-- Draw rounded rectangle using squares
--=======================================================================
function Inventory:DrawRoundedRect(x, y, w, h, r, g, b, alpha, radius)
    if not radius then radius = self.CornerRadius end
    if w < radius * 2 then w = radius * 2 end
    if h < radius * 2 then h = radius * 2 end
    
    -- Main rectangle
    HUD.DrawQuadRGBA(nil, x + radius, y, w - radius * 2, h, r, g, b, alpha)
    
    -- Clear corners
    local i
    for i = 1, radius do
        local step = radius - i
        -- Top-left
        HUD.DrawQuadRGBA(nil, x + i - 1, y + step, 1, 1, 0, 0, 0, 0)
        HUD.DrawQuadRGBA(nil, x + step, y + i - 1, 1, 1, 0, 0, 0, 0)
        
        -- Top-right
        HUD.DrawQuadRGBA(nil, x + w - i, y + step, 1, 1, 0, 0, 0, 0)
        HUD.DrawQuadRGBA(nil, x + w - step - 1, y + i - 1, 1, 1, 0, 0, 0, 0)
        
        -- Bottom-left
        HUD.DrawQuadRGBA(nil, x + i - 1, y + h - step - 1, 1, 1, 0, 0, 0, 0)
        HUD.DrawQuadRGBA(nil, x + step, y + h - i, 1, 1, 0, 0, 0, 0)
        
        -- Bottom-right
        HUD.DrawQuadRGBA(nil, x + w - i, y + h - step - 1, 1, 1, 0, 0, 0, 0)
        HUD.DrawQuadRGBA(nil, x + w - step - 1, y + h - i, 1, 1, 0, 0, 0, 0)
    end
end

--=======================================================================
-- Update equipped weapons from player
--=======================================================================
function Inventory:UpdateEquippedWeapons()
    self.EquippedWeapons = {}
    
    if Player and Player.EnabledWeapons then
        for slot, weaponType in pairs(Player.EnabledWeapons) do
            if weaponType and weaponType ~= true then
                table.insert(self.EquippedWeapons, {
                    slot = slot,
                    type = weaponType
                })
            end
        end
    end
end

--=======================================================================
-- Check if item is equipped
--=======================================================================
function Inventory:IsItemEquipped(item)
    if item.type ~= self.ItemTypes.WEAPON then
        return false
    end
    
    local i
    for i = 1, table.getn(self.EquippedWeapons) do
        local equipped = self.EquippedWeapons[i]
        if item.weaponType == equipped.type then
            return true
        end
    end
    
    return false
end

--=======================================================================
-- Draw item icon/model in slot 
--=======================================================================
function Inventory:DrawItemInSlot(item, x, y, size)
    if not item then return end
    
    -- Для теста используем одну и ту же иконку для всех предметов
    -- Просто рисуем цветной квадрат в зависимости от типа предмета
    local color = self.Colors.SlotEmpty
    
    if item.type == self.ItemTypes.WEAPON then
        color = {200, 100, 100}  -- Красноватый для оружия
    elseif item.type == self.ItemTypes.AMMO then
        color = {100, 200, 100}  -- Зеленоватый для патронов
    elseif item.type == self.ItemTypes.HEALTH then
        color = {100, 100, 200}  -- Синеватый для здоровья
    elseif item.type == self.ItemTypes.ARMOR then
        color = {200, 200, 100}  -- Желтоватый для брони
    else
        color = {150, 150, 150}  -- Серый для всего остального
    end
    
    -- Рисуем цветной квадрат вместо иконки
    HUD.DrawQuadRGBA(nil, x + 5, y + 5, size - 10, size - 10, 
                    color[1], color[2], color[3], 255)
    
    -- Рисуем первую букву типа предмета для большей наглядности
    HUD.SetFont("courbd", 20)
    local letter = string.sub(item.type, 1, 1)
    letter = string.upper(letter)
    local letterWidth = HUD.GetTextWidth(letter, "courbd", 20)
    HUD.PrintXY(x + (size - letterWidth)/2, y + (size - 20)/2, 
                letter, "courbd", 255, 255, 255, 20)
    
    -- Draw quantity
    if item.count > 1 then
        HUD.SetFont("courbd", 14)
        local qtyText = "x" .. item.count
        local qtyWidth = HUD.GetTextWidth(qtyText, "courbd", 14)
        HUD.PrintXY(x + size - qtyWidth - 4, y + size - 16, qtyText, "courbd",
                   self.Colors.Quantity[1], self.Colors.Quantity[2], self.Colors.Quantity[3], 14)
    end
    
    -- Draw equipped indicator
    if self:IsItemEquipped(item) then
        HUD.DrawQuadRGBA(nil, x + 2, y + 2, 8, 8,
                        self.Colors.Equipped[1], self.Colors.Equipped[2], self.Colors.Equipped[3], 255)
        HUD.SetFont("courbd", 10)
        HUD.PrintXY(x + 2, y + 2, "EQ", "courbd",
                   self.Colors.Equipped[1], self.Colors.Equipped[2], self.Colors.Equipped[3], 10)
    end
end

--=======================================================================
-- Draw inventory grid
--=======================================================================
function Inventory:DrawGrid()
    if not self.GridStartX or not self.GridStartY then return end
    
    local startIndex = (self.CurrentPage - 1) * self.ItemsPerPage
    local slotIndex = 0
    local totalItems = table.getn(self.Items)
    
    -- Для отладки
    -- CONSOLE.AddMessage("Drawing grid, CurrentSelection: " .. self.CurrentSelection .. ", Page: " .. self.CurrentPage)
    
    for row = 0, self.GridRows - 1 do
        for col = 0, self.GridCols - 1 do
            local slotNum = startIndex + slotIndex + 1
            local x = self.GridStartX + col * (self.SlotSize + self.SlotSpacing)
            local y = self.GridStartY + row * (self.SlotSize + self.SlotSpacing)
            
            -- Slot background
            local slotColor = self.Colors.SlotEmpty
            local borderColor = self.Colors.SlotBorder
            
            -- Highlight selected slot (проверяем точное совпадение номера слота)
            if slotNum == self.CurrentSelection then
                borderColor = self.Colors.SlotHighlight
                -- Для отладки
                -- CONSOLE.AddMessage("Highlighting slot " .. slotNum .. " at page " .. self.CurrentPage)
            end
            
            -- Draw slot
            HUD.DrawQuadRGBA(nil, x, y, self.SlotSize, self.SlotSize,
                           slotColor[1], slotColor[2], slotColor[3], 200)
            
            -- Border (обычная рамка)
            HUD.DrawQuadRGBA(nil, x, y, self.SlotSize, 1,
                           borderColor[1], borderColor[2], borderColor[3], 255)
            HUD.DrawQuadRGBA(nil, x, y + self.SlotSize - 1, self.SlotSize, 1,
                           borderColor[1], borderColor[2], borderColor[3], 255)
            HUD.DrawQuadRGBA(nil, x, y, 1, self.SlotSize,
                           borderColor[1], borderColor[2], borderColor[3], 255)
            HUD.DrawQuadRGBA(nil, x + self.SlotSize - 1, y, 1, self.SlotSize,
                           borderColor[1], borderColor[2], borderColor[3], 255)
            
            -- Для выделенного слота добавляем дополнительную подсветку
            if slotNum == self.CurrentSelection then
                -- Внутренняя рамка для лучшей видимости
                HUD.DrawQuadRGBA(nil, x + 2, y + 2, self.SlotSize - 4, 2,
                               borderColor[1], borderColor[2], borderColor[3], 200)
                HUD.DrawQuadRGBA(nil, x + 2, y + self.SlotSize - 4, self.SlotSize - 4, 2,
                               borderColor[1], borderColor[2], borderColor[3], 200)
                HUD.DrawQuadRGBA(nil, x + 2, y + 2, 2, self.SlotSize - 4,
                               borderColor[1], borderColor[2], borderColor[3], 200)
                HUD.DrawQuadRGBA(nil, x + self.SlotSize - 4, y + 2, 2, self.SlotSize - 4,
                               borderColor[1], borderColor[2], borderColor[3], 200)
            end
            
            -- Item
            if slotNum <= totalItems then
                local item = self.Items[slotNum]
                self:DrawItemInSlot(item, x, y, self.SlotSize)
            end
            
            slotIndex = slotIndex + 1
        end
    end
end

--=======================================================================
-- Draw main inventory menu
--=======================================================================
function Inventory:DrawMenu()
    if not self.IsOpen then return end
    local w, h = R3D.ScreenSize()

    -- Grid dimensions
    local gridWidth = self.GridCols * (self.SlotSize + self.SlotSpacing) - self.SlotSpacing
    local gridHeight = self.GridRows * (self.SlotSize + self.SlotSpacing) - self.SlotSpacing

    -- Center grid
    local gridX = (w - gridWidth) / 2
    local gridY = (h - gridHeight) / 2 + 5

    -- MAIN BACKGROUND (one big panel)
    local bgWidth = gridWidth + 320  -- Увеличил ширину фона
    local bgHeight = gridHeight + 120
    local bgX = gridX - 160
    local bgY = gridY - 50

    -- Draw main background with rounded corners
    self:DrawRoundedRect(bgX, bgY, bgWidth, bgHeight, 0, 0, 0, 220, 15)

    -- TITLE - по центру
    HUD.SetFont("timesbd", 32)
    local title = "INVENTORY"
    local titleWidth = HUD.GetTextWidth(title, "timesbd", 32)
    HUD.PrintXY((w - titleWidth) / 2, bgY + 12, title, "timesbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 32)

    -- STATS (top right) - ближе к заголовку
    local statsX = bgX + bgWidth - 150
    local statsY = bgY + 15

    HUD.SetFont("courbd", 14)
    local totalPages = math.max(1, math.ceil(table.getn(self.Items) / self.ItemsPerPage))
    local pageText = string.format("Page: %d/%d", self.CurrentPage, totalPages)
    HUD.PrintXY(statsX, statsY, pageText, "courbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 14)

    local slotsText = string.format("Slots: %d/%d", table.getn(self.Items), self.MaxSlots)
    HUD.PrintXY(statsX, statsY + 18, slotsText, "courbd",
                self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 14)

    -- DIVIDER LINE
    local lineY = bgY + 48
    HUD.DrawQuadRGBA(nil, bgX + 20, lineY, bgWidth - 40, 2,
                    self.Colors.Border[1], self.Colors.Border[2], self.Colors.Border[3], 255)

    -- SET GRID POSITION
    self.GridStartX = gridX
    self.GridStartY = gridY

    -- DRAW GRID
    self:DrawGrid()

    -- LEFT PANEL (player info) - чуть ниже
    local leftX = bgX + 20
    local leftY = gridY
    self:DrawPlayerInfo(leftX, leftY, 140, gridHeight)

    -- RIGHT PANEL (equipped items) - придвинул ближе
    local rightX = gridX + gridWidth + 20
    local rightY = gridY
    self:DrawEquippedList(rightX, rightY, gridHeight)

    -- ITEM DESCRIPTION (below grid)
    local descY = gridY + gridHeight + 15 
    self:DrawItemDescription(gridX, descY, gridWidth)

    -- CONTROLS (bottom)
    self:DrawControls(bgY + bgHeight - 22)
end

--=======================================================================
-- Draw player info panel (left side)
--=======================================================================
function Inventory:DrawPlayerInfo(x, y, width, gridHeight)
    if not Player then return end

    -- HEALTH
    HUD.SetFont("courbd", 12)
    HUD.PrintXY(x + 8, y + 10, "HEALTH", "courbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 12)

    local healthMax = Game.HealthCapacity or 100
    local healthPercent = Player.Health / healthMax
    local healthColor = {255, 255, 255}  -- Всегда белый текст
    if healthPercent > 0.5 then
        healthColor = {0, 255, 0}  -- Зеленый если HP > 50%
    elseif healthPercent > 0.25 then
        healthColor = {255, 255, 0}  -- Желтый если HP > 25%
    else
        healthColor = {255, 0, 0}  -- Красный если HP < 25%
    end

    HUD.PrintXY(x + 8, y + 25, string.format("%d/%d", math.floor(Player.Health), healthMax), "courbd",
                healthColor[1], healthColor[2], healthColor[3], 14)

    -- Health bar background
    HUD.DrawQuadRGBA(nil, x + 8, y + 42, 120, 8, 40, 40, 40, 255)
    -- Health bar fill
    HUD.DrawQuadRGBA(nil, x + 8, y + 42, 120 * healthPercent, 8,
                    healthColor[1], healthColor[2], healthColor[3], 255)

    -- ARMOR
    local armorY = y + 58
    HUD.PrintXY(x + 8, armorY, "ARMOR", "courbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 12)

    local armorMax = 0
    local armorName = "None"
    local armorColor = {100, 100, 100}

    if Player.ArmorType == 1 then
        armorMax = 75
        armorName = "Bronze"
        armorColor = {139, 90, 43}  -- Коричневый
    elseif Player.ArmorType == 2 then
        armorMax = 175
        armorName = "Silver"
        armorColor = {192, 192, 192}  -- Серебряный
    elseif Player.ArmorType == 3 then
        armorMax = 250
        armorName = "Gold"
        armorColor = {255, 215, 0}  -- Золотой
    end

    local armorText = string.format("%d/%d", math.floor(Player.Armor or 0), armorMax)
    if armorMax > 0 then
        armorText = armorText .. "  " .. armorName
    end

    HUD.PrintXY(x + 8, armorY + 15, armorText, "courbd",
                armorColor[1], armorColor[2], armorColor[3], 13)

    -- SOULS
    local soulsY = armorY + 42
    HUD.PrintXY(x + 8, soulsY, "SOULS", "courbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 12)
    HUD.PrintXY(x + 8, soulsY + 15, tostring(Player.SoulsCount or 0), "courbd",
                230, 161, 97, 14) 

    -- MONEY
    local moneyY = soulsY + 40
    HUD.PrintXY(x + 8, moneyY, "MONEY", "courbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 12)
    HUD.PrintXY(x + 8, moneyY + 15, tostring(Game.PlayerMoney or 0), "courbd",
                230, 161, 97, 14) 
end

--=======================================================================
-- Draw equipped items panel (right side)
--=======================================================================
function Inventory:DrawEquippedList(x, y, gridHeight)
    local panelWidth = 130  -- Уменьшил ширину как у левой панели

    -- Title (такой же шрифт как HEALTH/ARMOR и т.д.)
    HUD.SetFont("courbd", 12)
    HUD.PrintXY(x + 42, y + 10, "EQUIPPED", "courbd",
                self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 12)

    local yPos = y + 30
    HUD.SetFont("courbd", 11)

    local hasWeapons = false
    if Player and Player.EnabledWeapons then
        for slot = 1, 9 do
            if Player.EnabledWeapons[slot] and Player.EnabledWeapons[slot] ~= true then
                local weaponName = Player.EnabledWeapons[slot]
                -- Убираем префикс "I" если есть
                weaponName = string.gsub(weaponName, "^I", "")
                
                -- Формат: "1: Painkiller" (такой же как числа в статах)
                HUD.PrintXY(x - 6, yPos, slot .. ":" .. weaponName, "courbd",
                        self.Colors.Equipped[1], self.Colors.Equipped[2], self.Colors.Equipped[3], 11)
                yPos = yPos + 16
                hasWeapons = true
            end
        end
    end

    if not hasWeapons then
        HUD.PrintXY(x + 8, yPos, "None", "courbd",
                100, 100, 100, 11)
    end
end

--=======================================================================
-- Draw item description
--=======================================================================
function Inventory:DrawItemDescription(x, y, width)
    if self.CurrentSelection < 1 or self.CurrentSelection > table.getn(self.Items) then
        return
    end
    
    local item = self.Items[self.CurrentSelection]
    
    -- Description background
    --HUD.DrawQuadRGBA(nil, x, y, width, 50, 10, 10, 10, 200)
    
    HUD.SetFont("timesbd", 16)
    HUD.PrintXY(x + 10, y + 8, item.name, "timesbd",
               self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 16)
    
    HUD.SetFont("courbd", 12)
    local desc = item.description or "No description"
    HUD.PrintXY(x + 10, y + 30, desc, "courbd",
               self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 12)
end

--=======================================================================
-- Draw controls help
--=======================================================================
function Inventory:DrawControls(y)
    local w, h = R3D.ScreenSize()
    
    HUD.SetFont("courbd", 11)
    local controls = "ARROWS: Move | ENTER: Use | DEL: Drop | PGUP/PGDN: Page | I: Close"
    local controlsWidth = HUD.GetTextWidth(controls, "courbd", 11)
    HUD.PrintXY((w - controlsWidth) / 2, y + 30, controls, "courbd",
               150, 150, 150, 11)
end

--=======================================================================
-- Move selection in grid
--=======================================================================
function Inventory:MoveSelection(direction)
    --CONSOLE.AddMessage("MoveSelection called with direction: " .. direction)
    
    if not self.IsOpen then 
        CONSOLE.AddMessage("Inventory not open")
        return 
    end
    
    local totalItems = table.getn(self.Items)
    if totalItems == 0 then 
        CONSOLE.AddMessage("No items in inventory")
        return 
    end
    
    local oldSelection = self.CurrentSelection
    --CONSOLE.AddMessage("Current selection before move: " .. oldSelection)
    
    if direction == "up" then
        local newSelection = self.CurrentSelection - self.GridCols
        if newSelection >= 1 then
            self.CurrentSelection = newSelection
        else
            --CONSOLE.AddMessage("Cannot move up - would go below 1")
        end
    elseif direction == "down" then
        local newSelection = self.CurrentSelection + self.GridCols
        if newSelection <= totalItems then
            self.CurrentSelection = newSelection
        else
            --CONSOLE.AddMessage("Cannot move down - would exceed total items: " .. totalItems)
        end
    elseif direction == "left" then
        if self.CurrentSelection > 1 then
            self.CurrentSelection = self.CurrentSelection - 1
        else
            --CONSOLE.AddMessage("Cannot move left - already at left edge")
        end
    elseif direction == "right" then
        if self.CurrentSelection < totalItems then
            self.CurrentSelection = self.CurrentSelection + 1
        else
            --CONSOLE.AddMessage("Cannot move right - already at right edge")
        end
    end
    
    if oldSelection ~= self.CurrentSelection then
        CONSOLE.AddMessage("Selection changed to: " .. self.CurrentSelection)
        self:UpdatePageFromSelection()
        PlaySound2D("menu/menu_necro/scroller-move")
    else
        CONSOLE.AddMessage("Selection did not change")
    end
end

function Inventory:PickupNearestItem()
    -- Перенаправляем в UseSystem
    if UseSystem then
        UseSystem:FindTarget()
        return UseSystem:UseCurrentTarget()
    end
    return false
end

--=======================================================================
-- Handle input
--=======================================================================
function Inventory:HandleInput()
    if not self.IsOpen then return false end
    
    -- Стрелки - вызываем MoveSelection
    if INP.Key(Keys.Up) == 1 then
        self:MoveSelection("up")
        --CONSOLE.AddMessage("up")
        return true
    end
    
    if INP.Key(Keys.Down) == 1 then
        self:MoveSelection("down")
        --CONSOLE.AddMessage("down")
        return true
    end
    
    if INP.Key(Keys.Left) == 1 then
        self:MoveSelection("left")
        --CONSOLE.AddMessage("left")
        return true
    end
    
    if INP.Key(Keys.Right) == 1 then
        self:MoveSelection("right")
        --CONSOLE.AddMessage("right")
        return true
    end
    
    -- Цифры 1-9 для быстрого выбора
    local i
    for i = 1, 9 do
        local keyNum = Keys["Num" .. tostring(i)]
        local keyD = Keys["D" .. tostring(i)]
        if (keyNum and INP.Key(keyNum) == 1) or (keyD and INP.Key(keyD) == 1) then
            local totalItems = table.getn(self.Items)
            if totalItems > 0 then
                local slotNum = (self.CurrentPage - 1) * self.ItemsPerPage + i
                if slotNum <= totalItems then
                    self.CurrentSelection = slotNum
                    PlaySound2D("menu/menu_necro/scroller-move")
                end
            end
            return true
        end
    end
    
    -- PAGE UP - предыдущая страница
    if INP.Key(Keys.PageUp) == 1 then
        local totalPages = math.max(1, math.ceil(table.getn(self.Items) / self.ItemsPerPage))
        if self.CurrentPage > 1 then
            self.CurrentPage = self.CurrentPage - 1
            self.CurrentSelection = (self.CurrentPage - 1) * self.ItemsPerPage + 1
            if self.CurrentSelection > table.getn(self.Items) then
                self.CurrentSelection = table.getn(self.Items)
            end
            PlaySound2D("menu/menu_necro/scroller-move")
        end
        return true
    end
    
    -- PAGE DOWN - следующая страница
    if INP.Key(Keys.PageDown) == 1 then
        local totalPages = math.max(1, math.ceil(table.getn(self.Items) / self.ItemsPerPage))
        if self.CurrentPage < totalPages then
            self.CurrentPage = self.CurrentPage + 1
            self.CurrentSelection = (self.CurrentPage - 1) * self.ItemsPerPage + 1
            if self.CurrentSelection > table.getn(self.Items) then
                self.CurrentSelection = table.getn(self.Items)
            end
            PlaySound2D("menu/menu_necro/scroller-move")
        end
        return true
    end
    
    -- F - подобрать предмет с земли
    if INP.Key(Keys.F) == 1 then
        self:PickupNearestItem()
        return true
    end
    
    -- ENTER - использовать предмет
    if INP.Key(Keys.Enter) == 1 or INP.Key(Keys.NumlockEnter) == 1 then
        if table.getn(self.Items) > 0 and self.CurrentSelection <= table.getn(self.Items) then
            self:UseItem(self.CurrentSelection)
            self:UpdateEquippedWeapons()
        end
        return true
    end
    
    -- DELETE - выбросить предмет
    if INP.Key(Keys.Delete) == 1 then
        if table.getn(self.Items) > 0 and self.CurrentSelection <= table.getn(self.Items) then
            self:DropItem(self.CurrentSelection)
        end
        return true
    end
    
    if INP.Key(Keys.I) == 1 then
        return true
    end
    
    return false
end

--=======================================================================
-- Handle pickup for inventory (улучшенная версия)
--=======================================================================
function Inventory:HandlePickup(item, player, itemData)
    CONSOLE.AddMessage("Inventory:HandlePickup started")
    if not item or not player or not itemData then 
        CONSOLE.AddMessage("HandlePickup: invalid parameters")
        return false 
    end
    
    -- Определяем количество
    local count = 1
    if item.AmmoAdd and itemData.type == "AMMO" then
        count = item.AmmoAdd
    elseif item.HealthAdd and itemData.type == "HEALTH" then
        count = 1
    elseif item.ArmorAdd and itemData.type == "ARMOR" then
        count = 1
    end
    
    -- Создаем данные для добавления в инвентарь
    local invItem = {
        id = item._Name .. "_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        name = itemData.name,
        type = itemData.type,
        count = count,
        description = itemData.description or "No description",
        usable = true,
        droppable = true
    }
    
    -- Копируем специфичные поля
    if itemData.ammoType then
        invItem.ammoType = itemData.ammoType
        invItem.ammoAmount = itemData.ammoAmount or count
    end
    
    if itemData.armorType then
        invItem.armorType = itemData.armorType
        invItem.armorAmount = itemData.armorAmount or 50
    end
    
    if itemData.healthAmount then
        invItem.healthAmount = itemData.healthAmount or 25
    end
    
    if itemData.weaponType then
        invItem.weaponType = itemData.weaponType
        invItem.weaponSlot = itemData.weaponSlot
    end
    
    -- Для патронов проверяем, не превышен ли лимит в инвентаре
    if itemData.type == "AMMO" then
        -- Можно добавить проверку на максимальное количество в инвентаре
        -- Например, не больше 999 патронов одного типа
        local totalInInventory = 0
        for i, existingItem in ipairs(self.Items) do
            if existingItem.type == "AMMO" and existingItem.ammoType == itemData.ammoType then
                totalInInventory = totalInInventory + existingItem.count
            end
        end
        
        if totalInInventory + count > 999 then
            CONSOLE.AddMessage("Cannot carry more " .. itemData.name)
            return false
        end
    end
    
    if self:AddItem(invItem) then
        CONSOLE.AddMessage("Inventory:HandlePickup - success, item added")
        return true
    else
        CONSOLE.AddMessage("Inventory:HandlePickup - failed to add item")
        return false
    end
end

function Inventory:PatchItemTakeFunctions()
    local patched = 0
    
    for templateName, itemData in pairs(InventoryCfg.Lookup) do
        local template = Templates[templateName]
        if template then
            template.OnTake = function(self, player)
                if not player then return false end
                
                if Inventory and Inventory:HandlePickup(self, player, itemData) then
                    PlaySound2D("weapons/Picks/pickup_weapon_generic")
                    
                    -- Обновляем статистику если нужно
                    if not self.NotCountable then
                        if itemData.type == "AMMO" then
                            Game.PlayerAmmoFound = (Game.PlayerAmmoFound or 0) + (self.AmmoAdd or 1)
                        elseif itemData.type == "ARMOR" then
                            -- Для брони
                        elseif itemData.type == "HEALTH" then
                            -- Для здоровья
                        elseif itemData.type == "WEAPON" then
                            -- Для оружия
                        end
                    end
                    
                    GObjects:ToKill(self)
                    return true
                else
                    CONSOLE.AddMessage("Inventory full! Cannot pick up " .. (itemData.name or templateName))
                    PlaySound2D("misc/card-cannot_use")
                    return false
                end
            end
            
            patched = patched + 1
        end
    end
    
    CONSOLE.AddMessage("Patched " .. patched .. " item pickup functions")
end


--=======================================================================
-- Update page based on current selection
--=======================================================================
function Inventory:UpdatePageFromSelection()
    self.CurrentPage = math.floor((self.CurrentSelection - 1) / self.ItemsPerPage) + 1
end

--=======================================================================
-- Toggle inventory
--=======================================================================
function Inventory:Toggle()
    if Game.IsDemon then
        CONSOLE.AddMessage("Cannot open inventory in demon form")
        return
    end
    
    if Game.Difficulty < 3 then
        CONSOLE.AddMessage("Inventory available only on Trauma difficulty!")
        PlaySound2D("misc/card-cannot_use")
        return
    end
    
    self.IsOpen = not self.IsOpen
    
    if self.IsOpen then
        self:Open()
    else
        self:Close()
    end
end

--=======================================================================
-- Open inventory
--=======================================================================
function Inventory:Open()
    
    self.IsOpen = true
    self:UpdateEquippedWeapons()
    
    if table.getn(self.Items) > 0 then
        self.CurrentSelection = 1
    else
        self.CurrentSelection = 1
    end
    self.CurrentPage = 1
    
    if Player then
        Player.Frozen = true
    end
    
    Hud.Enabled = false
    Game.CameraFromPlayer = false
    
    PlaySound2D("menu/mapselect/option-accept")
    CONSOLE.AddMessage("Inventory opened")
end
--=======================================================================
-- Close inventory
--=======================================================================
function Inventory:Close()
    self.IsOpen = false
    
    if Player then
        Player.Frozen = false
    end
    
    Hud.Enabled = true
    Game.CameraFromPlayer = true
    
    PlaySound2D("menu/menu_necro/scroller-move")
    CONSOLE.AddMessage("Inventory closed")
    self:SaveToProfile()
end

--=======================================================================
-- Add item
--=======================================================================
function Inventory:AddItem(itemData)
    if not itemData or not itemData.id then
        CONSOLE.AddMessage("ERROR: Invalid item data")
        return false
    end
    
    local lookupKey = itemData.id
    if itemData.type == "AMMO" and itemData.ammoType then
        lookupKey = "AMMO_" .. itemData.ammoType
    end
    
    local i
    for i = 1, table.getn(self.Items) do
        local item = self.Items[i]
        
        if itemData.type == "AMMO" and itemData.ammoType then
            if item.type == "AMMO" and item.ammoType == itemData.ammoType then
                if item.count < item.maxCount then
                    local addCount = itemData.count or 1
                    item.count = math.min(item.count + addCount, item.maxCount)
                    -- CONSOLE.AddMessage("Added to stack: " .. item.name .. " x" .. tostring(addCount))
                    return true
                else
                    CONSOLE.AddMessage("Cannot add more: " .. item.name .. " (stack full)")
                    return false
                end
            end
        else
            if item.id == itemData.id then
                if item.count < item.maxCount then
                    local addCount = itemData.count or 1
                    item.count = math.min(item.count + addCount, item.maxCount)
                    -- CONSOLE.AddMessage("Added to stack: " .. item.name .. " x" .. tostring(addCount))
                    return true
                else
                    CONSOLE.AddMessage("Cannot add more: " .. item.name .. " (stack full)")
                    return false
                end
            end
        end
    end
    
    if table.getn(self.Items) >= self.MaxSlots then
        CONSOLE.AddMessage("Inventory is full!")
        return false
    end
    
    local newItem = {}
    local k
    for k, v in pairs(self.ItemTemplate) do
        newItem[k] = v
    end
    for k, v in pairs(itemData) do
        newItem[k] = v
    end
    
    if not newItem.count then
        newItem.count = 1
    end
    
    if newItem.type == "AMMO" and newItem.ammoType then
        newItem.id = "AMMO_" .. newItem.ammoType
    end
    
    table.insert(self.Items, newItem)
    CONSOLE.AddMessage("Added to inventory: " .. newItem.name)
    return true
end

--=======================================================================
-- Remove item
--=======================================================================
function Inventory:RemoveItem(index, count)
    local item = self.Items[index]
    if not item then return false end
    
    if count and count < item.count then
        item.count = item.count - count
        CONSOLE.AddMessage("Removed " .. tostring(count) .. "x " .. item.name)
        return true
    else
        table.remove(self.Items, index)
        CONSOLE.AddMessage("Removed: " .. item.name)
        
        if self.CurrentSelection > table.getn(self.Items) then
            self.CurrentSelection = math.max(1, table.getn(self.Items))
        end
        return true
    end
end

--=======================================================================
-- Use item
--=======================================================================
function Inventory:UseItem(index)
    local item = self.Items[index]
    if not item then
        CONSOLE.AddMessage("No item selected")
        return false
    end
    
    if not item.usable then
        CONSOLE.AddMessage("This item cannot be used")
        return false
    end
    
    if not Player then
        CONSOLE.AddMessage("No player found")
        return false
    end
    
    if item.type == self.ItemTypes.HEALTH then
        local healthToAdd = item.healthAmount or 25
        Player.Health = math.min(Player.Health + healthToAdd, Game.HealthCapacity or 100)
        CONSOLE.AddMessage("Used: " .. item.name .. " (+" .. tostring(healthToAdd) .. " HP)")
        self:RemoveItem(index, 1)
        PlaySound2D("items/item-soul-gold")
        
    elseif item.type == self.ItemTypes.AMMO then
        if item.ammoType and Player.Ammo then
            local ammoToAdd = item.ammoAmount or 10
            Player.Ammo[item.ammoType] = (Player.Ammo[item.ammoType] or 0) + ammoToAdd
            if Player.CheckMaxAmmo then
                Player:CheckMaxAmmo()
            end
            CONSOLE.AddMessage("Used: " .. item.name .. " (+" .. tostring(ammoToAdd) .. " ammo)")
            self:RemoveItem(index, 1)
            PlaySound2D("weapons/Picks/pickup_ammo_generic")
        end
        
    elseif item.type == self.ItemTypes.ARMOR then
        if item.armorType and Player then
            if Player.ArmorType == item.armorType then
                local maxArmor = 50
                if item.armorType == 2 then maxArmor = 100
                elseif item.armorType == 3 then maxArmor = 155 end
                Player.Armor = math.min(Player.Armor + (item.armorAmount or 50), maxArmor)
            else
                Player.ArmorType = item.armorType
                Player.Armor = item.armorAmount or 50
                if GetArmorRescueFactor then
                    Player.ArmorRescueFactor = GetArmorRescueFactor(Player.ArmorType)
                end
            end
            CONSOLE.AddMessage("Used: " .. item.name)
            self:RemoveItem(index, 1)
            PlaySound2D("items/item-shield-medium")
        end
        
    elseif item.type == self.ItemTypes.WEAPON then
        if item.weaponSlot and Player then
            local isEquipped = false
            if Player.EnabledWeapons[item.weaponSlot] then
                if Player.EnabledWeapons[item.weaponSlot] == item.weaponType then
                    isEquipped = true
                end
            end
            
            if isEquipped then
                Player.EnabledWeapons[item.weaponSlot] = nil
                CONSOLE.AddMessage("Unequipped: " .. item.name)
                PlaySound2D("items/item-drop")
                
                if Player._CurWeaponIndex == item.weaponSlot then
                    local newSlot = nil
                    for slot = 1, 9 do
                        if Player.EnabledWeapons[slot] and slot ~= item.weaponSlot then
                            newSlot = slot
                            break
                        end
                    end
                    
                    if newSlot then
                        pcall(function()
                            CPlayer.WeaponChangeConfirmation(Player.ClientID, Player._Entity, newSlot - 1)
                        end)
                    else
                        pcall(function()
                            CPlayer.WeaponChangeConfirmation(Player.ClientID, Player._Entity, 0)
                        end)
                    end
                end
            else
                Player.EnabledWeapons[item.weaponSlot] = item.weaponType
                CONSOLE.AddMessage("Equipped: " .. item.name)
                PlaySound2D("weapons/Picks/pickup_weapon_generic")
                
                if Player._CurWeaponIndex ~= item.weaponSlot then
                    pcall(function()
                        CPlayer.WeaponChangeConfirmation(Player.ClientID, Player._Entity, item.weaponSlot - 1)
                    end)
                end
            end
            
            self:UpdateEquippedWeapons()
        end
    end
    
    return true
end

--=======================================================================
-- Drop item
--=======================================================================
function Inventory:DropItem(index)
    local item = self.Items[index]
    if not item then return false end
    
    if not item.droppable then
        CONSOLE.AddMessage("This item cannot be dropped")
        return false
    end
    
    if not Player then return false end
    
    -- Create dropped item entity
    local dropTemplate = nil
    if item.weaponType then
        dropTemplate = item.weaponType .. ".CItem"
    elseif item.ammoType then
        dropTemplate = item.ammoType .. ".CItem"
    elseif item.armorType then
        local armorTemplates = {[1] = "ArmorWeak", [2] = "ArmorMedium", [3] = "ArmorStrong"}
        dropTemplate = armorTemplates[item.armorType] .. ".CItem"
    elseif item.healthAmount then
        dropTemplate = "Health.CItem"
    end
    
    if dropTemplate and Templates and Templates[dropTemplate] then
        local dropItem = GObjects:Add("Item" .. tostring(math.random(1000, 9999)), CloneTemplate(dropTemplate))
        if dropItem then
            local px, py, pz = Player.Pos:Get()
            local fx, fy, fz = 0, 0, 0
            if Player.ForwardVector then
                fx, fy, fz = Player.ForwardVector:Get()
            end
            dropItem.Pos:Set(px + fx * 2, py + fy * 2, pz + fz * 2)
            if dropItem.Apply then
                dropItem:Apply()
            end
        end
    end
    
    self:RemoveItem(index, item.count)
    CONSOLE.AddMessage("Dropped: " .. item.name)
    PlaySound2D("items/item-drop")
    
    return true
end

--=======================================================================
-- Save to profile
--=======================================================================
function Inventory:SaveToProfile()
    local profile = Game:GetProfile()
    if not profile then return end
    
    profile.Inventory = {
        Items = {},
        MaxSlots = self.MaxSlots
    }
    
    local i
    for i = 1, table.getn(self.Items) do
        local item = self.Items[i]
        local saveItem = {
            id = item.id,
            name = item.name,
            type = item.type,
            model = item.model,
            count = item.count,
            description = item.description,
            usable = item.usable,
            droppable = item.droppable,
            weaponType = item.weaponType,
            weaponSlot = item.weaponSlot,
            ammoType = item.ammoType,
            ammoAmount = item.ammoAmount,
            armorType = item.armorType,
            armorAmount = item.armorAmount,
            healthAmount = item.healthAmount
        }
        table.insert(profile.Inventory.Items, saveItem)
    end
    
    PlayerProfile:Save(Cfg.CurrentProfile, profile)
end

--=======================================================================
-- Load from profile
--=======================================================================
function Inventory:LoadFromProfile()
    local profile = Game:GetProfile()
    if not profile or not profile.Inventory then
        self.Items = {}
        return
    end
    
    self.Items = {}
    self.MaxSlots = profile.Inventory.MaxSlots or 32
    
    local i
    for i = 1, table.getn(profile.Inventory.Items) do
        local saveItem = profile.Inventory.Items[i]
        local item = {}
        local k
        for k, v in pairs(self.ItemTemplate) do
            item[k] = v
        end
        for k, v in pairs(saveItem) do
            item[k] = v
        end
        table.insert(self.Items, item)
    end
    
    CONSOLE.AddMessage("Inventory loaded (" .. tostring(table.getn(self.Items)) .. " items)")
end

--=======================================================================
-- Test items
--=======================================================================
function Inventory:AddTestItems()
    CONSOLE.AddMessage("Adding test items...")
    
    self:AddItem({
        id = "weapon_shotgun",
        name = "Shotgun",
        type = self.ItemTypes.WEAPON,
        description = "Powerful close-range weapon",
        weaponType = "Shotgun",  
        weaponSlot = 2
    })
    
    self:AddItem({
        id = "ammo_shells",
        name = "Shotgun Shells",
        type = self.ItemTypes.AMMO,
        count = 48,
        description = "Ammunition for shotgun",
        ammoType = "Shotgun",
        ammoAmount = 10
    })
    
    self:AddItem({
        id = "health_pack",
        name = "Health Pack",
        type = self.ItemTypes.HEALTH,
        count = 8,
        description = "Restores 25 HP",
        healthAmount = 25
    })
    
    self:AddItem({
        id = "weapon_minigun",
        name = "MiniGun",
        type = self.ItemTypes.WEAPON,
        description = "High rate of fire weapon",
        weaponType = "MiniGunRL",  
        weaponSlot = 4
    })
    
    self:AddItem({
        id = "armor_bronze",
        name = "Bronze Armor",
        type = self.ItemTypes.ARMOR,
        count = 1,
        description = "Basic armor protection",
        armorType = 1,
        armorAmount = 50
    })
    
    CONSOLE.AddMessage("Added " .. table.getn(self.Items) .. " test items")
end

--=======================================================================
-- Get weapon slot by type
--=======================================================================
function Inventory:GetWeaponSlot(weaponType)
    local slots = {
        Shotgun = 2,
        StakeGun = 3,
        MiniGunRL = 4,
        DriverElectro = 5,
        RifleFlameThrower = 6,
        BoltGunHeater = 7,
        HellGun = 8,
        Devastator = 9
    }
    return slots[weaponType]
end

--=======================================================================
-- Integration with Trader
--=======================================================================
function Inventory:AddFromTrader(itemData)
    local invItem = {
        id = (itemData.WeaponType or itemData.AmmoType or itemData.Type or "item") .. "_" .. tostring(os.time()),
        name = itemData.Name,
        type = itemData.Type,
        count = itemData.Amount or 1,
        description = itemData.Info or "",
    }
    
    if itemData.Type == Inventory.ItemTypes.WEAPON then
        invItem.weaponType = itemData.WeaponType
        invItem.weaponSlot = self:GetWeaponSlot(itemData.WeaponType)
    elseif itemData.Type == Inventory.ItemTypes.AMMO then
        invItem.ammoType = itemData.AmmoType
        invItem.ammoAmount = 10
    elseif itemData.Type == Inventory.ItemTypes.ARMOR then
        if itemData.ArmorType == "ArmorWeak" then
            invItem.armorType = 1
        elseif itemData.ArmorType == "ArmorMedium" then
            invItem.armorType = 2
        elseif itemData.ArmorType == "ArmorStrong" then
            invItem.armorType = 3
        end
        invItem.armorAmount = 50
    end
    
    return self:AddItem(invItem)
end

--=======================================================================
-- Get weapon slot by type
--=======================================================================
function Inventory:GetWeaponSlot(weaponType)
    local slots = {
        IShotgun = 2,
        IStakeGun = 3,
        IMiniGunRL = 4,
        IDriverElectro = 5,
        IRifleFlameThrower = 6,
        IBoltGunHeater = 7,
        IHellGun = 8,
        IDevastator = 9
    }
    return slots[weaponType]
end