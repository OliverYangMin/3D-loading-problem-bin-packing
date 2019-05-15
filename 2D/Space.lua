local function distance(node1, node2)
    local dis = {math.abs(node1[1] - node2[1]), math.abs(node1[2] - node2[2])}
    table.sort(dis)
    return dis
end

Space = {x = 0, y = 0, corners = {}, volume = 0, node1 = {}, node2 = {}}
Space.__index = Space

function Space:new(node1, node2)
    local self = {node1 = node1, node2 = node2} 
    setmetatable(self, Space)
    self.x, self.y = {node1[1], node2[1]}, {node1[2], node2[2]}
    self.w, self.h = node2[1] - node1[1], node2[2] - node1[2]
    self.corners = {node1, {node2[1], node1[2]}, node2, {node1[1], node2[2]}}
    self.volume = self.w * self.h
    if self.w == W and self.h == H then 
        self.dis, self.mcorner = {0,0}, 1
    else
        self.dis, self.mcorner = self:minSpaceDistance()
    end 
    return self
end 

function Space:getBestLayer(cLayers)
    for i=1,#cLayers do if not cLayers[i].fit then cLayers[i]:getFitness(self) end end 
    table.sort(cLayers, function(a,b) return a.volume>=b.volume and a.fit[1]<=b.fit[1] and a.fit[2]<b.fit[2] end)
    return cLayers[1]
end

function Space:chooseBestLayer()
    local best_layer, layer_type = {volume = 0} 
    for i, rect in ipairs(rects) do 
        if rect.num > 0 then 
            local layer = rect:createLayer(self)
            if layer and compareLayer(layer, best_layer) then
                best_layer, layer_type = layer, i
            end 
        end 
    end 
    return best_layer, layer_type
end 


function Space:minSpaceDistance()
    local min, mcorner = {math.huge, math.huge}
    for c,corner in ipairs(self.corners) do
        for cc,c_corner in ipairs(container.corners) do
            local dis = distance(corner, c_corner)
            if compareTable(dis, min) then 
                min, mcorner = dis, c
            end 
        end 
    end 
    return min, mcorner
end 

function Space:isBeContained(space)
    return space.x[1] <= self.x[1] and space.y[1] <= self.y[1] and space.x[2] >= self.x[2] and space.y[2] >= self.y[2] 
end 

function Space:createMaxSpace(rect)
    local spaces = {}
    if rect.w < self.w then 
        if self.mcorner%4 < 2 then
            spaces[#spaces+1] = Space:new({self.x[1] + rect.w, self.y[1]}, self.node2) 
        else
            spaces[#spaces+1] = Space:new(self.node1, {self.x[2] - rect.w, self.y[2]})           
        end 
    end
    
    if rect.h < self.h then
        if self.mcorner <= 2 then
            spaces[#spaces+1] = Space:new({self.x[1], self.y[1] + rect.h}, self.node2)
        else
            spaces[#spaces+1] = Space:new(self.node1, {self.x[2], self.y[2] - rect.h})
        end 
    end 
    return spaces
end 

function Space:setLayerPosition(rect)
    local c = self.mcorner
    rect:setPosition{c%4 < 2 and self.corners[c][1] or self.corners[c][1] - rect.w, c > 2 and self.corners[c][2] - rect.h or self.corners[c][2]}
end 


function Space:isTooSmall()
    for _,rect in ipairs(rects) do
        if rect.num > 0 and self:isFeasible(rect) then
            return false
        end 
    end 
    return true
end 

function Space:insertEmpty()
    if not self:isTooSmall() then
        empty[#empty+1] = self
    end
end 

function Space:cutSpace(rect)
    local minx, miny = math.max(self.x[1], rect.x), math.max(self.y[1], rect.y) 
    local maxx, maxy = math.min(self.x[2], rect.x + rect.w), math.min(self.y[2], rect.y + rect.h)
    local spaces = {}
    if minx < maxx and miny < maxy then
        local overlap = {w = maxx - minx, h = maxy - miny}
       
        if overlap.w < self.w then 
            if minx == self.x[1] then
                spaces[#spaces+1] = Space:new({self.x[1] + overlap.w, self.y[1]}, self.node2) 
            elseif maxx == self.x[2] then
                spaces[#spaces+1] = Space:new(self.node1, {self.x[2] - overlap.w, self.y[2]})  
            else
                spaces[#spaces+1] = Space:new(self.node1, {minx, self.y[2]})
                spaces[#spaces+1] = Space:new({maxx, self.y[1]}, self.node2)
            end 
        end 
        
        if overlap.h < self.h then
            if miny == self.y[1] then
                spaces[#spaces+1] = Space:new({self.x[1], self.y[1] + overlap.h}, self.node2)
            elseif maxy == self.y[2] then 
                spaces[#spaces+1] = Space:new(self.node1, {self.x[2], self.y[2] - overlap.h})
            else
                spaces[#spaces+1] = Space:new(self.node1, {self.x[2], miny})
                spaces[#spaces+1] = Space:new({self.x[1],maxy}, self.node2)
            end 
        end 
    end
    for s=#spaces,1,-1 do if spaces[s]:isTooSmall() then table.remove(spaces, s) end end 
    return spaces
end 

function Space:isFeasible(rect)
    return (self.w >= rect.w and self.h >= rect.h) or (self.w >= rect.h and self.h >= rect.w)
end 

function Space:draw()
    local r = Add3DRect(m3d, self.w, self.h)
    SetPosition(r, self.x[1] + self.w / 2, 0, self.y[1] + self.h / 2)
end 