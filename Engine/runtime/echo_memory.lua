local M = {}

local MAX_MEMORIES = 4
local BASE_RECALL = 0.05
local FLOOR_RECALL = 0.005
local MAX_RECALL = 0.15

local function is_notable(room)
	return room.landmark
		or room.type == "shrine"
		or room.type == "crypt"
		or room.type == "arena"
end

function M.mutate(sig)
	local m = {}

	for k, v in pairs(sig) do
		m[k] = v
	end

	if love.math.random() < 0.4 then
		m.w = math.max(
			4,
			m.w + love.math.random(-2, 2)
		)

		m.h = math.max(
			4,
			m.h + love.math.random(-2, 2)
		)
	end

	if love.math.random() < 0.3 then
		m.landmark = false
	end

	return m
end

function M.remember(room, memories)
	if not is_notable(room)
		or not memories
	then
		return
	end

	local sig = {
		type = room.type,
		w = room.w,
		h = room.h,
		landmark = room.landmark,
	}

	for _, m in ipairs(memories) do
		if m.type == sig.type
			and m.w == sig.w
			and m.h == sig.h
			and m.landmark == sig.landmark
		then
			return
		end
	end

	table.insert(memories, sig)

	while #memories > MAX_MEMORIES do
		table.remove(memories, 1)
	end
end

function M.recall(floor, memories)
	if not memories or #memories == 0 then
		return nil
	end

	local chance =
		math.min(
			BASE_RECALL
				+ floor * FLOOR_RECALL,
			MAX_RECALL
		)

	if love.math.random() >= chance then
		return nil
	end

	local sig =
		memories[
			love.math.random(#memories)
		]

	return M.mutate(sig)
end

return M
