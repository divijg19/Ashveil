local M = {}

local map = {
	c = "close",
	escape = "close",
	up = "up",
	down = "down",
	["return"] = "confirm",
}

function M.get_action(key)
	return map[key]
end

return M
