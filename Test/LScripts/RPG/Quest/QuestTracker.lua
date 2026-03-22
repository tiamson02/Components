--============================================================================
-- By 7ZOV
--============================================================================

QuestTracker = QuestTracker or {}

function QuestTracker:Init()
    CONSOLE.AddMessage("QuestTracker initialized")
end

function QuestTracker:Update()
    -- Не вызываем до инициализации игры
    if not Game or not Game.Active then
        return
    end
    
    -- Только если игра в процессе
    if Game.GMode ~= GModes.SingleGame or Game._BlockedPlay then
        return
    end
    
    -- Остальной код отслеживания убийств...
    -- Пока оставим пустым или добавим позже
end

function QuestTracker:OnEnemyKilled(enemyActorName)
    -- Эта функция будет вызываться из игровых событий
    if not QuestSystem then return end
    
    -- Проверяем все квесты
    for questID, state in pairs(QuestSystem._quests) do
        if state == "active" then
            local quest = _G[questID]
            if quest and quest.TargetActor == enemyActorName then
                QuestSystem:UpdateObjective(questID, 1, 1)
                break
            end
        end
    end
end

-- Инициализация
