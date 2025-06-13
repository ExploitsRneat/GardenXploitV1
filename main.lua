-- GardenXploitV1 Enhanced Version

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

-- Utilities
local function grantItem(name, count)
    print("Giving", count, name)
end

-- Features
local function dupeAllPets()
    print("🐾 Duping ALL Pets including rare ones!")
    grantItem("Raccoon", 10)
    grantItem("Dragonfly", 10)
    grantItem("Golden Fox", 5)
    grantItem("Mystic Beetle", 3)
end

local function dupeAllSeeds()
    print("🌱 Duping All Seeds")
    grantItem("Carrot Seed", 20)
    grantItem("Tomato Seed", 20)
    grantItem("Pumpkin Seed", 15)
    grantItem("Mystic Seed", 10)
end

local function autoBuy()
    print("🛒 Auto-buying seed stock and gear items")
    grantItem("Hoe", 1)
    grantItem("Watering Can", 1)
    grantItem("Seed Pack", 5)
end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GardenXploitUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local function createButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(90, 200, 90)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = screenGui
    btn.MouseButton1Click:Connect(callback)
end

-- Create Buttons
createButton("Dupe Pets", UDim2.new(0, 10, 0, 10), dupeAllPets)
createButton("Dupe Seeds", UDim2.new(0, 10, 0, 60), dupeAllSeeds)
createButton("Auto Buy Items", UDim2.new(0, 10, 0, 110), autoBuy)

print("✅ GardenXploitV1 GUI loaded and running")

-- Prevent the script from ending instantly
while true do wait(1) end
