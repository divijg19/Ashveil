package.path = "./?.lua;./?/init.lua;" .. package.path

local Game = require("core.game")
local MessagePanel = require("Engine.runtime.message_panel")

local love_input = require("input.love")
local explore_input = require("input.explore")
local combat_input = require("input.combat")
local event_input = require("input.event")

local renderer = require("render.love")

local game = Game:new()

function love.update(dt)
	MessagePanel.update(dt)

	-- transitions update continuously (no player input)
	if game.scene:is("transition") then
		game:update(nil)
		return
	end

	-- message panel blocks gameplay input
	if MessagePanel.has_active() then
		local key = love_input.get_key()

		if key == "return"
			or key == "space"
			or love_input.was_clicked()
		then
			MessagePanel.acknowledge()
		end

		return
	end

	local key = love_input.get_key()
	local action = nil

	if game.scene:is("explore") then
		action = explore_input.get_action(key)

	elseif game.scene:is("event") then
		action = event_input.get_action(key)

	elseif game.scene:is("combat") then
		action = combat_input.get_action(key)
	end

	if action then
		game:update(action)
	end
end

function love.draw()
	renderer.draw(game:get_draw_data())
end
