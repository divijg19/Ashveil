local M = {}

local DIRS = {
	{ 0, -1 },
	{ 0, 1 },
	{ -1, 0 },
	{ 1, 0 },
}

function M.near(game)
	local px = game.player.x
	local py = game.player.y

	for _, d in ipairs(DIRS) do
		local nx = px + d[1]
		local ny = py + d[2]

		for _, p in ipairs(game.props) do
			if p.x == nx
				and p.y == ny
				and p.poi
				and p.poi.state == "active"
			then
				return p
			end
		end
	end

	return nil
end

function M.activate(poi)
	if not poi or not poi.poi then
		return nil
	end

	return poi.poi.interaction.event_type
end

function M.complete(prop)
	if prop then
		prop.state = "resolved"
		if prop.poi then
			prop.poi.state = "completed"
		end
	end
end

return M
