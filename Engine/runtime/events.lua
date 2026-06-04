local Reward = require("Engine.runtime.rewards")
local Relics = require("Engine.runtime.relics")
local Artifacts = require("Engine.runtime.artifacts")
local Consumables = require("Engine.runtime.consumables")

local SYMBOLS = {"△", "□", "○", "◇"}

local EVENT_DEFS = {
	shrine_altar = {
		cancel_index = 4,
		message = "The altar radiates warmth.",
		options = {
			"Blessing of Ash (+1 Resolve)",
			"Blessing of Sight (+1 Perception)",
			"Blessing of Might (+1 Strength)",
			"Leave",
		},
		resolve = function(game, event, choice)
			-- Broken Prayer chain: step 2
			if game.player.discovery_flags.prayer_hint
				and not game.player.discovery_flags.prayer_hint_received
				and Relics.has(
					game.player,
					"forgotten_prayer"
				)
			then
				game.player.discovery_flags.prayer_hint_received = true
				local MessagePanel = require(
					"Engine.runtime.message_panel"
				)
				MessagePanel.push(
					"The altar hums in recognition of the prayer."
				)
			end

			local bonus = 1
			if game.player.blessing_doubled then
				bonus = 2
			end

			if choice == 1 then
				Reward.blessing(game.player, "Blessing of Ash")
				game.player.stats.resolve = game.player.stats.resolve + bonus
				game.player.gold = game.player.gold + 2
				return {message = "Resolve fills you. +" .. bonus .. " Resolve. An offering of gold rests at the base."}
			elseif choice == 2 then
				Reward.blessing(game.player, "Blessing of Sight")
				game.player.stats.perception = game.player.stats.perception + bonus
				game.player.gold = game.player.gold + 2
				return {message = "Your perception sharpens. +" .. bonus .. " Perception. An offering of gold rests at the base."}
			elseif choice == 3 then
				Reward.blessing(game.player, "Blessing of Might")
				game.player.stats.strength = game.player.stats.strength + bonus
				game.player.gold = game.player.gold + 2
				return {message = "Strength surges through you. +" .. bonus .. " Strength. An offering of gold rests at the base."}
			end
			return {message = nil}
		end,
	},

	shrine_seal = {
		cancel_index = 2,
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
				local bonus = 1
				if game.player.blessing_doubled then
					bonus = 2
				end
				game.player.stats[stat] = game.player.stats[stat] + bonus
				return {message = "A faint understanding settles in your mind. +"
					.. bonus .. " "
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
		cancel_index = 2,
		message = "A sealed sarcophagus rests before you.",
		options = {"Open", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.40 then
				Reward.vitality(game.player, 1)
				local msg = "You find preserved vitality within. +1 Vitality."
				if love.math.random() < 0.50 then
					Consumables.grant(game.player, "ration")
					msg = msg .. " Rations, still sealed."
				end
				return {message = msg}
			else
				return {message = "The sarcophagus is empty."}
			end
		end,
	},

	crypt_tomb = {
		cancel_index = 2,
		message = "The tomb has been disturbed. Claw marks scar the stone.",
		options = {"Investigate", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			-- Broken Prayer chain: step 3
			if game.floor >= 10
				and game.floor <= 14
				and game.player.discovery_flags.prayer_hint_received
				and not game.player.discovery_flags.prayer_truth
				and Relics.has(
					game.player,
					"forgotten_prayer"
				)
			then
				game.player.discovery_flags.prayer_truth = true
				return {
					message = "The tomb bears the missing verse. The prayer was never meant to end.",
				}
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
		cancel_index = 2,
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
		cancel_index = 4,
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
		cancel_index = 2,
		message = "Broken stone litters the floor.",
		options = {"Search", "Ignore"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.30 then
				Reward.vitality(game.player, 1)
				game.player.gold = game.player.gold + 1
				return {message = "You find a hidden vitality cache. +1 Vitality. A single coin glints nearby."}
			else
				return {message = "Nothing but dust and rubble."}
			end
		end,
	},

	ruin_statue = {
		cancel_index = 2,
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
				local gold = love.math.random(1, 2)
				game.player.gold = game.player.gold + gold
				return {message = "A faint glyph reveals hidden knowledge. +1 "
					.. stat:gsub("^%l", string.upper)
					.. ". You find " .. gold .. " gold near the base."}

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
		cancel_index = 2,
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
		cancel_index = 2,
		message = "A forgotten reliquary reveals itself.",
		options = {"Open", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local relic_id = Relics.random_unowned(game.player)
			if not relic_id then
				game.player.gold = game.player.gold + 10
				return {message = "The reliquary is empty. You find scattered gold."}
			end

			Relics.grant(game.player, relic_id)
			local def = Relics.def(relic_id)
			return {message = "You find " .. def.name .. "."}
		end,
	},

	hidden_passage = {
		cancel_index = 2,
		message = "A concealed passage opens before you.",
		options = {"Enter Passage", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.40 then
				Reward.vitality(game.player, 1)
				local msg = "You find a hidden cache. +1 Vitality."
				if love.math.random() < 0.50 then
					Consumables.grant(game.player, "bandage")
					msg = msg .. " A bandage is tucked inside."
				end
				return {message = msg}

			elseif roll < 0.70 then
				Reward.blessing(game.player, "Blessing of Discovery")
				return {message = "A forgotten blessing lingers here."}

			else
				return {message = "The passage is empty. Dust and silence remain."}
			end
		end,
	},

	side_door = {
		cancel_index = 2,
		message = "A strange door stands where no door should be.",
		options = {"Open Door", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local roll = love.math.random()

			if roll < 0.35 then
				Reward.vitality(game.player, 1)
				game.player.gold = game.player.gold + 1
				return {message = "A small chamber holds preserved vitality. +1 Vitality. A few coins lie scattered."}

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

	fallen_explorer = {
		cancel_index = 2,
		message = "A fallen explorer rests against the wall.\nTheir pack is partially open.",
		options = {"Search", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local gold = love.math.random(1, 3) + math.floor(game.floor / 5)
			game.player.gold = game.player.gold + gold

			local msg = "The explorer did not make it further. You find " .. gold .. " gold."

			if love.math.random() < 0.40 then
				Consumables.grant(game.player, "bandage")
				msg = msg .. " A bandage is tucked in their pack."
			end

			if love.math.random() < 0.20 then
				Artifacts.grant(game.player, "exploratoris_ephemeris")
				msg = msg .. " Their journal survives."
			end

			return {message = msg}
		end,
	},

	torn_satchel = {
		cancel_index = 2,
		message = "A torn satchel lies discarded in the shadows.",
		options = {"Search", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local gold = love.math.random(2, 4)
			game.player.gold = game.player.gold + gold

			local msg = "You find " .. gold .. " gold inside."

			if love.math.random() < 0.35 then
				Consumables.grant(game.player, "ration")
				msg = msg .. " A ration remains."
			end

			return {message = msg}
		end,
	},

	pilgrim_pack = {
		cancel_index = 2,
		message = "A weathered pack rests near the shrine. Pilgrim's belongings.",
		options = {"Search", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local gold = love.math.random(1, 3)
			game.player.gold = game.player.gold + gold

			local msg = "You find " .. gold .. " gold in the pack."

			if love.math.random() < 0.50 then
				Consumables.grant(game.player, "ration")
				msg = msg .. " Rations, untouched."
			end

			if not Artifacts.has(game.player, "preces_fragmentum") then
				Artifacts.grant(game.player, "preces_fragmentum")
				msg = msg .. " Inside, a strip of parchment with faded words."
			end

			return {message = msg}
		end,
	},

	hidden_cache = {
		cancel_index = 2,
		message = "You notice disturbed stonework. Something is hidden here.",
		options = {"Investigate", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local gold = love.math.random(8, 12)
			game.player.gold = game.player.gold + gold

			local msg = "You uncover a hidden cache with " .. gold .. " gold."

			local rng = love.math.random()
			if rng < 0.30 then
				Consumables.grant(game.player, "bandage")
				msg = msg .. " Bandages, preserved."
			elseif rng < 0.50 then
				Consumables.grant(game.player, "ration")
				msg = msg .. " Rations, still sealed."
			end

			if love.math.random() < 0.25 then
				Artifacts.grant(game.player, "sigillum_fractum")
				msg = msg .. " A broken seal lies behind loose stonework."
			end

			return {message = msg}
		end,
	},

	hidden_cache_scout = {
		cancel_index = 2,
		message = "You noticed disturbed stonework during the fight.",
		options = {"Investigate", "Leave"},
		resolve = function(game, event, choice)
			if choice == 2 then
				return {message = nil}
			end

			local gold = love.math.random(8, 12)
			local tier = event.poi and event.poi.scout_tier or "read"
			local mult = {
				glimpse = 1,
				read = 1,
				understand = 1.5,
				insight = 1.8,
				revelation = 2,
			}
			gold = math.floor(gold * (mult[tier] or 1))
			game.player.gold = game.player.gold + gold

			local msg = "You uncover a hidden cache with " .. gold .. " gold."

			local rng = love.math.random()
			if rng < 0.35 then
				Consumables.grant(game.player, "bandage")
				msg = msg .. " Bandages inside."
			elseif rng < 0.60 then
				Consumables.grant(game.player, "ration")
				msg = msg .. " Rations inside."
			end

			if love.math.random() < 0.20 then
				Artifacts.grant(game.player, "sigillum_fractum")
				msg = msg .. " A broken seal lies among the contents."
			end

			return {message = msg}
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
		cancel_index = def.cancel_index,
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

		local bonus = 1
		if game.player.blessing_doubled then
			bonus = 2
		end

		event.message = "The seal accepts your understanding. Choose:"
		event.options = {
			"+" .. bonus .. " Strength",
			"+" .. bonus .. " Resolve",
			"+" .. bonus .. " Perception",
		}
		event.resolve = function(g, e, c)
			local stat = c == 1 and "strength"
				or c == 2 and "resolve"
				or "perception"
			local b = 1
			if g.player.blessing_doubled then
				b = 2
			end
			g.player.stats[stat] = g.player.stats[stat] + b
			e.done = true
			return {message = "You feel transformed. +"
				.. b .. " "
				.. stat:gsub("^%l", string.upper) .. "."}
		end
		return {trial = true}
	end

	return {trial = true}
end

return M
