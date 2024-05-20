---------------------------------
-- enemy.lua
---------------------------------


local physics = require("physics")

Enemy = {HP=0,enemyShape=nil}
function Enemy:new(o)
    o = o or {}
    setmetatable(o,self)
    self._index = self
    return self
end
function OnLocalCollision(self,event)
    --remove self if past screen borders
    if(event.phase == 'ended')
    then
        if(event.other.name~="enemy")
        then
            if(event.other.name == "wall")
            then
                self:removeSelf();
                self = nil 
            else 
            self.enemy.HP = self.enemy.HP - 1
            if(self.enemy.HP <=0)
            then
                self:removeSelf();
                self = nil
            end
            end
        end
    end
    return true
end
function Enemy:spawn()
    physics.addBody(self,"kinematic");
end
function Enemy:move()
end
function Enemy:remove()

return true
end