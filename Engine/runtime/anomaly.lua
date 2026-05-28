local M = {}

local BASE_CHANCE = 0.02
local FLOOR_SCALE = 0.008
local MAX_CHANCE = 0.18

local TYPES = {
	{ type = "silent",   weight = 30 },
	{ type = "geometry", weight = 30 },
	{ type = "echo",     weight = 25 },
	{ type = "dead",     weight = 15 },
}

function M.roll(floor)
	local chance =
		math.min(
			BASE_CHANCE
				+ floor * FLOOR_SCALE,
			MAX_CHANCE
		)

	if love.math.random() >= chance then
		return nil
	end

	local total = 0

	for _, t in ipairs(TYPES) do
		total = total + t.weight
	end

	local roll =
		love.math.random(total)

	local cumulative = 0

	for _, t in ipairs(TYPES) do
		cumulative =
			cumulative + t.weight

		if roll <= cumulative then
			return {
				type = t.type,
				floor = floor,
			}
		end
	end
end

return M
