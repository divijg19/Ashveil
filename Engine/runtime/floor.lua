local Environment =
	require(
		"Engine.runtime.environment"
	)

local M = {}

function M.next(
	game,
	Map,
	Compositions
)
	-- ================================
	-- Advance Floor
	-- ================================

	game.floor =
		game.floor + 1

	-- ================================
	-- Regenerate Dungeon
	-- ================================

	local map,
		rooms,
		exit =
			Map.create(
				80,
				80,
				game.floor
			)

	game.map = map
	game.rooms = rooms
	game.exit = exit

	-- ================================
	-- Reset Runtime Collections
	-- ================================

	game.enemies = {}
	game.props = {}

	-- ================================
	-- Repopulate Environment
	-- ================================

	Environment.populate(
		game,
		rooms,
		Compositions
	)

	-- ================================
	-- Respawn Player
	-- ================================

	local spawn =
		rooms[1].center

	game.player.x =
		spawn.x

	game.player.y =
		spawn.y

	-- ================================
	-- Descent Messaging
	-- ================================

	game.log =
		"You descend deeper..."
end

return M
