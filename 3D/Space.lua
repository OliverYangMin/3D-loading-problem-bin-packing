Space = {x = 0, y = 0, z = 0, corners = {}, volume = 0, node1 = {}, node2 = {}} 
Space.__index = Space

function Space:new(node1, node2)
    local self = {node1 = node1, node2 = node2}  
    setmetatable(self, Space)
    self.x, self.y, self.z = {node1[1], node2[1]}, {node1[2], node2[2]}, {node1[3], node2[3]}
    self.w, self.h, self.d =  node2[1] - node1[1], node2[2] - node1[2], node2[3] - node1[3]
    self.corners = {node1, {node2[1], node1[2], node1[3]}, {node2[1], node2[2], node1[3]}, {node1[1], node2[2], node1[3]},
                    {node1[1], node1[2], node2[3]}, {node2[1], node1[2], node2[3]}, node2, {node1[1], node2[2], node2[3]}}
    self.volume = self.w * self.h * self.d
    if self.w == W and self.h == H and self.d == D then 
        self.dis, self.mcorner = {0, 0, 0}, 1
    else
        self.dis, self.mcorner = self:minSpaceDistance()
    end 
    return self
end 

function Space:minSpaceDistance()
    local min, mcorner = {math.huge, math.huge, math.huge}
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

function Space:getLayer(w, h, d, box)
    if w <= self.w and h <= self.h and d <= self.d then 
        local layers = {}
        for i=1,3 do
            for j=1,3 do
                if i ~= j then 
                    local xyz, whd = {1,1,1}, {self.w / w, self.h / h, self.d / d}
                    xyz[i] = math.min(math.floor(whd[i]), box.num)
                    xyz[j] = math.min(math.floor(box.num / xyz[i]), math.floor(whd[j]))
                    layers[#layers+1] = Layer:new(w * xyz[1], h * xyz[2], d * xyz[3], xyz[i] * xyz[j], w, h, d, box.tp)
                end 
            end 
        end 
        return self:getBestLayer(layers)
    end 
end 

function Space:getBestLayer(cLayers)
    for i=1,#cLayers do if not cLayers[i].fit then cLayers[i]:getFitness(self) end end 
    table.sort(cLayers, compareLayer)
    return cLayers[1]
end
    
function Space:chooseBestLayer()
    local best_layer = {volume = 0} 
    for i, box in ipairs(boxes) do 
        if box.num > 0 then 
            local layer = self:getBestLayer(box:getLayersFromDiffDirection(self))
            if layer and compareLayer(layer, best_layer) then
                best_layer = layer
            end 
        end 
    end 
    return best_layer
end 

function Space:setLayerPosition(layer)
    local c = self.mcorner
    layer:setPosition{c % 4 < 2 and self.corners[c][1] or self.corners[c][1] - layer.w, 
        (c % 4 > 0 and c % 4 < 3) and  self.corners[c][2] or self.corners[c][2] - layer.h, 
        c > 4 and self.corners[c][3] - layer.d or self.corners[c][3]} 
end 

function Space:createMaxSpace(layer)
    local spaces = {}
    if layer.w < self.w then 
        if self.mcorner % 4 < 2 then -- 1458
            local space = Space:new({self.x[1] + layer.w, self.y[1], self.z[1]}, self.node2) 
            if not space:isTooSmall() then spaces[#spaces+1] = space end
        else
            local space = Space:new(self.node1, {self.x[2] - layer.w, self.y[2], self.z[2]})           
            if not space:isTooSmall() then spaces[#spaces+1] = space end
        end 
    end
    
    if layer.h < self.h then
        if self.mcorner % 4 > 0 and self.mcorner % 4 < 3 then -- 1256
            local space = Space:new({self.x[1], self.y[1] + layer.h, self.z[1]}, self.node2)
            if not space:isTooSmall() then spaces[#spaces+1] = space end
        else
            local space = Space:new(self.node1, {self.x[2], self.y[2] - layer.h, self.z[2]})
            if not space:isTooSmall() then spaces[#spaces+1] = space end
        end 
    end 
    
    if layer.d < self.d then
        if self.mcorner < 5 then -- 1234
            local space = Space:new({self.x[1], self.y[1], self.z[1] + layer.d}, self.node2)
            if not space:isTooSmall() then spaces[#spaces+1] = space end 
        else
            local space = Space:new(self.node1, {self.x[2], self.y[2], self.z[2] - layer.d})
            if not space:isTooSmall() then spaces[#spaces+1] = space end
        end 
    end 
    
    return spaces
end 

function Space:cutSpace(layer)
    local minx,miny,minz = math.max(self.x[1], layer.x), math.max(self.y[1], layer.y), math.max(self.z[1], layer.z) 
    local maxx,maxy,maxz = math.min(self.x[2], layer.x + layer.w), math.min(self.y[2], layer.y + layer.h), math.min(self.z[2], layer.z + layer.d)
    if minx < maxx and miny < maxy and minz < maxz then
        local spaces = {}
        local overlap = {maxx - minx, maxy - miny, maxz - minz}
        if overlap[1] < self.w then 
            if minx == self.x[1] then
                spaces[#spaces+1] = Space:new({self.x[1] + overlap[1], self.y[1],self.z[1]}, self.node2) 
            elseif maxx == self.x[2] then
                spaces[#spaces+1] = Space:new(self.node1, {self.x[2] - overlap[1], self.y[2], self.z[2]})  
            else
                spaces[#spaces+1] = Space:new(self.node1, {minx, self.y[2], self.z[2]})
                spaces[#spaces+1] = Space:new({maxx, self.y[1], self.z[1]}, self.node2)
            end 
        end 
        
        if overlap[2] < self.h then
            if miny == self.y[1] then
                spaces[#spaces+1] = Space:new({self.x[1], self.y[1] + overlap[2], self.z[1]}, self.node2)
            elseif maxy == self.y[2] then 
                spaces[#spaces+1]  = Space:new(self.node1, {self.x[2], self.y[2] - overlap[2], self.z[2]})
            else
                spaces[#spaces+1]   = Space:new(self.node1, {self.x[2], miny, self.z[2]})
                spaces[#spaces+1]  = Space:new({self.x[1], maxy, self.z[1]}, self.node2)
            end 
        end 
        
        if overlap[3] < self.d then
            if minz == self.z[1] then
                spaces[#spaces+1] = Space:new({self.x[1], self.y[1], self.z[1] + overlap[3]}, self.node2)
            elseif maxz == self.z[2] then 
                spaces[#spaces+1] = Space:new(self.node1, {self.x[2], self.y[2], self.z[2] - overlap[3]})
            else
                spaces[#spaces+1] = Space:new(self.node1, {self.x[2], self.y[2], minz})
                spaces[#spaces+1] = Space:new({self.x[1], self.y[1], maxz}, self.node2)
            end 
        end
        for s=#spaces,1,-1 do if spaces[s]:isTooSmall() then table.remove(spaces, s) end end 
        return spaces
    end 
    return false
end 


function Space:isFeasible(box)
    if box.vw then
        if (self.w >= box.h and self.h >= box.w and self.d >= box.d) or (self.w >= box.d and self.h >= box.w and self.d >= box.h) then
            return true
        end 
    end 
    
    if box.vh then
        if (self.w >= box.w and self.h >= box.h and self.d >= box.d) or (self.w >= box.d and self.h >= box.w and self.d >= box.h) then
            return true
        end 
    end 
    
    if box.vd then
        if (self.w >= box.w and self.h >= box.d and self.d >= box.h) or (self.w >= box.h and self.h >= box.d and self.d >= box.w) then
            return true
        end 
    end 
    return false
end 

function Space:isTooSmall()
    for _,box in ipairs(boxes) do
        if box.num > 0 and self:isFeasible(box) then
            return false
        end 
    end 
    return true
end 

function Space:isOverlap(layer)
    local minx,miny,minz = math.max(self.x[1], layer.x), math.max(self.y[1], layer.y), math.max(self.z[1], layer.z) 
    local maxx,maxy,maxz = math.min(self.x[2], layer.x + layer.w), math.min(self.y[2], layer.y + layer.h), math.min(self.z[2], layer.z + layer.d)
    return minx < maxx and miny < maxy and minz < maxz 
end 

function Space:isBeContainedBySpace(space)
    return space.x[1] <= self.x[1] and space.y[1] <= self.y[1] and space.z[1] <= self.z[1] and space.x[2] >= self.x[2] and space.y[2] >= self.y[2] and space.z[2] >= self.z[2]
end 

function Space:isBeContainedByEmpty()
    for i=#empty, 1, -1 do
        if self:isBeContainedBySpace(empty[i]) then return true end 
    end 
    return false
end 

function Space:draw()
   local bottom = Add3DRect(m3d, self.w*2, self.d)
    SetPosition(bottom, self.x[1]  , 0, self.z[1] + self.d/2 )
    local bottom_line = Add3DLine(m3d, self.w)
    SetPosition(bottom_line, self.x[1], self.y[1]+0.1, self.z[2])
    local back   = Add3DRect(m3d, self.w, self.h,255,255,0)
    SetRotation(back, -90, 0, 0)
    SetPosition(back, self.x[1] + self.w / 2, self.y[1] + self.h / 2, self.z[2])
    local left   = Add3DRect(m3d, self.h, self.d, 0, 255, 255)
    SetRotation(left,0, 0, -90)
    SetPosition(left  , self.x[1] , self.y[1] + self.h / 2, self.z[1] + self.d / 2)
end 