local M = {}

function M.get_action(key)
	local map = {
		w = "attack",
		a = "attack",
		space = "attack",

		q = "brace",
		b = "brace",
		s = "scout",

		f = "flee",

		escape = "pause"
	}

	return map[key]
end

return M
