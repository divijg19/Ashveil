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
		floor = 2,
		messages = {
			"The descent begins.",
			"You are not lost. Yet.",
			"The Veil stirs.",
			"Somewhere below, something waits.",
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
		floor = 4,
		messages = {
			"The air grows heavy.",
			"The Veil observes.",
			"These halls remember.",
			"You descend unnoticed.",
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
		floor = 6,
		messages = {
			"The corridors shift.",
			"You have been here before.",
			"Something follows.",
			"The silence follows.",
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
		floor = 8,
		messages = {
			"The halls repeat themselves.",
			"You are being remembered.",
			"The geometry breathes.",
			"Old echoes return.",
		},
	},

	{
		floor = 9,
		messages = {
			"Recurring. Returning. Repeating.",
			"The Veil does not forget.",
			"You have walked these halls before.",
			"The descent is recursive.",
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

	{
		floor = 12,
		messages = {
			"The Veil forgets itself.",
			"Depth dissolves.",
			"You are becoming part of it.",
			"There is no surface.",
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
