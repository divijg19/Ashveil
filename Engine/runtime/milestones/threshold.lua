local M = {}

function M.setup(game, room)
	local cx = room.center.x
	local cy = room.center.y

	-- Cracked Monolith (left side)
	table.insert(game.props, {
		x = cx - 3,
		y = cy,
		type = "monolith",
		poi = {
			state = "active",
			tags = {"curiosity"},
			interaction = {
				action = "Inspect",
			},
			inspect = "The monolith is split down the center. The fracture is older than memory.",
		},
	})

	-- Faded Mural (right side)
	table.insert(game.props, {
		x = cx + 3,
		y = cy,
		type = "mural",
		poi = {
			state = "active",
			tags = {"curiosity"},
			interaction = {
				action = "Inspect",
			},
			inspect = "The mural has been worn smooth. Only the outline of a descending figure remains.",
		},
	})
end

return M
