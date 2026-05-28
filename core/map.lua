local Archetypes = require("world.archetypes")
local Dungeon = require("Engine.world.dungeon")
local M = {}

local WALL = "#"
local FLOOR = "."

-- ========================================
-- Archetype Selection
-- ========================================

local ROOM_TYPES = {
	-- silence dominates
	"quiet",
	"quiet",
	"quiet",
	"quiet",
	"quiet",
	"quiet",

	-- connective tissue
	"hall",
	"hall",
	"hall",

	-- uncommon
	"ruin",
	"ruin",

	-- rare
	"crypt",

	-- very rare
	"shrine",

	-- very rare
	"arena",
}

local ROOM_TRANSITIONS = {
	quiet = {
		"quiet",
		"quiet",
		"hall",
		"ruin",
	},

	hall = {
		"quiet",
		"quiet",
		"crypt",
		"arena",
		"shrine",
	},

	ruin = {
		"quiet",
		"hall",
		"crypt",
	},

	crypt = {
		"hall",
		"quiet",
	},

	shrine = {
		"hall",
		"quiet",
	},

	arena = {
		"hall",
		"quiet",
	},
}

local function get_room_pool(floor)
	floor = floor or 1

	local pool = {
		"quiet", "quiet", "quiet", "quiet",
		"quiet", "quiet",
		"hall",  "hall",  "hall",
		"ruin",  "ruin",
		"crypt",
		"shrine",
		"arena",
	}

	if floor >= 3 then
		table.insert(pool, "crypt")
	end

	if floor >= 5 then
		table.insert(pool, "shrine")
	end

	if floor >= 7 then
		table.insert(pool, "crypt")
		table.insert(pool, "shrine")
	end

	if floor >= 9 then
		table.insert(pool, "quiet")
		table.insert(pool, "quiet")
	end

	return pool
end

local function get_transition_pool(previous_type, floor)
	floor = floor or 1

	local base = ROOM_TRANSITIONS[previous_type]

	if not base then
		return nil
	end

	local pool = {}

	for _, v in ipairs(base) do
		table.insert(pool, v)
	end

	if previous_type == "hall" then
		if floor >= 3 then
			table.insert(pool, "crypt")
		end

		if floor >= 5 then
			table.insert(pool, "shrine")
		end

		if floor >= 7 then
			table.insert(pool, "crypt")
			table.insert(pool, "shrine")
		end

	elseif previous_type == "quiet" then
		if floor >= 8 then
			table.insert(pool, "quiet")
			table.insert(pool, "quiet")
		end
	end

	return pool
end

local function random_room_type(previous_type, floor)
	floor = floor or 1

	if not previous_type then
		local pool = get_room_pool(floor)

		return pool[
			love.math.random(#pool)
		]
	end

	local pool =
		get_transition_pool(
			previous_type,
			floor
		)

	if not pool then
		pool = get_room_pool(floor)
	end

	return pool[
		love.math.random(#pool)
	]
end

-- ========================================
-- Geometry Rules
-- ========================================

local function generate_room_dimensions(room_type, floor, anomaly)
	floor = floor or 1

	local scale = 1.0

	if anomaly then
		if anomaly.type == "geometry" then
			scale = 1.3
				+ love.math.random()
				* 0.2

		elseif anomaly.type == "dead" then
			scale = 1.2
		end
	end

	-- ====================================
	-- Hall
	-- ====================================

	if room_type == "hall" then
		local len_boost =
			math.min(
				math.floor(floor / 4),
				4
			)

		local min_len = math.floor(
			(14 + len_boost) * scale
		)

		local max_len = math.floor(
			(20 + len_boost) * scale
		)

		if love.math.random() < 0.5 then
			return
				love.math.random(
					min_len,
					max_len
				),
				love.math.random(4, 5)
		else
			return
				love.math.random(4, 5),
				love.math.random(
					min_len,
					max_len
				)
		end

	-- ====================================
	-- Arena
	-- ====================================

	elseif room_type == "arena" then
		local boost =
			math.min(
				math.floor(floor / 6),
				2
			)

		local sz = math.floor(
			(12 + boost) * scale
		)

		local max_sz = math.floor(
			(16 + boost) * scale
		)

		return
			love.math.random(
				sz,
				max_sz
			),
			love.math.random(
				sz,
				max_sz
			)

	-- ====================================
	-- Crypt
	-- ====================================

	elseif room_type == "crypt" then
		local boost =
			math.min(
				math.floor(floor / 5),
				1
			)

		local min_sz = math.floor(
			(5 + boost) * scale
		)

		local max_sz = math.floor(
			(7 + boost) * scale
		)

		return
			love.math.random(
				min_sz,
				max_sz
			),
			love.math.random(
				min_sz,
				max_sz
			)

	-- ====================================
	-- Shrine
	-- ====================================

	elseif room_type == "shrine" then
		local boost =
			math.min(
				math.floor(floor / 5),
				2
			)

		local min_sz = math.floor(
			(9 + boost) * scale
		)

		local max_sz = math.floor(
			(11 + boost) * scale
		)

		return
			love.math.random(
				min_sz,
				max_sz
			),
			love.math.random(
				min_sz,
				max_sz
			)

	-- ====================================
	-- Ruin
	-- ====================================

	elseif room_type == "ruin" then
		local boost =
			math.min(
				math.floor(floor / 4),
				3
			)

		local min_sz = math.floor(
			(7 + boost) * scale
		)

		local max_sz = math.floor(
			(14 + boost) * scale
		)

		return
			love.math.random(
				min_sz,
				max_sz
			),
			love.math.random(
				min_sz,
				max_sz
			)
	end

	-- ====================================
	-- Quiet
	-- ====================================

	local boost =
		math.min(
			math.floor(floor / 3),
			3
		)

	local min_sz = math.floor(
		(6 + boost) * scale
	)

	local max_sz = math.floor(
		(10 + boost) * scale
	)

	return
		love.math.random(min_sz, max_sz),
		love.math.random(min_sz, max_sz)
end

-- ========================================
-- Dungeon Generation
-- ========================================

function M.create(width, height, floor, anomaly)
	floor = floor or 1

	local map = {}

	-- fill walls
	for y = 1, height do
		map[y] = {}

		for x = 1, width do
			map[y][x] = WALL
		end
	end

	local rooms = {}
	local previous_type = nil

	local ROOM_COUNT = 14

	for _ = 1, ROOM_COUNT do
		local room_type =
			random_room_type(
				previous_type,
				floor
			)

		local rw, rh =
			generate_room_dimensions(
				room_type,
				floor,
				anomaly
			)

		-- geometry anomaly: duplicate room structure
		if anomaly
			and anomaly.type == "geometry"
			and #rooms > 0
			and love.math.random() < 0.3
		then
			local prev =
				rooms[#rooms]

			rw, rh = prev.w, prev.h
			room_type = prev.type
		end

		local rx =
			love.math.random(
				2,
				width - rw - 1
			)

		local ry =
			love.math.random(
				2,
				height - rh - 1
			)

		local room =
			Dungeon.new_room(
				rx,
				ry,
				rw,
				rh
			)

		room.type = room_type

		-- overlap rejection
		local failed = false

		for _, other in ipairs(rooms) do
			if Dungeon.rooms_overlap(
				room,
				other
			) then
				failed = true
				break
			end
		end

		if not failed then
			Dungeon.carve_room(map, room)

			room.props = {}

			room.archetype = Archetypes[room_type]

			local landmark_chance =
				math.min(
					0.05 + floor * 0.015,
					0.30
				)

			room.landmark =
				love.math.random()
				< landmark_chance

			table.insert(rooms, room)
			previous_type = room_type

			-- connect to previous room
			if #rooms > 1 then
				local prev = rooms[#rooms - 1]

				Dungeon.carve_h_corridor(map, prev.center.x, room.center.x, prev.center.y)

				Dungeon.carve_v_corridor(map, prev.center.y, room.center.y, room.center.x)
			end
		end
	end

	local last_room =
		rooms[#rooms]

	local exit = {
		x = last_room.center.x,
		y = last_room.center.y,
	}

	return map, rooms, exit
end

return M
