local MessagePanel = require("Engine.runtime.message_panel")

local M = {}

function M.inspect(game, poi)
	if not poi or not poi.poi then
		return
	end

	local text = poi.poi.inspect

	if not text then
		return
	end

	if game.player.stats.perception >= 3 then
		local extras = {
			"The details seem clearer up close.",
			"Subtle imperfections catch your eye.",
			"Your training reveals hidden nuance.",
		}

		text = text
			.. " "
			.. extras[love.math.random(#extras)]
	end

	MessagePanel.push(text)
end

return M
