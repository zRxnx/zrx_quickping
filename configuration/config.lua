Config = {}
Config.CheckForUpdates = true --| Check for updates?
Config.UseUniqueID = false --| If using zrx_uniqueid
Config.DoubleClickTreshold = 0.3 --| Wait time to check for double click

Config.Activation = {
    mapping = 'MOUSE_BUTTON',
    key = 'MOUSE_MIDDLE'
}

Config.Icons = {
    normal = '📍',
    warning = '⚠️',
}

Config.Jobs = {
    police = {
        duration = 5000,
        color = { r = 0, g = 0, b = 255, a = 150 },
        blipColor = 4
    },

    ambulance = {
        duration = 5000,
        color = { r = 255, g = 0, b = 0, a = 150 },
        blipColor = 49
    },
}