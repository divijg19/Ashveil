local MessagePanel = require("Engine.runtime.message_panel")

local M = {}

function M.setup(game)
	MessagePanel.push_passive(
		"The Veil grows impossibly still."
	)
end

return M
