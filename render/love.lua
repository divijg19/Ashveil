local explore = require("render.explore")
local combat = require("render.combat")
local transition = require("render.transition")

local M = {}

function M.draw(state)
	if state.scene:is("explore") then
		explore.draw(state)

	elseif state.scene:is("combat") then
		combat.draw(state)

	elseif state.scene:is("transition") then
		explore.draw(state)
		transition.draw(state)
	end
end

return M
