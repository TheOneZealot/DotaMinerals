require("libraries/popups")

MINERALS_ROCK_LOOT_CHANCE = 0.5
MINERALS_ROCK_LOOT_AMOUNT = 10

function OnDeath( args )
	print("[Minerals] Rocks died -- ")
	local attacker = args.attacker
	local killed = args.unit

	if math.random() < MINERALS_ROCK_LOOT_CHANCE then
		print("-- Player recieves loot")
		attacker:ModifyGold(MINERALS_ROCK_LOOT_AMOUNT, true, DOTA_ModifyGold_Unspecified)
		PopupGoldGain(attacker, MINERALS_ROCK_LOOT_AMOUNT)
	end
end