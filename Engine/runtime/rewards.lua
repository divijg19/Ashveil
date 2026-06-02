local M = {}

function M.vitality(player, amount)
	if player.buff_doubled then
		amount = amount * 2
		player.buff_doubled = nil
	end

	player.stats.vitality = player.stats.vitality + amount
end

function M.blessing(player, name)
	table.insert(player.blessings, name)
end

function M.none()
end

return M
