-- Library dependencies: none.
-- PB-only drawing functions. They return HTML; liby4performance draws it.

function drawExampleCircle()
    return [[
        <svg style="position:absolute;left:0;top:0;width:100%;height:100%;">
            <circle cx="50%" cy="65%" r="34" fill="rgba(20,70,95,.35)"
                stroke="#8de7ff" stroke-width="2"/>
            <text x="50%" y="65%" text-anchor="middle" dominant-baseline="middle"
                fill="#f2fbff" style="font:bold 14px Arial,sans-serif;">example</text>
        </svg>
    ]]
end
