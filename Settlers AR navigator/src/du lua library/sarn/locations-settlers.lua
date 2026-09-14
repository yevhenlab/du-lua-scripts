-- SARN location data maintained specifically for Settlers server destinations.
-- Settlers outposts and other custom public locations belong in this data module.
return {
    locations = {
        {
            name = "Outposts",
            label = "Settlers outposts",
            type = "group",
            kind = "location-group",
            children = {
                {
                    name = "Loaded Outpost",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,37.1186,127.1793,84.0775}",
                    owner = nil
                },
                {
                    name = "Outpost Pilot",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,-38.7040,104.0518,14.5254}",
                    owner = nil
                },
                {
                    name = "Outpost Platform",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,-35.9356,179.2421,33.3149}",
                    owner = nil
                },
                {
                    name = "Outpost Station",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,-38.0879,-89.9850,18.9140}",
                    owner = nil
                },
                {
                    name = "Outpost Train",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,38.5003,36.6209,53.2553}",
                    owner = nil
                },
                {
                    name = "Outpost Tri",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,-41.9946,-24.8714,33.3484}",
                    owner = nil
                },
                {
                    name = "Outpost Valiant",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,32.9666,-47.1015,4.2835}",
                    owner = nil
                },
                {
                    name = "Outpost Villa",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,-42.8144,45.6020,20.2540}",
                    owner = nil
                },
                {
                    name = "Outpost Wave",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,24.8495,75.8674,6.3104}",
                    owner = nil
                },
                {
                    name = "YOS Legacy Outpost",
                    label = "Settlers outpost",
                    kind = "outpost",
                    type = "constructStatic",
                    coordinate = "::pos{0,27,34.8766,-142.4270,26.6025}",
                    owner = nil
                }
            }
        }
    },
    alioth = {
        {
            name = "1K - Design",
            label = "Settlers player base",
            kind = "base",
            type = "constructStatic",
            coordinate = "::pos{0,2,28.1481,92.9856,127.2590}",
            id = 1040035,
            coreSize = "L",
            owner = "unknown"
        },
        {
            name = "Alioth Market 0",
            label = "Market",
            kind = "market",
            type = "constructStatic",
            coordinate = "::pos{0,2,30.3401,95.8262,224.1425}",
            id = 1001108,
            coreSize = "XL",
            owner = "Aphelia",
            children = {
                {
                    name = "Alioth 0 Planet Shuttles",
                    label = "Market 0 planet shuttles",
                    kind = "shuttle",
                    type = "constructStatic",
                    coordinate = "::pos{0,2,30.2538,95.8300,240.2862}",
                    id = 1008131,
                    coreSize = "L",
                    owner = "Aphelia"
                },
                {
                    name = "Alioth Market 0 Park 1",
                    label = "Market 0 parking",
                    kind = "parking",
                    type = "constructStatic",
                    coordinate = "::pos{0,2,30.3361,95.7051,213.3531}",
                    id = 1001159,
                    coreSize = "XL",
                    owner = "Aphelia"
                },
                {
                    name = "Alioth Market 0 Park 2",
                    label = "Market 0 parking",
                    kind = "parking",
                    type = "constructStatic",
                    coordinate = "::pos{0,2,30.4460,95.8215,214.3583}",
                    id = 1001160,
                    coreSize = "XL",
                    owner = "Aphelia"
                },
                {
                    name = "Alioth Market 0 Park 3",
                    label = "Market 0 parking",
                    kind = "parking",
                    type = "constructStatic",
                    coordinate = "::pos{0,2,30.3442,95.9474,213.3531}",
                    id = 1001363,
                    coreSize = "XL",
                    owner = "Aphelia"
                }
            }
        },
        {
            name = "Neon Abyss Parking",
            label = "Settlers parking",
            kind = "parking",
            type = "constructStatic",
            coordinate = "::pos{0,2,29.8821,94.5593,446.0808}",
            id = 1028126,
            coreSize = "XL",
            owner = "Aphelia"
        },
        {
            name = "Settlers Honeycomb",
            label = "Settlers Institute location",
            kind = "location",
            type = "constructStatic",
            coordinate = "::pos{0,2,29.4206,94.7910,265.5872}",
            id = 1052866,
            coreSize = "L",
            owner = nil,
            children = {
                {
                    name = "Parking spots",
                    label = "Settlers Honeycomb parking",
                    type = "group",
                    kind = "location-group",
                    children = {
                        {
                            name = "Parking Spot 1",
                            label = "Landing Pad Honeycomb Library",
                            kind = "parking",
                            type = "constructStatic",
                            coordinate = "::pos{0,2,29.3815,94.8736,301.6822}",
                            id = 1052874,
                            coreSize = "L",
                            owner = "Aphelia"
                        },
                        {
                            name = "Parking Spot 2",
                            label = "Landing Pad Honeycomb Library",
                            kind = "parking",
                            type = "constructStatic",
                            coordinate = "::pos{0,2,29.3260,94.8924,302.0701}",
                            id = 1052873,
                            coreSize = "L",
                            owner = "Aphelia"
                        },
                        {
                            name = "Parking Spot 3",
                            label = "Landing Pad Honeycomb Library",
                            kind = "parking",
                            type = "constructStatic",
                            coordinate = "::pos{0,2,29.3095,94.8287,301.9837}",
                            id = 1052871,
                            coreSize = "L",
                            owner = "Aphelia"
                        },
                        {
                            name = "Parking Spot 4",
                            label = "Landing Pad Honeycomb Library",
                            kind = "parking",
                            type = "constructStatic",
                            coordinate = "::pos{0,2,29.2931,94.7651,302.0265}",
                            id = 1052872,
                            coreSize = "L",
                            owner = "Aphelia"
                        },
                        {
                            name = "Parking Spot 5",
                            label = "Landing Pad Honeycomb Library",
                            kind = "parking",
                            type = "constructStatic",
                            coordinate = "::pos{0,2,29.3486,94.7461,301.6387}",
                            id = 1052876,
                            coreSize = "L",
                            owner = "Aphelia"
                        }
                    }
                }
            }
        }
    },
    institutes = {
        {
            name = "Hadron Quantum Teleporter",
            label = "Settlers Institute location",
            kind = "teleporter",
            type = "constructStatic",
            coordinate = "::pos{0,2,29.0677,95.2200,295.6887}",
            id = 1038443,
            coreSize = "S",
            owner = nil
        }
    }
}
