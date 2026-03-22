--=======================================================================
-- PKLib - Painkiller UI Library (Rounded Corners Only)
-- Версия: 1.2 - Без обводки, закругление квадратиками
--=======================================================================

PKLib = {}
PKLib.Version = "1.2"

--=======================================================================
-- UI Module - Рисование закругленных элементов
--=======================================================================
PKLib.UI = {}

-- Нарисовать прямоугольник с закругленными углами (фон)
-- Используем квадратики для формирования закруглений
function PKLib.UI.DrawRoundedRect(x, y, w, h, r, g, b, alpha, radius)
    if not radius then radius = 10 end
    if w < radius * 2 then w = radius * 2 end
    if h < radius * 2 then h = radius * 2 end
    
    -- Центральная часть (полный прямоугольник)
    HUD.DrawQuadRGBA(nil, x, y, w, h, r, g, b, alpha)
    
    -- Убираем углы (рисуем поверх прозрачными или цветом фона)
    -- Верхний левый угол
    HUD.DrawQuadRGBA(nil, x, y, radius, radius, 0, 0, 0, 0)
    -- Верхний правый угол
    HUD.DrawQuadRGBA(nil, x + w - radius, y, radius, radius, 0, 0, 0, 0)
    -- Нижний левый угол
    HUD.DrawQuadRGBA(nil, x, y + h - radius, radius, radius, 0, 0, 0, 0)
    -- Нижний правый угол
    HUD.DrawQuadRGBA(nil, x + w - radius, y + h - radius, radius, radius, 0, 0, 0, 0)
    
    -- Рисуем квадратики для закругления (по одному пикселю/единице)
    -- Это создаст эффект закругленных углов
    for i = 1, radius do
        local size = radius - i + 1
        -- Верхний левый
        HUD.DrawQuadRGBA(nil, x + i - 1, y + radius, 1, size, r, g, b, alpha)
        HUD.DrawQuadRGBA(nil, x + radius, y + i - 1, size, 1, r, g, b, alpha)
        
        -- Верхний правый
        HUD.DrawQuadRGBA(nil, x + w - radius - i, y + radius, 1, size, r, g, b, alpha)
        HUD.DrawQuadRGBA(nil, x + w - radius - size, y + i - 1, size, 1, r, g, b, alpha)
        
        -- Нижний левый
        HUD.DrawQuadRGBA(nil, x + i - 1, y + h - radius - size, 1, size, r, g, b, alpha)
        HUD.DrawQuadRGBA(nil, x + radius, y + h - radius - i, size, 1, r, g, b, alpha)
        
        -- Нижний правый
        HUD.DrawQuadRGBA(nil, x + w - radius - i, y + h - radius - size, 1, size, r, g, b, alpha)
        HUD.DrawQuadRGBA(nil, x + w - radius - size, y + h - radius - i, size, 1, r, g, b, alpha)
    end
end

-- Готовое меню с заголовком (только фон + титул, без рамки)
function PKLib.UI.DrawMenuBox(x, y, w, h, title, titleColor, bgColor, cornerRadius)
    -- Цвета по умолчанию
    if not titleColor then titleColor = {230, 161, 97, 255} end
    if not bgColor then bgColor = {0, 0, 0, 200} end
    if not cornerRadius then cornerRadius = 10 end
    
    -- Фон с закругленными углами
    PKLib.UI.DrawRoundedRect(x, y, w, h, bgColor[1], bgColor[2], bgColor[3], bgColor[4], cornerRadius)
    
    -- Заголовок
    if title then
        HUD.SetFont("timesbd", 28)
        local titleWidth = HUD.GetTextWidth(title, "timesbd", 28)
        HUD.PrintXY(x + (w - titleWidth) / 2, y + 10, title, "timesbd", 
                   titleColor[1], titleColor[2], titleColor[3], 28)
    end
end

--=======================================================================
-- Navigation Module - Простая навигация по меню
--=======================================================================
PKLib.Nav = {}

function PKLib.Nav.Create(itemCount, startIndex)
    if not startIndex then startIndex = 1 end
    return {
        Current = startIndex,
        Count = itemCount,
        Sounds = {
            move = "menu/menu_necro/scroller-move",
            select = "menu/mapselect/option-accept"
        }
    }
end

function PKLib.Nav.Handle(nav, keys)
    if not keys then
        keys = {
            up = Keys.UpArrow,
            down = Keys.DownArrow,
            enter = Keys.Enter,
            cancel = Keys.I
        }
    end
    
    local moved = false
    
    if INP.Key(keys.up) == 1 then
        if nav.Current > 1 then
            nav.Current = nav.Current - 1
            if nav.Sounds.move then PlaySound2D(nav.Sounds.move) end
            moved = true
        end
    end
    
    if INP.Key(keys.down) == 1 then
        if nav.Current < nav.Count then
            nav.Current = nav.Current + 1
            if nav.Sounds.move then PlaySound2D(nav.Sounds.move) end
            moved = true
        end
    end
    
    for i = 1, 9 do
        local keyNum = Keys["Num" .. i]
        local keyD = Keys["D" .. i]
        if (keyNum and INP.Key(keyNum) == 1) or (keyD and INP.Key(keyD) == 1) then
            if i <= nav.Count then
                nav.Current = i
                if nav.Sounds.move then PlaySound2D(nav.Sounds.move) end
                moved = true
            end
        end
    end
    
    return moved
end

function PKLib.Nav.GetSelected(nav)
    return nav.Current
end

function PKLib.Nav.SetCount(nav, count)
    nav.Count = count
    if nav.Current > count then
        nav.Current = count
    end
    if nav.Count < 1 then
        nav.Current = 1
    end
end

--=======================================================================
-- Инициализация
--=======================================================================

return PKLib