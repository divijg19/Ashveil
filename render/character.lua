local Relics = require("Engine.runtime.relics")
local Knowledge = require("systems.knowledge")

local STANCES = {"guarded", "aggressive", "focused"}
local STANCE_LABELS = {
	guarded = "Guarded     (-1 damage taken)",
	aggressive = "Aggressive  (+1 dealt, +1 taken)",
	focused = "Focused     (+3 Scout)",
}

local M = {}

function M.draw(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local p = state.player

	-- backdrop
	love.graphics.setColor(0, 0, 0, 0.85)
	love.graphics.rectangle("fill", 0, 0, w, h)

	-- panel
	local pw = 360
	local ph = h - 80
	local px = (w - pw) / 2
	local py = 40

	love.graphics.setColor(0.15, 0.15, 0.15, 1)
	love.graphics.rectangle("fill", px, py, pw, ph)
	love.graphics.setColor(0.4, 0.4, 0.4, 1)
	love.graphics.rectangle("line", px, py, pw, ph)

	local cx = px + 20
	local cy = py + 20
	local line_h = 20

	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("=== CHARACTER ===", cx, cy)
	cy = cy + 30

	-- stats
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("Vitality: " .. p.stats.vitality, cx, cy)
	cy = cy + line_h
	love.graphics.print("Strength:  " .. p.stats.strength, cx, cy)
	cy = cy + line_h
	love.graphics.print("Resolve:   " .. p.stats.resolve, cx, cy)
	cy = cy + line_h
	love.graphics.print("Perception: " .. p.stats.perception, cx, cy)
	cy = cy + line_h
	love.graphics.print("Agility:    " .. p.stats.agility, cx, cy)
	cy = cy + line_h + 10

	-- stance selector
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Stance --", cx, cy)
	cy = cy + line_h

	local sheet = state.character_sheet
	local sel = sheet and sheet.selection or 1

	for i, s in ipairs(STANCES) do
		local label = STANCE_LABELS[s]
		local is_selected = p.stance == s
		local is_highlighted = sel == i

		if is_highlighted then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(">", cx, cy)
			love.graphics.setColor(0.9, 0.9, 0.7, 1)
		elseif is_selected then
			love.graphics.setColor(0.7, 0.9, 0.7, 1)
			love.graphics.print("*", cx, cy)
		else
			love.graphics.setColor(0.6, 0.6, 0.6, 1)
		end

		love.graphics.print(label, cx + 16, cy)
		cy = cy + line_h
	end

	cy = cy + 10

	-- blessings (cap at 5)
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Blessings --", cx, cy)
	cy = cy + line_h

	if #p.blessings == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", cx, cy)
		cy = cy + line_h
	else
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
		local shown = 0
		local max_shown = 5
		for _, name in ipairs(p.blessings) do
			if shown >= max_shown then
				local remaining = #p.blessings - shown
				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				love.graphics.print("+" .. remaining .. " more...", cx, cy)
				cy = cy + line_h
				break
			end
			love.graphics.print(name, cx, cy)
			cy = cy + line_h
			shown = shown + 1
		end
	end

	cy = cy + 10

	-- relics (cap at 5)
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Relics --", cx, cy)
	cy = cy + line_h

	local relic_count = Relics.count(p)
	if relic_count == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", cx, cy)
		cy = cy + line_h
	else
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
		local shown = 0
		local max_shown = 5
		for id in pairs(p.relics) do
			if shown >= max_shown then
				local remaining = relic_count - shown
				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				love.graphics.print("+" .. remaining .. " more...", cx, cy)
				cy = cy + line_h
				break
			end
			local def = Relics.def(id)
			if def then
				if def.symbol then
					love.graphics.print(def.symbol, cx, cy)
					love.graphics.print(def.name, cx + 16, cy)
				else
					love.graphics.print(def.name, cx, cy)
				end
				love.graphics.setColor(0.55, 0.55, 0.55, 1)
				love.graphics.print(def.desc, cx + 16, cy + line_h)
				if def.artifact then
					love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
					love.graphics.print(def.artifact, cx + 16, cy + line_h * 2)
				end
				cy = cy + line_h * 3
				love.graphics.setColor(0.75, 0.75, 0.75, 1)
			end
			shown = shown + 1
		end
	end

	cy = cy + 10

	-- knowledge journal
	if p.knowledge then
		local arch_order = {"brute", "stalker", "watcher", "fanatic"}
		local shown = 0
		local max_shown = 10

		love.graphics.setColor(0.9, 0.9, 0.9, 1)
		love.graphics.print("-- Observed Creatures --", cx, cy)
		cy = cy + line_h + 4

		local klh = 14

		for _, arch in ipairs(arch_order) do
			if shown >= max_shown then
				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				love.graphics.print("+ more...", cx, cy)
				cy = cy + klh
				break
			end

			local entry = p.knowledge[arch]
			if entry and entry.encounters > 0 then
				shown = shown + 1
				local total = Knowledge.fact_count(arch)
				local disc = Knowledge.discovered_count(p, arch)

				local label = arch:gsub("^%l", string.upper)
				love.graphics.setColor(0.75, 0.75, 0.75, 1)
				love.graphics.print(label, cx, cy)
				cy = cy + klh

				love.graphics.setColor(0.5, 0.5, 0.5, 1)
				love.graphics.print("Seen: " .. entry.encounters .. "  |  Observed: " .. disc .. "/" .. total, cx + 8, cy)
				cy = cy + klh

				if Knowledge.mastered(p, arch) then
					love.graphics.setColor(0.85, 0.8, 0.6, 1)
					love.graphics.print("MASTERED", cx + 8, cy)
					cy = cy + klh
				end

				love.graphics.setColor(0.5, 0.55, 0.6, 0.7)
				for key, fact in pairs(entry.facts) do
					if fact.discovered then
						love.graphics.setColor(0.55, 0.7, 0.55, 0.8)
						love.graphics.print("  " .. fact.text, cx + 8, cy)
						cy = cy + klh
					end
				end

				-- Show undiscovered slots
				local undisc = Knowledge.undiscovered_facts(p, arch)
				for _ = 1, #undisc do
					love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
					love.graphics.print("  ?", cx + 8, cy)
					cy = cy + klh
				end
			end
		end
	end

	cy = cy + 10

	-- close hint
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.print("Press ESC to close", cx, cy)

	love.graphics.setColor(1, 1, 1, 1)
end

return M
