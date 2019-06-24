Layer = {}
Layer.__index = Layer

function Layer:new(w, h, d, num, sw, sh, sd, tp)
    local self = {w = w, h = h, d = d, num = num, tp = tp, volume = w * h * d}
    setmetatable(self, Layer)
    self.sw,self.sh,self.sd = sw or w, sh or h, sd or d
    return self
end 

function Layer:getFitness(space) 
    self.fit = {space.w - self.w, space.h - self.h, space.d - self.d}
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
    for i=1,self.h/self.sh-1 do
        local rect = Add3DRect(m3d, self.w+1, self.d+1, 0,0,0)
        SetPosition(rect, self.x+self.w/2, self.y + self.sh * i, self.z + self.d/2)
    end 
    for i=1,self.d/self.sd-1 do
        local rect = Add3DRect(m3d, self.w+1, self.h+1, 0, 0, 0)
        SetRotation(rect, -90,0,0)
        SetPosition(rect, self.x + self.w/2, self.y + self.h/2, self.z + self.sd * i )
    end
end 

function Layer:setPosition(pos)
    self.x, self.y, self.z = unpack(pos)
end 

function Layer:pos()
    SetPosition(self.cube, self.x + self.w / 2, self.y + self.h / 2, self.z + self.d / 2)
end 

function Layer:draw()
    self.cube = Add3DBox(m3d, self.w, self.d, self.h, 255 * self.tp / #boxes, 255 * (1 - self.tp / #boxes), self.h)
end 