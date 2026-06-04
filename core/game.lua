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
local Relics = require("Engine.runtime.relics")
local Artifacts = require("Engine.runtime.artifacts")
local Consumables = require("Engine.runtime.consumables")
local Regions = require("Engine.runtime.regions")
local Variants = require("Engine.runtime.variants")
local Intent = require("systems.intent")
local Tells = require("systems.tells")
local Dice = require("systems.dice")
local Scout = require("systems.scout")
local Knowledge = require("systems.knowledge")

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
			relics = {},
			inventory = {
				artifacts = {},
				consumables = {},
				key_items = {},
			},
			gold = 0,
			max_vitality = 10,
			stance = "guarded",
			floor_heal_used = false,
			blessing_doubled = false,
			trial_mod = nil,
			discovery_flags = {},
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

		log = "",

		current_region = Regions.for_floor(1),

		seen_regions = {},

		is_game_over = false,

		show_character = false,

		show_pause = false,

		character_sheet = {
			selection = 1,
		},
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

	Knowledge.init(obj.player)

	Relics.register_grant_hook(
		function(player, id)
			if id == "forgotten_prayer"
				and not player.discovery_flags.prayer_hint
			then
				player.discovery_flags.prayer_hint = true
				MessagePanel.push(
					"The prayer is incomplete. The final verse is missing."
				)
			end
		end
	)

	return obj
end

function Game:update(action)
	if self.is_game_over then
		self.show_character = false
		self.show_pause = false
		return
	end

	self.log = ""

	-- Consumable hotkeys work globally
	if action == "1" then
		self:use_consumable("bandage")
		return
	elseif action == "2" then
		self:use_consumable("ration")
		return
	end

	if self.show_character then
		self:update_character(action)
		return
	end

	if self.show_pause then
		self:update_pause(action)
		return
	end

	if action == "pause" then
		self.show_pause = true
		return
	end

	SceneLoop.update(
		self,
		action
	)

	if self.player.stats.vitality <= 0 then
		self.is_game_over = true
		self.show_character = false
		self.show_pause = false
		self.log = "You died in the Veil."
	end
end

-- =========================
-- EXPLORE
-- =========================

function Game:update_explore(action)
	if not action then
		return
	end

	if action == "interact" then
		self:player_interact()
		return
	end

	if action == "inspect" then
		self:player_inspect()
		return
	end

	if action == "character" then
		self.show_character = true
		self.character_sheet.selection = 1
		return
	end

	self:player_turn(action)
	self:world_turn()
	self.nearby_poi = POI.near(self)
end

function Game:update_character(action)
	if not action then
		return
	end

	if action == "close" then
		self.show_character = false
		return
	end

	if action == "up" then
		self.character_sheet.selection = math.max(
			1,
			self.character_sheet.selection - 1
		)
	elseif action == "down" then
		self.character_sheet.selection = math.min(
			3,
			self.character_sheet.selection + 1
		)
	elseif action == "confirm" then
		local stances = {"guarded", "aggressive", "focused"}
		self.player.stance = stances[
			self.character_sheet.selection
		]
	end
end

function Game:update_pause(action)
	if not action then
		return
	end

	if action == "resume" then
		self.show_pause = false
	elseif action == "quit" then
		love.event.quit()
	end
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
		elseif data and data.enemy then
			self.scene:set("combat")

			self.combat =
				Encounter.start(
					self.player,
					data.enemy,
					self.player.trial_mod
				)

			Knowledge.add_encounter(
				self.player,
				data.enemy.archetype
			)
		else
			self.scene:set("explore")
		end
	end
end

function Game:update_combat(action)
	local c = self.combat
	if not c or not c.enemy then
		return
	end

	-- Check pending exit (victory message awaiting acknowledgment)
	if c.pending_exit then
		if not MessagePanel.has_active() then
			self:exit_combat(c.pending_exit_won)
		end
		return
	end

	-- Turn start: select intent and tell
	if not c.enemy_intent then
		local arch = c.enemy.archetype
		local variant_tendency = nil
		if c.variant then
			local vdef = Variants.def(c.variant)
			if vdef then
				variant_tendency = vdef.tendency
			end
		end
		c.enemy_intent = Intent.select_intent(
			arch,
			c.enemy_hp,
			c.enemy.max_hp,
			variant_tendency
		)
		local tell = Tells.select_tell(arch, c.enemy_intent)
		c.tell = tell.text
		MessagePanel.push_passive(c.tell)

		-- Insight decrement
		if c.insight_turns > 0 then
			c.insight_turns = c.insight_turns - 1
		end

		-- Reset per-turn fields
		c.scout_observation = nil
		c.scout_tier = nil
		c.new_fact_text = nil
	end

	if not action then
		return
	end

	local ename = c.enemy.archetype:gsub("^%l", string.upper)

	if action == "attack" then
		-- Player deals damage
		local dmg = self.player.stats.strength
		if self.player.stance == "aggressive" then
			dmg = dmg + 1
		end
		if c.enemy_intent == "defend" then
			dmg = math.max(1, dmg - 1)
		end
		c.enemy_hp = c.enemy_hp - dmg

		if c.enemy_hp <= 0 then
			MessagePanel.push(
				"You strike. The " .. ename .. " falls."
			)
			c.pending_exit = true
			c.pending_exit_won = true
			return
		end

		-- Enemy acts
		local result = "You strike."
		local enemy_result = self:_process_enemy_turn(c)
		if enemy_result == nil then
			return
		end
		local validation = self:_get_validation(c)
		if validation then
			enemy_result = enemy_result .. " " .. validation
		end
		MessagePanel.push_passive(
			result .. " " .. enemy_result
		)

	elseif action == "brace" then
		c.brace_active = true
		c.scout_bonus = c.scout_bonus + 2

		local result
		if c.scout_bonus > 2 then
			result = "You brace for the coming blow, observing carefully."
		else
			result = "You steady yourself and watch."
		end

		-- Enemy acts
		local enemy_result = self:_process_enemy_turn(c)
		if enemy_result == nil then
			return
		end
		local validation = self:_get_validation(c)
		if validation then
			enemy_result = enemy_result .. " " .. validation
		end
		MessagePanel.push_passive(
			result .. " " .. enemy_result
		)

	elseif action == "scout" then
		-- Calculate effective scout bonus
		local bonus = (c.scout_bonus or 0)
			+ self.player.stats.perception
		if self.player.stance == "focused" then
			bonus = bonus + 3
		elseif self.player.stance == "aggressive" then
			bonus = bonus - 3
		end
		if c.modifier == "shadows" then
			bonus = bonus - 2
		end

		local roll = Dice.roll(bonus, 11)
		c.scout_bonus = 0 -- consumed

		-- Wound anomaly: suppress all scout observations
		if self.wound_anomaly_active then
			roll.level = "glimpse"
		end

		local scout_result = Scout.resolve(
			c,
			self.player,
			roll.level
		)

		if self.wound_anomaly_active then
			scout_result.message = "The Veil is bleeding here. It is hard to see clearly."
		end

		c.scout_observation = scout_result.message
		c.scout_tier = roll.level

		if scout_result.new_fact_text then
			c.new_fact_text = scout_result.new_fact_text
		end

		if scout_result.insight_turns > 0 then
			c.insight_turns = scout_result.insight_turns
		end

		-- Scout may reveal hidden treasure
		if roll.level == "understand"
			or roll.level == "insight"
			or roll.level == "revelation"
		then
			local stash_chance = {
				understand = 0.15,
				insight = 0.25,
				revelation = 0.35,
			}
			if love.math.random() < (stash_chance[roll.level] or 0.15) then
				c._scout_found_stash = true
				c._scout_tier_for_stash = roll.level
				c.scout_observation = c.scout_observation
					.. " You notice disturbed stonework."
			end
		end

		-- Enemy acts
		local enemy_result = self:_process_enemy_turn(c)
		if enemy_result == nil then
			return
		end

		-- Scout observation lives in combat panel; enemy result in message panel
		local validation = self:_get_validation(c)
		if validation then
			enemy_result = enemy_result .. " " .. validation
		end
		MessagePanel.push_passive(enemy_result)

	elseif action == "flee" then
		MessagePanel.push_passive("You flee the encounter.")
		self:exit_combat(false)
		return
	end

	-- Clear intent for next turn (brace persists if not consumed)
	c.enemy_intent = nil
end

function Game:_get_validation(c)
	if not c.scout_tier then
		return nil
	end

	if c.scout_tier ~= "understand"
		and c.scout_tier ~= "insight"
		and c.scout_tier ~= "revelation"
	then
		return nil
	end

	local base = Intent.intent_damage(c.enemy_intent, c.enemy.archetype)
	if base > 0 then
		return "Your observation proves accurate."
	end

	return nil
end

function Game:_process_enemy_turn(c)
	local ename = c.enemy.archetype:gsub("^%l", string.upper)
	local base = Intent.intent_damage(
		c.enemy_intent,
		c.enemy.archetype
	)

	if base > 0 then
		local edmg = base
		if self.player.stance == "aggressive" then
			edmg = edmg + 1
		end
		if self.player.stance == "guarded" then
			edmg = math.max(1, edmg - 1)
		end
		if c.brace_active then
			edmg = math.max(0, edmg - 1)
			c.brace_active = false
		end

		if edmg > 0 then
			c.player_hp = c.player_hp - edmg
		end

		if c.player_hp <= 0 then
			self.player.stats.vitality = 0
			c.enemy_intent = nil
			self.is_game_over = true
			MessagePanel.push("You died in the Veil.")
			return nil
		end

		self.player.stats.vitality = c.player_hp

		if edmg > 0 then
			return "The " .. ename .. " strikes for " .. edmg .. "."
		else
			return "You deflect the blow."
		end

	elseif c.enemy_intent == "recover" then
		local amount = 1
		local rule = Intent.archetype_rule(
			c.enemy.archetype,
			"recover_amount"
		)
		if rule then
			amount = rule
		end

		local before = c.enemy_hp
		c.enemy_hp = math.min(
			c.enemy_hp + amount,
			c.enemy.max_hp
		)
		self.player.stats.vitality = c.player_hp

		if c.enemy_hp > before then
			return "The " .. ename .. " recovers."
		else
			return "The " .. ename .. " tries to recover."
		end

	elseif c.enemy_intent == "defend" then
		self.player.stats.vitality = c.player_hp
		if c.enemy.archetype == "sentinel" then
			return "The " .. ename .. " braces. The Veil echoes."
		end
		return "The " .. ename .. " braces."
	end

	self.player.stats.vitality = c.player_hp
	return ""
end

function Game:exit_combat(player_won)
	local c = self.combat
	if not c then
		return
	end

	Encounter.finish(
		c,
		self.player,
		player_won
	)

	self.combat = nil
	self.scene:set("explore")

	-- Scout-revealed hidden cache: spawn after combat
	if player_won and c._scout_found_stash then
		table.insert(self.props, {
			x = self.player.x + 1,
			y = self.player.y,
			type = "hidden_cache",
			poi = {
				state = "active",
				tags = {"treasure"},
				interaction = {
					action = "Search",
					event_type = "hidden_cache_scout",
				},
				inspect = "You noticed this during the fight. Disturbed stonework.",
				scout_tier = c._scout_tier_for_stash,
			},
		})
	end

	if not player_won then
		self.player.trial_mod = nil
		return
	end

	-- Blood Sigil: heal 1 on first combat victory each floor
	if Relics.has(self.player, "blood_sigil")
		and not self.player.floor_heal_used
	then
		self.player.stats.vitality =
			self.player.stats.vitality + 1
		self.player.floor_heal_used = true
		MessagePanel.push(
			"The sigil pulses. Vitality is restored."
		)
	end

	local trial_mod = self.player.trial_mod

	if trial_mod then
		self.player.trial_mod = nil

		local rewarded_stat

		if trial_mod == "wounds" then
			self.player.stats.strength =
				self.player.stats.strength + 1
			MessagePanel.push(
				"You endure the wound. Strength grows."
			)
			rewarded_stat = "strength"

		elseif trial_mod == "fury" then
			self.player.stats.resolve =
				self.player.stats.resolve + 1
			MessagePanel.push(
				"You overcome fury. Resolve deepens."
			)
			rewarded_stat = "resolve"

		elseif trial_mod == "shadows" then
			self.player.stats.perception =
				self.player.stats.perception + 1
			MessagePanel.push(
				"You navigate the darkness. Perception sharpens."
			)
			rewarded_stat = "perception"
		end

		-- Warden's Scar: +1 to a random remaining stat after trial reward
		if rewarded_stat
			and Relics.has(
				self.player,
				"wardens_scar"
			)
		then
			local pool = {
				"strength",
				"resolve",
				"perception",
			}

			local remaining = {}

			for _, s in ipairs(pool) do
				if s ~= rewarded_stat then
					table.insert(remaining, s)
				end
			end

			local bonus =
				remaining[
					love.math.random(
						#remaining
					)
				]

			self.player.stats[bonus] =
				self.player.stats[bonus] + 1

			MessagePanel.push(
				"The scar pulses. +1 "
					.. bonus:gsub("^%l", string.upper)
					.. "."
			)
		end
	end

	-- Elite variant relic chance (5%)
	if c.variant and player_won then
		if love.math.random() < 0.05 then
			local relic_id = Relics.random_unowned(self.player)
			if relic_id then
				Relics.grant(self.player, relic_id)
				local vdef = Variants.def(c.variant)
				MessagePanel.push(
					"The "
						.. (vdef and vdef.name or "elite")
						.. " carried a relic."
				)
			end
		end
	end

	-- Sentinel: relic or gold cache
	if c.enemy
		and c.enemy.archetype == "sentinel"
		and player_won
	then
		if love.math.random() < 0.50 then
			local relic_id = Relics.random_unowned(self.player)
			if relic_id then
				Relics.grant(self.player, relic_id)
				MessagePanel.push(
					"The sentinel's remains yield a relic."
				)
			else
				self.player.gold = self.player.gold + 10
				MessagePanel.push(
					"The sentinel's chamber holds gold."
				)
			end
		else
			self.player.gold = self.player.gold + 12
			MessagePanel.push(
				"You find a gold cache in the sentinel's chamber."
			)
		end
	end

	-- Mark of Ash: check completion after sentinel defeat
	if c
		and c.enemy
		and c.enemy.archetype == "sentinel"
		and player_won
		and self.player.discovery_flags.mark_recognized
		and not self.player.discovery_flags.mark_complete
	then
		self.player.discovery_flags.mark_complete = true
		Artifacts.grant(self.player, "messorem_cinis")
		MessagePanel.push(
			"The Echo Chamber bears the Mark of Ash. You understand now.\nA fragment of charcoal-black stone rests among the echoes."
		)
	end
end

-- =========================
-- CONSUMABLES
-- =========================

function Game:use_consumable(id)
	local player = self.player
	if not player.inventory.consumables[id]
		or player.inventory.consumables[id] < 1
	then
		return
	end

	if self.scene:is("combat") then
		MessagePanel.push("Cannot use items in combat.")
		return
	end

	local def = Consumables.def(id)
	if def then
		def.use(player)
		player.inventory.consumables[id] = player.inventory.consumables[id] - 1
		MessagePanel.push(def.use_message or "Used " .. def.name .. ".")
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

	-- Mark of Ash chain: check in shrine rooms
	if poi.poi
		and poi.poi.interaction
		and poi.poi.interaction.event_type
	then
		local et = poi.poi.interaction.event_type
		if string.find(et, "shrine") then
			if not self.player.discovery_flags.mark_seen
				and self.floor >= 2
				and self.floor <= 4
			then
				self.player.discovery_flags.mark_seen = true
				MessagePanel.push(
					"A strange symbol is carved into the stone. You do not recognize it."
				)
			elseif self.player.discovery_flags.mark_seen
				and not self.player.discovery_flags.mark_recognized
				and self.floor >= 6
				and self.floor <= 8
			then
				self.player.discovery_flags.mark_recognized = true
				MessagePanel.push(
					"The same symbol. You've seen this before."
				)
			end
		end
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
	elseif action == "cancel" then
		if ev.cancel_index then
			Events.resolve(self, ev, ev.cancel_index)
		end
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

		show_character = self.show_character,

		show_pause = self.show_pause,

		character_sheet = self.character_sheet,
	}
end

return Game
