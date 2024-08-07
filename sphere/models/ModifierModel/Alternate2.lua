local Modifier = require("sphere.models.ModifierModel.Modifier")
local Alternate = require("sphere.models.ModifierModel.Alternate")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.Alternate2: sphere.Modifier
---@operator call: sphere.Alternate2
local Alternate2 = Modifier + {}

Alternate2.name = "Alternate2"

Alternate2.defaultValue = "key"
Alternate2.values = {"key", "scratch"}

Alternate2.description = "1 1 1 1 -> 1 1 2 2, doubles the input mode"

---@param config table
---@return string
---@return string
function Alternate2:getString(config)
	return "Alt", "2" .. config.value:sub(1, 1):upper()
end

Alternate2.applyMeta = Alternate.applyMeta

---@param config table
---@param chart ncdk2.Chart
function Alternate2:apply(config, chart)
	local inputMode = chart.inputMode

	local inputType = config.value
	if not inputMode[inputType] then
		return
	end

	---@type number[]
	local inputAlternate = {}

	local new_notes = Notes()
	for _, note in chart.notes:iter() do
		local _inputType, inputIndex = InputMode:splitInput(note.column)
		if _inputType ~= inputType then
			new_notes:insert(note)
		elseif _inputType and inputIndex then
			inputAlternate[inputIndex] = inputAlternate[inputIndex] or 3
			local state = inputAlternate[inputIndex]

			local isStartNote = note.noteType == "ShortNote" or note.noteType == "LongNoteStart"
			if isStartNote then
				state = (state + 1) % 4
				inputAlternate[inputIndex] = state
			end

			local plusColumn = state < 2 and 1 or 2
			local newInputIndex = (inputIndex - 1) * 2 + plusColumn

			local column = _inputType .. newInputIndex
			if note.noteType == "ShortNote" then
				note.column = column
				new_notes:insert(note)
			elseif note.noteType == "LongNoteStart" then
				note.column = column
				note.endNote.column = column
				new_notes:insert(note)
				new_notes:insert(note.endNote)
			end
		end
	end
	chart.notes = new_notes

	inputMode[inputType] = inputMode[inputType] * 2

	chart:compute()
end

return Alternate2
