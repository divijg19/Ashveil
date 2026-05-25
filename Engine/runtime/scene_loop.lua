local M = {}

function M.update(game, action)
	if game.scene:is("explore") then
		game:update_explore(action)

	elseif game.scene:is("transition") then
		game:update_transition()

	elseif game.scene:is("combat") then
		game:update_combat(action)
	end
end

return M
