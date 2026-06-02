local M = {}

function M.update(game, ai)
	for i = #game.enemies, 1, -1 do
		local e = game.enemies[i]

		if e.hp <= 0 then
			table.remove(
				game.enemies,
				i
			)

		else
			local before_hp =
				game.player.stats.vitality

			ai.enemy_turn(game, e)

			if game.player.stats.vitality
				< before_hp
			then
				game.log =
					"Enemy hit you."
			end
		end
	end
end

return M
