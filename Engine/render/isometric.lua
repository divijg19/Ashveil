local M = {}

M.TILE_WIDTH = 64
M.TILE_HEIGHT = 32

function M.to_screen(x, y)
	local sx =
		(x - y)
		* (M.TILE_WIDTH / 2)

	local sy =
		(x + y)
		* (M.TILE_HEIGHT / 2)

	return sx, sy
end

return M
