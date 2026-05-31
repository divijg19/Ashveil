local M = {}

function M.available(room)
	return room.interaction ~= nil
		and not room.visited
end

function M.trigger(room)
	return room.interaction
end

return M
