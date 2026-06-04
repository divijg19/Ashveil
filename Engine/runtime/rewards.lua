local M = {}

function M.vitality(player, amount)
	if player.buff_doubled then
		amount = amount * 2
		player.buff_doubled = nil
	end

	player.stats.vitality = player.stats.vitality + amount
end

function M.blessing(player, name)
	table.insert(player.blessings, name)
end

local GOLD_MESSAGES = {
	fallen_explorer    = "Several tarnished coins remain among the explorer's belongings.",
	pilgrim_pack       = "A small pouch of coins is tucked inside the pack.",
	torn_satchel       = "Coins spill from the torn satchel.",
	hidden_cache       = "Coins were hidden among the stones.",
	hidden_cache_scout = "Your observation reveals a stash concealed within the stonework.",
	shrine_altar       = "An offering of gold rests at the base.",
	ruin_debris        = "A single coin glints in the debris.",
	ruin_statue        = "You find gold near the statue's base.",
	side_door          = "A few coins lie scattered on the floor.",
	sentinel_cache     = "A cache of gold survives beneath the chamber.",
	sentinel_consolation = "The sentinel's chamber holds scattered gold.",
	reliquary          = "Scattered gold surrounds the reliquary.",
	forgotten_shrine   = "A few ancient coins lie amid the rubble.",
}

function M.gold(player, amount, source)
	player.gold = player.gold + amount
	return GOLD_MESSAGES[source] or "You find " .. amount .. " gold."
end

return M
