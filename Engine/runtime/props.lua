local M = {}

function M.add(props, prop)
	table.insert(props, prop)
end

function M.add_many(props, items)
	for _, item in ipairs(items) do
		table.insert(props, item)
	end
end

function M.get_at(props, x, y)
	for _, p in ipairs(props) do
		if p.x == x
			and p.y == y
		then
			return p
		end
	end

	return nil
end

return M
