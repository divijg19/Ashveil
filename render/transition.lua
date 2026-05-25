local M = {}

function M.draw(state)
	local t = state.transition

	if not t then
		return
	end

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	local alpha = t.alpha or 0

	love.graphics.setColor(0, 0, 0, alpha)

	love.graphics.rectangle(
		"fill",
		0,
		0,
		w,
		h
	)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.print(
		"A VEIL STIRS...",
		w / 2 - 60,
		h / 2
	)
end

return M
