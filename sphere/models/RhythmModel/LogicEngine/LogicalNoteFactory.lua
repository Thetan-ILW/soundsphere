local ShortLogicalNote = require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")
local LongLogicalNote = require("sphere.models.RhythmModel.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

local notes = {
	ShortNote = {ShortLogicalNote, true, true, true},
	LongNoteStart = {LongLogicalNote, true, true, true},
	LaserNoteStart = {LongLogicalNote, true, true, true},
	DrumrollNoteStart = {LongLogicalNote, true, true, false},
	LineNoteStart = {ShortLogicalNote},
	SoundNote = {ShortLogicalNote},
	ImageNote = {ShortLogicalNote},
}

---@param note ncdk2.Note
---@return sphere.LogicalNote?
function LogicalNoteFactory:getNote(note)
	local classAndData = notes[note.noteType]
	if not classAndData then
		return
	end

	local isPlayable = classAndData[2]
	local isScorable = classAndData[3]
	local isInputMatchable = classAndData[4]
	return classAndData[1](note, isPlayable, isScorable, isInputMatchable)
end

return LogicalNoteFactory
