local M = {}

local MASTERY_ENCOUNTERS = 10

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
	sentinel = {
		ancient_memory = { text = "Fights with the memory of ages past.", discovered = false },
		unyielding = { text = "Rarely yields ground once engaged.", discovered = false },
		veil_touched = { text = "Draws strength from the Veil itself.", discovered = false },
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
		player.knowledge[arch].recognized_tier = "unknown"
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
	if not player.knowledge then
		return false
	end
	local entry = player.knowledge[archetype]
	if not entry or entry.encounters < MASTERY_ENCOUNTERS then
		return false
	end
	for _, fact in pairs(entry.facts) do
		if not fact.discovered then
			return false
		end
	end
	return true
end

function M.tier(player, archetype)
	if not player.knowledge or not player.knowledge[archetype] then
		return "unknown"
	end
	if M.mastered(player, archetype) then
		return "mastered"
	end
	if M.discovered_count(player, archetype) >= 1 then
		return "studied"
	end
	return "unknown"
end

function M.recognize(player, archetype)
	local tier = M.tier(player, archetype)
	if not player.knowledge or not player.knowledge[archetype] then
		return nil
	end
	local entry = player.knowledge[archetype]
	if tier == entry.recognized_tier then
		return nil
	end
	entry.recognized_tier = tier
	if tier == "studied" then
		return "You have begun to learn this archetype."
	elseif tier == "mastered" then
		return "You know the "
			.. archetype:gsub("^%l", string.upper)
			.. " completely."
	end
	return nil
end

return M
