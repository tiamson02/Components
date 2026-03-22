--============================================================================
-- Profile System 
-- by CityZD Lead Team
--============================================================================
PlayerProfile = {
	GameplayTime 		 = 0,
	EnemiesKilled 		 = 0,
	SoulsCollected 		 = 0,
	GoldFound 			 = 0,
	ArmorsFound 		 = 0,
	HolyItemsFound 		 = 0,
	AmmoFound 			 = 0,
	ObjectsDestroyed 	 = 0,
	SecretsFound 		 = 0,

	DemonMorphCount		 = 0,
	KilledInDemonMode	 = 0,
	NrOfPowerUps		 = 0,
	NrOfGCUses			 = 0,
	NrOfJumps			 = 0,
	NrOfDeaths			 = 0,
	NrOfFiveStarsLevels	 = 0,
	NrOfGameLaunches	 = 0,
	NrOfCritHP			 = 0,
	NrOfDmgPlayer		 = 0,
	NrOfDmgMobs			 = 0,
	NrOfRestoredHP		 = 0,
	NrOfAirKills		 = 0,
	Difficulty 			 = 1,

	EmptyTask			 = 0,

	-- RPG
	RPG = {
		Enabled = true, -- Если система всегда включена для профиля
		PlayerLevel = 1,
		PlayerXP = 0,
		XPToNextLevel = 100,
		SkillPoints = 0,
		Stats = {
			Strength = 1,
			Agility = 1,
			Intelligence = 1
		},
		ActiveSkills = {},
		SkillTree = {} -- Или используй стандартное дерево из RPG.lua
	},
	Check_Complete_MainCampain			= false,
}
--============================================================================
function PlayerProfile:ResetStats(obj)	
	if not obj then return end
	
	obj.GameplayTime 		 = 0
	obj.EnemiesKilled 		 = 0
	obj.SoulsCollected 		 = 0
	obj.GoldFound 			 = 0
	obj.ArmorsFound 		 = 0
	obj.HolyItemsFound 		 = 0
	obj.AmmoFound 			 = 0
	obj.ObjectsDestroyed 	 = 0
	obj.SecretsFound 		 = 0

	obj.DemonMorphCount		 = 0
	obj.KilledInDemonMode	 = 0
	obj.NrOfPowerUps		 = 0
	obj.NrOfGCUses			 = 0
	obj.NrOfJumps			 = 0
	obj.NrOfDeaths			 = 0
	obj.NrOfFiveStarsLevels	 = 0
	obj.NrOfGameLaunches	 = 0
	obj.NrOfCritHP			 = 0
	obj.NrOfDmgPlayer		 = 0
	obj.NrOfDmgMobs			 = 0
	obj.NrOfRestoredHP		 = 0
	obj.NrOfAirKills		 = 0
	obj.Difficulty 			 = 1

	-- RPG
	obj.RPG = {
		Enabled = true,
		PlayerLevel = 1,
		PlayerXP = 0,
		XPToNextLevel = 100,
		SkillPoints = 0,
		Stats = {
			Strength = 1,
			Agility = 1,
			Intelligence = 1
		},
		ActiveSkills = {},
		--SkillTree = Clone(RPGSystem.SkillTree.nodes) -- Важно: инициализировать с тем же деревом, что и в RPG.lua
	}

	obj.EmptyTask			 = 0

	obj.Check_Complete_MainCampain			= false

end
--============================================================================
-- false - Profile already exists
-- true - Profile creation ok
--============================================================================
function PlayerProfile:Create(name)	
	if not name then return end
	
	local profiles = self:GetProfiles()	
	
	for i,v in profiles do
		if v == name then
			return false
		end
	end
	
	local obj = Clone(self)
	self:ResetStats(obj)
	
	self:Save(name, obj)
	return true
end
--============================================================================
function PlayerProfile:Delete(name)	
	if not name then return end
	if name == "Default" then
		return 
	end
	
	local path = "../Profiles/"..name.."/"
	
	local dirs = FS.FindFiles(path.."SaveGames/*",0,1)
	
	for i,v in dirs do
		FS.DeleteFiles(path.."SaveGames/"..v.."/")
		FS.RemoveDirectory(path.."SaveGames/"..v.."/")
		
	end
	FS.RemoveDirectory(path.."SaveGames/")
		
	FS.DeleteFiles(path)
	FS.RemoveDirectory(path)
	
	if Cfg.CurrentProfile and Cfg.CurrentProfile == name then
		Cfg.CurrentProfile = "Default"
		Game:SetProfile(Cfg.CurrentProfile)
	end
end
--============================================================================
function PlayerProfile:IsProfileOnDisk(name)	
	local list = PlayerProfile:GetProfiles()	
	
	for i,v in list do
		if v == name then return true end
	end
	
	return false
end
--============================================================================
function PlayerProfile:GetProfiles()	
	local list = FS.FindFiles("../Profiles/*",0,1)	
	for i,v in list do
		if v == "CVS" then
			table.remove(list,i)
		end
	end

	return list
end
--============================================================================
function PlayerProfile:Save(name,profile)
		if not profile then return end
		FS.CreateDirectory("../Profiles/")	
		local path = "../Profiles/"..name.."/"	
		FS.CreateDirectory(path)
		
		FS.CreatePAK(path.."profile.dat")	
		SaveFullObj(path.."profile.info",profile)			
		FS.ClosePAK()

		--CONSOLE.AddMessage("Profile is saved")
end
--============================================================================
function PlayerProfile:LoadProfile(name)
	if not name then return end
	local path = "../Profiles/"..name.."/*"
	
	local list = FS.FindFiles(path,1,0)			
	
	if table.getn(list) == 0 then
		Game:Print("Corrupted profile - missing data")
		local obj = Clone(self)
		self:Save(name, obj)		
	end
	
	o = TableClone(PlayerProfile)
	
	local pack = FS.RegisterPack("../Profiles/"..name.."/profile.dat", "../Profiles/"..name.."/" )		

		DoFile("../Profiles/"..name.."/profile.info")
		FS.UnregisterPack(pack)
	return o
end