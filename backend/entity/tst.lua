-- init called on creation of entity
local function init(self)
    -- set self.Chunkloader = true means this entity's chunk will always remain loaded
    self.Chunkloader = true
    -- self.Data is an arbitrary table, this is persisted, populated here with target coordinates
    self.Data.target = { x = math.random(-64, 64), y = math.random(-64, 64) }
end

-- update called each simulation step, with dt being the number of seconds since last step (float)
local function update(self, dt)
    -- position must be fetched using self:GetPosition method
    x, y, _ = self:GetPosition()
    -- calculate distance from target on x and y axis
    local dx = self.Data.target.x - x
    local dy = self.Data.target.y - y
    -- if we're close enough then consider ourselves successful
    if dx * dx < 4 and dy * dy < 4 then
        self.Data.target = { x = math.random(-chunk.Size+1, chunk.Size*2-1), y = math.random(-chunk.Size, chunk.Size*2-1) }
    else
        -- determine largest direction of motion
        if dx * dx > dy * dy then
            dx = dx < 0 and -1 or 1
            dy = 0
        elseif dy * dy > dx * dx then
            dy = dy < 0 and -1 or 1
            dx = 0
        else
            dx = dx < 0 and -1 or 1
            dy = dy < 0 and -1 or 1
        end
        -- self:Move(dx, dy, dz) moves relative to current position
        -- by multiplying by dt we move at a constant speed regardless of performance
        -- we also have self:MoveTo(x, y, z) which moves to an absolute position
        -- note that z is left as 0 as this is a 2D game
        self:Move(dx * dt, dy * dt, 0)
    end
end

-- called when this entity receives a message
local function message(self, msg)
end

-- entity file must return table of this format
return { init = init, update = update, message = message }
