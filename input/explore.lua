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
		right = "right"
	}

	return map[key]
end

return M
