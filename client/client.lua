---@diagnostic disable: missing-parameter, param-type-mismatch
local isBusy = false
local lastPressTime = 0
local doubleClickThreshold = 0.3
local singleClickScheduled = false

RegisterCommand('+quick_ping', function()
    if isBusy then
        return
    end

    local currentTime = GetGameTimer() / 1000

    if (currentTime - lastPressTime) <= doubleClickThreshold then
        singleClickScheduled = false

        HandlePing('⚠️')
    else
        singleClickScheduled = true

        SetTimeout(doubleClickThreshold * 1000, function()
            if singleClickScheduled then
                HandlePing('📍')
            end
        end)
    end

    lastPressTime = currentTime
end)

RegisterCommand('-quick_ping', function()
end)
RegisterKeyMapping('+quick_ping', Strings.place_desc, 'MOUSE_BUTTON', 'MOUSE_MIDDLE')

HandlePing = function(icon)
    local _, entity, endCoords = lib.raycast.fromCamera(511, 4, 1000.0)
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
    PlaceTemporaryMarker(data.coords, data.duration, data.color, data.pid, data.name, data.blipColor, data.entity, data.icon)
end)

DrawText3D = function(x, y, z, text, r, g, b, scale)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0, scale or 0.2)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(0, 0)
    ClearDrawOrigin()
end

CreateBlip = function(coords, sprite, color, scale, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)

    return blip
end

PlaceTemporaryMarker = function(coords, duration, color, pid, name, blipColor, netId, icon)
    CreateThread(function()
        local endTime = GetGameTimer() + duration
        local blip = CreateBlip(coords, 12, blipColor, 1.0, Strings.display_text:format(pid, name))
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

            --DrawMarker(1, coords.x, coords.y, coords.z, nil, nil, nil, nil, nil, nil, 1.0, 1.0, 10000.0, color.r, color.g, color.b, color.a, false, true, 2, false, nil, nil, nil)
            DrawText3D(coords.x, coords.y, coords.z+8.0, Strings.display_text:format(id, name), 255, 255, 255, 0.2)
            DrawText3D(coords.x, coords.y, coords.z+5.0, Strings.display_text_meter:format(Round(distance, 0)), 255, 255, 255, 0.15)
            DrawText3D(coords.x, coords.y, coords.z+0.5, icon, 255, 255, 255, 0.3)

            Wait(0)
        end

        RemoveBlip(blip)
        isBusy = false
    end)
end

Round = function(num, decimalPlaces)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", num))
end