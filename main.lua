-- Grow-a-Garden Complete System Script with Duping
-- Place this in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- RemoteEvents
local plantEvent = Instance.new("RemoteEvent", ReplicatedStorage)
plantEvent.Name = "PlantSeedEvent"

local waterEvent = Instance.new("RemoteEvent", ReplicatedStorage)
waterEvent.Name = "WaterCropEvent"

local harvestEvent = Instance.new("RemoteEvent", ReplicatedStorage)
harvestEvent.Name = "HarvestCropEvent"

-- Storage Reference
local cropsStorage = ServerStorage:WaitForChild("Crops")
local petsStorage = ServerStorage:FindFirstChild("Pets")

-- Planted crop data
local plantedCrops = {}  -- [plot] = { owner, cropType, stage, watered, model }

-- Leaderstats setup
Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    local carrotSeeds = Instance.new("IntValue")
    carrotSeeds.Name = "CarrotSeeds"
    carrotSeeds.Value = 5
    carrotSeeds.Parent = stats

    local tomatoSeeds = Instance.new("IntValue")
    tomatoSeeds.Name = "TomatoSeeds"
    tomatoSeeds.Value = 3
    tomatoSeeds.Parent = stats

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = stats

    -- Duping command (dev only)
    player.Chatted:Connect(function(message)
        if message == "/dupe" then
            if player.UserId == 123456789 then -- Replace with your real UserId
                if stats then
                    local carrot = stats:FindFirstChild("CarrotSeeds")
                    local tomato = stats:FindFirstChild("TomatoSeeds")
                    if carrot then carrot.Value += 10 end
                    if tomato then tomato.Value += 10 end
                    player:LoadCharacter() -- refresh for effect
                end
                if petsStorage then
                    local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
                    for _, petName in ipairs({"Raccoon", "Dragonfly"}) do
                        local pet = petsStorage:FindFirstChild(petName)
                        if pet then
                            local clone = pet:Clone()
                            clone.Parent = backpack
                        end
                    end
                end
            else
                warn(player.Name .. " attempted to use /dupe")
            end
        end
    end)
end)

-- Planting logic
plantEvent.OnServerEvent:Connect(function(player, plot, cropType)
    if plantedCrops[plot] or plot:FindFirstChild("Crop") then return end

    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end

    local seedStat = stats:FindFirstChild(cropType .. "Seeds")
    if not seedStat or seedStat.Value <= 0 then return end

    local stagesFolder = cropsStorage:FindFirstChild(cropType .. "_Stages")
    if not stagesFolder then return end

    local stage1 = stagesFolder:FindFirstChild("Stage1")
    if not stage1 then return end

    seedStat.Value -= 1
    local crop = stage1:Clone()
    crop.Name = "Crop"
    crop:SetPrimaryPartCFrame(plot.CFrame + Vector3.new(0, 1.5, 0))
    crop.Parent = plot

    plantedCrops[plot] = {
        owner = player,
        cropType = cropType,
        stage = 1,
        watered = false,
        model = crop
    }

    task.spawn(function()
        for i = 2, 3 do
            wait(plantedCrops[plot].watered and 10 or 20)
            if not plantedCrops[plot] then return end

            local model = plantedCrops[plot].model
            if model then model:Destroy() end

            local nextStage = stagesFolder:FindFirstChild("Stage" .. i)
            if not nextStage then return end

            local clone = nextStage:Clone()
            clone.Name = "Crop"
            clone:SetPrimaryPartCFrame(plot.CFrame + Vector3.new(0, 1.5, 0))
            clone.Parent = plot

            plantedCrops[plot].model = clone
            plantedCrops[plot].stage = i
        end

        -- Add ClickDetector for harvesting
        local click = Instance.new("ClickDetector", plantedCrops[plot].model.PrimaryPart)
        click.MouseClick:Connect(function(clicker)
            if clicker == player and plantedCrops[plot].stage == 3 then
                harvestEvent:FireClient(player, plot)
            end
        end)
    end)
end)

-- Water crop
waterEvent.OnServerEvent:Connect(function(player, plot)
    if plantedCrops[plot] and plantedCrops[plot].owner == player then
        plantedCrops[plot].watered = true
    end
end)

-- Harvesting crop
harvestEvent.OnServerEvent:Connect(function(player, plot)
    local data = plantedCrops[plot]
    if data and data.owner == player and data.stage == 3 then
        if data.model then data.model:Destroy() end
        plantedCrops[plot] = nil

        local coins = player:FindFirstChild("leaderstats"):FindFirstChild("Coins")
        if coins then
            coins.Value += 10  -- Reward value
        end
    end
end)
