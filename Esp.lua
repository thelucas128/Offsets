_G.Configuration = _G.Configuration or {
	["Generator"] = {
		Show = true,
		Color = Color3.new(0, 1, 0),
		Shape = "Circle", -- Square,Circle
		Filled = false,
		Radius = 5,--Use radius if Circle/Use Size if Square
	},
	["Palletwrong"] = {
		Show = true,
		Color = Color3.new(0, 0, 1),
		Shape = "Circle", -- Square,Circle
		Filled = false,
		Radius = 5,--Use radius if Circle
	},
	["Killer"] = {
		Show = true,
		Color = Color3.new(1, 0, 0),
		Shape = "Circle", -- Square,Circle
		Filled = false,
		Radius = 4,--Use radius if Circle/Use Size if Square
	},
}

local Players = game:GetService("Players")

local EspLib = {}
EspLib.__index = EspLib

local WorldToScreen = WorldToScreen

function EspLib.new(Type, Properties)
	local self = setmetatable({}, EspLib)
	local drawing = Drawing.new(Type)

	if Properties then
		for prop, value in pairs(Properties) do
			drawing[prop] = value
		end
	end

	self.Drawing = drawing
	self.Visible = drawing.Visible
	return self
end

function EspLib:SetVisible(state)
	if self.Drawing.Visible ~= state then
		self.Drawing.Visible = state
		self.Visible = state
	end
end

function EspLib:SetPosition(pos)
	self.Drawing.Position = pos
end

function EspLib:SetColor(color)
	self.Drawing.Color = color
end

function EspLib:Destroy()
	self.Drawing:Remove()
	self.Drawing = nil
end


local DrawingTable = {}

local Cache = {


}

local Killer = nil

local function GetKiller()
	if Killer then return end
	for i,v in Players:GetChildren() do
		if v.Character:GetAttribute("Chasemusic") then
			Killer = v.Character
			print("Found Killer",v)
		end
	end
end

local function FunctionCache()
	local Map = workspace:FindFirstChild("Map")
	local Utulity = nil
	if Map:FindFirstChild("Rooftop") then
		Map = Map:FindFirstChild("Rooftop")
		Utulity = Map:FindFirstChild("Nature")
	end


	if Utulity then
		for i,v in Map:GetChildren() do
			if (v.Name == "Generator" and _G.Configuration.Generator.Show) then
				--print(v)
				table.insert(Cache,v)
			end
		end

		for i,v in Utulity:GetChildren() do
			if (v.Name == "Palletwrong" and _G.Configuration.Palletwrong.Show) then
				table.insert(Cache,v)
			end
		end
	else
		for i,v in Map:GetChildren() do
			if (v.Name == "Generator" and _G.Configuration.Generator.Show) or (v.Name == "Palletwrong" and Configuration.Palletwrong.Show)  then
				--print(v)
				table.insert(Cache,v)
			end
		end
	end

end


while true do
	local map = workspace:FindFirstChild("Map")
	if not map then continue end
	if workspace:FindFirstChild("Map"):FindFirstChildOfClass("Model") and workspace:FindFirstChild("Map"):FindFirstChildOfClass("Model").Parent == nil then
		Killer = nil
		for i,v in pairs(Cache) do
			table.clear(Cache)
			for _, v in pairs(DrawingTable) do
				v:Destroy()
			end
			table.clear(DrawingTable)
		end
		return
	end

	if #Cache <= 0 then
		FunctionCache()
	end

	for i,v in Cache do

		if not DrawingTable[v.Address] then
			local esp = EspLib.new(_G.Configuration[v.Name].Shape, {
				Color =  _G.Configuration[v.Name].Color,
				Size = _G.Configuration[v.Name].Size,
				Radius = _G.Configuration[v.Name].Radius,
				Filled = _G.Configuration[v.Name].Filled,
				Visible = true
			})

			DrawingTable[v.Address] = esp
		end

		local hitbox = v:FindFirstChild("HitBox") or v:FindFirstChild("HumanoidRootPart")


		if hitbox then
			local screenPos = WorldToScreen(hitbox.Position)
			if screenPos then
				DrawingTable[v.Address]:SetPosition(screenPos)
				DrawingTable[v.Address]:SetVisible(true)
			end
		else
			if DrawingTable[v.Address] then
				DrawingTable[v.Address]:Destroy()
				DrawingTable[v.Address] = nil
			end
		end
	end


	spawn(function()
		if not _G.Configuration.Killer.Show then return end
		GetKiller()
		if Killer then
			if not DrawingTable["Killer"] then
				local esp = EspLib.new(_G.Configuration["Killer"].Shape, {
					Color =  _G.Configuration["Killer"].Color,
					Size = _G.Configuration["Killer"].Size,
					Radius = _G.Configuration["Killer"].Radius,
					Filled = _G.Configuration["Killer"].Filled,
					Visible = true
				})

				DrawingTable["Killer"] = esp
			end



			local RootPart = Killer:FindFirstChild("HumanoidRootPart")

			if RootPart and DrawingTable["Killer"] then
				DrawingTable["Killer"]:SetPosition(WorldToScreen(RootPart.Position))
			end
		end
	end)

	task.wait()
end
