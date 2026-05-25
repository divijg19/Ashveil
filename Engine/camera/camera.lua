local Camera = {}

Camera.__index = Camera

function Camera:new()
	local obj = {
		x = 0,
		y = 0,
	}

	setmetatable(obj, self)

	return obj
end

function Camera:center_on(px, py)
	self.x = px
	self.y = py
end

return Camera
