function lexicoCompare(a, b) 
    if a.dis[1] < b.dis[1] then
        return true
    elseif a.dis[1] == b.dis[1] then
        if a.dis[2] < b.dis[2] then
            return true
        elseif a.dis[2] == b.dis[2] then
            return a.volume > b.volume
        end 
    end 
    return false
end


function init()
    local data = {{73,44,98,10}, {60,38,60,10}, {73,60,105,7},    {77,52,90,8},    {58,24,66,9},    {76,55,106,6},    {44,36,55,8},    {58,23,82,8}}
    W, H = 400, 400
    total_volume = 0
    m3d = Create3DWorld('3D-container-loading',true, 0.5,50)
    SetCamera(m3d, 0,300,-100, 0,100,0)
    AddSphere(m3d, 3)

    container = Space:new({0,0},{W, H})
    container:draw()

    empty = {container} 
    rects = {} 
    for i=1,#data do rects[#rects+1] = Rect:new(data[i][1], data[i][2], data[i][4]) end
    packed = {} 
end 

function createLayerForSpace(space)
    local layer, layer_type = {volume = 0} 
    for i, rect in ipairs(rects) do 
        if rect.num > 0 then 
            local lay = rect:createLayer(space)
            if lay and (lay.volume > layer.volume or (lay.volume == layer.volume and lay.fit[1] <= layer.fit[1] and lay.fit[2] < layer.fit[2])) then
                layer, layer_type = lay, i
            end 
        end 
    end 
    return layer, layer_type
end 
function isTooSmall(space)
    for _,rect in ipairs(rects) do
        if rect.num > 0 and space:isFeasible(rect) then
            return false
        end 
    end 
    return true
end 





function outputResult()
    for i=1,#rects do
        if rects[i].num > 0 then print('rect type ', i, ' remaining ', rects[i].num) end 
    end 
    print(string.format('Total volume is %d, %d be filled, and full rate = %f', container.volume, total_volume, total_volume / container.volume))
end 































--function reactiveGRASP()
--    local beta = {}, n = {}
--    for i=1,9 do beta[i] = i * 0.1  n[i] = 0 end 
--    local Vbest, Vworst = 0, math.huge
--    local num_iter = 0
--    local sum_value = 0
--    while num_iter < max_iter do
        
--        num_iter = num_iter + 1
--        V = Constructive()
--        if V >= Vworst + 0.5 * (Vbest - Vworst)
--        Vstar = Improvement()
--        if Vstar > Vbest then
--            Vbest = Vstar
--        end 
--        if Vstar < Vworst then
--            Vworst = Vstar
--        end 
--        sum_value = sum_value + Vstar
--        if num_iter % 500 == 0 then
--            ((mean-Vworst)/(Vbest - Vworst)) ^ alpha
            
--        end 
--    end 
--end 