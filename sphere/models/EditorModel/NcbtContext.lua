local rbtree = require("rbtree")
local ncbt = require("ncbt")
local class = require("class")
local Visual = require("chartedit.Visual")

---@class sphere.NcbtContext
---@operator call: sphere.NcbtContext
local NcbtContext = class()

function NcbtContext:load()
	self.onsets = nil

	self.onsetsDeltaDist = nil
	self.tempo = nil
	self.offset = nil
	self.bins = nil
	self.binsSize = nil
end

---@param soundData audio.SoundData
function NcbtContext:detect(soundData)
	self.duration = soundData:getDuration()

	local onsets = ncbt.onsets(soundData)

	local tree = rbtree.new()
	for _, time in ipairs(onsets) do
		tree:insert(time)
	end
	self.onsets = tree

	local out = ncbt.tempo_offset(onsets)

	self.onsetsDeltaDist = out.onsetsDeltaDist
	self.tempo = out.tempo
	self.offset = out.offset
	self.bins = out.bins
	self.binsSize = out.binsSize
end

---@param layer chartedit.Layer
function NcbtContext:apply(layer)
	if not self.tempo then
		return
	end

	local beatDuration = 60 / self.tempo
	local beats = math.floor((self.duration - self.offset) / beatDuration)
	local lastOffset = beats * beatDuration + self.offset

	layer:new()
	layer.points:initDefault()
	local visual = Visual()
	layer.visuals.main = visual

	local p = layer.points:getFirstPoint()
	visual:getPoint(p)
	p._interval:new(self.offset, beats)

	local p = layer.points:getLastPoint()
	visual:getPoint(p)
	p._interval:new(lastOffset, 1)

end

return NcbtContext
