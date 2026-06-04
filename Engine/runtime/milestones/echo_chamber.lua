local MessagePanel = require("Engine.runtime.message_panel")

local M = {}

function M.setup(game, room)
	local cx = room.center.x
	local cy = room.center.y

	-- Spawn Echo Chamber Sentinel at room center
	local sentinel = {
		x = cx,
		y = cy,
		archetype = "sentinel",
		hp = 6,
		max_hp = 6,
		display_name = "Echo Chamber Sentinel",
	}

	table.insert(game.enemies, sentinel)

	-- Veil Echo inspection prop
	table.insert(game.props, {
		x = cx - 3,
		y = cy + 2,
		type = "veil_echo",
		poi = {
			state = "active",
			tags = {"curiosity"},
			interaction = {
				action = "Inspect",
			},
			inspect = "The Veil shudders when you speak. This place remembers.",
		},
	})
end

return M
