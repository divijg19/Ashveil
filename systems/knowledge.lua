local M = {}

local ARCHETYPE_FACTS = {
	brute = {
		favors_heavy = { text = "Favors heavy attacks.", discovered = false },
		recovers_after = { text = "Often recovers after exertion.", discovered = false },
		predictable_wounded = { text = "Becomes predictable when wounded.", discovered = false },
	},
	stalker = {
		rarely_defends = { text = "Rarely takes a defensive stance.", discovered = false },
		relentless = { text = "Attacks relentlessly when closing.", discovered = false },
		evasive = { text = "Becomes evasive when threatened.", discovered = false },
	},
	watcher = {
		patient = { text = "Prefers patient, measured actions.", discovered = false },
		swift_recovery = { text = "Recovers quickly from harm.", discovered = false },
		observant = { text = "Watches and waits for openings.", discovered = false },
	},
	fanatic = {
		aggressive = { text = "Favors overwhelming offense.", discovered = false },
		relentless_fury = { text = "Pressures harder as the fight continues.", discovered = false },
		reckless = { text = "Leaves openings in its aggression.", discovered = false },
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

function M.current_facts(player, archetype)
	local result = {}
	if not player.knowledge or not player.knowledge[archetype] then
		return result
	end
	for key, fact in pairs(player.knowledge[archetype].facts) do
		if fact.discovered then
			table.insert(result, fact.text)
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

return M
