-- SARN location data: explicit high-level planets and moons from the DU client atlas.
-- This is a data module. It does not inspect or generate locations at runtime.

return {
    kinds = {
        planet = { icon = "icon-planet" },
        moon = { icon = "icon-moon" },
        market = { icon = "icon-market" }
    },

    locations = {
        {
            name = "Madis",
            label = "Planet",
            kind = "planet",
            color = "255,150,70",
            coordinate = "::pos{0,0,17465536.00,22665536.00,-34464.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 1 },
            areaRadius = 44300.00,
            children = {
                {
                    name = "Madis Moon 1",
                    label = "Moon of Madis",
                    kind = "moon",
                    coordinate = "::pos{0,0,17448118.86,22966848.03,143079.98}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 10 },
                    areaRadius = 10000.00
                },
                {
                    name = "Madis Moon 2",
                    label = "Moon of Madis",
                    kind = "moon",
                    coordinate = "::pos{0,0,17194626.00,22243633.88,-214962.81}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 11 },
                    areaRadius = 12000.00
                },
                {
                    name = "Madis Moon 3",
                    label = "Moon of Madis",
                    kind = "moon",
                    coordinate = "::pos{0,0,17520617.44,22184726.90,-309986.22}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 12 },
                    areaRadius = 15000.00
                }
            }
        },
        {
            name = "Alioth",
            label = "Planet",
            kind = "planet",
            color = "70,220,255",
            coordinate = "::pos{0,0,-8.00,-8.00,-126303.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 2 },
            areaRadius = 126067.90,
            children = {
                {
                    name = "Sanctuary",
                    label = "Moon of Alioth",
                    kind = "moon",
                    icon = "icon-sanctuary-moon",
                    coordinate = "::pos{0,0,-1404834.53,562655.32,-285074.95}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 26 },
                    areaRadius = 83400.00
                },
                {
                    name = "Alioth Moon 1",
                    label = "Moon of Alioth",
                    kind = "moon",
                    coordinate = "::pos{0,0,457932.99,-1509009.24,115525.00}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 21 },
                    areaRadius = 30000.00
                },
                {
                    name = "Alioth Moon 4",
                    label = "Moon of Alioth",
                    kind = "moon",
                    coordinate = "::pos{0,0,-1692694.85,729681.81,-411465.62}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 22 },
                    areaRadius = 30330.00
                },
                {
                    name = "Haven",
                    label = "Moon of Alioth",
                    kind = "moon",
                    icon = "icon-sanctuary-moon",
                    coordinate = "::pos{0,0,-1205152.02,1124841.79,-2638867.62}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 27 },
                    areaRadius = 83443.02,
                    childrenModule = "sarn/locations-settlers",
                    children = {
                        {
                            name = "Haven 01",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,8.5484,-117.9288,223.3196}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 02",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,-12.7097,-163.9586,148.1083}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 03",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,9.9864,110.2546,320.5352}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 04",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,14.1401,43.4619,3.8171}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 05",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,-16.5686,-20.2231,6.8145}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 06",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,-7.4550,-71.8886,79.3384}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 07",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,46.1823,-19.4880,85.8835}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 08",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,-0.0006,0.0001,-6.2526}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 09",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,-41.7771,-52.1732,76.3726}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 10",
                            label = "Market district",
                            kind = "market",
                            icon = "icon-market-district",
                            coordinate = "::pos{0,27,-51.4445,55.4728,105.3451}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 11",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,56.9906,94.9863,78.9619}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 12",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,21.7438,157.0900,236.6085}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 13",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,50.7013,-121.9409,9.7124}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 14",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,-49.8660,125.9217,14.7111}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 15",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,28.4687,11.0308,32.7180}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 16",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,16.8827,65.2548,39.1318}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 17",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,16.1746,-40.8993,33.2707}",
                            ownerId = nil
                        },
                        {
                            name = "Haven 18",
                            label = "Market",
                            kind = "market",
                            icon = "icon-market",
                            coordinate = "::pos{0,27,-3.8036,-13.6867,28.8962}",
                            ownerId = nil
                        }
                    }
                }
            }
        },
        {
            name = "Thades",
            label = "Planet",
            kind = "planet",
            color = "255,190,80",
            coordinate = "::pos{0,0,29165536.00,10865536.00,65536.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 3 },
            areaRadius = 49000.00,
            children = {
                {
                    name = "Thades Moon 1",
                    label = "Moon of Thades",
                    kind = "moon",
                    coordinate = "::pos{0,0,29214403.49,10907080.70,433861.28}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 30 },
                    areaRadius = 14000.00
                },
                {
                    name = "Thades Moon 2",
                    label = "Moon of Thades",
                    kind = "moon",
                    coordinate = "::pos{0,0,29404194.34,10432766.60,19553.82}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 31 },
                    areaRadius = 15000.00
                }
            }
        },
        {
            name = "Talemai",
            label = "Planet",
            kind = "planet",
            color = "150,205,255",
            coordinate = "::pos{0,0,-13234464.00,55765536.00,465536.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 4 },
            areaRadius = 57500.00,
            children = {
                {
                    name = "Talemai Moon 1",
                    label = "Moon of Talemai",
                    kind = "moon",
                    coordinate = "::pos{0,0,-13058408.39,55781856.76,740177.66}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 42 },
                    areaRadius = 15000.00
                },
                {
                    name = "Talemai Moon 2",
                    label = "Moon of Talemai",
                    kind = "moon",
                    coordinate = "::pos{0,0,-13503090.34,55594324.49,769836.53}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 40 },
                    areaRadius = 12000.00
                },
                {
                    name = "Talemai Moon 3",
                    label = "Moon of Talemai",
                    kind = "moon",
                    coordinate = "::pos{0,0,-12800514.62,55700257.46,325207.84}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 41 },
                    areaRadius = 11000.00
                }
            }
        },
        {
            name = "Sicari",
            label = "Planet",
            kind = "planet",
            color = "255,220,100",
            coordinate = "::pos{0,0,52765536.00,27165536.00,52065536.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 6 },
            areaRadius = 51100.00
        },
        {
            name = "Sinnen",
            label = "Planet",
            kind = "planet",
            color = "210,145,255",
            coordinate = "::pos{0,0,52718347.17,26962117.31,51830774.69}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 7 },
            areaRadius = 54950.00,
            children = {
                {
                    name = "Sinnen Moon 1",
                    label = "Moon of Sinnen",
                    kind = "moon",
                    coordinate = "::pos{0,0,52416510.67,26795577.16,51893332.65}",
                    ownerId = nil,
                    atlasBody = { systemId = 0, bodyId = 70 },
                    areaRadius = 0.00
                }
            }
        },
        {
            name = "Teoma",
            label = "Planet",
            kind = "planet",
            color = "95,235,190",
            coordinate = "::pos{0,0,80865536.00,54665536.00,-934464.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 8 },
            areaRadius = 62000.00
        },
        {
            name = "Jago",
            label = "Planet",
            kind = "planet",
            color = "90,150,255",
            coordinate = "::pos{0,0,-94134464.00,12765536.00,-3634464.00}",
            ownerId = nil,
            atlasBody = { systemId = 0, bodyId = 9 },
            areaRadius = 61590.00
        }
    }
}
