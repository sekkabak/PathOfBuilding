-- Path of Building
--
-- Module: Custom Tab
-- Simple example tab scaffold you can extend.

local CustomTabClass = newClass("CustomTab", "ControlHost", function(self, build)
    self.ControlHost()

    self.build = build
    self.modFlag = false

    self.controls = {}
end)

function CustomTabClass:Draw(viewPort, inputEvents)
    self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height

	self:ProcessControlsInput(inputEvents, viewPort)
	for _, event in ipairs(inputEvents) do
	end

	main:DrawBackground(viewPort)
	self:DrawControls(viewPort)
end

-- Persist a minimal section so builds remain compatible if removed later
function CustomTabClass:Save(xml)
    -- Example attribute; replace with real state as needed
    xml.attrib = xml.attrib or {}
    xml.attrib.example = xml.attrib.example or "true"
end

function CustomTabClass:Load(xml, dbFileName)
    -- Read back any attributes as needed

    -- Check if we have power charges
    if self.build and self.build.calcsTab and self.build.calcsTab.mainEnv then
        local env = self.build.calcsTab.mainEnv
        if env.player and env.player.powerCharges and env.player.powerCharges > 0 then
            -- We have power charges
            self.hasPowerCharges = true
        else
            self.hasPowerCharges = false
        end
    else
        self.hasPowerCharges = false
    end

    -- Configure the config tab with Onslaught


    -- self.build.configTab.input["condition:Onslaught"] = true
    -- self.build.configTab.modFlag = true
    -- self.build.configTab:AddUndoState()
    -- self.build.configTab:BuildModList()
    -- self.build.configTab:UpdateControls()
    -- self.build.buildFlag = true

    -- self.build.configTab.input

    return false
end

return CustomTabClass
