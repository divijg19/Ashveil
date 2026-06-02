local M = {}

function M.draw(state)
	local combat = state.combat
	if not combat then return end

	-- title
	love.graphics.print(
		"=== COMBAT ===",
		40,
		30
	)

	if combat.modifier then
		local names = {
			wounds = "Trial of Wounds",
			fury = "Trial of Fury",
			shadows = "Trial of Shadows",
		}
		love.graphics.print(names[combat.modifier], 40, 55)
	end

	-- player panel
	love.graphics.rectangle(
		"line",
		40,
		80,
		220,
		120
	)

	love.graphics.print(
		"ASHVEIL KNIGHT",
		60,
		100
	)

	love.graphics.print(
		"Vitality: " .. combat.player_hp,
		60,
		130
	)

	love.graphics.print(
		"Strength: " .. state.player.stats.strength,
		60,
		145
	)

	-- enemy panel
	love.graphics.rectangle(
		"line",
		340,
		80,
		220,
		120
	)

	love.graphics.print(
		"VEILBEAST",
		360,
		100
	)

	if combat.modifier == "shadows" then
		love.graphics.print(
			"HP: ???",
			360,
			130
		)
	else
		love.graphics.print(
			"HP: " .. combat.enemy_hp,
			360,
			130
		)
	end

	-- command box
	love.graphics.rectangle(
		"line",
		40,
		260,
		520,
		120
	)

	love.graphics.print(
		"[W / SPACE] Attack",
		60,
		290
	)

	love.graphics.print(
		"[Q] Guard",
		60,
		320
	)

	love.graphics.print(
		"[E] Skill",
		240,
		290
	)

	love.graphics.print(
		"[ESC] Flee",
		240,
		320
	)

	-- combat log
	love.graphics.print(
		state.log or "",
		40,
		410
	)
end

return M
