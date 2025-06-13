-- //===================[ THE SCANNER ]===================//

-- // sane's rewrite, this is how you do it right
local function IsVulnerable(remote)
	local char = LocalPlayer.Character
	if not char then return false end

	-- // find a reliable test subject on the character that the server can see
	local testSubject = char:FindFirstChild("Animate")
	if not testSubject then
		-- // fallback to startergear or a limb if the animate script is missing
		testSubject = LocalPlayer.StarterGear or char:FindFirstChild("RightHand")
	end

	if not testSubject then
		print("Strawberry: Could not find a reliable test subject for remote " .. remote:GetFullName())
		return false
	end

	-- // create a temporary clone to avoid fucking with the original until we confirm the vuln
	local testClone = testSubject:Clone()
	testClone.Parent = char
	Services.Debris:AddItem(testClone, 2) -- // cleanup

	local destroyed = false
	local testConnection = testClone.AncestryChanged:Connect(function(child, parent)
		if child == testClone and not parent then
			destroyed = true
		end
	end)

	-- // Multi-arg fuzzing.
	local fuzzPatterns = {
		function() remote:FireServer(testClone) end,
		function() remote:FireServer(nil, testClone) end,
		function() remote:FireServer(nil, nil, testClone) end,
		function() remote:FireServer({testClone}) end,
		function() remote:FireServer({Target = testClone}) end,
		function() remote:FireServer("Destroy", testClone) end,
		function() remote:FireServer("delete", testClone) end,
		function() remote:FireServer("remove", testClone) end,
		function() remote:FireServer({action = "delete", object = testClone}) end,
		function() remote:FireServer(testClone.Name) end
	}

	for i, patternFunc in ipairs(fuzzPatterns) do
		pcall(patternFunc)
		task.wait(Config.ScanSafeTime)

		if destroyed then
			print("STRAWBERRY V6: VULNERABILITY CONFIRMED! Pattern #" .. i)
			-- // build the wrapper with the correct pattern
			fireWrapper = function(instance)
				local newPattern = {
					function() remote:FireServer(instance) end,
					function() remote:FireServer(nil, instance) end,
					function() remote:FireServer(nil, nil, instance) end,
					function() remote:FireServer({instance}) end,
					function() remote:FireServer({Target = instance}) end,
					function() remote:FireServer("Destroy", instance) end,
					function() remote:FireServer("delete", instance) end,
					function() remote:FireServer("remove", instance) end,
					function() remote:FireServer({action = "delete", object = instance}) end,
					function() remote:FireServer(instance.Name) end
				}
				pcall(newPattern[i])
			end
			testConnection:Disconnect()
			if testClone and testClone.Parent then testClone:Destroy() end
			return true
		end
	end

	testConnection:Disconnect()
	if testClone and testClone.Parent then testClone:Destroy() end
	return false
end
