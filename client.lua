Citizen.CreateThread(function()
    while true do
        local plyPos = GetEntityCoords(PlayerPedId())
        local vehicle = VehicleInFront(plyPos)
        local trunk = GetEntityBoneIndexByName(vehicle, 'boot')
        if trunk ~= -1 then
            local coords = GetWorldPositionOfEntityBone(vehicle, trunk)
            if #(plyPos - coords) <= 1.5 then
                if not inTrunk then
                    if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                        lib.showTextUI('[H] - Open')
                        if IsControlJustReleased(0, 74)then
                            SetCarBootOpen(vehicle)
                            lib.hideTextUI()
                        end
                    else
                        lib.showTextUI('[H] - Close\n[E] - Hide')
                        if IsControlJustReleased(0, 74) then
                            SetVehicleDoorShut(vehicle, 5)
                            lib.hideTextUI()
                        end
                    end
                end
                if IsControlJustReleased(0, 38) and not inTrunk then
                    getInTrunk(vehicle)
                    lib.hideTextUI()
                end
            end
        end
        Citizen.Wait(0)
    end
end)

function getInTrunk(veh)
    local model = GetEntityModel(veh)
    if not DoesVehicleHaveDoor(veh, 6) and DoesVehicleHaveDoor(veh, 5) and IsThisModelACar(model) then
        SetVehicleDoorOpen(veh, 5, 1)
        local plyPed = PlayerPedId()

        local d1,d2 = GetModelDimensions(model)

        local trunkDic = "fin_ext_p1-7"
        local trunkAnim = "cs_devin_dual-7"
        LoadAnimDict(trunkDic)

        SetBlockingOfNonTemporaryEvents(plyPed, true)                   
        DetachEntity(plyPed)
        ClearPedTasks(plyPed)
        ClearPedSecondaryTask(plyPed)
        ClearPedTasksImmediately(plyPed)
        TaskPlayAnim(plyPed, trunkDic, trunkAnim, 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)

        AttachEntityToEntity(plyPed, veh, 0, -0.1,d1["y"]+0.85,d2["z"]-0.87, 0, 0, 40.0, 1, 1, 1, 1, 1, 1)
        inTrunk = true
        trunkVeh = veh

        while inTrunk do
            Citizen.Wait(0)
            local coords = GetEntityCoords(PlayerPedId())
            lib.showTextUI('[F] - Get Out')

            if IsControlJustReleased(0, 23) then
                inTrunk = false
                lib.hideTextUI()
            end

            if not IsEntityPlayingAnim(plyPed, trunkDic, trunkAnim, 3) then
                TaskPlayAnim(plyPed, trunkDic, trunkAnim, 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
            end

            if not DoesEntityExist(veh) then
                inTrunk = false
            end
        end
        RemoveAnimDict(trunkDic)
        SetVehicleDoorOpen(veh, 5, 1, 0)
        DetachEntity(plyPed)
        Citizen.Wait(10)
        if DoesEntityExist(veh) then 
            local dropPosition = GetOffsetFromEntityInWorldCoords(veh, 0.0,d1["y"]-0.6,0.0)
            SetEntityCoords(plyPed,dropPosition["x"],dropPosition["y"],dropPosition["z"])
        else
            ClearPedTasks(plyPed)
            local plyCoords = GetEntityCoords(plyPed)
            SetEntityCoords(plyped, plyCoords.x, plyCoords.y, plyCoords.x+2)
        end
        trunkVeh = nil
    end
end

function VehicleInFront()
    local plyPed = PlayerPedId()
    local pos = GetEntityCoords(plyPed)
    local entityWorld = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 3.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, plyPed, 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do RequestAnimDict(dict) Citizen.Wait(5); end
end
