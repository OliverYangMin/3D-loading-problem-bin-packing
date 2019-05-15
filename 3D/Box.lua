Box = {w = 0, h = 0, d = 0, num = 1, x = 0, y = 0, z = 0, volume = 0, tp = 0}
Box.__index = Box
function Box:new(w, h, d, num, sw, sh, sd)
    local self = {w = w, h = h, d = d, num = num, volume = w * h * d}
    setmetatable(self, Box)
    self.sw,self.sh,self.sd = sw or w, sh or h, sd or d
    return self
end 

function Box:getFitness(space) -- 可能有问题  需求针对同一空间
    self.fit = {space.w - self.w, space.h - self.h, space.d - self.d}
    table.sort(self.fit)
end 

function Box:getLayersFromDiffDirection(space) -- 3 * 2 * 1 = 6  -- ToDO   add direction change limitation
    local whd, layers = {self.w, self.h, self.d}, {}
    if whd[1] == whd[2] and whd[2] == whd[3] then 
        layers[#layers+1] = space:getLayer(whd[1], whd[2], whd[3],self.num)
    elseif whd[1] ~= whd[2] and whd[2] ~= whd[3] and whd[1] ~= whd[3] then
        for i=1,#whd do
            for j=1,#whd do
                if i ~= j then 
                    layers[#layers+1] = space:getLayer(whd[i], whd[j], whd[6-i-j], self.num)
                end 
            end 
        end 
    else
        local a, b = getUniqueDouble(self.w, self.h, self.d)
        layers[#layers+1] = space:getLayer(a,b,b,self.num); layers[#layers+1] = space:getLayer(b,a,b,self.num); layers[#layers+1] = space:getLayer(b,b,a,self.num)
    end 
    return layers
end 

function Box:cutOverlapSpace()
    for i=#empty,1,-1 do                                                 
        local spaces = empty[i]:cutSpace(self)
        if spaces then 
            table.remove(empty, i)  
            if #spaces > 0 then
                for s=#spaces,1,-1 do
                    if spaces[s] then
                        for j=i-1,1,-1 do
                            if spaces[s]:isBeContainedBySpace(empty[j]) then 
                                goto continue 
                            end 
                        end 
                        empty[#empty+1] = spaces[s]--spaces[s]:insertEmpty()
                    end 
                    ::continue::
                end 
            end
        end
    end 
end

function Box:cutBox()
    for i=1,self.h/self.sh-1 do
        local rect = Add3DRect(m3d, self.w+1, self.d+1, 0,0,0)
        SetPosition(rect, self.x+self.w/2, self.y + self.sh * i, self.z+self.d/2)
    end 
    for i=1,self.d/self.sd-1 do
        local rect = Add3DRect(m3d, self.w+1, self.h+1, 0, 0, 0)
        SetRotation(rect, -90,0,0)
        SetPosition(rect, self.x + self.w/2, self.y + self.h/2, self.z + self.sd * i )
    end
end 

function Box:setPosition(pos)
    self.x, self.y, self.z = unpack(pos)
end 

function Box:pos()
    SetPosition(self.box, self.x + self.w / 2, self.y + self.h / 2, self.z + self.d / 2)
end 

function Box:draw()
    self.box = Add3DBox(m3d, self.w, self.d, self.h, self.w, self.d, self.h)
    -- self.box = Add3DBox(m3d, self.w, self.d, self.h, boxes[self.tp].w, boxes[self.tp].d, boxes[self.tp].h)
end 