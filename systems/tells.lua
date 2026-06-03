local M = {}

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
			hints = {"attack", "heavy_attack"},
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
}

function M.select_tell(archetype, intent)
	local pool = TELLS[archetype]
	if not pool then
		return {text = "The enemy stirs.", hints = {"attack"}}
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
		return {text = "The enemy stirs.", hints = {"attack"}}
	end

	return candidates[love.math.random(#candidates)]
end

return M
