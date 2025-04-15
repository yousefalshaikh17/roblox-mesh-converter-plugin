--!strict

local InsertService = game:GetService('InsertService')

-- Basepart properties for copying
-- @TODO: When new type solver is out, update to keyof BasePart. (https://github.com/luau-lang/rfcs/pull/16)
local basePartProperties: {string} = {
	"Anchored",
	"AssemblyAngularVelocity",
	"AssemblyLinearVelocity",
	"BackSurface",
	"BottomSurface",
	"BrickColor",
	"CFrame",
	"CanCollide",
	"CanQuery",
	"CanTouch",
	"CastShadow",
	"CollisionGroup",
	"Color",
	"CustomPhysicalProperties",
	"EnableFluidForces",
	"FrontSurface",
	"LeftSurface",
	"LocalTransparencyModifier",
	"Locked",
	"Massless",
	"Material",
	"MaterialVariant",
	"PivotOffset",
	"Reflectance",
	"RightSurface",
	"RootPriority",
	"Size",
	"TopSurface",
	"Transparency",
	"Name"
}

local function generateMeshPartFromMeshId(meshId: string): MeshPart
	return InsertService:CreateMeshPartAsync(meshId, Enum.CollisionFidelity.Hull, Enum.RenderFidelity.Automatic)
end

local function generateSpecialMeshFromMeshPart(meshPart: MeshPart): SpecialMesh
	local specialMesh: SpecialMesh = Instance.new('SpecialMesh')
	specialMesh.MeshType = Enum.MeshType.FileMesh
	specialMesh.MeshId = meshPart.MeshId
	specialMesh.TextureId = meshPart.TextureID
	
	-- Scale is the size of the part divided by the original mesh size
	specialMesh.Scale = meshPart.Size / meshPart.MeshSize
	
	return specialMesh
end

local function copyBasePartProperties(sourceBasePart: BasePart, targetBasePart: BasePart): ()
	-- @TODO: When new type solver is out, update to keyof BasePart and remove any.
	for _,property: string in basePartProperties do
		(targetBasePart :: any)[property] = (sourceBasePart :: any)[property]
	end
end


-- Initialize Converter


local module = {}

function module:CreateSpecialMeshFromMeshPart(meshPart: MeshPart): Part
	if not meshPart:IsA('MeshPart') then
		error("Input is not a MeshPart.")
	end
	local specialMesh: SpecialMesh = generateSpecialMeshFromMeshPart(meshPart)
	local part: Part = Instance.new('Part')
	copyBasePartProperties(meshPart, part)
	specialMesh.Parent = part
	return part
end

function module:CreateMeshPartFromSpecialMesh(part: BasePart): MeshPart
	if part:IsA('MeshPart') then
		error("Input is already a MeshPart.")
	end	

	-- Find SpecialMesh
	local originalMesh: SpecialMesh? = part:FindFirstChildOfClass('SpecialMesh')
	if not originalMesh then
		error("No SpecialMesh found.")
	end

	-- Create new MeshPart
	local newPart: MeshPart = generateMeshPartFromMeshId(originalMesh.MeshId)
	copyBasePartProperties(part, newPart)

	-- Apply mesh details
	newPart.TextureID = originalMesh.TextureId
	newPart.Size = originalMesh.Scale * newPart.MeshSize
	
	return newPart
end


return module
