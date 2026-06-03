local MessagePanel = require("Engine.runtime.message_panel")

local M = {}

function M.setup(game)
	game.wound_anomaly_active = true
	MessagePanel.push("The Veil is bleeding. Something has wounded it.")
end

function M.reset(game)
	game.wound_anomaly_active = nil
end

return M
