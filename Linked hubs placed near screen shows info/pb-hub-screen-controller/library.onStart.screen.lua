-- Install as an additional Library > onStart filter.
-- This module owns Screen projection, payloads, and Screen input/output.

hscScreen = hscScreen or {}

function hscScreen.getGridBounds(width, height)
    local left = math.max(0, hscGridMarginLeftMeters / width)
    local right = math.max(0, hscGridMarginRightMeters / width)
    local top = math.max(0, hscGridMarginTopMeters / height)
    local bottom = math.max(0, hscGridMarginBottomMeters / height)

    local maximumInset = 0.49
    left = math.min(left, maximumInset)
    right = math.min(right, maximumInset)
    top = math.min(top, maximumInset)
    bottom = math.min(bottom, maximumInset)

    return left, right, top, bottom
end

function hscScreen.projectHubsToScreen(hubs, width, height)
    width = tonumber(width)
    height = tonumber(height)

    if width == nil or width <= 0 then
        return nil, "The Screen width is missing."
    end

    if height == nil or height <= 0 then
        return nil, "The Screen height is missing."
    end
    local gridLeft, gridRight, gridTop, gridBottom = hscScreen.getGridBounds(width, height)
    local gridWidth = 1 - gridLeft - gridRight
    local gridHeight = 1 - gridTop - gridBottom
    local projected = {}

    for _, hub in ipairs(hubs) do
        local horizontal = hub.x / width
        local vertical = hub.y / height

        if hscReverseColumns then
            horizontal = -horizontal
        end

        if hscReverseRows then
            vertical = -vertical
        end

        local screenX = 0.5 + horizontal
        local screenY = 0.5 - vertical

        local gridX = (screenX - gridLeft) / gridWidth
        local gridY = (screenY - gridTop) / gridHeight

        local outsideX = math.max(math.abs(hub.x) - width / 2, 0)
        local outsideY = math.max(math.abs(hub.y) - height / 2, 0)

        local products = {}
        local productsByItemId = {}

        for _, product in ipairs(hub.containerProducts or {}) do
            product.source = "container"
            product.primaryAmount = tonumber(product.containerQuantity) or 0
            productsByItemId[product.itemId] = product
            products[#products + 1] = product
        end

        for _, industry in ipairs(hub.industryIds or {}) do
            local product = industry.product

            if product ~= nil and product.itemId ~= nil then
                local existing = productsByItemId[product.itemId]

                if existing ~= nil then
                    existing.industryAmount = tonumber(product.cycleQuantity)
                    existing.hasIndustrySource = true
                else
                    product.source = "industry"
                    product.primaryAmount = tonumber(product.cycleQuantity) or 0
                    productsByItemId[product.itemId] = product
                    products[#products + 1] = product
                end
            end
        end

        table.sort(products, function(left, right)
            return (tonumber(left.primaryAmount) or 0)
                > (tonumber(right.primaryAmount) or 0)
        end)

        local column = math.max(1, math.min(
            hscColumns,
            math.floor(math.max(0, math.min(0.999999, gridX)) * hscColumns) + 1
        ))
        local row = math.max(1, math.min(
            hscRows,
            math.floor(math.max(0, math.min(0.999999, gridY)) * hscRows) + 1
        ))

        projected[#projected + 1] = {
            id = hub.id,
            name = hub.label,
            hubName = hub.name,
            industryIds = hub.industryIds,
            iconPath = hub.iconPath,
            screenX = screenX,
            screenY = screenY,
            gridX = gridX,
            gridY = gridY,
            x = hub.x,
            y = hub.y,
            depth = hub.depth,
            position = hub.position,
            cellColumn = column,
            cellRow = row,
            products = products,
            inventory = hub.inventory,
            inside = screenX >= 0 and screenX <= 1
                and screenY >= 0 and screenY <= 1,
            surfaceDistance = math.sqrt(
                hub.depth * hub.depth
                + outsideX * outsideX
                + outsideY * outsideY
            )
        }
    end

    local hubByCell = {}

    for _, hub in ipairs(projected) do
        local cellKey = tostring(hub.cellColumn) .. ":" .. tostring(hub.cellRow)
        local existingHub = hubByCell[cellKey]

        if existingHub == nil
            or math.abs(tonumber(hub.depth) or math.huge)
                < math.abs(tonumber(existingHub.depth) or math.huge)
            or (
                math.abs(tonumber(hub.depth) or math.huge)
                    == math.abs(tonumber(existingHub.depth) or math.huge)
                and tostring(hub.id) < tostring(existingHub.id)
            ) then
            hubByCell[cellKey] = hub
        end
    end

    local selected = {}

    for _, hub in pairs(hubByCell) do
        selected[#selected + 1] = hub
    end

    table.sort(selected, function(left, right)
        if left.cellRow ~= right.cellRow then
            return left.cellRow < right.cellRow
        end

        return left.cellColumn < right.cellColumn
    end)

    return selected, width, height
end

function hscScreen.buildProjectionPayload(projected, clickMarkers, width, height)
    width = math.max(0.001, tonumber(width) or 1)
    height = math.max(0.001, tonumber(height) or 1)
    local gridLeft, gridRight, gridTop, gridBottom = hscScreen.getGridBounds(width, height)
    local header = table.concat({
        "HSP14",
        tostring(hscProjectionFontSize),
        tostring(hscClickPollFrames),
        tostring(hscRows),
        tostring(hscColumns),
        hscReserveTopTextArea and "1" or "0",
        hscReserveBottomTextArea and "1" or "0",
        tostring(hscReservedTextAreaFraction),
        string.format("%.6f", gridLeft),
        string.format("%.6f", gridRight),
        string.format("%.6f", gridTop),
        string.format("%.6f", gridBottom),
        hscDebugScreen and "1" or "0",
        hscDebugElements and "1" or "0",
        hsc.sanitizeLabel(hscScreenTitle) .. "  v"
            .. hsc.sanitizeLabel(hscScreenVersion)
    }, "|")
    local lines = { header }
    local payloadLength = #header
    local compactAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

    local function appendIfFits(line, reserve)
        local addedLength = 1 + #line

        if payloadLength + addedLength
            > hscScreenInputMaxCharacters - (reserve or 0) then
            return false
        end

        lines[#lines + 1] = line
        payloadLength = payloadLength + addedLength
        return true
    end

    local function encodeCompactCoordinate(value)
        value = math.floor(math.max(0, math.min(1, value)) * 4095 + 0.5)
        return string.sub(compactAlphabet, math.floor(value / 64) + 1,
            math.floor(value / 64) + 1)
            .. string.sub(compactAlphabet, value % 64 + 1, value % 64 + 1)
    end

    local fullLines = {}

    for hubIndex, hub in ipairs(projected or {}) do
        local primaryProduct = hub.products ~= nil and hub.products[1] or nil
        local secondaryParts = {}

        for productIndex = 2, #(hub.products or {}) do
            local product = hub.products[productIndex]

            if product.containerQuantity ~= nil then
                secondaryParts[#secondaryParts + 1] = hsc.sanitizeLabel(product.name)
                    .. " x" .. tostring(hsc.formatQuantity(product.containerQuantity) or "?")
            end
        end

        fullLines[hubIndex] = table.concat({
            "H",
            string.format("%.4f", hub.screenX),
            string.format("%.4f", hub.screenY),
            hub.inside and "1" or "0",
            hsc.sanitizeLabel(primaryProduct ~= nil and primaryProduct.iconPath or ""),
            hsc.sanitizeLabel(primaryProduct ~= nil and primaryProduct.category or "no industry"),
            hsc.sanitizeLabel(primaryProduct ~= nil and primaryProduct.name or hub.name),
            hsc.sanitizeLabel(primaryProduct ~= nil and primaryProduct.size or ""),
            hsc.sanitizeLabel(primaryProduct ~= nil and (
                (primaryProduct.tier ~= nil and "Tier " .. tostring(primaryProduct.tier) .. ", " or "")
                .. (primaryProduct.unitMass ~= nil and "Mass "
                    .. hsc.formatMeasurement(primaryProduct.unitMass, "kg") .. ", " or "")
                .. (primaryProduct.unitVolume ~= nil and "Volume "
                    .. hsc.formatMeasurement(primaryProduct.unitVolume, "L") or "")
            ) or "no product"),
            tostring(primaryProduct ~= nil and primaryProduct.containerQuantity ~= nil
                and hsc.formatQuantity(primaryProduct.containerQuantity) or ""),
            "C",
            table.concat(secondaryParts, "~")
        }, "|")
    end

    -- Every detected hub receives either a full record or a four-character
    -- compact point record. This prevents a hub from disappearing merely
    -- because another hub has a long name, icon path, or product list.
    local compactReserve = 3 + #fullLines * 4
    local omitted = {}

    for hubIndex, fullLine in ipairs(fullLines) do
        if payloadLength + 1 + #fullLine
            <= hscScreenInputMaxCharacters - compactReserve then
            appendIfFits(fullLine, compactReserve)
        else
            omitted[#omitted + 1] = projected[hubIndex]
        end
    end

    if #omitted > 0 then
        local compactParts = {}

        for _, hub in ipairs(omitted) do
            compactParts[#compactParts + 1] = encodeCompactCoordinate(hub.screenX)
                .. encodeCompactCoordinate(hub.screenY)
        end

        appendIfFits("D|" .. table.concat(compactParts), 0)
    end

    local markerLines = {}

    for markerIndex = #(clickMarkers or {}), 1, -1 do
        local marker = clickMarkers[markerIndex]
        local markerLine = table.concat({
            "C",
            string.format("%.4f", marker.x),
            string.format("%.4f", marker.y),
            tostring(marker.index)
        }, "|")

        if payloadLength + 1 + #markerLine > hscScreenInputMaxCharacters then
            break
        end

        table.insert(markerLines, 1, markerLine)
        payloadLength = payloadLength + 1 + #markerLine
    end

    for _, markerLine in ipairs(markerLines) do
        lines[#lines + 1] = markerLine
    end

    return table.concat(lines, "\n")
end

function hscScreen.buildConfigurationPayload(width, height)
    width = math.max(0.001, tonumber(width) or 1)
    height = math.max(0.001, tonumber(height) or 1)
    local gridLeft, gridRight, gridTop, gridBottom = hscScreen.getGridBounds(width, height)

    return table.concat({
        "HSCFG1",
        tostring(hscProjectionFontSize),
        tostring(hscClickPollFrames),
        tostring(hscRows),
        tostring(hscColumns),
        hscReserveTopTextArea and "1" or "0",
        hscReserveBottomTextArea and "1" or "0",
        tostring(hscReservedTextAreaFraction),
        string.format("%.6f", gridLeft),
        string.format("%.6f", gridRight),
        string.format("%.6f", gridTop),
        string.format("%.6f", gridBottom),
        hscDebugScreen and "1" or "0",
        hscDebugElements and "1" or "0",
        hsc.sanitizeLabel(hscScreenTitle) .. "  v"
            .. hsc.sanitizeLabel(hscScreenVersion)
    }, "|")
end

function hscScreen.getProductAmount(product)
    return tonumber(product ~= nil and product.containerQuantity)
        or tonumber(product ~= nil and product.containerAmount)
        or tonumber(product ~= nil and product.cycleQuantity)
        or 1
end

function hscScreen.getProductDetails(product)
    if product == nil then return "no product" end

    local amount = hscScreen.getProductAmount(product)
    local parts = {}

    if product.tier ~= nil then
        parts[#parts + 1] = "Tier " .. tostring(product.tier)
    end

    if product.unitMass ~= nil then
        parts[#parts + 1] = "Mass " .. hsc.formatMeasurement(
            product.unitMass * amount, "kg"
        )
    end

    if product.unitVolume ~= nil then
        parts[#parts + 1] = "Volume " .. hsc.formatMeasurement(
            product.unitVolume * amount, "L"
        )
    end

    return #parts > 0 and table.concat(parts, ", ") or "x1"
end

function hscScreen.encodeCellField(value)
    return (tostring(value or ""):gsub("([^%w %._,/%-:%(%)])", function(character)
        return string.format("%%%02X", string.byte(character))
    end))
end

function hscScreen.buildCellPayload(hub)
    local primary = (hub.products or {})[1]
    local primaryAmount = primary ~= nil
        and (hsc.formatQuantity(hscScreen.getProductAmount(primary)) or "1")
        or ""
    local category = primary ~= nil and hsc.sanitizeLabel(primary.category) or "no product"
    local source = primary ~= nil and tostring(primary.source or "industry") or ""
    local tier = primary ~= nil and tostring(primary.tier or "") or ""
    local amountValue = primary ~= nil and hscScreen.getProductAmount(primary) or nil
    local primaryVolume = primary ~= nil and primary.unitVolume ~= nil
        and amountValue ~= nil
        and hsc.formatMeasurement(primary.unitVolume * amountValue, "L")
        or ""
    local primaryMass = primary ~= nil and primary.unitMass ~= nil
        and amountValue ~= nil
        and hsc.formatMeasurement(primary.unitMass * amountValue, "kg")
        or ""

    local secondary = {}

    for productIndex = 2, #(hub.products or {}) do
        local product = hub.products[productIndex]
        local label = hsc.sanitizeLabel(product.name)
            .. " x" .. tostring(hsc.formatQuantity(
                tonumber(product.containerQuantity)
                    or tonumber(product.cycleQuantity)
                    or 1
            ) or 1)

        secondary[#secondary + 1] = label
    end

    local inventory = hub.inventory or {}
    local containerLabel = ""
    local containerFill = ""

    if inventory.totalVolume ~= nil and inventory.maxVolume ~= nil
        and tonumber(inventory.maxVolume) ~= nil and tonumber(inventory.maxVolume) > 0 then
        local percent = math.max(0, math.min(100,
            (tonumber(inventory.totalVolume) or 0) / tonumber(inventory.maxVolume) * 100
        ))
        local roundedPercent = math.floor(percent + 0.5)
        containerLabel = string.format(
            "%s%% container: %s / %s",
            tostring(roundedPercent),
            hsc.formatMeasurement(inventory.totalVolume, "L") or "0 L",
            hsc.formatMeasurement(inventory.maxVolume, "L") or "0 L"
        )
        containerFill = string.format("%.4f", percent / 100)
    end

    local function makePayload(secondaryProducts)
        return table.concat({
            "HSCELL5",
            tostring(hub.cellColumn),
            tostring(hub.cellRow),
            string.format("%.4f", tonumber(hub.screenX) or 0),
            string.format("%.4f", tonumber(hub.screenY) or 0),
            hub.inside and "1" or "0",
            hscScreen.encodeCellField(primary ~= nil and primary.iconPath or ""),
            hscScreen.encodeCellField(tier),
            hscScreen.encodeCellField(category),
            hscScreen.encodeCellField(source),
            hscScreen.encodeCellField(primary ~= nil and primary.name or "no product"),
            hscScreen.encodeCellField(primary ~= nil and primary.size or ""),
            primaryAmount,
            hscScreen.encodeCellField(primaryVolume),
            hscScreen.encodeCellField(primaryMass),
            hscScreen.encodeCellField(table.concat(secondaryProducts, "\n")),
            hscScreen.encodeCellField(containerLabel),
            containerFill
        }, "|")
    end

    local payload = makePayload(secondary)

    while #payload > hscScreenInputMaxCharacters and #secondary > 0 do
        table.remove(secondary)
        payload = makePayload(secondary)
    end

    return payload
end

function hscScreen.sendConfiguration()
    if hsc.runtime == nil or hsc.runtime.screen == nil then return false end

    local payload = hscScreen.buildConfigurationPayload(
        hsc.runtime.screenWidth,
        hsc.runtime.screenHeight
    )
    hsc.runtime.screen.setScriptInput(payload)
    hscStorage.saveLayout(hsc.runtime.databank, hsc.runtime.screenId, payload)
    return true
end

function hscScreen.queueDirtyCells(hubs)
    if hsc.runtime == nil then return end

    local queue = hsc.runtime.dirtyCellQueue
    local queued = hsc.runtime.queuedCells

    for _, hub in ipairs(hubs or {}) do
        if hub.previousCellColumn ~= nil and hub.previousCellRow ~= nil then
            local previousKey = tostring(hub.previousCellColumn)
                .. ":" .. tostring(hub.previousCellRow)

            if queued[previousKey] == nil then
                queue[#queue + 1] = {
                    clear = true,
                    cellColumn = hub.previousCellColumn,
                    cellRow = hub.previousCellRow
                }
            end

            queued[previousKey] = {
                clear = true,
                cellColumn = hub.previousCellColumn,
                cellRow = hub.previousCellRow
            }
        end

        local key = tostring(hub.cellColumn) .. ":" .. tostring(hub.cellRow)

        if queued[key] == nil then
            queue[#queue + 1] = hub
        end

        queued[key] = hub
    end
end

function hscScreen.sendNextDirtyCell()
    if hsc.runtime == nil or hsc.runtime.screen == nil then return false end

    local queuedHub = table.remove(hsc.runtime.dirtyCellQueue, 1)
    if queuedHub == nil then return false end

    local key = tostring(queuedHub.cellColumn) .. ":" .. tostring(queuedHub.cellRow)
    local hub = hsc.runtime.queuedCells[key] or queuedHub
    hsc.runtime.queuedCells[key] = nil

    if hub.clear then
        hsc.runtime.screen.setScriptInput("HSCLEAR1|" .. tostring(hub.cellColumn)
            .. "|" .. tostring(hub.cellRow))
    else
        local payload = hscStorage.getRenderCell(
            hsc.runtime.databank,
            hsc.runtime.screenId,
            hub.cellColumn,
            hub.cellRow
        ) or hscScreen.buildCellPayload(hub)
        hsc.runtime.screen.setScriptInput(payload)
        hscStorage.clearDirtyHubs(hsc.runtime.databank, hsc.runtime.screenId, { hub })
    end
    hscStorage.saveHubCells(
        hsc.runtime.databank,
        hsc.runtime.screenId,
        hsc.runtime.hubs
    )
    return true
end

function hscScreen.addClickMarker(x, y)
    if not hscDebugScreen then
        return
    end

    if hsc.runtime == nil then
        hsc.print("Click ignored: runtime is not initialized.")
        return
    end

    x = tonumber(x)
    y = tonumber(y)

    if x == nil or y == nil then
        hsc.print("Click ignored: invalid coordinates.")
        return
    end

    hsc.runtime.nextClickIndex = hsc.runtime.nextClickIndex + 1
    local markers = hsc.runtime.clickMarkers

    markers[#markers + 1] = {
        index = hsc.runtime.nextClickIndex,
        x = math.max(0, math.min(1, x)),
        y = math.max(0, math.min(1, y)),
        r = 0.30 + math.random() * 0.70,
        g = 0.30 + math.random() * 0.70,
        b = 0.30 + math.random() * 0.70
    }

    while #markers > hscMaxClickMarkers do
        table.remove(markers, 1)
    end

    hsc.print(string.format("Click %.4f, %.4f", x, y))
end

function hscScreen.pollClickOutput()
    if hsc.runtime == nil or hsc.runtime.screen == nil then
        return
    end

    local output = hsc.call(hsc.runtime.screen, "getScriptOutput")

    if type(output) ~= "string" or output == ""
        or output == hsc.runtime.lastClickOutput then
        return
    end

    local x, y, clickTime = string.match(
        output,
        "^HSC_CLICK|([^|]+)|([^|]+)|([^|]+)$"
    )

    x = tonumber(x)
    y = tonumber(y)
    clickTime = tonumber(clickTime)

    if x == nil or y == nil or clickTime == nil then
        return
    end

    hsc.runtime.lastClickOutput = output
    hsc.call(hsc.runtime.screen, "clearScriptOutput")

    local isDuplicate = hsc.runtime.lastClickX ~= nil
        and math.abs(x - hsc.runtime.lastClickX) < 0.002
        and math.abs(y - hsc.runtime.lastClickY) < 0.002
        and clickTime - hsc.runtime.lastClickTime <= hscClickDebounceSeconds

    if isDuplicate then
        return
    end

    hsc.runtime.lastClickX = x
    hsc.runtime.lastClickY = y
    hsc.runtime.lastClickTime = clickTime
    if hscDebugScreen then
        hsc.print(string.format(
            "Mouse click received from Screen: x=%.4f, y=%.4f",
            x,
            y
        ))
        hscScreen.addClickMarker(x, y)
    end
end

-- The renderer source remains embedded in the controller only because the PB
-- automatically installs it on the Screen. All controller calls use this
-- Screen-module entry point.
function hscScreen.getRenderScript()
    return [==[
local backgroundLayer = createLayer()
local gridBorderLayer = createLayer()
local gridCellLayer = createLayer()
local titleTextLayer = createLayer()
local hubCellColorLayer = createLayer()
local productImageLayer = createLayer()
local containerProgressLayer = createLayer()
local markerLayer = createLayer()
local projectionTextLayer = createLayer()
local clickCircleLayer = createLayer()
local clickTextLayer = createLayer()
local rx, ry = getResolution()

setBackgroundColor(0.008, 0.011, 0.016)
setNextFillColor(backgroundLayer, 0.008, 0.011, 0.016, 1)
addBox(backgroundLayer, 0, 0, rx, ry)

local input = getInput() or ""
local hscScreenInputChanged = hscScreenLastInput ~= input

if hscScreenInputChanged then
    hscScreenInputReceiveCount = (hscScreenInputReceiveCount or 0) + 1
    hscScreenLastInput = input
end

 hscScreenConfig = hscScreenConfig or {
    fontSize = 12,
    clickPollFrames = 2,
    rows = 3,
    columns = 5,
    reserveTopTextArea = false,
    reserveBottomTextArea = false,
    reservedTextAreaFraction = 0.12,
    gridMarginLeft = 0,
    gridMarginRight = 0,
    gridMarginTop = 0,
    gridMarginBottom = 0,
    showScreenDebug = false,
    showElementsDebug = false,
    screenTitle = ""
}
hscScreenCells = hscScreenCells or {}
local clickMarkers = {}

if hscScreenInputChanged then
    local parsedFontSize, parsedClickPollFrames, parsedRows, parsedColumns,
        parsedTopArea, parsedBottomArea, parsedAreaFraction, parsedGridLeft,
        parsedGridRight, parsedGridTop, parsedGridBottom, parsedScreenDebug,
        parsedElementsDebug, parsedTitle = string.match(
        input,
        "^HSCFG1|(%d+)|(%d+)|(%d+)|(%d+)|([01])|([01])|([%d%.]+)|([%d%.]+)|([%d%.]+)|([%d%.]+)|([%d%.]+)|([01])|([01])|(.*)$"
    )

    if parsedFontSize then
        hscScreenConfig = {
            fontSize = tonumber(parsedFontSize),
            clickPollFrames = math.max(1, tonumber(parsedClickPollFrames)),
            rows = math.max(1, tonumber(parsedRows)),
            columns = math.max(1, tonumber(parsedColumns)),
            reserveTopTextArea = parsedTopArea == "1",
            reserveBottomTextArea = parsedBottomArea == "1",
            reservedTextAreaFraction = math.max(0, math.min(0.40,
                tonumber(parsedAreaFraction) or 0.12)),
            gridMarginLeft = math.max(0, math.min(0.49, tonumber(parsedGridLeft) or 0)),
            gridMarginRight = math.max(0, math.min(0.49, tonumber(parsedGridRight) or 0)),
            gridMarginTop = math.max(0, math.min(0.49, tonumber(parsedGridTop) or 0)),
            gridMarginBottom = math.max(0, math.min(0.49, tonumber(parsedGridBottom) or 0)),
            showScreenDebug = parsedScreenDebug == "1",
            showElementsDebug = parsedElementsDebug == "1",
            screenTitle = parsedTitle or ""
        }
        hscScreenCells = {}
    else
        local clearColumn, clearRow = string.match(
            input,
            "^HSCLEAR1|(%d+)|(%d+)$"
        )

        if clearColumn and clearRow then
            hscScreenCells[clearColumn .. ":" .. clearRow] = nil
        else
        local fields = {}

        for field in string.gmatch(input .. "|", "(.-)|") do
            fields[#fields + 1] = field
        end

        local function decodeField(value)
            return (tostring(value or ""):gsub("%%(%x%x)", function(hex)
                return string.char(tonumber(hex, 16))
            end))
        end

        if fields[1] == "HSCELL5" and #fields >= 18 then
            local column = tonumber(fields[2])
            local row = tonumber(fields[3])
            local x = tonumber(fields[4])
            local y = tonumber(fields[5])

            if column and row and x and y then
                hscScreenCells[column .. ":" .. row] = {
                    column = column, row = row,
                    x = x, y = y, inside = fields[6] == "1",
                    iconPath = decodeField(fields[7]),
                    tier = decodeField(fields[8]),
                    productType = decodeField(fields[9]),
                    source = decodeField(fields[10]),
                    name = decodeField(fields[11]),
                    size = decodeField(fields[12]),
                    primaryAmount = fields[13],
                    volume = decodeField(fields[14]),
                    mass = decodeField(fields[15]),
                    secondary = decodeField(fields[16]),
                    containerLabel = decodeField(fields[17]),
                    containerFill = tonumber(fields[18]) or 0
                }
            end
        end
        end
    end
end

local fontSize = hscScreenConfig.fontSize
local clickPollFrames = hscScreenConfig.clickPollFrames
local rows = hscScreenConfig.rows
local columns = hscScreenConfig.columns
local reserveTopTextArea = hscScreenConfig.reserveTopTextArea
local reserveBottomTextArea = hscScreenConfig.reserveBottomTextArea
local reservedTextAreaFraction = hscScreenConfig.reservedTextAreaFraction
local gridMarginLeft = hscScreenConfig.gridMarginLeft
local gridMarginRight = hscScreenConfig.gridMarginRight
local gridMarginTop = hscScreenConfig.gridMarginTop
local gridMarginBottom = hscScreenConfig.gridMarginBottom
local showScreenDebug = hscScreenConfig.showScreenDebug
local showElementsDebug = hscScreenConfig.showElementsDebug
local screenTitle = hscScreenConfig.screenTitle
local points = {}

for _, point in pairs(hscScreenCells) do
    points[#points + 1] = point
end

local cursorX, cursorY = getCursor()
local cursorPressed = getCursorPressed()
local cursorDown = getCursorDown()
local cursorReleased = getCursorReleased()
local cursorInside = cursorX >= 0 and cursorX <= rx and cursorY >= 0 and cursorY <= ry

if showScreenDebug and cursorInside and (cursorPressed or cursorDown or cursorReleased) then
    local normalizedCursorX = cursorX / rx
    local normalizedCursorY = cursorY / ry

    setOutput(string.format(
        "HSC_CLICK|%.6f|%.6f|%.6f",
        normalizedCursorX,
        normalizedCursorY,
        getTime()
    ))

    if cursorPressed or cursorReleased then
        logMessage(string.format(
            "[HSC] Screen click detected: x=%.4f, y=%.4f",
            normalizedCursorX,
            normalizedCursorY
        ))
    end
end

requestAnimationFrame(clickPollFrames)

local gap = math.max(4, math.floor(math.min(rx, ry) * 0.006))
local reservedBandHeight = math.floor(ry * reservedTextAreaFraction)
local gridLeft = gridMarginLeft * rx
local gridRight = rx - gridMarginRight * rx
local gridTop = gridMarginTop * ry
local gridBottom = ry - gridMarginBottom * ry
local gridWidth = math.max(1, gridRight - gridLeft)
local gridHeight = math.max(1, gridBottom - gridTop)
local cellWidth = gridWidth / columns
local cellHeight = gridHeight / rows

local function addOutlinedText(layer, font, text, x, y, r, g, b, a,
    alignH, alignV, outlineOffset, borderR, borderG, borderB)
    outlineOffset = tonumber(outlineOffset) or 1
    borderR = borderR ~= nil and borderR or 1 - r
    borderG = borderG ~= nil and borderG or 1 - g
    borderB = borderB ~= nil and borderB or 1 - b
    local offsets = {
        { -outlineOffset, -outlineOffset },
        { outlineOffset, -outlineOffset },
        { outlineOffset, outlineOffset },
        { -outlineOffset, outlineOffset },
        { -outlineOffset, 0 },
        { 0, -outlineOffset },
        { outlineOffset, 0 },
        { 0, outlineOffset }
    }

    for _, offset in ipairs(offsets) do
        setNextFillColor(layer, borderR, borderG, borderB, a)
        setNextShadow(layer, 0, 0, 0, 0, 0)
        setNextTextAlign(layer, alignH, alignV)
        addText(layer, font, text, x + offset[1], y + offset[2])
    end

    setNextFillColor(layer, r, g, b, a)
    setNextShadow(layer, 0, 0, 0, 0, 0)
    setNextTextAlign(layer, alignH, alignV)
    addText(layer, font, text, x, y)
end

local titleAreaHeight = gridTop > 0
    and math.min(gridTop, reservedBandHeight)
    or reservedBandHeight

-- Four fixed typography levels. Every label below reuses one of these
-- preloaded resources; no cell or product line loads its own font.
local titleFontSize = math.max(14, math.floor(
    math.min(fontSize * 2.1, titleAreaHeight * 0.50)
))
local cellTitleFontSize = math.max(10, math.floor(fontSize * 1.15))
local secondaryFontSize = math.max(8, math.floor(fontSize * 0.90))
local smallFontSize = math.max(7, math.floor(fontSize * 0.72))
local titleFont = loadFont("Play-Bold", titleFontSize)
local cellTitleFont = loadFont("Play-Bold", cellTitleFontSize)
local secondaryFont = loadFont("Play-Bold", secondaryFontSize)
local smallFont = loadFont("Play-Bold", smallFontSize)

if reserveTopTextArea and screenTitle ~= "" then
    addOutlinedText(titleTextLayer, titleFont, screenTitle, rx / 2,
        titleAreaHeight / 2, 1.00, 0.86, 0.12, 1, AlignH_Center, AlignV_Middle)
end

setNextFillColor(titleTextLayer, 0.92, 0.94, 0.98, 1)
setNextShadow(titleTextLayer, 2, 0, 0, 0, 1)
setNextTextAlign(titleTextLayer, AlignH_Right, AlignV_Middle)
addText(
    titleTextLayer,
    smallFont,
    "screen update #" .. tostring(hscScreenInputReceiveCount or 0),
    rx - 30,
    ry - 10
)

for row = 1, rows do
    for column = 1, columns do
        local x = gridLeft + (column - 1) * cellWidth + gap / 2
        local y = gridTop + (row - 1) * cellHeight + gap / 2
        local width = cellWidth - gap
        local height = cellHeight - gap

        setNextFillColor(gridBorderLayer, 0.18, 0.32, 0.43, 0.95)
        addBoxRounded(gridBorderLayer, x, y, width, height, 7)
        setNextFillColor(gridCellLayer, 0.025, 0.044, 0.060, 0.88)
        addBoxRounded(gridCellLayer, x + 2, y + 2, width - 4, height - 4, 5)
    end
end

local markerSize = math.max(3, math.floor(fontSize * 0.32))
local categoryFont = smallFont
local detailFont = smallFont
local mainProductFont = cellTitleFont
local containerFont = secondaryFont

local function splitLongWord(lines, font, word, maximumWidth)
    local piece = ""

    for index = 1, #word do
        local character = string.sub(word, index, index)

        if piece ~= ""
            and getTextBounds(font, piece .. character) > maximumWidth then
            lines[#lines + 1] = piece
            piece = character
        else
            piece = piece .. character
        end
    end

    return piece
end

local function wrapLabelToWidth(font, label, maximumWidth)
    local lines = {}
    local currentLine = ""

    for word in string.gmatch(label, "%S+") do
        local candidate = currentLine == "" and word
            or currentLine .. " " .. word
        local candidateWidth = getTextBounds(font, candidate)

        if candidateWidth <= maximumWidth then
            currentLine = candidate
        elseif currentLine ~= "" then
            lines[#lines + 1] = currentLine
            currentLine = getTextBounds(font, word) <= maximumWidth
                and word
                or splitLongWord(lines, font, word, maximumWidth)
        else
            currentLine = splitLongWord(lines, font, word, maximumWidth)
        end
    end

    if currentLine ~= "" then
        lines[#lines + 1] = currentLine
    end

    return lines
end

for index, point in ipairs(points) do
    local normalizedX = math.max(0, math.min(1, point.x))
    local normalizedY = math.max(0, math.min(1, point.y))
    local x = normalizedX * rx
    local y = normalizedY * ry
    local primaryName = point.name or "Hub"
    local column = math.max(1, math.min(
        columns,
        tonumber(point.column) or 1
    ))
    local row = math.max(1, math.min(
        rows,
        tonumber(point.row) or 1
    ))
    local cellX = gridLeft + (column - 1) * cellWidth + gap / 2
    local cellY = gridTop + (row - 1) * cellHeight + gap / 2
    local cellDrawWidth = cellWidth - gap
    local cellDrawHeight = cellHeight - gap

    if not point.inside then
        primaryName = "[OUT] " .. primaryName
    else
        local colorR = 0.18 + ((index * 47) % 45) / 100
        local colorG = 0.18 + ((index * 29) % 45) / 100
        local colorB = 0.18 + ((index * 13) % 45) / 100

        setNextFillColor(hubCellColorLayer, colorR, colorG, colorB, 0.06)
        addBoxRounded(
            hubCellColorLayer,
            cellX + 3,
            cellY + 3,
            cellDrawWidth - 6,
            cellDrawHeight - 6,
            4
        )

        if point.iconPath ~= nil and point.iconPath ~= "" then
            local productImage = loadImage(point.iconPath)

            if productImage ~= nil then
                local imageSize = math.max(1, math.min(
                    cellDrawWidth - 12,
                    cellDrawHeight - 12
                ))
                setNextFillColor(productImageLayer, 1, 1, 1, 0.80)
                addImage(productImageLayer, productImage,
                    cellX + (cellDrawWidth - imageSize) / 2,
                    cellY + (cellDrawHeight - imageSize) / 2,
                    imageSize, imageSize)
            end
        end
    end

    if showElementsDebug then
        setNextFillColor(markerLayer, 1.00, 0.78, 0.05, 1)
        addBox(
            markerLayer,
            x - markerSize / 2,
            y - markerSize / 2,
            markerSize,
            markerSize
        )

        local projectionCoordinate = string.format("%.3f;%.3f", point.x, point.y)
        local coordinateOffset = markerSize / 2 + smallFontSize + 3
        setNextFillColor(projectionTextLayer, 1.00, 0.86, 0.12, 1)
        setNextShadow(projectionTextLayer, 2, 0, 0, 0, 1)
        setNextTextAlign(projectionTextLayer, AlignH_Center, AlignV_Middle)
        addText(projectionTextLayer, smallFont, projectionCoordinate,
            x, y - coordinateOffset)
        addText(projectionTextLayer, smallFont, projectionCoordinate,
            x, y + coordinateOffset)
    end

    local mainName = primaryName

    if point.size ~= nil and point.size ~= "" then
        mainName = mainName .. " " .. string.upper(point.size)
    end

    local amountText = point.primaryAmount ~= nil and point.primaryAmount ~= ""
        and " x" .. point.primaryAmount
        or ""

    local labelFont = mainProductFont
    local wrappedLines
    local amountOnLastTitleLine = false
    local amountOnOwnLine = false
    local singleLineWidth = getTextBounds(labelFont, mainName .. amountText)

    if singleLineWidth <= cellDrawWidth - 6 then
        wrappedLines = { mainName }
        amountOnLastTitleLine = amountText ~= ""
    else
        wrappedLines = wrapLabelToWidth(
            labelFont,
            mainName,
            cellDrawWidth - 16
        )

        if amountText ~= "" then
            local lastLine = wrappedLines[#wrappedLines] or ""

            if getTextBounds(labelFont, lastLine .. amountText)
                <= cellDrawWidth - 16 then
                amountOnLastTitleLine = true
            else
                amountOnOwnLine = true
            end
        end
    end
    local labelLineHeight = cellTitleFontSize * 1.15
    local labelCenterX = cellX + cellDrawWidth / 2

    local secondaryLines = {}
    for secondaryLine in string.gmatch(point.secondary or "", "[^\n]+") do
        secondaryLines[#secondaryLines + 1] = secondaryLine
    end

    local containerLabel = point.containerLabel or ""
    local hasContainerLine = containerLabel ~= ""
    local progressHeight = math.max(secondaryFontSize + 2, 12)
    local progressY = cellY + cellDrawHeight - progressHeight - 3
    local containerTextY = progressY + progressHeight / 2
    local headerY = cellY + 10
    local firstLabelY = headerY + smallFontSize + 5
    local titleLineCount = #wrappedLines + (amountOnOwnLine and 1 or 0)
    local metricsY = firstLabelY
        + (titleLineCount - 1) * labelLineHeight
        + cellTitleFontSize + 5

    local function addPairChunk(text, x, y, isValue)
        if text == nil or text == "" then return x end

        local r, g, b = 0.92, 0.94, 0.98
        if isValue then r, g, b = 1.00, 0.86, 0.12 end

        addOutlinedText(projectionTextLayer, smallFont, text, x, y,
            r, g, b, 1, AlignH_Left, AlignV_Middle, 1, 0, 0, 0)
        return x + getTextBounds(smallFont, text)
    end

    if point.inside then
        local headerX = cellX + 8

        if point.tier ~= nil and point.tier ~= "" then
            headerX = addPairChunk("Tier ", headerX, headerY, false)
            headerX = addPairChunk(point.tier, headerX, headerY, true)
        end

        if point.productType ~= nil and point.productType ~= "" then
            headerX = addPairChunk(headerX > cellX + 8 and ", type " or "type ",
                headerX, headerY, false)
            headerX = addPairChunk(point.productType, headerX, headerY, true)
        end

        if point.source ~= nil and point.source ~= "" then
            headerX = addPairChunk(headerX > cellX + 8 and ", source " or "source ",
                headerX, headerY, false)
            addPairChunk(point.source, headerX, headerY, true)
        end
    end

    for lineIndex, line in ipairs(wrappedLines) do
        local lineY = firstLabelY + (lineIndex - 1) * labelLineHeight
        local appendAmount = lineIndex == #wrappedLines and amountOnLastTitleLine

        if appendAmount then
            local nameWidth = getTextBounds(labelFont, line)
            local amountWidth = getTextBounds(labelFont, amountText)
            local lineX = labelCenterX - (nameWidth + amountWidth) / 2
            addOutlinedText(projectionTextLayer, labelFont, line, lineX,
                lineY, 1.00, 0.72, 0.06, 1,
                AlignH_Left, AlignV_Middle, 2, 0, 0, 0)
            addOutlinedText(projectionTextLayer, labelFont, amountText,
                lineX + nameWidth, lineY, 0.92, 0.94, 0.98, 1,
                AlignH_Left, AlignV_Middle, 2, 0, 0, 0)
        else
            addOutlinedText(projectionTextLayer, labelFont, line, labelCenterX,
                lineY, 1.00, 0.72, 0.06, 1,
                AlignH_Center, AlignV_Middle, 2, 0, 0, 0)
        end
    end

    if amountOnOwnLine then
        addOutlinedText(projectionTextLayer, labelFont, amountText,
            labelCenterX, firstLabelY + #wrappedLines * labelLineHeight,
            0.92, 0.94, 0.98, 1,
            AlignH_Center, AlignV_Middle, 2, 0, 0, 0)
    end

    local volumeY = metricsY
    local massY = metricsY + smallFontSize + 2

    if point.volume ~= nil and point.volume ~= "" then
        local volumeX = addPairChunk("Volume ", cellX + 8, volumeY, false)
        addPairChunk(point.volume, volumeX, volumeY, true)
    end

    if point.mass ~= nil and point.mass ~= "" then
        local massLabel = "Mass "
        local massX = addPairChunk(massLabel, cellX + 8, massY, false)
        addPairChunk(point.mass, massX, massY, true)
    end

    local secondaryRightX = cellX + cellDrawWidth - 8
    local secondaryTopY = massY + smallFontSize / 2 + 6
    local secondaryBottomY = hasContainerLine
        and progressY - 7
        or cellY + cellDrawHeight - 8

    for lineIndex, secondaryLine in ipairs(secondaryLines) do
        local lineY = secondaryBottomY
            - (lineIndex - 1) * (secondaryFontSize + 1)

        if lineY - secondaryFontSize / 2 < secondaryTopY then break end

        addOutlinedText(projectionTextLayer, secondaryFont, secondaryLine,
            secondaryRightX, lineY, 0.55, 0.82, 1.00, 1,
            AlignH_Right, AlignV_Middle)
    end

    if hasContainerLine then
        local progressX = cellX + 8
        local progressWidth = math.max(1, cellDrawWidth - 16)
        local fill = math.max(0, math.min(1, tonumber(point.containerFill) or 0))

        setNextFillColor(containerProgressLayer, 0.14, 0.19, 0.24, 0.88)
        addBoxRounded(containerProgressLayer, progressX, progressY,
            progressWidth, progressHeight, 1)
        local fillR = 0.12 + 0.70 * fill
        local fillG = 0.85 - 0.45 * fill
        local fillB = 0.28

        if fill > 0.90 then
            local danger = math.min(1, (fill - 0.90) / 0.10)
            fillR = 0.75 + 0.25 * danger
            fillG = 0.445 - 0.37 * danger
            fillB = 0.28 - 0.18 * danger
        end

        setNextFillColor(containerProgressLayer, fillR, fillG, fillB, 0.88)
        addBoxRounded(containerProgressLayer, progressX, progressY,
            progressWidth * fill, progressHeight, 1)
        addOutlinedText(projectionTextLayer, containerFont, containerLabel,
            cellX + 14, containerTextY, 0.92, 0.94, 0.98, 1,
            AlignH_Left, AlignV_Middle)
    end
end

if showScreenDebug then
    -- Reuse an existing font. Loading one more font here can exceed the
    -- Screen's font-resource budget after product cells have been rendered.
    local clickFont = smallFont
    local clickRadius = math.max(7, math.floor(fontSize * 0.75))

    for _, marker in ipairs(clickMarkers) do
        local x = marker.x * rx
        local y = marker.y * ry
        local coordinateLabel = string.format(
            "#%d (%.3f, %.3f)", marker.index, marker.x, marker.y)

        setNextFillColor(clickCircleLayer, marker.r, marker.g, marker.b, 0.92)
        addCircle(clickCircleLayer, x, y, clickRadius)
        setNextFillColor(clickTextLayer, marker.r, marker.g, marker.b, 1)
        setNextShadow(clickTextLayer, 2, 0, 0, 0, 1)
        setNextTextAlign(clickTextLayer, AlignH_Left, AlignV_Middle)
        addText(clickTextLayer, clickFont, coordinateLabel,
            x + clickRadius + 5, y)
    end

    if cursorInside then
        setNextFillColor(clickCircleLayer, 0.10, 0.95, 1.00, 0.90)
        addCircle(clickCircleLayer, cursorX, cursorY, 4)
    end
end
]==]
end
