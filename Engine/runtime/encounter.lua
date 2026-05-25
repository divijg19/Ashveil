local M = {}

function M.start(player, enemy)
	return {
		enemy = enemy,

		player_hp = player.hp,
		enemy_hp = enemy.hp,
	}
end

function M.finish(encounter, player, won)
	if won then
		encounter.enemy.hp = 0
	end

	player.hp =
		encounter.player_hp
end

return M
