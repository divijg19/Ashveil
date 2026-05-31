local Reward = require("Engine.runtime.rewards")

local EVENT_DEFS = {
	shrine = {
		message = "The altar remains intact.",
		options = {"Pray", "Leave"},
		resolve = function(game, choice)
			if choice == 1 then
				Reward.vitality(game.player, 1)
				return {message = "A warmth spreads through you."}
			end
			return {message = nil}
		end,
	},

	crypt = {
		message = "A sealed sarcophagus remains untouched.",
		options = {"Open", "Leave"},
		resolve = function(game, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.35 then
				Reward.vitality(game.player, 1)
				return {message = "You find preserved vitality within."}
			elseif roll < 0.65 then
				return {message = "Something stirs within...", combat = true}
			else
				return {message = "The sarcophagus is empty."}
			end
		end,
	},

	arena = {
		message = "The arena awaits.",
		options = {"Enter", "Leave"},
		resolve = function(game, choice)
			if choice == 2 then
				return {message = nil}
			end
			return {message = nil, combat = true}
		end,
	},

	ruin = {
		message = "Broken stone litters the floor.",
		options = {"Search", "Ignore"},
		resolve = function(game, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.3 then
				Reward.vitality(game.player, 1)
				return {message = "You find a hidden vitality cache."}
			elseif roll < 0.6 then
				return {message = "Nothing but dust and stone."}
			else
				return {message = "The ruins yield nothing."}
			end
		end,
	},
}

local M = {}

function M.start(type, room)
	local def = EVENT_DEFS[type]
	if not def then
		return nil
	end

	return {
		type = type,
		message = def.message,
		options = def.options,
		resolve = def.resolve,
		selection = 1,
		result = nil,
		done = false,
	}
end

function M.complete(game, event)
	event.done = true
end

function M.resolve(game, event, choice)
	local result = event.resolve(game, choice)
	event.result = result
	event.done = true
	return result
end

return M
