local M = {}

function M.start(player, enemy, modifier)
	local encounter = {
		enemy = enemy,
		player_hp = player.stats.vitality,
		enemy_hp = enemy.hp,
		modifier = modifier,

		enemy_intent = nil,
		brace_active = false,

		tell = nil,
		scout_bonus = 0,
		insight_turns = 0,
		scout_observation = nil,
		scout_tier = nil,
		new_fact_text = nil,
	}

	if modifier == "wounds" then
		encounter.player_hp = math.ceil(encounter.player_hp / 2)
	elseif modifier == "fury" then
		encounter.enemy_hp = encounter.enemy_hp + 2
	end

	return encounter
end

function M.finish(encounter, player, won)
	if won then
		encounter.enemy.hp = 0
	end

	player.stats.vitality =
		encounter.player_hp
end

return M
