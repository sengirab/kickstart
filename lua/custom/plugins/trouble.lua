-- Trouble: a persistent, auto-updating list for diagnostics, LSP results, symbols and quickfix
-- https://github.com/folke/trouble.nvim

vim.pack.add {
  -- Track main: v3.7.1 (latest tag) uses the treesitter `_on_line` hook removed in Neovim 0.12
  { src = 'https://github.com/folke/trouble.nvim', version = 'main' },
}

require('trouble').setup {}

require('which-key').add {
  { '<leader>x', group = 'Trouble' },
}

vim.keymap.set('n', '<leader>xx', '<Cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (workspace)' })
vim.keymap.set('n', '<leader>xX', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Diagnostics (buffer)' })
vim.keymap.set('n', '<leader>xs', '<Cmd>Trouble symbols toggle focus=false<CR>', { desc = 'Symbols outline' })
vim.keymap.set('n', '<leader>xl', '<Cmd>Trouble lsp toggle focus=false win.position=right<CR>', { desc = 'LSP definitions / references' })
vim.keymap.set('n', '<leader>xL', '<Cmd>Trouble loclist toggle<CR>', { desc = 'Location list' })
vim.keymap.set('n', '<leader>xQ', '<Cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix list' })

-- Project-wide TypeScript check: the LSP only reports diagnostics for open buffers,
-- so run `tsc --noEmit` and show every error in Trouble's quickfix view.

local tsc_cache = {} ---@type table<string, string|false>

local function tsc_major(bin)
  local out = vim.system({ bin, '--version' }, { text = true }):wait()
  local version = out.code == 0 and vim.version.parse(out.stdout or '') or nil
  return version and version.major or 0
end

-- Prefer TypeScript 7+ (native, ~10x faster than 5.x): the project's own tsc if it is 7+,
-- else tsc on PATH (Mason's, same as the LSP), else the project's older tsc.
local function find_tsc(root)
  if tsc_cache[root] ~= nil then return tsc_cache[root] end
  local project_tsc
  local dir = root
  while dir and not project_tsc do
    local bin = vim.fs.joinpath(dir, 'node_modules', '.bin', 'tsc')
    if vim.fn.executable(bin) == 1 then project_tsc = bin end
    local parent = vim.fs.dirname(dir)
    dir = parent ~= dir and parent or nil
  end
  local tsc = (project_tsc and tsc_major(project_tsc) >= 7 and project_tsc) or (vim.fn.executable 'tsc' == 1 and 'tsc') or project_tsc or false
  tsc_cache[root] = tsc
  return tsc
end

-- Parse `tsc --pretty false` output: `file(line,col): error TS1234: message`,
-- followed by indented continuation lines for chained messages.
local function parse_tsc(output, root)
  local items = {}
  for line in vim.gsplit(output, '\n', { trimempty = true }) do
    local file, lnum, col, severity, code, msg = line:match '^(.+)%((%d+),(%d+)%): (%a+) (TS%d+): (.*)$'
    if file then
      table.insert(items, {
        filename = vim.fs.joinpath(root, file),
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = severity == 'error' and 'E' or 'W',
        text = code .. ': ' .. msg,
      })
    elseif line:match '^%s' and #items > 0 then
      items[#items].text = items[#items].text .. '\n' .. vim.trim(line)
    else
      table.insert(items, { text = line, type = 'E' })
    end
  end
  return items
end

local function typecheck_project()
  local root = vim.fs.root(0, 'tsconfig.json')
  if not root then
    vim.notify('tsc: no tsconfig.json found', vim.log.levels.WARN)
    return
  end
  local tsc = find_tsc(root)
  if not tsc then
    vim.notify('tsc: executable not found', vim.log.levels.ERROR)
    return
  end

  -- Keep the incremental build cache in Neovim's cache dir: repeat runs are ~3x faster, and the
  -- project's own tsconfig.tsbuildinfo (used by its build tooling) is left alone.
  local cache_dir = vim.fs.joinpath(vim.fn.stdpath 'cache', 'tsc')
  vim.fn.mkdir(cache_dir, 'p')
  local build_info = vim.fs.joinpath(cache_dir, vim.fn.sha256(root):sub(1, 16) .. '.tsbuildinfo')

  vim.notify('tsc: checking ' .. vim.fn.fnamemodify(root, ':~') .. ' …')
  local cmd = { tsc, '--noEmit', '--pretty', 'false', '--incremental', '--tsBuildInfoFile', build_info }
  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local items = parse_tsc(result.stdout .. result.stderr, root)
      if #items == 0 then
        vim.notify 'tsc: no errors'
        return
      end
      vim.fn.setqflist({}, ' ', { title = 'tsc --noEmit', items = items })
      vim.cmd 'Trouble qflist open'
    end)
  end)
end

vim.keymap.set('n', '<leader>xt', typecheck_project, { desc = 'TypeScript errors (tsc --noEmit)' })
