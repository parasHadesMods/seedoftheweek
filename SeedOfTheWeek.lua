ModUtil.RegisterMod("SeedOfTheWeek")

local config = {
    ModName = "Seed of the Week",
    Enabled = true
}
  
if ModConfigMenu then
    ModConfigMenu.Register(config)
end

local function deep_print(t, indent)
    if not indent then indent = 0 end 
    local indentString = ""
    for i = 1, indent do
      indentString = indentString .. "  "
    end
    for k,v in orderedPairs(t) do
      if type(v) == "table" then
        print(indentString..k)
        deep_print(v, indent + 1)
      else
        print(indentString..k, v)
      end
    end
  end

ModUtil.LoadOnce(function ()
    SeedOfTheWeekRoute = {
        [1] = {
            RoomSetName = "Tartarus",
            RoomName = "RoomOpening",
            ChosenRewardType = "WeaponUpgrade",
            EnemySet = { "HeavyMelee" },
            Waves = 1,
            PreSpawnPoints = {
                HeavyMelee = { 508060 }
            },
            UpgradeOptions = {
                [1] = {
                    Type = "Trait",
                    ItemName = "GunExplodingSecondaryTrait",
                    Rarity = "Common"
                }
            }
        },
        [2] = {
            RoomSetName = "Tartarus",
            RoomName = "A_Combat06",
            EnemySet = { "PunchingBagUnitElite" },
            EliteAttributes = {
                PunchingBagUnitElite = { "Vacuuming" }
            },
            PreSpawnPoints = {
                PunchingBagUnitElite = { 410001 }
            },
            Waves = 1,
            ChosenRewardType = "Boon",
            ForceLootName = "ZeusUpgrade",
            UpgradeOptions = {
                [1] = {
                    Type = "Trait",
                    ItemName = "ZeusWeaponTrait",
                    Rarity = "Epic"
                }
            }
        },
        [3] = {
            RoomSetName = "Tartarus",
            RoomName = "A_Combat08A",
            RoomFlipped = false,
            EnemySet = { "HeavyRangedElite" },
            EliteAttributes = {
                HeavyRangedElite = { "Beams" }
            },
            PreSpawnPoints = {
                HeavyRangedElite = { 410013, 430029, 430002 }
            },
            Waves = 1,
            SecretPointIndex = 2,
            ChosenRewardType = "GemDropRunProgress"
        },
        [4] = {
            RoomSetName = "Secrets",
            RoomName = "RoomSecret03",
            RoomFlipped = true,
            ChosenRewardType = "TrialUpgrade",
            UpgradeOptions = {
                [1] = {
                    Type = "TransformingTrait",
                    ItemName = "ChaosBlessingSecondaryTrait",
                    SecondaryItemName = "ChaosCurseDeathWeaponTrait",
                    Rarity = "Epic"
                }
            }
        },
        [5] = {
            RoomSetName = "Tartarus",
            RoomName = "A_Combat05",
            RoomFlipped = true,
            EnemySet = { "DisembodiedHandElite" },
            EliteAttributes = {
                DisembodiedHandElite = { "Beams" }
            },
            PreSpawnPoints = {
                DisembodiedHandElite = { 480613, 410133, 410187 }
            },
            Waves = 1,
            ChosenRewardType = "Boon",
            ForceLootName = "ZeusUpgrade",
            UpgradeOptions = {
                [1] = {
                    Type = "Trait",
                    ItemName = "ZeusBonusBounceTrait",
                    Rarity = "Epic"
                }
            },
            StoreOptions = {
                [1] = {
                    Name = "TemporaryForcedSecretDoorTrait",
                    Type = "Trait"
                },
                [2] = {
                    Name = "TemporaryForcedSecretDoorTrait",
                    Type = "Trait"
                },
            }
        },
        [6] = {
            RoomSetName = "Tartarus",
            RoomName = "A_Shop01",
            RoomFlipped = false,
            ChosenRewardType = "Shop",
            StoreOptions = {
                [1] = {
                    Name = "RoomRewardHealDrop",
                    Type = "Consumable"
                },
                [2] = {
                    Name = "BlindBoxLoot",
                    Args = {
                        BoughtFromShop = true,
                        Cost = 150,
                        DoesNotBlockExit = true,
                        ForceLootName = "PoseidonUpgrade"
                    },
                    Type = "Consumable"
                },
                [3] = {
                    Name = "HermesUpgradeDrop",
                    Type = "Consumable"
                }
            },
            UpgradeOptions = {
                [1] = {
                    Type = "Trait",
                    ItemName = "RushSpeedBoostTrait",
                    Rarity = "Epic"
                }
            }
        },
        [7] = {
            RoomSetName = "Base",
            RoomName = "CharonFight01"
        }
    }
end)

function SeedOfTheWeek.GetRunDepth(run)
    local depth = GetRunDepth(run)
    if depth == 1 and not run.Hero.ActivationFinished then
        return 0
    else
        return depth
    end
end


ModUtil.WrapBaseFunction("ChooseRoomReward", function(baseFunc, run, room, rewardStoreName, previouslyChosenRewards)
    -- Runs when Zag activates an exit door, so we want the depth of the next room
    local depth = SeedOfTheWeek.GetRunDepth(run) + 1
    if config.Enabled then
        print("ChooseRoomReward", depth)
        local data = SeedOfTheWeekRoute[depth]
        if data.ChosenRewardType == "Boon" then
            room.ForceLootName = data.ForceLootName
        end
        return data.ChosenRewardType
    else
        local result = baseFunc(run, room, rewardStoreName, previouslyChosenRewards)
        print("ChooseRoomReward", depth, result)
        return result
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("ChooseNextRoomData", function(baseFunc, run, args)
    -- Runs when Zag activates an exit door, so we want the depth of the next room
    local depth = SeedOfTheWeek.GetRunDepth(run) + 1
    print("ChooseNextRoomData", depth)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        local roomData = RoomSetData[data.RoomSetName][data.RoomName]
        return roomData
    else
        local result = baseFunc(run, args)
        return result
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("RunShopGeneration", function(baseFunc, room)
    local depth = SeedOfTheWeek.GetRunDepth(CurrentRun)
    print("RunShopGeneration", depth)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        print("  ", room.Flipped, data.RoomFlipped)
        if data.RoomFlipped ~= nil then
            room.Flipped = data.RoomFlipped
        end
    end
    return baseFunc(room)
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("IsSecretDoorEligible", function(baseFunc, run, room)
    -- Runs when Zag activates an exit door, so we want the depth of the next room
    local depth = SeedOfTheWeek.GetRunDepth(run) + 1
    print("IsSecretDoorEligible", depth)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        if data.RoomSetName == "Secrets" then
            return true
        else
            return false
        end 
    else
        local result = baseFunc(run, args)
        return result
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("IsWellShopEligible", function (baseFunc, run, room)
    local depth = SeedOfTheWeek.GetRunDepth(run)
    print("IsWellShopEligible", depth)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        if data.StoreOptions ~= nil and data.ChosenRewardType ~= "Shop" then
            -- must be a well shop
            return true
        else
            return baseFunc(run, room)
        end
    else
        return baseFunc(run, room)
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("GetIdsByType", function(baseFunc, args)
    local result = baseFunc(args)
    if args.Name == "SecretPoint" and config.Enabled then
        local depth = SeedOfTheWeek.GetRunDepth(CurrentRun)
        print("GetIdsByType (SecretPoint)", depth)
        local data = SeedOfTheWeekRoute[depth]
        if data ~= nil and data.SecretPointIndex ~= nil then
            result = OverwriteAndCollapseTable(result)
            table.sort(result, cmp_multitype)
            return { result[data.SecretPointIndex] }
        end
    end
    return result
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("SetTraitsOnLoot", function(baseFunc, lootData, args)
    -- Runs when Zag opens the boon menu, so we want the depth of the current room
    local depth = SeedOfTheWeek.GetRunDepth(CurrentRun)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        lootData.UpgradeOptions = data.UpgradeOptions
    else
        baseFunc(lootData, args) -- mutates lootData
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("DoUnlockRoomExits", function(baseFunc, run, room)
    -- Runs when Zag doors would unlock. We want to inspect the next room to see if it's a secret.
    local depth = SeedOfTheWeek.GetRunDepth(run) + 1
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        if data.RoomSetName == "Secrets" then
            -- only offer the secret doors
            local secretDoors = {}
            for id, door in pairs(OfferedExitDoors) do
                if door.Name == "SecretDoor" then
                    secretDoors[id] = door
                end
            end
            OfferedExitDoors = secretDoors
        elseif data.RoomName == "CharonFight01" then
            -- don't unlock any doors, will exit via the bag
            OfferedExitDoors = {}
        end
    end

    return baseFunc(run, room)
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("GenerateEncounter", function(baseFunc, run, room, encounter)
    local depth = SeedOfTheWeek.GetRunDepth(run) + 1
    print("GenerateEncounter", depth)
    local orginalEnemySet = encounter.EnemySet
    local originalMinWaves = encounter.MinWaves
    local originalMaxWaves = encounter.MinWaves
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        encounter.EnemySet = data.EnemySet
        encounter.MinWaves = data.Waves
        encounter.MaxWaves = data.Waves
    end
    baseFunc(run, room, encounter)
    encounter.EnemySet = originalEnemySet
    encounter.MinWaves = originalMinWaves
    encounter.MaxWaves = originalMaxWaves
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("PickEliteAttributes", function(baseFunc, room, enemy)
    local depth = SeedOfTheWeek.GetRunDepth(CurrentRun)
    print("PickEliteAttributes", depth)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        if data.EliteAttributes ~= nil then
            local attributes = data.EliteAttributes[enemy.Name]
            room.EliteAttributes[enemy.Name] = data.EliteAttributes[enemy.Name]
        else
            local result = baseFunc(room, enemy)
            deep_print(room.EliteAttributes)
            return result
        end
    else
        return baseFunc(room, enemy)
    end
end)

ModUtil.WrapBaseFunction("SelectSpawnPoint", function(baseFunc, room, enemy, encounter)
    local depth = SeedOfTheWeek.GetRunDepth(CurrentRun)
    print("SelectSpawnPoint", depth, enemy.Name)
    if config.Enabled and encounter.PreSpawning then
        local data = SeedOfTheWeekRoute[depth]
        if data.PreSpawnPoints ~= nil and 
           data.PreSpawnPoints[enemy.Name] ~= nil then
            local result = table.remove(data.PreSpawnPoints[enemy.Name])
            if result ~= nil then
                print("  ", enemy.Name, result)
                return result
            end
        else
            local result = baseFunc(room, enemy, encounter)
            print("  ", enemy.Name, result)
            return result
        end
    end
    return baseFunc(room, enemy, encounter)
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("RunUnthreadedEvents", function(baseFunc, events, eventSource)
    local original = {}
    if events ~= nil and config.Enabled then
        for k, v in pairs(events) do
            -- force Charon bag (by removing requirements) if the next room is the Charon fight
            if type(v) == "table" and v.FunctionName == "CheckForbiddenShopItem" then
                local depth = SeedOfTheWeek.GetRunDepth(CurrentRun) + 1
                local data = SeedOfTheWeekRoute[depth]
                if data.RoomName == "CharonFight01" then
                    original[k] = DeepCopyTable(v)
                    v.GameStateRequirements = nil
                end
            end
        end
    end
    baseFunc(events, eventSource)
    if events ~= nil then
        for k, v in pairs(original) do
            events[k] = v
        end
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("FillInShopOptions", function(baseFunc, args)
    if config.Enabled then
        local depth = SeedOfTheWeek.GetRunDepth(CurrentRun)
        print("FillInShopOptions", depth)
        local data = SeedOfTheWeekRoute[depth]
        if data.StoreOptions ~= nil then
            deep_print(data.StoreOptions)
            return { StoreOptions = data.StoreOptions }
        else
           return baseFunc(args)
        end
    else
        local store = baseFunc(args)
        deep_print(store)
        return store
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("PurchaseConsumableItem", function(baseFunc, run, item, args)
    if config.Enabled then
        local depth = SeedOfTheWeek.GetRunDepth(run) + 1
        local data = SeedOfTheWeekRoute[depth]
        if item.UseText == "UseCharonStoreDiscount" and data == nil then
            -- end of a loyalty card route
            local originalThreadedFunctionNames = item.UseThreadedFunctionNames
            item.UseThreadedFunctionNames = { "ShowRunClearScreen" }
            baseFunc(run, item, arg)
            item.UseThreadedFunctionNames = originalThreadedFunctionNames
        else
            return baseFunc(run, item, args)
        end
    else
        return baseFunc(run, item, args)
    end
end, SeedOfTheWeek)

ModUtil.WrapBaseFunction("IsMetaUpgradeSelected", function(baseFunc, name)
    if config.Enabled then
        if name == "RerollMetaUpgrade" then
            return false
        elseif name == "RerollPanelMetaUpgrade" then
            return false
        end
    end
    return baseFunc(name)
end, SeedOfTheWeek)
