--=======================================================================
-- By 7ZOV
--=======================================================================

InventoryCfg = {
    Ammo = {
        {
            template = "AmmoShotgun.CItem",
            name = "Shotgun Shells",
            type = "AMMO",
            ammoType = "Shotgun",
            ammoAmount = 10,
            description = "Ammunition for shotgun"
        },
        {
            template = "AmmoStakes.CItem",
            name = "Stakes",
            type = "AMMO",
            ammoType = "Stakes",
            ammoAmount = 8,
            description = "Wooden stakes"
        },
        {
            template = "AmmoGrenades.CItem",
            name = "Grenades",
            type = "AMMO",
            ammoType = "Grenades",
            ammoAmount = 4,
            description = "Explosive grenades"
        },
        {
            template = "AmmoGrenadesBig.CItem",
            name = "Grenades (Big)",
            type = "AMMO",
            ammoType = "Grenades",
            ammoAmount = 8,
            description = "Big pack of grenades"
        },
        {
            template = "AmmoMiniGun.CItem",
            name = "MiniGun Ammo",
            type = "AMMO",
            ammoType = "MiniGun",
            ammoAmount = 50,
            description = "Ammunition for minigun"
        },
        {
            template = "AmmoFreezer.CItem",
            name = "Freezer Ammo",
            type = "AMMO",
            ammoType = "IceBullets",
            ammoAmount = 30,
            description = "Ice bullets for freezer"
        },
        {
            template = "AmmoShurikens.CItem",
            name = "Shurikens",
            type = "AMMO",
            ammoType = "Shurikens",
            ammoAmount = 15,
            description = "Throwing stars"
        },
        {
            template = "AmmoElectro.CItem",
            name = "Electro Ammo",
            type = "AMMO",
            ammoType = "Electro",
            ammoAmount = 20,
            description = "Electro driver ammunition"
        },
        {
            template = "AmmoRifle.CItem",
            name = "Rifle Ammo",
            type = "AMMO",
            ammoType = "Rifle",
            ammoAmount = 30,
            description = "Ammunition for rifle"
        },
        {
            template = "AmmoFlameThrower.CItem",
            name = "Flame Fuel",
            type = "AMMO",
            ammoType = "FlameThrower",
            ammoAmount = 50,
            description = "Fuel for flamethrower"
        },
        {
            template = "AmmoBolt.CItem",
            name = "Bolts",
            type = "AMMO",
            ammoType = "Bolt",
            ammoAmount = 15,
            description = "Bolts for boltgun"
        },
        {
            template = "AmmoHeaterBomb.CItem",
            name = "Heater Bombs",
            type = "AMMO",
            ammoType = "HeaterBomb",
            ammoAmount = 8,
            description = "Heat-seeking bombs"
        }
    },
    
    -- Armor items
    Armor = {
        {
            template = "ArmorWeak.CItem",
            name = "Bronze Armor",
            type = "ARMOR",
            armorType = 1,
            armorAmount = 50,
            description = "Basic armor protection"
        },
        {
            template = "ArmorMedium.CItem",
            name = "Silver Armor",
            type = "ARMOR",
            armorType = 2,
            armorAmount = 100,
            description = "Medium armor protection"
        },
        {
            template = "ArmorStrong.CItem",
            name = "Gold Armor",
            type = "ARMOR",
            armorType = 3,
            armorAmount = 155,
            description = "Strong armor protection"
        }
    },
    
    -- Health items
    Health = {
        {
            template = "Health.CItem",
            name = "Health Pack",
            type = "HEALTH",
            healthAmount = 25,
            description = "Restores 25 HP"
        },
        {
            template = "MegaHealth.CItem",
            name = "Mega Health",
            type = "HEALTH",
            healthAmount = 50,
            description = "Restores 50 HP"
        }
    },
    
    -- Weapon items
    Weapons = {
        {
            template = "IShotgunFZ.CItem",
            name = "Shotgun",
            type = "WEAPON",
            weaponType = "Shotgun",
            weaponSlot = 2,
            description = "Powerful close-range weapon"
        },
        {
            template = "IStakeGun.CItem",
            name = "Stake Gun",
            type = "WEAPON",
            weaponType = "StakeGun",
            weaponSlot = 3,
            description = "Fires wooden stakes"
        },
        {
            template = "IMiniGunRL.CItem",
            name = "MiniGun",
            type = "WEAPON",
            weaponType = "MiniGunRL",
            weaponSlot = 4,
            description = "High rate of fire"
        },
        {
            template = "IDriverElectro.CItem",
            name = "Electro Driver",
            type = "WEAPON",
            weaponType = "DriverElectro",
            weaponSlot = 5,
            description = "Electro and shurikens"
        },
        {
            template = "IRifleFlameThrower.CItem",
            name = "Rifle",
            type = "WEAPON",
            weaponType = "RifleFlameThrower",
            weaponSlot = 6,
            description = "Rifle with flamethrower"
        },
        {
            template = "IBoltGunHeater.CItem",
            name = "Bolt Gun",
            type = "WEAPON",
            weaponType = "BoltGunHeater",
            weaponSlot = 7,
            description = "Bolts and heater bombs"
        },
        {
            template = "IHellGun.CItem",
            name = "Hell Gun",
            type = "WEAPON",
            weaponType = "HellGun",
            weaponSlot = 8,
            description = "Hellfire weapon"
        },
        {
            template = "IDevastator.CItem",
            name = "Devastator",
            type = "WEAPON",
            weaponType = "Devastator",
            weaponSlot = 9,
            description = "Rocket launcher"
        }
    },
    
    Special = {
        {
            template = "Quad.CItem",
            name = "Quad Damage",
            type = "SPECIAL",
            description = "Temporary damage boost",
            usable = true,
            onUse = function(player)
                -- Активировать Quad Damage
                Game:EnableGoldenCards() -- Или другая логика
            end
        },
        {
            template = "MegaPack.CItem",
            name = "Mega Pack",
            type = "SPECIAL",
            description = "Full ammo and health",
            usable = true,
            onUse = function(player)
                -- Дать всё
            end
        }
    },

    Item = {},
}

--=======================================================================
-- Build lookup table for quick access
--=======================================================================
InventoryCfg.Lookup = {}

function InventoryCfg:BuildLookup()
    self.Lookup = {}
    
    -- Helper function to add items to lookup
    local function addItems(items)
        if not items then return end
        for i, item in ipairs(items) do
            if item and item.template then
                self.Lookup[item.template] = item
            end
        end
    end
    
    addItems(self.Ammo)
    addItems(self.Armor)
    addItems(self.Health)
    addItems(self.Weapons)
    addItems(self.Special)
    addItems(self.Item)
    
    local count = 0
    for k, v in pairs(self.Lookup) do
        count = count + 1
    end
    CONSOLE.AddMessage("InventoryCfg: " .. count .. " items registered")
end

--=======================================================================
-- Get item data by template name
--=======================================================================
function InventoryCfg:GetItemData(templateName)
    return self.Lookup[templateName]
end

