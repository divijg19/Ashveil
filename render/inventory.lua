local Consumables = require("Engine.runtime.consumables")

local M = {}

function M.draw(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local p = state.player

	-- backdrop
	love.graphics.setColor(0, 0, 0, 0.9)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local lcx = 40
	local lcy = 48
	local line_h = 20

	-- title
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("INVENTORY", lcx, lcy)
	lcy = lcy + line_h + 8

	-- Consumables
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Consumables:", lcx, lcy)
	lcy = lcy + line_h

	local con_ids = {"bandage", "ration"}
	local has_any = false
	for _, cid in ipairs(con_ids) do
		local count = Consumables.count(p, cid)
		local def = Consumables.def(cid)
		if def and count > 0 then
			has_any = true
			love.graphics.setColor(0.75, 0.75, 0.75, 1)
			love.graphics.print(def.name .. " x" .. count, lcx + 16, lcy)
			lcy = lcy + line_h
		end
	end
	if not has_any then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", lcx + 16, lcy)
		lcy = lcy + line_h
	end
	lcy = lcy + 8

	-- Currencies
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Currencies:", lcx, lcy)
	lcy = lcy + line_h
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("Gold: " .. (p.gold or 0), lcx + 16, lcy)
	lcy = lcy + line_h
	love.graphics.print("Veil Shards: " .. (p.veil_shards or 0), lcx + 16, lcy)
	lcy = lcy + line_h + 8

	-- Equipment
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Equipment:", lcx, lcy)
	lcy = lcy + line_h
	local eq = p.equipment or {}
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("Weapon: " .. (eq.weapon or "(empty)"), lcx + 16, lcy)
	lcy = lcy + line_h
	love.graphics.print("Charm: " .. (eq.charm or "(empty)"), lcx + 16, lcy)
	lcy = lcy + line_h + 8

	-- Materials
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Materials:", lcx, lcy)
	lcy = lcy + line_h
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.print("No crafting materials discovered.", lcx + 16, lcy)

	-- close hint
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.print("[I] Close", lcx, h - 40)

	love.graphics.setColor(1, 1, 1, 1)
end

return M
