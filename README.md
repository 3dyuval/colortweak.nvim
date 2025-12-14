# colortweak.nvim

HSL transforms for Neovim highlight groups. Per-colorscheme configuration.

## Spec

```lua
{
  "3dyuval/colortweak.nvim",
  lazy = false,
  opts = {
    ["retro-fallout"] = {
      ft = { yaml = { h = -60 } },
    },
  },
}
```

## Usage

```lua
require("colortweak").setup({
  -- Per-colorscheme config (only applies when that theme is active)
  ["retro-fallout"] = {
    ft = {
      yaml = { h = -60 },      -- more purple, less amber
      markdown = { h = 100 },
    },
    patterns = {
      ["Comment"] = { l = 0.7 },
    },
  },

  ["gruvbox"] = {
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

## Transform values

- `h` - Hue shift in degrees (-360 to 360)
- `s` - Saturation multiplier (0.5 = half, 2 = double)
- `l` - Lightness multiplier (0.5 = darker, 2 = lighter)

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
