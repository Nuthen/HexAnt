game = {}

function game:enter()
	self.radius = 80
	self.tileH = 64
	self.tileW = math.sqrt(3)/2 * self.tileH
	
	self.gridHeight = self.radius*2*self.tileH
	self.gridWidth = (self.radius)*self.tileW*(3/2) * 1.2
	
	self.canvas = love.graphics.newCanvas(self.gridWidth, self.gridHeight)
	self.canvas:setFilter('linear', 'linear') -- line traces will look a little clearer when zoomed
	
	-- origin
	self.startX = self.canvas:getWidth()/2 - love.graphics.getWidth()/2
	self.startY = self.canvas:getHeight()/2 - love.graphics.getHeight()/2
	
	self.tiles = {}
	local count = math.random(2, 12)
	for i = 1, count do
		self.tiles[i] = {}
		local r,g,b,a = HSL(255/count*(i-1), 170, 150, 255)
		self.tiles[i].color = {r,g,b,a}
		local turn = math.random(1,4)
		if turn <= 2 then
			self.tiles[i].turn = turn-3
		else
			self.tiles[i].turn = turn-2
		end
	end
	
	local turnStr = ''
	for i = 1, #self.tiles do
		local char = ''
		if self.tiles[i].turn == -1 then
			char = 'L'
		elseif self.tiles[i].turn == 1 then
			char = 'R'
		elseif self.tiles[i].turn == -2 then
			char = '<'
		elseif self.tiles[i].turn == 2 then
			char = '>'
		end
		
		turnStr = turnStr .. char
	end
	self.turnStr = turnStr
	
	--love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('smooth')
	self.hexGrid = {}
	self.zoomMax = 3
	
	-- camera is centered on the canvas
	self.camera = {x = self.startX, y = self.startY, zoom = 1, speed = 400, targetBool = false, target = 1}
	
	self:makeGrid(self.width, self.height)
	
	self.ants = {}
	local ants = math.random(1, 12)
	for i = 1, ants do
		table.insert(self.ants, Ant:new(0, 0, 0))
	end
	
	self.timer = 0
	self.step = .5
	self.quickSteps = 1
	
	love.graphics.setPointSize(5)
	love.graphics.setLineWidth(2)
end

function game:makeGrid(width, height)
	local grid = {}
	for iy = 1, self.radius*2 + 1 do
		grid[iy] = {}
		for ix = 1, self.radius*2 + 1 do
			table.insert(grid[iy], HexTile:new(ix, iy, self.radius))
		end
	end
	
	self.hexGrid = grid
	
	self:drawGrid()
	
	for iy = 1, #self.hexGrid do
		for ix = 1, #self.hexGrid[iy] do
			self.hexGrid[iy][ix]:setLines(true)
		end
	end
end

function game:update(dt)
	self.timer = self.timer + dt
	if self.timer >= self.step then
		self.timer = 0
		for i = 1, self.quickSteps do
			for k, ant in ipairs(self.ants) do
				ant:step()
				
				self.errorOut = true
			end
		end
	end
	
	local cameraX = self.camera.x
	local cameraY = self.camera.y
	
	local speed = self.camera.speed*dt/self.camera.zoom
	if love.keyboard.isDown('lshift', 'rshift') then speed = speed * 2 end
	if love.keyboard.isDown('w', 'up') then self.camera.y = self.camera.y - speed end
	if love.keyboard.isDown('s', 'down') then self.camera.y = self.camera.y + speed end
	if love.keyboard.isDown('a', 'left') then self.camera.x = self.camera.x - speed end
	if love.keyboard.isDown('d', 'right') then self.camera.x = self.camera.x + speed end
end

function game:keypressed(key, isrepeat)
    if console.keypressed(key) then
        return
    end
	
	-- reset
	if key == 'f2' then
		self:enter()
	end
	
	-- toggle fullscreen
	if key == 'f12' then
		self:toggleFullscreen()
		self:drawGrid()
	end
end

function game:mousepressed(x, y, mbutton)
    if console.mousepressed(x, y, mbutton) then
        return
    end
	
	if mbutton == 'wu' and self.camera.zoom < self.zoomMax then
		self.camera.zoom = self.camera.zoom + .1
	elseif mbutton == 'wd' and self.camera.zoom >= .2 then
		self.camera.zoom = self.camera.zoom - .1
	end
end

function game:drawGrid()
	self.canvas:renderTo(function()
		for iy = 1, #self.hexGrid do
			for ix = 1, #self.hexGrid[iy] do
				self.hexGrid[iy][ix]:draw()
			end
		end
	end)
end

function game:draw()
	love.graphics.setColor(255, 255, 255)
	
    love.graphics.push()
	
	-- translate to origin, scale, translate back
	love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	love.graphics.scale(self.camera.zoom)
	love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)
	
	
	-- translate to screen coordinates
	love.graphics.translate(-self.camera.x, -self.camera.y)
	
	
	love.graphics.draw(self.canvas)
	
	for iy = 1, #self.hexGrid do
		for ix = 1, #self.hexGrid[iy] do
			self.hexGrid[iy][ix]:drawLines()
		end
	end
	
	for k, ant in ipairs(self.ants) do
		ant:draw()
	end
	
	love.graphics.pop()
	
	
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(love.timer.getFPS(), 5, 5)
	love.graphics.print('Steps: '..self.ants[1].steps, 5, 45)
	love.graphics.print('Turns: '..self.turnStr..' ('..#self.tiles..')', 5, 95)
	love.graphics.print('Ant Count: '..#self.ants, 5, 135)
end


function game:toggleFullscreen()
	if love.window.getFullscreen() then
		local width, height = self.oldScreenWidth, self.oldScreenHeight
		love.window.setMode(width, height, {fullscreen = false, fsaa = 4, resizable = true, centered = false})
		--self:resize(width, height)
	else
		self.oldScreenWidth, self.oldScreenHeight = love.graphics.getWidth(), love.graphics.getHeight()
	
		local width, height = love.window.getDesktopDimensions()
		love.window.setMode(width, height, {fullscreen = true, fsaa = 4})
		
		--self:resize(width, height)
	end
end

function game:inRange(tileX, tileY, tileZ, radius)
	radius = radius or self.radius
	local dist = (math.abs(tileX) + math.abs(tileZ) + math.abs(tileY)) /2
	if dist <= radius then
		return true, dist
	end
end

function game:getTile(tileX, tileY, tileZ)
	local ix = tileX + self.radius + 1
	local iy = tileZ + self.radius + 1
	
	return self.hexGrid[iy][ix].tileType
end

function game:pointInView(x, y)
	local zoom = self.camera.zoom
	local width, height = love.graphics.getWidth()/zoom, love.graphics.getHeight()/zoom
	local scrnX, scrnY = self.camera.x+love.graphics.getWidth()/2-width/2, self.camera.y+love.graphics.getHeight()/2-height/2
	local tileWidth, tileHeight = self.tileW/zoom*1.5, self.tileH/zoom*1.5 -- a bit extra to detect a point that's near the screen
	
	if scrnX - tileWidth <= x and scrnX + width + tileWidth >= x and scrnY - tileHeight <= y and scrnY + height + tileHeight >= height then
		return true
	end
end