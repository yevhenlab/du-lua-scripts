# ARN module parentId migration chat

Date: 2026-09-24  
Scope: Compare the Construct Editor export with ARN location modules, decide how custom-module roots should attach, and migrate ARN to that format.

## Decisions

- Custom location modules return a nodes table keyed by descriptive names. The nodes wrapper stays so ARN can distinguish location roots from module metadata such as types and disabled.
- locations-registry.lua lists modules with optional label and module; it no longer declares attachments or sourceKey.
- Only a root under a custom module's nodes table needs parentId. It points to a node in the combined standard/custom catalog. Nested children infer their parent from nesting. Standard locations.lua entries keep their existing inline hierarchy.
- parentId is module data for root attachment. ARN's runtime parentIds are internal relationships and are not written on every node.
- Keep registry label; ARN shows it in the Source filter.
- Keep locations.lua as the standard catalog; it loads alongside custom root modules.
- For player construct exports: owner IDs 0, 1, and 2 produce owner = Aphelia; all other owner IDs omit owner, while ownerId and ownerType remain.
- Construct type mapping: static names containing mine, mining, or ore use mining; names containing outpost use outpost; other statics use construct; space constructs use spaceconstruct. Player location label and explicit icon stay omitted.

## Implemented

- Updated ARN's library.onStart.locationCatalog.lua to collect module roots, index standard and custom IDs, attach roots by parentId, preserve module source IDs/labels and module types/disabled, and warn about missing, ambiguous, cyclic, or unreachable roots.
- Simplified locations-registry.lua to module names and labels.
- Migrated locations-settlers.lua and locations-example.lua to top-level nodes maps with parentId on module roots.
- Updated the Construct Editor export policy: owner IDs 0/1/2 map to Aphelia, other IDs omit owner, and types follow the agreed static/space/name rules.
- Added locations-constructs.lua as a copy of the current Construct Editor export. The current data contains 66 static constructs: 24 mining, 6 outpost, 36 construct; two roots have no parentId and are skipped with warnings.
- Updated README and catalog/technical design docs. Rebuilt ar-navigator.generated.json.
- Kept standard locations.lua unchanged; it parses and loads with the new custom modules.

## Verification and caveats

- Lua 5.1 syntax checks passed for the loader, standard catalog, registry, Settlers, example, and construct modules.
- Runtime catalog initialization loaded 27 Settlers nodes and 64 parented construct nodes; a separate check confirmed a child module resolves a parent declared later in registry order.
- ARN's standard locations.lua contains an existing empty coordinate on Institutes, which emits a coordinate warning. It was not changed in this work.
- The two unparented roots in the construct snapshot are Static construct (ID 1144736) and AigarsLimAcan (ID 1193431). They need a parent assignment before ARN can load them.
- locations-constructs.lua is a snapshot; refresh it from the Construct Editor output when that output changes.
