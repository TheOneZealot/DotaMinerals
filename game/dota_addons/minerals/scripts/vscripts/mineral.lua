function OnCreated( args )
	local target = args.target

	print("[Minerals] Mineral created")
	target:SetRenderColor(255, 255, 0)
end