local ISubmissionClientRemote = require("sea.remotes.ISubmissionClientRemote")

---@class sea.FakeSubmissionClientRemote: sea.ISubmissionClientRemote
---@operator call: sea.FakeSubmissionClientRemote
local FakeSubmissionClientRemote = ISubmissionClientRemote + {}

---@param chartfile_data string
---@param replayfile_data string
function FakeSubmissionClientRemote:new(chartfile_data, replayfile_data)
	self.chartfile_data = chartfile_data
	self.replayfile_data = replayfile_data
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function FakeSubmissionClientRemote:getChartfileData(hash)
	return {name = "file.bms", data = self.chartfile_data}
end

---@param events_hash string
---@return string?
---@return string?
function FakeSubmissionClientRemote:getEventsData(events_hash)
	return self.replayfile_data
end

return FakeSubmissionClientRemote
