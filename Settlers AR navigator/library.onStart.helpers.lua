-- Provides shared safe-call, vector, HTML escaping, and distance-formatting helpers.
-- Library dependencies:
-- - SARNConfiguration from library.onStart.configuration.lua.
SARN = SARN or {}

function SARN.applicationCaption()
    return string.char(83, 69, 84, 84, 76, 69, 82, 83, 32, 65, 82, 32,
        78, 65, 86, 73, 71, 65, 84, 79, 82)
end

function SARN.startupCaption()
    return SARN.applicationCaption() .. string.char(32, 118, 48, 46, 49, 46, 48)
end

function SARN.call(element, methodName, ...)
    if element == nil or type(element[methodName]) ~= "function" then return nil end
    local ok, value = pcall(element[methodName], ...)
    return ok and value or nil
end

function SARN.components(value)
    if type(value) == "table" then
        return tonumber(value.x or value[1]), tonumber(value.y or value[2]), tonumber(value.z or value[3])
    elseif type(value) == "string" then
        local x, y, z = value:match("::pos%{0,%s*0,%s*([+-]?%d*%.?%d+),%s*([+-]?%d*%.?%d+),%s*([+-]?%d*%.?%d+)%}")
        if x and y and z then return tonumber(x), tonumber(y), tonumber(z) end
    end
    return nil, nil, nil
end

function SARN.distance(from, to)
    local fx, fy, fz = SARN.components(from)
    local tx, ty, tz = SARN.components(to)
    if fx == nil or tx == nil then return nil end
    local dx, dy, dz = tx - fx, ty - fy, tz - fz
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function SARN.escapeHtml(value)
    local escaped = tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    return escaped
end

function SARN.formatWholeWithSeparators(value)
    local whole = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    local groups = {}
    repeat
        table.insert(groups, 1, tostring(whole % 1000))
        whole = math.floor(whole / 1000)
    until whole == 0
    for index = 2, #groups do
        groups[index] = string.format("%03d", tonumber(groups[index]))
    end
    return table.concat(groups, "'")
end

function SARN.formatDistance(distanceMeters)
    local meters = math.max(0, tonumber(distanceMeters) or 0)
    if meters < 100 then
        local rounded = math.floor(meters * 10 + 0.5) / 10
        if rounded < 100 then return string.format("%.1f m", rounded) end
    end
    if meters < 1000 then
        local rounded = math.floor(meters + 0.5)
        if rounded < 1000 then return tostring(rounded) .. " m" end
    end

    local kilometers = meters / 1000
    if kilometers < 10 then
        local rounded = math.floor(kilometers * 100 + 0.5) / 100
        if rounded < 10 then return string.format("%.2f km", rounded) end
    end
    if kilometers < 100 then
        local rounded = math.floor(kilometers * 10 + 0.5) / 10
        if rounded < 100 then return string.format("%.1f km", rounded) end
    end
    if kilometers < 200 then
        local rounded = math.floor(kilometers + 0.5)
        if rounded < 200 then return tostring(rounded) .. " km" end
    end

    local su = meters / 200000
    if su < 10 then
        local rounded = math.floor(su * 100 + 0.5) / 100
        if rounded < 10 then return string.format("%.2f su", rounded) end
    end
    if su < 100 then
        local rounded = math.floor(su * 10 + 0.5) / 10
        if rounded < 100 then return string.format("%.1f su", rounded) end
    end
    return SARN.formatWholeWithSeparators(su) .. " su"
end
