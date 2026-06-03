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
	if not c then
		return
	end

	local ename = c.enemy.archetype:gsub("^%l", string.upper)
	local w = love.graphics.getWidth()

	-- Display max (fury trial adds +2 to enemy HP at start)
	local display_max = c.enemy.max_hp
	if c.modifier == "fury" then
		display_max = c.enemy.max_hp + 2
	end

	-- Combat header
	love.graphics.setColor(0.6, 0.55, 0.5, 0.25)
	love.graphics.print("COMBAT", w / 2 - 28, 12)

	-- Separator line below header
	love.graphics.setColor(0.3, 0.3, 0.3, 0.2)
	love.graphics.rectangle("fill", w / 2 - 100, 34, 200, 1)

	-- Enemy info panel (taller for tell + scout + insight + facts + bonus)
	local pw = 340
	local ph = 220
	local px = (w - pw) / 2
	local py = 150

	love.graphics.setColor(0.08, 0.08, 0.08, 0.92)
	love.graphics.rectangle("fill", px, py, pw, ph)

	love.graphics.setColor(0.25, 0.25, 0.25, 0.35)
	love.graphics.rectangle("line", px, py, pw, ph)

	local lx = px + 24
	local cy = py + 20

	-- Archetype name (prominent)
	love.graphics.setColor(0.85, 0.85, 0.85, 1)
	love.graphics.print(ename, lx, cy)
	cy = cy + 28

	-- Vitality
	love.graphics.setColor(0.65, 0.65, 0.65, 1)

	if c.modifier == "shadows" then
		love.graphics.print("Vitality: ???", lx, cy)
	else
		love.graphics.print(
			"Vitality: "
				.. c.enemy_hp
				.. " / "
				.. display_max,
			lx,
			cy
		)
	end

	cy = cy + 24

	-- Separator
	love.graphics.setColor(0.3, 0.3, 0.3, 0.25)
	love.graphics.rectangle("fill", lx, cy, pw - 48, 1)
	cy = cy + 12

	-- Tell text (always shown — replaces direct "Intent:" display)
	if c.tell then
		love.graphics.setColor(0.55, 0.55, 0.55, 0.7)
		love.graphics.print("\"" .. c.tell .. "\"", lx, cy)
		cy = cy + 18
	end

	-- Scout bonus indicator
	if c.scout_bonus and c.scout_bonus > 0 then
		love.graphics.setColor(0.7, 0.75, 0.7, 0.8)
		love.graphics.print("[Scout +" .. c.scout_bonus .. "]", lx, cy)
		cy = cy + 18
	end

	-- Scout observation (if player scouted this turn)
	if c.scout_observation then
		local sc = SCOUT_COLORS[c.scout_tier] or SCOUT_COLORS.read
		love.graphics.setColor(sc)
		love.graphics.print(c.scout_observation, lx, cy)
		cy = cy + 18
	end

	-- Knowledge discovery notification (new fact this turn)
	if c.new_fact_text then
		love.graphics.setColor(0.6, 0.85, 0.6, 0.85)
		love.graphics.print("New Observation:", lx, cy)
		cy = cy + 15
		love.graphics.setColor(0.7, 0.9, 0.7, 0.9)
		love.graphics.print(c.new_fact_text, lx + 12, cy)
		cy = cy + 18
	end

	-- Insight mode: show direct intent (temporary perfect information)
	if c.insight_turns and c.insight_turns > 0 and c.enemy_intent then
		love.graphics.setColor(0.85, 0.8, 0.65, 0.8)
		love.graphics.print(
			"Insight: " .. c.insight_turns,
			lx,
			cy
		)
		cy = cy + 16

		local intent_label = c.enemy_intent:gsub("_", " ")
		intent_label = intent_label:gsub("^%l", string.upper)

		love.graphics.setColor(0.85, 0.8, 0.65, 1)
		love.graphics.print(
			"Intent: " .. intent_label,
			lx,
			cy
		)
		cy = cy + 18
	end

	-- Observed facts (persistent knowledge from player registry)
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
			cy = cy + 4
			love.graphics.setColor(0.55, 0.6, 0.65, 0.6)
			love.graphics.print("Observed:", lx, cy)
			cy = cy + 16

			love.graphics.setColor(0.5, 0.55, 0.6, 0.55)
			for _, ftext in ipairs(facts) do
				love.graphics.print(
					"• " .. ftext,
					lx + 12,
					cy
				)
				cy = cy + 15
			end
		end
	end

	-- Trial modifier
	if c.modifier then
		local names = {
			wounds = "Trial of Wounds",
			fury = "Trial of Fury",
			shadows = "Trial of Shadows",
		}
		love.graphics.setColor(0.55, 0.55, 0.55, 0.55)
		love.graphics.print(
			names[c.modifier] or "",
			w - 40 - 170,
			py + 20
		)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
