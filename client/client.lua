CORE = exports.zrx_utility:GetUtility()
---@diagnostic disable: missing-parameter, param-type-mismatch
local isBusy = false
local lastPressTime = 0
local singleClickScheduled = false

RegisterCommand('+quick_ping', function()
    if isBusy then
        return
    end

    local currentTime = GetGameTimer() / 1000

    if (currentTime - lastPressTime) <= Config.DoubleClickTreshold then
        singleClickScheduled = false

        HandlePing(Config.Icons.normal)
    else
        singleClickScheduled = true

        SetTimeout(Config.DoubleClickTreshold * 1000, function()
            if singleClickScheduled then
                HandlePing(Config.Icons.warning)
            end
        end)
    end

    lastPressTime = currentTime
end)

RegisterCommand('-quick_ping', function() end)
RegisterKeyMapping('+quick_ping', Strings.place_desc, Config.Activation.mapping, Config.Activation.key)

HandlePing = function(icon)
    local _, entity, endCoords = lib.raycast.fromCamera(511, 4, 10000)
    local netId

    if endCoords.x == 0.0 or endCoords.y == 0.0 or endCoords.z  == 0.0 then
        return
    end

    if DoesEntityExist(entity) and GetEntityType(entity) == 1 or GetEntityType(entity) == 2 then
        netId = NetworkGetNetworkIdFromEntity(entity)
    end

    isBusy = true

    TriggerServerEvent('wrp_quickping:client:receivePing', endCoords, netId, icon)
end

RegisterNetEvent('wrp_quickping:client:receivePing', function(data)
    PlaceTemporaryMarker(data.coords, data.duration, data.pid, data.name, data.blipColor, data.entity, data.icon)
end)

PlaceTemporaryMarker = function(coords, duration, pid, name, blipColor, netId, icon)
    CreateThread(function()
        local endTime = GetGameTimer() + duration
        local blip = CORE.Client.CreateBlip(coords, 12, blipColor, 1.0, Strings.display_text:format(pid, name))
        local distance, entity
        local id = Config.UseUniqueID and exports.zrx_uniqueid:GetPlayerUIDfromSID(pid) or pid

        if netId then
            entity = NetworkGetEntityFromNetworkId(netId)
        end

        while GetGameTimer() < endTime do
            if DoesEntityExist(entity) then
                coords = GetEntityCoords(entity)
            end

            distance = #(GetEntityCoords(cache.ped) - coords)

            CORE.Client.DrawText3D(coords.x, coords.y, coords.z+8.0, Strings.display_text:format(id, name), 255, 255, 255, 0.2)
            CORE.Client.DrawText3D(coords.x, coords.y, coords.z+5.0, Strings.display_text_meter:format(math.round(distance, 0)), 255, 255, 255, 0.15)
            CORE.Client.DrawText3D(coords.x, coords.y, coords.z+0.5, icon, 255, 255, 255, 0.3)

            Wait(0)
        end

        RemoveBlip(blip)
        isBusy = false
    end)
end