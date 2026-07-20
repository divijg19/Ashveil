local M = {}

function M.get_action(key)
	if key == "i" or key == "escape" then
		return "close"
	elseif key == "up" then
		return "up"
	elseif key == "down" then
		return "down"
	elseif key == "e" then
		return "equip"
	elseif key == "u" then
		return "unequip"
	end
end

return M
