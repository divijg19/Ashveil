local M = {}

local map = {
	up = "up",
	down = "down",
	w = "up",
	s = "down",
	["return"] = "confirm",
	space = "confirm",
	escape = "cancel",
}

function M.get_action(key)
	return map[key]
end

return M
