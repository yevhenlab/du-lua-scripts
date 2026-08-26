myLibrary = myLibrary or {}

myLibrary.typeColors = {
    ["Ammo"] = {0.95, 0.65, 0.65, 0.4},
    ["Catalyst"] = {0.80, 0.65, 0.95, 0.4},
    ["Combat Element"] = {0.95, 0.55, 0.60, 0.4},
    ["Complex Part"] = {0.65, 0.75, 0.95, 0.4},
    ["Exceptional Part"] = {0.90, 0.65, 0.95, 0.4},
    ["Fuel"] = {0.65, 0.90, 0.75, 0.4},
    ["Functional Part"] = {0.70, 0.75, 1.00, 0.4},
    ["Furniture & Appliances Element"] = {0.90, 0.75, 0.65, 0.4},
    ["Industry & Infrastructure Element"] = {0.65, 0.85, 0.85, 0.4},
    ["Intermediary Part"] = {0.70, 0.85, 0.95, 0.4},
    ["Ore"] = {0.75, 0.65, 0.55, 0.4},
    ["Piloting Element"] = {0.65, 0.80, 0.95, 0.4},
    ["Planet Element"] = {0.70, 0.90, 0.70, 0.4},
    ["Product"] = {0.85, 0.62, 0.45, 0.4},
    ["Product Honeycomb"] = {0.95, 0.80, 0.55, 0.4},
    ["Pure"] = {0.65, 0.85, 1.00, 0.4},
    ["Pure Honeycomb"] = {0.70, 0.90, 0.95, 0.4},
    ["Scrap"] = {0.70, 0.70, 0.70, 0.4},
    ["Structural Part"] = {0.70, 0.75, 0.80, 0.4},
    ["Systems Element"] = {0.75, 0.70, 0.95, 0.4},
    ["Warp Cell"] = {0.75, 0.60, 1.00, 0.4}
}

myLibrary.defaultColor = {0.75, 0.75, 0.75, 0.4}

function myLibrary.getSlots()
    return {
        slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10,
        slot11, slot12, slot13, slot14, slot15, slot16, slot17, slot18,
        slot19, slot20, slot21, slot22, slot23, slot24, slot25, slot26,
        slot27, slot28, slot29, slot30, slot31, slot32, slot33, slot34,
        slot35, slot36, slot37, slot38, slot39, slot40, slot41, slot42,
        slot43, slot44, slot45, slot46, slot47, slot48, slot49, slot50,
        slot51, slot52, slot53, slot54, slot55, slot56, slot57, slot58,
        slot59, slot60, slot61, slot62, slot63, slot64, slot65, slot66,
        slot67, slot68, slot69, slot70, slot71, slot72, slot73, slot74,
        slot75, slot76, slot77, slot78, slot79, slot80, slot81, slot82,
        slot83, slot84, slot85, slot86, slot87, slot88, slot89, slot90,
        slot91, slot92, slot93, slot94, slot95, slot96, slot97, slot98,
        slot99, slot100
    }
end

function myLibrary.getProductLabel(product)
    local tierTx = product.tier and ("T" .. tostring(product.tier) .. " ") or ""
	
    local title = tostring(product.displayName or product.name or product.id)
    local size = tostring(product.size or "-")

    if size == "" then
        size = "-"
    else
        size = string.upper(size)
    end

    return tierTx .. title .. " [" .. size .. "]"
end

function myLibrary.isIndustry(element)
    if element == nil then
        return false
    end

    local class = element.getClass()
    local ret = class == "IndustryUnit" or string.match(class, "^Industry%d+$") ~= nil
	if not ret and class ~= "ScreenUnit" then system.print(class or "nil") end
	return ret
end

function myLibrary.isScreen(element)
    if element == nil then
        return false
    end

    local class = element.getClass()
    return class == "Screen1" or class == "ScreenUnit"
end

function myLibrary.getSlotPairs()
    local slots = myLibrary.getSlots()
    local slotPairs = {}
    local slotNumber = 1

    while slotNumber < 100 do
        local first = slots[slotNumber]
        local second = slots[slotNumber + 1]
        local industry = nil
        local screen = nil

        if myLibrary.isIndustry(first) and myLibrary.isScreen(second) then
            industry = first
            screen = second
        elseif myLibrary.isScreen(first) and myLibrary.isIndustry(second) then
            industry = second
            screen = first
        end

        if industry and screen then
            slotPairs[#slotPairs + 1] = {
                industry = industry,
                screen = screen,
                industrySlot = slotNumber,
                screenSlot = slotNumber + 1
            }

            if myLibrary.isScreen(first) then
                slotPairs[#slotPairs].industrySlot = slotNumber + 1
                slotPairs[#slotPairs].screenSlot = slotNumber
            end

            slotNumber = slotNumber + 2
        else
            slotNumber = slotNumber + 1
        end
    end

    return slotPairs
end

function myLibrary.getCurrentProduct(industry)
    local info = industry.getInfo()
    local product = info and info.currentProducts and info.currentProducts[1]
    local productId = product and product.id

    if productId == nil then
        local outputs = industry.getOutputs()
        productId = outputs and outputs[1]
    end

    if productId == nil then
        return nil
    end

    local item = system.getItem(productId)

    if item == nil then
        return nil
    end

    local displayClass = nil

    if item.displayClassId then
        displayClass = system.getItem(item.displayClassId)
    end

    item.screenType = item.type

    if displayClass and displayClass.displayName then
        item.screenType = displayClass.displayName
    end

    return item
end

function myLibrary.buildScreenCode(product)
    local title = tostring(product.displayName or product.name or product.id)
    local itemType = tostring(product.screenType or product.type or "Unknown")
    local tier = tostring(product.tier or "-")
    local size = tostring(product.size or "-")
    local unitMass = tostring(product.unitMass or "-")
    local unitVolume = tostring(product.unitVolume or "-")
    local iconPath = tostring(product.iconPath or "")
    local color = myLibrary.typeColors[itemType] or myLibrary.defaultColor

    if size == "" then
        size = "-"
    else
        size = string.upper(size)
    end

    local screenTemplate = [==[
local rslib = require('rslib')
local backgroundLayer = createLayer()
local imageLayer = createLayer()
local headerLayer = createLayer()
local titleOutlineLayer = createLayer()
local titleLayer = createLayer()
local detailsLayer = createLayer()
local rx, ry = getResolution()

local title = %q
local itemType = %q
local tier = %q
local size = %q
local unitMass = %q
local unitVolume = %q
local iconPath = %q
local typeColor = {%.3f, %.3f, %.3f, %.3f}

local img = loadImage(iconPath)

setNextFillColor(
    backgroundLayer,
    typeColor[1],
    typeColor[2],
    typeColor[3],
    typeColor[4]
)
addBox(backgroundLayer, 0, 0, rx, ry)

local imageSize = math.min(rx, ry) * 0.98
local imageX = (rx - imageSize) / 2
local imageY = (ry - imageSize) / 2

setNextFillColor(backgroundLayer, 0, 0, 0, 1)
addBox(backgroundLayer, imageX, imageY, imageSize, imageSize)
addImage(imageLayer, img, imageX, imageY, imageSize, imageSize)

-- Header: type on the first line
local typeFontSize = 57
local typeFont = loadFont("Play-Bold", typeFontSize)

setNextFillColor(headerLayer, typeColor[1], typeColor[2], typeColor[3], 1)
setNextShadow(headerLayer, 3, 0, 0, 0, 1)
setNextTextAlign(headerLayer, AlignH_Center, AlignV_Top)
addText(headerLayer, typeFont, itemType .. ":", rx / 2, 22)

-- Tier and size on the second line, 40 percent smaller
local infoFontSize = math.floor(typeFontSize * 0.6)
local infoFont = loadFont("Play-Bold", infoFontSize)
local infoText = "Tier: " .. tier .. "    Size: [" .. size .. "]"

setNextFillColor(headerLayer, 1, 1, 1, 1)
setNextShadow(headerLayer, 3, 0, 0, 0, 1)
setNextTextAlign(headerLayer, AlignH_Center, AlignV_Top)
addText(headerLayer, infoFont, infoText, rx / 2, 84)

-- Reduce the title font until it fits within two lines
local titleSize = 100
local titleFont = nil
local titleLines = nil
local maxTitleWidth = rx * 0.82
local titleFits = false

while titleSize >= 48 and not titleFits do
    titleFont = loadFont("Play-Bold", titleSize)
    titleLines = rslib.getTextWrapped(titleFont, title, maxTitleWidth)
    titleFits = #titleLines <= 2

    for _, line in ipairs(titleLines) do
        local lineWidth = getTextBounds(titleFont, line)

        if lineWidth > maxTitleWidth then
            titleFits = false
        end
    end

    if not titleFits then
        titleSize = titleSize - 4
    end
end

-- Title remains centered inside its own region
local titleSpacing = titleSize * 0.9
local titleCenterY = ry * 0.59
local titleY = titleCenterY - titleSpacing * (#titleLines - 1) / 2
local titleX = rx / 2
local shift = 6

for _, line in ipairs(titleLines) do
    setNextFillColor(titleOutlineLayer, 0, 0, 0, 1)
    setNextTextAlign(titleOutlineLayer, AlignH_Center, AlignV_Middle)
    addText(titleOutlineLayer, titleFont, line, titleX - shift, titleY - shift)

    setNextFillColor(titleOutlineLayer, 0, 0, 0, 1)
    setNextTextAlign(titleOutlineLayer, AlignH_Center, AlignV_Middle)
    addText(titleOutlineLayer, titleFont, line, titleX + shift, titleY - shift)

    setNextFillColor(titleOutlineLayer, 0, 0, 0, 1)
    setNextTextAlign(titleOutlineLayer, AlignH_Center, AlignV_Middle)
    addText(titleOutlineLayer, titleFont, line, titleX - shift, titleY + shift)

    setNextFillColor(titleOutlineLayer, 0, 0, 0, 1)
    setNextTextAlign(titleOutlineLayer, AlignH_Center, AlignV_Middle)
    addText(titleOutlineLayer, titleFont, line, titleX + shift, titleY + shift)

    setNextFillColor(titleLayer, 1, 1, 0, 1)
    setNextTextAlign(titleLayer, AlignH_Center, AlignV_Middle)
    addText(titleLayer, titleFont, line, titleX, titleY)
    titleY = titleY + titleSpacing
end

-- Mass and volume have a dedicated bottom line
local detailsFont = loadFont("Play-Bold", 34)
local detailsText = "Mass: " .. unitMass .. " kg"
detailsText = detailsText .. "    Volume: " .. unitVolume .. " L"

setNextFillColor(detailsLayer, 1, 1, 1, 1)
setNextShadow(detailsLayer, 3, 0, 0, 0, 1)
setNextTextAlign(detailsLayer, AlignH_Center, AlignV_Bottom)
addText(detailsLayer, detailsFont, detailsText, rx / 2, ry - 24)
]==]

    return string.format(
        screenTemplate,
        title,
        itemType,
        tier,
        size,
        unitMass,
        unitVolume,
        iconPath,
        color[1],
        color[2],
        color[3],
        color[4]
    )
end
