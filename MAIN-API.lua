local HttpsService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local InjectStatus = false

local StartInjecting = Instance.new("BindableFunction")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:FindFirstChild("PlayerGui")

local NoClippedParts = {}
local IsNoClip = false

local function ViewInventory(Player)
	if game.Players:FindFirstChild(Player) then
		local Player = game.Players:FindFirstChild(Player)
		local Items = {}

		for _, Item in pairs(Player.Backpack:GetChildren()) do
			table.insert(Items, Item.Name)
		end

		local Character = Player.Character
		if Character then
			local EquippedItem = Character:FindFirstChildWhichIsA("Tool")
			if EquippedItem then
				table.insert(Items, EquippedItem.Name)
			end
		end

		local Text = string.format("%s Inventory : ", Player.Name)

		for _, Item in pairs(Items) do
			Text = Text..Item.." "
		end

		StarterGui:SetCore("SendNotification", {
			Title = "PolaBeax - View Inventory",
			Text = Text,
			Duration = 10,
		})
	else
		StarterGui:SetCore("SendNotification", {
			Title = "PolaBeax - View Inventory",
			Text = "Invaild player!",
			Duration = 5,
		})
	end
end

local function ToggleFly()
	-- Press E to toggle

	repeat wait()
	until Player and game.Players.LocalPlayer.Character and (Player.Character:FindFirstChild("UpperTorso") or Player.Character:FindFirstChild("Torso")) and Player.Character:findFirstChild("Humanoid")
	local mouse = game.Players.LocalPlayer:GetMouse()
	repeat wait() until mouse
	local plr = game.Players.LocalPlayer
	local UpperTorso = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso") 
	local flying = true
	local deb = true
	local ctrl = {f = 0, b = 0, l = 0, r = 0}
	local lastctrl = {f = 0, b = 0, l = 0, r = 0}
	local maxspeed = 50
	local speed = 0

	function Fly()
		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		repeat wait()
			plr.Character.Humanoid.PlatformStand = true
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0.1,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		until not flying
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
	end
	
	local onKeyDown
	onKeyDown = mouse.KeyDown:connect(function(key)
		if key:lower() == "l" then
			if flying then flying = false onKeyDown:Disconnect()
			end
		elseif key:lower() == "w" then
			ctrl.f = 1
		elseif key:lower() == "s" then
			ctrl.b = -1
		elseif key:lower() == "a" then
			ctrl.l = -1
		elseif key:lower() == "d" then
			ctrl.r = 1
		end
	end)
	
	local onKeyUp
	onKeyUp = mouse.KeyUp:connect(function(key)
		if flying == true then
			if key:lower() == "w" then
				ctrl.f = 0
			elseif key:lower() == "s" then
				ctrl.b = 0
			elseif key:lower() == "a" then
				ctrl.l = 0
			elseif key:lower() == "d" then
				ctrl.r = 0
			end
		else
			onKeyUp:Disconnect()
		end
	end)
	Fly()
end

local function ExecuteString(String)
	if string.sub(String, 0, 9) == "WalkSpeed" then
		local Speed = string.sub(String, 10, -1)
		Speed = string.gsub(Speed, ">", "")
		Speed = tonumber(Speed)
		
		local Character = Player.Character
		if Character then
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.WalkSpeed = Speed
				
				StarterGui:SetCore("SendNotification", {
					Title = "PolaBeax - WalkSpeed",
					Text = "WalkSpeed change to "..tostring(Speed),
					Duration = 5,
				})

			end
		end
	elseif string.sub(String, 0, 8) == "JumpHeight" then
		local High = string.sub(String, 9, -1)
		High = string.gsub(High, ">", "")
		High = tonumber(High)

		local Character = Player.Character
		if Character then
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.UseJumpPower = true
				Humanoid.JumpPower = High

				StarterGui:SetCore("SendNotification", {
					Title = "PolaBeax - JumpHeight",
					Text = "JumpHeight change to "..tostring(High),
					Duration = 5,
				})
			end
		end
	elseif string.sub(String, 0, 13) == "ViewInventory" then
		local Target = string.sub(String, 14, -1)
		Target = string.gsub(Target, ">", "")
		Target = string.gsub(Target, " ", "")
		
		ViewInventory(Target)
	elseif string.sub(String, 0, 3) == "fly" then
		spawn(function()
			ToggleFly()
		end)
		
		StarterGui:SetCore("SendNotification", {
			Title = "PolaBeax - Fly",
			Text = "Fly Enabled! Click [L] to unfly!",
			Duration = 5,
		})
	elseif string.sub(String, 0, 6) == "noclip" then
		if IsNoClip == false then
			for _, Part in pairs(workspace:GetDescendants()) do
				local ColSuc, Die = pcall(function()
					if Part.CanCollide == true then
						table.insert(NoClippedParts, Part)
						Part.CanCollide = false
					end
				end)
			end
			
			StarterGui:SetCore("SendNotification", {
				Title = "PolaBeax - NoClip",
				Text = "NoClip enabled! Use the command again to disable!",
				Duration = 5,
			})
			
			IsNoClip = true
		else
			for _, CollidedPart in pairs(NoClippedParts) do
				if CollidedPart then
					local ColSuc, Die = pcall(function()
						CollidedPart.CanCollide = true
					end)
				end
			end
			
			StarterGui:SetCore("SendNotification", {
				Title = "PolaBeax - NoClip",
				Text = "NoClip disabled! Use the command again to enable!",
				Duration = 5,
			})
			
			IsNoClip = false
		end
	end
end

local function CreateInstance(TypeName, Parent)

	local Instanc = Instance.new(TypeName)
	Instanc.Name = HttpsService:GenerateGUID(false)
	Instanc.Parent = Parent
	
	return Instanc
	
end

local function SetDraggable(UI)
	local UserInputService = game:GetService("UserInputService")

	local gui = UI

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

local function LoadAttributes(Instanc, Properties)
	for Name, Type in pairs(Properties) do
		Instanc[Name] = Type
	end
end

function StartInjecting.OnInvoke(Respone)
	local success, err = pcall(function()
		if Respone == "Yes" then
			local Injection = 0

			StarterGui:SetCore("SendNotification", {
				Title = "PolaBeax",
				Text = "Thank you for using our script, have a great day!",
				Duration = 5,
			})

			local StartUpGui = CreateInstance("ScreenGui", CoreGui)

			local MainFrame = CreateInstance("Frame", StartUpGui)
			MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			MainFrame.BorderSizePixel = 0
			MainFrame.Position = UDim2.fromScale(0.313, 0.305)
			MainFrame.Size = UDim2.fromScale(0.234, 0.091)

			local Title = CreateInstance("TextLabel", MainFrame)
			Title.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
			Title.BorderSizePixel = 0
			Title.Position = UDim2.fromScale(0, 0)
			Title.Size = UDim2.fromScale(1, 0.358)
			Title.Text = " PolaBeax"
			Title.Font = Enum.Font.Legacy
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextScaled = true
			Title.TextXAlignment = Enum.TextXAlignment.Left

			SetDraggable(MainFrame)

			local StatusLabel = CreateInstance("TextLabel", MainFrame)
			StatusLabel.BackgroundTransparency = 1
			StatusLabel.BorderSizePixel = 0
			StatusLabel.Position = UDim2.fromScale(0.656, 0)
			StatusLabel.Size = UDim2.fromScale(0.344, 0.358)
			StatusLabel.Text = "Injecting"
			StatusLabel.Font = Enum.Font.Legacy
			StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			StatusLabel.TextScaled = true
			StatusLabel.TextXAlignment = Enum.TextXAlignment.Right

			spawn(function()
				local DotCounter = 0

				while InjectStatus == false and wait(0.5) do
					if DotCounter == 0 then
						StatusLabel.Text = "Injecting."
						DotCounter = 1
					elseif DotCounter == 1 then
						StatusLabel.Text = "Injecting.."
						DotCounter = 2
					elseif DotCounter == 2 then
						StatusLabel.Text = "Injecting..."
						DotCounter = 3
					elseif DotCounter == 3 then
						StatusLabel.Text = "Injecting"
						DotCounter = 0
					end
				end
			end)

			local CounterOutside = CreateInstance("Frame", MainFrame)
			CounterOutside.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
			CounterOutside.BorderColor3 = Color3.fromRGB(255, 255, 255)
			CounterOutside.Position = UDim2.fromScale(0.05, 0.503)
			CounterOutside.Size = UDim2.fromScale(0.896, 0.349)

			local MainCounter = CreateInstance("Frame", CounterOutside)
			MainCounter.BackgroundColor3 = Color3.fromHSV(0.333333, 1, 1)
			MainCounter.BorderSizePixel = 0
			MainCounter.Position = UDim2.new(0, 0, 0, 0)
			MainCounter.Size = UDim2.new(0, 0, 1, 0)

			local speed = 15 --Change to speed you want
			while true and InjectStatus == false do
				for i = 0,1,0.001*speed do
					MainCounter.BackgroundColor3 = Color3.fromHSV(i,1,1) --creates a color using i
					Injection += math.random(3, 6) / 10
					MainCounter.Size = UDim2.fromScale(Injection / 100, 1)

					if Injection >= 100 then
						InjectStatus = true

						break
					end

					wait()
				end
			end
			
			
			TweenService:Create(Title, TweenInfo.new(1), {TextTransparency = 1}):Play()
			TweenService:Create(StatusLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
			
			TweenService:Create(MainFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
			TweenService:Create(Title, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
			TweenService:Create(StatusLabel, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
			TweenService:Create(CounterOutside, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
			TweenService:Create(MainCounter, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
			
			StarterGui:SetCore("SendNotification", {
				Title = "PolaBeax",
				Text = "Injection Completed!",
				Duration = 5
			})
			wait(2)
			
			StartUpGui:ClearAllChildren()
			
			local MainFrame = CreateInstance("Frame", StartUpGui)
			LoadAttributes(MainFrame, {
				Position = UDim2.new(0.1166489943862,0,0.24364407360554,0);
				Size = UDim2.new(0.30752915143967,0,0.18855932354927,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(3/17,3/17,3/17);
			})
			SetDraggable(MainFrame)
			
			local Title = CreateInstance("TextLabel", MainFrame)
			LoadAttributes(Title, {
				TextWrapped = true;
				TextColor3 = Color3.new(1,1,1);
				Text = " PolaBeax";
				FontSize = Enum.FontSize.Size14;
				Size = UDim2.new(1.0241379737854,0,0.26996654272079,0);
				BackgroundTransparency = 1;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextSize = 14;
				BackgroundColor3 = Color3.new(1,1,1);
				TextScaled = true;
				TextWrap = true;
			})
			
			local CodeBox = CreateInstance("TextBox", MainFrame)
			LoadAttributes(CodeBox, {
				FontSize = Enum.FontSize.Size24;
				TextColor3 = Color3.new(178/255,178/255,178/255);
				ClearTextOnFocus = false;
				Text = "";
				PlaceholderColor3 = Color3.new(178/255,178/255,178/255);
				TextXAlignment = Enum.TextXAlignment.Left;
				TextSize = 20;
				Font = Enum.Font.SourceSans;
				PlaceholderText = "Welcome to PolaBeax Version 1.4";
				Position = UDim2.new(0.024137930944562,0,0.37840032577515,0);
				Size = UDim2.new(0,270,0,23);
				TextYAlignment = Enum.TextYAlignment.Top;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(13/51,13/51,13/51);
			})
			
			local ExecuteButton = CreateInstance("TextButton", MainFrame)
			LoadAttributes(ExecuteButton, {
				TextWrapped = true;
				TextColor3 = Color3.new(1,1,1);
				Text = "Execute";
				TextSize = 14;
				Size = UDim2.new(0,74,0,16);
				Font = Enum.Font.SourceSans;
				FontSize = Enum.FontSize.Size14;
				Position = UDim2.new(0.69975864887238,0,0.75162237882614,0);
				BackgroundColor3 = Color3.new(13/51,13/51,13/51);
				TextScaled = true;
				BorderSizePixel = 0;
				TextWrap = true;
			})
			
			ExecuteButton.MouseButton1Click:Connect(function()
				local suc, er = pcall(function()
					ExecuteString(CodeBox.Text)
				end)
				
				if er then
					StarterGui:SetCore("SendNotification", {
						Title = "PolaBeax",
						Text = "Invaid command!",
						Duration = 5
					})
				end
			end)
		end
	end)
	
	if err then
		StarterGui:SetCore("SendNotification", {
			Title = "PolaBeax",
			Text = "An error has blocked the script from running, we sorry for this problem!",
			Duration = 5
		})
	end
end

StarterGui:SetCore("SendNotification", {
	Title = "Inject Request",
	Text = "Are you sure you want to inject PolaBeaX to this game?",
	Duration = 25,
	Callback = StartInjecting,
	Button1 = "Yes",
	Button2 = "No"
})
