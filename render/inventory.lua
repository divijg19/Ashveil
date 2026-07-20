local Consumables = require("Engine.runtime.consumables")
local Equipment = require("Engine.runtime.equipment")

local M = {}

local function equipped_name(player, slot)
	local inst = Equipment.equipped_instance(player, slot)
	if not inst then return nil end
	local def = Equipment.def(inst.id)
	return def and def.name or nil
end

local function format_provenance(floor, region, source)
	local lines = {}
	if floor then
		table.insert(lines, "F" .. floor .. " \183 " .. (region or "?"))
	else
		table.insert(lines, "Location unknown")
	end
	table.insert(lines, source or "Unknown")
	return lines
end

local function draw_equipment_list(lcx, lcy, player, cursor, has_cursor)
	local equipment = (player.inventory and player.inventory.equipment) or {}
	local line_h = 20

	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Equipment:", lcx, lcy)
	lcy = lcy + line_h

	if #equipment == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(nothing recovered yet)", lcx + 16, lcy)
		lcy = lcy + line_h
		return lcy, nil
	end

	for i, inst in ipairs(equipment) do
		local def = Equipment.def(inst.id)
		if def then
			if has_cursor and i == cursor then
				love.graphics.setColor(1, 0.85, 0.5, 1)
				love.graphics.print(">", lcx + 12, lcy)
				love.graphics.print(def.name, lcx + 32, lcy)
			else
				love.graphics.setColor(0.75, 0.75, 0.75, 1)
				love.graphics.print(def.name, lcx + 32, lcy)
			end
			lcy = lcy + line_h
		end
	end

	return lcy, equipment
end

local function draw_detail_panel(lcx, lcy, w, player, cursor, equipment)
	local line_h = 20
	local inst = equipment[cursor]
	if not inst then return lcy end
	local def = Equipment.def(inst.id)
	if not def then return lcy end

	lcy = lcy + 4

	-- Provenance (narrative format)
	love.graphics.setColor(0.6, 0.6, 0.6, 1)
	love.graphics.print("Recovered:", lcx + 16, lcy)
	lcy = lcy + line_h
	local prov_lines = format_provenance(inst.floor, inst.region, inst.source)
	for _, line in ipairs(prov_lines) do
		love.graphics.setColor(0.55, 0.55, 0.55, 1)
		love.graphics.print(line, lcx + 32, lcy)
		lcy = lcy + line_h
	end

	lcy = lcy + 4

	-- Kind
	love.graphics.setColor(0.55, 0.55, 0.55, 1)
	local kind_label = def.kind == "weapon" and "Weapon" or "Charm"
	love.graphics.print("Type: " .. kind_label, lcx + 16, lcy)
	lcy = lcy + line_h
	lcy = lcy + 4

	-- Description
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.printf(def.desc or "", lcx + 16, lcy, w - lcx - 56)
	lcy = lcy + line_h * 2

	-- Inspect text
	love.graphics.setColor(0.45, 0.45, 0.45, 1)
	love.graphics.printf("\"" .. (def.inspect or "") .. "\"", lcx + 16, lcy, w - lcx - 56)
	lcy = lcy + line_h * 2

	return lcy
end

local function draw_equipped_section(lcx, lcy, player)
	local line_h = 20

	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Equipped", lcx, lcy)
	lcy = lcy + line_h

	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	local wname = equipped_name(player, "weapon") or "(empty)"
	love.graphics.print("Weapon: " .. wname, lcx + 16, lcy)
	lcy = lcy + line_h

	local cname = equipped_name(player, "charm") or "(empty)"
	love.graphics.print("Charm : " .. cname, lcx + 16, lcy)
	lcy = lcy + line_h

	return lcy
end

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
	local equipment

	-- title
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("INVENTORY", lcx, lcy)
	lcy = lcy + line_h + 8

	-- ============ Consumables ============
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

	-- ============ Currencies ============
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("Currencies:", lcx, lcy)
	lcy = lcy + line_h
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("Gold: " .. (p.gold or 0), lcx + 16, lcy)
	lcy = lcy + line_h
	love.graphics.print("Veil Shards: " .. (p.veil_shards or 0), lcx + 16, lcy)
	lcy = lcy + line_h + 8

	-- ============ Equipment ============
	local inv_state = state.inventory_state or {}
	local cursor = inv_state and inv_state.cursor or 1
	local has_equipment = #((p.inventory and p.inventory.equipment) or {}) > 0
	local has_cursor = has_equipment and inv_state and inv_state.initialized

	lcy, equipment = draw_equipment_list(lcx, lcy, p, cursor, has_cursor)
	lcy = lcy + 8

	-- ============ Detail panel ============
	if has_cursor then
		lcy = draw_detail_panel(lcx, lcy, w, p, cursor, equipment)
	end
	lcy = lcy + 8

	-- ============ Equipped ============
	lcy = draw_equipped_section(lcx, lcy, p)

	-- ============ Action prompts ============
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.print("[I] Close   [Up/Down] Select   [E] Equip   [U] Unequip", lcx, h - 40)

	love.graphics.setColor(1, 1, 1, 1)
end

return M
