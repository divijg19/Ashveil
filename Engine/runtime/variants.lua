local M = {}

local VARIANTS = {
	veteran_brute = {
		base = "brute",
		name = "Veteran Brute",
		hp_mod = 2,
		tendency = "recover",
	},
	silent_stalker = {
		base = "stalker",
		name = "Silent Stalker",
		hp_mod = 1,
		tendency = "heavy",
	},
	elder_watcher = {
		base = "watcher",
		name = "Elder Watcher",
		hp_mod = 2,
		tendency = "recover",
	},
	zealot_fanatic = {
		base = "fanatic",
		name = "Zealot Fanatic",
		hp_mod = 1,
		tendency = "heavy_wounded",
	},
}

function M.def(variant_id)
	return VARIANTS[variant_id]
end

function M.roll_variant(floor)
	if floor < 5 then
		return nil
	end

	local chance
	if floor <= 9 then
		chance = 0.10
	elseif floor <= 14 then
		chance = 0.25
	else
		chance = 0.40
	end

	if love.math.random() < chance then
		local ids = {}
		for id in pairs(VARIANTS) do
			table.insert(ids, id)
		end
		return ids[love.math.random(#ids)]
	end

	return nil
end

return M
