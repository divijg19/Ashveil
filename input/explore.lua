local M = {}

function M.get_action(key)
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
		escape = "pause",
	}

	return map[key]
end

return M
