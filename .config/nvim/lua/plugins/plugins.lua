return {
  -- gruvbox-material theme
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.gruvbox_material_enable_bold = true
      vim.g.gruvbox_material_enable_italic = true
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },

  -- nvim-spider plugin
  {
    "chrisgrieser/nvim-spider",
    opts = {},
  },

  -- neo-tree settings
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        width = 28,
      },
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
    },
  },

  -- guess-indent plugin
  {
    "nmac427/guess-indent.nvim",
    opts = {
      auto_cmd = true,
      override_editorconfig = true,
    },
  },

  -- telescope-undo plugin
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { -- note how they're inverted to above example
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>u",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      -- don't use `defaults = { }` here, do this in the main telescope spec
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        -- no other extensions here, they can have their own spec too
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
  },

  -- markdown preview plugin
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
