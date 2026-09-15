-- ARN location data: planetoids and assigned Aphelia constructs.
-- Generated offline from the DU atlas and aphelia-construct-hierarchy.json; no runtime data inspection.
local heliosPlanets = {{
    id = 2,
    name = "Alioth",
    label = "Planet",
    type = "planet",
    color = "70,220,255",
    coordinate = "::pos{0,0,-8,-8,-126303}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 2
    },
    radius = 126067.90,
    atmosphereRadius = 132460.00,
    areaRadius = 126067.90,
    children = {{
        id = 21,
        name = "Alioth Moon 1",
        label = "Moon of Alioth",
        type = "moon",
        coordinate = "::pos{0,0,457932.99,-1509009.24,115525}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 21
        },
        radius = 30000.00,
        atmosphereRadius = 30000.00,
        areaRadius = 30000.00,
        children = {{
            id = 150211,
            name = "Market Alioth Moon I 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,21,1.9473,-111.5177,170.097}",
            owner = "Aphelia"
        }, {
            id = 150212,
            name = "Market Alioth Moon I 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,21,-1.9517,66.4785,79.896}",
            owner = "Aphelia"
        }}
    }, {
        id = 22,
        name = "Alioth Moon 4",
        label = "Moon of Alioth",
        type = "moon",
        coordinate = "::pos{0,0,-1692694.85,729681.81,-411465.62}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 22
        },
        radius = 30330.00,
        atmosphereRadius = 30330.00,
        areaRadius = 30330.00,
        children = {{
            id = 150221,
            name = "Market Alioth Moon IV 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,22,13.1025,-108.8957,21.9}",
            owner = "Aphelia"
        }, {
            id = 150222,
            name = "Market Alioth Moon IV 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,22,-32.2053,55.1574,14.684}",
            owner = "Aphelia"
        }}
    }, {
        id = 27,
        name = "Haven",
        label = "Moon of Alioth",
        type = "moon",
        icon = "icon-sanctuary-moon",
        coordinate = "::pos{0,0,-1205152.02,1124841.79,-2638867.62}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 27
        },
        radius = 83443.00,
        atmosphereRadius = 89870.00,
        areaRadius = 83443.00,
        children = {{
            name = "[01-10] Market Districts",
            label = "Haven market districts",
            type = "location-group",
            children = {{
                id = 100810,
                name = "Haven 01",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,8.5537,-117.9416,356.317}",
                owner = "Aphelia",
                children = {{
                    id = 100815,
                    name = "Haven 1 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,8.6883,-117.923,259.285}",
                    owner = "Aphelia"
                }, {
                    id = 101830,
                    name = "Haven 1 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,8.6461,-118.0284,258.922}",
                    owner = "Aphelia"
                }, {
                    id = 100811,
                    name = "Market Haven 01",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,8.5524,-117.932,243.133}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100820,
                name = "Haven 02",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-12.7155,-163.9458,281.105}",
                owner = "Aphelia",
                children = {{
                    id = 100825,
                    name = "Haven 2 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-12.8493,-163.9712,184.132}",
                    owner = "Aphelia"
                }, {
                    id = 102830,
                    name = "Haven 2 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-12.812,-163.8623,183.735}",
                    owner = "Aphelia"
                }, {
                    id = 100821,
                    name = "Market Haven 02",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-12.7138,-163.9555,167.922}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100830,
                name = "Haven 03",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,9.9927,110.2423,453.54}",
                owner = "Aphelia",
                children = {{
                    id = 100835,
                    name = "Haven 3 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,10.1249,110.2735,356.654}",
                    owner = "Aphelia"
                }, {
                    id = 103830,
                    name = "Haven 3 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,10.0926,110.1643,356.218}",
                    owner = "Aphelia"
                }, {
                    id = 100831,
                    name = "Market Haven 03",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,9.9906,110.2518,340.357}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100840,
                name = "Haven 04",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,14.1379,43.448,136.823}",
                owner = "Aphelia",
                children = {{
                    id = 100845,
                    name = "Haven 4 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,14.2624,43.3908,39.85}",
                    owner = "Aphelia"
                }, {
                    id = 104830,
                    name = "Haven 4 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,14.1714,43.3222,39.453}",
                    owner = "Aphelia"
                }, {
                    id = 100841,
                    name = "Market Haven 04",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,14.1418,43.457,23.64}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100850,
                name = "Haven 05",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-16.3667,-11.4387,345.264}",
                owner = "Aphelia",
                children = {{
                    id = 100855,
                    name = "Haven 5 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-16.3231,-11.5729,248.29}",
                    owner = "Aphelia"
                }, {
                    id = 105830,
                    name = "Haven 5 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-16.4334,-11.5503,247.893}",
                    owner = "Aphelia"
                }, {
                    id = 100851,
                    name = "Market Haven 05",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-16.3576,-11.4355,232.081}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100860,
                name = "Haven 06",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,10.5751,-68.7285,470.399}",
                owner = "Aphelia",
                children = {{
                    id = 100865,
                    name = "Haven 6 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,10.6521,-68.8427,374.579}",
                    owner = "Aphelia"
                }, {
                    id = 106830,
                    name = "Haven 6 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,10.5401,-68.8514,372.286}",
                    owner = "Aphelia"
                }, {
                    id = 100861,
                    name = "Market Haven 06",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,10.5839,-68.723,357.364}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100870,
                name = "Haven 07",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,57.8479,-5.7638,581.067}",
                owner = "Aphelia",
                children = {{
                    id = 100875,
                    name = "Haven 7 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,57.7613,-5.5681,484.093}",
                    owner = "Aphelia"
                }, {
                    id = 107830,
                    name = "Haven 7 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,57.8717,-5.5316,483.696}",
                    owner = "Aphelia"
                }, {
                    id = 100871,
                    name = "Market Haven 07",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,57.8405,-5.7752,467.884}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100880,
                name = "Haven 08",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,61.9156,178.1912,673.843}",
                owner = "Aphelia",
                children = {{
                    id = 100885,
                    name = "Haven 8 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,61.9806,178.4438,576.869}",
                    owner = "Aphelia"
                }, {
                    id = 108830,
                    name = "Haven 8 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,62.0392,178.2403,576.472}",
                    owner = "Aphelia"
                }, {
                    id = 100881,
                    name = "Market Haven 08",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,61.9073,178.201,560.66}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100890,
                name = "Haven 09",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-58.8871,84.9585,461.439}",
                owner = "Aphelia",
                children = {{
                    id = 100895,
                    name = "Haven 9 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-58.9453,84.721,364.47}",
                    owner = "Aphelia"
                }, {
                    id = 109830,
                    name = "Haven 9 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-59.0094,84.8999,364.097}",
                    owner = "Aphelia"
                }, {
                    id = 100891,
                    name = "Market Haven 09",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-58.8785,84.9505,348.254}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100900,
                name = "Haven 10",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-54.9885,-104.738,211.868}",
                owner = "Aphelia",
                children = {{
                    id = 100905,
                    name = "Haven 10 Shuttles Landing",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-54.9776,-104.9745,114.895}",
                    owner = "Aphelia"
                }, {
                    id = 110830,
                    name = "Haven 10 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-55.0796,-104.891,114.497}",
                    owner = "Aphelia"
                }, {
                    id = 100901,
                    name = "Market Haven 10",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,27,-54.9789,-104.7367,98.685}",
                    owner = "Aphelia"
                }}
            }}
        }, {
            name = "[11-20] Markets only",
            label = "Haven markets without districts",
            type = "location-group",
            children = {{
                id = 150271,
                name = "Market Haven 11",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,28.3052,179.1995,25.047}",
                owner = "Aphelia"
            }, {
                id = 150272,
                name = "Market Haven 12",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,46.6642,-96.0428,26.661}",
                owner = "Aphelia"
            }, {
                id = 150273,
                name = "Market Haven 13",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,30.3116,-4.8462,29.572}",
                owner = "Aphelia"
            }, {
                id = 150274,
                name = "Market Haven 14",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,45.737,74.3893,5.995}",
                owner = "Aphelia"
            }, {
                id = 150275,
                name = "Market Haven 15",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-27.6946,139.2916,29.772}",
                owner = "Aphelia"
            }, {
                id = 150276,
                name = "Market Haven 16",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-26.749,-123.8432,35.977}",
                owner = "Aphelia"
            }, {
                id = 150277,
                name = "Market Haven 17",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-26.4229,-61.132,24.086}",
                owner = "Aphelia"
            }, {
                id = 150278,
                name = "Market Haven 18",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-27.3222,21.867,32.596}",
                owner = "Aphelia"
            }, {
                id = 150279,
                name = "Market Haven 19",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-85.424,37.1735,254.918}",
                owner = "Aphelia"
            }, {
                id = 150270,
                name = "Market Haven 20",
                type = "construct",
                label = "",
                coordinate = "::pos{0,27,-24.6036,69.1031,93.95}",
                owner = "Aphelia"
            }}
        }}
    }, {
        id = 26,
        name = "Sanctuary",
        label = "Moon of Alioth",
        type = "moon",
        icon = "icon-sanctuary-moon",
        coordinate = "::pos{0,0,-1404834.53,562655.32,-285074.95}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 26
        },
        radius = 83400.00,
        atmosphereRadius = 89550.00,
        areaRadius = 83400.00,
        children = {{
            name = "[11-20] Markets only",
            label = "Sanctuary markets without districts",
            type = "location-group",
            children = {{
                id = 150261,
                name = "Market Sanctuary 11",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,41.8898,3.742,31.957}",
                owner = "Aphelia"
            }, {
                id = 150262,
                name = "Market Sanctuary 12",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,46.5658,-68.0318,311.513}",
                owner = "Aphelia"
            }, {
                id = 150263,
                name = "Market Sanctuary 13",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,11.4787,-33.0602,70.02}",
                owner = "Aphelia"
            }, {
                id = 150264,
                name = "Market Sanctuary 14",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-56.951,13.422,68.659}",
                owner = "Aphelia"
            }, {
                id = 150265,
                name = "Market Sanctuary 15",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-37.7955,152.0305,39.203}",
                owner = "Aphelia"
            }, {
                id = 150266,
                name = "Market Sanctuary 16",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,40.8329,58.7721,467.545}",
                owner = "Aphelia"
            }, {
                id = 150267,
                name = "Market Sanctuary 17",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,5.8677,130.1461,60.143}",
                owner = "Aphelia"
            }, {
                id = 150268,
                name = "Market Sanctuary 18",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-30.1408,-120.235,405.214}",
                owner = "Aphelia"
            }, {
                id = 150269,
                name = "Market Sanctuary 19",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,13.3629,-145.8962,61.91}",
                owner = "Aphelia"
            }, {
                id = 150260,
                name = "Market Sanctuary 20",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-24.6765,-162.1089,94.361}",
                owner = "Aphelia"
            }}
        }, {
            name = "[01-10] Market Districts",
            label = "Sanctuary market districts",
            type = "location-group",
            children = {{
                id = 100510,
                name = "Sanctuary 01",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-63.5505,-159.5147,199.457}",
                owner = "Aphelia",
                children = {{
                    id = 100511,
                    name = "Market Sanctuary 01",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-63.5562,-159.4971,86.289}",
                    owner = "Aphelia"
                }, {
                    id = 101530,
                    name = "Sanctuary 01 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-63.4286,-159.5897,101.691}",
                    owner = "Aphelia"
                }, {
                    id = 100515,
                    name = "Sanctuary 1 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-63.4393,-159.3388,102.066}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100520,
                name = "Sanctuary 02",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,1.3717,-103.951,227.056}",
                owner = "Aphelia",
                children = {{
                    id = 100521,
                    name = "Market Sanctuary 02",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,1.3797,-103.9571,113.949}",
                    owner = "Aphelia"
                }, {
                    id = 102530,
                    name = "Sanctuary 02 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,1.2457,-103.9532,128.479}",
                    owner = "Aphelia"
                }, {
                    id = 100525,
                    name = "Sanctuary 2 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,1.2876,-104.0578,129.317}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100530,
                name = "Sanctuary 03",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,83.4554,55.229,171.828}",
                owner = "Aphelia",
                children = {{
                    id = 100531,
                    name = "Market Sanctuary 03",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,83.4626,55.2809,58.582}",
                    owner = "Aphelia"
                }, {
                    id = 103530,
                    name = "Sanctuary 03 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,83.4379,54.1262,75.969}",
                    owner = "Aphelia"
                }, {
                    id = 100535,
                    name = "Sanctuary 3 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,83.5481,54.34,76.25}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100540,
                name = "Sanctuary 04",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-5.9727,61.2495,195.466}",
                owner = "Aphelia",
                children = {{
                    id = 100541,
                    name = "Market Sanctuary 04",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-5.963,61.2505,82.303}",
                    owner = "Aphelia"
                }, {
                    id = 104530,
                    name = "Sanctuary 04 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-6.0617,61.1592,97.816}",
                    owner = "Aphelia"
                }, {
                    id = 100545,
                    name = "Sanctuary 4 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-5.9586,61.1133,98.362}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100550,
                name = "Sanctuary 05",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-10.5331,0.4796,141.729}",
                owner = "Aphelia",
                children = {{
                    id = 100551,
                    name = "Market Sanctuary 05",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-10.5262,0.487,28.614}",
                    owner = "Aphelia"
                }, {
                    id = 105530,
                    name = "Sanctuary 05 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-10.5391,0.3511,44.011}",
                    owner = "Aphelia"
                }, {
                    id = 100555,
                    name = "Sanctuary 5 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-10.4318,0.3865,45.312}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100560,
                name = "Sanctuary 06",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,12.2004,169.9148,145.539}",
                owner = "Aphelia",
                children = {{
                    id = 100561,
                    name = "Market Sanctuary 06",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,12.2027,169.9053,32.336}",
                    owner = "Aphelia"
                }, {
                    id = 106530,
                    name = "Sanctuary 06 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,12.0967,169.9893,48.666}",
                    owner = "Aphelia"
                }, {
                    id = 100565,
                    name = "Sanctuary 6 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,12.0689,169.8775,49.053}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100570,
                name = "Sanctuary 07",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-32.5599,91.0703,175.955}",
                owner = "Aphelia",
                children = {{
                    id = 100571,
                    name = "Market Sanctuary 07",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-32.5658,91.0611,62.797}",
                    owner = "Aphelia"
                }, {
                    id = 107530,
                    name = "Sanctuary 07 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-32.5625,91.2202,78.128}",
                    owner = "Aphelia"
                }, {
                    id = 100575,
                    name = "Sanctuary 7 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-32.667,91.1701,78.639}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100580,
                name = "Sanctuary 08",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,50.191,-133.6966,156.592}",
                owner = "Aphelia",
                children = {{
                    id = 100581,
                    name = "Market Sanctuary 08",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,50.1822,-133.6898,43.444}",
                    owner = "Aphelia"
                }, {
                    id = 108530,
                    name = "Sanctuary 08 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,50.3142,-133.6524,58.767}",
                    owner = "Aphelia"
                }, {
                    id = 100585,
                    name = "Sanctuary 8 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,50.2515,-133.5057,59.451}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100590,
                name = "Sanctuary 09",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,-32.9404,-56.8215,130.593}",
                owner = "Aphelia",
                children = {{
                    id = 100591,
                    name = "Market Sanctuary 09",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-32.9461,-56.8308,17.414}",
                    owner = "Aphelia"
                }, {
                    id = 109530,
                    name = "Sanctuary 09 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-32.9475,-56.6709,33.204}",
                    owner = "Aphelia"
                }, {
                    id = 100595,
                    name = "Sanctuary 9 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,-33.0505,-56.7256,33.651}",
                    owner = "Aphelia"
                }}
            }, {
                id = 100600,
                name = "Sanctuary 10",
                type = "construct",
                label = "",
                coordinate = "::pos{0,26,41.5185,112.0797,134.115}",
                owner = "Aphelia",
                children = {{
                    id = 100601,
                    name = "Market Sanctuary 10",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,41.5125,112.0899,20.935}",
                    owner = "Aphelia"
                }, {
                    id = 100605,
                    name = "Sanctuary 10 Shuttles",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,41.6253,112.193,37.171}",
                    owner = "Aphelia"
                }, {
                    id = 110530,
                    name = "Sanctuary 10 UEF Store",
                    type = "construct",
                    label = "",
                    coordinate = "::pos{0,26,41.6422,112.0438,36.729}",
                    owner = "Aphelia"
                }}
            }}
        }}
    }, {
        id = 180200,
        name = "Alioth Exchange",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,24.3989,99.3716,211.537}",
        owner = "Aphelia",
        children = {{
            id = 180202,
            name = "Alioth Exchange Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.3994,99.3716,147.294}",
            owner = "Aphelia"
        }, {
            name = "Halls",
            label = "Alioth Exchange halls",
            type = "location-group",
            children = {{
                id = 180207,
                name = "Alioth Exchange Hall Blue 1",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.4562,99.3761,148.881}",
                owner = "Aphelia"
            }, {
                id = 180208,
                name = "Alioth Exchange Hall Blue 2",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.5141,99.3796,150.623}",
                owner = "Aphelia"
            }, {
                id = 180203,
                name = "Alioth Exchange Hall Green 1",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.4024,99.3102,147.586}",
                owner = "Aphelia"
            }, {
                id = 180204,
                name = "Alioth Exchange Hall Green 2",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.4056,99.2466,148.013}",
                owner = "Aphelia"
            }, {
                id = 180209,
                name = "Alioth Exchange Hall Red 1",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.3424,99.3692,145.829}",
                owner = "Aphelia"
            }, {
                id = 180210,
                name = "Alioth Exchange Hall Red 2",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.2845,99.3657,144.469}",
                owner = "Aphelia"
            }, {
                id = 180205,
                name = "Alioth Exchange Hall Yellow 1",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.3962,99.4351,147.121}",
                owner = "Aphelia"
            }, {
                id = 180206,
                name = "Alioth Exchange Hall Yellow 2",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.393,99.4987,147.077}",
                owner = "Aphelia"
            }}
        }, {
            name = "Parking",
            label = "Alioth Exchange parking",
            type = "location-group",
            children = {{
                id = 180211,
                name = "Alioth Exchange Landing 01",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.4081,99.1614,108.115}",
                owner = "Aphelia"
            }, {
                id = 180212,
                name = "Alioth Exchange Landing 02",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.3908,99.5835,106.354}",
                owner = "Aphelia"
            }, {
                id = 180213,
                name = "Alioth Exchange Landing 03",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.2072,99.3631,102.217}",
                owner = "Aphelia"
            }, {
                id = 180214,
                name = "Alioth Exchange Landing 04",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,24.591,99.3819,132.386}",
                owner = "Aphelia"
            }}
        }, {
            id = 180201,
            name = "Alioth Exchange Pillar",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.3388,99.433,5.154}",
            owner = "Aphelia"
        }}
    }, {
        id = 100000,
        name = "Arkship",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,29.76053,95.4536,3745.104}",
        owner = "Aphelia",
        children = {{
            id = 100001,
            name = "Arkship_Startroom",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.7513,95.5243,3261.494}",
            owner = "Aphelia"
        }}
    }, {
        id = 100004,
        name = "Arkship Crater",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,29.7471,95.5488,203.328}",
        owner = "Aphelia"
    }, {
        id = 100110,
        name = "District 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,31.13,101.4843,380.699}",
        owner = "Aphelia",
        children = {{
            id = 101030,
            name = "District 01 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.1935,101.303,194.07}",
            owner = "Aphelia"
        }, {
            id = 100112,
            name = "District 1 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.2233,101.4089,221.843}",
            owner = "Aphelia"
        }, {
            id = 101002,
            name = "District 1 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.2434,101.4142,186.684}",
            owner = "Aphelia"
        }, {
            id = 100115,
            name = "District 1 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.2798,101.4234,199.614}",
            owner = "Aphelia"
        }, {
            id = 100111,
            name = "District 1 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.1416,101.3904,177.99}",
            owner = "Aphelia"
        }}
    }, {
        id = 100120,
        name = "District 02",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,24.5093,89.0736,544.403}",
        owner = "Aphelia",
        children = {{
            id = 102030,
            name = "District 02 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.495,89.0304,359.582}",
            owner = "Aphelia"
        }, {
            id = 100122,
            name = "District 2 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.6196,89.0999,384.024}",
            owner = "Aphelia"
        }, {
            id = 102002,
            name = "District 2 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.6298,89.1192,348.092}",
            owner = "Aphelia"
        }, {
            id = 100125,
            name = "District 2 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.6486,89.1547,359.612}",
            owner = "Aphelia"
        }, {
            id = 100121,
            name = "District 2 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.5761,89.0216,343.288}",
            owner = "Aphelia"
        }}
    }, {
        id = 100130,
        name = "District 03",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,35.54,89.0188,321.296}",
        owner = "Aphelia",
        children = {{
            id = 103030,
            name = "District 03 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.6631,89.1404,135.038}",
            owner = "Aphelia"
        }, {
            id = 100132,
            name = "District 3 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.5763,89.1511,162.753}",
            owner = "Aphelia"
        }, {
            id = 103002,
            name = "District 3 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.5664,89.1733,127.511}",
            owner = "Aphelia"
        }, {
            id = 100135,
            name = "District 3 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.5487,89.2136,140.291}",
            owner = "Aphelia"
        }, {
            id = 100131,
            name = "District 3 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.6144,89.06,119.22}",
            owner = "Aphelia"
        }}
    }, {
        id = 100140,
        name = "District 04",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,27.6144,99.6358,341.489}",
        owner = "Aphelia",
        children = {{
            id = 104030,
            name = "District 04 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,27.6795,99.8105,155.689}",
            owner = "Aphelia"
        }, {
            id = 100142,
            name = "District 4 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,27.594,99.7622,183.957}",
            owner = "Aphelia"
        }, {
            id = 104002,
            name = "District 4 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,27.5766,99.7747,149.107}",
            owner = "Aphelia"
        }, {
            id = 100145,
            name = "District 4 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,27.5453,99.7976,162.596}",
            owner = "Aphelia"
        }, {
            id = 100141,
            name = "District 4 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,27.6627,99.7095,138.853}",
            owner = "Aphelia"
        }}
    }, {
        id = 100150,
        name = "District 05",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,32.3833,86.686,509.202}",
        owner = "Aphelia",
        children = {{
            id = 105030,
            name = "District 05 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,32.3541,86.6948,324.147}",
            owner = "Aphelia"
        }, {
            id = 100152,
            name = "District 5 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,32.3375,86.8092,351.723}",
            owner = "Aphelia"
        }, {
            id = 105002,
            name = "District 5 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,32.318,86.8172,316.711}",
            owner = "Aphelia"
        }, {
            id = 100155,
            name = "District 5 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,32.2829,86.8317,329.909}",
            owner = "Aphelia"
        }, {
            id = 100151,
            name = "District 5 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,32.4153,86.7748,307.254}",
            owner = "Aphelia"
        }}
    }, {
        id = 100160,
        name = "District 06",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,35.8145,102.3049,322.053}",
        owner = "Aphelia",
        children = {{
            id = 106074,
            name = "District 06 Extra Parking 04",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.8399,102.3385,128.583}",
            owner = "Aphelia"
        }, {
            id = 100162,
            name = "District 6 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.7233,102.2214,163.51}",
            owner = "Aphelia"
        }, {
            id = 106002,
            name = "District 6 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.7211,102.1962,128.268}",
            owner = "Aphelia"
        }, {
            id = 100165,
            name = "District 6 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.7169,102.1505,141.049}",
            owner = "Aphelia"
        }, {
            id = 100161,
            name = "District 6 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.7343,102.3231,119.977}",
            owner = "Aphelia"
        }, {
            id = 106075,
            name = "District 06 Extra Parking 05",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.6309,102.331,128.135}",
            owner = "Aphelia"
        }}
    }, {
        id = 100170,
        name = "District 07",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,22.1881,99.1991,335.498}",
        owner = "Aphelia",
        children = {{
            id = 107030,
            name = "District 07 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.2234,99.1775,150.031}",
            owner = "Aphelia"
        }, {
            id = 100172,
            name = "District 7 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.154,99.3161,176.955}",
            owner = "Aphelia"
        }, {
            id = 107002,
            name = "District 7 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.1354,99.3255,141.713}",
            owner = "Aphelia"
        }, {
            id = 100175,
            name = "District 7 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.1017,99.3428,154.493}",
            owner = "Aphelia"
        }, {
            id = 100171,
            name = "District 7 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.2284,99.2757,133.422}",
            owner = "Aphelia"
        }}
    }, {
        id = 100180,
        name = "District 08",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,21.2987,95.4182,459.622}",
        owner = "Aphelia",
        children = {{
            id = 108030,
            name = "District 08 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,21.3516,95.2472,274.186}",
            owner = "Aphelia"
        }, {
            id = 100182,
            name = "District 8 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,21.3874,95.3422,301.079}",
            owner = "Aphelia"
        }, {
            id = 108002,
            name = "District 8 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,21.4077,95.3456,265.837}",
            owner = "Aphelia"
        }, {
            id = 100185,
            name = "District 8 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,21.4446,95.3514,278.617}",
            owner = "Aphelia"
        }, {
            id = 100181,
            name = "District 8 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,21.3049,95.331,257.546}",
            owner = "Aphelia"
        }}
    }, {
        id = 100190,
        name = "District 09",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,28.7701,86.8363,394.49}",
        owner = "Aphelia",
        children = {{
            id = 109030,
            name = "District 09 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.9362,86.863,209}",
            owner = "Aphelia"
        }, {
            id = 100192,
            name = "District 9 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8555,86.9217,235.948}",
            owner = "Aphelia"
        }, {
            id = 109002,
            name = "District 9 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8559,86.9451,200.706}",
            owner = "Aphelia"
        }, {
            id = 100195,
            name = "District 9 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8571,86.9877,213.486}",
            owner = "Aphelia"
        }, {
            id = 100191,
            name = "District 9 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8511,86.8268,192.414}",
            owner = "Aphelia"
        }}
    }, {
        id = 100200,
        name = "District 10",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,36.3456,92.9009,317.307}",
        owner = "Aphelia",
        children = {{
            id = 110030,
            name = "District 10 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.4598,93.0367,131.06}",
            owner = "Aphelia"
        }, {
            id = 100202,
            name = "District 10 Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.3724,93.0379,158.764}",
            owner = "Aphelia"
        }, {
            id = 110002,
            name = "District 10 Center Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.361,93.0592,123.523}",
            owner = "Aphelia"
        }, {
            id = 100205,
            name = "District 10 Moon Shuttles",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.3404,93.0979,136.303}",
            owner = "Aphelia"
        }, {
            id = 100201,
            name = "District 10 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.4167,92.9503,115.231}",
            owner = "Aphelia"
        }}
    }, {
        id = 120415,
        name = "Guardians of Alioth Odysseus Alpha",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,31.8913,95.4387,314.76}",
        owner = "Aphelia",
        children = {{
            id = 120417,
            name = "BigEdge RD Temple",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.915,95.2818,284.259}",
            owner = "Aphelia"
        }, {
            id = 120420,
            name = "Gallia Gemina Telescope",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.8477,95.1698,300.059}",
            owner = "Aphelia"
        }, {
            name = "Gallia Gemina Tour Palaces",
            label = "Guardians tour palaces",
            type = "location-group",
            children = {{
                id = 120408,
                name = "Gallia Gemina Tour Palace W01",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.908,95.7078,784.603}",
                owner = "Aphelia"
            }, {
                id = 120409,
                name = "Gallia Gemina Tour Palace W02",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9083,95.7077,656.861}",
                owner = "Aphelia"
            }, {
                id = 120410,
                name = "Gallia Gemina Tour Palace W03",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9082,95.7072,529.076}",
                owner = "Aphelia"
            }, {
                id = 120411,
                name = "Gallia Gemina Tour Palace W04",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9083,95.7068,401.825}",
                owner = "Aphelia"
            }, {
                id = 120412,
                name = "Gallia Gemina Tour Palace W05",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9082,95.7065,274.089}",
                owner = "Aphelia"
            }}
        }, {
            id = 120413,
            name = "Geo Air Space Museum N",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.8317,95.5609,302.019}",
            owner = "Aphelia"
        }, {
            name = "Outpost Museum stands",
            label = "Guardians museum stands",
            type = "location-group",
            children = {{
                id = 120466,
                name = "Outpost Museum stand 01",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.5091,95.4862,91.756}",
                owner = "Aphelia"
            }, {
                id = 120467,
                name = "Outpost Museum stand 02",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,32.0602,95.5451,128.661}",
                owner = "Aphelia"
            }, {
                id = 120468,
                name = "Outpost Museum stand 03",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9223,95.8053,137.188}",
                owner = "Aphelia"
            }, {
                id = 120469,
                name = "Outpost Museum stand 04",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9096,95.3453,119.336}",
                owner = "Aphelia"
            }, {
                id = 120473,
                name = "Outpost Museum stand 08",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.8619,95.2672,103.953}",
                owner = "Aphelia"
            }, {
                id = 120474,
                name = "Outpost Museum stand 09",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,32.0747,95.4318,124.668}",
                owner = "Aphelia"
            }, {
                id = 120475,
                name = "Outpost Museum stand 10",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.7307,95.5988,120.396}",
                owner = "Aphelia"
            }, {
                id = 120476,
                name = "Outpost Museum stand 11",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.7863,95.6853,262.845}",
                owner = "Aphelia"
            }, {
                id = 120477,
                name = "Outpost Museum stand 12",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.8328,95.715,264.241}",
                owner = "Aphelia"
            }, {
                id = 120478,
                name = "Outpost Museum stand 13",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9013,95.6178,261.487}",
                owner = "Aphelia"
            }, {
                id = 120479,
                name = "Outpost Museum stand 14",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.7287,95.6952,249.475}",
                owner = "Aphelia"
            }, {
                id = 120480,
                name = "Outpost Museum stand 15",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.6329,95.5168,214.781}",
                owner = "Aphelia"
            }, {
                id = 120481,
                name = "Outpost Museum stand 16",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.6115,95.3172,256.237}",
                owner = "Aphelia"
            }, {
                id = 120482,
                name = "Outpost Museum stand 17",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.916,95.2817,251.426}",
                owner = "Aphelia"
            }, {
                id = 120483,
                name = "Outpost Museum stand 18",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9863,95.2848,253.022}",
                owner = "Aphelia"
            }, {
                id = 120484,
                name = "Outpost Museum stand 19",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9221,95.3541,255.311}",
                owner = "Aphelia"
            }}
        }, {
            name = "UEF Outpost Museums",
            label = "Guardians UEF museums",
            type = "location-group",
            children = {{
                id = 120400,
                name = "UEF Outpost Museum 1",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.8926,95.2025,254.398}",
                owner = "Aphelia"
            }, {
                id = 120401,
                name = "UEF Outpost Museum 2",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9354,95.2508,275.092}",
                owner = "Aphelia"
            }, {
                id = 120402,
                name = "UEF Outpost Museum 3",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9569,95.3172,274.99}",
                owner = "Aphelia"
            }, {
                id = 120403,
                name = "UEF Outpost Museum 4",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9577,95.3851,274.897}",
                owner = "Aphelia"
            }, {
                id = 120404,
                name = "UEF Outpost Museum 5",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9456,95.4525,274.858}",
                owner = "Aphelia"
            }, {
                id = 120405,
                name = "UEF Outpost Museum 6",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.9225,95.5209,274.9}",
                owner = "Aphelia"
            }, {
                id = 120406,
                name = "UEF Outpost Museum 7",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.8699,95.5882,274.997}",
                owner = "Aphelia"
            }, {
                id = 120407,
                name = "UEF Outpost Museum 8",
                type = "construct",
                label = "",
                coordinate = "::pos{0,2,31.8704,95.6489,340.612}",
                owner = "Aphelia"
            }}
        }}
    }, {
        id = 100210,
        name = "Institutes",
        type = "construct",
        label = "",
        coordinate = "", -- ::pos{0,2,29.0509,95.1092,475.123}
        owner = "Aphelia",
        children = {{
            id = 100218,
            name = "Construction and Mining Institute",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8283,95.1252,287.157}",
            owner = "Aphelia"
        }, {
            id = 100211,
            name = "District 11 Parking",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.025,95.1975,273.064}",
            owner = "Aphelia"
        }, {
            id = 100214,
            name = "District 11 Plaza",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8882,95.1345,276.49}",
            owner = "Aphelia"
        }, {
            id = 100219,
            name = "Industry and Community Institute",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.8986,95.0645,286.149}",
            owner = "Aphelia"
        }, {
            id = 100212,
            name = "Institute Center",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.9476,95.1627,316.452}",
            owner = "Aphelia"
        }, {
            id = 100216,
            name = "Military and Piloting Institute",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.882,95.2039,286.416}",
            owner = "Aphelia"
        }}
    }, {
        id = 150021,
        name = "Market Alioth 11",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,-1.0753,178.5098,70.445}",
        owner = "Aphelia"
    }, {
        id = 150022,
        name = "Market Alioth 12",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,22.7149,-92.3096,167.322}",
        owner = "Aphelia"
    }, {
        id = 150023,
        name = "Market Alioth 13",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,-23.3806,-10.5469,179.319}",
        owner = "Aphelia"
    }, {
        id = 150024,
        name = "Market Alioth 14",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,-73.4709,101.3838,90.039}",
        owner = "Aphelia"
    }, {
        id = 150025,
        name = "Market Alioth 15",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,61.7767,27.8645,53.74}",
        owner = "Aphelia"
    }, {
        id = 150026,
        name = "Market Alioth 16",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,23.4432,114.4213,211.672}",
        owner = "Aphelia"
    }, {
        id = 150027,
        name = "Market Alioth 17",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,37.8676,64.1813,152.024}",
        owner = "Aphelia"
    }, {
        id = 150028,
        name = "Market Alioth 18",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,49.9369,-170.7628,62.655}",
        owner = "Aphelia"
    }, {
        id = 150029,
        name = "Market Alioth 19",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,-32.7351,76.3812,209.528}",
        owner = "Aphelia"
    }, {
        id = 150020,
        name = "Market Alioth 20",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,-35.1522,-95.1182,301.563}",
        owner = "Aphelia"
    }, {
        id = 101001,
        name = "Market Alioth District 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,30.3349,101.313,123.45}",
        owner = "Aphelia",
        children = {{
            id = 101003,
            name = "District 1 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,30.3362,101.3147,143.575}",
            owner = "Aphelia"
        }}
    }, {
        id = 102001,
        name = "Market Alioth District 02",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,24.448,88.0452,238.775}",
        owner = "Aphelia",
        children = {{
            id = 102003,
            name = "District 2 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,24.448,88.0472,258.9}",
            owner = "Aphelia"
        }}
    }, {
        id = 103001,
        name = "Market Alioth District 03",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,34.9737,87.3062,176.692}",
        owner = "Aphelia",
        children = {{
            id = 103003,
            name = "District 3 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,34.9733,87.3085,196.817}",
            owner = "Aphelia"
        }}
    }, {
        id = 104001,
        name = "Market Alioth District 04",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,28.3311,99.5187,166.381}",
        owner = "Aphelia",
        children = {{
            id = 104003,
            name = "District 4 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.3293,99.5181,186.506}",
            owner = "Aphelia"
        }}
    }, {
        id = 105001,
        name = "Market Alioth District 05",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,33.3898,87.3299,277.61}",
        owner = "Aphelia",
        children = {{
            id = 105003,
            name = "District 5 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,33.3881,87.3292,297.735}",
            owner = "Aphelia"
        }}
    }, {
        id = 106001,
        name = "Market Alioth District 06",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,36.0008,101.3528,220.543}",
        owner = "Aphelia",
        children = {{
            id = 106071,
            name = "District 06 Extra Parking 01",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.8318,101.5064,237.554}",
            owner = "Aphelia"
        }, {
            id = 106072,
            name = "District 06 Extra Parking 02",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.0847,101.2703,230.427}",
            owner = "Aphelia"
        }, {
            id = 106073,
            name = "District 06 Extra Parking 03",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.92,101.44,229.212}",
            owner = "Aphelia"
        }, {
            id = 106081,
            name = "District 06 Extra Parking Down 01",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.8703,101.3281,218.724}",
            owner = "Aphelia"
        }, {
            id = 106082,
            name = "District 06 Extra Parking Down 02",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.0509,101.4676,210.727}",
            owner = "Aphelia"
        }, {
            id = 106083,
            name = "District 06 Extra Parking Down 03",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.1328,101.5609,201.442}",
            owner = "Aphelia"
        }, {
            id = 106084,
            name = "District 06 Extra Parking Down 04",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,36.0191,101.604,200.81}",
            owner = "Aphelia"
        }, {
            id = 106030,
            name = "District 06 UEF Store",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.9406,101.2745,236.879}",
            owner = "Aphelia"
        }, {
            id = 106003,
            name = "District 6 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.9989,101.3533,240.657}",
            owner = "Aphelia"
        }}
    }, {
        id = 107001,
        name = "Market Alioth District 07",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,22.4989,98.147,232.961}",
        owner = "Aphelia",
        children = {{
            id = 107071,
            name = "District 07 Extra Parking 01",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.4898,98.0267,241.559}",
            owner = "Aphelia"
        }, {
            id = 107072,
            name = "District 07 Extra Parking 02",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.5888,98.2234,242.182}",
            owner = "Aphelia"
        }, {
            id = 107073,
            name = "District 07 Extra Parking 03",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.6882,98.1856,252.293}",
            owner = "Aphelia"
        }, {
            id = 107081,
            name = "District 07 Extra Parking Down 01",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.4058,98.2014,222.258}",
            owner = "Aphelia"
        }, {
            id = 107003,
            name = "District 7 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,22.497,98.1475,253.073}",
            owner = "Aphelia"
        }}
    }, {
        id = 108001,
        name = "Market Alioth District 08",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,21.2144,93.9659,251.55}",
        owner = "Aphelia",
        children = {{
            id = 108003,
            name = "District 8 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,21.2134,93.9676,271.675}",
            owner = "Aphelia"
        }}
    }, {
        id = 109001,
        name = "Market Alioth District 09",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,28.7122,85.6434,261.237}",
        owner = "Aphelia",
        children = {{
            id = 109003,
            name = "District 9 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,28.7111,85.6451,281.362}",
            owner = "Aphelia"
        }}
    }, {
        id = 110001,
        name = "Market Alioth District 10",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,35.9879,91.8441,190.635}",
        owner = "Aphelia",
        children = {{
            id = 110003,
            name = "District 10 Market Teleporter",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,35.988,91.8464,210.76}",
            owner = "Aphelia"
        }}
    }, {
        id = 200210,
        name = "Mission Alioth 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,29.4086,95.3913,237.814}",
        owner = "Aphelia",
        children = {{
            id = 200213,
            name = "Mission Alioth 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.4155,95.3894,254.66}",
            owner = "Aphelia"
        }, {
            id = 200212,
            name = "Mission Alioth 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.3862,95.3753,200.424}",
            owner = "Aphelia"
        }, {
            id = 200214,
            name = "Mission Alioth 01 Landing Extra 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.3803,95.3318,207.514}",
            owner = "Aphelia"
        }, {
            id = 200215,
            name = "Mission Alioth 01 Landing Extra 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.3531,95.3954,223.129}",
            owner = "Aphelia"
        }, {
            id = 200211,
            name = "Mission Alioth 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,29.4422,95.4025,287.36}",
            owner = "Aphelia"
        }, {
            name = "Parking spots",
            type = "location-group",
            label = "Mission Alioth parking",
            children = {{
                name = "Parking 1",
                type = "parking",
                label = "Mission Alioth parking",
                coordinate = "::pos{0,2,29.3863,95.3751,262.6128}",
                owner = "Aphelia"
            }, {
                name = "Parking 2",
                type = "parking",
                label = "Mission Alioth parking",
                coordinate = "::pos{0,2,29.3590,95.4113,259.9662}",
                owner = "Aphelia"
            }, {
                name = "Parking 3",
                type = "parking",
                label = "Mission Alioth parking",
                coordinate = "::pos{0,2,29.3940,95.3242,244.2558}",
                owner = "Aphelia"
            }, {
                name = "Parking 4",
                type = "parking",
                label = "Mission Alioth parking",
                coordinate = "::pos{0,2,29.3472,95.3768,230.7297}",
                owner = "Aphelia"
            }, {
                name = "Parking 5",
                type = "parking",
                label = "Mission Alioth parking",
                coordinate = "::pos{0,2,29.3645,95.3389,215.1427}",
                owner = "Aphelia"
            }}
        }}
    }, {
        id = 120471,
        name = "Outpost Museum stand 06",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,31.7254,94.9461,126.672}",
        owner = "Aphelia",
        children = {{
            id = 120470,
            name = "Outpost Museum stand 05",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.6262,95.0393,123.524}",
            owner = "Aphelia"
        }, {
            id = 120472,
            name = "Outpost Museum stand 07",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,31.8927,94.9605,112.369}",
            owner = "Aphelia"
        }}
    }, {
        id = 120242,
        name = "uef medium ships museum 05",
        type = "construct",
        label = "",
        coordinate = "::pos{0,2,1.1219,157.7622,91.523}",
        owner = "Aphelia",
        children = {{
            id = 120200,
            name = "UEF Medium Ships Museum 01",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,1.0572,157.7396,139.657}",
            owner = "Aphelia"
        }, {
            id = 120201,
            name = "UEF Medium Ships Museum 02",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,1.0564,157.7974,143.722}",
            owner = "Aphelia"
        }, {
            id = 120240,
            name = "uef medium ships museum 03",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,1.1146,157.7391,144.22}",
            owner = "Aphelia"
        }, {
            id = 120241,
            name = "uef medium ships museum 04",
            type = "construct",
            label = "",
            coordinate = "::pos{0,2,1.1146,157.7966,144.282}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 9,
    name = "Jago",
    label = "Planet",
    type = "planet",
    color = "90,150,255",
    coordinate = "::pos{0,0,-94134464,12765536,-3634464}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 9
    },
    radius = 61590.00,
    atmosphereRadius = 72700.00,
    areaRadius = 61590.00,
    children = {{
        id = 150091,
        name = "Market Jago 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,2.6613,177.5929,100.538}",
        owner = "Aphelia"
    }, {
        id = 150092,
        name = "Market Jago 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,-6.6388,-68.1536,60.56}",
        owner = "Aphelia"
    }, {
        id = 150093,
        name = "Market Jago 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,-1.5652,1.6186,37.571}",
        owner = "Aphelia"
    }, {
        id = 150094,
        name = "Market Jago 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,-6.5576,82.493,47.239}",
        owner = "Aphelia"
    }, {
        id = 150095,
        name = "Market Jago 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,88.3794,16.2183,31.107}",
        owner = "Aphelia"
    }, {
        id = 150096,
        name = "Market Jago 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,-85.7034,125.2505,36.57}",
        owner = "Aphelia"
    }, {
        id = 200910,
        name = "Mission Jago 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,9,17.0466,-137.0617,-11.336}",
        owner = "Aphelia",
        children = {{
            id = 200913,
            name = "Mission Jago 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,9,17.0531,-137.0753,5.513}",
            owner = "Aphelia"
        }, {
            id = 200912,
            name = "Mission Jago 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,9,16.9952,-137.0439,-48.722}",
            owner = "Aphelia"
        }, {
            id = 200911,
            name = "Mission Jago 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,9,17.1061,-137.1037,38.249}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 1,
    name = "Madis",
    label = "Planet",
    type = "planet",
    color = "255,150,70",
    coordinate = "::pos{0,0,17465536,22665536,-34464}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 1
    },
    radius = 44300.00,
    atmosphereRadius = 56500.00,
    areaRadius = 44300.00,
    children = {{
        id = 10,
        name = "Madis Moon 1",
        label = "Moon of Madis",
        type = "moon",
        coordinate = "::pos{0,0,17448118.86,22966848.03,143079.98}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 10
        },
        radius = 10000.00,
        atmosphereRadius = 10000.00,
        areaRadius = 10000.00,
        children = {{
            id = 150101,
            name = "Market Madis Moon I 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,10,60.1732,-98.1735,56.672}",
            owner = "Aphelia"
        }, {
            id = 150102,
            name = "Market Madis Moon I 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,10,-49.7318,39.6847,63.851}",
            owner = "Aphelia"
        }}
    }, {
        id = 11,
        name = "Madis Moon 2",
        label = "Moon of Madis",
        type = "moon",
        coordinate = "::pos{0,0,17194626,22243633.88,-214962.81}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 11
        },
        radius = 12000.00,
        atmosphereRadius = 12000.00,
        areaRadius = 12000.00,
        children = {{
            id = 150111,
            name = "Market Madis Moon II 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,11,-45.6326,-11.0212,-2225.73}",
            owner = "Aphelia"
        }, {
            id = 150112,
            name = "Market Madis Moon II 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,11,12.2818,139.6527,-1657.592}",
            owner = "Aphelia"
        }}
    }, {
        id = 12,
        name = "Madis Moon 3",
        label = "Moon of Madis",
        type = "moon",
        coordinate = "::pos{0,0,17520617.44,22184726.9,-309986.22}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 12
        },
        radius = 15000.00,
        atmosphereRadius = 15000.00,
        areaRadius = 15000.00,
        children = {{
            id = 150121,
            name = "Market Madis Moon III 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,12,30.3468,-161.5181,934.499}",
            owner = "Aphelia"
        }, {
            id = 150122,
            name = "Market Madis Moon III 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,12,-4.7263,18.8707,818.338}",
            owner = "Aphelia"
        }}
    }, {
        id = 150011,
        name = "Market Madis 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,4.4279,176.35,617.162}",
        owner = "Aphelia"
    }, {
        id = 150012,
        name = "Market Madis 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,10.6507,8.4529,614.496}",
        owner = "Aphelia"
    }, {
        id = 150013,
        name = "Market Madis 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,-0.1723,82.4675,600.486}",
        owner = "Aphelia"
    }, {
        id = 150014,
        name = "Market Madis 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,-80.6784,42.3477,620.941}",
        owner = "Aphelia"
    }, {
        id = 150015,
        name = "Market Madis 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,80.9904,7.6438,619.126}",
        owner = "Aphelia"
    }, {
        id = 150016,
        name = "Market Madis 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,14.2012,-91.8188,611.515}",
        owner = "Aphelia"
    }, {
        id = 200110,
        name = "Mission Madis 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,1,-36.273,162.4628,904.623}",
        owner = "Aphelia",
        children = {{
            id = 200113,
            name = "Mission Madis 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,1,-36.2654,162.4853,921.538}",
            owner = "Aphelia"
        }, {
            id = 200112,
            name = "Mission Madis 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,1,-36.2446,162.3787,866.934}",
            owner = "Aphelia"
        }, {
            id = 200111,
            name = "Mission Madis 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,1,-36.2847,162.5827,954.636}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 6,
    name = "Sicari",
    label = "Planet",
    type = "planet",
    color = "255,220,100",
    coordinate = "::pos{0,0,52765536,27165536,52065536}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 6
    },
    radius = 51100.00,
    atmosphereRadius = 57890.00,
    areaRadius = 51100.00,
    children = {{
        id = 150061,
        name = "Market Sicari 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,22.9964,-84.1265,40.941}",
        owner = "Aphelia"
    }, {
        id = 150062,
        name = "Market Sicari 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,-22.6734,-14.4341,49.976}",
        owner = "Aphelia"
    }, {
        id = 150063,
        name = "Market Sicari 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,-12.1731,92.6658,78.154}",
        owner = "Aphelia"
    }, {
        id = 150064,
        name = "Market Sicari 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,10.2042,-166.7179,41.326}",
        owner = "Aphelia"
    }, {
        id = 150065,
        name = "Market Sicari 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,74.8151,-24.3935,86.995}",
        owner = "Aphelia"
    }, {
        id = 150066,
        name = "Market Sicari 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,-63.5973,137.3353,183.843}",
        owner = "Aphelia"
    }, {
        id = 200610,
        name = "Mission Sicari 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,6,-24.9714,175.6023,118.955}",
        owner = "Aphelia",
        children = {{
            id = 200613,
            name = "Mission Sicari 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,6,-24.9674,175.6211,135.804}",
            owner = "Aphelia"
        }, {
            id = 200612,
            name = "Mission Sicari 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,6,-24.9369,175.5414,81.574}",
            owner = "Aphelia"
        }, {
            id = 200611,
            name = "Mission Sicari 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,6,-24.9954,175.6937,168.55}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 7,
    name = "Sinnen",
    label = "Planet",
    type = "planet",
    color = "210,145,255",
    coordinate = "::pos{0,0,52718347.1654,26962117.3105,51830774.6918}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 7
    },
    radius = 54950.00,
    atmosphereRadius = 64110.00,
    areaRadius = 54950.00,
    children = {{
        id = 70,
        name = "Sinnen Moon 1",
        label = "Moon of Sinnen",
        type = "moon",
        coordinate = "::pos{0,0,52416510.6689,26795577.1597,51893332.6527}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 70
        },
        radius = 17000.00,
        atmosphereRadius = 17000.00,
        areaRadius = 17000.00,
        children = {{
            id = 150701,
            name = "Market Sinnen Moon I 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,70,47.1199,-21.3653,-1889.866}",
            owner = "Aphelia"
        }, {
            id = 150702,
            name = "Market Sinnen Moon I 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,70,-43.1126,107.9656,-1891.521}",
            owner = "Aphelia"
        }}
    }, {
        id = 150071,
        name = "Market Sinnen 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,-4.0693,-92.0308,76.019}",
        owner = "Aphelia"
    }, {
        id = 150072,
        name = "Market Sinnen 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,-2.8639,13.0121,450.628}",
        owner = "Aphelia"
    }, {
        id = 150073,
        name = "Market Sinnen 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,15.707,103.1286,322.89}",
        owner = "Aphelia"
    }, {
        id = 150074,
        name = "Market Sinnen 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,41.6005,-173.6554,418.358}",
        owner = "Aphelia"
    }, {
        id = 150075,
        name = "Market Sinnen 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,68.7365,-33.9298,376.764}",
        owner = "Aphelia"
    }, {
        id = 150076,
        name = "Market Sinnen 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,-70.8709,162.6713,366.575}",
        owner = "Aphelia"
    }, {
        id = 200710,
        name = "Mission Sinnen 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,7,10.8945,151.3891,322.892}",
        owner = "Aphelia",
        children = {{
            id = 200713,
            name = "Mission Sinnen 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,7,10.8796,151.3955,339.741}",
            owner = "Aphelia"
        }, {
            id = 200712,
            name = "Mission Sinnen 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,7,10.9502,151.4128,285.509}",
            owner = "Aphelia"
        }, {
            id = 200711,
            name = "Mission Sinnen 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,7,10.8152,151.3794,372.482}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 4,
    name = "Talemai",
    label = "Planet",
    type = "planet",
    color = "150,205,255",
    coordinate = "::pos{0,0,-13234464,55765536,465536}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 4
    },
    radius = 57500.00,
    atmosphereRadius = 72500.00,
    areaRadius = 57500.00,
    children = {{
        id = 42,
        name = "Talemai Moon 1",
        label = "Moon of Talemai",
        type = "moon",
        coordinate = "::pos{0,0,-13058408.39,55781856.758,740177.66}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 42
        },
        radius = 15000.00,
        atmosphereRadius = 15000.00,
        areaRadius = 15000.00,
        children = {{
            id = 150421,
            name = "Market Talemai Moon I 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,42,-37.8503,170.3167,12.716}",
            owner = "Aphelia"
        }, {
            id = 150422,
            name = "Market Talemai Moon I 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,42,46.4474,-42.7359,11.666}",
            owner = "Aphelia"
        }}
    }, {
        id = 40,
        name = "Talemai Moon 2",
        label = "Moon of Talemai",
        type = "moon",
        coordinate = "::pos{0,0,-13503090.34,55594324.49,769836.53}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 40
        },
        radius = 12000.00,
        atmosphereRadius = 12000.00,
        areaRadius = 12000.00,
        children = {{
            id = 150401,
            name = "Market Talemai Moon II 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,40,-26.14,6.9964,279.65}",
            owner = "Aphelia"
        }, {
            id = 150402,
            name = "Market Talemai Moon II 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,40,47.5562,-153.6472,255.094}",
            owner = "Aphelia"
        }}
    }, {
        id = 41,
        name = "Talemai Moon 3",
        label = "Moon of Talemai",
        type = "moon",
        coordinate = "::pos{0,0,-12800514.62,55700257.457,325207.84}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 41
        },
        radius = 11000.00,
        atmosphereRadius = 11000.00,
        areaRadius = 11000.00,
        children = {{
            id = 150411,
            name = "Market Talemai Moon III 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,41,-5.9445,90.0125,96.13}",
            owner = "Aphelia"
        }, {
            id = 150412,
            name = "Market Talemai Moon III 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,41,-12.5213,-63.5317,86.515}",
            owner = "Aphelia"
        }}
    }, {
        id = 150041,
        name = "Market Talemai 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,-2.3947,-178.3647,-21.1}",
        owner = "Aphelia"
    }, {
        id = 150042,
        name = "Market Talemai 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,-10.7404,-88.2258,592.523}",
        owner = "Aphelia"
    }, {
        id = 150043,
        name = "Market Talemai 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,-4.6978,-4.5786,516.635}",
        owner = "Aphelia"
    }, {
        id = 150044,
        name = "Market Talemai 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,-9.4356,99.5903,609.486}",
        owner = "Aphelia"
    }, {
        id = 150045,
        name = "Market Talemai 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,60.3731,124.8693,526.469}",
        owner = "Aphelia"
    }, {
        id = 150046,
        name = "Market Talemai 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,-67.2931,74.3466,509.684}",
        owner = "Aphelia"
    }, {
        id = 200410,
        name = "Mission Talemai 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,4,52.7488,-29.0727,518.268}",
        owner = "Aphelia",
        children = {{
            id = 200413,
            name = "Mission Talemai 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,4,52.7488,-29.0472,535.117}",
            owner = "Aphelia"
        }, {
            id = 200412,
            name = "Mission Talemai 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,4,52.7895,-29.1397,480.883}",
            owner = "Aphelia"
        }, {
            id = 200411,
            name = "Mission Talemai 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,4,52.7113,-28.9632,567.856}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 8,
    name = "Teoma",
    label = "Planet",
    type = "planet",
    color = "95,235,190",
    coordinate = "::pos{0,0,80865536,54665536,-934464}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 8
    },
    radius = 62000.00,
    atmosphereRadius = 66960.00,
    areaRadius = 62000.00,
    children = {{
        id = 150081,
        name = "Market Teoma 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,2.5319,179.2855,804.78}",
        owner = "Aphelia"
    }, {
        id = 150082,
        name = "Market Teoma 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,7.3316,-83.8719,620.182}",
        owner = "Aphelia"
    }, {
        id = 150083,
        name = "Market Teoma 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,1.7959,-5.6494,644.896}",
        owner = "Aphelia"
    }, {
        id = 150084,
        name = "Market Teoma 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,-2.4681,94.1195,581.822}",
        owner = "Aphelia"
    }, {
        id = 150085,
        name = "Market Teoma 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,86.9943,31.7735,597.313}",
        owner = "Aphelia"
    }, {
        id = 150086,
        name = "Market Teoma 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,-88.3821,19.9114,616.736}",
        owner = "Aphelia"
    }, {
        id = 200810,
        name = "Mission Teoma 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,8,-21.0528,-145.8142,956.094}",
        owner = "Aphelia",
        children = {{
            id = 200813,
            name = "Mission Teoma 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,8,-21.0438,-145.8023,972.938}",
            owner = "Aphelia"
        }, {
            id = 200812,
            name = "Mission Teoma 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,8,-21.0471,-145.8706,918.736}",
            owner = "Aphelia"
        }, {
            id = 200811,
            name = "Mission Teoma 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,8,-21.041,-145.74,1005.643}",
            owner = "Aphelia"
        }}
    }}
}, {
    id = 3,
    name = "Thades",
    label = "Planet",
    type = "planet",
    color = "255,190,80",
    coordinate = "::pos{0,0,29165536,10865536,65536}",
    owner = nil,
    atlasBody = {
        systemId = 0,
        bodyId = 3
    },
    radius = 49000.00,
    atmosphereRadius = 80020.00,
    areaRadius = 49000.00,
    children = {{
        id = 30,
        name = "Thades Moon 1",
        label = "Moon of Thades",
        type = "moon",
        coordinate = "::pos{0,0,29214403.49,10907080.7,433861.28}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 30
        },
        radius = 14000.00,
        atmosphereRadius = 14000.00,
        areaRadius = 14000.00,
        children = {{
            id = 150301,
            name = "Market Thades Moon I 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,30,-2.9449,-117.7751,204.229}",
            owner = "Aphelia"
        }, {
            id = 150302,
            name = "Market Thades Moon I 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,30,-7.6777,110.8259,331.898}",
            owner = "Aphelia"
        }}
    }, {
        id = 31,
        name = "Thades Moon 2",
        label = "Moon of Thades",
        type = "moon",
        coordinate = "::pos{0,0,29404194.34,10432766.6,19553.82}",
        owner = nil,
        atlasBody = {
            systemId = 0,
            bodyId = 31
        },
        radius = 15000.00,
        atmosphereRadius = 15000.00,
        areaRadius = 15000.00,
        children = {{
            id = 150311,
            name = "Market Thades Moon II 1",
            type = "construct",
            label = "",
            coordinate = "::pos{0,31,-30.8586,-156.3956,236.997}",
            owner = "Aphelia"
        }, {
            id = 150312,
            name = "Market Thades Moon II 2",
            type = "construct",
            label = "",
            coordinate = "::pos{0,31,85.9995,52.7126,95.4}",
            owner = "Aphelia"
        }}
    }, {
        id = 150031,
        name = "Market Thades 1",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,-25.9458,124.8607,13742.488}",
        owner = "Aphelia"
    }, {
        id = 150032,
        name = "Market Thades 2",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,54.1098,-25.1438,13423.264}",
        owner = "Aphelia"
    }, {
        id = 150033,
        name = "Market Thades 3",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,-57.0357,-58.1891,12993.332}",
        owner = "Aphelia"
    }, {
        id = 150034,
        name = "Market Thades 4",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,75.191,169.8535,13380.699}",
        owner = "Aphelia"
    }, {
        id = 150035,
        name = "Market Thades 5",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,-2.7402,40.8698,13671.286}",
        owner = "Aphelia"
    }, {
        id = 150036,
        name = "Market Thades 6",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,-3.6907,-139.7983,13652.77}",
        owner = "Aphelia"
    }, {
        id = 200310,
        name = "Mission Thades 01",
        type = "construct",
        label = "",
        coordinate = "::pos{0,3,20.1274,151.4506,13689.484}",
        owner = "Aphelia",
        children = {{
            id = 200313,
            name = "Mission Thades 01 Bridge",
            type = "construct",
            label = "",
            coordinate = "::pos{0,3,20.1295,151.4355,13706.344}",
            owner = "Aphelia"
        }, {
            id = 200312,
            name = "Mission Thades 01 Landing",
            type = "construct",
            label = "",
            coordinate = "::pos{0,3,20.0844,151.4839,13652.046}",
            owner = "Aphelia"
        }, {
            id = 200311,
            name = "Mission Thades 01 Monument",
            type = "construct",
            label = "",
            coordinate = "::pos{0,3,20.1708,151.3915,13739.137}",
            owner = "Aphelia"
        }}
    }}
}}

local knownSpace = {
    name = "Known Space",
    label = "Known star systems",
    type = "known-space"
}

local heliosSystem = {
    id = 0,
    name = "Helios System",
    label = "Star system",
    type = "system",
    coordinate = "::pos{0,0,0,0,0}",
    worldUp = {
        x = 0,
        y = 0,
        z = 1
    },
    owner = nil,
    areaRadius = 100000000
}

heliosSystem.children = heliosPlanets
knownSpace.children = {heliosSystem}

-- Limited offline copy of atlas.lua used only when the client atlas cannot load.
local fallbackAtlas = {
    [0] = {
        [1] = {
            id = 1,
            name = "Madis",
            type = "planet",
            systemId = 0,
            center = {17465536.00, 22665536.00, -34464.00},
            radius = 44300.00,
            atmosphereRadius = 56500.00
        },
        [2] = {
            id = 2,
            name = "Alioth",
            type = "planet",
            systemId = 0,
            center = {-8.00, -8.00, -126303.00},
            radius = 126067.90,
            atmosphereRadius = 132460.00
        },
        [3] = {
            id = 3,
            name = "Thades",
            type = "planet",
            systemId = 0,
            center = {29165536.00, 10865536.00, 65536.00},
            radius = 49000.00,
            atmosphereRadius = 80020.00
        },
        [4] = {
            id = 4,
            name = "Talemai",
            type = "planet",
            systemId = 0,
            center = {-13234464.00, 55765536.00, 465536.00},
            radius = 57500.00,
            atmosphereRadius = 72500.00
        },
        [5] = {
            id = 5,
            name = "Feli",
            type = "planet",
            systemId = 0,
            center = {-43468928.00, 22631072.00, -48868928.00},
            radius = 41800.00,
            atmosphereRadius = 103740.00
        },
        [6] = {
            id = 6,
            name = "Sicari",
            type = "planet",
            systemId = 0,
            center = {52765536.00, 27165536.00, 52065536.00},
            radius = 51100.00,
            atmosphereRadius = 57890.00
        },
        [7] = {
            id = 7,
            name = "Sinnen",
            type = "planet",
            systemId = 0,
            center = {52718347.1654, 26962117.3105, 51830774.6918},
            radius = 54950.00,
            atmosphereRadius = 64110.00
        },
        [8] = {
            id = 8,
            name = "Teoma",
            type = "planet",
            systemId = 0,
            center = {80865536.00, 54665536.00, -934464.00},
            radius = 62000.00,
            atmosphereRadius = 66960.00
        },
        [9] = {
            id = 9,
            name = "Jago",
            type = "planet",
            systemId = 0,
            center = {-94134464.0000, 12765536.000, -3634464.0000},
            radius = 61590.00,
            atmosphereRadius = 72700.00
        },
        [10] = {
            id = 10,
            name = "Madis Moon 1",
            type = "satellite",
            systemId = 0,
            center = {17448118.86, 22966848.03, 143079.98},
            radius = 10000.00,
            atmosphereRadius = 10000.00
        },
        [11] = {
            id = 11,
            name = "Madis Moon 2",
            type = "satellite",
            systemId = 0,
            center = {17194626.00, 22243633.88, -214962.81},
            radius = 12000.00,
            atmosphereRadius = 12000.00
        },
        [12] = {
            id = 12,
            name = "Madis Moon 3",
            type = "satellite",
            systemId = 0,
            center = {17520617.44, 22184726.90, -309986.22},
            radius = 15000.00,
            atmosphereRadius = 15000.00
        },
        [21] = {
            id = 21,
            name = "Alioth Moon 1",
            type = "satellite",
            systemId = 0,
            center = {457932.99, -1509009.24, 115525.00},
            radius = 30000.00,
            atmosphereRadius = 30000.00
        },
        [22] = {
            id = 22,
            name = "Alioth Moon 4",
            type = "satellite",
            systemId = 0,
            center = {-1692694.85, 729681.81, -411465.62},
            radius = 30330.00,
            atmosphereRadius = 30330.00
        },
        [26] = {
            id = 26,
            name = "Sanctuary",
            type = "satellite",
            systemId = 0,
            center = {-1404834.53, 562655.32, -285074.95},
            radius = 83400.00,
            atmosphereRadius = 89550.00
        },
        [27] = {
            id = 27,
            name = "Haven",
            type = "satellite",
            systemId = 0,
            center = {-1205152.02, 1124841.79, -2638867.62},
            radius = 83443.00,
            atmosphereRadius = 89870.00
        },
        [30] = {
            id = 30,
            name = "Thades Moon 1",
            type = "satellite",
            systemId = 0,
            center = {29214403.49, 10907080.70, 433861.28},
            radius = 14000.00,
            atmosphereRadius = 14000.00
        },
        [31] = {
            id = 31,
            name = "Thades Moon 2",
            type = "satellite",
            systemId = 0,
            center = {29404194.34, 10432766.60, 19553.82},
            radius = 15000.00,
            atmosphereRadius = 15000.00
        },
        [40] = {
            id = 40,
            name = "Talemai Moon 2",
            type = "satellite",
            systemId = 0,
            center = {-13503090.34, 55594324.49, 769836.53},
            radius = 12000.00,
            atmosphereRadius = 12000.00
        },
        [41] = {
            id = 41,
            name = "Talemai Moon 3",
            type = "satellite",
            systemId = 0,
            center = {-12800514.62, 55700257.46, 325207.84},
            radius = 11000.00,
            atmosphereRadius = 11000.00
        },
        [42] = {
            id = 42,
            name = "Talemai Moon 1",
            type = "satellite",
            systemId = 0,
            center = {-13058408.39, 55781856.76, 740177.66},
            radius = 15000.00,
            atmosphereRadius = 15000.00
        },
        [50] = {
            id = 50,
            name = "Feli Moon 1",
            type = "satellite",
            systemId = 0,
            center = {-43886457.78, 22277418.70, -48846002.00},
            radius = 14000.00,
            atmosphereRadius = 14000.00
        },
        [70] = {
            id = 70,
            name = "Sinnen Moon 1",
            type = "satellite",
            systemId = 0,
            center = {52416510.6689, 26795577.1597, 51893332.6527},
            radius = 17000.00,
            atmosphereRadius = 17000.00
        },
        [100] = {
            id = 100,
            name = "Lacobus",
            type = "planet",
            systemId = 0,
            center = {98931072.00, -13468928.00, -868925.99},
            radius = 55650.00,
            atmosphereRadius = 70580.00
        },
        [101] = {
            id = 101,
            name = "Lacobus Moon 3",
            type = "satellite",
            systemId = 0,
            center = {98921672.1700, -13934537.1000, -631205.5300},
            radius = 15000.00,
            atmosphereRadius = 15000.00
        },
        [102] = {
            id = 102,
            name = "Lacobus Moon 1",
            type = "satellite",
            systemId = 0,
            center = {99213736.0000, -13751094.0000, -893388.4000},
            radius = 18000.00,
            atmosphereRadius = 18000.00
        },
        [103] = {
            id = 103,
            name = "Lacobus Moon 2",
            type = "satellite",
            systemId = 0,
            center = {99266436.0000, -13612831.0000, -1042957.4000},
            radius = 14000.00,
            atmosphereRadius = 14000.00
        },
        [110] = {
            id = 110,
            name = "Symeon",
            type = "planet",
            systemId = 0,
            center = {14231072.0000, -85568929.0000, -868928.3000},
            radius = 49050.00,
            atmosphereRadius = 55200.00
        },
        [120] = {
            id = 120,
            name = "Ion",
            type = "planet",
            systemId = 0,
            center = {2931072.7000, -98968928.0000, -868926.0200},
            radius = 44950.00,
            atmosphereRadius = 50450.00
        },
        [121] = {
            id = 121,
            name = "Ion Moon 1",
            type = "satellite",
            systemId = 0,
            center = {2489300.8000, -99117363.0000, -1117198.8000},
            radius = 11000.00,
            atmosphereRadius = 11000.00
        },
        [122] = {
            id = 122,
            name = "Ion Moon 2",
            type = "satellite",
            systemId = 0,
            center = {3011808.5000, -99258626.0000, -1362096.7000},
            radius = 15000.00,
            atmosphereRadius = 15000.00
        },
        [400] = {
            id = 400,
            name = "Thades Asteroid 00",
            type = "asteroid",
            systemId = 0,
            center = {29299301.32, 10711862.68, 2851.97},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [401] = {
            id = 401,
            name = "Thades Asteroid 01",
            type = "asteroid",
            systemId = 0,
            center = {29282550.05, 10753803.20, 117513.67},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [402] = {
            id = 402,
            name = "Thades Asteroid 02",
            type = "asteroid",
            systemId = 0,
            center = {29229075.50, 10805882.53, 256161.21},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [403] = {
            id = 403,
            name = "Thades Asteroid 03",
            type = "asteroid",
            systemId = 0,
            center = {29267536.95, 10749726.84, -97063.90},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [404] = {
            id = 404,
            name = "Thades Asteroid 04",
            type = "asteroid",
            systemId = 0,
            center = {29296929.92, 10741579.35, -34201.26},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [405] = {
            id = 405,
            name = "Thades Asteroid 05",
            type = "asteroid",
            systemId = 0,
            center = {29230291.68, 10801230.42, -117467.33},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [406] = {
            id = 406,
            name = "Thades Asteroid 06",
            type = "asteroid",
            systemId = 0,
            center = {29294439.12, 10755446.81, 185994.55},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [407] = {
            id = 407,
            name = "Thades Asteroid 07",
            type = "asteroid",
            systemId = 0,
            center = {29091470.31, 10943497.38, -37252.04},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [408] = {
            id = 408,
            name = "Thades Asteroid 08",
            type = "asteroid",
            systemId = 0,
            center = {29081043.07, 10962202.27, -75767.64},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [409] = {
            id = 409,
            name = "Thades Asteroid 09",
            type = "asteroid",
            systemId = 0,
            center = {29086073.94, 10961324.33, -37713.45},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [410] = {
            id = 410,
            name = "Thades Asteroid 10",
            type = "asteroid",
            systemId = 0,
            center = {29057495.95, 11010112.20, -12840.27},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [411] = {
            id = 411,
            name = "Thades Asteroid 11",
            type = "asteroid",
            systemId = 0,
            center = {29038528.76, 11009018.02, 34480.51},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [412] = {
            id = 412,
            name = "Thades Asteroid 12",
            type = "asteroid",
            systemId = 0,
            center = {29063783.12, 11010103.53, -19811.13},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [413] = {
            id = 413,
            name = "Thades Asteroid 13",
            type = "asteroid",
            systemId = 0,
            center = {29308876.96, 10722122.97, 63979.64},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [414] = {
            id = 414,
            name = "Thades Asteroid 14",
            type = "asteroid",
            systemId = 0,
            center = {29039962.95, 11009804.08, 20310.07},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [415] = {
            id = 415,
            name = "Thades Asteroid 15",
            type = "asteroid",
            systemId = 0,
            center = {29028034.74, 11006962.68, 90614.67},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [416] = {
            id = 416,
            name = "Thades Asteroid 16",
            type = "asteroid",
            systemId = 0,
            center = {29049290.89, 11009683.55, 130463.58},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [417] = {
            id = 417,
            name = "Thades Asteroid 17",
            type = "asteroid",
            systemId = 0,
            center = {29034838.01, 11011307.10, 100551.51},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [418] = {
            id = 418,
            name = "Thades Asteroid 18",
            type = "asteroid",
            systemId = 0,
            center = {29071108.08, 10957206.76, 212593.35},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [419] = {
            id = 419,
            name = "Thades Asteroid 19",
            type = "asteroid",
            systemId = 0,
            center = {29167994.87, 10859282.88, 268014.12},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [420] = {
            id = 420,
            name = "Thades Asteroid 20",
            type = "asteroid",
            systemId = 0,
            center = {29213864.06, 10803741.30, -121255.16},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [421] = {
            id = 421,
            name = "Thades Asteroid 21",
            type = "asteroid",
            systemId = 0,
            center = {29239443.63, 10792184.95, 211277.78},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [422] = {
            id = 422,
            name = "Thades Asteroid 22",
            type = "asteroid",
            systemId = 0,
            center = {29144431.74, 10891773.13, 265131.10},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [423] = {
            id = 423,
            name = "Thades Asteroid 23",
            type = "asteroid",
            systemId = 0,
            center = {29221331.78, 10813011.47, -112261.08},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [424] = {
            id = 424,
            name = "Thades Asteroid 24",
            type = "asteroid",
            systemId = 0,
            center = {29261255.06, 10778311.95, -68014.35},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [425] = {
            id = 425,
            name = "Thades Asteroid 25",
            type = "asteroid",
            systemId = 0,
            center = {29199560.98, 10832137.62, -97473.02},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [426] = {
            id = 426,
            name = "Thades Asteroid 26",
            type = "asteroid",
            systemId = 0,
            center = {29055988.74, 10976710.89, 153234.70},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [427] = {
            id = 427,
            name = "Thades Asteroid 27",
            type = "asteroid",
            systemId = 0,
            center = {29052925.00, 10978093.03, 202894.97},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [428] = {
            id = 428,
            name = "Thades Asteroid 28",
            type = "asteroid",
            systemId = 0,
            center = {29114441.38, 10927735.88, 231833.92},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [429] = {
            id = 429,
            name = "Thades Asteroid 29",
            type = "asteroid",
            systemId = 0,
            center = {29093988.60, 10935957.84, 206596.14},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [430] = {
            id = 430,
            name = "Thades Asteroid 30",
            type = "asteroid",
            systemId = 0,
            center = {29308670.06, 10719768.95, 122162.49},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [431] = {
            id = 431,
            name = "Thades Asteroid 31",
            type = "asteroid",
            systemId = 0,
            center = {29315394.75, 10724428.22, 30918.91},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [432] = {
            id = 432,
            name = "Thades Asteroid 32",
            type = "asteroid",
            systemId = 0,
            center = {29039991.14, 11019630.48, 64846.61},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [433] = {
            id = 433,
            name = "Thades Asteroid 33",
            type = "asteroid",
            systemId = 0,
            center = {29278192.73, 10762037.83, 209654.75},
            radius = 5215.19,
            atmosphereRadius = 0.00
        },
        [500] = {
            id = 500,
            name = "Aresion",
            type = "planet",
            systemId = 0,
            center = {-39760027.2679, -30291219.2937, -2213579.9143},
            radius = 41800.00,
            atmosphereRadius = 103740.00
        }
    }
}

return {
    types = {
        ["known-space"] = {},
        system = {},
        planet = {
            icon = "icon-planet"
        },
        moon = {
            icon = "icon-moon"
        },
        market = {
            icon = "icon-market"
        },
        construct = {}
    },
    locations = {knownSpace},
    fallbackAtlas = fallbackAtlas
}
