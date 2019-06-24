Box = {w = 0, h = 0, num = 1, x = 0, y = 0, volume = 0, tp = 0}
Box.__index = Box

function Box:new(w, h, num, sw, sh)
    local self = {w = w, h = h, num = num, volume = w * h}
    setmetatable(self, Box)
    self.sw, self.sh = sw or w, sh or h
    return self
end 

function Box:getFitness(space)
    self.fit = {space.w - self.w, space.h - self.h}
    table.sort(self.fit)
end 

function Box:createLayer(space)
    local function getLayer(w, h)
        if w <= space.w and h <= space.h then 
            local layer1,layer2
            local row, column
            -- XY 
            column = math.min(math.floor(space.w / w), self.num)
            row    = math.min(math.floor(space.h / h), math.floor(self.num / column))
            layer1 = Box:new(w * column, h * row, row * column, w, h)
            -- YX
            row = math.min(math.floor(space.h / h), self.num) 
            column = math.min(math.floor(space.w / w), math.floor(self.num / row))
            
            if layer1.num > row * column then return layer1 end
        
            layer2 = Box:new(w * column, h * row, row * column, w, h)
            if layer2.num > layer1.num then
                return layer2
            else
                layer1:getFitness(space)
                layer2:getFitness(space)
                --if layer1.fit[1] < layer2.fit[1] or (layer1.fit[1] == layer2.fit[1] and layer1.fit[2] < layer2.fit[2]) then
                if compareLayer(layer1, layer2) then
                    return layer1
                else
                    return layer2
                end 
            end
        end 
    end 
    local layers = {getLayer(self.w, self.h)}
    if self.w ~= self.h then layers[#layers+1] = getLayer(self.h, self.w) end
    return space:getBestLayer(layers, space)
end 

function Box:cutSpaceOverlap()
    for i=#empty,1,-1 do                                                 
        local spaces = empty[i]:cutSpace(self)
        if #spaces > 0 then
            table.remove(empty, i)  
            for s=#spaces,1,-1 do
                if spaces[s] then
                    for j=i-1,1,-1 do if spaces[s]:isBeContained(empty[j]) then goto continue end end 
                    empty[#empty+1] = spaces[s]
                end 
                ::continue::
            end 
        end
    end 
end

function Box:reduce(num)
    self.num = self.num - num
end 

function Box:cutBox()
    for i=1,self.w/self.sw-1 do
        local line = Add3DLine(m3d, self.h)
        SetRotation(line, 0,-90,0)
        SetPosition(line, self.x + self.sw * i, 7, self.y)
    end 
    for i=1,self.h/self.sh-1 do
        local line = Add3DLine(m3d, self.w)
        SetPosition(line, self.x, 7, self.y + self.sh * i)
    end 
end 

function Box:setPosition(pos)
    self.x, self.y = pos[1], pos[2]
end 

function Box:pos()
    SetPosition(self.box, self.x + self.w / 2, 3, self.y + self.h / 2)
end 

function Box:draw()
    self.box = Add3DBox(m3d, self.w, self.h, 6, self.w, self.h, math.random(180))
end 