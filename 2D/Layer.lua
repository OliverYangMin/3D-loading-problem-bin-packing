Layer = {}
Layer.__index = Layer

function Layer:new(w, h, num, sw, sh, tp)
    local self = {w = w, h = h, num = num, tp = tp, volume = w * h}
    setmetatable(self, Layer)
    self.sw,self.sh = sw or w, sh or h
    return self
end 

function Layer:getFitness(space) 
    self.fit = {space.w - self.w, space.h - self.h}
    table.sort(self.fit)
end 

function Layer:updateRemainingSpaces(cSpaces)
    for i=#cSpaces,1,-1 do       
        if cSpaces[i]:isTooSmall() then
            table.remove(cSpaces, i)
        else
            local spaces = cSpaces[i]:cutSpace(self)
            if spaces then 
                table.remove(cSpaces, i)  
                for s=#spaces,1,-1 do
                    if not spaces[s]:isBeContainedByEmpty() then
                        cSpaces[#cSpaces+1] = spaces[s]
                    end 
                end 
            end
        end
    end 
end

function Layer:cutBox()
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

function Layer:setPosition(pos)
    self.x, self.y = unpack(pos)
end 

function Layer:pos()
    SetPosition(self.box, self.x + self.w / 2, 3, self.y + self.h / 2)
end 

function Layer:draw()
    self.box = Add3DBox(m3d, self.w, self.h, 6, self.w, self.h, math.random(180))
end 