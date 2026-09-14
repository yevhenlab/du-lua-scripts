-- Registers optional location catalogs and maps their named lists to standard DU parents.
return {
    modules = {
        {
            label = "Settlers",
            module = "arn/locations-settlers",
            attachments = {
                { parentId = 2, sourceKey = "alioth" },
                { parentId = 27, sourceKey = "havenOutposts" },
                { parentId = 100210, sourceKey = "institutes" }
            }
        },
        {
            label = "Example",
            module = "arn/locations-example",
            attachments = {
                { parentId = 100210, sourceKey = "institutesExamples" },
                { parentId = 2, sourceKey = "planetoidExamples" }
            }
        }
    }
}