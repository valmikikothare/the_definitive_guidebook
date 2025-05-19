vim.cmd.source('~/.vimrc')
vim.api_nvim_set_keymap('c', 'w!!', "<esc>:lua require'utils'.sudo_write()<CR>", { silent = true })
require("config.lazy")

