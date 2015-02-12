game = {}

function game:enter()
	self.angleChange1 = math.rad(30)
	self.angleChange2 = math.rad(-30)
	
	self.lastMouseX = 0
	self.lastMouseY = 0
	
    self.canvas = love.graphics.newCanvas()
	self:startTree()
	
	self.random = false
end

function game:startTree()
	self.canvas:clear()
	self.canvas:renderTo(function()
		love.graphics.setColor(100, 25, 25)
		local x, y = love.graphics.getWidth()/2, love.graphics.getHeight()*9/10
		local points = {}

		local l = 200
		local angle = math.rad(-90)
		
		
		
		local iter = 1
		--love.graphics.polygon('fill', points)
		--love.graphics.setColor(0, 0, 0)
		self:drawBranch(x, y, angle, l, iter)
	end)
end

function game:drawBranch(x, y, angle, l, iter)
	local x2 = x + math.cos(angle)*l
	local y2 = y + math.sin(angle)*l
	
	iter = iter+1
	love.graphics.setColor(100, (14/l)*100+25, 25)
	
	love.graphics.line(x, y, x2, y2)
	if iter < 10 then
		if self.random then
			local branches = math.random(2, 3)
			for i = 1, branches do
				local angle = i*(self.angleChange1-self.angleChange2)/branches + angle
				self:drawBranch(x2, y2, angle + math.rad(math.random(-50, 50)), l * (math.random(3,6)/8), iter)
			end
		else
			l = l*3/5
			self:drawBranch(x2, y2, angle+self.angleChange1, l, iter)
			self:drawBranch(x2, y2, angle+self.angleChange2, l, iter)
		end
	end
end

function game:update(dt)
	local mouseX, mouseY = love.mouse.getPosition()
	
	if mouseX ~= self.lastMouseX or mouseY ~= self.lastMouseY then
		self.lastMouseX = mouseX
		self.lastMouseY = mouseY
	
		self.angleChange1 = math.rad((mouseX/love.graphics.getWidth()-.5)*2*180)
		self.angleChange2 = math.rad((mouseY/love.graphics.getHeight()-.5)*2*180)
		
		self:startTree()
	end
end

function game:keypressed(key, isrepeat)
    if console.keypressed(key) then
        return
    end
	
	if key == 'f1' then
		if self.random then
			self.random = false
		else
			self.random = true
		end
		self:startTree()
	end
	
	if key == ' ' then
		self:startTree()
	end
end

function game:mousepressed(x, y, mbutton)
    if console.mousepressed(x, y, mbutton) then
        return
    end
end

function game:draw()
	love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.canvas)
	
	love.graphics.print(love.timer.getFPS(), 5, 5)
	
	local state = 'false'
	if self.random then state = 'true' end
	love.graphics.print('random (f1): '..state, 5, 35)
end