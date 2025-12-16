# colortweak.nvim

HSL transforms for Neovim highlight groups.
Per-colorscheme configuration.
Tweak colors in file type level!

## HSL Transform values

- `h` - Hue shift in degrees (-360 to 360)
- `s` - Saturation multiplier (0.5 = half, 2 = double)
- `l` - Lightness multiplier (0.5 = darker, 2 = lighter)

## Installation

If you're **tweaking** a single colorscheme plugin, you can do it directly in the colorscheme spec (with deps), or by using a dedicated file for all themes and importing the tweak plugin directly:

```lua
{
  "3dyuval/colortweak.nvim",
  lazy = false,
  opts = {
    ["nord"] = {
      patterns = { SnacksPickerDir = { l = 1.2 } },
    },
    global = {
      patterns = { Comment = { l = 0.8 } },
    },
  },
}
```

If you're **tweaking** multiple colorscheme plugins, lazy.nvim merges `opts` tables so each theme file can add its own key:

```lua
-- lua/plugins/nord.lua
return {
  { "shaunsingh/nord.nvim" }, --or using deps = {  "3dyuval/colortweak.nvim"   }
  {
    "3dyuval/colortweak.nvim",
    opts = {
      ["nord"] = {
        patterns = { SnacksPickerDir = { l = 1.2 } },
      },
    },
  },
}
--- todo: add a OR here and tweak nord.Options in setup function
```


```lua
-- lua/plugins/retro-fallout.lua
return {
  { "3dyuval/retro-fallout.nvim" },
  {
    "3dyuval/colortweak.nvim",
    opts = {
      ["retro-fallout"] = {
        ft = { yaml = { h = -60 } },
      },
    },
  },
}

```

## Usage

```lua
require("colortweak").setup({
  ["retro-fallout"] = {   -- only applies when that theme is active
    ft = {
      yaml = { h = -60 },       -- yummy yaml
      markdown = { h = 100 },   -- touch of md
    },
    patterns = {
      ["Comment"] = { l = 0.7 },-- comments should be sparse, making them lighter makes them annoying - as they should be!
    },
  },

  ["nord"] = {
    ft = {
      markdown = { s = 1.2 },  -- more saturated
    },
  },

  -- Global config (applies to all colorschemes)
  global = {
    patterns = {
      ["Comment"] = { l = 0.8 },
    },
  },
})
```

## Options

### Per-colorscheme

Keys matching `vim.g.colors_name` apply only when that colorscheme is active:

```lua
["retro-fallout"] = {
  ft = { ... },
  patterns = { ... },
}
```

### `global`

Applies to all colorschemes. Colorscheme-specific config merges on top:

```lua
global = {
  ft = { yaml = { h = -30 } },
}
```

### `ft`

Filetype-specific transforms. Applies to `@*.{ft}` highlight groups:

```lua
ft = {
  yaml = { h = -60 },           -- shifts @*.yaml groups
  markdown = { h = 100 },       -- shifts @markup.* groups
  json = {
    patterns = {                -- or use explicit patterns
      ["@string.json"] = { h = 50 },
    },
  },
}
```

### `patterns`

Pattern-based transforms. `*` matches any characters:

```lua
patterns = {
  ["@markup.*"] = { h = 100 },
  ["Diagnostic*"] = { s = 1.5 },
  ["Comment"] = { l = 0.8 },
}
```

## API

```lua
require("colortweak").apply()  -- reapply transforms
```

## For Plugin makers! `colortweak.tweak` API

For creating **new highlight groups** derived from existing ones (not **tweaking** in-place).
Useful for plugins that need custom highlights based on the current theme.

```lua
local tweak = require("colortweak.tweak")

-- Create a new group derived from an existing one
tweak.hl("SnacksPickerDir", "Directory", { l = 1.2 })

-- Create multiple at once
tweak.hl({
  ClaudeNormal = { "DiagnosticInfo", { h = 120, s = 1.5 } },
  ClaudeThinking = { "DiagnosticHint", { l = 0.8 } },
})

-- These automatically re-apply on colorscheme change


-- Dimmed highlights for inactive/unfocused elements
tweak.hl({
  InactiveStatusLine = { "StatusLine", { l = 0.6, s = 0.5 } },
  GhostText = { "Comment", { l = 0.7 } },
})

-- Accent colors for plugin UI
tweak.hl({
  MyPluginBorder = { "FloatBorder", { h = 30 } },      -- warmer border
  MyPluginTitle = { "Title", { s = 1.4, l = 1.1 } },   -- more vibrant title
})

-- Get transformed definition without registering
local hl_def = tweak.get("DiagnosticInfo", { h = 120 })
vim.api.nvim_set_hl(0, "MyGroup", hl_def)

-- Cleanup
tweak.remove("ClaudeNormal")  -- unregister one
tweak.clear()                 -- unregister all
```

## TODO

- [ ] Add benchmarks
- [ ] Cache highlight list
- [ ] Only re-fetch highlights on ColorScheme change

## Contributions

Plugin created with help from AI using [Claude Code](https://claude.ai/code)
