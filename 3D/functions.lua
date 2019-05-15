function FileToTable(file)
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
            problem[#problem+1] = {a[line][4], a[line][6], a[line][2], a[line][8]}
        end 
        problems[#problems+1] = problem
    end 
end 

function init(number)
--    local data = {{73,44,98,13}, {60,38,60,12}, {73,60,105,9},    {77,52,90,21},    {58,24,66,12},    {76,55,106,20},    {44,36,55,11},    {58,23,82,14}}
--    W, H, D = 233, 220, 587
    readBischooff(number)
    

    --container:draw()
--    empty, boxes, packed = {container}, {}, {}
--    for i=1,#problems[p] do boxes[#boxes+1] = Box:new(data[i][1], data[i][2], data[i][3], data[i][4]) end
    
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

function getUniqueDouble(a, b, c)
    if a == b then
        return c, a
    elseif b == c then
        return a, b
    elseif a == c then
        return b, a
    end 
end 

function distance(node1, node2)
    local dis = {math.abs(node1[1] - node2[1]), math.abs(node1[2] - node2[2]), math.abs(node1[3] - node2[3])}
    table.sort(dis)
    return dis
end


function outputResult(v, start_time)
    for i=1,#boxes do if boxes[i].num > 0 then print('box type ', i, ' remaining ', boxes[i].num) end end 
    print(string.format('Total volume is %d, %d be filled, and full rate = %f', container.volume, v, v / container.volume))
    print('The CPU time is ', os.time() - start_time)
    if v / container.volume <0.5 then 
        print('ddddddddddddddddddddddddddddd') 
        return true
    end
    
end 