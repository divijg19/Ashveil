local Relics = require("Engine.runtime.relics")
local Artifacts = require("Engine.runtime.artifacts")
local Consumables = require("Engine.runtime.consumables")

local STANCES = {"guarded", "aggressive", "focused"}
local STANCE_LABELS = {
	guarded = "Guarded     (-1 damage taken)",
	aggressive = "Aggressive  (+1 dealt, +1 taken)",
	focused = "Focused     (+3 Scout)",
}

local BLESSING_SHORT = {
	["Blessing of Ash"] = "RES",
	["Blessing of Sight"] = "PER",
	["Blessing of Might"] = "STR",
	["Blessing of Discovery"] = "DISC",
}

local DISCOVERY_LABELS = {
	fallen_explorer = "Fallen Explorer",
	torn_satchel = "Torn Satchel",
	pilgrim_pack = "Pilgrim Pack",
	hidden_cache = "Hidden Cache",
	hidden_cache_scout = "Scout Cache",
	forgotten_shrine = "Forgotten Shrine",
	crypt_sarcophagus = "Sarcophagus",
	ruin_debris = "Rubble",
	ruin_statue = "Statue",
	side_door = "Side Door",
	shrine_altar = "Shrine Altar",
	shrine_seal = "Shrine Seal",
	shrine_reliquary = "Reliquary",
	hidden_passage = "Hidden Passage",
	hall_brazier = "Brazier",
	arena_challenge = "Arena",
	arena_trial = "Trial",
	crypt_tomb = "Tomb",
}

local M = {}

function M.draw(state)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local p = state.player

	-- backdrop
	love.graphics.setColor(0, 0, 0, 0.85)
	love.graphics.rectangle("fill", 0, 0, w, h)

	-- panel
	local pw = 360
	local ph = h - 80
	local px = (w - pw) / 2
	local py = 40

	love.graphics.setColor(0.15, 0.15, 0.15, 1)
	love.graphics.rectangle("fill", px, py, pw, ph)
	love.graphics.setColor(0.4, 0.4, 0.4, 1)
	love.graphics.rectangle("line", px, py, pw, ph)

	local cx = px + 20
	local lcx = cx
	local rcx = px + 190
	local line_h = 20

	-- title
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("=== CHARACTER ===", lcx, py + 20)

	local lcy = py + 50
	local rcy = py + 50

	-- ============================
	-- LEFT COLUMN — Character
	-- ============================

	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Character --", lcx, lcy)
	lcy = lcy + line_h

	-- stats
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print("Vitality: " .. p.stats.vitality, lcx, lcy)
	lcy = lcy + line_h
	love.graphics.print("Strength:  " .. p.stats.strength, lcx, lcy)
	lcy = lcy + line_h
	love.graphics.print("Resolve:   " .. p.stats.resolve, lcx, lcy)
	lcy = lcy + line_h
	love.graphics.print("Perception: " .. p.stats.perception, lcx, lcy)
	lcy = lcy + line_h
	love.graphics.print("Agility:    " .. p.stats.agility, lcx, lcy)
	lcy = lcy + line_h + 8

	-- blessings (aggregated)
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Blessings --", lcx, lcy)
	lcy = lcy + line_h

	if #p.blessings == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", lcx, lcy)
		lcy = lcy + line_h
	else
		local counts = {}
		for _, name in ipairs(p.blessings) do
			counts[name] = (counts[name] or 0) + 1
		end
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
		for name, count in pairs(counts) do
			local short = BLESSING_SHORT[name] or name
			if count > 1 then
				love.graphics.print(short .. " x" .. count, lcx, lcy)
			else
				love.graphics.print(short, lcx, lcy)
			end
			lcy = lcy + line_h
		end
	end

	lcy = lcy + 8

	-- stance selector
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Stance --", lcx, lcy)
	lcy = lcy + line_h

	local sheet = state.character_sheet
	local sel = sheet and sheet.selection or 1

	for i, s in ipairs(STANCES) do
		local label = STANCE_LABELS[s]
		local is_selected = p.stance == s
		local is_highlighted = sel == i

		if is_highlighted then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(">", lcx, lcy)
			love.graphics.setColor(0.9, 0.9, 0.7, 1)
		elseif is_selected then
			love.graphics.setColor(0.7, 0.9, 0.7, 1)
			love.graphics.print("*", lcx, lcy)
		else
			love.graphics.setColor(0.6, 0.6, 0.6, 1)
		end

		love.graphics.print(label, lcx + 16, lcy)
		lcy = lcy + line_h
	end

	lcy = lcy + 8

	-- gold
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Gold --", lcx, lcy)
	lcy = lcy + line_h
	love.graphics.setColor(0.75, 0.75, 0.75, 1)
	love.graphics.print(p.gold, lcx, lcy)
	lcy = lcy + line_h

	-- ============================
	-- RIGHT COLUMN — Discoveries
	-- ============================

	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Discoveries --", rcx, rcy)
	rcy = rcy + line_h

	-- relics (compact: name only)
	local relic_count = Relics.count(p)
	if relic_count == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", rcx, rcy)
		rcy = rcy + line_h
	else
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
		local shown = 0
		local max_shown = 8
		for id in pairs(p.relics) do
			if shown >= max_shown then
				break
			end
			local def = Relics.def(id)
			if def then
				if def.symbol then
					love.graphics.print(def.symbol, rcx, rcy)
					love.graphics.print(def.name, rcx + 16, rcy)
				else
					love.graphics.print(def.name, rcx, rcy)
				end
				rcy = rcy + line_h
				shown = shown + 1
			end
		end
		if relic_count > max_shown then
			love.graphics.setColor(0.5, 0.5, 0.5, 1)
			love.graphics.print("+" .. (relic_count - max_shown) .. " more...", rcx, rcy)
			rcy = rcy + line_h
		end
	end

	rcy = rcy + 4

	-- artifacts (one-line with provenance)
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Artifacts --", rcx, rcy)
	rcy = rcy + line_h

	local artifact_count = Artifacts.count(p)
	if artifact_count == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", rcx, rcy)
		rcy = rcy + line_h
	else
		for id, meta in Artifacts.each(p) do
			local def = Artifacts.def(id)
			if def then
				love.graphics.setColor(0.75, 0.75, 0.75, 1)
				love.graphics.print(def.name, rcx, rcy)
				rcy = rcy + line_h

				if meta and meta.legacy then
					love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
					love.graphics.print("Before Records", rcx + 8, rcy)
					rcy = rcy + line_h
				elseif meta and meta.floor then
					love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
					love.graphics.print("F" .. meta.floor .. " - " .. meta.region, rcx + 8, rcy)
					rcy = rcy + line_h
				end
			end
		end
	end

	rcy = rcy + 4

	-- consumables (summarized)
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Consumables --", rcx, rcy)
	rcy = rcy + line_h

	local con_ids = {"bandage", "ration"}
	local has_any = false
	for _, cid in ipairs(con_ids) do
		local count = Consumables.count(p, cid)
		local def = Consumables.def(cid)
		if def and count > 0 then
			has_any = true
			love.graphics.setColor(0.75, 0.75, 0.75, 1)
			love.graphics.print(def.name .. " x" .. count, rcx, rcy)
			rcy = rcy + line_h
		end
	end
	if not has_any then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", rcx, rcy)
		rcy = rcy + line_h
	end

	rcy = rcy + 4

	-- key items
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Key Items --", rcx, rcy)
	rcy = rcy + line_h

	local ki_count = 0
	for _ in pairs(p.inventory.key_items or {}) do
		ki_count = ki_count + 1
	end
	if ki_count == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none)", rcx, rcy)
		rcy = rcy + line_h
	else
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
		for id in pairs(p.inventory.key_items) do
			love.graphics.print(id, rcx, rcy)
			rcy = rcy + line_h
		end
	end

	rcy = rcy + 4

	-- recent discoveries
	love.graphics.setColor(0.9, 0.9, 0.9, 1)
	love.graphics.print("-- Recent Discoveries --", rcx, rcy)
	rcy = rcy + line_h

	local log = p.discovery_log or {}
	if #log == 0 then
		love.graphics.setColor(0.5, 0.5, 0.5, 1)
		love.graphics.print("(none yet)", rcx, rcy)
		rcy = rcy + line_h
	else
		love.graphics.setColor(0.75, 0.75, 0.75, 1)
		local first_idx = math.max(1, #log - 4)
		for i = #log, first_idx, -1 do
			local label = DISCOVERY_LABELS[log[i]] or log[i]
			love.graphics.print(label, rcx, rcy)
			rcy = rcy + line_h
		end
	end

	-- footer (anchored to panel bottom)
	local footer_y = py + ph - 30
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.print("Press ESC to close", cx, footer_y)

	love.graphics.setColor(1, 1, 1, 1)
end

return M
