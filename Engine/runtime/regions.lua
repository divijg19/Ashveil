local M = {}

local REGIONS = {
	{ floor = 1,  name = "Upper Veil",   desc = "The Veil hangs thin here.",           milestone = false },
	{ floor = 5,  name = "Threshold",    desc = "You cross the Threshold.",             milestone = true  },
	{ floor = 6,  name = "Deep Veil",    desc = "The air grows heavy.",                 milestone = false },
	{ floor = 10, name = "Echo Chamber", desc = "The Veil remembers everything.",       milestone = true  },
	{ floor = 11, name = "Lower Veil",   desc = "The descent deepens.",                 milestone = false },
	{ floor = 15, name = "Wound of the Veil", desc = "The Veil is bleeding.",           milestone = true  },
	{ floor = 16, name = "Abyssal Veil", desc = "Silence presses from all sides.",      milestone = false },
	{ floor = 20, name = "Heart Below",  desc = "Something waits at the end.",          milestone = true  },
}

function M.for_floor(floor)
	local best = nil
	for _, r in ipairs(REGIONS) do
		if floor >= r.floor then
			best = r
		end
	end
	return best
end

function M.entered(prev_floor, next_floor)
	local prev = M.for_floor(prev_floor)
	local next_r = M.for_floor(next_floor)
	if prev and next_r and prev ~= next_r then
		return next_r
	end
	return nil
end

function M.is_milestone(floor)
	local r = M.for_floor(floor)
	return r and r.milestone and r.floor == floor
end

return M
