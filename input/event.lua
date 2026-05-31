local M = {}

function M.get_action(key)
	local map = {
		up = "up",
		down = "down",
		w = "up",
		s = "down",
		["return"] = "confirm",
		space = "confirm",
	}

	return map[key]
end

return M
