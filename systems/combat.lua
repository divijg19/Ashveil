local M = {}

function M.player_vs_enemy(game, nx, ny)
	local enemy = game:get_enemy_at(nx, ny)
	if enemy then
		enemy.hp = enemy.hp - game.player.stats.strength
		return true
	end
	return false
end

function M.enemy_vs_player(game, nx, ny)
	if nx == game.player.x and ny == game.player.y then
		game.player.stats.vitality = game.player.stats.vitality - 1
		return true
	end
	return false
end

return M
