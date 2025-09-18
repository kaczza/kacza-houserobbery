fx_version 'cerulean'
games { 'gta5' }
author 'Kacza'
description 'Kz-houserobbery'
lua54 'yes'

server_script 'server.lua'


client_script 'client.lua'
    


shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
