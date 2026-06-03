local M = {}

function M.get_action(key)
	local map = {
		w = "attack",
		space = "attack",

		q = "guard",
		e = "skill",
		f = "flee",

		escape = "pause"
	}

	return map[key]
end

return M
