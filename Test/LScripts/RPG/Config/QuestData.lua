--============================================================================
-- By 7ZOV
--============================================================================

QuestData = QuestData or {}

QuestData.Q001_SoldierHunt = {
	ID = "Q001_SoldierHunt",
	Name = "Hunt the Soldiers",
	Description = "Kill 5 zombie soldiers.",
	TargetActor = "Zombie_Soldier_WalkOnly.CActor",
	TargetCount = 5,
	RewardXP = 100,
	RewardMoney = 50,
	OnComplete = function()
		CONSOLE.AddMessage("Quest 'Hunt the Soldiers' completed! +100 XP")
		if Game.AddXP then
			Game:AddXP(100)  -- ← начисляем XP
		end
		if Player then
			Game.PlayerMoney = (Game.PlayerMoney or 0) + 50
			CONSOLE.AddMessage("+50 coins")
		end
	end
}

Q001_SoldierHunt = QuestData.Q001_SoldierHunt