-- Projects generic 3D target geometry and produces the three AR display modes.
-- Library dependencies:
-- - SARN helpers from library.onStart.helpers.lua.
-- - SARNLinkedElements from library.onStart.linkedElements.lua.
SARNArDrawing = SARNArDrawing or {}

local function normalizedVector(value)
    local x, y, z = SARN.components(value)
    if x == nil then return nil end
    local length = math.sqrt(x * x + y * y + z * z)
    if length < 0.000001 then return nil end
    return { x = x / length, y = y / length, z = z / length }
end

local function projectOntoPlane(value, normal)
    local vx, vy, vz = SARN.components(value)
    local nx, ny, nz = SARN.components(normal)
    if vx == nil or nx == nil then return nil end
    local alongNormal = vx * nx + vy * ny + vz * nz
    return normalizedVector({
        x = vx - nx * alongNormal,
        y = vy - ny * alongNormal,
        z = vz - nz * alongNormal
    })
end

local function crossProduct(first, second)
    local ax, ay, az = SARN.components(first)
    local bx, by, bz = SARN.components(second)
    if ax == nil or bx == nil then return nil end
    return normalizedVector({ x = ay * bz - az * by, y = az * bx - ax * bz, z = ax * by - ay * bx })
end

function SARNArDrawing.getFallbackWorldAxes()
    local core = SARNLinkedElements and SARNLinkedElements.core or nil
    local up = core ~= nil and normalizedVector(SARN.call(core, "getWorldVertical")) or nil
    if up == nil then up = normalizedVector(SARN.call(system, "getCameraWorldUp")) end
    local forward = up ~= nil and projectOntoPlane(SARN.call(construct, "getWorldOrientationForward"), up) or nil
    if forward == nil and up ~= nil then forward = projectOntoPlane(SARN.call(system, "getCameraWorldForward"), up) end
    if up == nil or forward == nil then
        return {
            right = SARN.call(system, "getCameraWorldRight"),
            forward = SARN.call(system, "getCameraWorldForward"),
            up = SARN.call(system, "getCameraWorldUp")
        }
    end
    local right = crossProduct(forward, up)
    return { right = right, forward = forward, up = up }
end

function SARNArDrawing.buildTwoDimensionalTargetHtml(bounds, centerPoint, label, distance)
    local left, right, top, bottom = bounds.left, bounds.right, bounds.top, bounds.bottom
    local x, y = centerPoint.x, centerPoint.y
    local arm = math.max(2, math.min(24, math.min(right - left, bottom - top) * 0.28))
    local color = SARNConfiguration.markerColor
    local distanceLabel = tostring(label or "Target") .. " " .. SARN.formatDistance(distance)
    local line = 'position:absolute;background:rgb(' .. color .. ');box-shadow:0 0 4px #001820;pointer-events:none;'
    local corner = function(horizontalX, horizontalY, horizontalWidth, verticalX, verticalY, verticalHeight)
        return '<div style="' .. line .. 'left:' .. string.format("%.1f", horizontalX) .. 'px;top:' .. string.format("%.1f", horizontalY) .. 'px;width:' .. string.format("%.1f", horizontalWidth) .. 'px;height:3px"></div>'
            .. '<div style="' .. line .. 'left:' .. string.format("%.1f", verticalX) .. 'px;top:' .. string.format("%.1f", verticalY) .. 'px;width:3px;height:' .. string.format("%.1f", verticalHeight) .. 'px"></div>'
    end
    return corner(left, top, arm, left, top, arm) .. corner(right - arm, top, arm, right - 3, top, arm)
        .. corner(left, bottom - 3, arm, left, bottom - arm, arm) .. corner(right - arm, bottom - 3, arm, right - 3, bottom - arm, arm)
        .. '<div style="position:absolute;left:' .. string.format("%.1f", x - 3) .. 'px;top:' .. string.format("%.1f", y - 3) .. 'px;width:6px;height:6px;border-radius:50%;background:rgb(' .. color .. ');box-shadow:0 0 4px #001820"></div>'
        .. '<div style="position:absolute;left:' .. string.format("%.1f", x) .. 'px;top:' .. string.format("%.1f", top - 22) .. 'px;transform:translateX(-50%);color:rgb(' .. color .. ');font:bold 14px Arial,sans-serif;text-shadow:0 0 4px #001820;white-space:nowrap">' .. SARN.escapeHtml(distanceLabel) .. '</div>'
end

function SARNArDrawing.buildFarDistanceDotHtml(centerPoint, label, distance)
    local color = SARNConfiguration.markerColor
    return '<div style="position:absolute;left:'
        .. string.format("%.1f", centerPoint.x - 6)
        .. 'px;top:' .. string.format("%.1f", centerPoint.y - 6)
        .. 'px;width:12px;height:12px;box-sizing:border-box;border-radius:50%;border:2px solid rgb('
        .. color .. ');background:rgba(' .. color .. ',0.28);box-shadow:0 0 6px #001820;pointer-events:none"></div>'
        .. '<div style="position:absolute;left:' .. string.format("%.1f", centerPoint.x)
        .. 'px;top:' .. string.format("%.1f", centerPoint.y - 26)
        .. 'px;transform:translateX(-50%);color:rgb(' .. color
        .. ');font:bold 14px Arial,sans-serif;text-shadow:0 0 4px #001820;white-space:nowrap">'
        .. SARN.escapeHtml(tostring(label or "Target")) .. ' ' .. SARN.formatDistance(distance) .. '</div>'
end

function SARNArDrawing.buildLimitedVisibilityDotHtml(anchorPoint, label, distance)
    local color = SARNConfiguration.markerColor
    return '<div style="position:absolute;left:'
        .. string.format("%.1f", anchorPoint.x - 4)
        .. 'px;top:' .. string.format("%.1f", anchorPoint.y - 4)
        .. 'px;width:8px;height:8px;box-sizing:border-box;border-radius:50%;background:rgb('
        .. color .. ');border:1px solid #e8fbff;box-shadow:0 0 6px #001820;pointer-events:none"></div>'
        .. '<div style="position:absolute;left:' .. string.format("%.1f", anchorPoint.x + 9)
        .. 'px;top:' .. string.format("%.1f", anchorPoint.y - 18)
        .. 'px;color:rgb(' .. color
        .. ');font:bold 13px Arial,sans-serif;text-shadow:0 0 4px #001820;white-space:nowrap">'
        .. SARN.escapeHtml(tostring(label or "Target")) .. ' ' .. SARN.formatDistance(distance) .. '</div>'
end

function SARNArDrawing.projectWorldPoint(point, allowOutsideScreen)
    local x, y, z = SARN.components(point)
    local projected = x ~= nil and SARN.call(library, "getPointOnScreen", { x, y, z }) or nil
    local sx, sy, sz = SARN.components(projected)
    if sx == nil or sy == nil or sz == 0 then return nil end
    if not allowOutsideScreen and (sx < 0 or sx > 1 or sy < 0 or sy > 1) then return nil end
    return { x = sx, y = sy }
end

function SARNArDrawing.offset(point, worldAxes, rightOffset, forwardOffset, upOffset)
    local px, py, pz = SARN.components(point)
    if px == nil then return nil end
    local rx, ry, rz = SARN.components(worldAxes and worldAxes.right)
    local fx, fy, fz = SARN.components(worldAxes and worldAxes.forward)
    local ux, uy, uz = SARN.components(worldAxes and worldAxes.up)
    if rx == nil or fx == nil or ux == nil then
        rx, ry, rz = 1, 0, 0
        fx, fy, fz = 0, 1, 0
        ux, uy, uz = 0, 0, 1
    end
    return {
        x = px + rx * rightOffset + fx * forwardOffset + ux * upOffset,
        y = py + ry * rightOffset + fy * forwardOffset + uy * upOffset,
        z = pz + rz * rightOffset + fz * forwardOffset + uz * upOffset
    }
end

function SARNArDrawing.getTargetHalfExtents(size)
    local x, y, z = SARN.components(size)
    if x ~= nil then
        return math.abs(x) / 2, math.abs(y) / 2, math.abs(z) / 2
    end

    local key = string.lower(tostring(size or "")):gsub("[^a-z]", "")
    local halfExtents = {
        xs = 4,
        extrasmall = 4,
        s = 8,
        small = 8,
        m = 16,
        medium = 16,
        l = 32,
        large = 32,
        xl = 64,
        extralarge = 64
    }
    local halfExtent = halfExtents[key] or 4
    return halfExtent, halfExtent, halfExtent
end

function SARNArDrawing.getProjectedBoxCorners(worldPosition, size, worldAxes)
    local halfRight, halfForward, halfUp = SARNArDrawing.getTargetHalfExtents(size)
    local corners = {}
    local hasVisibleCorner = false
    for up = -1, 1, 2 do
        for forward = -1, 1, 2 do
            for right = -1, 1, 2 do
                -- Every vertex starts from this target's world-space centre.
                local projected = SARNArDrawing.projectWorldPoint(SARNArDrawing.offset(
                    worldPosition, worldAxes,
                    right * halfRight, forward * halfForward, up * halfUp
                ), true)
                corners[#corners + 1] = projected
                if projected ~= nil then hasVisibleCorner = true end
            end
        end
    end
    return hasVisibleCorner and corners or nil
end

function SARNArDrawing.getProjectedBounds(corners)
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local left, right, top, bottom = math.huge, -math.huge, math.huge, -math.huge
    for _, corner in ipairs(corners) do
        if corner ~= nil then
            left, right = math.min(left, corner.x * width), math.max(right, corner.x * width)
            top, bottom = math.min(top, corner.y * height), math.max(bottom, corner.y * height)
        end
    end
    return { left = left, right = right, top = top, bottom = bottom }
end

function SARNArDrawing.countScreenVisibleCorners(corners)
    local count = 0
    for _, corner in ipairs(corners or {}) do
        if corner ~= nil and corner.x >= 0 and corner.x <= 1
            and corner.y >= 0 and corner.y <= 1 then
            count = count + 1
        end
    end
    return count
end

function SARNArDrawing.getVisibleCornerAnchor(corners)
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local totalX, totalY, count = 0, 0, 0
    for _, corner in ipairs(corners or {}) do
        if corner ~= nil and corner.x >= 0 and corner.x <= 1
            and corner.y >= 0 and corner.y <= 1 then
            totalX, totalY, count = totalX + corner.x, totalY + corner.y, count + 1
        end
    end
    if count == 0 then return nil end
    return { x = totalX / count * width, y = totalY / count * height }
end

function SARNArDrawing.isCameraInsideTarget(camera, worldPosition, size, worldAxes)
    local cx, cy, cz = SARN.components(camera)
    local tx, ty, tz = SARN.components(worldPosition)
    local rx, ry, rz = SARN.components(worldAxes and worldAxes.right)
    local fx, fy, fz = SARN.components(worldAxes and worldAxes.forward)
    local ux, uy, uz = SARN.components(worldAxes and worldAxes.up)
    if cx == nil or tx == nil then return false end
    if rx == nil or fx == nil or ux == nil then
        rx, ry, rz = 1, 0, 0
        fx, fy, fz = 0, 1, 0
        ux, uy, uz = 0, 0, 1
    end
    local halfRight, halfForward, halfUp = SARNArDrawing.getTargetHalfExtents(size)
    local dx, dy, dz = cx - tx, cy - ty, cz - tz
    local rightDistance = dx * rx + dy * ry + dz * rz
    local forwardDistance = dx * fx + dy * fy + dz * fz
    local upDistance = dx * ux + dy * uy + dz * uz
    return math.abs(rightDistance) <= halfRight
        and math.abs(forwardDistance) <= halfForward
        and math.abs(upDistance) <= halfUp
end

function SARNArDrawing.getRenderMetrics(corners, camera, worldPosition, size, worldAxes)
    local metrics = {
        visibleCorners = SARNArDrawing.countScreenVisibleCorners(corners),
        cameraInside = SARNArDrawing.isCameraInsideTarget(
            camera, worldPosition, size, worldAxes
        )
    }
    if corners ~= nil then
        local bounds = SARNArDrawing.getProjectedBounds(corners)
        local width = tonumber(system.getScreenWidth()) or 1920
        local height = tonumber(system.getScreenHeight()) or 1080
        metrics.bounds = bounds
        metrics.screenSpan = math.max(bounds.right - bounds.left, bounds.bottom - bounds.top)
            / math.min(width, height)
    end
    return metrics
end

function SARNArDrawing.buildCornerDotsHtml(corners)
    if corners == nil then return "" end
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local color = SARNConfiguration.markerColor
    local html = ""
    for _, corner in ipairs(corners) do
        if corner ~= nil then
            html = html .. '<div style="position:absolute;left:'
                .. string.format("%.1f", corner.x * width - 3)
                .. 'px;top:' .. string.format("%.1f", corner.y * height - 3)
                .. 'px;width:6px;height:6px;border-radius:50%;background:rgb('
                .. color .. ');box-shadow:0 0 5px #001820;pointer-events:none"></div>'
        end
    end
    return html
end

function SARNArDrawing.buildLineHtml(first, second, color)
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local x1, y1 = first.x * width, first.y * height
    local x2, y2 = second.x * width, second.y * height
    local dx, dy = x2 - x1, y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 1 then return "" end
    local angle
    if type(math.atan2) == "function" then
        angle = math.atan2(dy, dx)
    elseif dx > 0 then
        angle = math.atan(dy / dx)
    elseif dx < 0 then
        angle = math.atan(dy / dx) + (dy >= 0 and math.pi or -math.pi)
    else
        angle = dy >= 0 and math.pi / 2 or -math.pi / 2
    end
    return '<div style="position:absolute;left:' .. string.format("%.1f", x1)
        .. 'px;top:' .. string.format("%.1f", y1 - 1) .. 'px;width:'
        .. string.format("%.1f", length) .. 'px;height:2px;background:rgb(' .. color
        .. ');box-shadow:0 0 4px #001820;transform-origin:left center;transform:rotate('
        .. string.format("%.3f", math.deg(angle)) .. 'deg);pointer-events:none"></div>'
end

function SARNArDrawing.buildThreeDimensionalTargetHtml(worldPosition, size, worldAxes, label, distance)
    local corners = SARNArDrawing.getProjectedBoxCorners(worldPosition, size, worldAxes)
    if corners == nil then return nil end
    local edges = {
        {1, 2}, {1, 3}, {2, 4}, {3, 4}, {5, 6}, {5, 7},
        {6, 8}, {7, 8}, {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }
    local cornerFraction = 0.24
    local html = ""
    for _, edge in ipairs(edges) do
        local first, second = corners[edge[1]], corners[edge[2]]
        if first ~= nil and second ~= nil then
            local fromFirst = {
                x = first.x + (second.x - first.x) * cornerFraction,
                y = first.y + (second.y - first.y) * cornerFraction
            }
            local fromSecond = {
                x = second.x + (first.x - second.x) * cornerFraction,
                y = second.y + (first.y - second.y) * cornerFraction
            }
            -- The same open-corner geometry used for the original PB target:
            -- only short segments depart from each projected box vertex.
            html = html .. SARNArDrawing.buildLineHtml(
                first, fromFirst,
                SARNConfiguration.markerColor
            ) .. SARNArDrawing.buildLineHtml(
                second, fromSecond,
                SARNConfiguration.markerColor
            )
        end
    end
    local centerPoint = SARNArDrawing.projectWorldPoint(worldPosition)
    if centerPoint ~= nil then
        local screenWidth = tonumber(system.getScreenWidth()) or 1920
        local screenHeight = tonumber(system.getScreenHeight()) or 1080
        local centerX, centerY = centerPoint.x * screenWidth, centerPoint.y * screenHeight
        html = html .. '<div style="position:absolute;left:'
            .. string.format("%.1f", centerX - 3)
            .. 'px;top:' .. string.format("%.1f", centerY - 3)
            .. 'px;width:6px;height:6px;border-radius:50%;background:rgb('
            .. SARNConfiguration.markerColor .. ')"></div>'
            .. '<div style="position:absolute;left:' .. string.format("%.1f", centerX)
            .. 'px;top:' .. string.format("%.1f", centerY - 26)
            .. 'px;transform:translateX(-50%);color:rgb(' .. SARNConfiguration.markerColor
            .. ');font:bold 14px Arial,sans-serif;text-shadow:0 0 4px #001820;white-space:nowrap">'
            .. SARN.escapeHtml(tostring(label or "Target")) .. ' ' .. SARN.formatDistance(distance) .. '</div>'
    end
    return html
end

function SARNArDrawing.drawTarget(target)
    local camera = SARN.call(system, "getCameraWorldPos")
    local worldPosition = type(target) == "table" and target.worldPosition or nil
    local label = type(target) == "table" and target.label or "Target"
    local size = type(target) == "table" and target.size or nil
    local worldAxes = type(target) == "table" and target.worldAxes or nil
    if worldAxes == nil then worldAxes = SARNArDrawing.getFallbackWorldAxes() end
    if worldPosition == nil or camera == nil then return "", nil, {} end

    local distance = SARN.distance(camera, worldPosition)
    if distance == nil then
        return "", nil, {}
    end

    local projected = SARNArDrawing.projectWorldPoint(worldPosition)
    local corners = SARNArDrawing.getProjectedBoxCorners(worldPosition, size, worldAxes)
    local metrics = SARNArDrawing.getRenderMetrics(
        corners, camera, worldPosition, size, worldAxes
    )
    local cornerDots = SARNArDrawing.buildCornerDotsHtml(corners)
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local centerPoint = projected ~= nil and {
        x = projected.x * width,
        y = projected.y * height
    } or nil
    if metrics.visibleCorners <= 4 then
        metrics.mode = "dot (limited visibility)"
        local anchorPoint = centerPoint or SARNArDrawing.getVisibleCornerAnchor(corners)
        if anchorPoint == nil then
            metrics.suppressed = "no visible corner anchor"
            return "", distance, metrics
        end
        return SARNArDrawing.buildLimitedVisibilityDotHtml(
            anchorPoint, label, distance
        ), distance, metrics
    end
    if metrics.cameraInside then
        metrics.mode = "dot (inside)"
        if projected == nil then return "", distance, metrics end
        return SARNArDrawing.buildLimitedVisibilityDotHtml({
            x = projected.x * width,
            y = projected.y * height
        }, label, distance), distance, metrics
    end
    if (metrics.screenSpan or 0) > 0.10 then
        local wireframe = SARNArDrawing.buildThreeDimensionalTargetHtml(worldPosition, size, worldAxes, label, distance)
        if wireframe ~= nil then
            metrics.mode = "3D"
            return wireframe .. cornerDots, distance, metrics
        end
    end
    if projected == nil then
        metrics.mode = "hidden"
        metrics.suppressed = "target centre is outside the current view"
        return "", distance, metrics
    end
    centerPoint = { x = projected.x * width, y = projected.y * height }
    if (metrics.screenSpan or 0) < 0.02 then
        metrics.mode = "dot"
        return cornerDots .. SARNArDrawing.buildFarDistanceDotHtml(centerPoint, label, distance), distance, metrics
    end
    if corners == nil then return "", distance, metrics end
    metrics.mode = "2D"
    return cornerDots .. SARNArDrawing.buildTwoDimensionalTargetHtml(
        metrics.bounds, centerPoint, label, distance
    ), distance, metrics
end
