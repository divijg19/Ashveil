local M = {}

local map = {
	w = "attack",
	a = "attack",
	space = "attack",

	q = "brace",
	b = "brace",
	s = "scout",

	f = "flee",

	escape = "pause",
}

function M.get_action(key)
	return map[key]
end

return M
