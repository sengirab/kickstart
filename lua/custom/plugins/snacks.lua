-- snacks.nvim: a collection of small plugins. Only `image` is enabled here; the others stay off.
-- https://github.com/folke/snacks.nvim

vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {
  -- Shows images in the terminal with the kitty graphics protocol (Ghostty supports it):
  -- opening an image file displays it, and images in markdown/html are drawn in the buffer.
  -- ImageMagick (`magick`) converts every format except PNG; `:checkhealth snacks` shows what is missing.
  -- https://github.com/folke/snacks.nvim/blob/main/docs/image.md
  image = {},
}
