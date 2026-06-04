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

		elseif item.prop.type == "blood_seal" then
			love.graphics.circle(
				"line",

				sx,
				sy,

				12
			)

			love.graphics.circle(
				"line",

				sx,
				sy,

				6
			)

		elseif item.prop.type == "reliquary" then
			love.graphics.rectangle(
				"fill",

				sx - 10,
				sy - 14,

				20,
				20
			)

		elseif item.prop.type == "hidden_passage" then
			love.graphics.rectangle(
				"fill",

				sx - 8,
				sy - 8,

				20,
				20
			)

		elseif item.prop.type == "side_door" then
			love.graphics.rectangle(
				"line",

				sx - 6,
				sy - 14,

				12,
				24
			)

		elseif item.prop.type == "monolith" then
			love.graphics.rectangle(
				"fill",

				sx - 6,
				sy - 30,

				12,
				40
			)

		elseif item.prop.type == "mural" then
			love.graphics.rectangle(
				"fill",

				sx - 18,
				sy - 12,

				36,
				24
			)

		elseif item.prop.type == "veil_echo" then
			love.graphics.circle(
				"line",

				sx,
				sy,

				8
			)

			love.graphics.circle(
				"line",

				sx,
				sy,

				4
			)

		elseif item.prop.type == "fallen_explorer" then
			love.graphics.setColor(0.4, 0.35, 0.3, 0.85)
			-- slumped body
			love.graphics.rectangle(
				"fill",

				sx - 4,
				sy - 10,

				8,
				16
			)
			-- head slumped to side
			love.graphics.rectangle(
				"fill",

				sx - 8,
				sy - 16,

				8,
				8
			)

		elseif item.prop.type == "torn_satchel" then
			love.graphics.setColor(0.5, 0.4, 0.25, 0.8)
			-- tilted rectangle
			love.graphics.polygon(
				"fill",

				sx - 6,
				sy + 2,

				sx + 4,
				sy + 6,

				sx + 8,
				sy - 4,

				sx - 2,
				sy - 8
			)

		elseif item.prop.type == "pilgrim_pack" then
			love.graphics.setColor(0.45, 0.35, 0.25, 0.8)
			-- bundle
			love.graphics.rectangle(
				"fill",

				sx - 5,
				sy - 4,

				10,
				12
			)
			-- staff
			love.graphics.setColor(0.5, 0.4, 0.3, 0.8)
			love.graphics.rectangle(
				"fill",

				sx + 6,
				sy - 18,

				3,
				26
			)

		elseif item.prop.type == "hidden_cache" then
			-- faint floor mark — barely visible
			love.graphics.setColor(0.25, 0.25, 0.22, 0.35)
			love.graphics.rectangle(
				"fill",

				sx - 5,
				sy - 3,

				10,
				6
			)
			love.graphics.setColor(1, 1, 1, 1)
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

	-- game over overlay
	if state.is_game_over then
		local w = love.graphics.getWidth()
		local h = love.graphics.getHeight()
		love.graphics.setColor(0.75, 0.75, 0.75, 0.85)
		love.graphics.printf(
			"You died in the Veil.",
			0,
			h / 2 - 20,
			w,
			"center"
		)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
