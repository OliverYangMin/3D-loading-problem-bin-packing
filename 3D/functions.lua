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

    m3d = Create3DWorld('3D-container-loading', true, 1, 30)
    SetCamera(m3d, W * 2, H * 1.5, -D / 2, 0, 0, D)
    AddSphere(m3d, 3, 16,255,0,0)  
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
    for i=1,#boxes do if boxes[i].num > 0 then print('box type ', i, ' remaining ', boxes[i].num) end end 
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





















