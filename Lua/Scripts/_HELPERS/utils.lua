---@diagnostic disable: undefined-field, undefined-global
Utils = {}

math.randomseed(os.time())

function Utils.is_game_paused()
	if SERVER then
		return false
	end

	return Game.Paused
end

--[[ Utils.SetAffliction
* character: Кто получит аффликшен (Barotrauma.Character)
* affliction: Айди (String)
* strength: Сколько должно быть аффликшена
* limb: Конечность для применения. (Barotrauma.LimbType)
* add: Если true, то аффликшен будет добавлятся, а не переназначаться
* source: кто применил этот аффликшен (Barotrauma.Character) ]] --
function Utils.SetAffliction(character, affliction, strength, limb, add, source)
	local prefab = AfflictionPrefab.Prefabs[affliction]

	limb = limb or LimbType.Torso
	add = add or false

	local strength = strength * character.CharacterHealth.MaxVitality / 100
	local affliction = prefab.Instantiate(strength, source)

	character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(limb), affliction, add)
end

--[[ Utils.SetAffliction
* character: Кто получит аффликшен (Barotrauma.Character)
* affliction: Айди (String)
* strength: Сколько должно быть аффликшена
* limb: Конечность для применения. (Barotrauma.LimbType)
* add: Если true, то аффликшен будет добавлятся, а не переназначаться
* seconds: длительность аффликшена, если он временный
* source: кто применил этот аффликшен (Barotrauma.Character) ]]
function Utils.SetAfflictionTime(character, affliction, strength, limb, add, seconds, source)
	local prefab = AfflictionPrefab.Prefabs[affliction]

	limb = limb or LimbType.Torso
	add = add or false
	delay = 0 or seconds * 1000

	local strength = strength * character.CharacterHealth.MaxVitality / 100
	local affliction = prefab.Instantiate(strength, source)

	character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(limb), affliction, add)

	Timer.Wait(function()
		local affliction = prefab.Instantiate(-strength, source)
		character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(limb), affliction, add)
	end, delay)
end

function Utils.RemoveItem(item)
	if item == nil or item.Removed then return end

	if SERVER then
		-- use server remove method
		Entity.Spawner.AddEntityToRemoveQueue(item)
	else
		-- use client remove method
		item.Remove()
	end
end

--[[
Utils.GetAffliction
* character: У кого проверять (Barotrauma.Character)
* affliction: Айди аффликшена на проверку (String) 
]]
function Utils.GetAffliction(character, affliction)
	local aff = character.CharacterHealth.GetAffliction(affliction)
	if aff == nil then
		return 0
	end
	return aff.Strength
end

--[[ Utils.GetAfflictionLimb
* character: У кого проверять (Barotrauma.Character)
* affliction: Айди аффликшена на проверку (String)
* limb: Конечность для проверки. (Barotrauma.LimbType) --]]
function Utils.GetAfflictionLimb(character, affliction, limb)
	local aff = character.CharacterHealth.GetAffliction(affliction, character.AnimController.GetLimb(limb))
	if aff == nil then
		return 0
	end
	return aff.Strength
end

function Utils.ThrowError(text, level)
	if level == nil then level = 0 end
	error("AMlua Custom Error: " .. text, 2 + level)
end

--[[
Возвращает true/false с псевдошансом
]]
function Utils.Probability(chance)
	local random = math.random() * 100
	return random <= chance
end

-- Thanks Mannatu. Now this is my function e-he-he-he
function Utils.LimbTypeToString(type)
	if (type == LimbType.Torso) then return "Torso" end
	if (type == LimbType.Head) then return "Head" end
	if (type == LimbType.LeftArm or type == LimbType.LeftForearm or type == LimbType.LeftHand) then return "Left Arm" end
	if (type == LimbType.RightArm or type == LimbType.RightForearm or type == LimbType.RightHand) then return "Right Arm" end
	if (type == LimbType.LeftLeg or type == LimbType.LeftThigh or type == LimbType.LeftFoot) then return "Left Leg" end
	if (type == LimbType.RightLeg or type == LimbType.RightThigh or type == LimbType.RightFoot) then return "Right Leg" end
	return "???"
end

-- converts thighs, feet, forearms and hands into legs and arms
function Utils.NormalizeLimbType(limbtype)
	if limbtype == LimbType.Head or
		limbtype == LimbType.Torso or
		limbtype == LimbType.RightArm or
		limbtype == LimbType.LeftArm or
		limbtype == LimbType.RightLeg or
		limbtype == LimbType.LeftLeg then
		return limbtype
	end

	if limbtype == LimbType.LeftForearm or limbtype == LimbType.LeftHand then
		return LimbType.LeftArm
	elseif limbtype == LimbType.RightForearm or limbtype == LimbType.RightHand then
		return LimbType.RightArm
	elseif limbtype == LimbType.LeftThigh or limbtype == LimbType.LeftFoot then
		return LimbType.LeftLeg
	elseif limbtype == LimbType.RightThigh or limbtype == LimbType.RightFoot then
		return LimbType.RightLeg
	elseif limbtype == LimbType.Waist then
		return LimbType.Torso
	end

	return limbtype
end

-- misc --
function PrintChat(msg)
	if SERVER then
		-- use server method
		Game.SendMessage(msg, ChatMessageType.Server)
	else
		-- use client method
		Game.ChatBox.AddMessage(ChatMessage.Create("", msg, ChatMessageType.Server, nil))
	end

end

function Utils.DMClient(client, msg, color)
	if SERVER then
		if (client == nil) then return end

		local chatMessage = ChatMessage.Create("", msg, ChatMessageType.Server, nil)
		if (color ~= nil) then chatMessage.Color = color end
		Game.SendDirectChatMessage(chatMessage, client)
	else
		PrintChat(msg)
	end
end

function Utils.CharacterToClient(character)

	if not SERVER then return nil end

	for key, client in pairs(Client.ClientList) do
		if client.Character == character then
			return client
		end
	end

	return nil
end
