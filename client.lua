local inTrunk = false

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if inTrunk then
            local vehicle = GetEntityAttachedTo(PlayerPedId())
            if DoesEntityExist(vehicle) or not IsPedDeadOrDying(PlayerPedId()) or not IsPedFatallyInjured(PlayerPedId()) then
                local coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot'))
                SetEntityCollision(PlayerPedId(), false, false)
		DisableControlAction(0, 23, true) 
                lib.showTextUI('[F] - Get Out')

                if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                    SetEntityVisible(PlayerPedId(), false, false)
                else
                    if not IsEntityPlayingAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 3) then
                        loadDict('timetable@floyd@cryingonbed@base')
                        TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)

                        SetEntityVisible(PlayerPedId(), true, false)
                    end
                end
                if IsControlJustReleased(0, 47) and inTrunk then
                    SetCarBootOpen(vehicle)
                    SetEntityCollision(PlayerPedId(), true, true)
                    Wait(750)
                    inTrunk = false
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    ClearPedTasks(PlayerPedId())
                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))
                    Wait(250)
                    SetVehicleDoorShut(vehicle, 5)
                end
            else
                SetEntityCollision(PlayerPedId(), true, true)
                DetachEntity(PlayerPedId(), true, true)
                SetEntityVisible(PlayerPedId(), true, false)
                ClearPedTasks(PlayerPedId())
                SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))
            end
        end
    end
end)   

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(0) end
    while true do
        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0, 0, 70)
        if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle,-1)--GetPedInVehicleSeat(vehicle, false)
		then
            local trunk = GetEntityBoneIndexByName(vehicle, 'boot')
            if trunk ~= -1 then
                local coords = GetWorldPositionOfEntityBone(vehicle, trunk)
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true) <= 1.5 then
                    if not inTrunk then
                        if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                            lib.showTextUI('[H] - Open')
								if IsControlJustReleased(0, 74)then
								end
                        else
                            lib.showTextUI('[H] - Close\n[E] - Hide')
                        end
                    end
                    if IsControlJustReleased(0, 47) and not inTrunk then
                        local player = GetPlayerFromServerId(id)
                        local playerPed = GetPlayerPed(player)
						local playerPed2 = GetPlayerPed(-1)
							if DoesEntityExist(playerPed) then
								if not IsEntityAttached(playerPed) or GetDistanceBetweenCoords(GetEntityCoords(playerPed), GetEntityCoords(PlayerPedId()), true) >= 5.0 then
									SetCarBootOpen(vehicle)
									Wait(350)
									AttachEntityToEntity(PlayerPedId(), vehicle, -1, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)	
									loadDict('timetable@floyd@cryingonbed@base')
									TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
									Wait(50)
									inTrunk = true

									Wait(1500)
									SetVehicleDoorShut(vehicle, 5)
								end
							end
                    end
                end
            end
        end
        Wait(0)
    end
end)

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end

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
                        if IsControlJustReleased(0, 74)then
                            SetCarBootOpen(vehicle)
                        end
                    else
                        if IsControlJustReleased(0, 74) then
                            SetVehicleDoorShut(vehicle, 5)
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

function VehicleInFront()
    local plyPed = PlayerPedId()
    local pos = GetEntityCoords(plyPed)
    local entityWorld = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 3.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, plyPed, 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end
