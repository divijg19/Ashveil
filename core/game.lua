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
local DescentText = require("Engine.runtime.descent_text")
local Anomaly = require("Engine.runtime.anomaly")
local MessagePanel = require("Engine.runtime.message_panel")
local Events = require("Engine.runtime.events")
local POI = require("Engine.runtime.poi")
local Inspection = require("Engine.runtime.inspection")

local Compositions = require("world.compositions")
local movement = require("systems.movement")
local ai = require("systems.ai")

local Game = {}

function Game:new()
	local echo_memories = {}

	local map, rooms, exit =
		Map.create(80, 80, 1, nil, echo_memories)

	local spawn = rooms[1].center

	local obj = {
		map = map,
		rooms = rooms,
		exit = exit,

		echo_memories = echo_memories,

		floor = 1,

		seed =
			love.math.random(
				999999
			),

		player = {
			x = spawn.x,
			y = spawn.y,
			stats = {
				vitality = 10,
				strength = 1,
				resolve = 1,
				perception = 1,
				agility = 1,
			},
			blessings = {},
			trial_mod = nil,
		},

		enemies = {},

		props = {},

		scene = SceneManager:new("explore"),

		camera = Camera:new(),

		combat = nil,

		transition = Transition:new(0.6),

		anomaly = nil,

		event = nil,

		nearby_poi = nil,

		active_poi = nil,

		_prev_log = nil,

		log = "",

		is_game_over = false,
	}

	Environment.populate(
		obj,
		rooms,
		Compositions
	)

	setmetatable(obj, self)
	self.__index = self

	MessagePanel.push(
		"Welcome to Ashveil."
	)

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

	if self.player.stats.vitality <= 0 then
		self.is_game_over = true
		self.log = "You died in the Veil."
	end
end

-- =========================
-- EXPLORE
-- =========================

function Game:update_explore(action)
	if action == "interact" then
		self:player_interact()
		return
	end

	if action == "inspect" then
		self:player_inspect()
		return
	end

	self:player_turn(action)
	self:world_turn()
	self.nearby_poi = POI.near(self)
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
		self.scene:set("transition")

		local next_floor =
			self.floor + 1

		local anomaly =
			Anomaly.roll(next_floor)

		self.anomaly = anomaly

		local msg =
			DescentText.get(
				next_floor,
				anomaly
				and anomaly.type
			)

		-- very rarely repeat previous message
		if self._prev_msg
			and love.math.random()
				< 0.05
		then
			msg = self._prev_msg
		end

		self._prev_msg = msg

		-- subtle timing instability
		local duration = 1.2

		local roll =
			love.math.random()

		if roll < 0.06 then
			duration = 1.4
		elseif roll < 0.10 then
			duration = 1.0
		end

		-- very rare text offset
		local offset_x = 0

		if love.math.random() < 0.08 then
			offset_x =
				love.math.random(
					-2, 2
				)
		end

		self.transition:start({
			descent = true,
			next_floor = next_floor,
			duration = duration,
			msg = msg,
			offset_x = offset_x,
		})

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
		self.transition.duration =
			0.6

		local data =
			self.transition.data

		if data and data.descent then
			Floor.next(
				self,
				Map,
				Compositions,
				self.anomaly
			)

			MessagePanel.push(
				data.msg
			)

			self.scene:set("explore")
		else
			self.scene:set("combat")

			self.combat =
				Encounter.start(
					self.player,
					data.enemy,
					self.player.trial_mod
				)

			local enemy_speed = 2
			self.combat.player_initiative =
				love.math.random(
					1,
					self.player.stats.agility + enemy_speed
				) <= self.player.stats.agility

			self.log =
				"The battle begins!"
		end
	end
end

function Game:update_combat(action)
	if not action then
		return
	end

	local c = self.combat

	if action == "attack" then
		if c.player_initiative then
			c.enemy_hp = c.enemy_hp - self.player.stats.strength
			self.log = "You strike the Veilbeast."

			if c.enemy_hp <= 0 then
				self:exit_combat(true)
				return
			end

			c.player_hp = c.player_hp - 1

			if c.player_hp <= 0 then
				self.player.stats.vitality = 0
				self.is_game_over = true
				self.log = "You were slain."
				return
			end
		else
			c.player_hp = c.player_hp - 1

			if c.player_hp <= 0 then
				self.player.stats.vitality = 0
				self.is_game_over = true
				self.log = "You were slain."
				return
			end

			c.enemy_hp = c.enemy_hp - self.player.stats.strength
			self.log = "You strike the Veilbeast."

			if c.enemy_hp <= 0 then
				self:exit_combat(true)
				return
			end
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

	if not player_won then
		self.player.trial_mod = nil
		return
	end

	if self.player.trial_mod then
		local mod = self.player.trial_mod
		self.player.trial_mod = nil

		if mod == "wounds" then
			self.player.stats.strength =
				self.player.stats.strength + 1
			MessagePanel.push(
				"You endure the wound. Strength grows."
			)

		elseif mod == "fury" then
			self.player.stats.resolve =
				self.player.stats.resolve + 1
			MessagePanel.push(
				"You overcome fury. Resolve deepens."
			)

		elseif mod == "shadows" then
			self.player.stats.perception =
				self.player.stats.perception + 1
			MessagePanel.push(
				"You navigate the darkness. Perception sharpens."
			)
		end
	end
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
-- EVENT
-- =========================

function Game:player_interact()
	local poi = POI.near(self)
	if not poi then
		return
	end

	local event_type = POI.activate(poi)
	if not event_type then
		return
	end

	self.active_poi = poi
	self.event = Events.start(event_type, poi)
	self.scene:set("event")
end

function Game:player_inspect()
	local poi = POI.near(self)
	if not poi then
		return
	end

	Inspection.inspect(self, poi)
end

function Game:start_event(event_type, poi)
	self.event = Events.start(event_type, poi)
	self.scene:set("event")
end

function Game:update_event(action)
	local ev = self.event

	if not ev then
		self.scene:set("explore")
		return
	end

	if ev.done then
		local result = ev.result

		if self.active_poi then
			POI.complete(self.active_poi)
			self.active_poi = nil
		end

		self.event = nil
		self.scene:set("explore")

		if result and result.combat then
			local enemy = self:get_enemy_at(
				self.player.x,
				self.player.y
			)

			if enemy then
				self:start_combat(enemy)
				return
			end
		end

		if result and result.message then
			MessagePanel.push(result.message)
		end

		return
	end

	if not action then
		return
	end

	if action == "up" then
		ev.selection = math.max(
			1,
			ev.selection - 1
		)

	elseif action == "down" then
		ev.selection = math.min(
			#ev.options,
			ev.selection + 1
		)

	elseif action == "confirm" then
		Events.resolve(self, ev, ev.selection)
	end
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

		event = self.event,

		nearby_poi = self.nearby_poi,

		active_poi = self.active_poi,

		anomaly = self.anomaly,

		message_panel = MessagePanel,

		log = self.log,

		scene = self.scene,

		is_game_over = self.is_game_over,
	}
end

return Game
