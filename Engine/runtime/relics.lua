local RELIC_DEFS = {
	ashbound_heart = {
		name = "Ashbound Heart",
		desc = "+2 Strength",
		artifact = "A heart petrified by ancient fire. Warm to the touch.",
		symbol = "\226\x96\xB3",
		apply = function(p)
			p.stats.strength = p.stats.strength + 2
		end,
	},
	veil_lens = {
		name = "Veil Lens",
		desc = "+2 Perception",
		artifact = "A shard of crystallized darkness. It reflects nothing.",
		symbol = "\226\x97\x8B",
		apply = function(p)
			p.stats.perception = p.stats.perception + 2
		end,
	},
	forgotten_prayer = {
		name = "Forgotten Prayer",
		desc = "Blessings grant +2 instead of +1.",
		artifact = "The final verse is missing.",
		symbol = "\226\x96\xA1",
		apply = function(p)
			p.blessing_doubled = true
		end,
	},
	blood_sigil = {
		name = "Blood Sigil",
		desc = "First combat victory each floor restores 1 Vitality.",
		artifact = "The sigil pulses when blood is near.",
		symbol = "\226\x97\x87",
		apply = function(p) end,
	},
	wardens_scar = {
		name = "Warden's Scar",
		desc = "Arena Trial rewards grant +1 additional stat.",
		artifact = "The wound never fully healed. It reminds you.",
		symbol = "\226\xAC\xA1",
		apply = function(p) end,
	},
}

local AVAILABLE_IDS = {}
for id in pairs(RELIC_DEFS) do
	table.insert(AVAILABLE_IDS, id)
end

local MessagePanel = require("Engine.runtime.message_panel")

local M = {}

local GRANT_HOOKS = {}

function M.register_grant_hook(fn)
	table.insert(GRANT_HOOKS, fn)
end

function M.def(id)
	return RELIC_DEFS[id]
end

function M.grant(player, id)
	if not RELIC_DEFS[id] then
		return false
	end

	if player.relics[id] then
		return false
	end

	local def = RELIC_DEFS[id]
	if def.apply then
		def.apply(player)
	end

	for _, hook in ipairs(GRANT_HOOKS) do
		hook(player, id)
	end

	player.relics[id] = true

	MessagePanel.push_passive(
		"New Relic: " .. (def and def.name or id)
	)

	return true
end

function M.has(player, id)
	if not player or not player.relics then
		return false
	end
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
	if not player or not player.relics then
		return nil
	end

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
