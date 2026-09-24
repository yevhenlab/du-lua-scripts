-- Registers optional location catalogs. Each module root declares its own parentId.
return {
    modules = {
        { label = "Settlers", module = "arn/locations-settlers" },
        { label = "Player constructs", module = "arn/locations-constructs" },
        { label = "Example", module = "arn/locations-example" }
    }
}
