local slotPairs = myLibrary.getSlotPairs()
local updatedScreens = 0

for _, slotPair in ipairs(slotPairs) do
    local product = myLibrary.getCurrentProduct(slotPair.industry)

    if product then
        local screenCode = myLibrary.buildScreenCode(product)
        slotPair.screen.setRenderScript(screenCode)
        slotPair.screen.activate()
        updatedScreens = updatedScreens + 1

        system.print("Updated: " .. myLibrary.getProductLabel(product))
    end
end

system.print("Updated screens: " .. updatedScreens)
unit.exit()
