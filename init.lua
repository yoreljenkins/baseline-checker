-- Baseline Checker - Neovim plugin for browser compatibility checking
-- Main entry point and user command definitions

local compat_data = require('baseline-checker.compat_data')
local linter = require('baseline-checker.linter')
local api = require('baseline-checker.api')

local M = {}

M.config = {
  auto_lint = true,
  show_virtual_text = true,
  update_on_startup = false,
  keymaps = {
    check_baseline = '<leader>cb',
    toggle_linter = '<leader>ct',
    update_data = '<leader>cu'
  }
}

function M.setup(opts)
  if opts then
    M.config = vim.tbl_deep_extend('force', M.config, opts)
  end
  compat_data.initialize()
  if M.config.auto_lint then
    linter.setup_autocmds()
  end
  if M.config.update_on_startup then
    api.update_compatibility_data()
  end
  M.setup_commands()
  M.setup_keymaps()
  print('Baseline Checker plugin loaded')
end

function M.check_baseline(property)
  if not property or property == '' then
    property = vim.fn.input('Enter CSS property to check: ')
    if property == '' then
      return
    end
  end
  local info = compat_data.get_property_info(property)

  if not info then
    local feature_data = api.fetch_feature_by_id(property)
    if feature_data and feature_data.features and #feature_data.features > 0 then
      local feature = feature_data.features[1] 
      info = api.convert_webstatus_feature_to_compat_data(feature)
      if info then
        compat_data.update_property(property, info)
      end
    end
  end

  if not info then
    print(string.format('No compatibility data found for "%s"', property))
    print('Try running :BaselineUpdate to fetch latest data from web.dev')
    return
  end

  local lines = {
    string.format('Property: %s', property),
    string.format('Status: %s', info.status:upper()),
    string.format('Baseline: %s', info.baseline and 'Yes' or 'No'),
    '',
    'Browser Support:',
    string.format('  Chrome: %s', info.support.chrome),
    string.format('  Firefox: %s', info.support.firefox),
    string.format('  Safari: %s', info.support.safari),
    string.format('  Edge: %s', info.support.edge),
    '',
    'Description:',
    info.description,
    '',
    '📡 Data source: web.dev baseline API'
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'delete'
  vim.bo[buf].modifiable = false

  local width = 60
  local height = #lines + 2
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local _ = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Baseline Compatibility ',
    title_pos = 'center'
  })


  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':q<CR>', { noremap = true, silent = true })
end

function M.show_feature_stats()
  local properties = compat_data.get_all_properties()
  local stats = {
    total = 0,
    widely = 0,
    newly = 0,
    limited = 0,
    experimental = 0,
    unknown = 0
  }

  for _, prop in ipairs(properties) do
    local info = compat_data.get_property_info(prop)
    stats.total = stats.total + 1

    if info then
      if info.baseline_category == 'widely' then
        stats.widely = stats.widely + 1
      elseif info.baseline_category == 'newly' then
        stats.newly = stats.newly + 1
      elseif info.baseline_category == 'limited' then
        stats.limited = stats.limited + 1
      elseif info.status == 'experimental' then
        stats.experimental = stats.experimental + 1
      else
        stats.unknown = stats.unknown + 1
      end
    else
      stats.unknown = stats.unknown + 1
    end
  end

  local lines = {
    'Baseline Checker Feature Statistics:',
    '',
    string.format('Total features: %d', stats.total),
    string.format('✓ Widely available: %d', stats.widely),
    string.format('🆕 Newly available: %d', stats.newly),
    string.format('⚠ Limited availability: %d', stats.limited),
    string.format('🧪 Experimental: %d', stats.experimental),
    string.format('? Unknown: %d', stats.unknown),
    '',
    'Use :BaselineUpdate to fetch latest data from web.dev'
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'delete'
  vim.bo[buf].modifiable = false

  local width = 50
  local height = #lines + 2
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local _ = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Feature Statistics ',
    title_pos = 'center'
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':q<CR>', { noremap = true, silent = true })
end

function M.list_properties()
  local properties = compat_data.get_all_properties()

  if #properties == 0 then
    print('No compatibility data available')
    return
  end

  local lines = { 'Known CSS Properties:' }
  for _, prop in ipairs(properties) do

    local info = compat_data.get_property_info(prop)
    local status_icon = info.baseline and '✓' or '⚠'
    local category = info.baseline_category or 'local'
    table.insert(lines, string.format('  %s %s (%s - %s)', status_icon, prop, info.status, category))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'delete'
  vim.bo[buf].modifiable = false

  local width = 70
  local height = math.min(#lines + 2, 20)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local _ = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Available Properties ',
    title_pos = 'center'
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':q<CR>', { noremap = true, silent = true })
end

function M.setup_commands()
  vim.api.nvim_create_user_command('CheckBaseline', function(opts)
    M.check_baseline(opts.args)
  end, { 
    nargs = '?',
    desc = 'Check browser compatibility for CSS property',
    complete = function()
      return compat_data.get_all_properties()
    end
  })

  vim.api.nvim_create_user_command('BaselineList', function()
    M.list_properties()
  end, { desc = 'List all known CSS properties' })

  vim.api.nvim_create_user_command('BaselineStats', function()
    M.show_feature_stats()
  end, { desc = 'Show baseline feature statistics by category' })

  vim.api.nvim_create_user_command('BaselineToggle', function()
    linter.toggle()
  end, { desc = 'Toggle baseline compatibility linting' })

  vim.api.nvim_create_user_command('BaselineUpdate', function()
    api.update_compatibility_data()
  end, { desc = 'Update compatibility data from external sources' })

  vim.api.nvim_create_user_command('BaselineCache', function()
    local stats = api.get_cache_stats()
    print(string.format('Cache: %d entries, oldest: %s, newest: %s',
          stats.entries, stats.oldest, stats.newest))
  end, { desc = 'Show API cache statistics' })

  vim.api.nvim_create_user_command('BaselineTest', function()
    api.test_api_connectivity()
  end, { desc = 'Test web.dev API connectivity' })
end

function M.setup_keymaps()
  if M.config.keymaps.check_baseline then
    vim.keymap.set('n', M.config.keymaps.check_baseline, function()
      M.check_baseline()
    end, { desc = 'Check baseline compatibility' })
  end

  if M.config.keymaps.toggle_linter then
    vim.keymap.set('n', M.config.keymaps.toggle_linter, function()
      linter.toggle()
    end, { desc = 'Toggle baseline linter' })
  end

  if M.config.keymaps.update_data then
    vim.keymap.set('n', M.config.keymaps.update_data, function()
      api.update_compatibility_data()
    end, { desc = 'Update compatibility data' })
  end
end

return M
