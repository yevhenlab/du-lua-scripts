local foundCore, slotName = ibh.findCore()

ibh.startedAt = system.getArkTime()
system.showScreen(true)
ibh.updateHudClock()
unit.setTimer("ibhHudClock", 0.5)

if foundCore == nil then
    ibh.debugElements("Core not found; link it and restart PB.")
else
    local localId = ibh.call(foundCore, "getLocalId") or "?"

    ibh.debugElements(
        "Core: " .. tostring(slotName)
        .. ", id " .. tostring(localId)
    )

    local foundDatabank, databankSlot = ibh.findDatabank()
    if foundDatabank ~= nil then
        local restored = ibh.loadTrackedElements()
        ibh.loadContainerCapacities()
        ibh.debugElements(
            "Databank: " .. tostring(databankSlot)
            .. ", loaded " .. tostring(restored)
        )
        if ibhDebugPbStartInfo then
            ibh.printContainerCapacityDatabank()
        end
    else
        ibh.debugElements("Databank not linked.")
    end

    if not ibh.startElementSearch(foundCore) then
        ibh.debugElements("Element search could not start.")
    end
end
