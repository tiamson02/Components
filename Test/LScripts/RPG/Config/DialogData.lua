--============================================================================
-- By 7ZOV
--============================================================================

--============================================================================
-- Пролог
--============================================================================

PrologDialogs = {

}

--============================================================================
-- Тестовая часть
--============================================================================

Dialogs = {
    test_dialog = {
        Text = "Hello, traveler! What brings you to these parts? I trade in various goods and services.",
        Options = {
            {
                Text = "Show me your products.",
                Action = "Console:Cmd_TRADER()",
                NextDialog = nil
            },
            {
                Text = "Tell me about yourself",
                Action = nil,
                NextDialog = "about_me"
            },
            
            {
                Text = "Do you have any work for me?",
                Action = nil,
                NextDialog = "test_work"
            },

            {
                Text = "Nothing, I was just passing by.",
                Action = nil,
                NextDialog = nil
            }
        }
    },

    test_work = {
        Text = "Yes, I have a job for you. Hunt down 5 zombie soldiers that have been terrorizing the area.",
        Options = {
            {
                Text = "I'm taking on 'Soldier Hunting'",
                Condition = function()
                    local questState = QuestSystem:GetQuestState("Q001_SoldierHunt")
                    return questState ~= "active" and questState ~= "completed"
                end,
                Action = "QuestSystem:StartQuest('Q001_SoldierHunt')",
                NextDialog = "test_dialog",
            },

            {
                Text = "Not interested",
                Action = nil,
                NextDialog = "test_dialog",
            },
        }

    },
    
    about_me = {
        Text = "I'm an old trader, I've been wandering these lands for many years. I've seen a lot... Too much. But if you need anything, I'll help you.",
        Options = {
            {
                Text = "Thank you for the information",
                Action = nil,
                NextDialog = "test_dialog",
            },
            {
                Text = "Can you tell me more?",
                Action = nil,
                NextDialog = "more_info"
            }
        }
    },
    
    more_info = {
        Text = "What exactly are you interested in? I can tell you about the local dangers, trade routes, or how to survive in this damned place.",
        Options = {
            {
                Text = "Dangers",
                Action = "CONSOLE.AddMessage('Be careful of demons in these parts...')",
                NextDialog = nil
            },
            {
                Text = "Trade routes",
                Action = "CONSOLE.AddMessage('The trade routes are long abandoned, but I know a couple of good places...')",
                NextDialog = nil
            },
            {
                Text = "How to survive",
                Action = "CONSOLE.AddMessage('Keep your weapons clean and always have a supply of ammunition.!')",
                NextDialog = nil
            },
            {
                Text = "Return to trading",
                Action = "Console:Cmd_TRADER()",
                NextDialog = nil
            }
        }
    }
}
