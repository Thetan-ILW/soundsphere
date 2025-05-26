local class = require("class")

---@class sphere.IScoreSource
---@operator call: sphere.IScoreSource
local IScoreSource = class()

IScoreSource.score_multiplier = 1
IScoreSource.score_format = "%d"

---@return number
function IScoreSource:getScore()
	error("not implemented")
end

---@return string
function IScoreSource:getScoreString()
	return self.score_format:format(self:getScore() * self.score_multiplier)
end

return IScoreSource
