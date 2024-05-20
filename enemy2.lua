local physics = require("physics")
require("enemy")
Enemy2 = {}
function Enemy2:new(o)
    o = o or Enemy:new(o)
    setmetatable(o,self)
    self._index = self
    self.HP = 2
    --star shape
    local triangle
    local vertices = {}
    local x1,y1,x2,y2,x3,y3
    local realHeight = math.sqrt((100)^2-(100*0.5)^2)
    x1 = 0
    y2 = realHeight/2
    y3 = y2
    y1 = y3 - realHeight 
    x2 = -100/2
    x3 = 100/2
    y2 = 100/2
    y3 = y2
     --Making the triangle
     table.insert (vertices,x1)
     table.insert (vertices,y1)
     table.insert (vertices,x2)
     table.insert (vertices,y2)
     table.insert (vertices,x3)
     table.insert (vertices,y3)
     self.enemyShape = display.newPolygon(math.random(0,640),10, vertices)
     
     self.enemyShape.rotation = math.random(360)-180 -- ±180°
    self.enemyShape.isVisible = false
    self.enemyShape.enemy = self
 
    return self
    
end
function Enemy2:spawn()
    self.enemyShape.isVisible = true
    physics.addBody(self.enemyShape,"dynamic");
    self.enemyShape.collision = OnLocalCollision
    self.enemyShape:addEventListener("collision")
end
function Enemy2:move()
    self.enemyShape:applyForce(0,math.random(20,50), self.enemyShape.x, self.enemyShape.y)
    
end
       