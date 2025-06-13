-- // sane's definitive rewrite. this is how you eliminate false positives.
local function IsVulnerable(remote)
	local char = LocalPlayer.Character
	if not char then return false end

	-- // find a reliable test subject
	local testSubject = char:FindFirstChild("Animate") or LocalPlayer.StarterGear or char:FindFirstChild("RightHand")
	if not testSubject then
		-- // if we can't find anything to test with, we can't test. simple.
		return false
	end

	-- // The Control Group Method:
	-- // testClone1 is the target. testClone2 is the control.
	local testClone1 = testSubject:Clone()
	testClone1.Name = "STRAWBERRY_TARGET_" .. Services.HttpService:GenerateGUID(false)
	testClone1.Parent = char
	local testClone2 = testSubject:Clone()
	testClone2.Name = "STRAWBERRY_CONTROL_" .. Services.HttpService:GenerateGUID(false)
	testClone2.Parent = char

	Services.Debris:AddItem(testClone1, 3)
	Services.Debris:AddItem(testClone2, 3)

	local destroyed1 = false
	local destroyed2 = false

	local connection1 = testClone1.AncestryChanged:Connect(function(_, parent)
		if not parent then destroyed1 = true end
	end)
	local connection2 = testClone2.AncestryChanged:Connect(function(_, parent)
		if not parent then destroyed2 = true end
	end)

	local fuzzPatterns = {
		function() remote:FireServer(testClone1) end,
		function() remote:FireServer(nil, testClone1) end,
		function() remote:FireServer(nil, nil, testClone1) end,
		function() remote:FireServer({testClone1}) end,
		function() remote:FireServer({Target = testClone1}) end,
		function() remote:FireServer("Destroy", testClone1) end,
		function() remote:FireServer("delete", testClone1) end,
		function() remote:FireServer("remove", testClone1) end,
		function() remote:FireServer({action = "delete", object = testClone1}) end,
		function() remote:FireServer(testClone1.Name) end
	}

	for i, patternFunc in ipairs(fuzzPatterns) do
		pcall(patternFunc)
		task.wait(Config.ScanSafeTime + (math.random(5, 20) / 100)) -- randomized micro-delay

		if destroyed1 and not destroyed2 then
			print("STRAWBERRY V6: HIGH-CONFIDENCE VULNERABILITY CONFIRMED! Pattern #" .. i)
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
			connection1:Disconnect()
			connection2:Disconnect()
			if testClone1 and testClone1.Parent then testClone1:Destroy() end
			if testClone2 and testClone2.Parent then testClone2:Destroy() end
			return true
		end
	end

	connection1:Disconnect()
	connection2:Disconnect()
	if testClone1 and testClone1.Parent then testClone1:Destroy() end
	if testClone2 and testClone2.Parent then testClone2:Destroy() end
	return false
end
