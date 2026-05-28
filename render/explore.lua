local Queue =
	require("Engine.render.queue")

local Iso =
	require("Engine.render.isometric")

local M = {}

local function get_screen_center()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	-- slightly below center feels better
	return w / 2, h / 3
end

-- ========================================
-- Helpers
-- ========================================

local function world_to_camera(state, x, y)
	local sx, sy =
		Iso.to_screen(x, y)

	local cam_sx, cam_sy =
		Iso.to_screen(
			state.camera.x,
			state.camera.y
		)

	local cx, cy = get_screen_center()

	return
		sx - cam_sx + cx,
		sy - cam_sy + cy
end

local function draw_floor(state, x, y)
	local sx, sy = world_to_camera(state, x, y)

	love.graphics.polygon(
		"line",
		sx, sy,
		sx + Iso.TILE_WIDTH / 2, sy + Iso.TILE_HEIGHT / 2,
		sx, sy + Iso.TILE_HEIGHT,
		sx - Iso.TILE_WIDTH / 2, sy + Iso.TILE_HEIGHT / 2
	)
end

local function draw_wall(state, x, y)
	local sx, sy = world_to_camera(state, x, y)

	love.graphics.polygon(
		"fill",
		sx, sy,
		sx + Iso.TILE_WIDTH / 2, sy + Iso.TILE_HEIGHT / 2,
		sx, sy + Iso.TILE_HEIGHT,
		sx - Iso.TILE_WIDTH / 2, sy + Iso.TILE_HEIGHT / 2
	)
end

-- ========================================
-- Main Draw
-- ========================================

function M.draw(state)
	-- ensure full color for world
	love.graphics.setColor(1, 1, 1, 1)

	-- update camera
	state.camera:center_on(
		state.player.x,
		state.player.y
	)

	local queue = Queue.build(state)

	-- depth sort
	table.sort(queue, function(a, b)
		return a.depth < b.depth
	end)

	-- render
	for _, item in ipairs(queue) do
		if item.type == "floor" then
			draw_floor(state, item.x, item.y)

		elseif item.type == "wall" then
			draw_wall(state, item.x, item.y)

		elseif item.type == "prop" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

		if item.prop.type == "pillar" then
			love.graphics.rectangle(
				"fill",

				sx - 6,
				sy - 18,

				12,
				24
			)

		elseif item.prop.type == "altar" then
			love.graphics.rectangle(
				"fill",

				sx - 10,
				sy - 10,

				20,
				20
			)

		elseif item.prop.type == "sarcophagus" then
			love.graphics.rectangle(
				"fill",

				sx - 8,
				sy - 14,

				16,
				28
			)

		elseif item.prop.type == "rubble" then
			love.graphics.rectangle(
				"fill",

				sx - 10,
				sy - 6,

				20,
				12
			)

		elseif item.prop.type == "obelisk" then
			love.graphics.rectangle(
				"fill",

				sx - 4,
				sy - 24,

				8,
				32
			)

		elseif item.prop.type == "seal" then
			love.graphics.circle(
				"line",

				sx,
				sy,

				10
			)

		elseif item.prop.type == "remains" then
			love.graphics.rectangle(
				"fill",

				sx - 6,
				sy - 4,

				12,
				8
			)

		elseif item.prop.type == "brazier" then
			love.graphics.rectangle(
				"fill",

				sx - 4,
				sy - 12,

				8,
				12
			)

		elseif item.prop.type == "statue" then
			love.graphics.rectangle(
				"fill",

				sx - 8,
				sy - 24,

				16,
				36
			)

		elseif item.prop.type == "broken_column" then
			love.graphics.rectangle(
				"fill",

				sx - 8,
				sy - 10,

				16,
				12
			)

		elseif item.prop.type == "tomb" then
			love.graphics.rectangle(
				"fill",

				sx - 12,
				sy - 16,

				24,
				32
			)

		elseif item.prop.type == "glyph" then
			love.graphics.circle(
				"fill",

				sx,
				sy,

				4
			)
		end

		elseif item.type == "exit" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

			love.graphics.circle(
				"line",
				sx,
				sy,
				14
			)

			love.graphics.print(
				">",
				sx - 4,
				sy - 8
			)

		elseif item.type == "enemy" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

			love.graphics.print(
				"E",
				sx - 4,
				sy
			)

		elseif item.type == "player" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

			love.graphics.print(
				"@",
				sx - 4,
				sy
			)
		end
	end

	-- ========================================
	-- HUD
	-- ========================================

	M.draw_hud(state)
end

local function get_hud_alpha(state)
	local anomaly = state.anomaly

	if not anomaly then
		return 0.85
	end

	if anomaly.type == "silent"
		or anomaly.type == "dead"
	then
		return 0.7
	end

	return 0.85
end

function M.draw_hud(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	local alpha =
		get_hud_alpha(state)

	-- panel background (subtle)
	love.graphics.setColor(
		0,
		0,
		0,
		0.5
	)

	love.graphics.rectangle(
		"fill",
		10,
		10,
		130,
		40
	)

	-- subtle edge separation
	love.graphics.setColor(
		0.35,
		0.35,
		0.35,
		0.25
	)

	love.graphics.rectangle(
		"line",
		10,
		10,
		130,
		40
	)

	-- floor label
	love.graphics.setColor(
		0.85,
		0.85,
		0.85,
		alpha
	)

	love.graphics.print(
		"Floor " .. state.floor,
		18,
		14
	)

	-- vitality label
	love.graphics.print(
		"Vitality "
			.. state.player.hp,
		18,
		28
	)

	-- game over
	if state.is_game_over then
		love.graphics.setColor(
			0.75,
			0.75,
			0.75,
			0.85
		)

		love.graphics.printf(
			"You died in the Veil",
			0,
			h / 2 - 20,
			w,
			"center"
		)
	end

	-- restore full color for subsequent frames
	love.graphics.setColor(1, 1, 1, 1)
end

return M
