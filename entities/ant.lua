Ant = class('Ant')

function Ant:initialize(dx, dy, dz)
	local radius = game.radius
	
	dx, dy, dz = dx or 0, dy or 0, dz or 0
	
	self.tileX = 0 + dx
	self.tileZ = 0 + dy
	self.tileY = -self.tileX - self.tileZ + dz
	
	ix = self.tileX + radius + 1
	iy = self.tileZ + radius + 1
	
	self.ix = ix or 3
	self.iy = iy or 3
	
	self.tile = game.hexGrid[iy][ix]
	self.x = self.tile.x
	self.y = self.tile.y
	
	self.dir = 1
	self.maxDir = 6
	
	self.steps = 0
	
	self.destroy = false
end

function Ant:step()
	local ix, iy = self.ix, self.iy
	
	if self.tile.tileType > 0 then
		local turn = game.tiles[self.tile.tileType].turn
		self:changeDir(turn)
		
		if self:move() then
			self:flipTile(ix, iy)
		end
		
		self.steps = self.steps+1
		
		game.canvas:renderTo(function()
			game.hexGrid[self.iy][self.ix]:draw()
			game.hexGrid[iy][ix]:draw()
		end)
		
		if game.drawBorders then
			for jy = -1, 1 do
				for jx = -1, 1 do
					local nx, ny = ix+jx, iy+jy
					if nx >= 1 and ny >= 1 and ny <= #game.hexGrid and nx <= #game.hexGrid[ny] then
						game.hexGrid[iy+jy][ix+jx]:setLines()
					end
				end
			end
		end
		
	else -- die
		self.destroy = true
	end
end

function Ant:changeDir(b)
	if self.dir + b < 1 then self.dir = self.maxDir + (self.dir+b)
	elseif self.dir + b > self.maxDir then self.dir = (self.dir+b) - self.maxDir
	else self.dir = self.dir + b end
end

function Ant:move()
	local dx, dy = 0, 0
	if       self.dir == 1 then dx = 1
	elseif self.dir == 2 then dx = 1 dy = -1
	elseif self.dir == 3 then dy = -1
	elseif self.dir == 4 then dx = -1
	elseif self.dir == 5 then dx = -1 dy = 1
	elseif self.dir == 6 then dy = 1 end
	
	local tileX = self.ix+dx - game.radius - 1
	local tileZ = self.iy+dy - game.radius - 1
	local tileY = -tileX - tileZ
	if game:inRange(tileX, tileY, tileZ) then
		if game.hexGrid[self.iy+dy][self.ix+dx].tileType > 0 then
			self.tile = game.hexGrid[self.iy+dy][self.ix+dx]
			self.x = self.tile.x
			self.y = self.tile.y
			self.ix = self.ix+dx
			self.iy = self.iy+dy
			
			return true
		end
	end
end

function Ant:flipTile(ix, iy)
	local tileType = game.hexGrid[iy][ix].tileType
	local tileCount = #game.tiles
	if tileType >= tileCount then
		game.hexGrid[iy][ix].tileType = 1
	else
		game.hexGrid[iy][ix].tileType = tileType+1
	end
	game.hexGrid[iy][ix].untouched = false
end

function Ant:draw()
	love.graphics.setColor(30, 30, 30, 200)
	love.graphics.circle('fill', self.x, self.y, 20, 6)
	
	love.graphics.line(self.x, self.y, self.x+math.cos(math.rad(30 + (self.dir)*60))*50, self.y+math.sin(math.rad(30 + (self.dir)*60))*50)
end