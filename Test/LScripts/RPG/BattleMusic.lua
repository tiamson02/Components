
BattleMusic = {
    Tracks = {},
    Order = {},
    Loaded = false,
    CurrentCategory = "Battle", -- можно менять: "Ambient", "Menu", etc.
}

CUSTOM_SOUND_PATH = "../Data/CustomSound/"

function BattleMusic:Load(category)
    if category then
        self.CurrentCategory = category
    else
        category = self.CurrentCategory or "Battle"
    end

    self.Tracks = {}
    local baseDir = "../Data/CustomSound/" .. category
    local searchPattern = baseDir .. "/*"

    local files = FS.FindFiles(searchPattern, 1, 0)
    if not files then
        --Game:Print("BattleMusic: No files found in " .. baseDir .. " (or directory doesn't exist)")
        self.Order = {}
        self:LoadOrderFromFile(baseDir .. "/order.cfg")
        self.Loaded = true
        return
    end

    for i = 1, table.getn(files) do
        local f = files[i]
        if f ~= "." and f ~= ".." then
            local lowerF = string.lower(f)
            if string.sub(lowerF, -4) == ".wav" or string.sub(lowerF, -4) == ".ogg" then
                table.insert(self.Tracks, f)
            end
        end
    end

    table.sort(self.Tracks)

    self.Order = {}
    self:LoadOrderFromFile(baseDir .. "/order.cfg")

    if table.getn(self.Order) == 0 then
        for i = 1, table.getn(self.Tracks) do
            table.insert(self.Order, i)
        end
    end

    self.Loaded = true
    Game:Print("BattleMusic: Loaded " .. table.getn(self.Tracks) .. " tracks from " .. baseDir)
end

function BattleMusic:LoadOrderFromFile(cfgPath)
    local f = io.open(cfgPath, "r")
    if f then
        for line in f:lines() do
            local cleanLine = string.gsub(line, "^%s*(.-)%s*$", "%1")
            local num = tonumber(cleanLine)
            if num and num >= 1 and num <= table.getn(self.Tracks) then
                table.insert(self.Order, num)
            end
        end
        f:close()
    end
end

function BattleMusic:Save()
    local f = io.open(CUSTOM_SOUND_PATH .. "order.cfg", "w")
    if f then
        for i = 1, table.getn(self.Order) do
            f:write(self.Order[i], "\n")
        end
        f:close()
    end
end

function BattleMusic:GetTrackName(trackIndex)
    if trackIndex and trackIndex >= 1 and trackIndex <= table.getn(self.Tracks) then
        return self.Tracks[trackIndex]
    end
    return "Invalid Track"
end
