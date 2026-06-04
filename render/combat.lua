local Variants = require("Engine.runtime.variants")

local M = {}

local SCOUT_COLORS = {
	glimpse = {0.5, 0.5, 0.5, 0.6},
	read = {0.65, 0.65, 0.65, 0.7},
	understand = {0.7, 0.8, 0.7, 0.8},
	insight = {0.85, 0.8, 0.6, 0.9},
	revelation = {0.6, 0.85, 0.85, 1},
}

function M.draw(state)
	local c = state.combat
	if not c or not c.enemy then
		return
	end

	local w = love.graphics.getWidth()

	-- Variant: override name
	local ename
	if c.variant then
		local vdef = Variants.def(c.variant)
		if vdef then
			ename = vdef.name
		end
	end
	ename = ename or c.enemy.display_name
		or c.enemy.archetype:gsub("^%l", string.upper)

	-- Display max (variant hp_mod and fury +2 are baked into max_hp)
	local display_max = c.enemy.max_hp

	-- Combat header
	love.graphics.setColor(0.6, 0.55, 0.5, 0.25)
	love.graphics.print("COMBAT", w / 2 - 28, 12)

	-- Separator line below header
	love.graphics.setColor(0.3, 0.3, 0.3, 0.2)
	love.graphics.rectangle("fill", w / 2 - 100, 34, 200, 1)

	-- Enemy info panel (sectioned layout)
	local pw = 340
	local ph = 280
	local px = (w - pw) / 2
	local py = 130
	local lx = px + 20
	local ry = py + 12

	if state.wound_anomaly_active then
		love.graphics.setColor(0.12, 0.06, 0.06, 0.92)
	else
		love.graphics.setColor(0.08, 0.08, 0.08, 0.92)
	end
	love.graphics.rectangle("fill", px, py, pw, ph)

	love.graphics.setColor(0.25, 0.25, 0.25, 0.35)
	love.graphics.rectangle("line", px, py, pw, ph)

	-- Trial modifier (top-right)
	if c.modifier then
		local names = {
			wounds = "Trial: Wounds",
			fury = "Trial: Fury",
			shadows = "Trial: Shadows",
		}
		love.graphics.setColor(0.55, 0.55, 0.55, 0.55)
		love.graphics.print(
			names[c.modifier] or "",
			px + pw - 130,
			py + 14
		)
	end

	-- ── Enemy Section ──
	love.graphics.setColor(0.45, 0.45, 0.45, 0.5)
	love.graphics.print("Enemy", lx, ry)
	ry = ry + 16

	-- Enemy name
	love.graphics.setColor(0.85, 0.85, 0.85, 1)
	love.graphics.print(ename, lx, ry)
	ry = ry + 24

	-- HP Bar + Vitality text
	local bar_x = lx
	local bar_y = ry
	local bar_w = 120
	local bar_h = 14
	local filled = math.min(c.enemy_hp, display_max)

	if c.modifier == "shadows" then
		love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
		love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
		love.graphics.setColor(0.65, 0.65, 0.65, 1)
		love.graphics.print("Vitality: ???", lx + bar_w + 12, bar_y - 1)
	else
		local gap = 1
		local seg_w = (bar_w - (display_max - 1) * gap) / display_max
		for i = 1, display_max do
			local seg_x = bar_x + (i - 1) * (seg_w + gap)
			love.graphics.setColor(
				i <= filled and 0.6 or 0.15,
				i <= filled and 0.3 or 0.15,
				i <= filled and 0.3 or 0.15,
				i <= filled and 0.9 or 0.5
			)
			love.graphics.rectangle("fill", seg_x, bar_y, seg_w, bar_h)
		end
		love.graphics.setColor(0.65, 0.65, 0.65, 1)
		love.graphics.print(
			"Vitality: " .. c.enemy_hp .. " / " .. display_max,
			lx + bar_w + 12,
			bar_y - 1
		)
	end
	ry = ry + bar_h + 4

	-- Damage feedback
	if c.damage_feedback and c.damage_feedback.timer > 0 then
		local df = c.damage_feedback
		local is_heal = df.text:sub(1, 1) == "+"
		love.graphics.setColor(
			is_heal and 0.5 or 1,
			is_heal and 1 or 0.5,
			0.5,
			0.8
		)
		love.graphics.print("(" .. df.text .. ")", lx + bar_w + 12, ry)
		ry = ry + 18
	end

	ry = ry + 2

	-- Separator
	love.graphics.setColor(0.3, 0.3, 0.3, 0.25)
	love.graphics.rectangle("fill", lx, ry, pw - 40, 1)
	ry = ry + 8

	-- ── Tell Section ──
	if c.tell then
		love.graphics.setColor(0.45, 0.45, 0.45, 0.5)
		love.graphics.print("Tell", lx, ry)
		ry = ry + 16

		love.graphics.setColor(0.55, 0.55, 0.55, 0.7)
		love.graphics.print("\"" .. c.tell .. "\"", lx, ry)
		ry = ry + 20

		love.graphics.setColor(0.3, 0.3, 0.3, 0.25)
		love.graphics.rectangle("fill", lx, ry, pw - 40, 1)
		ry = ry + 8
	end

	-- ── Observation Section ──
	if c.scout_observation or c.new_fact_text then
		love.graphics.setColor(0.45, 0.45, 0.45, 0.5)
		love.graphics.print("Observation", lx, ry)
		ry = ry + 16

		if c.scout_observation then
			local sc = SCOUT_COLORS[c.scout_tier] or SCOUT_COLORS.read
			love.graphics.setColor(sc)
			love.graphics.print(c.scout_observation, lx, ry)
			ry = ry + 18
		end

		if c.new_fact_text then
			love.graphics.setColor(0.6, 0.85, 0.6, 0.85)
			love.graphics.print("New Observation:", lx, ry)
			ry = ry + 15
			love.graphics.setColor(0.7, 0.9, 0.7, 0.9)
			love.graphics.print(c.new_fact_text, lx + 12, ry)
			ry = ry + 18
		end

		love.graphics.setColor(0.3, 0.3, 0.3, 0.25)
		love.graphics.rectangle("fill", lx, ry, pw - 40, 1)
		ry = ry + 8
	end

	-- ── Effects Section ──
	local has_effects = (c.scout_bonus and c.scout_bonus > 0)
		or c.brace_active
		or (c.insight_turns and c.insight_turns > 0)

	if has_effects then
		love.graphics.setColor(0.45, 0.45, 0.45, 0.5)
		love.graphics.print("Effects", lx, ry)
		ry = ry + 16

		if c.scout_bonus and c.scout_bonus > 0 then
			love.graphics.setColor(0.7, 0.75, 0.7, 0.8)
			love.graphics.print("[Scout +" .. c.scout_bonus .. "]", lx, ry)
			ry = ry + 18
		end

		if c.brace_active then
			love.graphics.setColor(0.7, 0.75, 0.85, 0.8)
			love.graphics.print("[Brace]", lx, ry)
			ry = ry + 18
		end

		if c.insight_turns and c.insight_turns > 0 then
			love.graphics.setColor(0.85, 0.8, 0.65, 0.8)
			love.graphics.print("Insight: " .. c.insight_turns, lx, ry)
			ry = ry + 18

			if c.enemy_intent then
				local intent_label = c.enemy_intent:gsub("_", " ")
				intent_label = intent_label:gsub("^%l", string.upper)
				love.graphics.setColor(0.85, 0.8, 0.65, 1)
				love.graphics.print("Intent: " .. intent_label, lx + 12, ry)
				ry = ry + 18
			end
		end

		love.graphics.setColor(0.3, 0.3, 0.3, 0.25)
		love.graphics.rectangle("fill", lx, ry, pw - 40, 1)
		ry = ry + 8
	end

	-- ── You Section ──
	love.graphics.setColor(0.45, 0.45, 0.45, 0.5)
	love.graphics.print("You", lx, ry)
	ry = ry + 16

	local pv = state.player.stats.vitality or 0
	local pmv = state.player.max_vitality or 10
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("Vitality: " .. pv .. " / " .. pmv, lx, ry)

	local stance = state.player.stance or "guarded"
	local stance_color = stance == "aggressive" and {0.85, 0.55, 0.45}
		or stance == "guarded" and {0.5, 0.7, 0.85}
		or {0.85, 0.8, 0.5}
	love.graphics.setColor(stance_color)
	love.graphics.print(
		"Stance: " .. stance:gsub("^%l", string.upper),
		lx + 140,
		ry
	)
	ry = ry + 22

	-- ── Observed Facts ──
	if state.player and state.player.knowledge then
		local facts = {}
		if state.player.knowledge[c.enemy.archetype] then
			for key, fact in pairs(
				state.player.knowledge[c.enemy.archetype].facts
			) do
				if fact.discovered then
					table.insert(facts, fact.text)
				end
			end
		end

		if #facts > 0 then
			ry = ry + 4
			love.graphics.setColor(0.45, 0.45, 0.45, 0.5)
			love.graphics.print("Observed", lx, ry)
			ry = ry + 16

			love.graphics.setColor(0.5, 0.55, 0.6, 0.55)
			for _, ftext in ipairs(facts) do
				love.graphics.print(
					"• " .. ftext,
					lx + 12,
					ry
				)
				ry = ry + 15
			end
		end
	end

	-- anomaly visual overlays
	if state.anomaly then
		local w = love.graphics.getWidth()
		local h = love.graphics.getHeight()

		if state.anomaly.type == "silent" then
			local vw = 30
			love.graphics.setColor(0.1, 0.1, 0.15, 0.5)
			love.graphics.rectangle("fill", 0, 0, w, vw)
			love.graphics.rectangle("fill", 0, h - vw, w, vw)
			love.graphics.rectangle("fill", 0, 0, vw, h)
			love.graphics.rectangle("fill", w - vw, 0, vw, h)

		elseif state.anomaly.type == "dead" then
			love.graphics.setColor(0.25, 0.25, 0.25, 0.15)
			love.graphics.rectangle("fill", 0, 0, w, h)

		elseif state.anomaly.type == "echo" then
			love.graphics.setColor(0.6, 0.55, 0.8, 0.08)
			love.graphics.rectangle("fill", 0, 0, w, 120)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
