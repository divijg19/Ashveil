local M = {}

function M.get_action(key)
	if key == "escape" then
		return "close"
	end
	if key == "return" or key == " " then
		return "confirm"
	end
	if key == "up" then
		return "up"
	end
	if key == "down" then
		return "down"
	end
	if key == "left" then
		return "left"
	end
	if key == "right" then
		return "right"
	end
	return nil
end

return M
