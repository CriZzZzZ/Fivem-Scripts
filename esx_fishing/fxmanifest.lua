fx_version 'cerulean'
game 'gta5'

author 'Cristiano Barroca'
description 'Sistema de Pesca ESX Completo'
version '1.2.0'

shared_script 'config.lua'

client_script 'client.lua'
server_script {
    '@oxmysql/lib/MySQL.lua', -- ou mysql-async
    'server.lua'
}
