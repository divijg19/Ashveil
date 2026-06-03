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
			ai.enemy_turn(game, e)

			-- Combat encounter started during enemy turn; stop processing
			if game.scene:is("transition") then
				break
			end
		end
	end
end

return M
