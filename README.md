# `telescope-luasnip`

**THIS PLUGIN IS A WORK IN PROGRES AND DOES NOT FUNCTION YET**

Use [Telescope][2] to search your [LuaSnip][3]

# Installations

Using [Vim Plug][5]:

```lua
-- Install telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

-- Install LuaSnips
Plug 'L3MON4D3/LuaSnip'

--install this integration
Plug 'kbknapp/telescope-luasnip'
```

# Setup

Load the extension:

```lua
-- Ensure LuaSnip is setup
require('luasnip').setup()

-- Ensure telescope is setup
require('telescope').setup()

-- Load the telescope extension
require('telescope').load_extension('luasnip')
```

# Usage

```viml
:Telescope snippets
```

# License

This project is licensed under the terms of the [GPLv2][4]. 
See `LICENSE-GPL` in this repository for details.

# Inspiration

Forked/inspire by [telescope-snippets][1]

[//]:

[1]: https://github.com/Maverun/telescope-snippets
[2]: https://github.com/nvim-telescope/telescope.nvim
[3]: https://github.com/L3MON4D3/LuaSnip
[4]: https://opensource.org/licenses/gpl-2.0.php
