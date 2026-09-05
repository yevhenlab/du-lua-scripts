-- Library dependencies: liby.liby4performance and liby.example-rectangle-content-html.
-- These PB-local renderers return HTML; liby4performance combines them into one HUD.
local exampleExternalHtml = require("liby.example-rectangle-content-html")

function drawExampleCircle()
    return [[<svg style="position:absolute;left:0;top:0;width:100%;height:100%;"><circle cx="50%" cy="65%" r="34" fill="rgba(20,70,95,.35)" stroke="#8de7ff" stroke-width="2"/><text x="50%" y="65%" text-anchor="middle" dominant-baseline="middle" fill="#f2fbff" style="font:bold 14px Arial,sans-serif;">example</text></svg>]]
end

function drawExampleCounter()
    return '<div style="position:absolute;right:28px;bottom:270px;color:#f2fbff;font:bold 42px Arial,sans-serif;text-shadow:1px 1px 0 #000;">' .. tostring(exampleCounter) .. '</div>'
end

function drawExampleExternalHtml()
    return '<div style="position:absolute;right:28px;bottom:332px;width:250px;box-sizing:border-box;padding:12px;border:2px solid #ffcf74;background:rgba(55,35,12,.5);text-shadow:1px 1px 0 #000;">' .. exampleExternalHtml .. '</div>'
end
