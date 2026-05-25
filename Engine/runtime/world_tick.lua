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
				game.player.hp

			ai.enemy_turn(game, e)

			if game.player.hp
				< before_hp
			then
				game.log =
					"Enemy hit you."
			end
		end
	end
end

return M
