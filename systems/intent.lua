local Entities = require("Engine.runtime.entities")

local M = {}

local INTENTS = {"attack", "heavy_attack", "defend", "recover"}

local ARCHETYPE_RULES = {
	brute = {
		heavy_damage = 2,
	},
	stalker = {
		no_defend = true,
	},
	watcher = {
		recover_amount = 2,
	},
	fanatic = {
		heavy_bonus = 2,
	},
}

function M.select_intent(archetype, hp, max_hp)
	local def = Entities.archetype_def(archetype)
	if not def then
		return "attack"
	end

	local weights = {}
	for intent, w in pairs(def.intent_weights) do
		weights[intent] = w
	end

	-- Apply archetype rules
	local rule = ARCHETYPE_RULES[archetype]
	if rule then
		if rule.no_defend then
			weights.defend = nil
		end
		if rule.heavy_bonus then
			weights.heavy_attack = (weights.heavy_attack or 0) + rule.heavy_bonus
		end
	end

	-- Wounded-state behavior (below 50% HP)
	if hp and max_hp and hp <= math.floor(max_hp / 2) then
		if archetype == "brute" then
			weights.heavy_attack = math.floor((weights.heavy_attack or 0) / 2)
			weights.recover = (weights.recover or 0) + 2
		elseif archetype == "watcher" then
			weights.recover = (weights.recover or 0) + 2
			weights.defend = (weights.defend or 0) + 1
		elseif archetype == "fanatic" then
			weights.heavy_attack = (weights.heavy_attack or 0) + 2
		end
	end

	local total = 0
	for _, w in pairs(weights) do
		total = total + w
	end

	local roll = love.math.random() * total
	local cumulative = 0

	for _, intent in ipairs(INTENTS) do
		local w = weights[intent]
		if w then
			cumulative = cumulative + w
			if roll <= cumulative then
				return intent
			end
		end
	end

	return "attack"
end

function M.intent_damage(intent, archetype)
	if intent == "heavy_attack" then
		local rule = ARCHETYPE_RULES[archetype]
		if rule and rule.heavy_damage then
			return rule.heavy_damage
		end
		return 2
	elseif intent == "attack" then
		return 1
	end
	return 0
end

function M.archetype_rule(archetype, key)
	local rule = ARCHETYPE_RULES[archetype]
	if rule then
		return rule[key]
	end
	return nil
end

return M
