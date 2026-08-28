-- Install as an additional Library > onStart filter.
-- This module owns all persistent Databank access for the controller.

hscStorage = hscStorage or {}

function hscStorage.describeValue(value)
    if value == nil then return "empty" end

    local compact = string.gsub(tostring(value), "[\r\n\t]+", " ")
    local previewLength = 140

    if #compact > previewLength then
        compact = string.sub(compact, 1, previewLength) .. "..."
    end

    return tostring(#tostring(value)) .. " chars: " .. compact
end

function hscStorage.getUpdatedAt()
    local ok, value = pcall(function()
        return os.time()
    end)

    if ok and value ~= nil then
        return tostring(value)
    end

    return "unknown"
end

function hscStorage.parseHubRecord(value)
    local dirty, updatedAt, fingerprint = string.match(
        tostring(value or ""),
        "^HSC%-CELL%-2|([01])|([^|]*)|(.*)$"
    )

    if dirty == nil then
        return nil
    end

    return {
        dirty = dirty == "1",
        updatedAt = updatedAt,
        fingerprint = fingerprint
    }
end

function hscStorage.makeHubRecord(fingerprint, dirty, updatedAt)
    return table.concat({
        "HSC-CELL-2",
        dirty and "1" or "0",
        tostring(updatedAt or "unknown"),
        tostring(fingerprint or "")
    }, "|")
end

function hscStorage.getFingerprintCell(fingerprint)
    local _, column, row = string.match(
        tostring(fingerprint or ""),
        "^([^|]*)|([^|]*)|([^|]*)|"
    )

    return tonumber(column), tonumber(row)
end

function hscStorage.getString(databank, key)
    local method = hsc.getMethod(databank, "getStringValue")
    if method == nil then return nil end
    local ok, value = pcall(method, key)

    if ok and hscDebugDatabank then
        hsc.print("Databank read " .. tostring(key) .. " -> "
            .. hscStorage.describeValue(value))
    end

    return ok and value or nil
end

function hscStorage.saveLayout(databank, screenId, payload)
    if databank == nil then return false end
    local key = "hsc:v2:projection:" .. tostring(screenId)
    local method = hsc.getMethod(databank, "setStringValue")
    if method == nil then return false end
    if hscStorage.getString(databank, key) == payload then return true end
    local ok = pcall(method, key, payload)

    if ok and hscDebugDatabank then
        hsc.print("Databank write " .. key .. " <- "
            .. hscStorage.describeValue(payload))
    end

    return ok
end

function hscStorage.saveHubCells(databank, screenId, hubs)
    if databank == nil then return false end
    local lines = { "HSC-CELLS-1" }

    for _, hub in ipairs(hubs or {}) do
        local position = hub.position or {}
        lines[#lines + 1] = table.concat({
            tostring(hub.cellColumn or ""), tostring(hub.cellRow or ""),
            tostring(hub.id or ""), string.format("%.4f", tonumber(hub.x) or 0),
            string.format("%.4f", tonumber(hub.y) or 0),
            string.format("%.4f", tonumber(hub.depth) or 0),
            string.format("%.4f", tonumber(hub.screenX) or 0),
            string.format("%.4f", tonumber(hub.screenY) or 0),
            string.format("%.4f", tonumber(position[1]) or 0),
            string.format("%.4f", tonumber(position[2]) or 0),
            string.format("%.4f", tonumber(position[3]) or 0),
            hub.dirty and "1" or "0",
            tostring(hub.updatedAt or "")
        }, "|")

        if hscScreen ~= nil and hscScreen.buildCellPayload ~= nil then
            local renderKey = "hsc:v5:renderCell:" .. tostring(screenId)
                .. ":" .. tostring(hub.cellColumn) .. ":" .. tostring(hub.cellRow)
            local renderPayload = hscScreen.buildCellPayload(hub)

            if hscStorage.getString(databank, renderKey) ~= renderPayload then
                local renderMethod = hsc.getMethod(databank, "setStringValue")

                if renderMethod ~= nil then
                    local renderOk = pcall(renderMethod, renderKey, renderPayload)

                    if renderOk and hscDebugDatabank then
                        hsc.print("Databank write " .. renderKey .. " <- "
                            .. hscStorage.describeValue(renderPayload))
                    end
                end
            end
        end
    end

    local value = table.concat(lines, "\n")
    local key = "hsc:v3:cells:" .. tostring(screenId)

    if hscStorage.getString(databank, key) == value then return true end

    local method = hsc.getMethod(databank, "setStringValue")
    if method == nil then return false end
    local ok = pcall(method, key, value)

    if ok and hscDebugDatabank then
        hsc.print("Databank write " .. key .. " <- "
            .. hscStorage.describeValue(value))
    end

    return ok
end

function hscStorage.getRenderCell(databank, screenId, column, row)
    return hscStorage.getString(
        databank,
        "hsc:v5:renderCell:" .. tostring(screenId)
            .. ":" .. tostring(column) .. ":" .. tostring(row)
    )
end

function hscStorage.getHubFingerprint(hub)
    local parts = {
        tostring(hub.id or ""), tostring(hub.cellColumn or ""),
        tostring(hub.cellRow or ""), string.format("%.4f", tonumber(hub.screenX) or 0),
        string.format("%.4f", tonumber(hub.screenY) or 0),
        string.format("%.4f", tonumber(hub.x) or 0),
        string.format("%.4f", tonumber(hub.y) or 0),
        string.format("%.4f", tonumber(hub.depth) or 0),
        tostring((hub.inventory or {}).maxVolume or ""),
        tostring((hub.inventory or {}).totalVolume or "")
    }

    for _, product in ipairs(hub.products or {}) do
        parts[#parts + 1] = table.concat({
            tostring(product.itemId or ""), tostring(product.containerQuantity or ""),
            tostring(product.cycleQuantity or "")
        }, ":")
    end

    return table.concat(parts, "|")
end

function hscStorage.syncHubs(databank, screenId, hubs)
    local dirtyHubs = {}
    local setMethod = hsc.getMethod(databank, "setStringValue")
    if setMethod == nil then return dirtyHubs end

    for _, hub in ipairs(hubs or {}) do
        local key = "hsc:v4:cell:" .. tostring(screenId) .. ":" .. tostring(hub.id)
        local fingerprint = hscStorage.getHubFingerprint(hub)
        local stored = hscStorage.parseHubRecord(hscStorage.getString(databank, key))

        if stored == nil or stored.fingerprint ~= fingerprint then
            if stored ~= nil then
                local previousColumn, previousRow = hscStorage.getFingerprintCell(
                    stored.fingerprint
                )

                if previousColumn ~= nil and previousRow ~= nil
                    and (previousColumn ~= hub.cellColumn or previousRow ~= hub.cellRow) then
                    hub.previousCellColumn = previousColumn
                    hub.previousCellRow = previousRow
                end
            end

            hub.dirty = true
            hub.updatedAt = hscStorage.getUpdatedAt()
            hub.fingerprint = fingerprint
            local record = hscStorage.makeHubRecord(fingerprint, true, hub.updatedAt)
            local ok = pcall(setMethod, key, record)

            if ok then
                dirtyHubs[#dirtyHubs + 1] = hub

                if hscDebugDatabank then
                    hsc.print("Databank write " .. key .. " <- "
                        .. hscStorage.describeValue(record))
                end
            end
        else
            hub.dirty = stored.dirty
            hub.updatedAt = stored.updatedAt
            hub.fingerprint = stored.fingerprint

            if hub.dirty then
                dirtyHubs[#dirtyHubs + 1] = hub
            end
        end
    end

    return dirtyHubs
end

function hscStorage.clearDirtyHubs(databank, screenId, hubs)
    local setMethod = hsc.getMethod(databank, "setStringValue")
    if setMethod == nil then return false end

    for _, hub in ipairs(hubs or {}) do
        if hub.dirty then
            local key = "hsc:v4:cell:" .. tostring(screenId) .. ":" .. tostring(hub.id)
            local record = hscStorage.makeHubRecord(
                hub.fingerprint or hscStorage.getHubFingerprint(hub),
                false,
                hub.updatedAt
            )
            local ok = pcall(setMethod, key, record)

            if ok then
                hub.dirty = false

                if hscDebugDatabank then
                    hsc.print("Databank clear dirty " .. key .. " <- "
                        .. hscStorage.describeValue(record))
                end
            end
        end
    end

    return true
end
