local M = {}

function M.get_action(key)
	local map = {
		w = "attack",
		space = "attack",

		q = "guard",
		e = "skill",

		escape = "flee"
	}

	return map[key]
end

return M
