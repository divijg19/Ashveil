local explore = require("render.explore")
local combat = require("render.combat")
local transition = require("render.transition")
local event_view = require("render.event")
local character_view = require("render.character")
local inventory_view = require("render.inventory")

local M = {}

-- =============================
-- SCENE DISPATCH
-- =============================

function M.draw(state)
	if not state.scene then
		return
	end

	-- scene content first
	if state.scene:is("explore") then
		explore.draw(state)

	elseif state.scene:is("combat") then
		local w, h = love.graphics.getWidth(), love.graphics.getHeight()
		love.graphics.setColor(0.05, 0.05, 0.08, 1)
		love.graphics.rectangle("fill", 0, 0, w, h)
		combat.draw(state)

	elseif state.scene:is("event") then
		explore.draw(state)
		event_view.draw(state)

	elseif state.scene:is("transition") then
		explore.draw(state)
		transition.draw(state)
	end

	-- persistent HUD overlays
	M.draw_top_panel(state)
	M.draw_bottom_narrative(state)
	M.draw_bottom_actions(state)

	-- character sheet overlay (topmost)
	if state.show_character then
		character_view.draw(state)
	end

	-- inventory overlay
	if state.show_inventory then
		inventory_view.draw(state)
	end
end

-- =============================
-- TOP-LEFT CHARACTER PANEL
-- =============================

-- stance colors (module-level constant)
local STANCE_COLORS = {
	aggressive = { 0.85, 0.55, 0.45, 1 },
	guarded = { 0.5, 0.7, 0.85, 1 },
	focused = { 0.85, 0.8, 0.5, 1 },
}

function M.draw_top_panel(state)
	local w = love.graphics.getWidth()
	local p = state.player
	if not p or not p.stats then
		return
	end

	-- solid background (taller for vertical stats + stance)
	love.graphics.setColor(0.08, 0.08, 0.08, 0.88)
	love.graphics.rectangle("fill", 8, 8, 155, 108)

	-- subtle edge
	love.graphics.setColor(0.3, 0.3, 0.3, 0.4)
	love.graphics.rectangle("line", 8, 8, 155, 108)

	-- floor + vitality
	love.graphics.setColor(0.85, 0.85, 0.85, 1)
	love.graphics.print("Floor " .. state.floor, 16, 12)
	love.graphics.print("Vitality " .. p.stats.vitality, 16, 26)

	-- vertical stats (readability > density)
	love.graphics.setColor(0.65, 0.65, 0.65, 1)
	love.graphics.print("STR  " .. p.stats.strength, 16, 42)
	love.graphics.print("RES  " .. p.stats.resolve, 16, 54)
	love.graphics.print("PER  " .. p.stats.perception, 16, 66)
	love.graphics.print("AGI  " .. p.stats.agility, 16, 78)

	-- stance display (color-coded)
	local sc = STANCE_COLORS[p.stance] or { 0.7, 0.7, 0.65, 1 }
	love.graphics.setColor(sc)
	love.graphics.print(p.stance:gsub("^%l", string.upper), 16, 94)

	love.graphics.setColor(1, 1, 1, 1)
end

-- =============================
-- BOTTOM NARRATIVE PANEL
-- =============================

function M.draw_bottom_narrative(state)
	local panel = state.message_panel
	if not panel then
		return
	end

	local msg = panel.current()
	if not msg then
		return
	end

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	local ph = 80
	local px = 10
	local py = h - ph - 50

	love.graphics.setColor(0.08, 0.08, 0.08, 0.9)
	love.graphics.rectangle("fill", px, py, w - 20, ph)

	love.graphics.setColor(0.3, 0.3, 0.3, 0.4)
	love.graphics.rectangle("line", px, py, w - 20, ph)

	-- message text
	if msg.text then
		love.graphics.setColor(0.85, 0.85, 0.85, msg.alpha or 1)
		love.graphics.printf(
			msg.text,
			px + 20,
			py + 18,
			w - 60,
			"center"
		)
	end

	-- acknowledgment prompt
	if msg.is_waiting then
		love.graphics.setColor(0.6, 0.6, 0.6, (msg.alpha or 1) * 0.7)
		love.graphics.printf(
			"[ Enter ]",
			px + 20,
			py + ph - 22,
			w - 60,
			"center"
		)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

-- =============================
-- BOTTOM ACTION BAR
-- =============================

function M.draw_bottom_actions(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	if not state.scene then
		return
	end

	local py = h - 42

	-- background strip
	love.graphics.setColor(0.08, 0.08, 0.08, 0.85)
	love.graphics.rectangle("fill", 0, py, w, 42)

	love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
	love.graphics.rectangle("line", 0, py, w, 42)

	-- consumable counts
	local bandage_count = 0
	local ration_count = 0
	if state.player
		and state.player.inventory
		and state.player.inventory.consumables
	then
		bandage_count = state.player.inventory.consumables.bandage or 0
		ration_count = state.player.inventory.consumables.ration or 0
	end

	-- context-sensitive prompts
	local left = 20
	local spacing = state.scene:is("combat") and 130 or 150

	if state.scene:is("explore") or state.scene:is("event") then
		love.graphics.setColor(0.7, 0.7, 0.7, 1)

		local poi = state.nearby_poi
		if poi and poi.poi then
			local action = (poi.poi.interaction or {}).action or "Interact"
			love.graphics.print("[E] " .. action, left, py + 12)
			left = left + spacing

			if poi.poi.inspect then
				love.graphics.print("[F] Inspect", left, py + 12)
				left = left + spacing
			end
		end

		love.graphics.print("[C] Character", left, py + 12)
		left = left + spacing

		-- consumables
		if bandage_count > 0 then
			love.graphics.setColor(0.7, 0.7, 0.7, 1)
			love.graphics.print("[1] Bandage x" .. bandage_count, left, py + 12)
			left = left + spacing
		end
		if ration_count > 0 then
			love.graphics.setColor(0.7, 0.7, 0.7, 1)
			love.graphics.print("[2] Ration x" .. ration_count, left, py + 12)
			left = left + spacing
		end

		love.graphics.setColor(0.7, 0.7, 0.7, 1)
		love.graphics.print("ESC Menu", left, py + 12)

	elseif state.scene:is("combat") then
		love.graphics.setColor(0.7, 0.7, 0.7, 1)
		love.graphics.print("[A] Attack", left, py + 12)
		left = left + spacing
		love.graphics.print("[B] Brace", left, py + 12)
		left = left + spacing
		love.graphics.print("[S] Scout", left, py + 12)
		left = left + spacing
		love.graphics.print("[F] Flee", left, py + 12)
		left = left + spacing

		-- consumables
		if bandage_count > 0 then
			love.graphics.setColor(0.7, 0.7, 0.7, 1)
			love.graphics.print("[1] Bandage x" .. bandage_count, left, py + 12)
			left = left + spacing
		end
		if ration_count > 0 then
			love.graphics.setColor(0.7, 0.7, 0.7, 1)
			love.graphics.print("[2] Ration x" .. ration_count, left, py + 12)
			left = left + spacing
		end

		love.graphics.setColor(0.7, 0.7, 0.7, 1)
		love.graphics.print("ESC", left, py + 12)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
