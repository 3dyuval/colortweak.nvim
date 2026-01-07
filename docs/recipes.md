# Recipes

## For Plugin Makers - `colortweak.tweak` API

Create **new highlight groups** derived from existing ones. Automatically re-applies on colorscheme change.

```lua
local tweak = require("colortweak.tweak")

-- Single highlight
tweak.hl("MyPluginPopup", "NormalFloat", { l = 1.2 })

-- Multiple at once
tweak.hl({
  MyPluginBorder = { "FloatBorder", { h = 30 } },
  MyPluginTitle = { "Title", { s = 1.4, l = 1.1 } },
  MyPluginDimmed = { "Comment", { l = 0.7 } },
})

-- Get definition without registering
local hl_def = tweak.get("DiagnosticInfo", { h = 120 })
vim.api.nvim_set_hl(0, "MyPluginInfo", hl_def)

-- Cleanup
tweak.remove("MyPluginBorder")  -- unregister one
tweak.clear()                   -- unregister all
```

---

## For Theme Makers

Want to offer colortweak support as an **optional** feature? Here's how to integrate it into your colorscheme plugin.

### Basic Integration

Check if colortweak is available and use it for color transforms:

```lua
-- lua/my-theme/init.lua
local M = {}

local function has_colortweak()
  return pcall(require, "colortweak.color")
end

function M.setup(opts)
  opts = opts or {}

  -- Process color overrides with colortweak if available
  if opts.colors and has_colortweak() then
    local tweak = require("colortweak.color")
    for group, transform in pairs(opts.colors) do
      if type(transform) == "table" and (transform.h or transform.s or transform.l) then
        -- Transform the base color using HSL
        opts.colors[group] = tweak.transform(M.defaults[group], transform)
      end
    end
  end

  -- Apply your theme...
end

return M
```

### Expose Defaults for User Transforms

Let users transform your defaults with a callback pattern:

```lua
-- lua/my-theme/init.lua
local M = {}

M.defaults = {
  bg = "#1a1a2e",
  fg = "#eaeaea",
  accent = "#00d9ff",
  dimmed = "#666688",
}

function M.setup(opts)
  -- Support callback pattern for access to defaults
  if type(opts) == "function" then
    opts = opts(M.defaults)
  end
  opts = opts or {}

  -- Merge user colors with defaults
  local colors = vim.tbl_deep_extend("force", M.defaults, opts.colors or {})

  -- Apply theme with final colors...
end

return M
```

Users can then do:

```lua
require("my-theme").setup(function(defaults)
  local tweak = require("colortweak.color")
  return {
    colors = {
      accent = tweak.transform(defaults.accent, { h = -60 }),  -- shift hue
      dimmed = tweak.transform(defaults.dimmed, { l = 1.2 }),  -- lighter
    },
  }
end)
```

### Pass-through ft Config

Forward filetype transforms to colortweak:

```lua
-- lua/my-theme/init.lua
function M.setup(opts)
  opts = opts or {}

  -- Apply your base theme first
  M.apply_highlights()

  -- If user provided ft config and colortweak exists, set it up
  if opts.ft and has_colortweak() then
    require("colortweak").setup({
      [M.name] = { ft = opts.ft },
    })
  end
end
```

Users get per-filetype transforms:

```lua
require("my-theme").setup({
  ft = {
    yaml = { h = -60 },      -- purple-ish yaml
    markdown = { h = 100 },  -- shift markdown hue
  },
})
```

### Document the Optional Dependency

In your README:

```markdown
## Optional: HSL Color Transforms

With [colortweak.nvim](https://github.com/3dyuval/colortweak.nvim),
you can use HSL transforms instead of hardcoded hex values:

\`\`\`lua
{
  "you/your-theme.nvim",
  dependencies = { "3dyuval/colortweak.nvim" },  -- optional
  config = function()
    require("your-theme").setup({
      colors = {
        accent = { h = -60 },   -- shift hue
        dimmed = { s = 0.8 },   -- reduce saturation
      },
      ft = {
        yaml = { h = -60 },     -- per-filetype transforms
      },
    })
  end,
}
\`\`\`

Transform options:
- `h` - Hue shift in degrees (-360 to 360)
- `s` - Saturation multiplier (0.5 = half, 2 = double)
- `l` - Lightness multiplier (0.5 = darker, 2 = lighter)
```
