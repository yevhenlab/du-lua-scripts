-- Provides shared coordinate conversion, diagnostics, safe-call, HTML, and distance helpers.
-- Library dependencies: SARNConfiguration from library.onStart.configuration.lua and DU atlas.lua.
SARN = SARN or {}
SARN.warnings = SARN.warnings or {}
SARN.errors = SARN.errors or {}
SARN._reportedDiagnostics = SARN._reportedDiagnostics or {}

function SARN.applicationCaption()
    return string.char(83, 69, 84, 84, 76, 69, 82, 83, 32, 65, 82, 32,
        78, 65, 86, 73, 71, 65, 84, 79, 82)
end

function SARN.startupCaption()
    return SARN.applicationCaption() .. string.char(32, 118, 48, 46, 52, 46, 49)
end

function SARN.reportWarning(code, message)
    local key = tostring(code) .. ":" .. tostring(message)
    if SARN._reportedDiagnostics[key] then return end
    SARN._reportedDiagnostics[key] = true
    SARN.warnings[#SARN.warnings + 1] = { code = code, message = message }
    if system and type(system.print) == "function" then system.print("[SARN] Warning: " .. message) end
end

function SARN.call(element, methodName, ...)
    if element == nil or type(element[methodName]) ~= "function" then return nil end
    local ok, value = pcall(element[methodName], ...)
    return ok and value or nil
end

local numberPattern = "([+-]?%d*%.?%d+[eE]?[+-]?%d*)"

function SARN.parsePosition(value)
    if type(value) ~= "string" then return nil end
    local systemId, bodyId, x, y, z = value:match("^%s*::pos%s*{%s*" .. numberPattern
        .. "%s*,%s*" .. numberPattern .. "%s*,%s*" .. numberPattern
        .. "%s*,%s*" .. numberPattern .. "%s*,%s*" .. numberPattern .. "%s*}%s*$")
    if systemId == nil then return nil end
    return tonumber(systemId), tonumber(bodyId), tonumber(x), tonumber(y), tonumber(z)
end

function SARN.getAtlas()
    if SARN._atlasAttempted then return SARN._atlas end
    SARN._atlasAttempted = true
    local ok, atlasOrError = pcall(require, "atlas")
    if ok and type(atlasOrError) == "table" then
        SARN._atlas = atlasOrError
    else
        SARN.reportWarning("atlas-unavailable", "Could not load DU atlas.lua: " .. tostring(atlasOrError))
    end
    return SARN._atlas
end

function SARN.planetToWorld(systemId, bodyId, latitude, longitude, altitude)
    local atlas = SARN.getAtlas()
    local bodies = atlas and (atlas[systemId] or atlas[tostring(systemId)])
    local body = bodies and (bodies[bodyId] or bodies[tostring(bodyId)])
    local center = body and body.center
    local radius = body and tonumber(body.radius)
    local cx = center and tonumber(center.x or center[1])
    local cy = center and tonumber(center.y or center[2])
    local cz = center and tonumber(center.z or center[3])
    if cx == nil or cy == nil or cz == nil or radius == nil then
        SARN.reportWarning("atlas-body-unknown", "No atlas body for ::pos{" .. tostring(systemId)
            .. "," .. tostring(bodyId) .. ",...}; location skipped.")
        return nil, nil, nil
    end
    local lat = math.rad(latitude)
    local lon = math.rad(longitude)
    local radialDistance = radius + altitude
    return cx + radialDistance * math.cos(lat) * math.cos(lon),
        cy + radialDistance * math.cos(lat) * math.sin(lon),
        cz + radialDistance * math.sin(lat)
end

function SARN.components(value)
    if type(value) == "table" then
        return tonumber(value.x or value[1]), tonumber(value.y or value[2]), tonumber(value.z or value[3])
    elseif type(value) == "string" then
        local systemId, bodyId, x, y, z = SARN.parsePosition(value)
        if systemId == nil then
            SARN.reportWarning("coordinate-invalid", "Invalid coordinate '" .. value .. "'; location skipped.")
            return nil, nil, nil
        end
        if systemId == 0 and bodyId == 0 then return x, y, z end
        return SARN.planetToWorld(systemId, bodyId, x, y, z)
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
    for index = 2, #groups do groups[index] = string.format("%03d", tonumber(groups[index])) end
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
