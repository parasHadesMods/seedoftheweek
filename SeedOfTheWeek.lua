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
