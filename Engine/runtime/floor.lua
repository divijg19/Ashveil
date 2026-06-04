local Environment =
	require(
		"Engine.runtime.environment"
	)

local Regions =
	require(
		"Engine.runtime.regions"
	)

local MessagePanel =
	require(
		"Engine.runtime.message_panel"
	)

local Reward =
	require(
		"Engine.runtime.rewards"
	)

local M = {}

function M.next(
	game,
	Map,
	Compositions,
	anomaly
)
	-- ================================
	-- Advance Floor
	-- ================================

	local prev_floor = game.floor

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
				game.floor,
				anomaly,
				game.echo_memories
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
		Compositions,
		anomaly
	)

	-- ================================
	-- Respawn Player
	-- ================================

	local spawn_room =
		rooms[1]

	if not spawn_room then
		game.current_region = Regions.for_floor(game.floor)
		return
	end

	game.player.x =
		spawn_room.center.x

	game.player.y =
		spawn_room.center.y

	-- ================================
	-- Descent Messaging
	-- ================================

	game.log = ""
	game.player.buff_doubled = nil
	game.player.floor_heal_used = false

	-- ================================
	-- Region Transition
	-- ================================

	local new_region =
		Regions.entered(
			prev_floor,
			game.floor
		)

	if new_region
		and not game.seen_regions[
			new_region.floor
		]
	then
		game.seen_regions[
			new_region.floor
		] = true

		MessagePanel.push(
			new_region.desc
		)

		if new_region.milestone then
			local shards = new_region.floor <= 10 and 2 or 1
			Reward.veil_shards(game.player, shards)
			MessagePanel.push_passive(
				"Veil Shards resonate as you cross into the "
					.. new_region.name
					.. "."
			)
		end
	end

	game.current_region = new_region
		or Regions.for_floor(
			game.floor
		)
end

return M
