
BattleMusicMenu = {
    bgStartFrame = { 120, 243, 268 },
    bgEndFrame   = { 180, 267, 291 },
    menuWidth = 880,
    backAction = "PainMenu:ActivateScreen(MainMenu)",

    items = {
        -- Заголовок
        Title = {
            type        = MenuItemTypes.StaticText,
            text        = "Custom Battle Music",
            desc        = "Manage your custom battle music playlist.",
            action      = "",
            x           = 440, -- Центр
            y           = 100,
            fontBigSize = 24,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Center,
            useItemBG   = false,
        },

        -- Доступные треки (список)
        AvailTitle = {
            type        = MenuItemTypes.StaticText,
            text        = "Available Tracks:",
            desc        = "",
            action      = "",
            x           = 100,
            y           = 150,
            fontBigSize = 20,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Left,
            useItemBG   = false,
        },

        -- Текст с доступными треками (через textFuc)
        AvailText = {
            type        = MenuItemTypes.StaticText,
            textFuc     = "BattleMusicMenu:GetAvailableTracksTxt()",
            desc        = "",
            action      = "",
            x           = 100,
            y           = 180,
            fontBigSize = 14,
            textColor   = R3D.RGBA( 255, 255, 255, 255 ), -- Белый текст для списка
            align       = MenuAlign.Left,
            useItemBG   = false,
        },

        -- Заголовок текущего порядка
        OrderTitle = {
            type        = MenuItemTypes.StaticText,
            text        = "Play Order:",
            desc        = "",
            action      = "",
            x           = 574, -- Пример
            y           = 150,
            fontBigSize = 20,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Left,
            useItemBG   = false,
        },

        -- Текст с текущим порядком (через textFuc)
        OrderText = {
            type        = MenuItemTypes.StaticText,
            textFuc     = "BattleMusicMenu:GetOrderTxt()",
            desc        = "",
            action      = "",
            x           = 574, -- Пример
            y           = 180,
            fontBigSize = 14,
            textColor   = R3D.RGBA( 255, 255, 255, 255 ),
            align       = MenuAlign.Left,
            useItemBG   = false,
        },

        -- Кнопки управления (упрощённо)
        Btn_Add = {
            type        = MenuItemTypes.TextButton,
            text        = "+ Add All",
            desc        = "Add all tracks to play order.",
            action      = "BattleMusicMenu:AddAllTracks()",
            x           = 574,
            y           = 400, -- Пример
            fontBigSize = 20,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Center,
            sndAccept   = "menu/menu/option-accept",
            sndLightOn  = "menu/menu/option-light-on",
        },

        Btn_Remove = {
            type        = MenuItemTypes.TextButton,
            text        = "- Clear",
            desc        = "Clear the play order.",
            action      = "BattleMusicMenu:ClearOrder()",
            x           = 674, -- Пример
            y           = 400,
            fontBigSize = 20,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Center,
            sndAccept   = "menu/menu/option-accept",
            sndLightOn  = "menu/menu/option-light-on",
        },

        Btn_MoveUp = {
            type        = MenuItemTypes.TextButton,
            text        = "↑ Up",
            desc        = "Move last track up in order.",
            action      = "BattleMusicMenu:MoveUp()",
            x           = 774, -- Пример
            y           = 400,
            fontBigSize = 20,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Center,
            sndAccept   = "menu/menu/option-accept",
            sndLightOn  = "menu/menu/option-light-on",
        },

        Btn_MoveDown = {
            type        = MenuItemTypes.TextButton,
            text        = "↓ Down",
            desc        = "Move last track down in order.",
            action      = "BattleMusicMenu:MoveDown()",
            x           = 874, -- Пример
            y           = 400,
            fontBigSize = 20,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Center,
            sndAccept   = "menu/menu/option-accept",
            sndLightOn  = "menu/menu/option-light-on",
        },

        -- Кнопка сохранения
        Btn_Save = {
            type        = MenuItemTypes.TextButton,
            text        = "Save Order",
            desc        = "Save the current play order to file.",
            action      = "BattleMusicMenu:SaveAndExit()",
            x           = 952, -- Пример
            y           = 660, -- Пример
            fontBigSize = 26,
            textColor   = R3D.RGBA( 255, 186, 122, 255 ),
            align       = MenuAlign.Right,
            sndAccept   = "menu/menu/apply-accept",
            sndLightOn  = "menu/menu/back-light-on",
        },
    }
}

-- --- Функции для отображения текста ---
function BattleMusicMenu:GetAvailableTracksTxt()
    -- Обновляем список треков
    if BattleMusic then
        BattleMusic:Load()
    end
    local txt = "\n" -- Начинаем с новой строки для отступа
    local tracks = BattleMusic and BattleMusic.Tracks or {}
    for i = 1, table.getn(tracks) do
        txt = txt .. i .. ". " .. BattleMusic:GetTrackName(i) .. "\n"
    end
    if txt == "\n" then
        txt = "\nNo tracks found in Data/CustomSound/\n"
    end
    return txt
end

function BattleMusicMenu:GetOrderTxt()
    -- Обновляем список треков
    if BattleMusic then
        BattleMusic:Load()
    end
    local txt = "\n" -- Начинаем с новой строки для отступа
    local order = BattleMusic and BattleMusic.Order or {}
    for i = 1, table.getn(order) do
        local idx = order[i]
        txt = txt .. i .. ". " .. BattleMusic:GetTrackName(idx) .. "\n"
    end
    if txt == "\n" then
        txt = "\nEmpty. Will play all available tracks.\n"
    end
    return txt
end

-- === Функции меню BattleMusicMenu ===

function BattleMusicMenu:AddAllTracks()
    if not BattleMusic then
        Game:Print("BattleMusicMenu:AddAllTracks: BattleMusic not loaded!")
        return
    end
    BattleMusic.Order = {}
    for i = 1, table.getn(BattleMusic.Tracks) do
        table.insert(BattleMusic.Order, i) -- Добавляем индексы
    end
    BattleMusic:Save() -- Сохраняем сразу
    PainMenu:ActivateScreen(BattleMusicMenu) -- Перезагружаем меню
end

function BattleMusicMenu:ClearOrder()
    if not BattleMusic then
        Game:Print("BattleMusicMenu:ClearOrder: BattleMusic not loaded!")
        return
    end
    BattleMusic.Order = {}
    BattleMusic:Save() -- Сохраняем сразу
    PainMenu:ActivateScreen(BattleMusicMenu) -- Перезагружаем меню
end

function BattleMusicMenu:MoveUp()
    if not BattleMusic then
        Game:Print("BattleMusicMenu:MoveUp: BattleMusic not loaded!")
        return
    end
    local len = table.getn(BattleMusic.Order)
    if len >= 2 then
        -- Меняем местами последние два элемента
        local idx = len
        local tmp = BattleMusic.Order[idx - 1]
        BattleMusic.Order[idx - 1] = BattleMusic.Order[idx]
        BattleMusic.Order[idx] = tmp
        BattleMusic:Save() -- Сохраняем сразу
        PainMenu:ActivateScreen(BattleMusicMenu) -- Перезагружаем меню
    end
end

function BattleMusicMenu:MoveDown()
    if not BattleMusic then
        Game:Print("BattleMusicMenu:MoveDown: BattleMusic not loaded!")
        return
    end
    local len = table.getn(BattleMusic.Order)
    if len >= 2 then
        -- Меняем местами первые два элемента
        local idx = 1
        local tmp = BattleMusic.Order[idx + 1]
        BattleMusic.Order[idx + 1] = BattleMusic.Order[idx]
        BattleMusic.Order[idx] = tmp
        BattleMusic:Save() -- Сохраняем сразу
        PainMenu:ActivateScreen(BattleMusicMenu) -- Перезагружаем меню
    end
end

-- Функция SaveAndExit
function BattleMusicMenu:SaveAndExit()
    if BattleMusic then
        BattleMusic:Save()
    end
    PainMenu:ActivateScreen(MainMenu)
end

function BattleMusicMenu:Activate()
    PainMenu:ActivateScreen(self)
end