ModUtil.RegisterMod("SeedOfTheWeek")

local config = {
    ModName = "Seed of the Week",
    Enabled = true
}
  
if ModConfigMenu then
    ModConfigMenu.Register(config)
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
        },
        EncounterName = "GeneratedTartarus"
    },
    [2] = {
        RoomSetName = "Tartarus",
        RoomName = "A_Combat08A",
        ChosenRewardType = "GiftDropRunProgress",
        EncounterName = "GeneratedTartarus"
    },
    [3] = {
        RoomSetName = "Tartarus",
        RoomName = "A_Combat07",
        ChosenRewardType = "Boon",
        ForceLootName = "ZeusUpgrade",
        EncounterName = "GeneratedTartarus"
    }
}

function SeedOfTheWeek.GetRunDepth(run)
    if run.GameplayTime == 0 then
        return 0
    else
        return GetRunDepth(run)
    end
end


ModUtil.WrapBaseFunction("ChooseRoomReward", function(baseFunc, run, room, rewardStoreName, previouslyChosenRewards)
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

ModUtil.WrapBaseFunction("SetTraitsOnLoot", function(baseFunc, lootData, args)
    local depth = SeedOfTheWeek.GetRunDepth(CurrentRun) + 1
    print("SetTraitsOnLoot", depth)
    if config.Enabled then
        local data = SeedOfTheWeekRoute[depth]
        lootData.UpgradeOptions = data.UpgradeOptions
    else
        baseFunc(lootData, args) -- mutates lootData
    end
end, SeedOfTheWeek)

-- ModUtil.WrapBaseFunction("ChooseEncounter", function(baseFunc, run, room)
--     local depth = GetRunDepth(run)
--     if config.Enabled then
--         local data = SeedOfTheWeekRoute[depth]
--         local encounterData = EncounterData[data.EncounterName]
--         -- TODO Generated Encounters w/ overridden waves etc
--         local encounter = SetupEncounter(run, room)
--         return encounter
--     else
--         print("ChooseEncounter", depth)
--         return baseFunc(run, room)
--     end
-- end, SeedOfTheWeek)

