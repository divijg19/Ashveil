local M = {}

local map = {
	w = "up",
	s = "down",
	a = "left",
	d = "right",

	up = "up",
	down = "down",
	left = "left",
	right = "right",

	e = "interact",
	f = "inspect",
	c = "character",
	i = "inventory",
	escape = "pause",
}

function M.get_action(key)
	return map[key]
end

return M
