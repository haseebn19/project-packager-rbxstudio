-- [[ INITIALIZE PLUGIN ]]
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Toolbar = plugin:CreateToolbar("Project Packager")

-- Plugin Buttons
local unpackButton = Toolbar:CreateButton("Unpack", 
	"Ungroups the selected folder's contents to their respective destinations",
	"rbxassetid://278543077")
local packButton = Toolbar:CreateButton("Pack",
	"Groups all selected contents into an organized folder",
	"rbxassetid://278544480")

local operationRunning = false

-- [[ SERVICES ]]
local ServerStorage = game:GetService("ServerStorage")
local PackingLogic = require(script.PackingLogic)

-- [[ PACKING LOGIC ]]
local function PackSelection()
	if not operationRunning then
		operationRunning = true
		local selection = Selection:Get()

		if #selection > 0 then
			-- Begin recording changes
			local recordingId = ChangeHistoryService:TryBeginRecording("Pack Selection")
			if not recordingId then
				warn("Failed to begin change recording.")
				operationRunning = false
				return
			end

			local success, err = pcall(function()
				PackingLogic.PackFolder(selection)
			end)

			if success then
				-- Commit the recording
				ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Commit)
			else
				-- Cancel the recording
				ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Cancel)
				warn("Error: " .. err)
			end
		else
			warn("You did not select any items to pack")
		end

		operationRunning = false
	else
		warn("Packager: An operation is already running!")
	end
end
packButton.Click:Connect(PackSelection)

-- [[ UNPACKING LOGIC ]]
local function UnpackSelection()
	if not operationRunning then
		local selection = Selection:Get()
		if #selection == 1 then
			-- Begin recording changes
			local recordingId = ChangeHistoryService:TryBeginRecording("Unpack Selection")
			if not recordingId then
				warn("Failed to begin change recording.")
				operationRunning = false
				return
			end

			local success, err = pcall(function()
				PackingLogic.UnpackFolder(selection[1])
			end)

			if success then
				-- Commit the recording
				ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Commit)
			else
				-- Cancel the recording
				ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Cancel)
				warn("Error: " .. err)
			end
		else
			warn("Select one folder to unpack")
		end
		operationRunning = false
	else
		warn("An operation is already running!")
	end
end
unpackButton.Click:Connect(UnpackSelection)
