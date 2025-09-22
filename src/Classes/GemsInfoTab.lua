-- Path of Building
--
-- Module: Gems Info Tab
-- Displays a vertical list of active gem names from Data/Gems as small clickable boxes.
--

local ipairs = ipairs
local pairs = pairs
local t_insert = table.insert
local m_sort = table.sort

local ROW_HEIGHT = 20
local PANEL_WIDTH = 266
local PANEL_HEIGHT = 500
local BOX_WIDTH = PANEL_WIDTH - 17
local DESC_PANEL_WIDTH = 600
local DESC_PANEL_HEIGHT = 500

local GemsInfoTabClass = newClass("GemsInfoTab", "ControlHost", "Control", function(self, build)
	self.ControlHost()
	self.Control()

	self.build = build

	self.modFlag = false

	self.activeGems = { }
	self.selectedGem = nil
	self.selectedSkillData = nil
	self:BuildActiveGems()

	-- Panel that contains the vertical list (216x800) with scrollbar inside
    self.controls.gemPanel = new("Control", {"TOPLEFT",self,"TOPLEFT"}, {8, 8, PANEL_WIDTH, PANEL_HEIGHT})
    self.controls.gemPanel.canReceiveFocus = true
    self.controls.scroll = new("ScrollBarControl", {"RIGHT",self.controls.gemPanel,"RIGHT"}, {-1, 0, 16, 0}, ROW_HEIGHT * 2, "VERTICAL")
	self.controls.scroll.height = function()
		return PANEL_HEIGHT - 2
	end

	-- Description panel (584x800) next to the gem list
	self.controls.descPanel = new("Control", {"LEFT",self.controls.gemPanel,"RIGHT"}, {16, 0, DESC_PANEL_WIDTH - 16, DESC_PANEL_HEIGHT})
	self.controls.descScroll = new("ScrollBarControl", {"RIGHT",self.controls.descPanel,"RIGHT"}, {0, 0, 16, DESC_PANEL_HEIGHT}, 20, "VERTICAL")
	self.controls.descScroll.shown = true -- Ensure scrollbar is visible
	
	-- Draw function for description panel
	self.controls.descPanel.Draw = function(panel)
		local px, py = panel:GetPos()
		local pw, ph = panel:GetSize()
		local fontSize = 14
		local lineHeight = fontSize + 4
		
		-- Panel background
		SetDrawColor(0.4, 0.4, 0.4)
		DrawImage(nil, px, py, pw, ph)
		SetDrawColor(0.1, 0.1, 0.1)
		DrawImage(nil, px + 1, py + 1, pw - 2, ph - 2)
		
		if self.selectedGem and self.selectedSkillData then
			local y = py + 10
			
		-- Calculate total content height needed
		local totalContentHeight = 0
		if self.selectedSkillData.description then
			local desc = self.selectedSkillData.description
			local maxWidth = pw - 50 -- Very conservative margin
			local words = {}
			for word in desc:gmatch("%S+") do
				t_insert(words, word)
			end
			
			local line = ""
			local descLines = 0
			for _, word in ipairs(words) do
				local testLine = line == "" and word or line .. " " .. word
				local testWidth = DrawStringWidth(fontSize, "VAR", testLine)
				if testWidth > maxWidth then
					if line ~= "" then
						descLines = descLines + 1
						line = word
					else
						descLines = descLines + 1
					end
				else
					line = testLine
				end
			end
			if line ~= "" then
				descLines = descLines + 1
			end
			
			totalContentHeight = totalContentHeight + (descLines + 2) * lineHeight + 20 -- Description + header
		end
		
		-- Add level information height
		if self.selectedSkillData.levels then
			local maxLevel = 0
			for level, _ in pairs(self.selectedSkillData.levels) do
				if type(level) == "number" and level > maxLevel then
					maxLevel = level
				end
			end
			totalContentHeight = totalContentHeight + (maxLevel + 1) * (lineHeight - 2) + 20 -- All levels + header
		end
		
		-- Set up scrollbar
		self.controls.descScroll:SetContentDimension(totalContentHeight, ph)
		local offset = self.controls.descScroll.offset
		y = y - offset
		
		-- Only draw content that's within the panel bounds
		local contentStartY = py + 10
		local contentEndY = py + ph - 10
		
		-- Gem name
		if y >= contentStartY and y <= contentEndY then
			SetDrawColor(1, 1, 0.5)
			DrawString(px + 10, y, "LEFT", fontSize + 2, "VAR", self.selectedGem.name or "Unknown")
		end
		y = y + lineHeight + 10
		


		-- Gem stats
		-- Show gem stats for levels 1 to 20
		for lvl = 1, 20 do
			local gemInstance = {
				level = lvl,
				quality = self.selectedGem.quality or 0,
				qualityId = self.selectedGem.qualityId or "Default",
				displayEffect = nil,
				gemData = self.selectedSkillData,
			}
			local stats = calcLib.buildSkillInstanceStats(gemInstance, self.selectedGem.grantedEffect)
			local descriptions, lineMap = self.build.data.describeStats(stats, self.selectedGem.grantedEffect.statDescriptionScope)
			
			if descriptions and #descriptions > 0 then
				if y >= contentStartY and y <= contentEndY then
					SetDrawColor(1, 1, 1)
					DrawString(px + 10, y, "LEFT", fontSize, "VAR", "Level " .. lvl .. ":")
				end
				y = y + lineHeight - 2
				for _, line in ipairs(descriptions) do
					if y >= contentStartY and y <= contentEndY then
						SetDrawColor(1, 1, 1)
						DrawString(px + 20, y, "LEFT", fontSize, "VAR", line)
					end
					y = y + lineHeight - 2
				end
				y = y + 6
			end
		end

		-- Description
		if self.selectedSkillData.description then
			if y >= contentStartY and y <= contentEndY then
				SetDrawColor(1, 1, 1)
				DrawString(px + 10, y, "LEFT", fontSize, "VAR", "Description:")
			end
			y = y + lineHeight
			
                    -- Wrap description text properly
                    local desc = self.selectedSkillData.description
                    local maxWidth = pw - 40 -- 16px for scrollbar + 24px margin from right edge
                    
                    -- Split description into words
                    local words = {}
                    for word in desc:gmatch("%S+") do
                        t_insert(words, word)
                    end
                    
                    -- Build lines word by word
                    local currentLine = ""
                    for i, word in ipairs(words) do
                        local testLine = currentLine == "" and word or currentLine .. " " .. word
                        local lineWidth = DrawStringWidth(fontSize, "VAR", testLine)
                        
                        if lineWidth > maxWidth and currentLine ~= "" then
                            -- Current line is full, draw it and start new line
                            if y >= contentStartY and y <= contentEndY then
                                DrawString(px + 10, y, "LEFT", fontSize, "VAR", currentLine)
                            end
                            y = y + lineHeight
                            currentLine = word
                        else
                            -- Add word to current line
                            currentLine = testLine
                        end
                    end
                    
                    -- Draw the last line if it exists
                    if currentLine ~= "" then
                        if y >= contentStartY and y <= contentEndY then
                            DrawString(px + 10, y, "LEFT", fontSize, "VAR", currentLine)
                        end
                        y = y + lineHeight + 10
                    end
		end
		
		-- Levels information
		if self.selectedSkillData.levels then
			if y >= contentStartY and y <= contentEndY then
				SetDrawColor(0.8, 0.8, 1)
				DrawString(px + 10, y, "LEFT", fontSize, "VAR", "Level Information:")
			end
			y = y + lineHeight
			
			-- Show all available levels in correct order
			local maxLevel = 0
			-- Find the highest level available
			for level, _ in pairs(self.selectedSkillData.levels) do
				if type(level) == "number" and level > maxLevel then
					maxLevel = level
				end
			end
			
			-- Show all levels from 1 to maxLevel
			for level = 1, maxLevel do
				local data = self.selectedSkillData.levels[level]
				if data then
					SetDrawColor(1, 1, 1)
					local levelText = "Level " .. level .. ": "
					if type(data) == "table" then
						levelText = levelText .. "Requires Level " .. (data.levelRequirement or "?")
						if data.cost then
							levelText = levelText .. ", Cost: " .. (data.cost.Mana or "?") .. " Mana"
						end
					end
					if y >= contentStartY and y <= contentEndY then
						DrawString(px + 20, y, "LEFT", fontSize - 2, "VAR", levelText)
					end
					y = y + lineHeight - 2
				end
			end
		end
	else
		-- No gem selected
		SetDrawColor(0.7, 0.7, 0.7)
		DrawString(px + 10, py + 50, "LEFT", fontSize, "VAR", "Click on a gem to see its description")
	end
end

-- Add keyboard/mouse handling for description panel
self.controls.descPanel.OnKeyUp = function(panel, key)
	if self.controls.descScroll:IsScrollDownKey(key) then
		self.controls.descScroll:Scroll(1)
	elseif self.controls.descScroll:IsScrollUpKey(key) then
		self.controls.descScroll:Scroll(-1)
	end
	return panel
end

-- Add mouse wheel handling for description panel
self.controls.descPanel.OnWheel = function(panel, delta)
	if delta > 0 then
		self.controls.descScroll:Scroll(-3)
	else
		self.controls.descScroll:Scroll(3)
	end
	return panel
end

-- Vertical scrollbar on the right handles scrolling

-- Draw the list of small boxes (199x20) stacked vertically inside 200x600
self.controls.gemPanel.Draw = function(panel)
	local px, py = panel:GetPos()
        local pw, ph = panel:GetSize()
	-- panel background
	SetDrawColor(0.5, 0.5, 0.5)
	DrawImage(nil, px, py, pw, ph)
	SetDrawColor(0.1, 0.1, 0.1)
	DrawImage(nil, px + 1, py + 1, pw - 2, ph - 2)

        local total = #self.activeGems
        self.controls.scroll:SetContentDimension(total * ROW_HEIGHT, ph)
	local offset = self.controls.scroll.offset
	-- slider removed; only scrollbar remains
	local firstRow = math.max(1, math.floor(offset / ROW_HEIGHT) + 1)
	local visibleRows = math.ceil(ph / ROW_HEIGHT) + 1
	local lastRow = math.min(total, firstRow + visibleRows)

	local cursorX, cursorY = GetCursorPos()
	self._hoverIndex = nil
	for row = firstRow, lastRow do
		local entry = self.activeGems[row]
		local y = py + (row - 1) * ROW_HEIGHT - (firstRow - 1) * ROW_HEIGHT - (offset % ROW_HEIGHT)
		local x = px + 1
		local w = BOX_WIDTH
		local h = ROW_HEIGHT
		
		-- Only draw if within panel bounds (clipping)
		if y >= py and y + h <= py + ph then
			local hover = cursorX >= x and cursorX <= x + w and cursorY >= y and cursorY <= y + h
			if hover then 
				self._hoverIndex = row 
			end
			-- box
			SetDrawColor(hover and 0.9 or 0.8, hover and 0.9 or 0.8, hover and 0.9 or 0.8)
			DrawImage(nil, x, y, w, h)
			SetDrawColor(0.15, 0.15, 0.15)
			DrawImage(nil, x + 1, y + 1, w - 2, h - 2)
			-- text
			SetDrawColor(1, 1, 1)
			local text = entry.name or ""
			local fontSize = 14
			local maxTextW = w - 8
			local textW = DrawStringWidth(fontSize, "VAR", text)
			if textW > maxTextW then
				local cut = DrawStringCursorIndex(fontSize, "VAR", text, maxTextW, 0)
				text = text:sub(1, math.max(1, cut - 1))
			end
			DrawString(x + 4, y + (h - fontSize) / 2, "LEFT", fontSize, "VAR", text)
		end
	end
end

            self.controls.gemPanel.OnKeyUp = function(panel, key)
                if self.controls.scroll:IsScrollDownKey(key) then
                    self.controls.scroll:Scroll(1)
                elseif self.controls.scroll:IsScrollUpKey(key) then
                    self.controls.scroll:Scroll(-1)
                end
                return panel
            end

            -- Add mouse wheel handling for gem panel
            self.controls.gemPanel.OnWheel = function(panel, delta)
                if delta > 0 then
                    self.controls.scroll:Scroll(-3)
                else
                    self.controls.scroll:Scroll(3)
                end
                return panel
            end

self.controls.gemPanel.OnKeyDown = function(panel, key)
	ConPrintf("Key pressed: " .. (key or "nil") .. ", hover index: " .. (self._hoverIndex or "nil"))
	if key == "LEFTBUTTON" and self._hoverIndex then
		-- Select the gem and load its skill data
		local selectedEntry = self.activeGems[self._hoverIndex]
		if selectedEntry then
			self.selectedGem = selectedEntry
			self.selectedSkillData = self:GetSkillData(selectedEntry.id)
			-- Debug: print what we selected
			ConPrintf("Selected gem: " .. (selectedEntry.name or "Unknown") .. " (ID: " .. (selectedEntry.id or "Unknown") .. ")")
			if self.selectedSkillData then
				ConPrintf("Found skill data for: " .. (self.selectedSkillData.name or "Unknown"))
			else
				ConPrintf("No skill data found for gem ID: " .. (selectedEntry.id or "Unknown"))
			end
		end
		return panel
	end
	return panel
end

-- Alternative mouse event handler
self.controls.gemPanel.OnMouseDown = function(panel, button, x, y)
	ConPrintf("Mouse down: " .. (button or "nil") .. " at " .. (x or "nil") .. "," .. (y or "nil") .. ", hover index: " .. (self._hoverIndex or "nil"))
	if button == "LEFT" and self._hoverIndex then
		-- Select the gem and load its skill data
		local selectedEntry = self.activeGems[self._hoverIndex]
		if selectedEntry then
			self.selectedGem = selectedEntry
			self.selectedSkillData = self:GetSkillData(selectedEntry.id)
			-- Debug: print what we selected
			ConPrintf("Selected gem: " .. (selectedEntry.name or "Unknown") .. " (ID: " .. (selectedEntry.id or "Unknown") .. ")")
			if self.selectedSkillData then
				ConPrintf("Found skill data for: " .. (self.selectedSkillData.name or "Unknown"))
			else
				ConPrintf("No skill data found for gem ID: " .. (selectedEntry.id or "Unknown"))
			end
		end
		return panel
	end
	return panel
end
end)

function GemsInfoTabClass:BuildActiveGems()
	wipeTable(self.activeGems)
	-- Prefer the build's loaded data so we match game/version context
	local gems = (self.build and self.build.data and self.build.data.gems) or { }
	for gemId, gem in pairs(gems) do
		if gem and gem.name and gem.grantedEffect and not gem.grantedEffect.support then
			t_insert(self.activeGems, { id = gemId, name = gem.name, grantedEffect = gem.grantedEffect })
		end
	end
	m_sort(self.activeGems, function(a, b)
		if a.name == b.name then return a.id < b.id end
		return a.name < b.name
	end)
end

function GemsInfoTabClass:GetSkillData(gemId)
	-- Try to get skill data from the build's data first
	local skills = (self.build and self.build.data and self.build.data.skills) or (data and data.skills) or { }
	
	-- Find the skill by gem ID
	for skillId, skillData in pairs(skills) do
		if skillId == gemId then
			return skillData
		end
	end
	
	-- If not found by exact ID, try to find by granted effect ID
	local gems = (self.build and self.build.data and self.build.data.gems) or { }
	local gem = gems[gemId]
	if gem and gem.grantedEffectId then
		for skillId, skillData in pairs(skills) do
			if skillId == gem.grantedEffectId then
				return skillData
			end
		end
	end
	
	return nil
end

function GemsInfoTabClass:Load(xml, fileName)
end

function GemsInfoTabClass:Save(xml)
end

function GemsInfoTabClass:Draw(viewPort, inputEvents)
	self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height

	if #self.activeGems == 0 and self.build and self.build.data and self.build.data.gems then
		self:BuildActiveGems()
	end

            -- Handle click and wheel events directly here
            for _, event in ipairs(inputEvents) do
                if event.type == "KeyDown" and event.key == "LEFTBUTTON" then
                    if self._hoverIndex then
                        local selectedEntry = self.activeGems[self._hoverIndex]
                        if selectedEntry then
                            self.selectedGem = selectedEntry
                            self.selectedSkillData = self:GetSkillData(selectedEntry.id)
                        end
                    end
                elseif event.type == "KeyUp" and (event.key == "WHEELUP" or event.key == "WHEELDOWN") then
                    local cursorX, cursorY = GetCursorPos()
                    
                    -- Check if mouse is over gem panel
                    local gemPanelX, gemPanelY = self.controls.gemPanel:GetPos()
                    local gemPanelW, gemPanelH = self.controls.gemPanel:GetSize()
                    
                    if cursorX >= gemPanelX and cursorX <= gemPanelX + gemPanelW and 
                       cursorY >= gemPanelY and cursorY <= gemPanelY + gemPanelH then
                        -- Mouse is over gem panel, handle wheel scroll
                        if event.key == "WHEELUP" then
                            self.controls.scroll:Scroll(-3)
                        else -- WHEELDOWN
                            self.controls.scroll:Scroll(3)
                        end
                    end
                    
                    -- Check if mouse is over description panel
                    local descPanelX, descPanelY = self.controls.descPanel:GetPos()
                    local descPanelW, descPanelH = self.controls.descPanel:GetSize()
                    
                    if cursorX >= descPanelX and cursorX <= descPanelX + descPanelW and 
                       cursorY >= descPanelY and cursorY <= descPanelY + descPanelH then
                        -- Mouse is over description panel, handle wheel scroll
                        if event.key == "WHEELUP" then
                            self.controls.descScroll:Scroll(-3)
                        else -- WHEELDOWN
                            self.controls.descScroll:Scroll(3)
                        end
                    end
                end
            end

	self:ProcessControlsInput(inputEvents, viewPort)

	main:DrawBackground(viewPort)

	self:DrawControls(viewPort)
	
	-- Ensure scrollbar is drawn
	if self.controls.descScroll then
		self.controls.descScroll:Draw(viewPort)
	end
end

return GemsInfoTabClass


