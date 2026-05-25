local M = {}

function M.draw(state)
	-- clear screen (ANSI, more reliable than os.execute)
	io.write("\27[2J\27[H")

	for y, row in ipairs(state.map) do
		for x, tile in ipairs(row) do
			local drawn = false

			-- player
			if x == state.player.x and y == state.player.y then
				io.write("@")
				drawn = true
			end

			-- enemies
			for _, e in ipairs(state.enemies or {}) do
				if x == e.x and y == e.y then
					io.write("E")
					drawn = true
					break
				end
			end

			if not drawn then
				io.write(tile)
			end
		end
		print()
		if state.is_game_over then
			print("\n=== GAME OVER ===")
		end
	end

	print("HP:", state.player.hp, " | Enemies:", #(state.enemies or {}))
	print(state.log or "")
end

return M
