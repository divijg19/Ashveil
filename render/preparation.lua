local Equipment = require("Engine.runtime.equipment")

local M = {}

local function equipped_name(player, slot)
	local inst = Equipment.equipped_instance(player, slot)
	if not inst then return nil end
	local def = Equipment.def(inst.id)
	return def and def.name or nil
end

local function draw_slider(lcx, lcy, label, value, is_selected)
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print(label, lcx, lcy)
	if is_selected then
		love.graphics.setColor(1, 0.85, 0.5, 1)
	else
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
	end
	love.graphics.print(value, lcx + 200, lcy)
	return lcy + 24
end

function M.draw(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local p = state.player
	local prep = state.preparation_state
	if not prep or not p then return end

	love.graphics.setColor(0, 0, 0, 0.92)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local lcx = (w - 520) / 2
	local lcy = 80
	local line_h = 24

	-- Title
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("PREPARATION", lcx, lcy)
	lcy = lcy + line_h + 12

	-- Region info
	local region = state.current_region
	if region then
		love.graphics.setColor(0.85, 0.85, 0.85, 1)
		love.graphics.print("Entering: " .. region.name, lcx, lcy)
		lcy = lcy + line_h
		love.graphics.setColor(0.6, 0.6, 0.6, 1)
		love.graphics.printf(region.desc or "", lcx + 8, lcy, w - lcx - 40)
		lcy = lcy + line_h * 2
	end

	-- Separator
	love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
	love.graphics.rectangle("fill", lcx, lcy, w - lcx * 2, 1)
	lcy = lcy + 12

	-- Weapon slot
	local w_name = equipped_name(p, "weapon") or "(none)"
	lcy = draw_slider(lcx, lcy, "Weapon", w_name, prep.cursor == 1)

	-- Charm slot
	local c_name = equipped_name(p, "charm") or "(none)"
	lcy = draw_slider(lcx, lcy, "Charm", c_name, prep.cursor == 2)

	-- Stance slot
	local stance_name = (prep.stance or "guarded"):gsub("^%l", string.upper)
	lcy = draw_slider(lcx, lcy, "Stance", stance_name, prep.cursor == 3)

	-- Separator
	lcy = lcy + 6
	love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
	love.graphics.rectangle("fill", lcx, lcy, w - lcx * 2, 1)
	lcy = lcy + 14

	-- Prompt
	love.graphics.setColor(0.55, 0.55, 0.55, 1)
	love.graphics.print("[Enter] Confirm   [Esc] Cancel", lcx, lcy)

	love.graphics.setColor(1, 1, 1, 1)
end

return M