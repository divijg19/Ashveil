local M = {}

function M.get_action(key)
	if key == "i" or key == "escape" then
		return "close"
	end
end

return M
