local M = {}

function M.vitality(player, amount)
	player.hp = player.hp + amount
end

function M.none()
end

function M.random(...)
	local args = {...}
	local pick = args[love.math.random(#args)]
	if type(pick) == "function" then
		pick()
	end
end

return M
