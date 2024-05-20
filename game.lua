---------------------------------
-- game.lua
----------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local physics = require("physics")
require("enemy1") -- so enemy1 can work
require("enemy2") -- so enemy2 can work
require("boss") -- so boss can work DUUUHHHH
local soundTable = require("soundTable"); -- so we can use the sounds!!!
physics.start()
physics.setGravity(0,0);
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 local allEnemies = {}
 local enemyTimer 
 local cubePlayer
 local score = 0
 local scoreText
 local playerHP = 5 
 local hpText

---------------------------------------------------------------------------------
-- "scene:create()"
function scene:create( event )
    local sceneGroup = self.view

    --add wall sensors to tell enemys when to despawn
    --invisible rectangles that only serve to send collision events
    --because these walls are static, they will not send collision events 
    --to the kinematic player character, only the dynamic enemy objects
    local backWall = display.newRect(sceneGroup,0,0,2,1500)
    backWall.isVisible = false
    backWall.name = "wall"
    physics.addBody( backWall, "static", { isSensor=true } )
    local bottomWall = display.newRect(sceneGroup,0,1163,2000,2)
    bottomWall.isVisible = false
    bottomWall.name = "wall"
    physics.addBody( bottomWall, "static", { isSensor=true } )
--local function moveBg()
    local bg1 = display.newImageRect("farback.png", display.contentWidth, display.contentHeight)
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY

    local bg2 = display.newImageRect("starfield.png", display.contentWidth, display.contentHeight)
    bg2.x = display.contentCenterX
    bg2.y = display.contentCenterY

    sceneGroup:insert(bg1) --so they can be removed when the scene changes
    sceneGroup:insert(bg2)

local function moveBg()
    bg1.x = bg1.x - 1
    bg2.x = bg2.x - 3

    if (bg1.x + bg1.contentWidth) < display.screenOriginX then
        bg1.x = display.contentWidth
    end
    if (bg2.x + bg2.contentWidth) < display.screenOriginX then
        bg2.x = display.contentWidth
    end


end


    Runtime:addEventListener("enterFrame", moveBg)
    

--player controller stuff + player itself
    local controlBar = display.newRect (display.contentCenterX, display.contentHeight-65, display.contentWidth, 70);
    controlBar:setFillColor(1,1,1,0.5);

    sceneGroup:insert(controlBar)

   local cubePlayer = display.newCircle (display.contentCenterX, display.contentHeight-150, 15);
   physics.addBody (cubePlayer, "kinematic");
    cubePlayer.tag = "player"

    sceneGroup:insert(cubePlayer)

   local function move ( event )
    if event.phase == "began" then		
       cubePlayer.markX = cubePlayer.x 
    elseif event.phase == "moved" then	 	
        local x = (event.x - event.xStart) + cubePlayer.markX	 	
        
        if (x <= 20 + cubePlayer.width/2) then
          cubePlayer.x = 20+cubePlayer.width/2;
       elseif (x >= display.contentWidth-20-cubePlayer.width/2) then
          cubePlayer.x = display.contentWidth-20-cubePlayer.width/2;
       else
          cubePlayer.x = x;		
       end

    end

end
controlBar:addEventListener("touch", move);

local function updateScore()
    if scoreText then
        scoreText:removeSelf() -- Remove existing score text
        scoreText = nil
    end

    scoreText = display.newText("Score: " .. score, display.contentCenterX, 50,native.systemFontBold,24)
end   

local function onEnemyDestroyed()
    score = score + 100 -- increase score by 100 when an enemy is destroyed
    updateScore()
end

local function updateHP()
    if hpText then
        hpText:removeSelf() 
        hpText = nil
    end

    hpText = display.newText("HP: " .. playerHP, display.contentCenterX, 80,native.systemFontBold,24)

end

local function resetGame() -- reset game 
    print("game is reset")
    
    -- cancel timers
    if enemyTimer then
        timer.cancel(enemyTimer)
    end

    -- remove event listeners
    Runtime:removeEventListener("tap", fire)

    -- remove display objects and groups
    display.remove(cubePlayer)
    display.remove(scoreText)
    display.remove(hpText)

    -- reset variables to their initial values
    score = 0
    playerHP = 5
end

local function startOver(event)
    print("starting over")
    resetGame()
    --if event.phase == "began" then
        composer.gotoScene("title", {
             "slideRight", 
             time = 800 
        })
    --end

end

local function gameOver()
    local youLose = display.newText("GAME OVER", display.contentCenterX, display.contentCenterY, native.systemFontBold, 60)
    sceneGroup:insert(youLose)

    physics.pause()
    transition.pause()
    timer.pauseAll()
    audio.pause()

    youLose:addEventListener("tap", startOver)
    --bg2:addEventListener("tap", startOver)

end


local function decreaseHP()
    playerHP = playerHP - 1 -- decrease player's HP
    if playerHP == 0 then 
        gameOver() --THIS LOSER PLAYER DEAD
    end
   --playerHP = playerHP - 1 -- decrease player's HP
   updateHP() -- update and display the HP
end 

--sceneGroup:insert(youLose)

--pc gets hit by bullet and loses health
local function playerHit(event)
    if (event.phase == "began") then
        --if playerHP == 0 then 
          --  gameOver() --THIS LOSER PLAYER DEAD
        --end
        print("OMG PLAYER GOT HIT")
        decreaseHP()

    end

end

cubePlayer:addEventListener("collision", playerHit)

local function decreaseHP()
    playerHP = playerHP - 1 -- decrease player's HP
    if playerHP == 0 then 
        gameOver() --THIS LOSER PLAYER DEAD
    end
   --playerHP = playerHP - 1 -- decrease player's HP
   updateHP() -- update and display the HP
end 

--sceneGroup:insert(youLose)

--pc gets hit by bullet and loses health
local function playerHit(event)
    if (event.phase == "began") then
        --if playerHP == 0 then 
          --  gameOver() --THIS LOSER PLAYER DEAD
        --end
        print("OMG PLAYER GOT HIT")
        decreaseHP()
        
    end

end

cubePlayer:addEventListener("collision", playerHit)

-- shoot bullets from pc
local cnt = 0;
local function fire (event) 
    cnt = cnt+1;
	local p = display.newCircle (cubePlayer.x, cubePlayer.y-16, 5);
	p.anchorY = 1;
	p:setFillColor(0,1,0);
	physics.addBody (p, "dynamic", {radius=5} );
	p:applyForce(0, - 2, p.x, p.y);

	audio.play( soundTable["pcShoot"] );

	local function removeProjectile (event)
      if (event.phase=="began") then
	   	 event.target:removeSelf();
         event.target=nil;
         cnt = cnt - 1;

         --[[if (event.other == boss.enemyShape) then
            boss:Hurt() -- boss loses 1 hp
         end]]
         onEnemyDestroyed()
         audio.play( soundTable["enemyHitBullet"] );
         

         if (event.other.tag == "enemy") then

         	event.other.pp:hit();
         	--decreaseHP() -- doesnt work. i think im calling this in the wrong 
                         -- place but idk where to actually call it so..
         end
      end
    end
    p:addEventListener("collision", removeProjectile);
end

Runtime:addEventListener("tap", fire)

updateScore()
updateHP()

sceneGroup:insert(scoreText)
sceneGroup:insert(hpText)


end

-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
    

   --spawn enemies for 2 min before boss shows up
        enemyTimer = timer.performWithDelay(1000,function () -- 1000
            local whoToSpawn = math.random(0,10)
            if(whoToSpawn > 5)then
                local s = Enemy1:new()
                s:spawn()
                s:move()

            else
                local s2 = Enemy2:new()
                s2:spawn()
                s2:move(cubePlayer)
            end
        end,120)
      --show boss once after 2 min
      timer.performWithDelay(6000,function () -- 120000
        --set up boss
       local boss = FishBoss:new()
       boss:spawn()

       boss:move(cubePlayer)

       --sceneGroup:insert(boss)

       --boss:spawnBullets() 
       if enemyTimer then 
        timer.cancel(enemyTimer) -- make enemies stop spawning after boss shows up
       end 
      end,1)
   end
end
 
-- "scene:hide()"
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------
 
return scene
