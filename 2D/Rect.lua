-- class: Rect
Rect = {w = 0, h = 0, num = 1, x = 0, y = 0, volume = 0, tp = 0}
Rect.__index = Rect

function Rect:new(w, h, num, small_w, small_h)
    local self = {}
    setmetatable(self, Rect)
    self.w, self.h, self.num = w, h, num
    self.volume = self.w * self.h
    self.small_w, self.small_h = small_w or w, small_h or h
    return self
end 

function Rect:getFitness(space)
    self.fit = {space.w - self.w, space.h - self.h}
    table.sort(self.fit)
end 

function Rect:createLayer(space)
    local function getLayer(w, h)
        if w <= space.w and h <= space.h then 
            local layer1,layer2
            local row, column
            -- XY 
            column = math.min(math.floor(space.w / w), self.num)
            row    = math.min(math.floor(space.h / h), math.floor(self.num / column))
            layer1 = Rect:new(w * column, h * row, row * column, w, h)
            -- YX
            row = math.min(math.floor(space.h / h), self.num) 
            column = math.min(math.floor(space.w / w), math.floor(self.num / row))
            
            if layer1.num > row * column then return layer1 end
        
            layer2 = Rect:new(w * column, h * row, row * column, w, h)
            if layer2.num > layer1.num then
                return layer2
            else
                layer1:getFitness(space)
                layer2:getFitness(space)
                if layer1.fit[1] < layer2.fit[1] or (layer1.fit[1] == layer2.fit[1] and layer1.fit[2] < layer2.fit[2]) then
                    return layer1
                else
                    return layer2
                end 
            end
        end 
    end 
    local layers = {}
    layers[#layers+1] = getLayer(self.w, self.h)
    if self.w ~= self.h then layers[#layers+1] = getLayer(self.h, self.w) end
    if #layers > 1 then 
        if not layers[1].fit then layers[1]:getFitness(space) end 
        if not layers[2].fit then layers[2]:getFitness(space) end
        table.sort(layers, function(a,b) return a.num>=b.num and a.fit[1]<=b.fit[1] and a.fit[2]<b.fit[2] end) 
    end 
    return layers[1]
end 

function Rect:setPosition(pos)
    self.x, self.y = pos[1], pos[2]
end 

function Rect:pos()
    SetPosition(self.box, self.x + self.w / 2, 3, self.y + self.h / 2)
end 

function Rect:cutBox()
    for i=1,self.w/self.small_w-1 do
        local line = Add3DLine(m3d, self.h)
        SetRotation(line, 0,-90,0)
        SetPosition(line, self.x + self.small_w * i, 7, self.y)
    end 
    for i=1,self.h/self.small_h-1 do
        local line = Add3DLine(m3d, self.w)
        SetPosition(line, self.x, 7, self.y + self.small_h * i)
    end 
end 

function Rect:draw()
    self.box = Add3DBox(m3d, self.w, self.h,6, self.w, self.h, math.random(180))
end 