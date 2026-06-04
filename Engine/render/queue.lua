local M = {}

local FIND_TYPES = {
	fallen_explorer = true,
	torn_satchel = true,
	pilgrim_pack = true,
	hidden_cache = true,
	forgotten_shrine = true,
}

local DEPTH_OFFSET = {
	decoration = 0.10,
	resolved   = 0.15,
	prop       = 0.20,
	find       = 0.25,
	poi        = 0.30,
	stairs     = 0.40,
	enemy      = 0.50,
	player     = 0.60,
}

function M.build(state)
	local queue = {}

	-- map
	for y, row in ipairs(state.map) do
		for x, tile in ipairs(row) do
			table.insert(queue, {
				type =
					tile == "#"
					and "wall"
					or "floor",

				x = x,
				y = y,

				depth = x + y
			})
		end
	end

	-- props
	for _, p in ipairs(state.props or {}) do
		local kind

		if p.state == "resolved" then
			kind = "resolved"
		elseif p.poi then
			kind = FIND_TYPES[p.type] and "find" or "poi"
		else
			kind = "prop"
		end

		table.insert(queue, {
			type = "prop",

			x = p.x,
			y = p.y,

			prop = p,

			depth =
				p.x + p.y
				+ DEPTH_OFFSET[kind]
		})
	end

	-- exit
	table.insert(queue, {
		type = "exit",
		x = state.exit.x,
		y = state.exit.y,
		depth =
			state.exit.x +
			state.exit.y +
			DEPTH_OFFSET.stairs
	})

	-- enemies
	for _, e in ipairs(state.enemies or {}) do
		table.insert(queue, {
			type = "enemy",

			x = e.x,
			y = e.y,

			depth =
				e.x + e.y + DEPTH_OFFSET.enemy
		})
	end

	-- player
	table.insert(queue, {
		type = "player",

		x = state.player.x,
		y = state.player.y,

		depth =
			state.player.x
			+ state.player.y
			+ DEPTH_OFFSET.player
	})

	return queue
end

return M
