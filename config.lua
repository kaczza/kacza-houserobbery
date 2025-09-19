Config = {}
Config.OxTarget = true
Config.JobName = 'police'
Config.RequiredItem = true
Config.ItemRequired = "lockpick"
Config.BlipEnabled = true
Config.CopsRequired = 0
Config.Cooldown = 120 


Config.Ped = {
    Name = "a_m_y_business_03",
    Pos = {x = -3075.1641, y = 655.5101, z = 10.6596, h = 312.0332}
    
}   

Config.Houses = {
    House1 = {   --you can add as many locations as you want
        Door = vector3(-174.7202, 502.5304, 137.4204),
        Interior = vector3(-174.3378, 497.484, 137.6535), 
        HeadingInt = 191.0619,  --heading for interior 
        LootH = {
            vector3(-170.3029, 496.1262, 137.6536),
            vector3(-170.6799, 482.5876, 137.2442),
            vector3(-167.5402, 488.0954, 133.8438),
            vector3(-174.4345, 493.9098, 130.0436),
           vector3(-163.9029, 486.9148, 137.443)
        }
    },
    House2 = { 
        Door = vector3(-36.30156, -570.6331, 38.83335), 
        Interior = vector3(-31.4882, -595.133, 80.03),
        HeadingInt = 311.318,
        LootH = {
            vector3(-27.74033, -581.5154, 79.23),  
            vector3(-39.19651, -589.2886, 78.83),
            vector3(-32.36621, -583.7902, 78.86551), 
            vector3(-12.62623, -596.9193, 79.43),
            vector3(-22.9559, -587.7166, 79.2308),
            vector3(-41.160374, -584.516663, 78.83) 
        }
    },
    House3 = { 
        Door = vector3(-686.044, 596.1514, 143.6422),
        Interior = vector3(-682.4269, 592.7078, 145.37),  
        HeadingInt = 224.9117,  
        LootH = {
            vector3(-678.1968, 593.1891, 145.3798),   
            vector3(-671.786, 581.1215, 144.9703), 
            vector3(-671.7256, 587.5762, 141.5699),  
            vector3(-680.682, 589.1367, 137.7697),
             vector3(-668.4758, 587.9321, 145.1697),
            vector3(-671.5652, 581.0245, 141.5708),
            vector3(-682.4417, 595.8707, 137.7660)  
        }
    }
}

Config.Loot = {
    badloot = {
        "nyaklanc",
        "Iphone",
        "festmeny"
    },
    mediumloot = {
        "diamond",
        "mikro",
        "gitar",
        "lopott_tv"
    },
    goodloot = {
        "money"
        
    }
}

Config.Cant = {
    badloot = {1, 2, 3},
    mediumloot = {1, 2, 3},
    goodloot = {1000, 10000}
}


Config.Text = {
    acceptjob = "Accept job",
    notenoughcops = "Not enough cops to start the robery",
    help = "Go to the marked location and break into the house",
    Lockpick = "Lockpick the door",
    reenter = "You can no longer re-enter",
    check = "Check the place",
    Leave = "Leave the house",
    robery = "House robbery",--blip name
    time = "You didn't force the door in a reasonable time, come back to steal later.",
    timeover = "The time to review the site locations is over.",
    nolockpick = "You don't have a lockpick",
    wait = "A robbery has just started, you must wait a little while."
}
