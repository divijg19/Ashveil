local M = {}

local DEFAULT_TELL = {
	text = "The enemy stirs.",
	hints = {"attack"},
}

local TELLS = {
	brute = {
		{
			text = "The Brute tenses its muscles.",
			hints = {"attack", "heavy_attack"},
		},
		{
			text = "The Brute plants its feet firmly.",
			hints = {"heavy_attack", "defend"},
		},
		{
			text = "The Brute's breathing grows heavy.",
			hints = {"attack", "recover"},
		},
		{
			text = "The Brute lowers its stance.",
			hints = {"defend", "recover"},
		},
	},
	stalker = {
		{
			text = "The Stalker shifts its weight.",
			hints = {"attack", "heavy_attack"},
		},
		{
			text = "The Stalker circles quietly.",
			hints = {"attack", "heavy_attack"},
		},
		{
			text = "The Stalker watches for an opening.",
			hints = {"attack", "recover"},
		},
		{
			text = "The Stalker vanishes from sight.",
			hints = {"heavy_attack", "recover"},
		},
	},
	watcher = {
		{
			text = "The Watcher studies you carefully.",
			hints = {"defend", "recover"},
		},
		{
			text = "The Watcher withdraws slightly.",
			hints = {"defend", "recover"},
		},
		{
			text = "The Watcher remains perfectly still.",
			hints = {"recover", "defend"},
		},
		{
			text = "The Watcher's eyes track your movements.",
			hints = {"attack", "defend"},
		},
	},
	fanatic = {
		{
			text = "The Fanatic's grip tightens on its weapon.",
			hints = {"attack", "heavy_attack"},
		},
		{
			text = "The Fanatic lets out a guttural chant.",
			hints = {"heavy_attack", "recover"},
		},
		{
			text = "The Fanatic sneers and advances.",
			hints = {"attack", "heavy_attack"},
		},
		{
			text = "The Fanatic mutters under its breath.",
			hints = {"recover", "heavy_attack"},
		},
	},
	sentinel = {
		{
			text = "The Sentinel reflects your stance.",
			hints = {"defend", "recover"},
		},
		{
			text = "The Sentinel moves as if remembering.",
			hints = {"attack", "heavy_attack"},
		},
		{
			text = "The Sentinel's gaze flickers with recognition.",
			hints = {"heavy_attack", "defend"},
		},
		{
			text = "The Sentinel echoes a past battle.",
			hints = {"attack", "recover"},
		},
	},
}

local RECOGNITION_TELLS = {
	studied = {
		brute = "You recognize their patterns now.",
		stalker = "You know how this one moves.",
		watcher = "Their patience no longer unsettles you.",
		fanatic = "Their fervor is no longer a surprise.",
		sentinel = "The silence around them is familiar.",
	},
	mastered = {
		brute = "Their violence follows a known pattern.",
		stalker = "Their strikes arrive as you predicted.",
		watcher = "Their attention shifts where you expect.",
		fanatic = "Their recklessness plays out as you expected.",
		sentinel = "Even their stillness reveals its purpose.",
	},
}

function M.select_tell(archetype, intent)
	local pool = TELLS[archetype]
	if not pool then
		return DEFAULT_TELL
	end

	local candidates = {}
	for _, tell in ipairs(pool) do
		for _, h in ipairs(tell.hints) do
			if h == intent then
				table.insert(candidates, tell)
				break
			end
		end
	end

	if #candidates == 0 then
		return DEFAULT_TELL
	end

	return candidates[love.math.random(#candidates)]
end

function M.get_recognition_tell(archetype, tier)
	if tier == "unknown" then
		return ""
	end
	local lines = RECOGNITION_TELLS[tier]
	if not lines then
		return ""
	end
	return lines[archetype] or ""
end

return M
