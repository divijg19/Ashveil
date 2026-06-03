local M = {}

local DC_BASELINE = 11

function M.roll(bonus, dc)
	dc = dc or DC_BASELINE
	local result = love.math.random(1, 20) + (bonus or 0)
	local margin = result - dc

	local level = "glimpse"
	if margin >= 10 then
		level = "revelation"
	elseif margin >= 5 then
		level = "insight"
	elseif margin >= 0 then
		level = "understand"
	elseif margin >= -5 then
		level = "read"
	end

	return {
		level = level,
		result = result,
		margin = margin,
	}
end

return M
