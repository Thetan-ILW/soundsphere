local class = require("class")
local table_util = require("table_util")
local ModifierRegistry = require("sphere.models.ModifierModel.ModifierRegistry")

---@class sphere.ModifierModel
---@operator call: sphere.ModifierModel
local ModifierModel = class()

local Modifiers = ModifierRegistry.enum

local ModifiersByName = {}
local ModifiersById = {}

for name, id in pairs(Modifiers) do
	local M = require("sphere.models.ModifierModel." .. name)
	ModifiersByName[name] = M
	ModifiersById[id] = M
end

---@param nameOrId string|number?
---@return sphere.Modifier?
function ModifierModel:getModifier(nameOrId)
	return ModifiersByName[nameOrId] or ModifiersById[nameOrId]
end

---@param modifiers table
---@param modifier string
---@param index number
function ModifierModel:add(modifiers, modifier, index)
	local mod = assert(self:getModifier(modifier))
	table.insert(modifiers, index, {
		id = Modifiers[modifier],
		version = mod.version,
		value = mod.defaultValue
	})
end

---@param modifiers table
---@param index number
---@return table?
function ModifierModel:remove(modifiers, index)
	return table.remove(modifiers, index)
end

---@param modifier table
---@param value any
function ModifierModel:setModifierValue(modifier, value)
	modifier.value = value
end

---@param modifier table
---@param delta number
function ModifierModel:increaseModifierValue(modifier, delta)
	local mod = assert(self:getModifier(modifier.id))
	local indexValue = mod:toIndexValue(modifier.value)
	modifier.value = mod:fromIndexValue(indexValue + delta)
end

---@param modifiers table
---@param chart ncdk2.Chart
function ModifierModel:apply(modifiers, chart)
	local obj = {}
	for _, modifier in ipairs(modifiers) do
		local mod = self:getModifier(modifier.id)
		if mod then
			table_util.clear(obj)
			setmetatable(obj, mod)
			obj:apply(modifier, chart)
		end
	end
end

---@param modifiers table
---@param state table
function ModifierModel:applyMeta(modifiers, state)
	local obj = {}
	for _, modifier in ipairs(modifiers) do
		local mod = self:getModifier(modifier.id)
		if mod then
			table_util.clear(obj)
			setmetatable(obj, mod)
			obj:applyMeta(modifier, state)
		end
	end
end

---@param modifiers table
---@return string
function ModifierModel:getString(modifiers)
	local t = {}
	for _, modifier in ipairs(modifiers) do
		local mod = self:getModifier(modifier.id)
		if mod then
			local s, subs = mod:getString(modifier)
			local str = (s or "") .. (subs or "")
			if #str > 0 then
				table.insert(t, str)
			end
		end
	end
	return table.concat(t, " ")
end

---@param modifiers table
function ModifierModel:fixOldFormat(modifiers)
	for _, modifier in ipairs(modifiers) do
		local mod = self:getModifier(modifier.id)
		if mod then
			if type(modifier.value) == "number" and type(mod.defaultValue) == "string" then
				modifier.value = mod:fromIndexValue(modifier.value)
			end
		end
	end
end

return ModifierModel
