local M = {}

function M.update(game, action, dt)
	if not game.scene then return end

	if game.scene:is("explore") then
		game:update_explore(action)

	elseif game.scene:is("transition") then
		game:update_transition(dt)

	elseif game.scene:is("combat") then
		game:update_combat(action, dt)

	elseif game.scene:is("event") then
		game:update_event(action)
	end
end

return M
