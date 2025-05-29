local class = require("class")

---@class sea.IComputeDataProvider
---@operator call: sea.IComputeDataProvider
local IComputeDataProvider = class()

---@param hash string
---@return {name: string, data: string}?
---@return string?
function IComputeDataProvider:getChartData(hash)
	error("not implemented")
end

---@param replay_hash string
---@return string?
---@return string?
function IComputeDataProvider:getReplayData(replay_hash)
	error("not implemented")
end

return IComputeDataProvider
