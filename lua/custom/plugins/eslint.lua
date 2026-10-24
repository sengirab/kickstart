-- ESLint fixes for projects that have an ESLint config (the `eslint` server is enabled in init.lua).
-- Conform/Prettier format-on-save is unchanged; ESLint runs as a separate step.

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-eslint', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not (client and client.name == 'eslint') then return end

    -- Apply every auto-fixable ESLint problem in the current file (e.g. key alignment).
    -- `LspEslintFixAll` is defined by nvim-lspconfig's eslint config.
    vim.keymap.set('n', '<leader>F', '<Cmd>LspEslintFixAll<CR>', { buffer = event.buf, desc = 'ESLint: [F]ix file' })

    -- Fix on save (disabled): uncomment to run the same fixes on every write, after conform's
    -- format-on-save. Note that the first save of a file that has never been fixed rewrites the
    -- whole file, so the reformat ends up in the same diff as your edit. To keep them apart,
    -- save once before editing and commit that, or stage with `git add -p`.
    -- `LspEslintFixAll` is synchronous, so the fixes land before the file is written.
    --
    -- vim.api.nvim_create_autocmd('BufWritePre', {
    --   group = vim.api.nvim_create_augroup('custom-eslint-fix-on-save-' .. event.buf, { clear = true }),
    --   buffer = event.buf,
    --   command = 'LspEslintFixAll',
    -- })
  end,
})
