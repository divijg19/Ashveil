local Entities = require("Engine.runtime.entities")
local Props = require("Engine.runtime.props")
local Discovery = require("Engine.runtime.discovery")

local Threshold = require("Engine.runtime.milestones.threshold")
local EchoChamber = require("Engine.runtime.milestones.echo_chamber")
local WoundAnomaly = require("Engine.runtime.milestones.wound_anomaly")
local HeartBelow = require("Engine.runtime.milestones.heart_below")
local Variants = require("Engine.runtime.variants")

local M = {}

function M.populate(game, rooms, compositions, anomaly)
	local silent = anomaly
		and (anomaly.type == "silent"
			or anomaly.type == "dead")

	local dead = anomaly
		and anomaly.type == "dead"

	if not silent then
		for i = 2, #rooms do
			local room = rooms[i]
			local archetype

			if room.type == "arena" then
				if love.math.random() < 0.70 then
					archetype = "fanatic"
				else
					archetype = Entities.random_archetype()
				end
			end

			Entities.spawn_enemy(
				game.enemies,
				room,
				archetype
			)

		-- Variant roll for non-sentinel enemies
		local last = game.enemies[#game.enemies]
		if last
			and last.archetype ~= "sentinel"
		then
			local variant_id =
				Variants.roll_variant(
					game.floor
				)
			if variant_id then
				last.variant = variant_id
			end
		end
	end
	end

	local is_echo = anomaly
		and anomaly.type == "echo"

	for i = 2, #rooms do
		local room = rooms[i]
		local items = nil

		if is_echo and love.math.random() < 0.35 then
			items = compositions.echo(room)

		elseif room.type == "quiet" then
			items = compositions.quiet(room, game.floor)

		elseif room.type == "shrine" then
			items = compositions.shrine(room)

		elseif room.type == "crypt" then
			items = compositions.crypt(room)

		elseif room.type == "arena" then
			items = compositions.arena(room)

		elseif room.type == "ruin" then
			items = compositions.ruin(room)

		elseif room.type == "hall" then
			items = compositions.hall(room, game.floor)
		end

		if items then
			if silent and #items > 0 then
				local keep = dead and 0.1 or 0.3
				local filtered = {}

				for _, item in ipairs(items) do
					if love.math.random() < keep then
						table.insert(filtered, item)
					end
				end

				items = filtered
			end

			Props.add_many(game.props, items)
		end
	end

	if is_echo then
		for i = 2, #rooms do
			if love.math.random() < 0.15 then
				local echo = compositions.echo_light(rooms[i])
				Props.add_many(game.props, echo)
			end
		end
	end

	M.spawn_finds(game, rooms, anomaly)

	M.tag_pois(game, rooms, anomaly)

	-- Milestone post-processing
	for _, room in ipairs(rooms) do
		if room.type == "threshold" then
			Threshold.setup(game, room)
		end

		if game.floor == 10 and room.type ~= "quiet" then
			-- Use first non-quiet room for echo chamber setup
			if not game._milestone_echo_used then
				-- Clear existing enemies in this room
				local cx, cy = room.center.x, room.center.y
				for i = #game.enemies, 1, -1 do
					if game.enemies[i].x == cx and game.enemies[i].y == cy then
						table.remove(game.enemies, i)
					end
				end
				EchoChamber.setup(game, room)
				game._milestone_echo_used = true
			end
		end
	end

	game._milestone_echo_used = nil

	if game.floor == 15 then
		WoundAnomaly.setup(game)
	end

	if game.floor == 20 then
		HeartBelow.setup(game)
	end
end

function M.spawn_finds(game, rooms, anomaly)
	local silent = anomaly
		and (anomaly.type == "silent"
			or anomaly.type == "dead")

	if silent then
		return
	end

	for _, room in ipairs(rooms) do
		if room.type ~= "threshold" then
			local roll = love.math.random()

			if roll < 0.05 then
				Discovery.spawn(game, room, {
					type = "fallen_explorer",
					action = "Search",
					event_type = "fallen_explorer",
					inspect = "The explorer did not make it further.",
					tags = {"remains"},
				})
			elseif roll < 0.12 then
				Discovery.spawn(game, room, {
					type = "torn_satchel",
					action = "Search",
					event_type = "torn_satchel",
					inspect = "A weathered pack. Something glints inside.",
					tags = {"treasure"},
				})
			end
		end
	end

	for _, room in ipairs(rooms) do
		if room.type == "shrine" and love.math.random() < 0.15 then
			Discovery.spawn(game, room, {
				type = "pilgrim_pack",
				action = "Search",
				event_type = "pilgrim_pack",
				inspect = "A pilgrim's pack, untouched for years.",
				tags = {"treasure"},
			})
		end
	end

	for _, room in ipairs(rooms) do
		if room.type == "shrine" and love.math.random() < 0.10 then
			Discovery.spawn(game, room, {
				type = "forgotten_shrine",
				action = "Investigate",
				event_type = "forgotten_shrine",
				inspect = "The shrine has collapsed. Only a fractured idol remains.",
				tags = {"relic"},
			})
		end
	end

	for _, room in ipairs(rooms) do
		if room.landmark and love.math.random() < 0.02 then
			Discovery.spawn(game, room, {
				type = "hidden_cache",
				action = "Search",
				event_type = "hidden_cache",
				inspect = "The stonework is disturbed. Something is hidden here.",
				tags = {"treasure"},
			})
		end
	end

	for _, room in ipairs(rooms) do
		if room.type ~= "threshold" and love.math.random() < 0.03 then
			Discovery.spawn(game, room, {
				type = "remains",
				action = "Search",
				event_type = "watcher_remains",
				inspect = "The watcher's remains still hold a trace of observation.",
				tags = {"remains"},
			})
		end
	end

	for _, room in ipairs(rooms) do
		if room.type == "crypt" and love.math.random() < 0.06 then
			Discovery.spawn(game, room, {
				type = "remains",
				action = "Search",
				event_type = "charred_remains",
				inspect = "The fire was not natural. Something endured it.",
				tags = {"remains"},
			})
		end
	end
end

function M.tag_pois(game, rooms, anomaly)
	local silent = anomaly
		and (anomaly.type == "silent"
			or anomaly.type == "dead")

	for i = 2, #rooms do
		local room = rooms[i]

		if room.type == "shrine" then
			local altars = Props.find_by_type(game.props, "altar")
			for _, p in ipairs(altars) do
				if not p.poi then
					p.poi = {
						state = "active",
						tags = {"utility"},
						interaction = {
							action = "Pray",
							event_type = "shrine_altar",
						},
					}
				end
			end

			local seals = Props.find_by_type(game.props, "seal")
			for _, p in ipairs(seals) do
				if not p.poi and not silent then
					p.poi = {
						state = "active",
						tags = {"trial"},
						interaction = {
							action = "Investigate",
							event_type = "shrine_seal",
						},
						inspect = "The grooves appear unfinished. The markings seem recent.",
					}
				end
			end

			if room.landmark and Discovery.roll(game, room) then
				local cx = room.center.x
				local cy = room.center.y
				local dx = love.math.random(2, 4)
				local dy = love.math.random(2, 4)
				if love.math.random() < 0.5 then
					dx = -dx
				end
				if love.math.random() < 0.5 then
					dy = -dy
				end

				Discovery.spawn(game, room, {
					x = cx + dx,
					y = cy + dy,
					type = "reliquary",
					action = "Open",
					event_type = "shrine_reliquary",
					inspect = "A hidden chamber reveals itself. Ancient relics lie within.",
					tags = {"discovery"},
				})
			end

		elseif room.type == "crypt" then
			local sarcophagi = Props.find_by_type(game.props, "sarcophagus")
			local tagged = false
			for _, p in ipairs(sarcophagi) do
				if not tagged and not p.poi then
					p.poi = {
						state = "active",
						tags = {"utility"},
						interaction = {
							action = "Open",
							event_type = "crypt_sarcophagus",
						},
					}
					tagged = true
				end
			end

			local tombs = Props.find_by_type(game.props, "tomb")
			for _, p in ipairs(tombs) do
				if not p.poi and not silent then
					p.poi = {
						state = "active",
						tags = {"curiosity"},
						interaction = {
							action = "Investigate",
							event_type = "crypt_tomb",
						},
						inspect = "The seal has been broken. Claw marks scar the stone.",
					}
				end
			end

			if room.landmark and Discovery.roll(game, room) then
				local cx = room.center.x
				local cy = room.center.y

				Discovery.spawn(game, room, {
					x = cx + love.math.random(-2, 2),
					y = cy + love.math.random(-2, 2),
					type = "hidden_passage",
					action = "Enter Passage",
					event_type = "hidden_passage",
					inspect = "A passage has been concealed behind the stone.",
					tags = {"discovery"},
				})
			end

		elseif room.type == "arena" then
			local seals = Props.find_by_type(game.props, "seal")
			for _, p in ipairs(seals) do
				if not p.poi then
					p.poi = {
						state = "active",
						tags = {"utility"},
						interaction = {
							action = "Enter Arena",
							event_type = "arena_challenge",
						},
					}
				end
			end

			if game.floor >= 3 and not silent then
				local cx = room.center.x
				local cy = room.center.y

				Discovery.spawn(game, room, {
					x = cx + love.math.random(-3, 3),
					y = cy + love.math.random(-3, 3),
					type = "blood_seal",
					action = "Accept Trial",
					event_type = "arena_trial",
					inspect = "The seal pulses with a dark rhythm. Blood rituals etched its surface.",
					tags = {"trial"},
				})
			end

		elseif room.type == "ruin" then
			local rubble = Props.find_by_type(game.props, "rubble")
			local tagged = false
			for _, p in ipairs(rubble) do
				if not tagged and not p.poi then
					p.poi = {
						state = "active",
						tags = {"utility"},
						interaction = {
							action = "Search",
							event_type = "ruin_debris",
						},
					}
					tagged = true
				end
			end

			local statues = Props.find_by_type(game.props, "statue")
			for _, p in ipairs(statues) do
				if not p.poi and not silent then
					p.poi = {
						state = "active",
						tags = {"curiosity"},
						interaction = {
							action = "Examine",
							event_type = "ruin_statue",
						},
						inspect = "The face has been removed. A faint glyph remains visible on the base.",
					}
				end
			end

		elseif room.type == "hall" then
			local braziers = Props.find_by_type(game.props, "brazier")
			local tagged = false
			for _, p in ipairs(braziers) do
				if not tagged and not p.poi then
					p.poi = {
						state = "active",
						tags = {"utility"},
						interaction = {
							action = "Light",
							event_type = "hall_brazier",
						},
					}
					tagged = true
				end
			end

			local doors = Props.find_by_type(game.props, "side_door")
			for _, p in ipairs(doors) do
				if not p.poi and not silent then
					p.poi = {
						state = "active",
						tags = {"curiosity"},
						interaction = {
							action = "Open Door",
							event_type = "side_door",
						},
						inspect = "A strange door stands where no door should be.",
					}
				end
			end
		end
	end
end

return M
