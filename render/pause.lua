local M = {}

function M.draw(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local pw = 260
	local ph = 120
	local px = (w - pw) / 2
	local py = (h - ph) / 2

	love.graphics.setColor(0.12, 0.12, 0.12, 1)
	love.graphics.rectangle("fill", px, py, pw, ph)

	love.graphics.setColor(0.35, 0.35, 0.35, 0.5)
	love.graphics.rectangle("line", px, py, pw, ph)

	love.graphics.setColor(0.85, 0.85, 0.85, 1)
	love.graphics.printf("PAUSED", px, py + 14, pw, "center")

	love.graphics.setColor(0.65, 0.65, 0.65, 1)
	love.graphics.printf("[ESC]  Resume", px, py + 46, pw, "center")
	love.graphics.printf("[Q]  Quit", px, py + 70, pw, "center")

	love.graphics.setColor(1, 1, 1, 1)
end

return M
