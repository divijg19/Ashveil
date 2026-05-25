local M = {}

function M.spawn_enemy(enemies, room)
	table.insert(enemies, {
		x = room.center.x,
		y = room.center.y,

		hp = 3,
	})
end

function M.cleanup_dead(enemies)
	for i = #enemies, 1, -1 do
		if enemies[i].hp <= 0 then
			table.remove(enemies, i)
		end
	end
end

function M.get_at(entities, x, y)
	for _, e in ipairs(entities) do
		if e.x == x
			and e.y == y
		then
			return e
		end
	end

	return nil
end

return M
