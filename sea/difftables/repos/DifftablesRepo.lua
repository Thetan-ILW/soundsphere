local IDifftablesRepo = require("sea.difftables.repos.IDifftablesRepo")

---@class sea.DifftablesRepo: sea.IDifftablesRepo
---@operator call: sea.DifftablesRepo
local DifftablesRepo = IDifftablesRepo + {}

---@param models rdb.Models
function DifftablesRepo:new(models)
	self.models = models
end

---@return sea.Difftable[]
function DifftablesRepo:getDifftables()
	return self.models.difftables:select()
end

---@param id integer
---@return sea.Difftable?
function DifftablesRepo:getDifftable(id)
	return self.models.difftables:find({id = id})
end

---@param difftable sea.Difftable
---@return sea.Difftable
function DifftablesRepo:createDifftable(difftable)
	return self.models.difftables:create(difftable)
end

---@param difftable sea.Difftable
---@return sea.Difftable
function DifftablesRepo:updateDifftable(difftable)
	return self.models.difftables:update(difftable, {id = difftable.id})[1]
end

--------------------------------------------------------------------------------

---@param difftable_id integer
---@param hash string
---@param index integer
---@return sea.DifftableChartmeta?
function DifftablesRepo:getDifftableChartmeta(difftable_id, hash, index)
	return self.models.difftable_chartmetas:find({
		difftable_id = assert(difftable_id),
		hash = assert(hash),
		index = assert(index),
	})
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function DifftablesRepo:createDifftableChartmeta(difftable_chartmeta)
	return self.models.difftable_chartmetas:create(difftable_chartmeta)
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function DifftablesRepo:updateDifftableChartmeta(difftable_chartmeta)
	return self.models.difftable_chartmetas:update(difftable_chartmeta, {id = difftable_chartmeta.id})[1]
end

---@param difftable_id integer
---@param hash string
---@param index integer
function DifftablesRepo:deleteDifftableChartmeta(difftable_id, hash, index)
	return self.models.difftable_chartmetas:delete({
		difftable_id = assert(difftable_id),
		hash = assert(hash),
		index = assert(index),
	})
end

return DifftablesRepo
