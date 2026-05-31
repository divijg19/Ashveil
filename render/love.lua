local explore = require("render.explore")
local combat = require("render.combat")
local transition = require("render.transition")
local event_view = require("render.event")

local M = {}

function M.draw(state)
	if state.scene:is("explore") then
		explore.draw(state)

	elseif state.scene:is("combat") then
		combat.draw(state)

	elseif state.scene:is("event") then
		explore.draw(state)
		event_view.draw(state)

	elseif state.scene:is("transition") then
		explore.draw(state)
		transition.draw(state)
	end

	-- bottom narrative panel (overlays all scenes)
	local panel = state.message_panel

	if panel then
		M.draw_message_panel(panel)
	end
end

function M.draw_message_panel(panel)
	local msg = panel.current()

	if not msg then
		return
	end

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	local panel_w = math.min(500, w - 60)
	local panel_h = 80
	local px = (w - panel_w) / 2
	local py = h - 130

	-- panel backing
	love.graphics.setColor(
		0,
		0,
		0,
		0.6
	)

	love.graphics.rectangle(
		"fill",
		px,
		py,
		panel_w,
		panel_h
	)

	-- subtle edge
	love.graphics.setColor(
		0.35,
		0.35,
		0.35,
		0.25
	)

	love.graphics.rectangle(
		"line",
		px,
		py,
		panel_w,
		panel_h
	)

	-- atmospheric message text
	love.graphics.setColor(
		0.85,
		0.85,
		0.85,
		msg.alpha
	)

	love.graphics.printf(
		msg.text,
		px + 20,
		py + 18,
		panel_w - 40,
		"center"
	)

	-- acknowledgment prompt (only when waiting)
	if msg.is_waiting then
		love.graphics.setColor(
			0.6,
			0.6,
			0.6,
			msg.alpha * 0.7
		)

		love.graphics.printf(
			"[ Enter ]",
			px + 20,
			py + panel_h - 22,
			panel_w - 40,
			"center"
		)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return M
