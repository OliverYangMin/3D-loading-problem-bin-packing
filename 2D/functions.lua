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
end 

function init()
   
end 

function outputResult(v, start_time)
    for i=1,#boxes do if boxes[i].num > 0 then print('rect type ', i, ' remaining ', boxes[i].num) end end 
    print(string.format('Total volume is %d, %d be filled, and full rate = %f', container.volume, v, v / container.volume))
    print('The CPU time is ', os.time() - start_time)
end 