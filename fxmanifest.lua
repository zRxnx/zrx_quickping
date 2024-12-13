fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zRxnx'
description 'Advanced ping system'
version '1.1.0'

docs 'https://docs.zrxnx.at'
discord 'https://discord.gg/mcN25FJ33K'

dependencies {
    'zrx_utility',
	'ox_lib',
}

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
    'configuration/*.lua'
}

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}