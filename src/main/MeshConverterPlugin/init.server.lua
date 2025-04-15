--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

-- Load dependencies
local MeshConverter = require(script.MeshConverter)

-- Setup toolbar
local toolbar = plugin:CreateToolbar("Fate Forge Mesh Converter")

-- Create conversion buttons
local specialMeshButton: PluginToolbarButton = toolbar:CreateButton("Convert to SpecialMesh", "Convert MeshPart to SpecialMesh", "rbxassetid://84252334879354")
local meshPartButton: PluginToolbarButton = toolbar:CreateButton("Convert to MeshPart", "Convert SpecialMesh to MeshPart", "rbxassetid://125809798223918")

-- Buttons are not needed when the viewport is hidden.
specialMeshButton.ClickableWhenViewportHidden = false
meshPartButton.ClickableWhenViewportHidden = false

local function unloadPlugin()
	-- Process unloading
	print("Thank you for using the Mesh Converter plugin by Fate Forge!")
	toolbar:Destroy()
end

local function meshPartToSpecialMeshClicked()
	local instances: {Instance} = Selection:Get()
	
	-- Deactivate pressed state
	specialMeshButton.Enabled = false
	specialMeshButton:SetActive(false)
	specialMeshButton.Enabled = true
	
	-- Cancel if no Instances were selected
	if #instances == 0 then
		return
	end
	
	-- List of confirmed MeshParts containing SpecialMesh
	local meshParts: {MeshPart} = {}
	
	-- Check that all objects are compatible
	for _,instance: Instance in instances do
		assert(instance:IsA('MeshPart'), `One (or more) instances are not a MeshPart. Conflicting Instance: {instance:GetFullName()}`)
		assert(not instance:FindFirstChildOfClass('SpecialMesh'), `MeshParts cannot have a SpecialMesh within them. Conflicting MeshPart: {instance:GetFullName()}`)
		table.insert(meshParts, instance)
	end
	
	-- List to keep track of new SpecialMesh parts
	local specialMeshParts: {BasePart} = {}
	
	-- Convert MeshPart to SpecialMesh
	local specialMeshPart: BasePart
	for _, meshPart: MeshPart in meshParts do
		-- Convert MeshPart to SpecialMesh part
		specialMeshPart = MeshConverter:CreateSpecialMeshFromMeshPart(meshPart)
		
		-- Add to list of converted instances
		table.insert(specialMeshParts, specialMeshPart)
		
		-- Parent to original mesh
		specialMeshPart.Parent = meshPart.Parent
		
		-- Copy children into new part
		for _,child: Instance in meshPart:GetChildren() do
			child.Parent = specialMeshPart
		end
		
		-- Remove original mesh from GameModel
		meshPart.Parent = nil
	end
	
	-- Log the change as a waypoint
	ChangeHistoryService:SetWaypoint(`Converted {#specialMeshParts} MeshPart(s) into SpecialMesh`)
	
	-- Select converted meshes
	Selection:Set(specialMeshParts)
end

local function specialMeshToMeshPartClicked()
	local selection: {Instance} = Selection:Get()
	
	-- Deactivate pressed state
	meshPartButton.Enabled = false
	meshPartButton:SetActive(false)
	meshPartButton.Enabled = true
	
	-- Cancel if no SpecialMesh were selected
	if #selection == 0 then
		return
	end
	
	-- List of confirmed BaseParts containing SpecialMesh
	local specialMeshParts: {BasePart} = {}
	
	-- Indictator to ensure that only one SpecialMesh exists in a part.
	local foundOneSpecialMesh: boolean = false
	
	for _, instance: Instance in selection do
		-- If SpecialMesh was selected, instead select the parent part.
		if instance:IsA('SpecialMesh') then
			assert(instance.Parent and instance.Parent:IsA('BasePart'), `Selected SpecialMesh(s) need to be parented to a BasePart. Conflicting SpecialMesh: {instance:GetFullName()}`)
			instance = instance.Parent
		end
		
		-- If by now the selection isn't a BasePart, provide an error to the user.
		assert(instance:IsA('BasePart'), `Only SpecialMesh and BaseParts can be selected. Conflicting instance: {instance:GetFullName()}`)
		
		-- Reset indicator to false
		foundOneSpecialMesh = false
		
		for _,child in instance:GetChildren() do
			if child:IsA('SpecialMesh') then
				-- Check if another SpecialMesh was found in the part and throw an error accordingly.
				assert(not foundOneSpecialMesh, "Parts must contain only one SpecialMesh.")
				-- Mark indicator as true to prevent future duplicates
				foundOneSpecialMesh = true
			end
		end
		
		-- Handle the case that no SpecialMesh was found in the BasePart
		assert(foundOneSpecialMesh, "Parts must contain a SpecialMesh.")
		
		-- Sanity check is successful! Add to list of specialmesh parts.
		table.insert(specialMeshParts, instance)
	end
	
	-- List to keep track of new MeshParts
	local meshParts: {MeshPart} = {}
	
	-- Convert SpecialMesh to MeshPart
	local meshPart: MeshPart
	for _, basePart: BasePart in specialMeshParts do
		-- Convert SpecialMesh part to MeshPart.
		meshPart = MeshConverter:CreateMeshPartFromSpecialMesh(basePart)
		
		-- Add to list of converted instances
		table.insert(meshParts, meshPart)
		
		-- Parent to original specialmesh part
		meshPart.Parent = basePart.Parent
		
		-- Copy children into new part
		for _,child in basePart:GetChildren() do
			if not child:IsA('SpecialMesh') then
				child.Parent = meshPart
			end
		end
		
		-- Remove original mesh from GameModel
		basePart.Parent = nil
	end
	ChangeHistoryService:SetWaypoint(`Converted {#meshParts} SpecialMesh into MeshPart`)
	Selection:Set(meshParts)
end

plugin.Unloading:Once(unloadPlugin)
specialMeshButton.Click:Connect(meshPartToSpecialMeshClicked)
meshPartButton.Click:Connect(specialMeshToMeshPartClicked)