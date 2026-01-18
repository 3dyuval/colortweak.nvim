# Understanding Neovim Colors

If you've ever wanted to tweak a color in Neovim and found yourself lost, you're not alone. The [r/neovim wiki](https://www.reddit.com/r/neovim/wiki/index/plugin-colors/) has an excellent deep dive, but here's the gist.

Colors in Neovim aren't applied directly to text. Instead, everything goes through **highlight groups** - named definitions like `Comment`, `Function`, or `Normal` that map to actual colors and styles. When a colorscheme says "comments should be gray and italic," it's setting the `Comment` highlight group. When treesitter parses your code and finds a comment, it tags that text with `Comment`, and Neovim looks up what that means.

This indirection is what makes colorschemes work. Because highlight group names are standardized, a single colorscheme can provide consistent colors across every language without knowing anything about them specifically.

Plugins use the same system. A plugin like Telescope creates its own groups (`TelescopeBorder`, `TelescopeTitle`) and links them to standard ones like `FloatBorder` or `Title`. The linking means your colorscheme's choices flow through automatically - but you can always override the link if you want something different.

## Where colortweak fits in

The traditional way to customize is either hardcoding hex values (which ignore your colorscheme) or linking to a different group (which might not be quite right either).

colortweak offers a third option: derive colors from existing ones. Instead of picking a specific hex or hoping another group looks right, you can say "take `FloatBorder` but shift the hue 30 degrees" or "make `Comment` 20% lighter." The result adapts when you switch colorschemes.
