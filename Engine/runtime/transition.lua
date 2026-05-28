local M = {}

function M:new(duration)
	local obj = {
		timer = 0,

		duration = duration or 0.6,

		alpha = 0,

		active = false,
	}

	setmetatable(obj, self)
	self.__index = self

	return obj
end

function M:start(data)
	self.timer = 0
	self.alpha = 0

	self.active = true

	self.data = data or {}

	if self.data.duration then
		self.duration = self.data.duration
	end
end

function M:update(dt)
	if not self.active then
		return false
	end

	self.timer =
		self.timer + dt

	self.alpha =
		math.min(
			self.timer / self.duration,
			1
		)

	if self.timer >= self.duration then
		self.active = false

		return true
	end

	return false
end

return M
