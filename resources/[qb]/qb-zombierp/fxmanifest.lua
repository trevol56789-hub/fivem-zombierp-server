fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GitHub Copilot'
description 'QB-Core ZombieRP Server'
version '1.0.0'

shared_scripts {
  'config.lua',
  'shared/*.lua'
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua'
}

files {
  'html/*'
}

dependency 'qb-core'
