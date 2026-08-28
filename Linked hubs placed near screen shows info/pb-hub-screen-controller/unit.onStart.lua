local ok, result = pcall(hsc.run)

if ok then
    hsc.print("Startup projection complete: " .. tostring(result) .. " hubs displayed.")
else
    hsc.print("Startup failed: " .. tostring(result))
end
