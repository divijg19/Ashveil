local Relics = require("Engine.runtime.relics")

local STANCES = {"guarded", "aggressive", "focused"}
local STANCE_LABELS = {
	guarded = "Guarded     (-1 damage taken)",
	aggressive = "Aggressive  (+1 dealt, +1 taken)",
	focused = "Focused     (+2 effective Perception)",
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
				love.graphics.print(def.name, cx, cy)
				love.graphics.setColor(0.55, 0.55, 0.55, 1)
				love.graphics.print(def.desc, cx + 16, cy + line_h)
				cy = cy + line_h * 2
				love.graphics.setColor(0.75, 0.75, 0.75, 1)
			end
			shown = shown + 1
		end
	end

	cy = cy + 20

	-- close hint
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.print("Press ESC to close", cx, cy)

	love.graphics.setColor(1, 1, 1, 1)
end

return M
