local M = {}

M.TILE_WIDTH = 64
M.TILE_HEIGHT = 32

local HALF_W = M.TILE_WIDTH / 2
local HALF_H = M.TILE_HEIGHT / 2

function M.to_screen(x, y)
	local sx = (x - y) * HALF_W
	local sy = (x + y) * HALF_H
	return sx, sy
end

return M
