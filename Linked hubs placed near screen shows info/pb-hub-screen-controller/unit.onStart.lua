local ok, result = pcall(hsc.run)

if ok then
    hsc.print("Startup association complete: " .. tostring(result) .. " cells displayed.")
else
    hsc.print("Startup failed: " .. tostring(result))
end
