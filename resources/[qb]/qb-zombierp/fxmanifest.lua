fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GitHub Copilot'
description 'QB-Core ZombieRP Server - Versión Mejorada'
version '2.0.0'

shared_scripts {
  'config.lua',
  'shared/*.lua'
}

client_scripts {
  'client/client_improved.lua',
  'client/battlepass.lua',
  'client/map_ui.lua',
  'client/safe_zones.lua',
  'client/events.lua'
}

server_scripts {
  'server/server_improved.lua',
  'server/battlepass.lua',
  'server/map_zones.lua',
  'server/rewards.lua'
}

files {
  'html/index.html',
  'html/css/style.css',
  'html/js/ui.js'
}

ui_page 'html/index.html'

dependency 'qb-core'
