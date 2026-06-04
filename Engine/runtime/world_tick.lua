local M = {}

function M.update(game, ai)
	if not game.enemies then return end
	for i = #game.enemies, 1, -1 do
		local e = game.enemies[i]

		if (e.hp or 0) <= 0 then
			table.remove(
				game.enemies,
				i
			)

		else
			ai.enemy_turn(game, e)

			-- Combat encounter started during enemy turn; stop processing
			if game.scene and game.scene:is("transition") then
				break
			end
		end
	end
end

return M
