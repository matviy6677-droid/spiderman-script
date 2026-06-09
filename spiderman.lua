-- Universal Spider-Man Script (Keyless) - Wall Crawl + Web Swing + Zip
-- Made for Delta / Solara / Wave etc.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local wallClimbEnabled = false
local webConnection = nil

local CLIMB_SPEED = 28
local SWING_FORCE = 165
local ZIP_SPEED = 90

-- Wall Crawling
local function toggleWallClimb()
    wallClimbEnabled = not wallClimbEnabled
    print("🕷️ Wall Crawl: " .. (wallClimbEnabled and "ENABLED" or "DISABLED"))
end

RunService.Heartbeat:Connect(function()
    if not wallClimbEnabled or not root or not humanoid then return end

    local ray = Ray.new(root.Position, root.CFrame.LookVector * 6)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {character})

    if hit then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        root.Velocity = Vector3.new(root.Velocity.X, CLIMB_SPEED, root.Velocity.Z)
        local normal = hit.CFrame.LookVector
        root.CFrame = CFrame.lookAt(root.Position, root.Position - normal)
    end
end)

-- Web Swing
local function shootWeb(targetPos)
    if webConnection then webConnection:Disconnect() end

    local att0 = Instance.new("Attachment", root)
    local att1 = Instance.new("Attachment")
    att1.Position = targetPos
    att1.Parent = workspace.Terrain

    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = Color3.fromRGB(80, 180, 255)
    beam.LightEmission = 1
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.Parent = workspace

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = (targetPos - root.Position).Unit * SWING_FORCE
    bv.Parent = root

    webConnection = RunService.Heartbeat:Connect(function()
        if (root.Position - targetPos).Magnitude < 18 then
            if webConnection then webConnection:Disconnect() end
            if bv then bv:Destroy() end
            if beam then beam:Destroy() end
            if att0 then att0:Destroy() end
            if att1 then att1:Destroy() end
        end
    end)
end

-- Controls
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.F then
        toggleWallClimb()

    elseif input.KeyCode == Enum.KeyCode.Q then
        local mouse = player:GetMouse()
        local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
        local hit, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(ray.Origin, ray.Direction * 700), {character})
        if pos then
            shootWeb(pos)
        end

    elseif input.KeyCode == Enum.KeyCode.E then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, -ZIP_SPEED, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Parent = root
        Debris:AddItem(bv, 2)

    elseif input.KeyCode == Enum.KeyCode.X then
        wallClimbEnabled = false
        if webConnection then webConnection:Disconnect() end
        print("🕷️ Spider-Man abilities DISABLED")
    end
end)

player.CharacterAdded:Connect(function(new)
    character = new
    humanoid = new:WaitForChild("Humanoid")
    root = new:WaitForChild("HumanoidRootPart")
end)

print("🕷️ Spider-Man Script Loaded Successfully!")
print("F - Wall Crawl | Q - Web Swing/Fly | E - Fast Zip Down | X - Off")
