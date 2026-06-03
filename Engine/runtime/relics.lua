local RELIC_DEFS = {
	ashbound_heart = {
		name = "Ashbound Heart",
		desc = "+2 Strength",
		apply = function(p)
			p.stats.strength = p.stats.strength + 2
		end,
	},
	veil_lens = {
		name = "Veil Lens",
		desc = "+2 Perception",
		apply = function(p)
			p.stats.perception = p.stats.perception + 2
		end,
	},
	forgotten_prayer = {
		name = "Forgotten Prayer",
		desc = "Blessings grant +2 instead of +1.",
	},
	blood_sigil = {
		name = "Blood Sigil",
		desc = "First combat victory each floor restores 1 Vitality.",
	},
	wardens_scar = {
		name = "Warden's Scar",
		desc = "Arena Trial rewards grant +1 additional stat.",
	},
}

local AVAILABLE_IDS = {}
for id in pairs(RELIC_DEFS) do
	table.insert(AVAILABLE_IDS, id)
end

local M = {}

function M.def(id)
	return RELIC_DEFS[id]
end

function M.all_defs()
	return RELIC_DEFS
end

function M.grant(player, id)
	if not RELIC_DEFS[id] then
		return false
	end

	if player.relics[id] then
		return false
	end

	player.relics[id] = true

	local def = RELIC_DEFS[id]
	if def.apply then
		def.apply(player)
	end

	return true
end

function M.has(player, id)
	return player.relics[id] == true
end

function M.count(player)
	local n = 0
	for _ in pairs(player.relics or {}) do
		n = n + 1
	end
	return n
end

function M.random_unowned(player)
	local pool = {}

	for _, id in ipairs(AVAILABLE_IDS) do
		if not player.relics[id] then
			table.insert(pool, id)
		end
	end

	if #pool == 0 then
		return nil
	end

	return pool[love.math.random(#pool)]
end

return M
