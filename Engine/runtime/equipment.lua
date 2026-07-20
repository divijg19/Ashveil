local MessagePanel = require("Engine.runtime.message_panel")

local WEAPON_DEFS = {
	surveyors_knife = {
		id = "surveyors_knife",
		name = "Surveyor's Knife",
		short = "Knife",
		kind = "weapon",
		desc = "+1 Attack. A blade worn smooth by unanswered questions.",
		effect = { attack = 1 },
		inspect = "The edge tells stories of paths taken and not taken.",
	},
	pilgrims_staff = {
		id = "pilgrims_staff",
		name = "Pilgrim's Staff",
		short = "Staff",
		kind = "weapon",
		desc = "+1 Veil Affinity. Worn by those who walk until the end.",
		effect = { veil_affinity = 1 },
		inspect = "Every step wears it down. Every step makes it stronger.",
	},
	veil_hook = {
		id = "veil_hook",
		name = "Veil Hook",
		short = "Hook",
		kind = "weapon",
		desc = "+1 Scout. A hooked blade for pulling back what lies beneath.",
		effect = { scout = 1 },
		inspect = "It trembles when the veil grows thin.",
	},
	wardens_blade = {
		id = "wardens_blade",
		name = "Warden's Blade",
		short = "Blade",
		kind = "weapon",
		desc = "+1 Variant Damage. Forged to end what should not persist.",
		effect = { variant_damage = 1 },
		inspect = "It remembers every sentinel it was meant to be.",
	},
	rusted_machete = {
		id = "rusted_machete",
		name = "Rusted Machete",
		short = "Machete",
		kind = "weapon",
		desc = "+1 Attack, -1 Scout. Heavy, but it cuts.",
		effect = { attack = 1, scout = -1 },
		inspect = "The rust is not age. It is thirst.",
	},
}

local CHARM_DEFS = {
	hollow_coin = {
		id = "hollow_coin",
		name = "Hollow Coin",
		short = "Coin",
		kind = "charm",
		desc = "+10% Gold gained. A coin with nothing at its center.",
		effect = { gold_mult = 0.1 },
		inspect = "Some say it was the first currency. Others say it never was.",
	},
	prayer_knot = {
		id = "prayer_knot",
		name = "Prayer Knot",
		short = "Knot",
		kind = "charm",
		desc = "+1 Veil Affinity. A knot tied in the moment between breaths.",
		effect = { veil_affinity = 1 },
		inspect = "The threads lead nowhere. That is the point.",
	},
	echo_talisman = {
		id = "echo_talisman",
		name = "Echo Talisman",
		short = "Talisman",
		kind = "charm",
		desc = "+1 Scout. It hums with the voices of forgotten explorers.",
		effect = { scout = 1 },
		inspect = "Hold it to your ear and you will hear where you are going.",
	},
	ash_charm = {
		id = "ash_charm",
		name = "Ash Charm",
		short = "Charm",
		kind = "charm",
		desc = "+1 Max Vitality. A fragment of something that endured the fire.",
		effect = { vitality = 1 },
		inspect = "It is warm. It is still burning.",
	},
}

local ALL_DEFS = {}
for id, def in pairs(WEAPON_DEFS) do ALL_DEFS[id] = def end
for id, def in pairs(CHARM_DEFS) do ALL_DEFS[id] = def end

local INSTANCE_COUNTER = 0

local M = {}

function M.def(id)
	return ALL_DEFS[id]
end

function M.weapon_defs()
	return WEAPON_DEFS
end

function M.charm_defs()
	return CHARM_DEFS
end

function M.all_defs()
	return ALL_DEFS
end

function M.find_instance(player, instance_id)
	if not player or not player.inventory or not player.inventory.equipment then
		return nil
	end
	for _, instance in ipairs(player.inventory.equipment) do
		if instance.instance_id == instance_id then
			return instance
		end
	end
	return nil
end

function M.has_id(player, id)
	if not player or not player.inventory or not player.inventory.equipment then
		return false
	end
	for _, inst in ipairs(player.inventory.equipment) do
		if inst.id == id then return true end
	end
	return false
end

function M.equipped_instance(player, slot)
	if not player or not player.equipment then return nil end
	local instance_id = player.equipment[slot]
	if not instance_id then return nil end
	return M.find_instance(player, instance_id)
end

function M.grant(player, id, floor, region, source)
	local def = ALL_DEFS[id]
	if not def or not player or not player.inventory then
		return nil
	end

	-- v0.8.7: refuse duplicate id (recovered objects, not loot)
	if M.has_id(player, id) then
		return nil
	end

	INSTANCE_COUNTER = INSTANCE_COUNTER + 1
	player.inventory.equipment = player.inventory.equipment or {}
	-- v0.8.7: sequential counter. When save/load lands, swap to
	-- tostring(love.timer.getTime()) .. "_" .. INSTANCE_COUNTER for unique-across-sessions IDs.
	local instance = {
		id = id,
		instance_id = INSTANCE_COUNTER,
		floor = floor,
		region = region,
		source = source,
	}
	table.insert(player.inventory.equipment, instance)
	return instance
end

function M.compute_mods(player)
	local mods = {
		attack = 0,
		scout = 0,
		veil_affinity = 0,
		vitality = 0,
		gold_mult = 0,
		variant_damage = 0,
	}
	if not player then
		return mods
	end
	for slot, instance_id in pairs(player.equipment or {}) do
		local instance = M.find_instance(player, instance_id)
		if instance then
			local def = ALL_DEFS[instance.id]
			if def and def.effect then
				for k, v in pairs(def.effect) do
					mods[k] = (mods[k] or 0) + v
				end
			end
		end
	end
	return mods
end

function M.effective_max_vitality(player)
	local base = player.base_max_vitality or 10
	return base + (player.equipment_mods and player.equipment_mods.vitality or 0)
end

function M.equip(player, slot, instance_id)
	if not player or not player.equipment then return false end
	local item = M.find_instance(player, instance_id)
	if not item then return false end
	local def = ALL_DEFS[item.id]
	if not def or def.kind ~= slot then return false end
	player.equipment[slot] = instance_id
	player.equipment_mods = M.compute_mods(player)
	local name = def.name or item.id
	MessagePanel.push_passive("Equipped: " .. name)
	return true
end

function M.unequip(player, slot)
	if not player or not player.equipment then return false end
	if not player.equipment[slot] then return false end
	local instance = M.find_instance(player, player.equipment[slot])
	local def = instance and ALL_DEFS[instance.id]
	player.equipment[slot] = nil
	player.equipment_mods = M.compute_mods(player)
	if def and def.name then
		MessagePanel.push_passive("Unequipped: " .. def.name)
	end
	return true
end

function M.short_name(id)
	local def = ALL_DEFS[id]
	return def and def.short or "???"
end

function M.has_equipped(player, id)
	if not player or not player.equipment then return false end
	for slot, instance_id in pairs(player.equipment) do
		local instance = M.find_instance(player, instance_id)
		if instance and instance.id == id then
			return true
		end
	end
	return false
end

return M
