local physics = require("physics")
require("enemy")
Enemy1 = {}
function Enemy1:move()
    self.enemyShape:applyForce(0,math.random(30,50), self.enemyShape.x, self.enemyShape.y)
end

function Enemy1:spawn()
    self.enemyShape.isVisible = true
    physics.addBody(self.enemyShape,"dynamic");
    self.enemyShape.collision = OnLocalCollision
    --allows us to reference parent object in collision functiown
    self.enemyShape.enemy = self
    self.enemyShape:addEventListener("collision")
end
function Enemy1:new(o)
    o = o or Enemy:new(o)
    setmetatable(o,self)
    self._index = self
    self.HP = 2
    self.enemyShape = display.newRect(math.random(0,640),10,40,40)
    self.enemyShape.isVisible = false
    return self
end


