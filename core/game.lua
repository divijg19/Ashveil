local Map = require("core.map")
local Camera = require("Engine.camera.camera")
local Transition = require("Engine.runtime.transition")
local SceneManager = require("Engine.runtime.scene_manager")
local Encounter = require("Engine.runtime.encounter")
local WorldTick = require("Engine.runtime.world_tick")
local Entities = require("Engine.runtime.entities")
local Floor = require("Engine.runtime.floor")
local Environment = require("Engine.runtime.environment")
local SceneLoop = require("Engine.runtime.scene_loop")

local Compositions = require("world.compositions")
local movement = require("systems.movement")
local ai = require("systems.ai")

local Game = {}

function Game:new()
	local map, rooms, exit = Map.create(80, 80)

	local spawn = rooms[1].center

	local obj = {
		map = map,
		rooms = rooms,
		exit = exit,

		floor = 1,

		seed =
			love.math.random(
				999999
			),

		player = {
			x = spawn.x,
			y = spawn.y,
			hp = 10,
		},

		enemies = {},

		props = {},

		scene = SceneManager:new("explore"),

		camera = Camera:new(),

		combat = nil,

		transition = Transition:new(0.6),

		log = "Welcome to Ashveil.",

		is_game_over = false,
	}

	Environment.populate(
		obj,
		rooms,
		Compositions
	)

	setmetatable(obj, self)
	self.__index = self

	return obj
end

function Game:update(action)
	if self.is_game_over then
		return
	end

	self.log = ""

	SceneLoop.update(
		self,
		action
	)

	if self.player.hp <= 0 then
		self.is_game_over = true
		self.log = "You died in the Veil."
	end
end

-- =========================
-- EXPLORE
-- =========================

function Game:update_explore(action)
	self:player_turn(action)
	self:world_turn()
end

function Game:player_turn(action)
	if not action then
		return
	end

	local nx, ny = movement.player(self, action)

	if not nx then
		return
	end

	local enemy = self:get_enemy_at(nx, ny)

	if enemy then
		self:start_combat(enemy)
		return
	end

	self.player.x = nx
	self.player.y = ny

	if
		self.player.x == self.exit.x
		and
		self.player.y == self.exit.y
	then
		Floor.next(
			self,
			Map,
			Compositions
		)

		return
	end
end

function Game:world_turn()
	WorldTick.update(
		self,
		ai
	)
end

-- =========================
-- COMBAT
-- =========================

function Game:start_combat(enemy)
	self.scene:set("transition")

	self.transition:start({
		enemy = enemy,
	})

	self.log = "A Veil stirs..."
end

function Game:update_transition()
	local finished =
		self.transition:update(
			1 / 60
		)

	if finished then
		self.scene:set("combat")

		self.combat =
			Encounter.start(
				self.player,
				self.transition.data.enemy
			)

		self.log =
			"The battle begins!"
	end
end

function Game:update_combat(action)
	if not action then
		return
	end

	local c = self.combat

	if action == "attack" then
		c.enemy_hp = c.enemy_hp - 1

		self.log = "You strike the Veilbeast."

		if c.enemy_hp <= 0 then
			self:exit_combat(true)
			return
		end

		c.player_hp = c.player_hp - 1

		if c.player_hp <= 0 then
			self.player.hp = 0
			self.is_game_over = true
			self.log = "You were slain."
			return
		end
	elseif action == "guard" then
		self.log = "You brace for impact."
	elseif action == "skill" then
		self.log = "No skills learned yet."
	elseif action == "flee" then
		self:exit_combat(false)
		self.log = "You fled the encounter."
	end
end

function Game:exit_combat(player_won)
	local c = self.combat

	Encounter.finish(
		c,
		self.player,
		player_won
	)

	self.combat = nil

	self.scene:set("explore")
end

-- =========================
-- HELPERS
-- =========================

function Game:get_enemy_at(x, y)
	return Entities.get_at(
		self.enemies,
		x,
		y
	)
end

-- =========================
-- DRAW STATE
-- =========================

function Game:get_draw_data()
	return {
		map = self.map,
		rooms = self.rooms,
		exit = self.exit,
		floor = self.floor,

		player = self.player,
		enemies = self.enemies,
		props = self.props,

		camera = self.camera,

		combat = self.combat,

		transition = self.transition,

		log = self.log,

		scene = self.scene,

		is_game_over = self.is_game_over,
	}
end

return Game
