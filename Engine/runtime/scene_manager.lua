local M = {}

function M:new(initial)
	local obj = {
		current = initial
	}

	setmetatable(obj, self)
	self.__index = self

	return obj
end

function M:set(scene)
	self.current = scene
end

function M:is(scene)
	return self.current == scene
end

function M:get()
	return self.current
end

return M
