local M = {}

local last_key = nil
local last_click = false

function love.keypressed(key)
	last_key = key
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		last_click = true
	end
end

function M.get_key()
	local key = last_key
	last_key = nil
	return key
end

function M.was_clicked()
	local c = last_click
	last_click = false
	return c
end

return M
