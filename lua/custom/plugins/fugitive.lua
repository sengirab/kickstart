-- Fugitive: a full git client in Neovim (`:Git` status, commit, blame, log, diffs, merge conflicts).
-- Complements gitsigns.nvim, which handles the hunks in the current buffer.
-- https://github.com/tpope/vim-fugitive

vim.pack.add { 'https://github.com/tpope/vim-fugitive' }

require('which-key').add {
  { '<leader>g', group = '[G]it' },
}

vim.keymap.set('n', '<leader>gs', '<Cmd>Git<CR>', { desc = '[G]it [S]tatus' })
vim.keymap.set('n', '<leader>gb', '<Cmd>Git blame<CR>', { desc = '[G]it [B]lame (whole file)' })
vim.keymap.set('n', '<leader>gd', '<Cmd>Gdiffsplit<CR>', { desc = '[G]it [D]iff file against index' })
vim.keymap.set('n', '<leader>gl', '<Cmd>Git log --oneline --decorate<CR>', { desc = '[G]it [L]og' })
vim.keymap.set('n', '<leader>gL', '<Cmd>0Gclog<CR>', { desc = '[G]it [L]og of this file (quickfix)' })
vim.keymap.set('n', '<leader>gw', '<Cmd>Gwrite<CR>', { desc = '[G]it stage file ([W]rite)' })
vim.keymap.set('n', '<leader>gf', '<Cmd>Git fetch<CR>', { desc = '[G]it [F]etch' })
