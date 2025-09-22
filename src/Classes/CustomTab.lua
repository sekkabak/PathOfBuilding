-- Path of Building
--
-- Module: Custom Tab
-- Simple example tab scaffold you can extend.

local CustomTabClass = newClass("CustomTab", "ControlHost", function(self, build)
    self.ControlHost()

    self.build = build
    self.modFlag = false

    self.controls = {}
    -- self.controls.title = new("LabelControl", nil, { 20, 20, 0, 20 }, 20, "Custom Tab")
    -- self.controls.info = new("LabelControl", nil, { 20, 46, 0, 16 }, 16, "Add your controls here.")


    -- -- Label
    -- self.controls.header = new("LabelControl", nil, { 20, 20, 0, 20 }, 18, "Hello from Custom Tab")

    -- -- Button
    -- self.controls.clickMe = new("ButtonControl", nil, { 20, 50, 120, 20 }, "Click Me", function()
    --     self.modFlag = true
    -- end)

    -- -- Checkbox
    -- self.controls.toggle = new("CheckBoxControl", nil, { 160, 50, 18, 18 }, "Enable Onslaught", function(state)
    --     self.build.configTab.input["buffOnslaught"] = state
    --     self.build.configTab:BuildModList()
    --     self.build.buildFlag = true
    --     self.modFlag = true
    -- end)

    -- -- Edit box
    -- self.controls.edit = new("EditControl", nil, { 20, 80, 180, 20 }, "", "Type here", nil, 64, function(buf)
    --     self.lastInput = buf
    -- end)

    -- -- Dropdown
    -- self.controls.choice = new("DropDownControl", nil, { 20, 110, 180, 20 }, {
    --     { label = "Option A", val = "A" },
    --     { label = "Option B", val = "B" },
    -- }, function(index, value)
    --     self.selected = value.val
    -- end)

    -- Draw a list of all skill gems

    -- Draw a list of all skill gems in PoE

    -- Load the Gems data table
    local Gems = LoadModule("Data/Gems")
    ConPrintf("test")

    -- Build a sorted list of all skill gems (excluding supports)
    local skillGemList = {}
    for key, gem in pairs(Gems) do
        if gem.tags and gem.tags.grants_active_skill then
            table.insert(skillGemList, {
                name = gem.name or key,
                baseTypeName = gem.baseTypeName or "",
                gameId = gem.gameId or key,
                tagString = gem.tagString or "",
            })
        end
    end
    -- table.sort(skillGemList, function(a, b) return a.name < b.name end)
    ConPrintf("CustomTab: Skill gem list loaded, total gems: " .. tostring(#skillGemList))
    for _, gem in ipairs(skillGemList) do
        ConPrintf(gem.name .. gem.baseTypeName)
    end

    -- -- Display the list in a scrollable area
    -- local listY = 20
    -- local listX = 20
    -- local rowHeight = 18
    -- local maxRows = 20
    -- local totalRows = #skillGemList
    -- -- local scrollBar = new("ScrollBarControl", nil, { listX + 400, listY, 16, rowHeight * maxRows }, totalRows, maxRows)
    -- -- self.controls.gemScrollBar = scrollBar

    -- -- Draw function for the gem list
    -- self.controls.gemList = {
    --     Draw = function(_, viewPort)
    --         -- local firstRow = math.floor(scrollBar.offset)
    --         -- local lastRow = math.min(firstRow + maxRows, totalRows)
    --         -- for i = firstRow + 1, lastRow do
    --             local gem = skillGemList[i]
    --             -- DrawString(listX, listY + (i - firstRow - 1) * rowHeight, "LEFT", 16, "VAR", gem.name)
    --             -- Optionally, show tags or baseTypeName
    --             -- DrawString(listX + 220, listY + (i - firstRow - 1) * rowHeight, "LEFT", 14, "GREY", gem.tagString)
    --         end
    --     end
    -- }
    -- self:AddControl(self.controls.gemScrollBar)
    -- self:AddControl(self.controls.gemList)
end)

function CustomTabClass:Draw(viewPort, inputEvents)
    SetViewport(viewPort.x, viewPort.y, viewPort.width, viewPort.height)
    self:DrawControls(viewPort)
    SetViewport()


    -- self.build.configTab.input["buffElusive"] = true
    -- self.build.configTab.input["Onslaught"] = true
    self.build.configTab.input["buffOnslaught"] = true
    self.build.configTab:BuildModList()
    self.build.configTab:UpdateControls()
    self.build.buildFlag = true
    -- self.runCallback("OnFrame")
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
