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

SeedOfTheWeekRoute = {
    [1] = {
        RoomSetName = "Tartarus", 
        RoomName = "RoomOpening",
        ChosenRewardType = "Boon",
        ForceLootName = "ArtemisUpgrade",
        UpgradeOptions = {
            [1] = {
                Type = "Trait",
                ItemName = "ArtemisWeaponTrait",
                Rarity = "Epic"
            },
            [2] = {
                Type = "Trait",
                ItemName = "ArtemisSecondaryTrait",
                Rarity = "Heroic"
            },
            [3] = {
                Type = "Trait",
                ItemName = "ArtemisRangedTrait",
                Rarity = "Rare"
            }
        }
    },
    [2] = {
        RoomSetName = "Tartarus",
        RoomName = "A_Combat08A",
        ChosenRewardType = "GiftDropRunProgress"
    },
    [3] = {
        RoomSetName = "Tartarus",
        RoomName = "A_Combat07",
        ChosenRewardType = "Boon",
        ForceLootName = "ZeusUpgrade",
        UpgradeOptions = {
            [1] = {
                Type = "Trait",
                ItemName = "ZeusRangedTrait",
                Rarity = "Rare"
            },
            [2] = {
                Type = "Trait",
                ItemName = "ZeusBonusBoltTrait",
                Rarity = "Epic"
            },
            [3] = {
                Type = "Trait",
                ItemName = "ZeusSecondaryTrait",
                Rarity = "Rare"
            }
        }
    }, 
    [4] = {
        RoomSetName = "Secrets",
        RoomName = "RoomSecret01",
        ChosenRewardType = "TrialUpgrade",
        UpgradeOptions = {
            [1] = {
                Type = "TransformingTrait",
                ItemName = "ChaosBlessingMetapointTrait",
                SecondaryItemName = "ChaosCursePrimaryAttackTrait",
                Rarity = "Common"
            },
            [2] = {
                Type = "TransformingTrait",
                ItemName = "ChaosBlessingSecondaryTrait",
                SecondaryItemName = "ChaosCurseHiddenRoomReward",
                Rarity = "Common"
            },
            [3] = {
                Type = "TransformingTrait",
                ItemName = "ChaosBlessingAmmoTrait",
                SecondaryItemName = "ChaosCurseDamageTrait",
                Rarity = "Epic"
            }
        }
    },
    [5] = {
        RoomSetName = "Tartarus",
        RoomName = "A_Combat13",
        ChosenRewardType = "Boon",
        ForceLootName = "AresUpgrade",
    }
}

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
        end
    end

    return baseFunc(run, room)
end, SeedOfTheWeek)
