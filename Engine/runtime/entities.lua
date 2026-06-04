local ARCHETYPES = {
	brute = {
		hp = 5,
		intent_weights = { attack = 2, heavy_attack = 4, defend = 1, recover = 1 },
	},
	stalker = {
		hp = 3,
		intent_weights = { attack = 4, heavy_attack = 2, defend = 1, recover = 1 },
	},
	watcher = {
		hp = 4,
		intent_weights = { attack = 1, heavy_attack = 1, defend = 3, recover = 3 },
	},
	fanatic = {
		hp = 4,
		intent_weights = { attack = 3, heavy_attack = 3, defend = 1, recover = 1 },
	},
	sentinel = {
		hp = 6,
		intent_weights = { attack = 1, heavy_attack = 1, defend = 1, recover = 1 },
	},
}

local ARCHETYPE_NAMES
do
	local names = {}
	for k in pairs(ARCHETYPES) do
		table.insert(names, k)
	end
	ARCHETYPE_NAMES = names
end

local M = {}

function M.random_archetype()
	return ARCHETYPE_NAMES[love.math.random(#ARCHETYPE_NAMES)]
end

function M.archetype_def(name)
	return ARCHETYPES[name]
end

function M.spawn_enemy(enemies, room, archetype)
	archetype = archetype or M.random_archetype()
	local def = ARCHETYPES[archetype] or ARCHETYPES.brute
	local hp = def.hp

	table.insert(enemies, {
		x = room.center.x,
		y = room.center.y,

		archetype = archetype,
		display_name = archetype:gsub("^%l", string.upper),
		hp = hp,
		max_hp = hp,
	})
end

function M.get_at(entities, x, y)
	for _, e in ipairs(entities) do
		if e.x == x
			and e.y == y
		then
			return e
		end
	end

	return nil
end

return M
