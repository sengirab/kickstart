-- render-markdown: renders headings, lists, checkboxes, code blocks, tables and callouts in
-- markdown buffers. The line under the cursor and insert mode show the raw markdown.
-- Uses the `markdown` and `markdown_inline` treesitter parsers installed in init.lua.
-- https://github.com/MeanderingProgrammer/render-markdown.nvim

vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  -- LaTeX math needs the `latex` parser plus `utftex` or `latex2text`, neither of which is installed
  latex = { enabled = false },
}

vim.keymap.set('n', '<leader>tm', '<Cmd>RenderMarkdown buf_toggle<CR>', { desc = '[T]oggle [M]arkdown rendering' })
