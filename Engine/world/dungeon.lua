local M = {}

function M.new_room(x, y, w, h)
	return {
		x = x,
		y = y,

		w = w,
		h = h,

		center = {
			x = math.floor(x + w / 2),
			y = math.floor(y + h / 2),
		}
	}
end

function M.rooms_overlap(a, b)
	return
		a.x < b.x + b.w
		and a.x + a.w > b.x
		and a.y < b.y + b.h
		and a.y + a.h > b.y
end

function M.carve_room(map, room)
	for y = room.y,
		room.y + room.h - 1
	do
		for x = room.x,
			room.x + room.w - 1
		do
			map[y][x] = "."
		end
	end
end

function M.carve_h_corridor(
	map,
	x1,
	x2,
	y
)
	for x = math.min(x1, x2),
		math.max(x1, x2)
	do
		map[y][x] = "."
	end
end

function M.carve_v_corridor(
	map,
	y1,
	y2,
	x
)
	for y = math.min(y1, y2),
		math.max(y1, y2)
	do
		map[y][x] = "."
	end
end

return M
