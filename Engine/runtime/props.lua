local M = {}

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

function M.find_by_type(props, prop_type)
	local matches = {}

	for _, p in ipairs(props) do
		if p.type == prop_type then
			table.insert(matches, p)
		end
	end

	return matches
end

return M
