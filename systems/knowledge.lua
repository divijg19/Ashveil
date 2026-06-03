local M = {}

local ARCHETYPE_FACTS = {
	brute = {
		favors_heavy = { text = "Favors heavy, powerful strikes.", discovered = false },
		recovers_wounded = { text = "Becomes more defensive when wounded.", discovered = false },
		predictable_wounded = { text = "Withstands significant punishment before faltering.", discovered = false },
	},
	stalker = {
		rarely_defends = { text = "Rarely takes a defensive stance.", discovered = false },
		relentless = { text = "Strikes relentlessly.", discovered = false },
		no_recovery = { text = "Favors offense over recovery.", discovered = false },
	},
	watcher = {
		patient = { text = "Prefers patient, measured actions.", discovered = false },
		swift_recovery = { text = "Recovers quickly from harm.", discovered = false },
		wounded_retreat = { text = "Becomes increasingly defensive when wounded.", discovered = false },
	},
	fanatic = {
		aggressive = { text = "Rarely retreats once committed.", discovered = false },
		relentless_fury = { text = "Becomes increasingly reckless when cornered.", discovered = false },
		reckless = { text = "Predictably aggressive.", discovered = false },
	},
}

function M.init(player)
	player.knowledge = {}
	for arch, facts in pairs(ARCHETYPE_FACTS) do
		player.knowledge[arch] = {
			encounters = 0,
			facts = {},
		}
		for key, fact in pairs(facts) do
			player.knowledge[arch].facts[key] = {
				text = fact.text,
				discovered = false,
			}
		end
	end
end

function M.add_encounter(player, archetype)
	if player.knowledge and player.knowledge[archetype] then
		player.knowledge[archetype].encounters =
			player.knowledge[archetype].encounters + 1
	end
end

function M.discover(player, archetype, key)
	if not player.knowledge
		or not player.knowledge[archetype]
		or not player.knowledge[archetype].facts[key]
	then
		return false
	end
	player.knowledge[archetype].facts[key].discovered = true
	return true
end

function M.undiscovered_facts(player, archetype)
	local result = {}
	if not player.knowledge or not player.knowledge[archetype] then
		return result
	end
	for key, fact in pairs(player.knowledge[archetype].facts) do
		if not fact.discovered then
			table.insert(result, key)
		end
	end
	return result
end

function M.fact_text(archetype, key)
	if ARCHETYPE_FACTS[archetype] and ARCHETYPE_FACTS[archetype][key] then
		return ARCHETYPE_FACTS[archetype][key].text
	end
	return ""
end

function M.fact_count(archetype)
	local count = 0
	if ARCHETYPE_FACTS[archetype] then
		for _ in pairs(ARCHETYPE_FACTS[archetype]) do
			count = count + 1
		end
	end
	return count
end

function M.discovered_count(player, archetype)
	local count = 0
	if player.knowledge and player.knowledge[archetype] then
		for _, fact in pairs(player.knowledge[archetype].facts) do
			if fact.discovered then
				count = count + 1
			end
		end
	end
	return count
end

function M.mastered(player, archetype)
	local entry = player.knowledge[archetype]
	if not entry or entry.encounters < 10 then
		return false
	end
	for _, fact in pairs(entry.facts) do
		if not fact.discovered then
			return false
		end
	end
	return true
end

return M
