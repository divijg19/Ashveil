local movement = require("systems.movement")
local combat = require("systems.combat")

local M = {}

function M.enemy_turn(game, e)
	local nx, ny = movement.enemy(game, e)
	if not nx then
		return
	end

	if combat.enemy_vs_player(game, nx, ny) then
		return
	end

	if game:get_enemy_at(nx, ny) then
		return
	end

	e.x = nx
	e.y = ny
end

return M
