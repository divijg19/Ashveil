local Knowledge = require("systems.knowledge")

local M = {}

local SCOUT_TIERS = {
	brute = {
		glimpse = "The creature seems poised for violence.",
		read = "You notice tension concentrated in its stance.",
		understand = "Its stance suggests an attack is coming.",
		insight = "You recall Brutes favor overwhelming force.",
	},
	stalker = {
		glimpse = "The creature's intentions are difficult to track.",
		read = "You catch a flicker of movement in its posture.",
		understand = "Its movements suggest it's preparing to strike.",
		insight = "You recall Stalkers rarely commit to defense.",
	},
	watcher = {
		glimpse = "The creature offers little to read.",
		read = "You notice a subtle shift in its gaze.",
		understand = "Its patience suggests a measured response.",
		insight = "You recall Watchers favor recovery and patience.",
	},
	fanatic = {
		glimpse = "The creature's fervor clouds your reading.",
		read = "You notice the tension in its grip.",
		understand = "Its aggression suggests an incoming assault.",
		insight = "You recall Fanatics commit heavily to offense.",
	},
}

function M.resolve(combat, player, roll_level)
	local arch = combat.enemy.archetype
	local templates = SCOUT_TIERS[arch] or SCOUT_TIERS.brute
	local msg = ""

	if roll_level == "glimpse" then
		msg = templates.glimpse
	elseif roll_level == "read" then
		msg = templates.read
	elseif roll_level == "understand" then
		msg = templates.understand
	elseif roll_level == "insight" then
		msg = templates.insight
	elseif roll_level == "revelation" then
		msg = "You see through the " .. arch .. " completely. " .. templates.understand
	end

	-- Check for fact discovery at insight+
	local new_fact_text = nil
	if roll_level == "insight" or roll_level == "revelation" then
		local facts = Knowledge.undiscovered_facts(player, arch)
		if #facts > 0 then
			local key = facts[1]
			Knowledge.discover(player, arch, key)
			new_fact_text = Knowledge.fact_text(arch, key)
			msg = msg .. " You observe: " .. new_fact_text
		end
	end

	local insight_turns = 0
	if roll_level == "revelation" then
		insight_turns = 2
	end

	return {
		message = msg,
		tier = roll_level,
		insight_turns = insight_turns,
		new_fact_text = new_fact_text,
	}
end

return M
