-- Enemy AI: moves enemies toward the player during world_tick.
-- When an enemy reaches the player tile, triggers a full combat encounter.

local movement = require("systems.movement")

local M = {}

function M.enemy_turn(game, e)
	local nx, ny = movement.enemy(game, e)
	if not nx then
		return
	end

	if nx == game.player.x and ny == game.player.y then
		if game.scene:is("transition") then
			return
		end
		game:start_combat(e)
		return
	end

	if game:get_enemy_at(nx, ny) then
		return
	end

	e.x = nx
	e.y = ny
end

return M
