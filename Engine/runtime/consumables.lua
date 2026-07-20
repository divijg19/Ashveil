local Equipment = require("Engine.runtime.equipment")

local CONSUMABLES = {
	bandage = {
		name = "Bandage",
		desc = "Restore 2 Vitality.",
		use = function(player)
			player.stats.vitality = math.min(
				Equipment.effective_max_vitality(player),
				player.stats.vitality + 2
			)
		end,
		use_message = "You apply a bandage. +2 Vitality.",
	},
	ration = {
		name = "Ration",
		desc = "Restore 1 Vitality.",
		use = function(player)
			player.stats.vitality = math.min(
				Equipment.effective_max_vitality(player),
				player.stats.vitality + 1
			)
		end,
		use_message = "You eat a ration. +1 Vitality.",
	},
}

local M = {}

function M.def(id)
	return CONSUMABLES[id]
end

function M.grant(player, id, count)
	if not player or not player.inventory or not player.inventory.consumables then return false end
	count = math.max(count or 1, 0)
	player.inventory.consumables[id] = (player.inventory.consumables[id] or 0) + count
end

function M.has(player, id)
	if not player or not player.inventory or not player.inventory.consumables then
		return false
	end
	return (player.inventory.consumables[id] or 0) > 0
end

function M.count(player, id)
	if not player or not player.inventory then
		return 0
	end
	return player.inventory.consumables[id] or 0
end

return M
