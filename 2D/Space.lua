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
        self.dis, self.min_corner = {0,0}, 1, 1
    else
        self.dis, self.min_corner = self:minSpaceDistance()
    end 
    return self
end 

function Space:minSpaceDistance()
    local min, min_corner = {math.huge,math.huge}
    for c,corner in ipairs(self.corners) do
        for cc,c_corner in ipairs(container.corners) do
            local dis = distance(corner, c_corner)
            if dis[1] < min[1] or (dis[1] == min[1] and dis[2] < min[2]) then 
                min, min_corner = dis, c
            end 
        end 
    end 
    return min, min_corner
end 

function Space:isBeContained(space)
    return space.x[1] <= self.x[1] and space.y[1] <= self.y[1] and space.x[2] >= self.x[2] and space.y[2] >= self.y[2] 
end 


function Space:createMaxSpace(rect)
    local vertical, horizon 
    if rect.w < self.w then 
        if self.min_corner == 1 or self.min_corner == 4 then
            vertical = Space:new({self.x[1] + rect.w, self.y[1]}, self.node2) 
        else
            vertical = Space:new(self.node1, {self.x[2] - rect.w, self.y[2]})           
        end 
    end
    
    if rect.h < self.h then
        if self.min_corner <= 2 then
            horizon = Space:new({self.x[1], self.y[1] + rect.h}, self.node2)
        else
            horizon = Space:new(self.node1, {self.x[2], self.y[2] - rect.h})
        end 
    end 
    return vertical, horizon
end 

function Space:setLayerPosition(rect)
    local pos 
    if self.min_corner == 1 then 
        pos = self.corners[1]
    elseif self.min_corner == 2 then
        pos = {self.corners[2][1] - rect.w, self.corners[2][2]}
    elseif self.min_corner == 3 then
        pos = {self.corners[3][1] - rect.w, self.corners[3][2] - rect.h}
    else
        pos = {self.corners[4][1], self.corners[4][2] - rect.h}
    end 
    rect:setPosition(pos)
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
    local minx = math.max(self.x[1], rect.x) 
    local miny = math.max(self.y[1], rect.y) 
    local maxx = math.min(self.x[2], rect.x + rect.w) 
    local maxy = math.min(self.y[2], rect.y + rect.h)
    if minx >= maxx or miny >= maxy then
        return 
    else
        local overlap = {w = maxx - minx, h = maxy - miny}
        local vertical, horizon, vertical1, horizon1
        if overlap.w < self.w then 
            if minx == self.x[1] then
                vertical = Space:new({self.x[1] + overlap.w, self.y[1]}, self.node2) 
            elseif maxx == self.x[2] then
                vertical = Space:new(self.node1, {self.x[2] - overlap.w, self.y[2]})  
            else
                vertical  = Space:new(self.node1, {minx, self.y[2]})
                vertical1 = Space:new({maxx, self.y[1]}, self.node2)
            end 
        end 
        
        if overlap.h < self.h then
            if miny == self.y[1] then
                horizon = Space:new({self.x[1], self.y[1] + overlap.h}, self.node2)
            elseif maxy == self.y[2] then 
                horizon  = Space:new(self.node1, {self.x[2], self.y[2] - overlap.h})
            else
                horizon   = Space:new(self.node1, {self.x[2], miny})
                horizon1  = Space:new({self.x[1],maxy}, self.node2)
            end 
        end 
        return vertical, horizon, vertical1, horizon1
    end 
    
end 

function Space:isFeasible(rect)
    return (self.w >= rect.w and self.h >= rect.h) or (self.w >= rect.h and self.h >= rect.w)
end 

function Space:draw()
    local r = Add3DRect(m3d, self.w, self.h)
    SetPosition(r, self.x[1] + self.w / 2, 0, self.y[1] + self.h / 2)
end 