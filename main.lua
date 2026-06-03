package.path = "./?.lua;./?/init.lua;" .. package.path

local Game = require("core.game")
local MessagePanel = require("Engine.runtime.message_panel")

local love_input = require("input.love")
local explore_input = require("input.explore")
local combat_input = require("input.combat")
local event_input = require("input.event")
local character_input = require("input.character")
local pause_input = require("input.pause")

local renderer = require("render.love")
local pause_view = require("render.pause")

local game = Game:new()

function love.update(dt)
	MessagePanel.update(dt)

	-- Input ownership priority:
	-- 1. Game Over (handled inside game:update)
	-- 2. Transition
	-- 3. Message Panel
	-- 4. Character Sheet
	-- 5. Pause Menu
	-- 6. Scene Input

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

	if game.show_character then
		action = character_input.get_action(key)

	elseif game.show_pause then
		action = pause_input.get_action(key)

	elseif game.scene:is("explore") then
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

	if game.show_pause then
		pause_view.draw(game:get_draw_data())
	end
end
