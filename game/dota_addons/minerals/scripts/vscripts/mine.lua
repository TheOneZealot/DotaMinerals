require("libraries/popups")

function BuildingHelper:OnPreMine( builder, target )
	print("[Minerals] OnPreMine "..builder:GetUnitName().." "..builder:GetEntityIndex().." -> "..target:GetUnitName().." "..target:GetEntityIndex())

    local bValidRepair = target:GetClassname() == "npc_dota_building" and IsCustomBuilding(target)

    return bValidRepair
end

function BuildingHelper:OnMineStarted( builder, building )
	print("[Minerals] OnMineStarted "..builder:GetUnitName().." "..builder:GetEntityIndex().." -> "..building:GetUnitName().." "..building:GetEntityIndex())

	builder:StartGesture(ACT_DOTA_ATTACK)
    builder.mine_animation_timer = Timers:CreateTimer(function()
        if builder.state == "mining" then
            builder:StartGesture(ACT_DOTA_ATTACK)
        end
        return 1
    end)
end

function BuildingHelper:OnMineTick( building )
	print("[Minerals] OnMineTick "..building:GetUnitName().." "..building:GetEntityIndex())

	if not building.unit_mining then return end
	local player = building.unit_mining:GetPlayerOwner()
	local hero = player:GetAssignedHero()
    local goldCost = building:GetKeyValue("GoldCost")

    local amount = hero.upgrades.gold.amount + 1

    hero:ModifyGold(amount, true, 0)
    PopupGoldGain(hero, amount)
end

function BuildingHelper:OnMineCancelled( builder, building )
	print("[Minerals] OnMineCancelled "..builder:GetUnitName().." "..builder:GetEntityIndex().." -> "..building:GetUnitName().." "..building:GetEntityIndex())

	if builder.mine_animation_timer then
        builder:RemoveGesture(ACT_DOTA_ATTACK)
        Timers:RemoveTimer(builder.mine_animation_timer)
    end
end