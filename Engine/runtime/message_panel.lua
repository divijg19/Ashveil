local M = {
	_queue = {},
	_active = nil,
	_state = "idle",
	_timer = 0,
	_fade_in = 0.3,
	_linger = 0.4,
	_fade_out = 0.2,
}

function M.push(text)
	table.insert(M._queue, text)
	if M._state == "idle" or M._state == "passive" then
		M._advance()
	end
end

function M.push_passive(text)
	M._active = text
	M._state = "passive"
	M._timer = 0
end

function M._advance()
	if #M._queue == 0 then
		M._active = nil
		M._state = "idle"
		return
	end

	M._active = table.remove(M._queue, 1)
	M._state = "fade_in"
	M._timer = 0
end

function M.current()
	if M._state == "idle" then
		return nil
	end

	return {
		text = M._active,
		alpha = M:_alpha(),
		is_waiting = M._state == "active",
	}
end

function M:_alpha()
	if M._state == "passive" then
		return 1

	elseif M._state == "fade_in" then
		return math.min(M._timer / M._fade_in, 1)

	elseif M._state == "active" then
		return 1

	elseif M._state == "linger" then
		return 1

	elseif M._state == "fade_out" then
		return math.max(
			1 - M._timer / M._fade_out,
			0
		)
	end

	return 0
end

function M.has_active()
	return M._state ~= "idle" and M._state ~= "passive"
end

function M.acknowledge()
	if M._state == "fade_in"
		or M._state == "active"
	then
		M._state = "linger"
		M._timer = 0
	end
end

function M.update(dt)
	if M._state == "idle" or M._state == "passive" then
		return
	end

	M._timer = M._timer + dt

	if M._state == "fade_in"
		and M._timer >= M._fade_in
	then
		M._state = "active"
		M._timer = 0

	elseif M._state == "linger"
		and M._timer >= M._linger
	then
		M._state = "fade_out"
		M._timer = 0

	elseif M._state == "fade_out"
		and M._timer >= M._fade_out
	then
		M._advance()
	end
end

return M
