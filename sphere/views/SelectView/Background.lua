local BackgroundView = require("sphere.views.BackgroundView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local Layout = require("sphere.views.SelectView.Layout")

---@param self table
local function Background(self)
	local w, h = Layout:move("base")

	local graphics = self.game.configModel.configs.settings.graphics
	local dim = graphics.dim.select
	BackgroundView.ui = self.ui

	GaussianBlurView:draw(graphics.blur.select)
	BackgroundView:draw(w, h, dim, 0.01)
	GaussianBlurView:draw(graphics.blur.select)

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)
end

return Background
