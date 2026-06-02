local Reward = require("Engine.runtime.rewards")

local SYMBOLS = {"△", "□", "○", "◇"}

local EVENT_DEFS = {
	shrine_altar = {
		message = "The altar radiates warmth.",
		options = {
			"Blessing of Ash (+1 Resolve)",
			"Blessing of Sight (+1 Perception)",
			"Blessing of Might (+1 Strength)",
			"Leave",
		},
		resolve = function(game, event, choice)
			if choice == 1 then
				Reward.blessing(game.player, "Blessing of Ash")
				game.player.stats.resolve = game.player.stats.resolve + 1
				return {message = "Resolve fills you. +1 Resolve."}
			elseif choice == 2 then
				Reward.blessing(game.player, "Blessing of Sight")
				game.player.stats.perception = game.player.stats.perception + 1
				return {message = "Your perception sharpens. +1 Perception."}
			elseif choice == 3 then
				Reward.blessing(game.player, "Blessing of Might")
				game.player.stats.strength = game.player.stats.strength + 1
				return {message = "Strength surges through you. +1 Strength."}
			end
			return {message = nil}
		end,
	},

	shrine_seal = {
		message = "The seal bears ancient markings.",
		options = {"Investigate", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.50 then
				return {message = "The markings tell no clear story. You move on."}

			elseif roll < 0.80 then
				local stats = {"strength", "resolve", "perception"}
				local stat = stats[love.math.random(#stats)]
				game.player.stats[stat] = game.player.stats[stat] + 1
				return {message = "A faint understanding settles in your mind. +1 "
					.. stat:gsub("^%l", string.upper) .. "."}

			else
				local sequence = {}
				for i = 1, love.math.random(3, 4) do
					sequence[i] = love.math.random(1, 4)
				end

				local msg_parts = {}
				for _, v in ipairs(sequence) do
					table.insert(msg_parts, SYMBOLS[v])
				end

				event.trial = {
					sequence = sequence,
					step = 1,
					mode = "observe",
				}
				event.message = "The seal pulses. Observe: "
					.. table.concat(msg_parts, " ")
				event.options = {"I am ready"}
				event.resolve = function(g, e, c)
					e.trial.mode = "input"
					e.trial.step = 1
					e.message = "Repeat the sequence:"
					e.options = {"△", "□", "○", "◇"}
					e.resolve = trial_resolve
					return {trial = true}
				end

				return {message = nil, trial = true}
			end
		end,
	},

	crypt_sarcophagus = {
		message = "A sealed sarcophagus rests before you.",
		options = {"Open", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.40 then
				Reward.vitality(game.player, 1)
				return {message = "You find preserved vitality within. +1 Vitality."}
			else
				return {message = "The sarcophagus is empty."}
			end
		end,
	},

	crypt_tomb = {
		message = "The tomb has been disturbed. Claw marks scar the stone.",
		options = {"Investigate", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()
			local resolve_mod = (game.player.stats.resolve - 1) * 0.05

			if roll < 0.30 then
				local stats = {"strength", "resolve", "perception"}
				local stat = stats[love.math.random(#stats)]
				game.player.stats[stat] = game.player.stats[stat] + 1
				return {message = "You find remnants of power within. +1 "
					.. stat:gsub("^%l", string.upper) .. "."}

			elseif roll < 0.60 - resolve_mod then
				return {message = "Something stirs within...", combat = true}

			elseif roll < 0.85 then
				Reward.vitality(game.player, 1)
				return {message = "A hidden cache yields vitality. +1 Vitality."}

			else
				return {message = "Nothing but dust and broken stone."}
			end
		end,
	},

	arena_challenge = {
		message = "The challenge stone pulses with energy.",
		options = {"Enter Arena", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			return {message = "The arena awaits...", combat = true}
		end,
	},

	arena_trial = {
		message = "The blood seal offers a greater challenge.",
		options = {
			"Trial of Wounds",
			"Trial of Shadows",
			"Trial of Fury",
			"Leave",
		},
		resolve = function(game, event, choice)
			if choice == 4 then
				return {message = nil}
			end

			if choice == 1 then
				game.player.stats.vitality =
					math.max(1, game.player.stats.vitality - 3)
				game.player.trial_mod = "wounds"
				return {message = "The seal demands blood.", combat = true}

			elseif choice == 2 then
				game.player.trial_mod = "shadows"
				return {message = "The darkness watches.", combat = true}

			elseif choice == 3 then
				game.player.trial_mod = "fury"
				return {message = "The Veil remembers the weak.", combat = true}
			end
		end,
	},

	ruin_debris = {
		message = "Broken stone litters the floor.",
		options = {"Search", "Ignore"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.30 then
				Reward.vitality(game.player, 1)
				return {message = "You find a hidden vitality cache. +1 Vitality."}
			else
				return {message = "Nothing but dust and rubble."}
			end
		end,
	},

	ruin_statue = {
		message = "The statue stands weathered and worn. The face has been removed.",
		options = {"Examine", "Ignore"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.25 then
				local stats = {"strength", "resolve", "perception"}
				local stat = stats[love.math.random(#stats)]
				game.player.stats[stat] = game.player.stats[stat] + 1
				return {message = "A faint glyph reveals hidden knowledge. +1 "
					.. stat:gsub("^%l", string.upper) .. "."}

			elseif roll < 0.50 then
				Reward.vitality(game.player, 1)
				return {message = "You find a concealed cache. +1 Vitality."}

			elseif roll < 0.75 then
				Reward.blessing(game.player, "Blessing of Discovery")
				return {message = "The statue yields a blessing."}

			else
				return {message = "The statue holds nothing of value."}
			end
		end,
	},

	hall_brazier = {
		message = "The brazier flickers with ancient flame.",
		options = {"Light", "Ignore"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			game.player.buff_doubled = true
			return {message = "The flame responds. Your next reward will be doubled."}
		end,
	},

	shrine_reliquary = {
		message = "A forgotten reliquary reveals itself.",
		options = {"Open", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local stats = {"strength", "resolve", "perception"}
			local stat1 = stats[love.math.random(#stats)]
			local stat2 = stats[love.math.random(#stats)]

			game.player.stats[stat1] = game.player.stats[stat1] + 1
			game.player.stats[stat2] = game.player.stats[stat2] + 1

			return {message = "Ancient power flows through you. +1 "
				.. stat1:gsub("^%l", string.upper)
				.. ", +1 "
				.. stat2:gsub("^%l", string.upper)
				.. "."}
		end,
	},

	hidden_passage = {
		message = "A concealed passage opens before you.",
		options = {"Enter Passage", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.40 then
				Reward.vitality(game.player, 1)
				return {message = "You find a hidden cache. +1 Vitality."}

			elseif roll < 0.70 then
				Reward.blessing(game.player, "Blessing of Discovery")
				return {message = "A forgotten blessing lingers here."}

			else
				return {message = "The passage is empty. Dust and silence remain."}
			end
		end,
	},

	side_door = {
		message = "A strange door stands where no door should be.",
		options = {"Open Door", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.35 then
				Reward.vitality(game.player, 1)
				return {message = "A small chamber holds preserved vitality. +1 Vitality."}

			elseif roll < 0.70 then
				return {message = "The room beyond is empty. Dust covers the floor."}

			else
				local blessings = {
					"Blessing of Ash",
					"Blessing of Sight",
					"Blessing of Might",
					"Blessing of Discovery",
				}
				local name = blessings[love.math.random(#blessings)]
				Reward.blessing(game.player, name)
				return {message = "A forgotten shrine lies beyond. " .. name .. "."}
			end
		end,
	},
}

local M = {}

function M.start(event_type, poi)
	local def = EVENT_DEFS[event_type]
	if not def then
		return nil
	end

	return {
		type = event_type,
		message = def.message,
		options = def.options,
		resolve = def.resolve,
		selection = 1,
		result = nil,
		done = false,
		poi = poi,
	}
end

function M.resolve(game, event, choice)
	if not event.resolve then
		return
	end

	local result = event.resolve(game, event, choice)
	event.result = result

	if not result then
		return
	end

	if result.trial then
		return
	end

	event.done = true
end

function M.complete(game, event)
	event.done = true
end

local function trial_resolve(game, event, choice)
	local trial = event.trial
	local expected = trial.sequence[trial.step]

	if choice ~= expected then
		trial.mode = "done"
		event.message = "The seal falls silent. The pattern fades."
		event.options = {"Continue"}
		event.resolve = function(g, e, c)
			e.done = true
			return {message = nil}
		end
		return {trial = true}
	end

	trial.step = trial.step + 1

	if trial.step > #trial.sequence then
		trial.mode = "done"
		event.message = "The seal accepts your understanding. Choose:"
		event.options = {
			"+1 Strength",
			"+1 Resolve",
			"+1 Perception",
		}
		event.resolve = function(g, e, c)
			local stat = c == 1 and "strength"
				or c == 2 and "resolve"
				or "perception"
			g.player.stats[stat] = g.player.stats[stat] + 1
			e.done = true
			return {message = "You feel transformed. +1 "
				.. stat:gsub("^%l", string.upper) .. "."}
		end
		return {trial = true}
	end

	return {trial = true}
end

return M
