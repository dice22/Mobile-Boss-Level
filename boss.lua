---------------------------------
-- boss.lua
---------------------------------

require("enemy") -- require enemy.lua
--require("game") -- require game.lua 
local soundTable = require("soundTable");
local composer = require("composer")
--physics.start()
--physics.setGravity(0, 9.8) -- earth gravity
--require("game") -- require game.lua

local bulletSpeed = 500
local bossHP = 5 -- should be 30 but is 5 rn

local fishFrames = {
	frames = {
		{x= 22, y= 9, width= 163, height=53}, -- fish body (index 1)

		{x= 209, y= 27, width= 16, height=10}, -- snout frame 1 (index 2)
		{x=227, y=26, width=18, height=12}, -- snout frame 2 (index 3)
		{x=250, y=27, width=16, height=10}, -- snout frame 3 (index 4)

		{x=280, y=19, width=60, height=26 }, -- mouth frame 1 (index 5)
		{x=343, y=19, width=60, height=26}, -- mouth frame 2 (index 6)
		{x=406, y=19, width=60, height=26}, -- mouth frame 3 (index 7)

		{x=20, y=92, width=56, height=38}, -- pectoral fin 1 (index 8)
		{x=78, y=95, width=56, height=38}, -- pectoral fin 2 (index 9)
		{x=139, y=99, width=56, height=38}, -- pectoral fin 3 (index 10)

		{x=208, y=70, width=49, height=92}, -- Caudal fin 1 (index 11)
		{x=266, y=77, width=57, height=78}, -- Caudal fin 2 (index 12)
		{x=331, y=85, width=60, height=64}, -- Caudal fin 3 (index 13)

		{x=406, y=88, width=60, height=58}, -- dorsal fin frame (index 14)

		{x=11, y=184, width=225, height=113}, -- complete body frame (index 15)
	}
}

-- each sequence data has three sequences, one for when the fish is moving, one to play only the opening animation
-- and one for closing

local snoutSequenceData = {
	{name="snoutMove",frames={2,3,4},time=300,loopCount=0,loopDirection="forward"},
	{name="snoutOpen",frames={2,3,4},time=300,loopCount=1,loopDirection="forward"},
	{name="snoutClose",frames={4,3,},time=300,loopCount=1,loopDirection="forward"},
}

local mouthSequenceData ={
	{name="mouthMove",frames={5,6,7},time=800,loopCount=0,loopDirection="forward"},
	{name="mouthOpen",frames={5,6,7},time=800,loopCount=1,loopDirection="forward"},
	{name="mouthClose",frames={7,6,5},time=800,loopCount=1,loopDirection="forward"},
}

local pFinSequenceData ={ -- chest fin
	{name="pFinMove",frames={8,9,10},time=800,loopCount=0,loopDirection="forward"},
	{name="pFinOpen",frames={8,9,10},time=800,loopCount=1,loopDirection="forward"},
	{name="pFinClose",frames={10,9,8},time=800,loopCount=1,loopDirection="forward"}
}

local cFinSequenceData ={ -- tail fin
	{name="cFinMove",frames={11,12,13},time=800,loopCount=0,loopDirection="forward"},
	{name="cFinOpen",frames={11,12,13},time=800,loopCount=1,loopDirection="forward"},
	{name="cFinClose",frames={13,12,11},time=800,loopCount=1,loopDirection="forward"},
}

--[[local function updateHPText()
	if hpText then
        hpText:removeSelf() 
        hpText = nil
    end
	hpText = display.newText("boss HP: " .. bossHP, display.contentCenterX, display.contentHeight - 50,native.systemFontBold,24)
end]]

local function decreaseBossHP()
    bossHP = bossHP - 1 -- decrease boss's HP
    --updateHPText() -- update and display the HP

	if bossHP <= 0 then
		FishBoss:stop() -- stop boss animations & movements
		
		--[[local function goToTitleScreen()
			print("going to title")
			composer.gotoScene("title", { effect = "slideRight", time = 500 }) -- Adjust the transition effect and time as needed
		end
		
		local function onTap(event)
			print("game is won and ive been tapped")
			goToTitleScreen() 
			return true
		end
		
		-- Create an invisible overlay to cover the entire screen and capture taps
		local overlay = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
		overlay.isVisible = false  -- Make the overlay invisible
		overlay.isHitTestable = true  -- Ensure the overlay can receive tap events
		
		-- Add tap event listener to the overlay
		overlay:addEventListener("tap", onTap)
		
		-- Show the "Congratulations!" text
		local congratsText = display.newText("Congratulations!", display.contentCenterX, display.contentCenterY, native.systemFontBold, 36)
		congratsText:setTextColor(0, 1, 0) -- Make the congrats text green]]
		
		local congratsText = display.newText("Congratulations!",display.contentCenterX, display.contentCenterY, native.systemFontBold, 36)
		congratsText:setTextColor(0,1,0) -- make the congrats text green
	
		local function goToTitleScreen()
			print("going to title screen")
            composer.gotoScene("title", { effect = "slideRight", time = 500 }) 
        end

        local function onTap(event)
			print("the game is won and ive been tapped")
            goToTitleScreen() 
            return true
        end

        congratsText:addEventListener("tap", onTap)
	end

end


local function bossCollision(self, event)
    if event.phase == "began" then
		print("blshhhhhh")
        if event.other.tag == "bullet" then
            print("Bullet hit boss!")
			decreaseBossHP()
        end
    end
    return true
end

FishBoss = {} -- make boss table

function FishBoss:new(o)
    o = o or Enemy:new()
    setmetatable(o,self)
    self._index = self


    self.enemyShape = display.newGroup();

	physics.addBody(self.enemyShape, "dynamic", { radius = 30 }) 

    self.enemyShape.collision = bossCollision
    self.enemyShape:addEventListener("collision", self.enemyShape)

    return self
end

--updateHPText()

function FishBoss:spawn() 
	local fishSheet = graphics.newImageSheet("KingBayonet.png",fishFrames)
	
	self.enemyShape.anchorX=.5
	self.enemyShape.anchorY=.5
	self.enemyShape.x = display.contentCenterX
	self.enemyShape.y = display.contentCenterY

	--makes sure when we scale the fish, it stays in the same x y position
	self.enemyShape.anchorChildren = true
	local bodySprite = display.newImage(fishSheet,1)

	--set start location to screen center
	bodySprite.x = display.contentCenterX
	bodySprite.y = display.contentCenterY
	self.enemyShape:insert(bodySprite)
	local dorsalFinSprite = display.newImage(fishSheet,14)

	--specify x and y relative to body
	dorsalFinSprite.x = bodySprite.x+37
	dorsalFinSprite.y = bodySprite.y-40
	self.enemyShape:insert(dorsalFinSprite)
	local mouthSprite = display.newSprite(fishSheet,mouthSequenceData)

	--specify x and y relative to body
	mouthSprite.x = bodySprite.x-35
	mouthSprite.y = bodySprite.y+2
	self.enemyShape:insert(mouthSprite)
	local snoutSprite = display.newSprite(fishSheet,snoutSequenceData)

	--specify x and y relative to body
	snoutSprite.x = bodySprite.x-85
	snoutSprite.y = bodySprite.y
	self.enemyShape:insert(snoutSprite)
	local pFinSprite = display.newSprite(fishSheet,pFinSequenceData )

	--specify x and y relative to body
	pFinSprite.x = bodySprite.x+25
	pFinSprite.y = bodySprite.y+22
	self.enemyShape:insert(pFinSprite)
	local cFinSprite = display.newSprite(fishSheet,cFinSequenceData)

	--specify x and y relative to body
	cFinSprite.x = bodySprite.x+100
	cFinSprite.y = bodySprite.y-5
	self.enemyShape:insert(cFinSprite)

	physics.addBody(self.enemyShape,"kinematic");
	self.enemyShape.collision = bossCollision
	self.enemyShape:addEventListener("collision")


end


function FishBoss:shoot() -- spawn & shoot the bullets
	--local playerX, playerY = cubePlayer.x, cubePlayer.y
	
	local bullet = display.newCircle(self.enemyShape.x, self.enemyShape.y - 16, 5) 
    bullet:setFillColor(1, 0, 0) -- make the bullets red
    physics.addBody(bullet, "dynamic", { radius = 5 }) 

	bullet.tag = "bullet" -- give bullet a tag

    --[[local angle = math.atan2(playerY - self.enemyShape.y, playerX - self.enemyShape.x)
    local bulletSpeedX = bulletSpeed * math.cos(angle)
    local bulletSpeedY = bulletSpeed * math.sin(angle)

    bullet:setLinearVelocity(bulletSpeedX, bulletSpeedY)]]

	bullet:setLinearVelocity(0, 900) -- just make the bullets rain from the fish

	audio.play( soundTable["bossShoot"] );

	--local playerHP = 5 
	--local hpText

	--local hpText = display.newText({"HP: " .. playerHP, display.contentCenterX, 80,native.systemFontBold,24})

	--local hpText = display.newText({text = "HP: " .. playerHP, x = display.contentCenterX, y = 80, font = native.systemFontBold, fontSize = 24})


    local function removeBullet(event)
        if (event.phase == "began") then
            event.target:removeSelf()
            event.target = nil
        end

		--if (event.other.tag == "player") then 
			--print("OMG PLAYER GOT HIT")
			--playerHP = playerHP - 1
			--decreaseHP()
		--end

    end

	--updateHP()
    bullet:addEventListener("collision", removeBullet)
end

function FishBoss:move() 
    	--make sure each sprite is on the "moving" sequence
		self.enemyShape[3]:setSequence("mouthMove")
		self.enemyShape[3]:play()
		self.enemyShape[4]:setSequence("snoutMove")
		self.enemyShape[4]:play()
		self.enemyShape[5]:setSequence("pFinMove")
		self.enemyShape[5]:play()
		self.enemyShape[6]:setSequence("cFinMove")
		self.enemyShape[6]:play()

		local function shootBullets() -- shoot those bullets!!!!???
			FishBoss:shoot() 
		end
	
		-- shoot bullets every 2 seconds
		timer.performWithDelay(2000, shootBullets, -1)

		--move fish once every 1.5 seconds 
		timer.performWithDelay(1500,function ()
            local newX = math.random(300,600)
            local newY = math.random(0,display.contentHeight / 2) -- 1130 was og y value. 
			-- display.contentHeight/2 makes the fish only move in the top of the screen 
			-- so it doesnt move on top of pc

            transition.to(self.enemyShape,{time = 1000, x = newX, y = newY})
        end,0,"fishMovement")
	return true
end

--[[local function onBulletCollision(event)
    local phase = event.phase
    local projectile = event.target
    if phase == "began" then
        if event.other == cube then
            display.remove(bullet)
            return true 
        end
    end
end]]

--stops all fish animation, and resets the fish to its starting frames	
function FishBoss:stop()
    timer.cancel("fishMovement")
	transition.cancel();
	self.enemyShape[3]:pause()
	self.enemyShape[3]:setFrame(1)
	self.enemyShape[4]:pause()
	self.enemyShape[4]:setFrame(1)
	self.enemyShape[5]:pause()
	self.enemyShape[5]:setFrame(1)
	self.enemyShape[6]:pause()
	self.enemyShape[6]:setFrame(1)
end





