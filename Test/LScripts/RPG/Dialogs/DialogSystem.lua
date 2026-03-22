--============================================================================
-- By 7ZOV
--============================================================================

DialogSystem = {
    Active = false,
    CurrentDialog = nil,
    SelectedOption = 1,
    MinWidth = 600,
    MinHeight = 300,
    MaxWidth = 1000,
    MaxHeight = 600,
    NPCBoxPadding = 20,
    PlayerBoxPadding = 15,
    OptionSpacing = 8,
    Font = "courbd",
    FontSize = 18,
    HistoryFontSize = 16,
    Colors = {
        Text = {230, 161, 97},
        Highlight = {214, 0, 23},
        Background = {0, 0, 0},
        Border = {230, 161, 97},
        NPCBox = {10, 10, 20},
        PlayerBox = {20, 15, 10}
    },
    DialogHistory = {},
    DialogWidth = 0,
    DialogHeight = 0,
    NPCBoxHeight = 0,
    PlayerBoxHeight = 0,
    CurrentNPC = nil  -- Добавлено для отслеживания текущего NPC
}

function DialogSystem:Initialize()
    self.Active = false
    self.CurrentDialog = nil
    self.SelectedOption = 1
    self.DialogHistory = {}
    self.DialogWidth = self.MinWidth
    self.DialogHeight = self.MinHeight
    self.CurrentNPC = nil
end

function DialogSystem:CheckEnemiesAround()
    if not Player then return true end
    
    local playerX, playerY, playerZ = Player.Pos:Get()
    local enemies = 0
    
    for i, actor in Actors, nil do
        if actor and actor._Class == "CActor" and not actor._died and actor.Health > 0 and actor ~= Player then
            if not actor.NotCountable then
                local ax, ay, az = actor.Pos:Get()
                local dist = math.sqrt((ax - playerX)^2 + (ay - playerY)^2 + (az - playerZ)^2)
                if dist < 10 then -- Проверяем в радиусе 10 метров
                    enemies = enemies + 1
                    break
                end
            end
        end
    end
    
    return enemies > 0
end

function DialogSystem:CalculateDialogSize()
    if not self.CurrentDialog then return end
    
    local w, h = R3D.ScreenSize()
    local maxWidth = math.min(self.MaxWidth, w - 100)
    local maxHeight = math.min(self.MaxHeight, h - 100)
    
    HUD.SetFont(self.Font, self.HistoryFontSize)
    
    -- Рассчитываем высоту истории диалога
    local historyHeight = 0
    local maxHistoryLines = 8 -- Максимум 8 записей в истории
    
    -- Показываем последние сообщения из истории
    local historyStart = math.max(1, table.getn(self.DialogHistory) - maxHistoryLines + 1)
    for i = historyStart, table.getn(self.DialogHistory) do
        local entry = self.DialogHistory[i]
        local prefix = ""
        if entry.speaker == "NPC" then
            prefix = "[NPC]: "
        else
            prefix = "[You]: "
        end
        
        local lines = self:WrapText(prefix .. entry.text, maxWidth - 40)
        historyHeight = historyHeight + (table.getn(lines) * (self.HistoryFontSize + 2))
    end
    
    -- Рассчитываем высоту вариантов ответа
    local optionsHeight = 0
    for i, option in self.CurrentDialog.Options do
        local lines = self:WrapText(i .. ". " .. option.Text, maxWidth - 40)
        optionsHeight = optionsHeight + (table.getn(lines) * (self.FontSize + self.OptionSpacing))
    end
    
    -- Добавляем отступы и заголовки
    local titleHeight = 50
    local separatorHeight = 10
    local padding = 40
    
    local totalHeight = titleHeight + historyHeight + separatorHeight + optionsHeight + padding
    local totalWidth = maxWidth
    
    -- Ограничиваем размеры
    self.DialogHeight = math.max(self.MinHeight, math.min(totalHeight, maxHeight))
    self.DialogWidth = math.max(self.MinWidth, math.min(totalWidth, maxWidth))
    
    -- Рассчитываем высоты областей
    self.NPCBoxHeight = math.max(150, historyHeight + 30)
    self.PlayerBoxHeight = math.max(100, optionsHeight + 30)
end

function DialogSystem:ShowDialog(dialogId, npcName)
    if self:CheckEnemiesAround() then
        CONSOLE.AddMessage("Нельзя говорить с NPC во время боя!")
        PlaySound2D("misc/card-cannot_use")
        return
    end
    
    if Dialogs[dialogId] then
        -- Если это новый NPC или система не активна, очищаем историю
        if not self.Active or self.CurrentNPC ~= npcName then
            self.DialogHistory = {}
            self.CurrentNPC = npcName
        end
        
        -- Добавляем в историю только если это новый диалог
        if self.CurrentDialog ~= Dialogs[dialogId] then
            table.insert(self.DialogHistory, {
                speaker = "NPC",
                text = Dialogs[dialogId].Text
            })
        end
        
        self.CurrentDialog = Dialogs[dialogId]
        self.SelectedOption = 1
        self:CalculateDialogSize() -- Рассчитываем размеры
        self.Active = true
        if Player then Player.Frozen = true end
        Hud.Enabled = false -- Отключаем HUD как в магазине
        Game.CameraFromPlayer = false
        PlaySound2D("menu/menu_necro/scroller-move")
    end
end

function DialogSystem:HideDialog()
    self.Active = false
    self.CurrentDialog = nil
    self.DialogHistory = {}
    self.DialogWidth = self.MinWidth
    self.DialogHeight = self.MinHeight
    self.CurrentNPC = nil
    if Player then Player.Frozen = false end
    Hud.Enabled = true
    Game.CameraFromPlayer = true
    PlaySound2D("menu/menu_necro/scroller-move")
end

function DialogSystem:SelectOption()
    if not self.Active or not self.CurrentDialog then return end
    
    local option = self.CurrentDialog.Options[self.SelectedOption]
    if option then
        -- Добавляем выбор игрока в историю
        table.insert(self.DialogHistory, {
            speaker = "Player",
            text = option.Text
        })
        
        if option.Action then
            dostring(option.Action)
        end
        
        if option.NextDialog then
            -- Добавляем ответ NPC в историю
            if Dialogs[option.NextDialog] then
                table.insert(self.DialogHistory, {
                    speaker = "NPC",
                    text = Dialogs[option.NextDialog].Text
                })
            end
            self:ShowDialog(option.NextDialog, self.CurrentNPC)
        else
            self:HideDialog()
        end
    end
end

function DialogSystem:MoveSelection(direction)
    if not self.Active or not self.CurrentDialog then return end
    
    local optionCount = table.getn(self.CurrentDialog.Options)
    if direction == "up" then
        self.SelectedOption = self.SelectedOption - 1
        if self.SelectedOption < 1 then
            self.SelectedOption = optionCount
        end
    elseif direction == "down" then
        self.SelectedOption = self.SelectedOption + 1
        if self.SelectedOption > optionCount then
            self.SelectedOption = 1
        end
    end
    
    PlaySound2D("menu/menu_necro/scroller-move")
end

function DialogSystem:Update()
    if not self.Active then return end
    
    -- Обработка ввода
    if INP.Key(Keys.Up) == 1 then
        self:MoveSelection("up")
    elseif INP.Key(Keys.Down) == 1 then
        self:MoveSelection("down")
    elseif INP.Key(Keys.Enter) == 1 or INP.Key(Keys.NumlockEnter) == 1 then
        self:SelectOption()
    elseif INP.Key(Keys.Escape) == 1 then
        self:HideDialog()
    end
    
    -- Поддержка NumPad
    if INP.Key(Keys.Numpad8) == 1 then
        self:MoveSelection("up")
    elseif INP.Key(Keys.Numpad2) == 1 then
        self:MoveSelection("down")
    elseif INP.Key(Keys.NumpadEnter) == 1 then
        self:SelectOption()
    end
end

function DialogSystem:Render()
    if not self.Active or not self.CurrentDialog then return end
    
    local w, h = R3D.ScreenSize()
    
    self.DialogWidth = math.max(800, w * 0.8)
    self.DialogHeight = math.max(500, h * 0.7)
    
    local dialogX = (w - self.DialogWidth) / 2
    local dialogY = (h - self.DialogHeight) / 2
    
    HUD.DrawQuadRGBA(nil, dialogX, dialogY, self.DialogWidth, self.DialogHeight, 
                     self.Colors.Background[1], self.Colors.Background[2], self.Colors.Background[3], 220)
    
    HUD.SetFont("timesbd", 26)
    local titleText = "Dialog"
    local titleWidth = HUD.GetTextWidth(titleText, "timesbd", 26)
    HUD.PrintXY((w - titleWidth)/2, dialogY + 15, titleText, "timesbd", 
               self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 26)
    
    HUD.DrawQuadRGBA(nil, dialogX + 20, dialogY + 50, self.DialogWidth - 40, 2, 
                     self.Colors.Border[1], self.Colors.Border[2], self.Colors.Border[3], 200)
    
    -- РАЗДЕЛЕНИЕ ОКНА НА ДВЕ ЧАСТИ --
    
    -- Левая часть: История диалога (2/3 ширины)
    local leftPanelWidth = self.DialogWidth * 2/3
    local leftPanelX = dialogX
    local leftPanelY = dialogY + 60
    local leftPanelHeight = self.DialogHeight - 120
    
    -- Правая часть: Варианты ответов (1/3 ширины)
    local rightPanelWidth = self.DialogWidth * 1/3
    local rightPanelX = dialogX + leftPanelWidth
    local rightPanelY = leftPanelY
    local rightPanelHeight = leftPanelHeight
    
    -- Разделительная линия между панелями
    HUD.DrawQuadRGBA(nil, rightPanelX - 2, leftPanelY, 4, leftPanelHeight, 
                     self.Colors.Border[1], self.Colors.Border[2], self.Colors.Border[3], 180)
    
    -- ЛЕВАЯ ПАНЕЛЬ: ИСТОРИЯ ДИАЛОГА
    
    -- Подзаголовок истории
    HUD.SetFont("timesbd", 20)
    HUD.PrintXY(leftPanelX + (leftPanelWidth/4), leftPanelY + 10, "", "timesbd", 
               self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 20)
    
    -- Отображение истории диалога с разделением по сторонам
    HUD.SetFont(self.Font, 18)
    local historyStartY = leftPanelY + 40
    local historyLeftX = leftPanelX + 40  -- Для реплик NPC (слева)
    local historyRightX = leftPanelX + leftPanelWidth - 40  -- Для реплик игрока (справа)
    local lineSpacing = 25
    local maxLineWidth = (leftPanelWidth - 80) * 0.55  -- 45% ширины для каждой стороны
    
    local maxHistoryLines = math.floor((leftPanelHeight - 60) / lineSpacing)
    local historyStart = math.max(1, table.getn(self.DialogHistory) - maxHistoryLines + 1)
    local currentY = historyStartY
    local displayedLines = 0
    
    for i = historyStart, table.getn(self.DialogHistory) do
        local entry = self.DialogHistory[i]
        
        if entry.speaker == "NPC" then
            -- Реплика NPC слева
            local npcColor = {230, 161, 97}
            local prefix = "NPC:"
            local fullText = prefix .. " " .. entry.text
            
            -- Разбиваем текст на строки
            local lines = self:WrapText(fullText, maxLineWidth)
            
            -- Рисуем фон для блока реплики
            local maxTextWidth = 0
            for _, line in lines do
                local lineWidth = HUD.GetTextWidth(line, self.Font, 18)
                if lineWidth > maxTextWidth then maxTextWidth = lineWidth end
            end
            
            local blockHeight = table.getn(lines) * lineSpacing
            --HUD.DrawQuadRGBA(nil, historyLeftX - 10, currentY - 8, maxTextWidth + 20, blockHeight + 5, 
            --               40, 60, 80, 120)
            
            -- Отображаем кадую строку
            for j, line in lines do
                HUD.PrintXY(historyLeftX, currentY + (j-1) * lineSpacing, line, self.Font, 
                           npcColor[1], npcColor[2], npcColor[3], 18)
            end
            
            currentY = currentY + blockHeight + 5
            displayedLines = displayedLines + table.getn(lines)
            
        else
            -- Реплика игрока справа (с выравниванием по правому краю)
            local playerColor = {230, 161, 97}
            local prefix = "You:"
            local fullText = prefix .. " " .. entry.text
            
            -- Разбиваем текст на строки
            local lines = self:WrapText(fullText, maxLineWidth)
            
            -- Находим максимальную ширину для выравнивания
            local maxTextWidth = 0
            for _, line in lines do
                local lineWidth = HUD.GetTextWidth(line, self.Font, 18)
                if lineWidth > maxTextWidth then maxTextWidth = lineWidth end
            end
            
            local blockHeight = table.getn(lines) * lineSpacing
            
            -- Рисуем фон для блока реплики (выравниваем по правому краю)
            --HUD.DrawQuadRGBA(nil, historyRightX - maxTextWidth - 10, currentY - 8, maxTextWidth + 20, blockHeight + 5, 
            --               80, 60, 40, 120)  -- Коричневый фон
            
            -- Отображаем каждую строку
            for j, line in lines do
                local lineWidth = HUD.GetTextWidth(line, self.Font, 18)
                HUD.PrintXY(historyRightX - lineWidth, currentY + (j-1) * lineSpacing, line, self.Font, 
                           playerColor[1], playerColor[2], playerColor[3], 18)
            end
            
            currentY = currentY + blockHeight + 5
            displayedLines = displayedLines + table.getn(lines)
        end
        
        -- Проверка на переполнение
        if currentY > leftPanelY + leftPanelHeight - 30 then
            break
        end
        
        -- Если превысили максимальное количество строк
        if displayedLines >= maxHistoryLines then
            break
        end
    end
    
    -- ПРАВАЯ ПАНЕЛЬ: ВАРИАНТЫ ОТВЕТОВ
    
    -- Подзаголовок вариантов
    HUD.SetFont("timesbd", 20)
    HUD.PrintXY(rightPanelX + (rightPanelWidth/4), rightPanelY + 10, "", "timesbd", 
               self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 20)
    
    -- Варианты ответов
    HUD.SetFont(self.Font, 20)
    local optionStartY = rightPanelY + 50
    local optionX = rightPanelX + 20
    local optionY = optionStartY
    local optionSpacing = 35
    local maxOptionWidth = rightPanelWidth - 30  -- Максимальная ширина для вариантов
    
    for i, option in self.CurrentDialog.Options do
        local color = self.Colors.Text
        local optionText = i .. ". " .. option.Text
        
        -- Разбиваем текст варианта на строки
        local lines = self:WrapText(optionText, maxOptionWidth - 20)
        local blockHeight = table.getn(lines) * 28
        
        -- Находим максимальную ширину текста
        local maxTextWidth = 0
        for _, line in lines do
            local lineWidth = HUD.GetTextWidth(line, self.Font, 20)
            if lineWidth > maxTextWidth then maxTextWidth = lineWidth end
        end
        
        -- Выделение выбранного варианта
        if i == self.SelectedOption then
            color = self.Colors.Highlight
            
            -- Фон для выделенного варианта
            --HUD.DrawQuadRGBA(nil, optionX - 10, optionY - 8, maxTextWidth + 20, blockHeight + 5, 
            --               60, 40, 20, 150)  -- Темный фон
            
            -- Дополнительная рамка для выделения
            --HUD.DrawQuadRGBA(nil, optionX - 10, optionY - 8, maxTextWidth + 20, 3, 
            --               self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 255)
            --HUD.DrawQuadRGBA(nil, optionX - 10, optionY + blockHeight - 3, maxTextWidth + 20, 3, 
            --               self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 255)
            --HUD.DrawQuadRGBA(nil, optionX - 10, optionY - 8, 3, blockHeight + 5, 
            --               self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 255)
            --HUD.DrawQuadRGBA(nil, optionX + maxTextWidth + 7, optionY - 8, 3, blockHeight + 5, 
            --               self.Colors.Highlight[1], self.Colors.Highlight[2], self.Colors.Highlight[3], 255)
        else
            -- Более светлый фон для обычных вариантов
            --HUD.DrawQuadRGBA(nil, optionX - 10, optionY - 8, maxTextWidth + 20, blockHeight + 5, 
            --               30, 25, 20, 80)
        end
        
        -- Отображение текста варианта (каждой строки)
        for j, line in lines do
            HUD.PrintXY(optionX, optionY + (j-1) * 28, line, self.Font, 
                       color[1], color[2], color[3], 20)
        end
        
        optionY = optionY + blockHeight + optionSpacing
    end
    
    -- Подсказка управления внизу
    HUD.SetFont("courbd", 16)
    local controlText = "↑↓ - navigation | Enter - select"
    local controlWidth = HUD.GetTextWidth(controlText, "courbd", 16)
    HUD.PrintXY((w - controlWidth)/2, dialogY + self.DialogHeight - 35, controlText, "courbd", 
               self.Colors.Text[1], self.Colors.Text[2], self.Colors.Text[3], 16)
    
    -- Индикатор страниц истории
    if table.getn(self.DialogHistory) > displayedLines then
        local pageText = "↑ The last " .. displayedLines .. " lines are shown"
        HUD.SetFont("courbd", 14)
        HUD.PrintXY(leftPanelX + 20, leftPanelY + leftPanelHeight - 25, pageText, "courbd", 
                   self.Colors.Disabled[1], self.Colors.Disabled[2], self.Colors.Disabled[3], 14)
    end
end

function DialogSystem:WrapText(text, maxWidth)
    local lines = {}
    
    if not text or text == "" then
        return {""}
    end
    
    HUD.SetFont(self.Font, self.FontSize)
    
    local words = {}
    for word in string.gfind(text, "%S+") do
        table.insert(words, word)
    end
    
    if table.getn(words) == 0 then
        return {""}
    end
    
    local currentLine = ""
    
    for i, word in words do
        local testLine = currentLine
        if testLine ~= "" then testLine = testLine .. " " end
        testLine = testLine .. word
        
        local lineWidth = HUD.GetTextWidth(testLine, self.Font, self.FontSize)
        if lineWidth > maxWidth and currentLine ~= "" then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    if table.getn(lines) == 0 then
        table.insert(lines, "")
    end
    
    return lines
end

-- Инициализация
DialogSystem:Initialize()
