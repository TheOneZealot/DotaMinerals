require("libraries/popups")

function OnDeath( args )
	print("[Minerals] Rocks died -- ")
	local attacker = args.attacker
	local killed = args.unit

	print("-- Player recieves loot")
	attacker:ModifyGold(10, true, DOTA_ModifyGold_Unspecified)
	PopupGoldGain(attacker, 10)
end