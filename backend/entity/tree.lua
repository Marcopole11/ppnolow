-- init called on creation of entity
local function init(self)
end

-- update called each simulation step, with dt being the number of seconds since last step (float)
local function update(self, dt)
end

-- called when this entity receives a message
local function message(self, msg)
end

-- entity file must return table of this format
return { init = init, update = update, message = message }
