function constructive(memory, delta)
    local used_volume, ready = memory.used_volume or 0
    empty = memory.empty or {container}
    if not memory.boxes then
        boxes = {}
        for i=1,#problems[1] do 
            boxes[#boxes+1] = Box:new(unpack(problems[1][i])) 
        end
    end

    repeat
        table.sort(empty, compareSpace)             
        local layer = empty[1]:chooseLayer(delta)    
        if not layer then break end
        empty[1]:setLayerPosition(layer)      
        boxes[layer.tp]:reduce(layer.num)
        used_volume = used_volume + layer.volume
        local spaces = empty[1]:createMaxSpace(layer) 
        table.remove(empty, 1) 
        layer:updateRemainingSpaces(empty)   
        for s=1,#spaces do 
            if not spaces[s]:isBeContainedByEmpty() then 
                if not spaces[s]:isTooSmall() then
                    empty[#empty+1] = spaces[s] 
                end 
            end
        end --- 检验是否被其他空间，或者太小了包围
        if not memory.boxes and not ready and used_volume / container.volume > 0.5 then
            ready = true
            memory.boxes = DeepCopy(boxes)
            memory.empty = DeepCopy(empty)
            memory.used_volume = used_volume
        end
    until isNoLeft() or #empty == 0 
    print(used_volume/container.volume)
    return used_volume/container.volume, memory
end 
function constructiveGreedy(Pnum)
    local used_volume = 0
    init(Pnum) 
    layers = {}
    repeat
        table.sort(empty, compareSpace)   -- 将空间排序，选择第一个空间
    
        local layer = empty[1]:chooseLayer() -- 在空间中生成最优layer，需要保证这个空间能放进至少一个layer
        if not layer then break end
        layers[#layers+1] = layer
        empty[1]:setLayerPosition(layer)                        
        --layer:draw(); layer:pos(); layer:cutBox(); Update(m3d); Sleep(100)
        
        boxes[layer.tp]:reduce(layer.num)
        used_volume = used_volume + layer.volume
        
        local spaces = empty[1]:createMaxSpace(layer) -- 插入layer后，empty space被切割，生成2-1-0个子空间
        
        table.remove(empty, 1) 
        
        layer:updateRemainingSpaces(empty)   -- 其他的empty space可能与放置的layer有冲突，需要去重
        
        for s=1,#spaces do 
            if not spaces[s]:isBeContainedByEmpty() then 
                if not spaces[s]:isTooSmall() then
                    empty[#empty+1] = spaces[s] 
                end 
            end
        end --- 检验是否被其他空间，或者太小了包围
        
    until isNoLeft() or #empty == 0 
    outputResult(used_volume)
    return used_volume/container.volume
end 
local function chooseDelta()
    local r = math.random()
    local p = deltas[1].p
    for i=1,9 do
        if r <= p then
            return i
        end
        p = p + deltas[i+1].p
    end 
end

local function updateDeltas(iter, Vbest, Vworst)
    if iter % 250 == 0 then
        local sum_eval = 0
        for i=1,9 do
            deltas[i].eval = ((deltas[i].sum/iter - Vworst) / (Vbest - Vworst)) ^ 10
            sum_eval = sum_eval + deltas[i].eval
        end 
        for i=1,9 do
            deltas[i].p = deltas[i].eval / sum_eval 
        end
    end 
end 

function reactiveGRASP()
    deltas = {}; for i=1,9 do deltas[i] = {0.1 * i; count = 0, sum = 0, p = 1 / 9, eval = 0} end  
    
    local Vbest, Vworst, best_solution = 0, math.huge, {}
    
    for iter=1,max_iter do
        SetProgress(iter, max_iter)
        
        local n = chooseDelta()
        
        deltas[n].count = deltas[n].count + 1

        local V, memory, Vstar = constructive({}, deltas[n])
        
        if V >= Vworst + 0.5 * (Vbest - Vworst) and memory.empty then
            local v = constructive(memory) 
            Vstar = v > V and v or V
        else
            Vstar = V
        end
        
        if Vstar > Vbest  then 
            Vbest  = Vstar 
            best_Solution = DeepCopy(packed)
        end 
        
        Vworst = Vstar < Vworst and Vstar or Vworst

        deltas[n].sum = deltas[n].sum + Vstar
        
        updateDeltas(iter, Vbest, Vworst)
      
    end 
    
    print(Vbest, ' ',Vworst)
    for i=1,#deltas do print(string.format('%.5f',deltas[i].p)) end 
end 
function table.extend(tab1, tab2)
    if type(tab2) == 'table' then
        for i=1,#tab2 do
            tab1[#tab1+1] = tab2[i]
        end
    end
end 

function DeepCopy(object)      
    local SearchTable = {}  
    local function Func(object)  
        if type(object) ~= "table" then  
            return object         
        end  
        local NewTable = {}  
        SearchTable[object] = NewTable  
        for k, v in pairs(object) do  
            NewTable[Func(k)] = Func(v)  
        end     
        return setmetatable(NewTable, getmetatable(object))      
    end    
    return Func(object)  
end 

local function FileToTable(file)
    local inputx = io.input(file)
    local x = {}
    local i = 1
    for line in inputx:lines() do
        local j = 1
        x[i] = {}
        for num in string.gmatch(line,"[0-9.]+") do
            x[i][j]= tonumber(num)
            j = j + 1
        end
        i = i + 1
    end    
    return x
end

function readBischooff(number)
    local a = FileToTable('benchmarks/thpack'.. number .. '.txt')
    PSIZE = a[1][1]
    N = a[4][1]
    W, H, D = a[3][2], a[3][3], a[3][1]
    problems = {}
    for i=1,PSIZE do
        local problem = {}
        for j=1,N do
            local line = (i-1) * (3 + N) + 4 + j
            problem[#problem+1] = {a[line][1], a[line][4], a[line][6], a[line][2], a[line][8], a[line][5], a[line][7], a[line][3]}
        end 
        problems[#problems+1] = problem
    end 
end 

function readLiansu(number)
    local a = FileToTable('benchmarks/liansu.txt')
    PSIZE = a[1][1]
    N = a[4][1]
    W, H, D = a[3][2] * 100, a[3][3] * 100, a[3][1] * 100
    problems = {}
    for i=1,PSIZE do
        local problem = {}
        for j=1,N do
            local line = (i-1) * (3 + N) + 4 + j
            problem[#problem+1] = {a[line][1], a[line][4] * 100, a[line][6] * 100, a[line][2] * 100, a[line][8], a[line][5], a[line][7], a[line][3]}
        end 
        problems[#problems+1] = problem
    end 
end 


function init(p)
    empty, boxes, packed = {container}, {}, {}
    for i=1,#problems[p] do 
        boxes[#boxes+1] = Box:new(unpack(problems[p][i])) 
    end

--    m3d = Create3DWorld('3D-container-loading', true, 1, 30)
--    SetCamera(m3d, W * 2, H * 1.5, -D / 2, 0, 0, D)
--    AddSphere(m3d, 3, 16,255,0,0)  
end 

function isNoLeft()
    for i=1,#boxes do
        if boxes[i].num > 0 then
            return false
        end 
    end 
    return true
end

function compareTable(a, b, sign)
    for i=1,#a do
        if a[i] < b[i] then
            return true
        elseif a[i] > b[i] then
            return false
        end 
    end 
    return sign
end 

function compareSpace(a, b) 
    local result = compareTable(a.dis, b.dis, 1) 
    if result == 1 then
        return a.volume > b.volume
    end
    return result
end

function compareLayer(a, b)
    if a.volume > b.volume then
        return true
    elseif a.volume == b.volume then
        return compareTable(a.fit, b.fit)
    end 
    return false
end 

function compareLayer1(a, b)
    local result = compareTable(a.fit, b.fit, 1) 
    if result == 1 then
        return a.volume > b.volume
    end
    return result
end 

function distance(node1, node2)
    local dis = {math.abs(node1[1] - node2[1]), math.abs(node1[2] - node2[2]), math.abs(node1[3] - node2[3])}
    table.sort(dis)
    return dis
end

function outputResult(v) --, start_time)
    --for i=1,#boxes do if boxes[i].num > 0 then print('box type ', i, ' remaining ', boxes[i].num) end end 
    print(string.format('Total volume is %d, %d be filled, and full rate = %f', container.volume, v, v / container.volume))
end 

function drawResult()
    m3d = Create3DWorld('3D-container-loading', true, 1, 30)
    SetCamera(m3d, W * 2, H * 1.5, -D / 2, 0, 0, D)
    AddSphere(m3d, 3, 16,255,0,0)  
    
    for _,layer in ipairs(packed) do
        layer:draw()
        layer:pos()
        layer:cutBox()
        Update(m3d)
        Sleep(100)
    end 
end 