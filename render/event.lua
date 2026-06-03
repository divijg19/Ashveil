local M = {}

function M.draw(state)
	local ev = state.event
	if not ev then
		return
	end

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	local panel_w = math.min(500, w - 120)
	local px = (w - panel_w) / 2
	local py = math.max(100, (h - 260) / 2)

	-- panel backing
	love.graphics.setColor(0.08, 0.08, 0.08, 0.92)
	love.graphics.rectangle("fill", px, py, panel_w, 220)

	love.graphics.setColor(0.3, 0.3, 0.3, 0.4)
	love.graphics.rectangle("line", px, py, panel_w, 220)

	-- event message
	love.graphics.setColor(0.85, 0.85, 0.85, 1)
	love.graphics.printf(
		ev.message,
		px + 20,
		py + 16,
		panel_w - 40,
		"center"
	)

	-- "Choose:" header
	love.graphics.setColor(0.55, 0.55, 0.55, 0.7)
	love.graphics.printf(
		"Choose:",
		px + 20,
		py + 60,
		panel_w - 40,
		"center"
	)

	-- options
	local option_start_y = py + 85

	for i, opt in ipairs(ev.options) do
		local y = option_start_y + (i - 1) * 30

		if ev.selection == i then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(">", px + 20, y)
			love.graphics.setColor(0.9, 0.9, 0.8, 1)
		else
			love.graphics.setColor(0.65, 0.65, 0.65, 0.7)
		end

		love.graphics.print(opt, px + 36, y)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
