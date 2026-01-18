# colortweak.nvim

HSL transforms for Neovim highlight groups.
Per-colorscheme configuration.
Tweak colors at the filetype level!

## Understanding Neovim Colors

If you've ever wanted to tweak a color in Neovim and found yourself lost, you're not alone. The [r/neovim wiki](https://www.reddit.com/r/neovim/wiki/index/plugin-colors/) has an excellent deep dive, but here's the gist.

Colors in Neovim aren't applied directly to text. Instead, everything goes through **highlight groups** - named definitions like `Comment`, `Function`, or `Normal` that map to actual colors and styles. When a colorscheme says "comments should be gray and italic," it's setting the `Comment` highlight group. When treesitter parses your code and finds a comment, it tags that text with `Comment`, and Neovim looks up what that means. Run `:highlight` to see all defined groups.

You'll also see groups prefixed with `@` like `@comment` or `@function.python` - these are treesitter capture groups (not CSS at-rules). The `@` just denotes treesitter-specific highlights, and the suffix indicates language scope. Run `:Inspect` on any text to see which groups apply.

This _indirection_ is what makes colorschemes work - similar to how CSS classes let you define `.comment { color: gray }` once and apply it everywhere. Because highlight group names are _standardized_, a single colorscheme can provide consistent colors across every language without knowing anything about them specifically.

A plugin like Snacks creates its own groups (`SnacksPickerBorder`, `SnacksPickerTitle`) and links them to standard ones like `FloatBorder` or `Title`. The linking means your colorscheme's choices flow through automatically - but you can always override the link if you want something different. Run `:highlight SnacksPickerBorder` to see where a group links to.

## Where colortweak fits in

The traditional way to customize is either hardcoding hex values (which ignore your colorscheme) or linking to a different group (which might not be quite right either).

colortweak offers a third option: derive colors from existing ones. Think of it like CSS's `color: hsl(from var(--base) h s calc(l * 1.2))` - you're not picking a fixed value, you're saying "take this and adjust it." Instead of hardcoding a hex or hoping another group looks right, you can say "take `FloatBorder` but shift the hue 30 degrees" or "make `Comment` 20% lighter."

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
  },
}
```

## Customization Options

If you're like me and often switch between colorschemes, **tweaking** each colorscheme in centralized config is now possible:

```lua
-- lua/plugins/colorschemes.lua
return {
  { "shaunsingh/nord.nvim", enabled = true },
  { "3dyuval/retro-fallout.nvim", enabled = true },
  {
    "3dyuval/colortweak.nvim",
    opts = {
      ["nord"] = {
        patterns = { Comment = { l = 0.8 } }, -- lighter comments
      },
      ["retro-fallout"] = {
        patterns = { NormalFloat = { s = 0.8 } }, -- less saturated floats
      },
    },
  },
}
```

## Filetype Transforms

As a designer, I feel some files should feel a bit different. Project-level settings in YAML should trigger a different gut-level response. Having a way to shift hues slightly just for YAML makes it feel exactly like it should. Run `:set ft?` to see the current filetype:

```lua
opts = {
  ["my-theme"] = {
    ft = { yaml = { h = -60 } },
  },
}
```

### `ft`

Filetype-specific transforms. Applies to `@*.{ft}` highlight groups:

```lua
ft = {
  yaml = { h = -60 },      -- shifts @*.yaml groups
  markdown = { h = 100 },  -- shifts @markup.* groups
  json = {
    patterns = {           -- or use explicit patterns
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
require("colortweak").apply() -- reapply transforms
```

## For Plugin Makers

Create highlight groups derived from existing ones:

```lua
local tweak = require("colortweak.tweak")

tweak.hl("MyPluginBorder", "FloatBorder", { h = 30, l = 1.1 })
```

See [docs/recipes.md](docs/recipes.md) for full API and theme integration examples.

## TODO

- [ ] Add benchmarks
- [ ] Cache highlight list
- [ ] Only re-fetch highlights on ColorScheme change

## Contributions

Plugin created with help from AI using [Claude Code](https://claude.ai/code)
