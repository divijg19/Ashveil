local M = {}

function M.get_action(key)
	local map = {
		c = "character",
		escape = "close",
		up = "up",
		down = "down",
		["return"] = "confirm",
	}

	return map[key]
end

return M
