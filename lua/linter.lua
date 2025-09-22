-- CSS linter module with virtual text support
-- This module provides real-time linting for CSS files

local compat_data = require('baseline-checker.compat_data')

local M = {}

local ns_id = vim.api.nvim_create_namespace('baseline_checker')

M.config = {
  enabled = true,
  show_virtual_text = true,
  virtual_text_prefix = '',
  highlight_groups = {
    baseline = 'DiagnosticVirtualTextInfo',
    limited = 'DiagnosticVirtualTextWarn',
    experimental = 'DiagnosticVirtualTextError',
    unknown = 'DiagnosticVirtualTextHint'
  }
}

local function is_common_css_value(term)
  local common_values = {
    'auto', 'none', 'inherit', 'initial', 'unset', 'revert',
    'block', 'inline', 'flex', 'grid', 'table', 'inline-block',
    'absolute', 'relative', 'fixed', 'static', 'sticky',
    'hidden', 'visible', 'scroll', 'auto',
    'left', 'right', 'center', 'top', 'bottom',
    'bold', 'normal', 'italic',
    'solid', 'dashed', 'dotted', 'double',
    'transparent', 'currentcolor',
    'px', 'em', 'rem', 'vh', 'vw', 'vmin', 'vmax', 'fr',
    'red', 'blue', 'green', 'black', 'white', 'gray', 'grey'
  }

  for _, value in ipairs(common_values) do
    if term == value then
      return true
    end
  end

  if string.match(term, '^%d') or string.match(term, '%d+') then
    return true
  end

  return false
end

local function extract_css_properties(line)
  local properties = {}
  for property in string.gmatch(line, '([%a][%w%-]*)%s*:') do
    if not is_common_css_value(property) and string.len(property) > 1 then
      table.insert(properties, property)
    end
  end
  return properties
end

local function get_highlight_group(status)
  return M.config.highlight_groups[status] or M.config.highlight_groups.unknown
end

local function format_virtual_text(_, info)
  if not info then
    return string.format('%sUnknown property', M.config.virtual_text_prefix)
  end

  local icon = info.baseline and '✓' or '⚠'
  local status_text = info.status:upper()

  return string.format('%s%s %s', M.config.virtual_text_prefix, icon, status_text)
end

local function lint_line(bufnr, line_num, line_content)
  if not M.config.enabled then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, line_num, line_num + 1)

  local properties = extract_css_properties(line_content)

  for _, property in ipairs(properties) do
    local info = compat_data.get_property_info(property)
    local status = compat_data.get_support_status(property)

    if M.config.show_virtual_text and info then
      if status == 'experimental' or status == 'limited' or status == 'unknown' then
        local virtual_text = format_virtual_text(property, info)
        local highlight_group = get_highlight_group(status)

        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, 0, {
          virt_text = {{virtual_text, highlight_group}},
          virt_text_pos = 'eol'
        })
      end
    elseif M.config.show_virtual_text and not info then
      if not is_common_css_value(property) then
        local virtual_text = format_virtual_text(property, nil)
        local highlight_group = get_highlight_group('unknown')

        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, 0, {
          virt_text = {{virtual_text, highlight_group}},
          virt_text_pos = 'eol'
        })
      end
    end
  end
end


function M.lint_buffer(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

local filetype = vim.bo[bufnr].filetype
  if filetype ~= 'css' and filetype ~= 'scss' and filetype ~= 'less' then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    lint_line(bufnr, i - 1, line)
  end
end

function M.clear_buffer(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

function M.toggle()
  M.config.enabled = not M.config.enabled

  if M.config.enabled then
    M.lint_buffer()
    print('Baseline LSP checker enabled')
  else
    M.clear_buffer()
    print('Baseline LSP checker disabled')
  end
end

function M.setup_autocmds()
  vim.api.nvim_create_augroup('BaselineChecker', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
    group = 'BaselineChecker',
    pattern = { '*.css', '*.scss', '*.less', '*.sass', '*.styl' },
    callback = function(args)
      vim.defer_fn(function()
        M.lint_buffer(args.buf)
      end, 100)
    end
  })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = 'BaselineChecker',
    pattern = { '*.css', '*.scss', '*.less' },
    callback = function(args)
      M.clear_buffer(args.buf)
    end
  })
end

return M
