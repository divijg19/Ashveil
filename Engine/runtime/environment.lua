local Entities =
	require(
		"Engine.runtime.entities"
	)

local Props =
	require(
		"Engine.runtime.props"
	)

local M = {}

function M.populate(
	game,
	rooms,
	compositions
)
	-- ====================================
	-- Enemy Placement
	-- ====================================

	for i = 2, #rooms do
		local room = rooms[i]

		Entities.spawn_enemy(
			game.enemies,
			room
		)
	end

	-- ====================================
	-- Environmental Composition
	-- ====================================

	for i = 2, #rooms do
		local room = rooms[i]

		local items = nil

		if room.type == "quiet" then
			items =
				compositions.quiet(
					room,
					game.floor
				)

		elseif room.type == "shrine" then
			items =
				compositions.shrine(
					room
				)

		elseif room.type == "crypt" then
			items =
				compositions.crypt(
					room
				)

		elseif room.type == "arena" then
			items =
				compositions.arena(
					room
				)

		elseif room.type == "ruin" then
			items =
				compositions.ruin(
					room
				)

		elseif room.type == "hall" then
			items =
				compositions.hall(
					room
				)
		end

		if items then
			Props.add_many(
				game.props,
				items
			)
		end
	end
end

return M
