local M = {}

local function draw_selection_marker(x, y, selected)
	if not selected then
		return
	end

	love.graphics.setColor(
		0.85,
		0.85,
		0.85,
		0.5
	)

	love.graphics.print(
		">",
		x - 16,
		y
	)

	love.graphics.setColor(1, 1, 1, 1)
end

function M.draw(state)
	local ev = state.event
	if not ev then
		return
	end

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	local panel_w = math.min(500, w - 60)
	local px = (w - panel_w) / 2
	local py = h - 260

	-- panel backing
	love.graphics.setColor(
		0,
		0,
		0,
		0.6
	)

	love.graphics.rectangle(
		"fill",
		px,
		py,
		panel_w,
		200
	)

	-- subtle edge
	love.graphics.setColor(
		0.35,
		0.35,
		0.35,
		0.25
	)

	love.graphics.rectangle(
		"line",
		px,
		py,
		panel_w,
		200
	)

	-- event message
	love.graphics.setColor(
		0.85,
		0.85,
		0.85,
		1
	)

	love.graphics.printf(
		ev.message,
		px + 20,
		py + 20,
		panel_w - 40,
		"center"
	)

	-- option list
	local option_start_y = py + 70

	for i, opt in ipairs(ev.options) do
		local y = option_start_y + (i - 1) * 30

		love.graphics.setColor(
			0.75,
			0.75,
			0.75,
			ev.selection == i and 1 or 0.55
		)

		love.graphics.printf(
			opt,
			px + 20,
			y,
			panel_w - 40,
			"center"
		)

		draw_selection_marker(
			px + panel_w / 2,
			y,
			ev.selection == i
		)
	end

	-- controls hint
	love.graphics.setColor(
		0.5,
		0.5,
		0.5,
		0.5
	)

	love.graphics.printf(
		"Up / Down  |  Enter",
		px + 20,
		py + 170,
		panel_w - 40,
		"center"
	)

	love.graphics.setColor(1, 1, 1, 1)
end

return M
