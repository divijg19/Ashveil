local M = {}

function M.roll(game, room)
	local chance = 5

	if room.landmark then
		chance = chance + 10
	end

	chance = chance + math.min(game.floor, 10)

	chance = chance + game.player.stats.perception

	local anomaly = game.anomaly
	if anomaly
		and (anomaly.type == "silent" or anomaly.type == "dead")
	then
		chance = math.floor(chance / 2)
	end

	return love.math.random() * 100 < chance
end

function M.spawn(game, room, config)
	local x = config.x or room.center.x
	local y = config.y or room.center.y

	for attempt = 1, 10 do
		if game.map[y]
			and game.map[y][x]
			and game.map[y][x] == "."
		then
			break
		end

		x = love.math.random(
			room.x + 1,
			room.x + room.w - 2
		)
		y = love.math.random(
			room.y + 1,
			room.y + room.h - 2
		)
	end

	if not (game.map[y]
		and game.map[y][x]
		and game.map[y][x] == ".")
	then
		x = room.center.x
		y = room.center.y
	end

	local prop = {
		x = x,
		y = y,
		type = config.type,
		poi = {
			state = "active",
			tags = config.tags or {"discovery"},
			interaction = {
				action = config.action or "Open",
				event_type = config.event_type,
			},
			inspect = config.inspect or "You notice something unusual.",
		},
	}

	table.insert(game.props, prop)

	return prop
end

function M.complete(poi)
	if poi and poi.poi then
		poi.poi.state = "completed"
	end
end

return M
