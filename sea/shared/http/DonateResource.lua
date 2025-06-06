local IResource = require("web.framework.IResource")

---@class sea.DonateResource: web.IResource
---@operator call: sea.DonateResource
local DonateResource = IResource + {}

DonateResource.routes = {
	{"/donate", {
		GET = "getPage",
	}},
}

---@param views web.Views
function DonateResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DonateResource:getPage(req, res, ctx)
	self.views:render_send(res, "sea/shared/http/donate.etlua", ctx, true)
end

return DonateResource
