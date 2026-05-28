local M = {}

local TIERS = {
	{
		floor = 1,
		messages = {
			"The silence deepens.",
			"The Veil watches.",
			"The halls narrow.",
			"Something remembers you.",
		},
	},

	{
		floor = 3,
		messages = {
			"The dark thickens.",
			"You are expected.",
			"The walls breathe.",
			"Stillness settles.",
		},
	},

	{
		floor = 5,
		messages = {
			"The descent remembers.",
			"Light forgets you.",
			"The Veil thickens.",
			"Echoes without source.",
		},
	},

	{
		floor = 7,
		messages = {
			"Depth has weight.",
			"The Veil knows your name.",
			"Something stirs below.",
			"Silence is a presence.",
		},
	},

	{
		floor = 10,
		messages = {
			"You are far now.",
			"The Veil is all.",
			"Nothing follows.",
			"The dark is warm.",
		},
	},
}

function M.get(floor)
	local tier = TIERS[1]

	for _, t in ipairs(TIERS) do
		if floor >= t.floor then
			tier = t
		end
	end

	return tier.messages[
		love.math.random(#tier.messages)
	]
end

return M
