local Page = {}

local Gui = _G("classes.gui.Gui")
Gui:create("Page", Page)

local pages = {}

function Page:open()
	if pages[#pages] == self then
		warn("Attempt to open alread-open page")
		return
	end
	table.insert(pages, self)

	for _, other in ipairs(pages) do
		other.instance.Visible = false
	end

	if self:hasBindings("show") then
		self:call("show")
	else
		self.instance.Visible = true
	end

	self:call("open")
end

function Page:close()
	if pages[#pages] ~= self then
		warn("Attempt to close non-active page")
		return
	end

	table.remove(pages, #pages)
	self.instance.Visible = false

	local newActivePage = pages[#pages]
	if newActivePage then
		newActivePage.instance.Visible = true
	end

	if self:hasBindings("hide") then
		self:call("hide")
	else
		self.instance.Visible = true
	end

	self:call("close")
end

return Page