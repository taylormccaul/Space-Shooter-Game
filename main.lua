debug = true

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2 
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
createGemTimerMax = 0.9
createGemTimer = createGemTimerMax

-- Player Object
player = { x = 200, y = 510, speed = 130, img = nil }
isAlive = true
score = 0

background = { x = 400, y = 710, img = nil }

-- Image Storage
bulletImg = nil
enemyImg = nil
gemImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen
gems = {} -- array of current gems on screen

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- Loading
function love.load(arg)
	player.img = love.graphics.newImage('assets/3.png')
	enemyImg = love.graphics.newImage('assets/shipenemy.png')
	bulletImg = love.graphics.newImage('assets/shot7.png')
	gemImg = love.graphics.newImage('assets/gem1.png')
	background.img = love.graphics.newImage('assets/background.jpg')
	remaining_time = 5
	powerup_end = false
end


-- Updating
function love.update(dt)
	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out gem creation
	createGemTimer = createGemTimer - (1.4 * dt)
	if createGemTimer < 0 then
		createGemTimer = createGemTimerMax

		-- Create a gem powerup
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newGem = { x = randomNumber, y = -4, img = gemImg }
		table.insert(gems, newGem)
	end

	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = { x = randomNumber, y = -10, img = enemyImg }
		table.insert(enemies, newEnemy)
	end


	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 850 then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
		end
	end

	-- update the positions of powerups
	for i, gem in ipairs(gems) do
		gem.y = gem.y + (200 * dt)

		if gem.y > 850 then -- remove powerups when they pass off the screen
			table.remove(gems, i)
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	--[[for i, gem in ipairs(gems) do
		for j, player in ipairs(players) do --replace with bullet/bullets to fix
			if CheckCollision(gem.x, gem.y, gem.img:getWidth(), gem.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) then
				table.remove(gems, i)
				score = score + 1
			end
		end]]--
	
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end

		if score >= 50 then
			enemyImg = love.graphics.newImage('assets/ship1.png')
		end

		if score >= 100 then
			enemyImg = love.graphics.newImage('assets/shipenemy8.png')
		end
	end

	--[[if score >= 50 then
		enemyImg = love.graphics.newImage('assets/ship1.png')
				if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) >= 2 then
					table.remove(bullets, j)
					table.remove(enemies, i)
					score = score + 1
				end
			end]]--
	--end

	--[[if score >= 50 then
		enemyImg = love.graphics.newImage('assets/ship1.png')
	end]]--

	for i, gem in ipairs(gems) do
		if CheckCollision(gem.x, gem.y, gem.img:getWidth(), gem.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) then
			table.remove(gems, i)
			score = score + 1
			player.speed = 170
			remaining_time = remaining_time - dt
		if remaining_time <= 0 then
			player.speed = 130
		end
		end

	    --[[if CheckCollision(gem.x, gem.y, gem.img:getWidth(), gem.img:getHeight(), player.x, player.x, player.img:getWidth(), player.img:getHeight()) then
		and isAlive then
		    table.remove(gems, i)
		    isAlive = true
	    end
	end]]--

	if love.keyboard.isDown('left','a') then
		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	elseif love.keyboard.isDown('up','w') then
		if player.y > 0 then
			player.y = player.y - (player.speed*dt)
		end
	elseif love.keyboard.isDown('down','s') then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed*dt)
		end
	end

	if love.keyboard.isDown('space') and canShoot then
		-- Create some bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}
		gems = {}

		-- reset timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax
		createGemTimer = createGemTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 510

		-- reset our game state
		score = 0
		isAlive = true
	end

-- Drawing
function love.draw(dt)
	love.graphics.draw(background.img)
	
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

	for i, gem in ipairs(gems) do
		love.graphics.draw(gem.img, gem.x, gem.y)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("SCORE: " .. tostring(score), 400, 10)

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	if debug then
		fps = tostring(love.timer.getFPS())
		love.graphics.print("Current FPS: "..fps, 9, 10)
	end
end


--[[

function love.load()
	player = {xPos = 0, yPos = 0, width = 64, height = 64, speed = 200, img = shipImg}
	shots = {}

	canFire = false
	shotTimerMax = 0.2
	shotTimer = shotTimerMax
	shotStartSpeed = 100
	shotMaxSpeed = 300
end

function love.draw()
	love.graphics.setColor(186, 255, 255)
	background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255, 255, 255)

	love.graphics.draw(player.img, player.xPos, player.yPos, 0, 2, 2) 
	for index, shot in ipairs(shots) do
		love.graphics.draw(shot.img, shot.xPos, shot.yPos)
	end
end

--[[	downUp = love.keyboard.isDown("down") or love.keyboard.isDown("up")
	leftRight = love.keyboard.isDown("left") or love.keyboard.isDown("right")

	speed = playerSpeed
	if(downUp and leftRight) then
		speed = speed / math.sqrt(2)
	end

	if love.keyboard.isDown("down") and yPos < love.graphics.getHeight() - playerHeight then
		yPos = yPos + dt * speed
	elseif love.keyboard.isDown("up") and yPos > 0 then
		yPos = yPos - dt * speed
	end

	if love.keyboard.isDown("right") and xPos<love.graphics.getWidth()-playerWidth then
		xPos = xPos + dt * speed
	elseif love.keyboard.isDown("left") and xPos>0 then
		xPos = xPos - dt * speed
	end
end--]]

--[[function love.update(dt) --dt stands for deltaTime
	updatePlayer(dt)
	updateShots(dt)
	createEnemyTimer = createEnemyTimer - (1 * dt)
if createEnemyTimer < 0 then
	createEnemyTimer = createEnemyTimerMax
	-- Create an enemy
	randomNumber = math.random(10, love.graphics.getWidth() - 10)
	newEnemy = { x = randomNumber, y = -10, img = enemyImg }
	table.insert(enemies, newEnemy)
end

for i, enemy in ipairs(enemies) do
	enemy.y = enemy.y + (200 * dt)

	if enemy.y > 850 then -- remove enemies when they pass off the screen
		table.remove(enemies, i)
	end
end

for i, enemy in ipairs(enemies) do
	love.graphics.draw(enemy.img, enemy.x, enemy.y)
end

end

function updatePlayer(dt)
	down = love.keyboard.isDown("down")
	up = love.keyboard.isDown("up")
	left = love.keyboard.isDown("left")
	right = love.keyboard.isDown("right")

	speed = player.speed
	if((down or up) and (left or right)) then
		speed = speed / math.sqrt(2)
	end

	if down and player.yPos<love.graphics.getHeight()-player.height then
		player.yPos = player.yPos + dt * speed
	  elseif up and player.yPos>0 then
		player.yPos = player.yPos - dt * speed
	  end
	
	  if right and player.xPos<love.graphics.getWidth()-player.width then
		player.xPos = player.xPos + dt * speed
	  elseif left and player.xPos>0 then
		player.xPos = player.xPos - dt * speed
	  end

	if love.keyboard.isDown("space") then
		shotSpeed = shotStartSpeed
		if(left) then
		  shotSpeed = shotSpeed - player.speed/2
		elseif(right) then
		  shotSpeed = shotSpeed + player.speed/2
		end
		spawnShot(player.xPos + player.width/2, player.yPos, shotSpeed)
	  end
	
	  if shotTimer > 0 then
		shotTimer = shotTimer - dt
	  else
		canFire = true
	  end
	end

	  function updateShots(dt)
		for index, shot in ipairs(shots) do
		  shot.yPos = shot.yPos - (250 * dt) --shot.xPos = shot.xPos + dt * shot.speed
		  if shot.speed < shotMaxSpeed then
			shot.speed = shot.speed + dt * 100
		  end
		  if shot.yPos < 0 --[[ love.graphics.getHeight()]] --[[then
			--torpedo = nil -does not actually work-
			table.remove(shots, index)
		  end
		end
	  end

	  function spawnShot(x, y, speed)
		if canFire then
		  shot = {xPos = x, yPos = y, width = 16, height = 16, speed = speed, img = shotImg}
		  table.insert(shots, shot)
	  
		  canFire = false
		  shotTimer = shotTimerMax
		end
	  end
		--[[createEnemyTimer = createEnemyTimer - (1 * dt)
		if createEnemyTimer < 0 then
			createEnemyTimer = createEnemyTimerMax

			randomNumber = math.random(10, love.graphics.getWidth() - 10)
			newEnemy = {x = randomNumber, y = -10, img = enemyImg}
			table.insert(enemies, newEnemy)
		end

		for i, enemy in pairs(enemies) do
			love.graphics.draw(enemyImg, enemy.x, enemy.y)
		end
	end]]--
		--[[ function love.load()
	xPos = 0
	yPos = 0
	playerWidth = 64
	playerHeight = 64
	playerSpeed = 200
	carImage = love.graphics.newImage("C:\Users\paige\carclip.png")
end

function love.draw()
	love.graphics.print(carImage, xPos, yPos, 0, 2, 2)
end

function love.update()
	downUp = love.keyboard.isDown("down") or love.keyboard.isDown("up")
	leftRight = love.keyboard.isDown("left") or love.keyboard.isDown("right")

	speed = playerSpeed
	if(downUp and leftRight) then
		speed = speed / math.sqrt(2)
	end

	if love.keyboard.isDown("down") and yPos < love.graphics.getHeight()-playerHeight then
		yPos = yPos + dt * speed
	elseif love.keyboard.isDown("up") and yPoz > 0 then
		yPos = yPos - dt * speed
	end]]--
end
end