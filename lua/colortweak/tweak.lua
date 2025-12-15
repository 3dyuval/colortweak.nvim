-- colortweak/tweak.lua: Create tweaked highlight groups
local color = require("colortweak.color")

local M = {}

-- Store registered highlights for re-application on colorscheme change
local registered = {}
local augroup = nil

local function int_to_hex(int)
  if not int then
    return nil
  end
  return string.format("#%06x", int)
end

--- Get highlight definition with colors transformed
---@param source string Source highlight group name
---@param transform table { h = hue_shift, s = sat_mult, l = light_mult }
---@return table Highlight definition for nvim_set_hl
function M.get(source, transform)
  local hl = vim.api.nvim_get_hl(0, { name = source, link = false })
  if vim.tbl_isempty(hl) then
    return {}
  end

  if hl.fg then
    hl.fg = color.transform(int_to_hex(hl.fg), transform)
  end
  if hl.bg then
    hl.bg = color.transform(int_to_hex(hl.bg), transform)
  end
  if hl.sp then
    hl.sp = color.transform(int_to_hex(hl.sp), transform)
  end

  return hl
end

local function apply_single(name, source, transform)
  local hl = M.get(source, transform)
  if not vim.tbl_isempty(hl) then
    vim.api.nvim_set_hl(0, name, hl)
  end
end

local function apply_all()
  for name, def in pairs(registered) do
    apply_single(name, def[1], def[2])
  end
end

local function ensure_augroup()
  if not augroup then
    augroup = vim.api.nvim_create_augroup("colortweak_tweak", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = augroup,
      callback = function()
        vim.defer_fn(apply_all, 1)
      end,
    })
  end
end

--- Create highlight group(s) from source(s) with HSL transform
--- Automatically re-applies on colorscheme change
---@param name string New highlight group name
---@param source string Source highlight group name
---@param transform table { h = hue_shift, s = sat_mult, l = light_mult }
---@overload fun(map: table<string, {[1]: string, [2]: table}>)
function M.hl(name, source, transform)
  -- Single: tweak.hl("New", "Source", { h = 120 })
  if type(name) == "string" then
    ensure_augroup()
    registered[name] = { source, transform }
    apply_single(name, source, transform)
    return
  end

  -- Map: tweak.hl({ New = { "Source", { h = 120 } } })
  for hl_name, def in pairs(name) do
    M.hl(hl_name, def[1], def[2])
  end
end

--- Clear all registered highlights and release augroup
function M.clear()
  registered = {}
  if augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
    augroup = nil
  end
end

--- Remove a specific highlight from registry
---@param name string Highlight group name to unregister
function M.remove(name)
  registered[name] = nil
  if vim.tbl_isempty(registered) and augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
    augroup = nil
  end
end

return M
