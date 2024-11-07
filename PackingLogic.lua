-- [[ SERVICES ]]
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")

local module = {}

-- [[ VARIABLES ]]
local operationInProgress = false
local totalItemCount = nil
local itemsProcessed = 0
local toSelect = {}

-- [[ UTILITY FUNCTIONS ]]

-- Resets the progress-tracking variables at the end of each operation
local function _ResetProgressVars()
	totalItemCount = nil
	itemsProcessed = 0
	toSelect = {}
	operationInProgress = false
end

-- Attempts to clone an instance; returns false if cloning fails
local function _TryCloneInstance(instance: Instance)
	local success, clone = pcall(function()
		return instance:Clone()
	end)

	if not success then
		return false
	end
	return clone
end

-- Recursively counts all descendants of an instance or table of instances
local function _CountItems(itemToCount: Folder | {})
	local count = 0
	if typeof(itemToCount) == "Instance" then
		count += 1 + #itemToCount:GetDescendants()
	elseif typeof(itemToCount) == "table" then
		for _, instance: Instance in ipairs(itemToCount) do
			count += _CountItems(instance)
		end
	end
	return count
end

-- [[ PACKING LOGIC ]]

-- Cleans the descendants of each instance in the input table to avoid duplicate packing
local function _CleanDescendants(inputTable)
	local toRemove = {}
	local resultTable = {}

	-- Mark descendants of each instance for removal
	for _, instance in ipairs(inputTable) do
		for _, descendant in ipairs(instance:GetDescendants()) do
			toRemove[descendant] = true
		end
	end

	-- Build a result table that excludes marked descendants
	for _, instance in ipairs(inputTable) do
		if not toRemove[instance] then
			table.insert(resultTable, instance)
		end
	end

	return resultTable
end

-- Attempts to pack instances into a destination folder; creates folders if cloning fails
local function _PackInstances(source: Instance, destination: Instance)
	if source == game then
		warn(source.Name, "cannot be packed. Operation stopped.")
		return
	end

	local clone: Instance = _TryCloneInstance(source)
	if not clone then
		-- Optionally create folders for items that can't be cloned
		local folder = Instance.new("Folder")
		folder.Name = source.Name
		folder.Parent = destination
		warn("Could not pack", source:GetFullName(), ", created folder instead")
		for _, child in ipairs(source:GetChildren()) do
			_PackInstances(child, folder)
		end
	else
		clone.Parent = destination
		itemsProcessed += #clone:GetDescendants()
		print(source:GetFullName(), "cloned to", destination:GetFullName())
	end
	itemsProcessed += 1
	print("Items processed:", itemsProcessed, "/", totalItemCount)
	task.wait()
end

-- Packs selected instances into a "PackedFolder" and stores it in ServerStorage
function module.PackFolder(instancesToPack)
	if operationInProgress then
		warn("An operation is already in progress. Please wait until it's complete.")
		return
	end

	operationInProgress = true
	instancesToPack = _CleanDescendants(instancesToPack)
	totalItemCount = _CountItems(instancesToPack)
	itemsProcessed = 0

	local packedFolder = Instance.new("Folder")
	packedFolder.Name = "PackedFolder"

	-- Builds the folder structure for each instance to pack
	for _, instance in ipairs(instancesToPack) do
		local fullPath = instance:GetFullName()
		local pathParts = string.split(fullPath, ".")
		local currentFolder = packedFolder

		-- Navigate through the path, creating folders as necessary
		for i, part in ipairs(pathParts) do
			if i ~= #pathParts then
				local folder = currentFolder:FindFirstChild(part) or Instance.new("Folder")
				folder.Name = part
				folder.Parent = currentFolder
				currentFolder = folder
			else
				_PackInstances(instance, currentFolder)
			end
		end
	end

	packedFolder.Parent = ServerStorage
	Selection:Set({packedFolder})

	print("Total items processed:", itemsProcessed, "of", totalItemCount)
	_ResetProgressVars()
end

-- [[ UNPACKING LOGIC ]]

-- Recursively unpacks items from the folder into the target destination
local function _UnpackInstances(instancesFolder: Folder, destination: Instance)
	destination = destination or game

	for _, item in ipairs(instancesFolder:GetChildren()) do
		if CollectionService:HasTag(item, "RoPacker_Remove") then
			item.Parent = nil
		else
			local existingChild = destination:FindFirstChild(item.Name)
			if existingChild and item:IsA("Folder") then
				-- Unpacks recursively if a matching folder exists
				_UnpackInstances(item, existingChild)
			else
				print(item:GetFullName(), "unpacked to", destination:GetFullName())
				item.Parent = destination
				table.insert(toSelect, item)
				itemsProcessed += #item:GetDescendants()
			end
		end
		itemsProcessed += 1
		print("Items processed:", itemsProcessed, "/", totalItemCount)
		task.wait()
	end
end

-- Unpacks a packed folder of instances into ServerStorage or a specified destination
function module.UnpackFolder(packedFolder: Folder)
	if operationInProgress then
		warn("An operation is already in progress. Please wait until it's complete.")
		return
	end

	if packedFolder and packedFolder:IsA("Folder") then
		operationInProgress = true
		totalItemCount = _CountItems(packedFolder) - 1 -- Remove parent folder from count
		itemsProcessed = 0
		toSelect = {}

		_UnpackInstances(packedFolder)
		packedFolder.Parent = nil
		Selection:Set(toSelect)

		print("Total items processed:", itemsProcessed, "of", totalItemCount)
		_ResetProgressVars()
	else
		warn(packedFolder, "is not a packed Folder")
	end
end

return module
