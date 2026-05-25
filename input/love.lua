local M = {}

local last_key = nil

function love.keypressed(key)
	last_key = key
end

function M.get_key()
	local key = last_key
	last_key = nil
	return key
end

return M
