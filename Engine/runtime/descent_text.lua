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

local ANOMALY_TEXTS = {
	silent = {
		"The floor holds its breath.",
		"Nothing stirs here.",
		"The silence is absolute.",
		"You are utterly alone.",
	},

	geometry = {
		"The halls contradict themselves.",
		"The geometry does not fit.",
		"This floor bends.",
		"The Veil stutters.",
	},

	echo = {
		"Something was here.",
		"The Veil remembers.",
		"Old echoes linger.",
		"A ritual long finished.",
	},

	dead = {
		"This floor died long ago.",
		"Even the echoes are still.",
		"Nothing lives here.",
		"The dark is complete.",
	},
}

function M.get(floor, anomaly_type)
	if anomaly_type
		and ANOMALY_TEXTS[anomaly_type]
	then
		local pool =
			ANOMALY_TEXTS[anomaly_type]

		return pool[
			love.math.random(#pool)
		]
	end

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
