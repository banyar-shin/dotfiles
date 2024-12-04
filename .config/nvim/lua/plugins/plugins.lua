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

  -- guess-indent plugin
  {
    "nmac427/guess-indent.nvim",
    opts = {
      auto_cmd = true,
      override_editorconfig = true,
    },
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
        width = 24,
      },
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
    },
  },

  -- disabled plugins
  -- {
  --   "garymjr/nvim-snippets",
  --   enabled = false,
  -- },
  -- {
  --   "rafamadriz/friendly-snippets",
  --   enabled = false,
  -- },
}
