local DropGrabV4Btn = createGrayButton("DROP/GRAB V4.0")
DropGrabV4Btn.MouseButton1Click:Connect(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local player = Players.LocalPlayer
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InventoryHelper"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local dropButton = Instance.new("TextButton")
    dropButton.Name = "Drop"
    dropButton.Size = UDim2.new(0, 100, 0, 40)
    dropButton.Position = UDim2.new(0, 10, 1, -50)
    dropButton.AnchorPoint = Vector2.new(0, 1)
    dropButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropButton.Text = "DROP"
    dropButton.Visible = false
    dropButton.BackgroundTransparency = 0.3
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0.5, 0)
    dropCorner.Parent = dropButton
    dropButton.Parent = screenGui
    
    local grabButton = Instance.new("TextButton")
    grabButton.Name = "Grab"
    grabButton.Size = UDim2.new(0, 100, 0, 40)
    grabButton.Position = UDim2.new(1, -110, 1, -50)
    grabButton.AnchorPoint = Vector2.new(1, 1)
    grabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
    grabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    grabButton.Text = "GRAB"
    grabButton.Visible = true
    grabButton.BackgroundTransparency = 0.3
    local grabCorner = Instance.new("UICorner")
    grabCorner.CornerRadius = UDim.new(0.5, 0)
    grabCorner.Parent = grabButton
    grabButton.Parent = screenGui
    
    local deleteButton = Instance.new("TextButton")
    deleteButton.Name = "DeleteScript"
    deleteButton.Size = UDim2.new(0, 40, 0, 40)
    deleteButton.Position = UDim2.new(0.5, -20, 0, 10)
    deleteButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    deleteButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    deleteButton.Text = "X"
    deleteButton.TextScaled = true
    deleteButton.BackgroundTransparency = 0.2
    deleteButton.ZIndex = 10
    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0.2, 0)
    deleteCorner.Parent = deleteButton
    deleteButton.Parent = screenGui
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        deleteButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    deleteButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = deleteButton.Position
    
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    deleteButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            update(input)
        end
    end)
    
    deleteButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        isGrabbing = false
        grabConnection = nil
    end)
    
    local currentTool = nil
    local isGrabbing = false
    local grabConnection = nil
    local lastGrabTime = 0
    local GRAB_COOLDOWN = 0.5
    
    local function dropTool()
        if currentTool then
            currentTool.Parent = workspace
    
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    currentTool.Handle.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
                end
            end
    
            currentTool = nil
            dropButton.Visible = false
        end
    end
    
    local function collectTools()
        if not isGrabbing or not player.Character then return end
    
        local currentTime = tick()
        if currentTime - lastGrabTime < GRAB_COOLDOWN then return end
        lastGrabTime = currentTime
    
        for _, tool in ipairs(workspace:GetChildren()) do
            if tool:IsA("Tool") and tool.Parent == workspace then
                tool.Parent = player.Backpack
            end
        end
    end
    
    local function updateEquippedTool()
        local character = player.Character
        if not character then
            currentTool = nil
            dropButton.Visible = false
            return
        end
    
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") then
                currentTool = item
                dropButton.Visible = true
                return
            end
        end
    
        currentTool = nil
        dropButton.Visible = false
    end
    
    local function setupCharacter(character)
        currentTool = nil
        dropButton.Visible = false
        grabButton.Visible = true
    
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                currentTool = child
                dropButton.Visible = true
            end
        end)
    
        character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                updateEquippedTool()
            end
        end)
    
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            dropButton.Visible = false
            grabButton.Visible = false
            isGrabbing = false
            grabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
            grabButton.Text = "GRAB"
    
            if grabConnection then
                grabConnection:Disconnect()
                grabConnection = nil
            end
        end)
    end
    
    if player.Character then
        setupCharacter(player.Character)
        updateEquippedTool()
    end
    
    player.CharacterAdded:Connect(setupCharacter)
    player.CharacterRemoving:Connect(function()
        dropButton.Visible = false
        grabButton.Visible = false
        currentTool = nil
    end)
    
    RunService.Heartbeat:Connect(function()
        if player.Character then
            updateEquippedTool()
        else
            dropButton.Visible = false
            grabButton.Visible = false
        end
    end)
    
    dropButton.MouseButton1Click:Connect(dropTool)
    
    grabButton.MouseButton1Click:Connect(function()
        if not player.Character then return end
    
        isGrabbing = not isGrabbing
    
        if isGrabbing then
            grabButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
            grabButton.Text = "GRABBING"
    
            grabConnection = RunService.Heartbeat:Connect(collectTools)
        else
            grabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
            grabButton.Text = "GRAB"
    
            if grabConnection then
                grabConnection:Disconnect()
                grabConnection = nil
            end
        end
    end)
    
    print("Drop/Grab v4.0 запущен")
end)
 
