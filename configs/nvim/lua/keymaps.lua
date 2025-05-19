local map = vim.keymap.set
local utils = require("utils")

map('c', 'w!!', utils.sudo_write, { silent = true })

