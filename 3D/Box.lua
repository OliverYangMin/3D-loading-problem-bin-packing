Box = {tp, w = 0, h = 0, d = 0, num = 1, vw = true, vh = true, vd = true}
Box.__index = Box
function Box:new(tp, w, h, d, num, vw, vh, vd)
    local self = {tp = tp, w = w, h = h, d = d, num = num, vw = vw == 1, vh = vh == 1, vd = vd == 1}
    setmetatable(self, Box)
    return self
end 

function Box:reduce(num)
    self.num = self.num - num
end 

function Box:getLayersFromDiffDirection(space) -- 3 * 2 * 1 = 6  -- ToDo   add direction change limitation
    local layers = {}
    if self.vw then
        layers[#layers+1] = space:getLayer(self.h, self.w, self.d, self)
        if self.h ~= self.d then layers[#layers+1] = space:getLayer(self.d, self.w, self.h, self) end 
    end 
    
    if self.vh then
        layers[#layers+1] = space:getLayer(self.w, self.h, self.d, self)
        if self.w ~= self.d then layers[#layers+1] = space:getLayer(self.d, self.h, self.w, self) end 
    end 
    
    if self.vd then
        layers[#layers+1] = space:getLayer(self.w, self.d, self.h, self)
        if self.w ~= self.h then layers[#layers+1] = space:getLayer(self.h, self.d, self.w, self) end     
    end 
    return layers
end 