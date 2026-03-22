-- Типы сообщений, можешь создавать сколько  тебе нужно и с нужным именем
MessageType =
{
	ActorKill	= 1,
	ActorDamaged	= 2,
	PlayerDamaged	= 3,
	PlayerDead	= 4,
	-- e.t.c
}
setmetatable(MessageType,{__mode="vk"}) 

-- Основная глобальная таблица с функциями
MessageSystem = 
{
	Messages = {},
}

-- Инициализация всех существующх типов сообщений
function MessageSystem:Init()
	for i,v in MessageType do
		self.Messages[v] = {}
	end
end
-- Сразу вызов инициализаци должен быть здесь
MessageSystem:Init()

-- Отправка нужного сообщения. Сначала передаём нужный тип и затем нужное количество аргументов
function MessageSystem:Send(messageType, ...)
	if not self.Messages[messageType] then return end
	
	for i,v in self.Messages[messageType] do
		for j, k in v do
			if j ~= nil and k ~= nil then
				i(j, unpack(arg))
			end
		end
		
	end
end

-- Функция для добавления слушателя. Передаем тип сообщения который хотим слушать, затем саму таблицу передаём и после нужную функцию
-- Следи за тем чтобы аргументы функции всегда совпадали с тем, которые ты передаёшь через Send после типа сообщения.
function MessageSystem:AddListener(messageType, target, func)
	if not self.Messages[messageType] then return end
	
	if self.Messages[messageType][func] == nil then
		self.Messages[messageType][func] = {}
		setmetatable(self.Messages[messageType][func],{__mode="vk"}) 
	end
	
	self.Messages[messageType][func][target] = target
end

-- Функция для удаления слушателя. Так же надо указать тип сообщения, таблицу у которой брали функцию и саму функцию
function MessageSystem:RemoveListener(messageType,target, func)
	if not self.Messages[messageType] then return end
	if not self.Messages[messageType][func] == nil then return end
	
	self.Messages[messageType][func][target] = nil
end

-- Очистить все события
function MessageSystem:ClearAll()
	for i,v in MessageType do
		self.Messages[v] = {}
	end
end

--[[ Пример
-- Допустим есть акторы какие то
CActior = 
{
	Health = 100,
	IsTranZit = true,
}
 -- В функции дамага ищем где актор якобы умирает и отправляем сообщение всем слушателям
function CActor:OnDamaged(damage)
	
	
	if self.Health <= 0 then
		-- Допустим актор умер, отправляем всем слушателям сообщение о смерти
		MessageSystem:Send(MessageType.ActorKill, self, damage)
	end
	
end

-- Допустим есть какая то система квестов
QuestSystem = {}

-- Создаём у неё функцию или где удобно совпадающая с сигнатурой аргуметнов в Send
function QuestSystem:OnActorKilled(actor, damage)

	if actor ~= nil and actor.IsTranZit then
		-- QuestSystem:CompleteQuest("Kill Fucking TranZit, horses saved")
	end
end
-- После слушаем сообщение по типу, указывая таблицу из которой ты берёшь функцию и саму функцию, только через точку
-- Если собираешься слушать сообщение внутри функции таблицы, можешь и так сделать MessageSystem:AddListener(MessageType.ActorKill, self, self.OnActorKilled)
MessageSystem:AddListener(MessageType.ActorKill, QuestSystem, QuestSystem.OnActorKilled)

]]--
