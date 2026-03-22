--=======================================================================
-- by 7ZOV
--=======================================================================

UseSystem = {
    IsEnabled = true,
    
    UseDistance = 5,
    
    UseTypes = {
        ITEM = "item",
        WEAPON = "weapon",
        AMMO = "ammo",
        ARMOR = "armor",
        HEALTH = "health",
        DOOR = "door",
        SWITCH = "switch",
        NPC = "npc",
        VENDOR = "vendor"
    },
    
    CurrentTarget = nil,
    CurrentTargetType = nil,
    CurrentTargetDist = 0,
    
    ShowHint = true,
    HintText = "",
    HintColor = {230, 161, 97},
    
    Debug = false
}

--=======================================================================
-- Инициализация
--=======================================================================
function UseSystem:Init()
    self.IsEnabled = true
    CONSOLE.AddMessage("Use System initialized")
end

--=======================================================================
-- Поиск ближайшего объекта для взаимодействия
--=======================================================================
function UseSystem:FindTarget()
    if not Player then return nil end
    
    self.CurrentTarget = nil
    self.CurrentTargetType = nil
    self.CurrentTargetDist = self.UseDistance
    self.HintText = ""
    
    local playerX, playerY, playerZ = Player.Pos:Get()
    local playerDir = Player.ForwardVector
    
    for i, obj in GObjects.Elements do
        if obj and not obj._ToKill then
            local objX, objY, objZ = obj.Pos:Get()
            
            local dx = objX - playerX
            local dy = objY - playerY
            local dz = objZ - playerZ
            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
            
            if dist < self.UseDistance then
                local dot = (dx*playerDir.X + dy*playerDir.Y + dz*playerDir.Z) / dist
                if dot > 0.7 then
                    
                    local objType = self:GetObjectType(obj)
                    if objType then
                        if dist < self.CurrentTargetDist then
                            self.CurrentTarget = obj
                            self.CurrentTargetType = objType
                            self.CurrentTargetDist = dist
                            self.HintText = self:GetHintText(obj, objType)
                        end
                    end
                end
            end
        end
    end
    
    if self.Debug and self.CurrentTarget then
        CONSOLE.AddMessage("Target: " .. self.CurrentTarget._Name .. " (" .. self.CurrentTargetType .. ") at " .. string.format("%.1f", self.CurrentTargetDist))
    end
    
    return self.CurrentTarget
end

--=======================================================================
-- Определение типа объекта
--=======================================================================
function UseSystem:GetObjectType(obj)
    if not obj then return nil end
    
    if obj._Class == "CItem" then
        if InventoryCfg and InventoryCfg.Lookup then
            local templateName = obj._Name .. ".CItem"
            local itemData = InventoryCfg.Lookup[templateName]
            if itemData then
                return itemData.type
            end
        end
        
        if obj.AmmoAdd then return UseSystem.UseTypes.AMMO end
        if obj.ArmorAdd then return UseSystem.UseTypes.ARMOR end
        if obj.HealthAdd then return UseSystem.UseTypes.HEALTH end
        if obj.BaseObj and string.find(obj.BaseObj, "Weapon") then 
            return UseSystem.UseTypes.WEAPON 
        end
        
        return UseSystem.UseTypes.ITEM
    end
    
    if obj._Class == "CBox" and obj.IsDoor then
        return UseSystem.UseTypes.DOOR
    end
    
    if obj._Class == "CBox" and obj.IsSwitch then
        return UseSystem.UseTypes.SWITCH
    end
    
    if obj._Class == "CActor" and obj.IsNPC and not obj._died then
        return UseSystem.UseTypes.NPC
    end
    
    return nil
end

--=======================================================================
-- Получение текста подсказки
--=======================================================================
function UseSystem:GetHintText(obj, objType)
    if not obj then return "" end
    
    local text = ""
    local color = self.HintColor
    local objName = obj._Name
    
    if not objName then
        objName = "Unknown"
    end
    
    if objType == self.UseTypes.WEAPON then
        text = "Take " .. objName
    elseif objType == self.UseTypes.AMMO then
        text = "Take " .. objName
    elseif objType == self.UseTypes.ARMOR then
        text = "Take " .. objName
    elseif objType == self.UseTypes.HEALTH then
        text = "Take " .. objName
    elseif objType == self.UseTypes.DOOR then
        text = "Open Door"
    elseif objType == self.UseTypes.SWITCH then
        text = "Use Switch"
    elseif objType == self.UseTypes.NPC then
        text = "Talk to " .. objName
    else
        text = "Take " .. objName
    end
    
    return text
end

--=======================================================================
-- Использование объекта
--=======================================================================
function UseSystem:UseCurrentTarget()
    if not self.CurrentTarget or not Player then 
        if self.Debug then
            CONSOLE.AddMessage("No target to use")
        end
        return false 
    end
    
    local obj = self.CurrentTarget
    local objType = self.CurrentTargetType
    
    if self.Debug then
        CONSOLE.AddMessage("Using: " .. obj._Name .. " (" .. objType .. ")")
    end
    
    if objType == self.UseTypes.WEAPON or 
       objType == self.UseTypes.AMMO or 
       objType == self.UseTypes.ARMOR or 
       objType == self.UseTypes.HEALTH or 
       objType == self.UseTypes.ITEM then
        
        if obj.OnTake then
            local result = obj:OnTake(Player)
            if self.Debug then
                CONSOLE.AddMessage("OnTake result: " .. tostring(result))
            end
            return result
        else
            if Inventory and Inventory.IsEnabled then
                local templateName = obj._Name .. ".CItem"
                local itemData = InventoryCfg and InventoryCfg.Lookup[templateName]
                if itemData then
                    if Inventory:HandlePickup(obj, Player, itemData) then
                        GObjects:ToKill(obj)
                        return true
                    end
                end
            end
        end
        
    elseif objType == self.UseTypes.DOOR then
        if obj.OnUse then
            obj:OnUse(Player)
            return true
        end
        
    elseif objType == self.UseTypes.SWITCH then
        if obj.OnUse then
            obj:OnUse(Player)
            return true
        end
        
    elseif objType == self.UseTypes.NPC then
        if obj.OnTalk then
            obj:OnTalk(Player)
            return true
        elseif DialogSystem then
            DialogSystem:ShowDialog(obj.DialogId, obj._Name)
            return true
        end
    end
    
    return false
end

--=======================================================================
-- Обработка ввода
--=======================================================================
function UseSystem:HandleInput()
    if not self.IsEnabled or not Player then return false end
    if Game.IsDemon then return false end
    if Inventory and Inventory.IsOpen then return false end
    if DialogSystem and DialogSystem.Active then return false end
    
    self:FindTarget()
    
    if INP.Key(Keys.F) == 1 then
        if self.CurrentTarget then
            return self:UseCurrentTarget()
        else
            if self.Debug then
                CONSOLE.AddMessage("Nothing to use")
            end
            PlaySound2D("misc/card-cannot_use")
        end
        return true
    end
    
    return false
end

--=======================================================================
-- Отрисовка подсказки
--=======================================================================
function UseSystem:DrawHint()
    if not self.ShowHint or not self.CurrentTarget or not Player then return end
    
    local w, h = R3D.ScreenSize()
    
    local hintX = w / 2
    local hintY = h / 2 + 100
    
    local textWidth = HUD.GetTextWidth(self.HintText, "courbd", 16)
    local bgWidth = textWidth + 40
    local bgX = hintX - bgWidth / 2
    
    HUD.DrawQuadRGBA(nil, bgX, hintY - 15, bgWidth, 30, 0, 0, 0, 180)
    HUD.DrawQuadRGBA(nil, bgX, hintY - 15, bgWidth, 2, 
                     self.HintColor[1], self.HintColor[2], self.HintColor[3], 255)
    
    HUD.SetFont("courbd", 16)
    HUD.PrintXY(hintX - textWidth/2, hintY - 10, self.HintText, "courbd",
                self.HintColor[1], self.HintColor[2], self.HintColor[3], 16)
    
    HUD.SetFont("timesbd", 18)
    local keyText = "[F]"
    local keyWidth = HUD.GetTextWidth(keyText, "timesbd", 18)
    HUD.PrintXY(hintX - keyWidth/2, hintY - 35, keyText, "timesbd",
                255, 255, 255, 18)
end
