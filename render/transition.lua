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

	local data = t.data

	if data and data.descent then
		local ox =
			data.offset_x or 0

		love.graphics.printf(
			"~ Floor "
				.. (data.next_floor or "?")
				.. " ~",
			ox,
			h / 2 - 30,
			w,
			"center"
		)

		love.graphics.printf(
			data.msg or "",
			ox,
			h / 2 + 10,
			w,
			"center"
		)
	else
		love.graphics.printf(
			"A VEIL STIRS...",
			0,
			h / 2,
			w,
			"center"
		)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
