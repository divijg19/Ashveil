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
		name = "Exploratoris Ephemeris",
		desc = "\"Day 17. The whispers are louder below.\"",
	},
	sigillum_fractum = {
		name = "Sigillum Fractum",
		desc = "Something once rested here.",
	},
}

local M = {}

function M.def(id)
	return ARTIFACTS[id]
end

function M.grant(player, id)
	if not ARTIFACTS[id] then
		return false
	end
	player.inventory.artifacts[id] = true
	return true
end

function M.has(player, id)
	return player.inventory.artifacts[id] == true
end

function M.count(player)
	local n = 0
	for _ in pairs(player.inventory.artifacts or {}) do
		n = n + 1
	end
	return n
end

return M
