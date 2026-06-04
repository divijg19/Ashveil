local M = {}

local last_key = nil
local last_click = false

local old_keypressed = love.keypressed
function love.keypressed(key, scancode, isrepeat)
	if old_keypressed then
		old_keypressed(key, scancode, isrepeat)
	end
	if isrepeat then
		return
	end
	last_key = key
end

local old_mousepressed = love.mousepressed
function love.mousepressed(x, y, button, istouch)
	if old_mousepressed then
		old_mousepressed(x, y, button, istouch)
	end
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
