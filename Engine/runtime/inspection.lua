local MessagePanel = require("Engine.runtime.message_panel")

local M = {}

local RARE_OBSERVATIONS = {
	"A faint whisper emanates from the object.",
	"The Veil thins around this place.",
	"You sense a deeper purpose here.",
}

local EXTRA_OBSERVATIONS = {
	"The details seem clearer up close.",
	"Subtle imperfections catch your eye.",
	"Your training reveals hidden nuance.",
}

function M.inspect(game, poi)
	if not poi or not poi.poi then
		return
	end

	local text = poi.poi.inspect

	if not text then
		return
	end

	if game.player.stats.perception >= 5 then
		text = text
			.. " "
			.. RARE_OBSERVATIONS[
				love.math.random(#RARE_OBSERVATIONS)
			]

	elseif game.player.stats.perception >= 3 then
		text = text
			.. " "
			.. EXTRA_OBSERVATIONS[
				love.math.random(#EXTRA_OBSERVATIONS)
			]
	end

	MessagePanel.push(text)
end

return M
