# liby4slots

liby4slots discovers actual element objects linked directly to any Dual Universe Control Unit. Returned objects retain their element APIs.

## Install in the DU client

Copy the contents of `src/du lua library` into your DU client's
`Game/data/lua` directory. The installed file must end up at:

```text
<DU installation>/Game/data/lua/liby/liby4slots.lua
```
Alternatively, run the installer with your own DU installation path:

```powershell
.\install-local.ps1 -DuRoot "D:\Games\My Dual Universe"
```

## Use in Control Unit code

```lua
local initializeLiby4slots = require("liby.liby4slots")
local liby4slots = initializeLiby4slots(_G, unit, system)

local elements = liby4slots.getLinkedElements()
liby4slots.printLinkedElements()
```


DU loads required modules in a separate global environment. Passing `_G`, `unit`, and `system` gives liby4slots access to the calling Control Unit's linked elements and chat API while keeping its three-function public API local to the caller.

Every client that runs code requiring liby4slots must have the module installed in its local DU Lua directory.

## Public API

### `liby4slots.getLinkedElements()`

Returns every directly linked element object in Control Unit link order.

### `liby4slots.getElementsByItemId(itemId)`

Returns every directly linked element whose integer `getItemId()` equals `itemId`. Results follow Control Unit link order.

```lua
local elements = liby4slots.getElementsByItemId(itemId)

for _, element in ipairs(elements) do
    system.print(element.getName())
end
```

### `liby4slots.printLinkedElements()`

Cycles through all linked elements and prints one chat line per element:

```text
[l4s] slot#5 itemId=2702446443 class=Industry1 name="Basic Electronics industry m [913]"
```

## Test Lua configuration

After installing the module, generate and copy the test configuration:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

Paste it through **Paste Lua configuration from clipboard** on a Programming Board.
