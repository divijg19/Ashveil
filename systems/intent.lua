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

function M.select_intent(archetype)
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
		-- Stalker cannot defend
		if rule.no_defend then
			weights.defend = nil
		end
		-- Fanatic favors heavy attacks
		if rule.heavy_bonus then
			weights.heavy_attack = (weights.heavy_attack or 0) + rule.heavy_bonus
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
