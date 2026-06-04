-- DEPRECATED: old exploration-damage system (systems/combat.lua) has been
-- replaced by full encounter combat. If an enemy reaches the player during
-- world_turn, it now triggers a combat encounter rather than dealing 1 damage.
-- See systems/combat.lua (header) for the deprecated implementation.

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
