local ARTIFACTS = {
	messorem_cinis = {
		name = "Messorem Cinis",
		desc = "A fragment of charcoal-black stone.\nThe symbol is unmistakable.",
	},
	preces_fragmentum = {
		name = "Preces Fragmentum",
		desc = "\"...let the Veil remember my name...\"",
	},
	exploratoris_ephemeris = {
		name = "Explorer's Journal",
		desc = "\"Day 17. The whispers are louder below.\"",
	},
	sigillum_fractum = {
		name = "Sigillum Fractum",
		desc = "Something once rested here.",
	},
	broken_compass = {
		name = "Broken Compass",
		desc = "The needle spins endlessly.",
	},
	melted_coin = {
		name = "Melted Coin",
		desc = "The markings have been worn smooth.",
	},
	cracked_idol = {
		name = "Cracked Idol",
		desc = "A small stone figure. The face is gone.",
	},
}

local M = {}

function M.def(id)
	return ARTIFACTS[id]
end

function M.grant(player, id, floor, region, source)
	if not ARTIFACTS[id] then
		return false
	end
	if floor then
		player.inventory.artifacts[id] = {
			floor = floor,
			region = region,
			source = source,
		}
	else
		player.inventory.artifacts[id] = { legacy = true }
	end
	return true
end

function M.has(player, id)
	return player.inventory.artifacts[id] ~= nil
end

function M.count(player)
	local n = 0
	for _ in pairs(player.inventory.artifacts or {}) do
		n = n + 1
	end
	return n
end

function M.each(player)
	return pairs(player.inventory.artifacts or {})
end

return M
