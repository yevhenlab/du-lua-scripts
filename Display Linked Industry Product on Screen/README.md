# Display Linked Industry Product on Screen

This Dual Universe script shows an industry's current product on a linked screen.

The screen displays the product's:

- icon and name;
- type, tier, and size;
- mass and volume.

Colors are selected automatically based on the product type.

## Setup

1. Add `industry_product_display_library.lua` to the programming board's library filter.
2. Add `industry_product_display_on_start.lua` to the unit `onStart` filter.
3. Link an industry unit and a screen to two adjacent programming-board slots.
4. Start the programming board.

The industry and screen can be linked in either order:

```text
slot1: Industry    slot2: Screen
```

or:

```text
slot1: Screen      slot2: Industry
```

Repeat the same pattern for additional pairs. Each pair can use either order.

Unrelated linked elements are skipped. For example, this still finds the pair:

```text
slot1: Other element
slot2: Industry
slot3: Screen
```

The script checks `slot1` through `slot100` and supports up to 50 industry-screen pairs.

## Important

Screens are updated once when the programming board starts. Restart the board after changing an industry's recipe or product.
