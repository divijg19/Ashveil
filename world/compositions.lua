local M = {}

-- ========================================
-- Helpers
-- ========================================

local function add(props, x, y, t)
	table.insert(props, {
		x = x,
		y = y,

		type = t,
	})
end

-- ========================================
-- Shrine
-- ========================================

function M.shrine(room)
	local props = {}

	local cx = room.center.x
	local cy = room.center.y

	-- central altar
	add(props, cx, cy, "altar")

	-- ritual seal
	add(props, cx, cy + 2, "seal")

	-- pillar ring
	local positions = {
		{cx - 2, cy - 2},
		{cx + 2, cy - 2},
		{cx - 2, cy + 2},
		{cx + 2, cy + 2},
	}

	-- landmark expansion
	if room.landmark then
		positions = {
			{cx - 4, cy - 4},
			{cx + 4, cy - 4},
			{cx - 4, cy + 4},
			{cx + 4, cy + 4},

			{cx - 2, cy},
			{cx + 2, cy},

			{cx, cy - 2},
			{cx, cy + 2},
		}
	end

	for _, pos in ipairs(positions) do
		add(
			props,
			pos[1],
			pos[2],
			"pillar"
		)
	end

	return props
end

-- ========================================
-- Crypt
-- ========================================

function M.crypt(room)
	local props = {}

	local start_x = room.x + 1
	local end_x = room.x + room.w - 2

	local start_y = room.y + 1
	local end_y = room.y + room.h - 2

	for y = start_y, end_y, 3 do
		for x = start_x, end_x, 3 do
			local t = "sarcophagus"

			if love.math.random() < 0.25 then
				t = "remains"
			end

			add(props, x, y, t)
		end
	end

	-- landmark burial hall
	if room.landmark then
		add(
			props,
			room.center.x,
			room.center.y,
			"tomb"
		)
	end

	return props
end

-- ========================================
-- Arena
-- ========================================

function M.arena(room)
	local props = {}

	local cx = room.center.x
	local cy = room.center.y

	-- central seal
	add(props, cx, cy, "seal")

	-- surrounding obelisks
	local positions = {
		{cx - 4, cy},
		{cx + 4, cy},
		{cx, cy - 4},
		{cx, cy + 4},
	}

	if room.landmark then
		positions = {
			{cx - 6, cy},
			{cx + 6, cy},
			{cx, cy - 6},
			{cx, cy + 6},

			{cx - 4, cy - 4},
			{cx + 4, cy - 4},

			{cx - 4, cy + 4},
			{cx + 4, cy + 4},
		}
	end

	for _, pos in ipairs(positions) do
		add(
			props,
			pos[1],
			pos[2],
			"obelisk"
		)
	end

	return props
end

-- ========================================
-- Ruin
-- ========================================

function M.ruin(room)
	local props = {}

	local count =
		love.math.random(5, 10)

	for _ = 1, count do
		local px =
			love.math.random(
				room.x + 1,
				room.x + room.w - 2
			)

		local py =
			love.math.random(
				room.y + 1,
				room.y + room.h - 2
			)

		local t = "rubble"

		if love.math.random() < 0.4 then
			t = "broken_column"
		end

		add(props, px, py, t)
	end

	-- fragmented remains
	if room.landmark then
		add(
			props,
			room.center.x,
			room.center.y,
			"statue"
		)
	end

	return props
end

-- ========================================
-- Quiet
-- ========================================

function M.quiet(room, floor)
	floor = floor or 1

	local props = {}

	-- glyphs on deeper floors
	if floor >= 3 then
		local count =
			math.min(
				math.floor(floor / 3),
				4
			)

		for _ = 1, count do
			local px =
				love.math.random(
					room.x + 1,
					room.x + room.w - 2
				)

			local py =
				love.math.random(
					room.y + 1,
					room.y + room.h - 2
				)

			add(props, px, py, "glyph")
		end
	end

	-- occasional seal on deeper floors
	if floor >= 6
		and love.math.random() < 0.25
	then
		add(
			props,
			room.center.x,
			room.center.y,
			"seal"
		)
	end

	return props
end

-- ========================================
-- Hall
-- ========================================

function M.hall(room)
	local props = {}

	local horizontal =
		room.w > room.h

	if horizontal then
		for x = room.x + 3,
			room.x + room.w - 3,
			5
		do
			add(
				props,
				x,
				room.center.y,
				"brazier"
			)
		end
	else
		for y = room.y + 3,
			room.y + room.h - 3,
			5
		do
			add(
				props,
				room.center.x,
				y,
				"brazier"
			)
		end
	end

	return props
end

return M
