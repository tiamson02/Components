--============================================================================
-- By 7ZOV
--============================================================================

QuestSystem = {}

-- Локальное хранилище (не в Cfg!)
QuestSystem._quests = QuestSystem._quests or {}
QuestSystem._progress = QuestSystem._progress or {}

function QuestSystem:StartQuest(questID)
    local quest = _G[questID]
    if not quest then
        CONSOLE.AddMessage("Quest not found: " .. tostring(questID))
        return false
    end

    -- Проверяем, не выполнен ли уже квест
    if self._quests[questID] == "completed" then
        CONSOLE.AddMessage("Quest already completed: " .. quest.Name)
        return false
    end
    
    -- Проверяем, не активен ли уже квест
    if self._quests[questID] == "active" then
        CONSOLE.AddMessage("Quest already active: " .. quest.Name)
        return false
    end

    -- Ставим квест активным
    self._quests[questID] = "active"
    self._progress[questID] = { kills = 0 }
    
    CONSOLE.AddMessage("New quest: " .. quest.Name)
    return true
end

function QuestSystem:CompleteQuest(questID)
    local quest = _G[questID]
    if not quest then 
        CONSOLE.AddMessage("Quest not found for completion: " .. tostring(questID))
        return 
    end

    self._quests[questID] = "completed"
    
    CONSOLE.AddMessage("Quest completed: " .. quest.Name)
    
    if quest.OnComplete then
        quest.OnComplete()
    end
end

function QuestSystem:GetQuestState(questID)
    return self._quests[questID] or "inactive"
end

function QuestSystem:UpdateObjective(questID, objectiveIndex, amount)
    local quest = _G[questID]
    if not quest then return end

    local state = self:GetQuestState(questID)
    if state ~= "active" then return end
    
    -- Инициализируем прогресс если нужно
    if not self._progress[questID] then
        self._progress[questID] = { kills = 0 }
    end
    
    -- Увеличиваем прогресс
    self._progress[questID].kills = (self._progress[questID].kills or 0) + (amount or 1)
    
    CONSOLE.AddMessage("Progress: " .. self._progress[questID].kills .. "/" .. quest.TargetCount .. " " .. quest.Name)
    
    -- Проверяем завершение
    if self._progress[questID].kills >= quest.TargetCount then
        self:CompleteQuest(questID)
    end
end

function QuestSystem:GetProgress(questID)
    if self._progress[questID] then
        return self._progress[questID].kills or 0
    end
    return 0
end

-- ============================================
-- СОХРАНЕНИЕ/ЗАГРУЗКА через SaveGame
-- ============================================

-- Вызывается из SaveGame перед сохранением
function QuestSystem:PrepareSaveData()
    return {
        quests = Clone(self._quests),
        progress = Clone(self._progress)
    }
end

-- Вызывается из SaveGame после загрузки
function QuestSystem:RestoreSaveData(data)
    if data then
        self._quests = data.quests or {}
        self._progress = data.progress or {}
    else
        self._quests = {}
        self._progress = {}
    end
end

-- Для отладки
function QuestSystem:PrintState()
    CONSOLE.AddMessage("=== QuestSystem State ===")
    for questID, state in pairs(self._quests) do
        local progress = self._progress[questID] or {kills = 0}
        CONSOLE.AddMessage(questID .. ": " .. state .. " (" .. progress.kills .. " kills)")
    end
end
