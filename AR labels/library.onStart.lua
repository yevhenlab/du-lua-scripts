atlas = require("atlas")
cubes = {}
destinations = destinations or {}
straights = {}

if #destinations == 0 then
	local loaded, customDestinations = pcall(require, "custom/destinations")
	if loaded and type(customDestinations) == "table" then
		destinations = customDestinations
	end
end

min, max, format, match, rad, cos, sin = math.min, math.max, string.format, string.match, math.rad, math.cos, math.sin
dest = ""
w = system.getScreenWidth()
h = system.getScreenHeight()
far = 950000

function destToCord(dest)
	local destSystem, destPlanet, x, y, z = match(dest, "::pos{ *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*)}")
	local coorD = {}
	if destSystem == "0" and destPlanet == "0" then
		coorD = vec3({ tonumber(x), tonumber(y), tonumber(z) })
	else
		y = rad(y)
		x = rad(x)
		coorD = vec3(atlas[tonumber(destSystem)][tonumber(destPlanet)].center) + (atlas[tonumber(destSystem)][tonumber(destPlanet)].radius + z) * vec3(cos(x) * cos(y), cos(x) * sin(y), sin(x))
	end
	return coorD
end

function drawDot()
	local out = ""
	local playerPos = vec3(system.getCameraWorldPos())
	local cameraForward = vec3(system.getCameraWorldForward())
	dest = false

	for _, destination in pairs(destinations) do
		if destination.pos ~= "" then
			local coorD = destToCord(destination.pos)
			local distance = vec3().dist(coorD, playerPos)
			local cameraPos = coorD - playerPos

			if cameraForward:angle_between(cameraPos) < 0.035 then
				dest = destination.pos
			end

			local screenPoint = vec3(library.getPointOnScreen({ coorD:unpack() }))
			local svgH = min(max(15 * far / distance, 10), 15)
			local svgW = min(max(15 * far / distance, 10), 15)

			local dstStr = ""
			if distance / 1000 / 200 < 1 then
				dstStr = format("%0.1f", distance) .. " m"
			else
				dstStr = format("%0.1f", distance / 1000 / 200) .. " su"
			end

			if screenPoint.z ~= 0 then
				if destination.color == nil then
					destination.color = "0, 200, 150"
				end

				out = out .. [[
					<div style='
						position:absolute;
						color:rgb(]] .. destination.color .. [[);
						background:rgba(0,0,0,0.38);
						border:1px solid rgba(255,255,255,0.45);
						border-radius:4px;
						padding:2px 5px;
						text-shadow:
							-1px -1px 0 #000,
							 1px -1px 0 #000,
							-1px  1px 0 #000,
							 1px  1px 0 #000,
							 0 0 3px #fff,
							 0 0 7px rgba(0,0,0,0.5);
						font-size:]] .. min(max(17 * far / distance, 10), 17) .. [[px;
						top:]] .. screenPoint.y * 100 - 100 * svgH / 2 / h .. [[%;
						left:]] .. screenPoint.x * 100 - 100 * svgW / 2 / w .. [[%;
					'>
						<svg width="]] .. svgW .. [[" height="]] .. svgH .. [[">
							<rect width="]] .. svgW .. [[" height="]] .. svgH .. [["
								style="stroke-width:2; stroke:rgb(]] .. destination.color .. [[); fill-opacity:0" />
						</svg>
						]] .. destination.name .. [[ ]] .. dstStr .. [[
					</div>
				]]
			end
		end
	end

	return out
end

function drawCubes()
	local out = ""
	for _, cube in pairs(cubes) do
		local _, _, x1, y1, h1 = match(cube[1], "::pos{ *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*)}")
		local _, _, x2, y2, h2 = match(cube[2], "::pos{ *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*), *([+-]?%d+%.?%d*e?[+-]?%d*)}")
		hP = vec3().dist(vec3(system.getCameraWorldPos()), vec3({ -8.00, -8.00, -126303.00 })) - 126069.9
		cube = {
			[1] = "::pos{0,2," .. x1 .. "," .. y1 .. "," .. h1 .. "}", -- 3:1
			[2] = "::pos{0,2," .. x2 .. "," .. y1 .. "," .. h1 .. "}", -- 3:2
			[3] = "::pos{0,2," .. x1 .. "," .. y2 .. "," .. h1 .. "}", -- 3:5
			[4] = "::pos{0,2," .. x2 .. "," .. y2 .. "," .. h1 .. "}", -- 3:6

			[5] = "::pos{0,2," .. x1 .. "," .. y1 .. "," .. h2 .. "}", -- 2:1
			[6] = "::pos{0,2," .. x2 .. "," .. y1 .. "," .. h2 .. "}", -- 2:2
			[7] = "::pos{0,2," .. x1 .. "," .. y2 .. "," .. h2 .. "}", -- 2:5
			[8] = "::pos{0,2," .. x2 .. "," .. y2 .. "," .. h2 .. "}", -- 2:6

			[9] = "::pos{0,2," .. x1 .. "," .. y1 .. "," .. hP .. "}", -- p
			[10] = "::pos{0,2," .. x1 .. "," .. y2 .. "," .. hP .. "}", -- p
			[11] = "::pos{0,2," .. x2 .. "," .. y2 .. "," .. hP .. "}", -- p
			[12] = "::pos{0,2," .. x2 .. "," .. y1 .. "," .. hP .. "}", -- p
			["rgb"] = cube["rgb"] or "0, 255, 0"
		}
		localCube = {
			cube[1], cube[2], cube[1], cube[3], cube[1], cube[5], cube[8], cube[7], cube[8], cube[6], cube[8], cube[4], cube[3], cube[4], cube[4], cube[2], cube[2], cube[6], cube[6], cube[5], cube[5], cube[7], cube[7], cube[3], cube[9], cube[10], cube[10], cube[11], cube[11], cube[12], cube[12], cube[9],
		}
		for i = 1, #localCube, 2 do
			v1 = destToCord(localCube[i])
			v2 = destToCord(localCube[i + 1])
			cord1 = vec3(library.getPointOnScreen({ v1:unpack() }))
			cord2 = vec3(library.getPointOnScreen({ v2:unpack() }))
			x1 = cord1.x * w
			y1 = cord1.y * h
			x2 = cord2.x * w
			y2 = cord2.y * h
			if i < 24 then
				rgb = cube["rgb"]
			else
				rgb = "0, 50, 50"
			end --or  "0, 150, 150"
			if x1 * x2 * y1 * y2 ~= 0 then
				out = out .. [[
						<g style ="position:absolute; top:0px; left:0px;">
    						<svg  width="]] .. w .. [[" height="]] .. h .. [[">
    					    	<line x1="]] .. x1 .. [[" y1="]] .. y1 .. [[" x2="]] .. x2 .. [[" y2="]] .. y2 .. [[" style="stroke-width:2; stroke:rgb(]] .. rgb .. [[);" />
    						</svg>
						</g>
					]]
			else
				rgb = "200, 0, 0"
				if x1 * y1 ~= 0 then
					l = vec3().dist(vec3(system.getCameraWorldPos()), v1)
					v2 = (v2 - v1):normalize() * l + v1
					cord2 = vec3(library.getPointOnScreen({ v2:unpack() }))
					x2 = cord2.x * w
					y2 = cord2.y * h
					if x2 * y2 ~= 0 then
						out = out .. [[
				    			<g style ="position:absolute; top:0px; left:0px;">
    			    				<svg  width="]] .. w .. [[" height="]] .. h .. [[">
    		        					<line x1="]] .. x1 .. [[" y1="]] .. y1 .. [[" x2="]] .. x2 .. [[" y2="]] .. y2 .. [[" style="stroke-width:2; stroke:rgb(]] .. rgb .. [[);" />
    			    				</svg>
				    			</g>
				    		]]
					end
				elseif x2 * y2 ~= 0 then
					l = vec3().dist(vec3(system.getCameraWorldPos()), v2)
					v1 = (v1 - v2):normalize() * l + v2
					cord1 = vec3(library.getPointOnScreen({ v1:unpack() }))
					x1 = cord1.x * w
					y1 = cord1.y * h
					if x1 * y1 ~= 0 then
						out = out .. [[
				    	<g style ="position:absolute; top:0px; left:0px;">
    			    		<svg  width="]] .. w .. [[" height="]] .. h .. [[">
    		        			<line x1="]] .. x1 .. [[" y1="]] .. y1 .. [[" x2="]] .. x2 .. [[" y2="]] .. y2 .. [[" style="stroke-width:2; stroke:rgb(]] .. rgb .. [[);" />
    			    		</svg>
				    	</g>
				    ]]
					end
				end
			end
		end
	end
	return out
end

function drawLines()
	local out = ""
	--local playerPos = vec3(system.getCameraWorldPos()) - vec3(system.getCameraWorldUp()) + vec3(system.getCameraWorldForward())
	--local screenPoint = vec3(library.getPointOnScreen({ playerPos:unpack() }))
	--x1 = screenPoint.x * w
	--y1 = screenPoint.y * h
	local i = 0
	for _, straight in pairs(straights) do
		local screenPoint = vec3(library.getPointOnScreen({ destToCord(straight[1]):unpack() }))
		x1 = screenPoint.x * w
		y1 = screenPoint.y * h
		z1 = screenPoint.z
		for _, line in pairs(straight) do
			coorD = destToCord(line)
			local screenPoint = vec3(library.getPointOnScreen({ coorD:unpack() }))
			i = i + 1
			x2 = screenPoint.x * w
			y2 = screenPoint.y * h
			z2 = screenPoint.z
			if z1 ~= 0 and z2 ~= 0 then
				out = out .. [[
				    	<g style ="position:absolute; top:0px; left:0px;">
    			    		<svg  width="]] .. w .. [[" height="]] .. h .. [[">
    		        			<line x1="]] .. x1 .. [[" y1="]] .. y1 .. [[" x2="]] .. x2 .. [[" y2="]] .. y2 .. [[" style="stroke-width:2; stroke:rgb(0,255,0);" />
    			    		</svg>
				    	</g>
				    ]]
				local svgH = 15
				local svgW = 15
				out = out .. [[ <div style='position:absolute; text-shadow: 0px 0px 5px;color:rgb(0,255,0);font-size: 17px;top:]] .. screenPoint.y * 100 - 100 * svgH / 2 / h .. [[%;left:]] .. screenPoint.x * 100 - 100 * svgW / 2 / w .. [[%;'>
                        <svg width="]] .. svgW .. [[" height="]] .. svgH .. [[">
                          <rect width="]] .. svgW .. [[" height="]] .. svgH .. [[" style="stroke-width:2; stroke:rgb(0,255,0); fill-opacity:0" />
                      </svg>
                ]] .. i .. [[ </div>]]
			end
			x1 = x2
			y1 = y2
			z1 = z2
		end
	end
	return out
end

if #cubes == 0 then
	drawCubes = function()
		return ""
	end
end
if #destinations == 0 then
	drawDot = function()
		return ""
	end
end
if #straights == 0 then
	drawLines = function()
		return ""
	end
end
