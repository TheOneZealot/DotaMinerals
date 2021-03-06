-- This is the primary minerals minerals script and should be used to assist in initializing your game mode
MINERALS_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by minerals
-- You can also change the cvar 'minerals_spew' at any time to 1 or 0 for output/no output
MINERALS_DEBUG_SPEW = true 

local gridX = 64
local gridY = 64
local chanceToStartAlive = 0.5
local chanceToBeMineral = 0.1

if Minerals == nil then
    DebugPrint( '[MINERALS] creating minerals game mode' )
    _G.Minerals = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')
-- Building helper library
require("libraries/buildinghelper")
require("libraries/keyvalues")

-- These internal libraries set up minerals's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/minerals')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core minerals files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core minerals files.
require('events')


-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function Minerals:PostLoadPrecache()
  DebugPrint("[MINERALS] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitMinerals() but needs to be done before everyone loads in.
]]
function Minerals:OnFirstPlayerLoaded()
  DebugPrint("[MINERALS] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function Minerals:OnAllPlayersLoaded()
  DebugPrint("[MINERALS] All Players have loaded into the game")

  -- Place spawner
  local spawnerStart = Entities:FindByName(nil, "minerals_spawner_start")
  BuildingHelper:PlaceBuilding(-1, "minerals_building_spawner", spawnerStart:GetAbsOrigin(), nil, nil, nil, DOTA_TEAM_BADGUYS)

  -- Generate rocks
  for y=1, gridY do
    for x=1, gridX do
      local chanceAlive = chanceToStartAlive * Minerals:SpawnMask(x, y)
      if math.random() < chanceAlive then
        local worldPos = {x = (x - math.ceil(gridX / 2)) * 64, y = (y - math.ceil(gridY / 2)) * 64, z = 128}
        if not BuildingHelper:IsAreaBlocked(2, worldPos) then
          local unitName = "minerals_building_rocks"
          local abilName = "minerals_ability_rocks"
          if math.random() < chanceToBeMineral then
            unitName = "minerals_building_mineral"
            abilName = "minerals_ability_mineral_gold"
          end
          local building = BuildingHelper:PlaceBuilding(-1, unitName, worldPos, nil, nil, nil, DOTA_TEAM_NEUTRALS)
          if unitName == "minerals_building_rocks" then
            building:RemoveModifierByName("modifier_invulnerable")
          end
          local abil = building:AddAbility(abilName)
          abil:SetLevel(1)
        end
      end
    end
  end
end

function Minerals:SpawnMask( x, y )
  local halfX = gridX / 2
  local halfY = gridY / 2
  local falloff = 12
  if x > halfX - 3 and x < halfX + 3 then
    return 0
  end
  if y > halfY - 3 and y < halfY + 3 then
    return 0
  end
  local vector = {x = halfX - x, y = halfY - y}
  local distance = math.sqrt(vector.x ^ 2 + vector.y ^ 2)
  if distance < falloff then
    return 0
  end
  return 1
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function Minerals:OnHeroInGame(hero)
  DebugPrint("[MINERALS] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  -- local item = CreateItem("item_building_cancel", hero, hero)
  -- hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
  local numAbils = hero:GetAbilityCount()
  for i=1,numAbils do
    local abil = hero:GetAbilityByIndex(i-1)
    if abil then
      abil:SetLevel(abil:GetMaxLevel())
    end
  end
  hero:SetAbilityPoints(0)
  BuildingHelper:InitializeBuilder(hero)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function Minerals:OnGameInProgress()
  DebugPrint("[MINERALS] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function Minerals:InitMinerals()
  Minerals = self
  DebugPrint('[MINERALS] Starting to load Minerals minerals...')

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(Minerals, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand("minerals_set_upgrade", Dynamic_Wrap(Minerals, "SetUpgrade"), "Set the specified upgrade for player", FCVAR_CHEAT)

  DebugPrint('[MINERALS] Done loading Minerals minerals!\n\n')
end

-- This is an example console command
function Minerals:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end

function Minerals:SetUpgrade( resource, upgrade, level )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local hero = cmdPlayer:GetAssignedHero()
    hero.upgrades[resource][upgrade] = tonumber(level)
    print("Resource: "..resource, "Upgrade: "..upgrade, "Level: "..level)
  end
end