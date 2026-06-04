local Queue =
	require("Engine.render.queue")

local Iso =
	require("Engine.render.isometric")

local M = {}

local PROP_RENDERERS = {
	pillar = function(sx, sy)
		love.graphics.rectangle("fill", sx - 6, sy - 18, 12, 24)
	end,
	altar = function(sx, sy)
		love.graphics.rectangle("fill", sx - 10, sy - 10, 20, 20)
	end,
	sarcophagus = function(sx, sy)
		love.graphics.rectangle("fill", sx - 8, sy - 14, 16, 28)
	end,
	rubble = function(sx, sy)
		love.graphics.rectangle("fill", sx - 10, sy - 6, 20, 12)
	end,
	obelisk = function(sx, sy)
		love.graphics.rectangle("fill", sx - 4, sy - 24, 8, 32)
	end,
	seal = function(sx, sy)
		love.graphics.circle("line", sx, sy, 10)
	end,
	remains = function(sx, sy)
		love.graphics.rectangle("fill", sx - 6, sy - 4, 12, 8)
	end,
	brazier = function(sx, sy)
		love.graphics.rectangle("fill", sx - 4, sy - 12, 8, 12)
	end,
	statue = function(sx, sy)
		love.graphics.rectangle("fill", sx - 8, sy - 24, 16, 36)
	end,
	broken_column = function(sx, sy)
		love.graphics.rectangle("fill", sx - 8, sy - 10, 16, 12)
	end,
	tomb = function(sx, sy)
		love.graphics.rectangle("fill", sx - 12, sy - 16, 24, 32)
	end,
	glyph = function(sx, sy)
		love.graphics.circle("fill", sx, sy, 4)
	end,
	blood_seal = function(sx, sy)
		love.graphics.circle("line", sx, sy, 12)
		love.graphics.circle("line", sx, sy, 6)
	end,
	reliquary = function(sx, sy)
		love.graphics.rectangle("fill", sx - 10, sy - 14, 20, 20)
	end,
	hidden_passage = function(sx, sy)
		love.graphics.rectangle("fill", sx - 8, sy - 8, 20, 20)
	end,
	side_door = function(sx, sy)
		love.graphics.rectangle("line", sx - 6, sy - 14, 12, 24)
	end,
	monolith = function(sx, sy)
		love.graphics.rectangle("fill", sx - 6, sy - 30, 12, 40)
	end,
	mural = function(sx, sy)
		love.graphics.rectangle("fill", sx - 18, sy - 12, 36, 24)
	end,
	veil_echo = function(sx, sy)
		love.graphics.circle("line", sx, sy, 8)
		love.graphics.circle("line", sx, sy, 4)
	end,
	fallen_explorer = function(sx, sy, prop)
		if prop.state == "resolved" then
			love.graphics.setColor(0.3, 0.28, 0.25, 0.5)
			love.graphics.rectangle("line", sx - 6, sy - 12, 12, 18)
		else
			love.graphics.setColor(0.4, 0.35, 0.3, 0.85)
			love.graphics.rectangle("fill", sx - 4, sy - 10, 8, 16)
			love.graphics.rectangle("fill", sx - 8, sy - 16, 8, 8)
		end
	end,
	torn_satchel = function(sx, sy, prop)
		if prop.state == "resolved" then
			love.graphics.setColor(0.4, 0.35, 0.25, 0.4)
			love.graphics.rectangle("line", sx - 5, sy - 4, 10, 8)
		else
			love.graphics.setColor(0.5, 0.4, 0.25, 0.8)
			love.graphics.polygon("fill", sx - 6, sy + 2, sx + 4, sy + 6, sx + 8, sy - 4, sx - 2, sy - 8)
		end
	end,
	pilgrim_pack = function(sx, sy, prop)
		if prop.state == "resolved" then
			love.graphics.setColor(0.35, 0.28, 0.2, 0.4)
			love.graphics.rectangle("line", sx - 5, sy - 2, 10, 8)
		else
			love.graphics.setColor(0.45, 0.35, 0.25, 0.8)
			love.graphics.rectangle("fill", sx - 5, sy - 4, 10, 12)
			love.graphics.setColor(0.5, 0.4, 0.3, 0.8)
			love.graphics.rectangle("fill", sx + 6, sy - 18, 3, 26)
		end
	end,
	forgotten_shrine = function(sx, sy, prop)
		if prop.state == "resolved" then
			love.graphics.setColor(0.3, 0.28, 0.25, 0.45)
			love.graphics.rectangle("line", sx - 6, sy - 8, 12, 12)
		else
			love.graphics.setColor(0.4, 0.35, 0.3, 0.8)
			love.graphics.rectangle("fill", sx - 6, sy - 10, 12, 14)
			love.graphics.setColor(0.5, 0.4, 0.3, 0.85)
			love.graphics.rectangle("fill", sx - 2, sy - 14, 4, 6)
		end
	end,
	hidden_cache = function(sx, sy, prop)
		if prop.state == "resolved" then
			love.graphics.setColor(0.2, 0.2, 0.18, 0.3)
			love.graphics.line(sx - 4, sy - 2, sx, sy + 2, sx + 4, sy - 1)
			love.graphics.line(sx - 2, sy + 1, sx + 1, sy + 4)
		else
			love.graphics.setColor(0.25, 0.25, 0.22, 0.35)
			love.graphics.rectangle("fill", sx - 5, sy - 3, 10, 6)
		end
	end,
}

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

			local render_fn =
				PROP_RENDERERS[
					item.prop.type
				]
			if render_fn then
				render_fn(
					sx,
					sy,
					item.prop
				)
			end

			love.graphics.setColor(
				1, 1, 1, 1
			)

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

	-- anomaly visual overlays
	if state.anomaly then
		local w = love.graphics.getWidth()
		local h = love.graphics.getHeight()

		if state.anomaly.type == "silent" then
			local vw = 30
			love.graphics.setColor(0.1, 0.1, 0.15, 0.5)
			love.graphics.rectangle("fill", 0, 0, w, vw)
			love.graphics.rectangle("fill", 0, h - vw, w, vw)
			love.graphics.rectangle("fill", 0, 0, vw, h)
			love.graphics.rectangle("fill", w - vw, 0, vw, h)

		elseif state.anomaly.type == "dead" then
			love.graphics.setColor(0.25, 0.25, 0.25, 0.15)
			love.graphics.rectangle("fill", 0, 0, w, h)

		elseif state.anomaly.type == "echo" then
			love.graphics.setColor(0.6, 0.55, 0.8, 0.08)
			love.graphics.rectangle("fill", 0, 0, w, 120)
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
