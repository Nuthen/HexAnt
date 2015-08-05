HexTile = class('HexTile')

function HexTile:initialize(ix, iy, radius)
	self.ix = ix
	self.iy = iy
	self.radius = radius
	
	self.tileX = ix - radius - 1
	self.tileZ = iy - radius - 1
	self.tileY = -self.tileX - self.tileZ
	
	self.h = game.tileH
	self.w = game.tileW
	self.r = self.h/2
	
	self.tileType = 0
	
	local screenWidth, screenHeight = love.graphics.getDimensions()
	
	self.x = game.startX + screenWidth/2 + self.r * 3/2 * self.tileZ
	self.y = game.startY + screenHeight/2 + self.r * math.sqrt(3) * (self.tileX + self.tileZ/2)
	
	self.points = {}
	for i = 1, 6 do
		local angle = math.rad(60*(i-1))
		local px = self.x + math.cos(angle)*self.r
		local py = self.y + math.sin(angle)*self.r
		
		table.insert(self.points, px)
		table.insert(self.points, py)
	end
	
	local inRange, dist = game:inRange(self.tileX, self.tileY, self.tileZ, radius)
	if game:inRange(self.tileX, self.tileY, self.tileZ, radius) then
		self.tileType = 1
	end
	
	self.untouched = true
	
	self.lines = {0, 0, 0, 0, 0, 0}
	self.lineList = {}
end

function HexTile:setLines(initial)
	local initial = initial or false

	self.lines = {0, 0, 0, 0, 0, 0}
	if self.tileType > 0 then
		local tileX, tileY, tileZ = self.tileX, self.tileY, self.tileZ
		local tileType = self.tileType
		
		if not game:inRange(tileX, tileY-1, tileZ+1) or game:getTile(tileX, tileY-1, tileZ+1) ~= tileType then -- southeast
			local x1, y1, x2, y2 = self.points[1], self.points[2], self.points[3], self.points[4]
			
			if initial or self:lineCheck(x1, y1, x2, y2) then
				self.lines[1] = 1
			end
		end
		
		if not game:inRange(tileX+1, tileY-1, tileZ) or game:getTile(tileX+1, tileY-1, tileZ) ~= tileType then -- south
			local x1, y1, x2, y2 = self.points[3], self.points[4], self.points[5], self.points[6]
			
			if initial or self:lineCheck(x1, y1, x2, y2) then
				self.lines[2] = 1
			end
		end
		
		if not game:inRange(tileX+1, tileY, tileZ-1) or game:getTile(tileX+1, tileY, tileZ-1) ~= tileType then -- southwest
			local x1, y1, x2, y2 = self.points[5], self.points[6], self.points[7], self.points[8]
			
			if initial or self:lineCheck(x1, y1, x2, y2) then
				self.lines[3] = 1
			end
		end
		
		if not game:inRange(tileX, tileY+1, tileZ-1) or game:getTile(tileX, tileY+1, tileZ-1) ~= tileType then -- northwest
			local x1, y1, x2, y2 = self.points[7], self.points[8], self.points[9], self.points[10]
			
			if initial or self:lineCheck(x1, y1, x2, y2) then
				self.lines[4] = 1
			end
		end
		
		if not game:inRange(tileX-1, tileY+1, tileZ) or game:getTile(tileX-1, tileY+1, tileZ) ~= tileType then -- north
			local x1, y1, x2, y2 = self.points[9], self.points[10], self.points[11], self.points[12]
			
			if initial or self:lineCheck(x1, y1, x2, y2) then
				self.lines[5] = 1
			end
		end
		
		if not game:inRange(tileX-1, tileY, tileZ+1) or game:getTile(tileX-1, tileY, tileZ+1) ~= tileType then -- northeast
			local x1, y1, x2, y2 = self.points[11], self.points[12], self.points[1], self.points[2]
			
			if initial or self:lineCheck(x1, y1, x2, y2) then
				self.lines[6] = 1
			end
		end
	end
	
	self:runLines()
end

function HexTile:draw()
	if self.tileType > 0 then
		--if self.untouched then
			--love.graphics.setColor(255, 255, 255)
		--else
			love.graphics.setColor(game.tiles[self.tileType].color)
		--end
		
		love.graphics.polygon('fill', self.points)
		
		love.graphics.setColor(255, 255, 255)
		--love.graphics.polygon('line', self.points)
		
	end
end

function HexTile:drawLines()
	local sortedLines = self.sortedLines
	
	love.graphics.setColor(255, 255, 255)
	
	for k, line in pairs(self.lineList) do
		if #line > 0 then
			love.graphics.line(line)
		end
	end
end

function HexTile:runLines()
	if self.tileType > 0 then
		local sortedLines = {}
		local j = 1
		sortedLines[1] = {}
		for i = 1, #self.lines do
			if self.lines[i] == 1 then
				table.insert(sortedLines[j], i)
			elseif #sortedLines[j] > 0 then
				j = j+1
				sortedLines[j] = {}
			end
		end
		
		if #sortedLines > 1 then
			local i = #self.lines
			if self.lines[i] == 1 then
				if self.lines[1] == 1 then -- merge last and first table
					local tbl1 = sortedLines[#sortedLines]
					local tbl2 = sortedLines[1]
					
					for j = 1, #tbl2 do
						table.insert(tbl1, tbl2[j])
					end
					
					sortedLines[1] = tbl1
					sortedLines[#sortedLines] = nil
				end
			end
		end
		
		local lineList = {}
		for i = 1, #sortedLines do
			lineList[i] = {}
			if #sortedLines[i] > 0 then
				for j = 1, #sortedLines[i] do
					local indexWall = sortedLines[i][j]
							
					table.insert(lineList[i], self.points[indexWall*2-1])
					table.insert(lineList[i], self.points[indexWall*2])
					
					if j == #sortedLines[i] then
						if indexWall < 6 then
							table.insert(lineList[i], self.points[(indexWall+1)*2-1])
							table.insert(lineList[i], self.points[(indexWall+1)*2])
						else
							table.insert(lineList[i], self.points[1])
							table.insert(lineList[i], self.points[2])
						end
					end
				end
			end
		end
		
		self.lineList = lineList
	end 
end

function HexTile:lineCheck(x1, y1, x2, y2)
	if game:pointInView(x1, y1) and game:pointInView(x2, y2) then
		return true
	end
end