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
	compositions,
	anomaly
)
	local silent =
		anomaly
		and (anomaly.type == "silent"
			or anomaly.type == "dead")

	local dead =
		anomaly
		and anomaly.type == "dead"

	-- ====================================
	-- Enemy Placement
	-- ====================================

	if not silent then
		for i = 2, #rooms do
			local room = rooms[i]

			Entities.spawn_enemy(
				game.enemies,
				room
			)
		end
	end

	-- ====================================
	-- Room Interaction Assignment
	-- ====================================

	for i = 2, #rooms do
		local room = rooms[i]

		if room.type == "shrine"
			or room.type == "crypt"
			or room.type == "arena"
			or room.type == "ruin"
		then
			room.interaction = room.type
		end
	end

	-- ====================================
	-- Environmental Composition
	-- ====================================

	local is_echo =
		anomaly
		and anomaly.type == "echo"

	for i = 2, #rooms do
		local room = rooms[i]

		local items = nil

		-- echo anomaly: override some rooms
		if is_echo
			and love.math.random() < 0.35
		then
			items =
				compositions.echo(room)

		elseif room.type == "quiet" then
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
			-- silent/dead: sparse props
			if silent and #items > 0 then
				local keep =
					dead and 0.1 or 0.3

				local filtered = {}

				for _, item
					in ipairs(items)
				do
					if love.math.random()
						< keep
					then
						table.insert(
							filtered,
							item
						)
					end
				end

				items = filtered
			end

			Props.add_many(
				game.props,
				items
			)
		end
	end

	-- ====================================
	-- Echo Anomaly: Additional Echoes
	-- ====================================

	if is_echo then
		for i = 2, #rooms do
			if love.math.random() < 0.15
			then
				local echo =
					compositions.echo_light(
						rooms[i]
					)

				Props.add_many(
					game.props,
					echo
				)
			end
		end
	end
end

return M
