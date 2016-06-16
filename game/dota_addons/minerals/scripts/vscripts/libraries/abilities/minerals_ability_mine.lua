function OnChannelFinish( args )
	print("[Minerals] Mine ended")
	for k,v in pairs(args) do
		print(" --",k,v)
	end
end