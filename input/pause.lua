local M = {}

local map = {
	escape = "resume",
	q = "quit",
}

function M.get_action(key)
	return map[key]
end

return M
