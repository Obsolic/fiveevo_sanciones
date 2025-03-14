fx_version('cerulean')
games({ 'gta5' })

server_scripts({
    '@mysql-async/lib/MySQL.lua',
    'Config.lua',
    'server/main.lua'
});

client_scripts({
    'client/main.lua'
});