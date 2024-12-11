CORE = exports.zrx_utility:GetUtility()

CreateThread(function()
    if Config.CheckForUpdates then
        CORE.Server.CheckVersion('zrx_quickping')
    end
end)

RegisterNetEvent('wrp_quickping:client:receivePing', function(coords, entity, icon)
    local xPlayer = CORE.Bridge.getPlayerObject(source)

    if not xPlayer then
        return
    end

    if not Config.Jobs[xPlayer.job.name] then
        return
    end

    local xPlayers = CORE.Bridge.getExtendedPlayers('job', xPlayer.job.name)
    CORE.Bridge.notification(xPlayer.source, Strings.placed_desc, Strings.placed_title, 'info')

    for k, data in pairs(xPlayers) do
        TriggerClientEvent('wrp_quickping:client:receivePing', data.source, {
            coords = coords,
            duration = Config.Jobs[xPlayer.job.name].duration,
            color = Config.Jobs[xPlayer.job.name].color,
            blipColor = Config.Jobs[xPlayer.job.name].blipColor,
            pid = source,
            name = xPlayer.name,
            entity = entity,
            icon = icon,
        })
    end
end)