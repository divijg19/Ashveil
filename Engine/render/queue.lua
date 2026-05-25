local M = {}

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
		table.insert(queue, {
			type = "prop",

			x = p.x,
			y = p.y,

			prop = p,

			depth =
				p.x + p.y + 0.25
		})
	end

	-- enemies
	for _, e in ipairs(state.enemies or {}) do
		table.insert(queue, {
			type = "enemy",

			x = e.x,
			y = e.y,

			depth =
				e.x + e.y + 0.5
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
			+ 0.5
	})

	table.sort(queue, function(a, b)
		return a.depth < b.depth
	end)

	return queue
end

return M
