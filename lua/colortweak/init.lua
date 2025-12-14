-- colortweak.nvim: HSL transforms for highlight groups
local color = require("colortweak.color")

local M = {}

M.config = {}
local original_highlights = {}
local applied_ft = nil

local function get_highlight(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or not hl or vim.tbl_isempty(hl) then
    return nil
  end
  return hl
end

local function int_to_hex(int)
  if not int then return nil end
  return string.format("#%06x", int)
end

local function transform_highlight(group, opts)
  local hl = get_highlight(group)
  if not hl then return end

  if not original_highlights[group] then
    original_highlights[group] = vim.deepcopy(hl)
  end

  local new_hl = vim.deepcopy(hl)

  if hl.fg then
    new_hl.fg = color.transform(int_to_hex(hl.fg), opts)
  end

  if hl.bg then
    new_hl.bg = color.transform(int_to_hex(hl.bg), opts)
  end

  if hl.sp then
    new_hl.sp = color.transform(int_to_hex(hl.sp), opts)
  end

  vim.api.nvim_set_hl(0, group, new_hl)
end

local function restore_highlight(group)
  if original_highlights[group] then
    vim.api.nvim_set_hl(0, group, original_highlights[group])
  end
end

local function matches_pattern(group, pattern)
  local lua_pattern = pattern:gsub("%.", "%%."):gsub("%*", ".*")
  return group:match("^" .. lua_pattern .. "$") ~= nil
end

local function get_all_highlights()
  local groups = {}
  local output = vim.api.nvim_exec2("highlight", { output = true })
  for line in output.output:gmatch("[^\n]+") do
    local group = line:match("^(%S+)")
    if group then
      groups[group] = true
    end
  end
  return groups
end

local function apply_pattern_transforms(patterns)
  local all_groups = get_all_highlights()
  for group in pairs(all_groups) do
    for pattern, transform in pairs(patterns) do
      if matches_pattern(group, pattern) then
        transform_highlight(group, transform)
      end
    end
  end
end

local function apply_ft_transforms(ft, ft_opts)
  if ft_opts.patterns then
    apply_pattern_transforms(ft_opts.patterns)
  else
    local ft_suffix = "." .. ft
    local all_groups = get_all_highlights()
    for group in pairs(all_groups) do
      if group:match(ft_suffix .. "$") or (group:match("^@markup") and ft == "markdown") then
        transform_highlight(group, ft_opts)
      end
    end
  end
end

local function get_active_config()
  local colorscheme = vim.g.colors_name
  local active = {}

  if M.config.global then
    active = vim.deepcopy(M.config.global)
  end

  if colorscheme and M.config[colorscheme] then
    active = vim.tbl_deep_extend("force", active, M.config[colorscheme])
  end

  return active
end

local function restore_all()
  for group in pairs(original_highlights) do
    restore_highlight(group)
  end
  original_highlights = {}
end

function M.apply()
  restore_all()

  local active = get_active_config()
  if vim.tbl_isempty(active) then return end

  if active.patterns then
    apply_pattern_transforms(active.patterns)
  end

  local ft = vim.bo.filetype
  if ft and ft ~= "" and active.ft then
    applied_ft = ft
    local base_ft = ft:match("^([^.]+)")
    if active.ft[ft] then
      apply_ft_transforms(ft, active.ft[ft])
    elseif base_ft and active.ft[base_ft] then
      apply_ft_transforms(base_ft, active.ft[base_ft])
    end
  end
end

function M.setup(opts)
  M.config = opts or {}

  vim.api.nvim_create_user_command("ColortweakReload", function()
    M.apply()
    print("colortweak reloaded")
  end, {})

  local group = vim.api.nvim_create_augroup("colortweak", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      original_highlights = {}
      vim.defer_fn(M.apply, 1)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function()
      M.apply()
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function()
      local ft = vim.bo.filetype
      if ft ~= applied_ft then
        M.apply()
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "LazyReload",
    callback = function()
      vim.defer_fn(M.apply, 1000)
    end,
  })

  M.apply()
end

return M
