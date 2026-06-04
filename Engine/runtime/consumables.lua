local CONSUMABLES = {
	bandage = {
		name = "Bandage",
		desc = "Restore 2 Vitality.",
		use = function(player)
			player.stats.vitality = math.min(
				player.max_vitality or 10,
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
				player.max_vitality or 10,
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
	count = count or 1
	player.inventory.consumables[id] = (player.inventory.consumables[id] or 0) + count
end

function M.has(player, id)
	return (player.inventory.consumables[id] or 0) > 0
end

function M.count(player, id)
	return player.inventory.consumables[id] or 0
end

return M
